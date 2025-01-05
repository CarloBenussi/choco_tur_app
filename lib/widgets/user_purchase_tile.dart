import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserPurchaseTile extends StatefulWidget {
  const UserPurchaseTile({super.key, required this.userPurchase, required this.onRedeem});

  final ChocoTurUserPurchaseInfo userPurchase;
  final Function(BuildContext context, ChocoTurUserPurchaseInfo userPurchase) onRedeem;

  @override
  State<UserPurchaseTile> createState() => _UserPurchaseTileState();
}

class _UserPurchaseTileState extends State<UserPurchaseTile> {
  String? _langCode;
  String _description = "";

  void _onRedeem(BuildContext context) {
    Navigator.pop(context);

    widget.onRedeem(context, widget.userPurchase);
  }

  void _onPressed(BuildContext context) {
    showChocoTurDialog(
      context: context,
      title: "TEST",
      description: "BLABLA",
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

    _description = "DESCRIPTION WITH OFFER CONDITIONS AND TERMS BLABLA";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Styles.redShade,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
          enabled: !widget.userPurchase.redeemed,
          textColor: Styles.onRedShade,
          iconColor: Styles.onRedShade,
          leading: const Icon(Icons.star_outlined),
          title: Text(
            "TITLE OF PURCHASE",
            textAlign: TextAlign.center,
          ),
          dense: false,
          onTap: () => (!widget.userPurchase.redeemed) ? _onPressed : null,
          trailing: IconButton(
            onPressed: () => {
              showChocoTurDialog(
                context: context,
                title: "REDEEM",
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
    );
  }
}
