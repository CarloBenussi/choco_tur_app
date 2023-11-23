import 'dart:async';

import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/drawer.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  MapPage({super.key});

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _turinCenter = CameraPosition(
    target: LatLng(45.07049, 7.68682),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const ChocoTurAppBar(),
      drawer: const ChocoTurDrawer(),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _turinCenter,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ],
      ),
      bottomNavigationBar: const ChocoTurNavigationBar(
        selectedIndex: 1,
      ),
    );
  }
}
