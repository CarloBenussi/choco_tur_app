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
        body: Center(
          child: Builder(builder: (context) {
            if (Provider.of<ChocoTurUser>(context).loggedIn) {
              return const LoginButton();
            } else {
              return const Placeholder();
            }
          }),
        ),
        bottomNavigationBar: const ChocoTurNavigationBar(),
      ),
    );
  }
}
