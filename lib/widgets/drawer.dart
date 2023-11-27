import 'package:flutter/material.dart';

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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          )),
          ListTile(
            leading: Icon(
              Icons.tour_outlined,
            ),
            title: Text("My tours"),
          ),
          Divider(
            thickness: 0.5,
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(
              Icons.settings_outlined,
            ),
            title: Text("Settings"),
          ),
          ListTile(
            leading: Icon(
              Icons.logout_outlined,
            ),
            title: Text("Logout"),
          ),
          Divider(
            thickness: 0.5,
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(
              Icons.question_mark_outlined,
            ),
            title: Text("Guide and Feedback"),
          ),
          ListTile(
            leading: Icon(
              Icons.info_outline_rounded,
            ),
            title: Text("About"),
          ),
        ],
      ),
    );
  }
}
