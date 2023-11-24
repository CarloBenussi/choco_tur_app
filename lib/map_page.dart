import 'dart:async';

import 'package:choco_tur/utils/coordinates.dart';
import 'package:choco_tur/widgets/drawer.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final List<Marker> _markers = <Marker>[
    const Marker(
        markerId: MarkerId('1'),
        position: Coordinates.turinCenter,
        infoWindow: InfoWindow(
          title: 'My Position',
        )),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const ChocoTurDrawer(),
      body: Stack(
        children: [
          SafeArea(
            child: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: const CameraPosition(
                target: Coordinates.turinCenter,
                zoom: 14.4746,
              ),
              myLocationEnabled: true,
              compassEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          const Positioned(
            left: 20,
            top: 20,
            child: DrawerButton(
              style: ButtonStyle(
                iconColor: MaterialStatePropertyAll(Colors.black),
                backgroundColor: MaterialStatePropertyAll(Colors.white),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Coordinates.getUserPosition().then((value) async {
            // Marker added for current users location
            _markers.add(Marker(
              markerId: const MarkerId("2"),
              position: LatLng(value.latitude, value.longitude),
              infoWindow: const InfoWindow(
                title: 'My Current Location',
              ),
            ));

            // specified current users location
            CameraPosition cameraPosition = CameraPosition(
              target: LatLng(value.latitude, value.longitude),
              zoom: 14,
            );

            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});
          });
        },
        child: const FaIcon(Icons.my_location_rounded),
      ),
      bottomNavigationBar: const ChocoTurNavigationBar(
        selectedIndex: 1,
      ),
    );
  }
}
