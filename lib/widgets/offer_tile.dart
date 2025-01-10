import 'dart:ui';

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/models/choco_tur_user_wallet.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/dialog.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OfferTile extends StatefulWidget {
  const OfferTile({super.key, required this.offer});

  final ChocoTurOffer offer;

  @override
  State<OfferTile> createState() => _OfferTileState();
}

class _OfferTileState extends State<OfferTile> {
  String? _langCode;
  bool _isEnabled = false;
  String _description = "";
  bool _processing = false;

  void _onPurchase(BuildContext context) async {
    Navigator.pop(context);

    setState(() {
      _processing = true;
    });

    await Provider.of<ChocoTurUserWallet>(context, listen: false).purchaseOffer(context, widget.offer);

    setState(() {
      _processing = false;
    });
  }

  void _onPressed(BuildContext context) {
    showChocoTurDialog(
      context: context,
      title: AppLocalizations.of(context)!.purchaseOfferQuestion,
      description: AppLocalizations.of(context)!.purchaseOfferQuestionDescription,
      actions: [
        TextButton(
            onPressed: () => {Navigator.pop(context)},
            child: Text(
              AppLocalizations.of(context)!.noButton,
              style: const TextStyle(color: Styles.onRedShade),
            )),
        TextButton(
            onPressed: () => _onPurchase(context),
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

    _isEnabled = ((Provider.of<ChocoTurUserWallet>(context, listen: true).collectedCoins != null) &&
        (Provider.of<ChocoTurUserWallet>(context, listen: true).collectedCoins! >= widget.offer.tokensCost));
    _langCode = Provider.of<ChocoTurUser>(context, listen: true).language;

    var duration = Duration(seconds: widget.offer.duration);
    _description =
        '${widget.offer.descriptions[_langCode]!} \n\n ${widget.offer.businessIds.toString()} \n\n ${AppLocalizations.of(context)!.conditions}: ${widget.offer.conditions[_langCode]!} \n ${AppLocalizations.of(context)!.validForRedeem} \n\n ${AppLocalizations.of(context)!.validFor}: ${printDuration(duration, abbreviated: true, upperTersity: DurationTersity.hour)}';
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
              enabled: _isEnabled,
              textColor: Styles.onRedShade,
              iconColor: Styles.onRedShade,
              leading: LimitedBox(
                maxWidth: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.coins,
                      size: 16,
                      color: Styles.onRedShade,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        widget.offer.tokensCost.toString(),
                        style: const TextStyle(fontSize: 16, color: Styles.onRedShade),
                      ),
                    )
                  ],
                ),
              ),
              title: Text(
                widget.offer.titles[_langCode]!,
                textAlign: TextAlign.center,
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
