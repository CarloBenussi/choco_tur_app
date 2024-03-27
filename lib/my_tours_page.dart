import 'dart:ui';

import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/login_button.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyTourPage extends StatefulWidget {
  const MyTourPage({super.key});

  @override
  State<MyTourPage> createState() => _MyTourPageState();
}

class _MyTourPageState extends State<MyTourPage> {
  List<ChocoTurUserTour>? _userTours;
  bool _processing = false;

  List<ChocoTurUserTour>? _getUserTours(BuildContext context) {
    return Provider.of<ChocoTurUser>(context, listen: true).userTours;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _userTours = _getUserTours(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChocoTurAppBar(),
      backgroundColor: Colors.white,
      body: Consumer<ChocoTurUser>(
        builder: (context, user, child) {
          if ((_userTours != null) && (_userTours!.isNotEmpty)) {
            return Column(
              children: [
                Flexible(
                  child: ListView.separated(
                    itemCount: _userTours!.length,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(5),
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 5);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Styles.redShade,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          textColor: Styles.onRedShade,
                          leading: const Icon(Icons.tour_outlined),
                          iconColor: Styles.onRedShade,
                          title: Text(_userTours![index].title),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                backgroundColor: Styles.onRedShade,
                                valueColor: const AlwaysStoppedAnimation<Color>(Styles.gold),
                                value: _userTours![index].progress,
                              ),
                              Text(
                                _userTours![index].isActive
                                    ? AppLocalizations.of(context)!.active
                                    : AppLocalizations.of(context)!.inactive,
                                style: const TextStyle(color: Styles.onRedShade),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<PopupMenuItem>(
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                onTap: () async {
                                  setState(() {
                                    _processing = true;
                                  });
                                  await user.advanceTour(context, _userTours![index]);
                                  setState(() {
                                    _processing = false;
                                  });
                                },
                                child: Text(AppLocalizations.of(context)!.nextStop),
                              ),
                              PopupMenuItem(
                                onTap: () async {
                                  setState(() {
                                    _processing = true;
                                  });
                                  await user.revertTourStop(context, _userTours![index]);
                                  setState(() {
                                    _processing = false;
                                  });
                                },
                                child: Text(AppLocalizations.of(context)!.previousStop),
                              ),
                              PopupMenuItem(
                                onTap: () async {
                                  setState(() {
                                    _processing = true;
                                  });
                                  await user.deactivateTour(context, _userTours![index]);
                                  setState(() {
                                    _processing = false;
                                  });
                                },
                                child: Text(AppLocalizations.of(context)!.deactivate),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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
          } else if (!Provider.of<ChocoTurUser>(context, listen: false).loggedIn) {
            return const Center(child: LoginButton());
          } else {
            return Center(child: Text(AppLocalizations.of(context)!.noUserTourFound));
          }
        },
      ),
      bottomNavigationBar: const ChocoTurNavigationBar(
        selectedIndex: 2,
      ),
    );
  }
}
