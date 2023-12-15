import 'dart:async';
import 'dart:ui' as ui;

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/utils/coordinates.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/widgets/drawer.dart';
import 'package:choco_tur/widgets/generic_alert_dialog.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
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

  bool? _showGoToNextStopDialog;

  int? _lastActiveTourId;
  int? _lastTourNextStopId;

  // ignore: prefer_final_fields
  Future<Set<Marker>>? _markers;

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
        Provider.of<ChocoTurUser>(context, listen: true).activeTourId;
    int? tourNextStopId =
        Provider.of<ChocoTurUser>(context, listen: true).tourNextStopId;

    _lastActiveTourId = activeTourId;
    _lastTourNextStopId = tourNextStopId;
    Set<Marker> markers = {};
    if (activeTourId != null) {
      SqliteCache cache = await SqliteCache.getInstance();
      List<ChocoTurTourStop> tourStops = await cache.getTourStops(activeTourId);

      for (var i = 0; i < tourStops.length; ++i) {
        final ChocoTurTourStop stop = tourStops[i];
        final String markerIdStr =
            '${activeTourId.toString()} - ${stop.id.toString()}';
        final Uint8List markerIcon =
            await _getBytesFromAsset('assets/markers/${i + 1}.png', 100);

        Marker? tourStopMarker;
        if (stop.id == tourNextStopId) {
          tourStopMarker = RippleMarker(
            markerId: MarkerId(markerIdStr),
            position: stop.coordinates,
            infoWindow: InfoWindow(
                title: stop.name,
                snippet: stop.description,
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.tourStopStoryPages,
                      arguments: stop.id);
                }),
            icon: BitmapDescriptor.fromBytes(markerIcon),
          );
        } else {
          tourStopMarker = Marker(
            markerId: MarkerId(markerIdStr),
            position: stop.coordinates,
            infoWindow: InfoWindow(
              title: stop.name,
              snippet: stop.description,
            ),
            icon: BitmapDescriptor.fromBytes(markerIcon),
          );
        }

        if (!markers.add(tourStopMarker)) {
          LoggerInstance.logger.w('Marker $markerIdStr is already in set!');
        }
      }
    }

    return markers;
  }

  @override
  void initState() {
    super.initState();

    _cameraPosition ??=
        Provider.of<ChocoTurUser>(context, listen: false).cameraPosition;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if ((_showGoToNextStopDialog != null) && _showGoToNextStopDialog!) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.red.shade300,
            icon: const Icon(Icons.arrow_forward_rounded),
            iconColor: Colors.white,
            title: Text(
              AppLocalizations.of(context)!.goToTheNextStop,
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
                AppLocalizations.of(context)!.goToTheNextStopIndication,
                style: const TextStyle(color: Colors.white)),
            elevation: 24.0,
          ),
          barrierDismissible: true,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _markers = _getActiveToursMarkers(context);

    var showGoToNextStopDialogObj = ModalRoute.of(context)!.settings.arguments;
    if (showGoToNextStopDialogObj != null) {
      _showGoToNextStopDialog = showGoToNextStopDialogObj as bool;
    }
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
            future: _markers,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: [
                    Animarker(
                      curve: Curves.ease,
                      rippleRadius: 0.1,
                      mapId: _controller.future.then<int>(
                          (value) => value.mapId), //Grab Google Map Id
                      markers: snapshot.data!,
                      child: GoogleMap(
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
                    ),
                    // ),
                    Positioned(
                      left: 15,
                      top: 15,
                      child: DrawerButton(
                        style: ButtonStyle(
                          iconColor:
                              const MaterialStatePropertyAll(Colors.white),
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.red.shade300),
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
                              builder: (_) => GenericAlertDialog(
                                title: AppLocalizations.of(context)!
                                    .goToTheNextStopIndication,
                                content: AppLocalizations.of(context)!
                                    .goToTheNextStopIndication,
                              ),
                              barrierDismissible: true,
                            );
                          }
                        },
                        heroTag: "ToursButton",
                        backgroundColor: Colors.red.shade300,
                        child: const FaIcon(
                          Icons.tour_outlined,
                          color: Colors.white,
                        ),
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
            backgroundColor: Colors.red.shade300,
            child: const FaIcon(
              Icons.my_location_rounded,
              color: Colors.white,
            ),
          ),
          bottomNavigationBar: const ChocoTurNavigationBar(
            selectedIndex: 1,
          ),
        ),
      ),
    );
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
