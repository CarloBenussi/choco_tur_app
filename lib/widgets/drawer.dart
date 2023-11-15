import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChocoTurDrawer extends StatelessWidget {
  const ChocoTurDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          DrawerHeader(
              child: Text(
            "ChocoTur",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w600, color: Colors.blue),
          )),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.cartShopping,
              color: Colors.blue,
            ),
            title: Text("Purchased tours"),
          ),
          ListTile(),
          ListTile(),
        ],
      ),
    );
  }
}
