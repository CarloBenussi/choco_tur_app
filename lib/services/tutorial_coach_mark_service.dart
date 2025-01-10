import 'dart:ui';

import 'package:choco_tur/utils/global_keys.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TutorialCoachMarkService {
  static TutorialCoachMark? _tutorial;

  static TargetFocus _createTarget(String identify, String title, String description, ContentAlign align) {
    return TargetFocus(
      identify: identify,
      keyTarget: GlobalKeys.globalKeysMap[identify],
      color: Styles.onRedShade,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: align,
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.bold, color: Styles.redShade, fontSize: 16.0),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  description,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Styles.redShade, fontSize: 12.0),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  static TargetFocus _createTargetPosition(
      String identify, TargetPosition targetPosition, String title, String description, ContentAlign align) {
    return TargetFocus(
      identify: identify,
      targetPosition: targetPosition,
      color: Styles.onRedShade,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: align,
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.bold, color: Styles.redShade, fontSize: 16.0),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  description,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Styles.redShade, fontSize: 12.0),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  static Future<void> _onClick(BuildContext context, TargetFocus target) async {
    if (target.identify == GlobalKeys.NAVIGATOR_MYCHOCOTUR_BUTTON_KEY) {
      Navigator.pushNamed(context, RouteNames.myChocoTur);
    }
  }

  static void show(BuildContext context) {
    if (_tutorial == null) {
      List<TargetFocus> targets = [];
      // Entry target.
      final Size windowSize = MediaQueryData.fromView(window).size;
      targets.add(TargetFocus(
          identify: "TutorialIntro",
          targetPosition: TargetPosition(Size.zero, Offset(windowSize.width / 2, windowSize.height / 2)),
          color: Styles.onRedShade,
          enableOverlayTab: true,
          contents: [
            TargetContent(
                align: ContentAlign.top,
                padding: const EdgeInsets.all(5.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)!.tutorialIntroTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Styles.redShade, fontSize: 16.0),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            AppLocalizations.of(context)!.tutorialIntroHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Styles.redShade, fontSize: 12.0),
                          ))
                    ]))
          ]));
      targets.add(_createTarget(
          GlobalKeys.HOME_TOURS_TITLE_KEY,
          AppLocalizations.of(context)!.tutorialHomeToursTitleTitle,
          AppLocalizations.of(context)!.tutorialHomeToursTitleHint,
          ContentAlign.right));
      targets.add(_createTargetPosition(
          GlobalKeys.APP_BAR_DRAWER_KEY,
          TargetPosition(const Size.fromRadius(50), const Offset(0, 30)),
          AppLocalizations.of(context)!.tutorialAppBarDrawerTitle,
          AppLocalizations.of(context)!.tutorialAppBarDrawerHint,
          ContentAlign.bottom));
      targets.add(_createTarget(GlobalKeys.APP_BAR_TOKENS_KEY, AppLocalizations.of(context)!.tutorialAppBarTokensTitle,
          AppLocalizations.of(context)!.tutorialAppBarTokensHint, ContentAlign.bottom));
      targets.add(_createTarget(
          GlobalKeys.NAVIGATOR_HOME_BUTTON_KEY,
          AppLocalizations.of(context)!.tutorialNavigationHomeButtonTitle,
          AppLocalizations.of(context)!.tutorialNavigationHomeButtonHint,
          ContentAlign.right));
      targets.add(_createTarget(
          GlobalKeys.NAVIGATOR_MAP_BUTTON_KEY,
          AppLocalizations.of(context)!.tutorialNavigationMapButtonTitle,
          AppLocalizations.of(context)!.tutorialNavigationMapButtonHint,
          ContentAlign.top));
      targets.add(_createTarget(
          GlobalKeys.NAVIGATOR_MYCHOCOTUR_BUTTON_KEY,
          AppLocalizations.of(context)!.tutorialNavigationMyChocoTurButtonTitle,
          AppLocalizations.of(context)!.tutorialNavigationMyChocoTurButtonHint,
          ContentAlign.left));

      _tutorial = TutorialCoachMark(
          targets: targets, // List<TargetFocus>
          colorShadow: Colors.red, // DEFAULT Colors.black
          alignSkip: Alignment.bottomRight,
          textSkip: AppLocalizations.of(context)!.skipButton,
          textStyleSkip: TextStyle(color: Styles.redShade, fontWeight: FontWeight.bold),
          paddingFocus: 10,
          opacityShadow: 0.6,
          focusAnimationDuration: const Duration(milliseconds: 500),
          unFocusAnimationDuration: const Duration(milliseconds: 500),
          pulseAnimationDuration: const Duration(milliseconds: 500),
          showSkipInLastTarget: true,
          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          initialFocus: 0,
          useSafeArea: true,
          onFinish: () => {Navigator.pushNamed(context, RouteNames.home)},
          onClickTarget: (target) => {_onClick(context, target)},
          onClickOverlay: (target) => {_onClick(context, target)},
          onSkip: () {
            return true;
          });
    }

    Navigator.pushNamed(context, RouteNames.home);
    _tutorial!.show(context: context);
  }
}
