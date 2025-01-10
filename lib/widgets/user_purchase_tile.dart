import 'dart:ui';

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/dialog.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slide_countdown/slide_countdown.dart';

class UserPurchaseTile extends StatefulWidget {
  const UserPurchaseTile({super.key, required this.userPurchase, required this.offer});

  final ChocoTurUserPurchaseInfo userPurchase;
  final ChocoTurOffer offer;

  @override
  State<UserPurchaseTile> createState() => _UserPurchaseTileState();
}

class _UserPurchaseTileState extends State<UserPurchaseTile> {
  String? _langCode;
  Duration? _duration;
  String _description = "";
  bool _processing = false;

  void _onRedeem(BuildContext context) {
    Navigator.pop(context);

    setState(() {
      _processing = true;
    });

    // TODO: await Code and stuff

    setState(() {
      _processing = false;
    });
  }

  void _onPressed(BuildContext context) {
    showChocoTurDialog(
      context: context,
      title: "TEST: REDEEM",
      description: "DO YOU WANT TO REDEEM? AT WHICH SHOP?",
      actions: [
        TextButton(
            onPressed: () => {Navigator.pop(context)},
            child: Text(
              AppLocalizations.of(context)!.noButton,
              style: const TextStyle(color: Styles.onRedShade),
            )),
        TextButton(
            onPressed: () => _onRedeem(context),
            child: Text(
              AppLocalizations.of(context)!.yesButton,
              style: const TextStyle(color: Styles.onRedShade),
            )),
      ],
      dismissable: true,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _langCode = Provider.of<ChocoTurUser>(context, listen: true).language;

    int currentTimeMs = DateTime.now().millisecondsSinceEpoch;
    _duration = Duration(milliseconds: (int.parse(widget.userPurchase.expiryTime) - currentTimeMs));
    _description =
        '${widget.offer.descriptions[_langCode]!} \n\n ${widget.offer.businessIds.toString()} \n\n ${AppLocalizations.of(context)!.conditions}: ${widget.offer.conditions[_langCode]!}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Styles.redShade,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
              enabled: !widget.userPurchase.redeemed,
              textColor: Styles.onRedShade,
              iconColor: Styles.onRedShade,
              leading: const FaIcon(
                FontAwesomeIcons.check,
                size: 16,
                color: Styles.onRedShade,
              ),
              title: Text(
                widget.offer.titles[_langCode]!,
                textAlign: TextAlign.center,
              ),
              subtitle: Center(
                child: SlideCountdown(
                  duration: _duration,
                  style: const TextStyle(color: Styles.onRedShade),
                  decoration: BoxDecoration(color: Styles.redShade),
                ),
              ),
              dense: false,
              onTap: () => {_onPressed(context)},
              trailing: IconButton(
                onPressed: () => {
                  showChocoTurDialog(
                    context: context,
                    title: widget.offer.titles[_langCode]!,
                    description: _description,
                    icon: const Icon(Icons.info_outlined),
                    dismissable: true,
                  )
                },
                icon: const Icon(
                  Icons.info_outlined,
                ),
                color: Styles.onRedShade,
              )),
        ),
        if (_processing)
          Flexible(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              ),
              child: const Center(
                child: LoadingAnimation(),
              ),
            ),
          ),
      ],
    );
  }
}
