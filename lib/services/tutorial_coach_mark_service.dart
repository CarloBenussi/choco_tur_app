import 'dart:ui';

import 'package:choco_tur/utils/global_keys.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TutorialCoachMarkService {
  static TutorialCoachMark? _tutorial;

  static TargetFocus createTarget(
      String identify, GlobalKey key, String title, String description, ContentAlign align) {
    return TargetFocus(
      identify: identify,
      keyTarget: key,
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
                style: const TextStyle(fontWeight: FontWeight.bold, color: Styles.gold, fontSize: 16.0),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  description,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Styles.gold, fontSize: 12.0),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context) {
    if (_tutorial != null) {
      List<TargetFocus> targets = [];
      targets.add(createTarget("navigatorHomeButtonKey", GlobalKeys.navigatorHomeButtonKey, "HOME BUTTON",
          "Does this and that", ContentAlign.right));
      targets.add(createTarget(
          "Target 2", GlobalKeys.navigatorMapButtonKey, "MAP BUTTON", "Does this and that", ContentAlign.top));
      targets.add(createTarget("Target 3", GlobalKeys.navigatorMyChocoTurButtonKey, "MY CHOCOTUR BUTTON",
          "Does this and that", ContentAlign.left));

      _tutorial = TutorialCoachMark(
          targets: targets, // List<TargetFocus>
          colorShadow: Colors.red, // DEFAULT Colors.black
          alignSkip: Alignment.bottomRight,
          textSkip: AppLocalizations.of(context)!.skipButton,
          textStyleSkip: const TextStyle(color: Styles.onRedShade, fontWeight: FontWeight.bold),
          paddingFocus: 10,
          opacityShadow: 0.8,
          focusAnimationDuration: const Duration(milliseconds: 500),
          unFocusAnimationDuration: const Duration(milliseconds: 500),
          pulseAnimationDuration: const Duration(milliseconds: 500),
          showSkipInLastTarget: true,
          imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          initialFocus: 0,
          useSafeArea: true,
          onFinish: () => {Navigator.pushNamed(context, RouteNames.home)},
          onClickTargetWithTapPosition: (target, tapDetails) {
            print("target: $target");
            print("clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
          },
          onClickTarget: (target) {},
          onSkip: () {
            return true;
          });
    }

    Navigator.pushNamed(context, RouteNames.home);
    _tutorial!.show(context: context);
  }
}
