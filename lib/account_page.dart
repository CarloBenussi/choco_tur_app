import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/login_button.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const ChocoTurAppBar(),
        backgroundColor: Colors.white,
        body: Builder(builder: (context) {
          if (!Provider.of<ChocoTurUser>(context).loggedIn) {
            return const Center(child: LoginButton());
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        "Email",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        Provider.of<ChocoTurUser>(context).loginEmail!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.black),
                      ),
                    ],
                  )
                ],
              ),
            );
          }
        }),
        bottomNavigationBar: const ChocoTurNavigationBar(),
      ),
    );
  }
}
