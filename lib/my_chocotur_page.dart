import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/my_tours_ui.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:choco_tur/widgets/my_wallet_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyChocoTurPage extends StatefulWidget {
  const MyChocoTurPage({super.key, this.initialIndex});

  final int? initialIndex;

  @override
  State<MyChocoTurPage> createState() => _MyChocoTurPageState();
}

class _MyChocoTurPageState extends State<MyChocoTurPage> {
  List<ChocoTurUserTour>? _getUserTours(BuildContext context) {
    return Provider.of<ChocoTurUser>(context, listen: true).userTours;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex ?? 0,
      length: 2,
      child: Scaffold(
        appBar: ChocoTurAppBar(
          tabBar: TabBar(
            tabs: [
              Tab(
                icon: Icon(
                  Icons.tour_outlined,
                  color: Styles.redShade,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.wallet_outlined,
                  color: Styles.redShade,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        body: const TabBarView(
          children: [
            MyToursUi(),
            MyWalletUi(),
          ],
        ),
        bottomNavigationBar: const ChocoTurNavigationBar(
          selectedIndex: 2,
        ),
      ),
    );
  }
}
