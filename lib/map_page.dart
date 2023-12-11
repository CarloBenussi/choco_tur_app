import 'dart:async';

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/utils/coordinates.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/widgets/drawer.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // ignore: prefer_final_fields
  Set<Marker> _markers = {};

  StreamSubscription<Position>? _userLocationStreamSubscription;

  CameraPosition? _cameraPosition;

  void _moveCameraToCoordinates(LatLng position) async {
    // specified current users location
    CameraPosition cameraPosition = CameraPosition(
      target: position,
      zoom: 14,
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {});
  }

  void _setActiveToursMarkers(
      BuildContext context, int? activeTourId, int? tourNextStopIds) async {
    if (activeTourId != null) {
      _markers.clear();
      SqliteCache cache = await SqliteCache.getInstance();
      List<ChocoTurTourStop> tourStops = await cache.getTourStops(activeTourId);

      for (var j = 0; j < tourStops.length; ++j) {
        ChocoTurTourStop stop = tourStops[j];
        Marker tourStopMarker = Marker(
          markerId:
              MarkerId('${activeTourId.toString()} - ${stop.id.toString()}'),
          position: stop.coordinates,
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: stop.description,
            onTap: () {},
          ),
          icon: await BitmapDescriptor.fromAssetImage(
            // ignore: use_build_context_synchronously
            createLocalImageConfiguration(context, size: const Size(15, 15)),
            'assets/markers/${j + 1}.png',
          ),
        );

        _markers.add(tourStopMarker);
      }

      LoggerInstance.logger.d("Updated tour markers.");
    }
  }

  @override
  void initState() {
    super.initState();

    _cameraPosition ??=
        Provider.of<ChocoTurUser>(context, listen: false).cameraPosition;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO: Resolve issue for Geolocator.
      // _userLocationStreamSubscription =
      //     Coordinates.getUserPositionStream().listen((event) async {
      //   _updateUserLocationMarker(LatLng(event.latitude, event.longitude));
      //   setState(() {});
      // });
    });
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
          body: Stack(
            children: [
              Consumer<ChocoTurUser>(builder: (context, user, child) {
                _setActiveToursMarkers(
                    context, user.activeTour, user.tourNextStopId);
                return GoogleMap(
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
                    _controller.complete(controller);
                  },
                  onCameraMove: (CameraPosition position) {
                    _cameraPosition = position;
                  },
                  markers: _markers,
                );
              }),
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
                  onPressed: () {}, // TODO: Move camera to tour next stop
                  heroTag: "ToursButton",
                  child: const FaIcon(Icons.tour_outlined),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              Coordinates.getUserPosition().then((value) async {
                LatLng latLngValue = LatLng(value.latitude, value.longitude);
                _moveCameraToCoordinates(latLngValue);
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
