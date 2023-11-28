import 'package:choco_tur/utils/logger.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Coordinates {
  static void _checkPermission() async {
    // Test if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      throw const PermissionDeniedException('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true). According to Android guidelines
        // your App should show an explanatory UI now.
        throw const PermissionDeniedException(
            'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw const PermissionDeniedException(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  static Future<Position> getUserPosition() async {
    try {
      _checkPermission();
    } on PermissionDeniedException {
      return Future.error("Got no permissions.");
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    // Try to get last user position first.
    try {
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return Future.value(lastKnownPosition);
      }
    } on PlatformException {
      LoggerInstance.logger.w("Unsupported last known location.");
    }

    return Geolocator.getCurrentPosition();
  }

  static Stream<Position> getUserPositionStream() {
    try {
      _checkPermission();
    } on PermissionDeniedException {
      return Stream.error("Got no permissions.");
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return Geolocator.getPositionStream(
        locationSettings: const LocationSettings(distanceFilter: 5));
  }

  static const LatLng turinCenter = LatLng(45.07049, 7.68682);
}
