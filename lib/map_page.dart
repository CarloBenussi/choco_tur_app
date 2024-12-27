// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:ui' as ui;

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/firebase_service.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/coordinates.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/drawer.dart';
import 'package:choco_tur/widgets/dialog.dart';
import 'package:choco_tur/widgets/info_window_widget.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/marker_info_window.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

enum IntroDialogType {
  goToNextStop,
  goToNextStopAfterPause,
  askForTastingReview,
}

class IntroDialog {
  IntroDialogType type;
  String? tastingId;
  double? tastingScore;

  IntroDialog(this.type, [this.tastingId]);
}

// ignore: must_be_immutable
class MapPage extends StatefulWidget {
  MapPage({super.key});

  double closeZoom = 17;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  InfoWidgetRoute? _infoWidgetRoute;

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  IntroDialog? _introDialog;

  List<ChocoTurStop>? _activeTourStops;
  int? _nextStopIndex;
  String? _langCode;

  // ignore: prefer_final_fields
  Future<Set<Marker>>? _markers;
  // ignore: prefer_final_fields
  Set<Polyline> _polylines = {};

  CameraPosition? _cameraPosition;

  /// First it creates the Info Widget Route and then
  /// animates the Camera to the stop coordinates.
  void _onTap(BuildContext context, ChocoTurStop stop, [double? zoom]) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    Rect itemRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;

