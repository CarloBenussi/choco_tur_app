import 'dart:async';
import 'dart:ui' as ui;

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/services/firebase_service.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/dashed_line.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore: must_be_immutable
class TourStopInfos extends StatelessWidget {
  TourStopInfos({
    super.key,
    required this.langCode,
    required this.tourStopInfos,
  });

  final String langCode;
  final List<ChocoTurTourStopInfo> tourStopInfos;

  Polyline? _polyline;
  Set<Marker>? _markers;

  Future<Uint8List> _getMarkerBytes(String path, int width) async {
    Uint8List markerBytes = await FirebaseService.downloadImage(path);
    ui.Codec codec = await ui.instantiateImageCodec(markerBytes, targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<Set<Marker>> _getMarkers() async {
    if (_markers == null) {
      _markers = {};
      int markerId = 0;
      for (var tourStopInfo in tourStopInfos) {
        final Uint8List markerIcon = await _getMarkerBytes('markers/${markerId + 1}.png', 70);
        Marker marker = Marker(
          markerId: MarkerId(markerId.toString()),
          position: tourStopInfo.coordinates,
          icon: BitmapDescriptor.fromBytes(markerIcon),
          infoWindow: InfoWindow(
            title: tourStopInfo.titles[langCode],
          ),
        );
        _markers!.add(marker);
        markerId++;
      }

      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        const String.fromEnvironment('GOOGLE_MAPS_API_KEY'),
        PointLatLng(_markers!.first.position.latitude, _markers!.first.position.longitude),
        PointLatLng(_markers!.last.position.latitude, _markers!.last.position.longitude),
        travelMode: TravelMode.walking,
        wayPoints: List.from(
          _markers!.skip(1).take(_markers!.length - 1).map((e) =>
              PolylineWayPoint(location: '${e.position.latitude.toString()},${e.position.longitude.toString()}')),
        ),
      );
      _polyline = Polyline(
        polylineId: const PolylineId("Tour Line"),
        color: Styles.redShade,
        patterns: const [PatternItem.dot],
        points: List.from(result.points.map((e) => LatLng(e.latitude, e.longitude))),
        width: 2,
      );
    }

    return _markers!;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < tourStopInfos.length; ++i) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Styles.redShade,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      tourStopInfos[i].titles[langCode]!,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w300, color: Colors.black),
                    ),
                  )
                ],
              ),
              if (i < tourStopInfos.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: DashedLine(
                    length: 15,
                    direction: Axis.vertical,
                  ),
                ),
            ]
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: FutureBuilder(
            future: _getMarkers(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                return LimitedBox(
                  maxHeight: MediaQuery.of(context).size.width / 2,
                  maxWidth: MediaQuery.of(context).size.width / 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: snapshot.data!.first.position,
                        zoom: 14.4746,
                      ),
                      mapToolbarEnabled: false,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      compassEnabled: false,
                      markers: snapshot.data!,
                      polylines: {_polyline!},
                      gestureRecognizers: {}..add(Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())),
                    ),
                  ),
                );
              } else {
                return const LoadingAnimation();
              }
            },
          ),
        )
      ],
    );
  }
}
