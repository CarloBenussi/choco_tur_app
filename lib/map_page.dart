import 'dart:async';
import 'dart:ui' as ui;

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/utils/coordinates.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/drawer.dart';
import 'package:choco_tur/widgets/info_window_widget.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/map_tour_button.dart';
import 'package:choco_tur/widgets/marker_info_window.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  InfoWidgetRoute? _infoWidgetRoute;

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  bool? _showGoToNextStopDialog;

  List<ChocoTurStop>? _activeTourStops;
  LatLng? _nextStopCoordinates;
  String? _langCode;

  // ignore: prefer_final_fields
  Future<Set<Marker>>? _markers;

  CameraPosition? _cameraPosition;

  /// First it creates the Info Widget Route and then
  /// animates the Camera to the stop coordinates.
  void _onTap(BuildContext context, ChocoTurStop stop, [double? zoom]) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    Rect itemRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;

    _infoWidgetRoute = InfoWidgetRoute(
      barrierLabel: "BarrierLable",
      child: MarkerInfoWindow(stop: stop),
      buildContext: context,
      textStyle: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      mapsWidgetSize: itemRect,
    );

    _moveCameraToCoordinates(stop.coordinates, zoom);
  }

  void _moveCameraToCoordinates(LatLng position, [double? zoom]) async {
    final GoogleMapController controller = await _controller.future;

    CameraPosition cameraPosition = CameraPosition(
      target: position,
      zoom: zoom ?? await controller.getZoomLevel(),
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<Set<Marker>> _getActiveToursMarkers(BuildContext context) async {
    ChocoTurUserTour? activeUserTour = Provider.of<ChocoTurUser>(context, listen: true).activeTour;

    Set<Marker> markers = {};
    if (activeUserTour != null) {
      SqliteCache cache = await SqliteCache.getInstance();
      _activeTourStops = await cache.getTourStops(activeUserTour.id);
      if (_activeTourStops != null) {
        for (var i = 0; i < _activeTourStops!.length; ++i) {
          final ChocoTurStop stop = _activeTourStops![i];
          final String markerIdStr = '${activeUserTour.id.toString()} - ${stop.id.toString()}';
          final Uint8List markerIcon = await _getBytesFromAsset('assets/markers/${i + 1}.png', 100);

          Marker? tourStopMarker;
          if (stop.id == activeUserTour.nextStopId) {
            _nextStopCoordinates = stop.coordinates;
            tourStopMarker = RippleMarker(
                markerId: MarkerId(markerIdStr),
                position: stop.coordinates,
                icon: BitmapDescriptor.fromBytes(markerIcon),
                // ignore: use_build_context_synchronously
                onTap: () => _onTap(context, stop));
          } else {
            tourStopMarker = Marker(
              markerId: MarkerId(markerIdStr),
              position: stop.coordinates,
              infoWindow: InfoWindow(
                title: stop.titles[_langCode],
              ),
              icon: BitmapDescriptor.fromBytes(markerIcon),
            );
          }

          if (!markers.add(tourStopMarker)) {
            LoggerInstance.logger.w('Marker $markerIdStr is already in set!');
          }
        }
      }
    }

    return markers;
  }

  @override
  void initState() {
    super.initState();

    _cameraPosition ??= Provider.of<ChocoTurUser>(context, listen: false).cameraPosition;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if ((_showGoToNextStopDialog != null) && _showGoToNextStopDialog!) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Styles.redShade,
            icon: const Icon(Icons.arrow_forward_rounded),
            iconColor: Styles.onRedShade,
            title: Text(
              AppLocalizations.of(context)!.goToTheNextStop,
              style: const TextStyle(color: Styles.onRedShade),
            ),
            content: Text(AppLocalizations.of(context)!.goToTheNextStopIndication,
                style: const TextStyle(color: Styles.onRedShade)),
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

    _langCode = Provider.of<ChocoTurUser>(context, listen: true).language;
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
          Provider.of<ChocoTurUser>(context, listen: false).setCameraPosition(_cameraPosition!);
        }
      },
      child: SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          drawer: const ChocoTurDrawer(),
          body: FutureBuilder(
            future: _markers,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: [
                    Animarker(
                      curve: Curves.ease,
                      rippleRadius: 0.1,
                      mapId: _controller.future.then<int>((value) => value.mapId), //Grab Google Map Id
                      markers: snapshot.data!,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: (_cameraPosition != null)
                            ? _cameraPosition!
                            : const CameraPosition(
                                target: Coordinates.turinCenter,
                                zoom: 14.4746,
                              ),
                        mapToolbarEnabled: false,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: true,
                        onMapCreated: (GoogleMapController controller) {
                          if (!_controller.isCompleted) {
                            _controller.complete(controller);
                          }
                        },

                        /// If onCameraIdle does not work see https://github.com/flutter/flutter/issues/37682)
                        onCameraIdle: () {
                          if (_infoWidgetRoute != null) {
                            Navigator.of(context, rootNavigator: true).push(_infoWidgetRoute!).then<void>(
                              (newValue) {
                                _infoWidgetRoute = null;
                              },
                            );
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
                          iconColor: const MaterialStatePropertyAll(Styles.onRedShade),
                          backgroundColor: MaterialStatePropertyAll(Styles.redShade),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      bottom: 85,
                      child: MapTourButton(_nextStopCoordinates, _moveCameraToCoordinates),
                    ),
                  ],
                );
              } else {
                return const Center(child: LoadingAnimation());
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
            backgroundColor: Styles.redShade,
            child: const FaIcon(
              Icons.my_location_rounded,
              color: Styles.onRedShade,
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
    if (_cameraPosition != null) {
      Provider.of<ChocoTurUser>(context, listen: false).setCameraPosition(_cameraPosition!);
    }

    super.dispose();
  }
}
