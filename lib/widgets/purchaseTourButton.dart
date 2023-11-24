import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class PurchaseTourButton extends StatelessWidget {
  PurchaseTourButton({
    super.key,
    required this.onPressedFunction,
    required this.purchased,
  });

  void Function()? onPressedFunction;
  bool purchased;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: purchased ? () {} : onPressedFunction,
      icon: FaIcon(
        purchased ? Icons.check_rounded : FontAwesomeIcons.cartShopping,
        color: Colors.white,
      ),
      label: Text(
        purchased ? "Tour purchased" : "Purchase tour",
        style: const TextStyle(fontSize: 15, color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: purchased ? Colors.green : Colors.blue),
    );
  }
}
