import 'package:choco_tur/models/choco_tur_user_coins.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class PrizeListTile extends StatefulWidget {
  const PrizeListTile(
      {super.key, required this.cost, required this.title, required this.info, required this.onPressed});

  final int cost;
  final String title;
  final String info;
  final Function(BuildContext context) onPressed;

  @override
  State<PrizeListTile> createState() => _PrizeListTileState();
}

class _PrizeListTileState extends State<PrizeListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Styles.redShade,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
          enabled: ((Provider.of<ChocoTurUserCoins>(context, listen: true).collectedCoins != null) &&
              (Provider.of<ChocoTurUserCoins>(context, listen: true).collectedCoins! >= widget.cost)),
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
                    widget.cost.toString(),
                    style: const TextStyle(fontSize: 16, color: Styles.onRedShade),
                  ),
                )
              ],
            ),
          ),
          title: Text(
            widget.title,
            textAlign: TextAlign.center,
          ),
          dense: false,
          onTap: () => widget.onPressed,
          trailing: IconButton(
            onPressed: () => {
              showChocoTurDialog(
                context: context,
                title: widget.title,
                description: widget.info,
                icon: const Icon(Icons.info_outlined),
                dismissable: true,
              )
            },
            icon: Icon(
              Icons.info_outlined,
            ),
            color: Styles.onRedShade,
          )),
    );
  }
}
