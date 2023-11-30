import 'dart:async';

import 'package:choco_tur/models/choco_tur_user.dart';
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

  static const MarkerId _userLocationMarkerId = MarkerId("1");

  // ignore: prefer_final_fields
  Set<Marker> _markers = {};

  StreamSubscription<Position>? _userLocationStreamSubscription;

  CameraPosition? _cameraPosition;

  void _initUserLocation() async {
    Coordinates.getUserPosition().then((value) async {
      LatLng latLngValue = LatLng(value.latitude, value.longitude);
      _markers.add(
        Marker(
          markerId: _userLocationMarkerId,
          position: latLngValue,
          infoWindow: const InfoWindow(
            title: 'My Current Location',
          ),
          icon: await BitmapDescriptor.fromAssetImage(
            createLocalImageConfiguration(context, size: const Size(15, 15)),
            "assets/myLocation.png",
          ),
        ),
      );
    }).onError((error, stackTrace) async {
      LoggerInstance.logger.e("Error getting user position.");
    });

    setState(() {});
  }

  void _updateUserLocationMarker(LatLng position) async {
    Marker newUserLocationMarker = Marker(
      markerId: _userLocationMarkerId,
      position: position,
      infoWindow: const InfoWindow(
        title: 'My Current Location',
      ),
      icon: await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context, size: const Size(15, 15)),
        "assets/myLocation.png",
      ),
    );

    // Update user location marker to new instance.
    _markers = _markers
        .map((e) =>
            e.markerId == _userLocationMarkerId ? newUserLocationMarker : e)
        .toSet();
  }

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

  @override
  void initState() {
    super.initState();

    _cameraPosition ??=
        Provider.of<ChocoTurUser>(context, listen: false).cameraPosition;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initUserLocation();

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
                  _controller.complete(controller);
                },
                onCameraMove: (CameraPosition position) {
                  _cameraPosition = position;
                },
                markers: _markers,
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
                top: 15,
                child: FloatingActionButton(
                  onPressed: () {},
                  child: const FaIcon(Icons.my_location_rounded),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              Coordinates.getUserPosition().then((value) async {
                LatLng latLngValue = LatLng(value.latitude, value.longitude);
                _updateUserLocationMarker(latLngValue);
                _moveCameraToCoordinates(latLngValue);
              }).onError((error, stackTrace) async {
                LoggerInstance.logger.e("Error getting user position.");
              });
            },
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