    _infoWidgetRoute = InfoWidgetRoute(
      barrierLabel: "BarrierLable",
      child: MarkerInfoWindow(
        stop: stop,
        getDirectionsToStop: _drawPolyline,
      ),
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

  Future<Uint8List> _getMarkerBytes(String path, int width) async {
    Uint8List markerBytes = await FirebaseService.downloadImage(path);
    ui.Codec codec = await ui.instantiateImageCodec(markerBytes, targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    Uint8List ret = (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    fi.image.dispose();
    return ret;
  }

  Future<Set<Marker>> _getActiveToursMarkers(BuildContext context) async {
    ChocoTurUserTour? activeUserTour = Provider.of<ChocoTurUser>(context, listen: true).activeTour;

    Set<Marker> markers = {};
    if (activeUserTour != null) {
      _activeTourStops = await WebappService.getTourStops(
          context, activeUserTour.id, Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken);
      if (_activeTourStops != null) {
        for (var i = 0; i < _activeTourStops!.length; ++i) {
          final ChocoTurStop stop = _activeTourStops![i];
          final String markerIdStr = '${activeUserTour.id.toString()} - ${stop.id.toString()}';
          Marker? tourStopMarker;
          if (stop.id == activeUserTour.nextStopId) {
            final Uint8List markerIcon = await _getMarkerBytes('markers/${i + 1}g.png', 100);
            _nextStopIndex = i;
            tourStopMarker = Marker(
                markerId: MarkerId(markerIdStr),
                position: stop.coordinates,
                icon: BitmapDescriptor.fromBytes(markerIcon),
                onTap: () => _onTap(context, stop));
          } else {
            final Uint8List markerIcon = await _getMarkerBytes('markers/${i + 1}.png', 100);
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

  Future<void> _drawPolyline(LatLng destination) async {
    Position userPosition = await Coordinates.getUserPosition();

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      const String.fromEnvironment('GOOGLE_MAPS_API_KEY'),
      PointLatLng(userPosition.latitude, userPosition.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.walking,
    );
    _polylines.clear();
    _polylines.add(Polyline(
      polylineId: const PolylineId("Tour Line"),
      color: Styles.redShade,
      patterns: const [PatternItem.dot],
      points: List.from(result.points.map((e) => LatLng(e.latitude, e.longitude))),
      width: 3,
    ));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _cameraPosition ??= Provider.of<ChocoTurUser>(context, listen: false).cameraPosition;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_introDialog != null) {
        switch (_introDialog!.type) {
          case IntroDialogType.goToNextStop:
            showChocoTurDialog(
              context: context,
              icon: const Icon(Icons.arrow_forward_rounded),
              title: AppLocalizations.of(context)!.goToTheNextStop,
              description: AppLocalizations.of(context)!.goToTheNextStopIndication,
              dismissable: true,
            );

          case IntroDialogType.goToNextStopAfterPause:
            showChocoTurDialog(
              context: context,
              icon: const Icon(Icons.arrow_forward_rounded),
              title: AppLocalizations.of(context)!.goToTheNextStopAfterPause,
              description: AppLocalizations.of(context)!.goToTheNextStopIndication,
              dismissable: true,
            );

          case IntroDialogType.askForTastingReview:
            ChocoTurTasting? tasting = await WebappService.getTasting(
                context, Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken, _introDialog!.tastingId!);
            if (tasting != null) {
              showChocoTurDialog(
                context: context,
                icon: const Icon(Icons.cake),
                title: AppLocalizations.of(context)!.askIfTastingDoneTitle,
                description:
                    '${AppLocalizations.of(context)!.askIfTastingDonePart1}${tasting.titles[_langCode]}${AppLocalizations.of(context)!.askIfTastingDonePart2}${_activeTourStops![_nextStopIndex! - 1].titles[_langCode]}?',
                actions: [
                  TextButton(
                      onPressed: () => {Navigator.pop(context)},
                      child: Text(
                        AppLocalizations.of(context)!.noButton,
                        style: const TextStyle(color: Styles.onRedShade),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showChocoTurDialog(
                          context: context,
                          icon: const Icon(Icons.cake),
                          title: AppLocalizations.of(context)!.askIfTastingDoneTitle,
                          description: AppLocalizations.of(context)!.askForTastingScore,
                          actions: [
                            RatingBar.builder(
                              initialRating: 3,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Image.asset(
                                "assets/chocolateIcon.png",
                                width: 25,
                              ),
                              onRatingUpdate: (rating) {
                                _introDialog!.tastingScore = rating;
                              },
                            ),
                            TextButton(
                                onPressed: () {
                                  WebappService.reviewTasting(
                                      context,
                                      Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken,
                                      Provider.of<ChocoTurUser>(context, listen: false).loginEmail!,
                                      _introDialog!.tastingId!,
                                      _introDialog!.tastingScore! / 5);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.sendButton,
                                  style: const TextStyle(color: Styles.onRedShade),
                                )),
                          ],
                          dismissable: true,
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.yesButton,
                        style: const TextStyle(color: Styles.onRedShade),
                      )),
                ],
                dismissable: true,
              );
            }

          default:
            return;
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _langCode = Provider.of<ChocoTurUser>(context, listen: true).language;
    _markers = _getActiveToursMarkers(context);

    var introDialogObj = ModalRoute.of(context)!.settings.arguments;
    if (introDialogObj != null) {
      _introDialog = introDialogObj as IntroDialog;
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
                    GoogleMap(
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
                      polylines: _polylines,
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
                      child: FloatingActionButton(
                        onPressed: () async {
                          if ((_activeTourStops != null) && (_nextStopIndex != null)) {
                            // ChocoTurUserTour? activeUserTour =
                            //     Provider.of<ChocoTurUser>(context, listen: false).activeTour;
                            // ChocoTurStop stop = _activeTourStops!.elementAt(
                            //     _activeTourStops!.indexWhere((element) => (element.id == activeUserTour!.nextStopId)));
                            // Navigator.popAndPushNamed(context, RouteNames.tourStopStoryChat, arguments: stop);
                            _onTap(context, _activeTourStops![_nextStopIndex!], widget.closeZoom);
                          } else {
                            showChocoTurDialog(
                              context: context,
                              title: AppLocalizations.of(context)!.noActiveTourToGoTo,
                              description: AppLocalizations.of(context)!.noActiveTourToGoToIndication,
                              dismissable: true,
                            );
                          }
                        },
                        heroTag: "ToursButton",
                        backgroundColor: Styles.redShade,
                        child: const Icon(
                          Icons.tour_outlined,
                          color: Styles.onRedShade,
                        ),
                      ),
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
                _moveCameraToCoordinates(latLngValue, widget.closeZoom);
              }).onError((error, stackTrace) async {
                LoggerInstance.logger.e("Error getting user position.");
              });
            },
            heroTag: "UserPositionButton",
            backgroundColor: Styles.redShade,
            child: const Icon(
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
