import 'dart:async';
import 'dart:ui' as ui;

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/utils/coordinates.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/widgets/drawer.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  int? _lastActiveTourId;
  int? _lastTourNextStopId;
  // ignore: prefer_final_fields
  Set<Marker> _markers = {};

  StreamSubscription<Position>? _userLocationStreamSubscription;

  CameraPosition? _cameraPosition;

  void _moveCameraToCoordinates(LatLng position, double zoom) async {
    // specified current users location
    CameraPosition cameraPosition = CameraPosition(
      target: position,
      zoom: zoom,
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<Set<Marker>> _getActiveToursMarkers(BuildContext context) async {
    int? activeTourId =
        Provider.of<ChocoTurUser>(context, listen: true).activeTour;
    int? tourNextStopId =
        Provider.of<ChocoTurUser>(context, listen: true).tourNextStopId;

    // If nothing has changed wrt active tours, return same markers.
    if ((_lastActiveTourId == activeTourId) &&
        (_lastTourNextStopId == tourNextStopId)) {
      return _markers;
    }

    _lastActiveTourId = activeTourId;
    _lastTourNextStopId = tourNextStopId;
    _markers.clear();

    if (activeTourId != null) {
      SqliteCache cache = await SqliteCache.getInstance();
      List<ChocoTurTourStop> tourStops = await cache.getTourStops(activeTourId);

      for (var i = 0; i < tourStops.length; ++i) {
        final ChocoTurTourStop stop = tourStops[i];
        final String markerIdStr =
            '${activeTourId.toString()} - ${stop.id.toString()}';
        final Uint8List markerIcon =
            await _getBytesFromAsset('assets/markers/${i + 1}.png', 120);
        Marker tourStopMarker = Marker(
          markerId: MarkerId(markerIdStr),
          position: stop.coordinates,
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: stop.description,
            onTap: () {
              Navigator.pushNamed(context, "/tour_stop_story_pages",
                  arguments: stop.id);
            },
          ),
          icon: BitmapDescriptor.fromBytes(markerIcon),
        );

        if (!_markers.add(tourStopMarker)) {
          LoggerInstance.logger.w('Marker $markerIdStr is already in set!');
        }
      }

      LoggerInstance.logger.d("Updated tour markers.");
    }

    return _markers;
  }

  @override
  void initState() {
    super.initState();

    _cameraPosition ??=
        Provider.of<ChocoTurUser>(context, listen: false).cameraPosition;

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _userLocationStreamSubscription =
    //       Coordinates.getUserPositionStream().listen((event) async {
    //     setState(() {});
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusLost: () {
        if (_cameraPosition != null) {
          Provider.of<ChocoTurUser>(context, listen: false)
              .setCameraPosition(_cameraPosition!);
        }
      },
      child: SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          drawer: const ChocoTurDrawer(),
          body: FutureBuilder(
            future: _getActiveToursMarkers(context),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: (_cameraPosition != null)
                          ? _cameraPosition!
                          : const CameraPosition(
                              target: Coordinates.turinCenter,
                              zoom: 14.4746,
                            ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      compassEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        if (!_controller.isCompleted) {
                          _controller.complete(controller);
                        }
                      },
                      onCameraMove: (CameraPosition position) {
                        _cameraPosition = position;
                      },
                      markers: snapshot.data!,
                    ),
                    const Positioned(
                      left: 15,
                      top: 15,
                      child: DrawerButton(
                        style: ButtonStyle(
                          iconColor: MaterialStatePropertyAll(Colors.white),
                          backgroundColor: MaterialStatePropertyAll(Colors.red),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      bottom: 85,
                      child: FloatingActionButton(
                        onPressed: () async {
                          if (_lastActiveTourId != null) {
                            SqliteCache cache = await SqliteCache.getInstance();
                            ChocoTurTourStop stop = await cache
                                .getTourStopFromId(_lastTourNextStopId!);
                            _moveCameraToCoordinates(stop.coordinates, 16);
                          } else {
                            showDialog(
                              context: context,
                              builder: (_) => const AlertDialog(
                                title: Text("No active choco tur to go to"),
                                content: Text(
                                    "Once a tour is activated, this button will move the camera to the tour's next stop."),
                                elevation: 24.0,
                              ),
                              barrierDismissible: true,
                            );
                          }
                        },
                        heroTag: "ToursButton",
                        child: const FaIcon(Icons.tour_outlined),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              Coordinates.getUserPosition().then((value) async {
                LatLng latLngValue = LatLng(value.latitude, value.longitude);
                _moveCameraToCoordinates(latLngValue, 14);
              }).onError((error, stackTrace) async {
                LoggerInstance.logger.e("Error getting user position.");
              });
            },
            heroTag: "UserPositionButton",
            child: const FaIcon(Icons.my_location_rounded),
          ),
          bottomNavigationBar: const ChocoTurNavigationBar(
            selectedIndex: 1,
          ),
        ),
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() async {
    if (_userLocationStreamSubscription != null) {
      _userLocationStreamSubscription!.cancel();
    }

    if (_cameraPosition != null) {
      Provider.of<ChocoTurUser>(context, listen: false)
          .setCameraPosition(_cameraPosition!);
    }

    super.dispose();
  }
}
