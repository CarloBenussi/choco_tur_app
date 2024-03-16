import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/coordinates.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TourStopInfos extends StatefulWidget {
  const TourStopInfos({
    super.key,
    required this.langCode,
    required this.tourStopInfos,
  });

  final String langCode;
  final List<ChocoTurTourStopInfo> tourStopInfos;

  @override
  State<TourStopInfos> createState() => _TourStopInfosState();
}

class _TourStopInfosState extends State<TourStopInfos> {
  static const double widgetSize = 200;

  int _currentSelectedIndex = 0;
  final Set<Marker> _markers = {};

  void _onPressed(int index) {
    setState(() {
      _currentSelectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    int markerId = 1;
    for (var tourStopInfo in widget.tourStopInfos) {
      Marker marker = Marker(
        markerId: MarkerId(markerId.toString()),
        position: tourStopInfo.coordinates,
      );
      _markers.add(marker);
      markerId++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < widget.tourStopInfos.length; ++i) ...[
              ElevatedButton(
                onPressed: () => _onPressed(i),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: (i == _currentSelectedIndex) ? Colors.white : Styles.redShade,
                  fixedSize: const Size(15, 15),
                ),
                child: null,
              ),
              if (i < widget.tourStopInfos.length - 1)
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: DashedLine(
                    length: widgetSize,
                    direction: Axis.vertical,
                  ),
                ),
            ]
          ],
        ),
        SizedBox(
          height: widgetSize,
          width: widgetSize,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: Coordinates.turinCenter,
                zoom: 14.4746,
              ),
              mapToolbarEnabled: false,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              compassEnabled: true,
              markers: _markers,
            ),
          ),
        )
      ],
    );
  }
}
