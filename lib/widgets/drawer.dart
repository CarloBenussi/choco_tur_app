import 'package:flutter/material.dart';

class ChocoTurDrawer extends StatelessWidget {
  const ChocoTurDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
              child: Text(
            "ChocoTur",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          )),
          const ListTile(
            leading: Icon(
              Icons.tour_outlined,
            ),
            title: Text("My tours"),
          ),
          const Divider(
            thickness: 0.5,
            color: Colors.grey,
          ),
          const ListTile(
            leading: Icon(
              Icons.settings_outlined,
            ),
            title: Text("Settings"),
          ),
          const ListTile(
            leading: Icon(
              Icons.account_circle_outlined,
            ),
            title: Text("Account"),
          ),
          ListTile(
              leading: const Icon(
                Icons.logout_outlined,
              ),
              title: const Text("Logout"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text("Are you sure you want to logout?"),
                    content: Text(
                        "User preferences such as language and camera position will be lost"),
                    actions: [
                      TextButton(onPressed: null, child: Text("Yes")),
                      TextButton(onPressed: null, child: Text("No")),
                    ],
                    elevation: 24.0,
                  ),
                  barrierDismissible: false,
                );
              }),
          const Divider(
            thickness: 0.5,
            color: Colors.grey,
          ),
          const ListTile(
            leading: Icon(
              Icons.question_mark_outlined,
            ),
            title: Text("Guide and Feedback"),
          ),
          ListTile(
              leading: const Icon(
                Icons.info_outline_rounded,
              ),
              title: const Text("About"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const AboutDialog(),
                  barrierDismissible: true,
                );
              }),
        ],
      ),
    );
  }
}
