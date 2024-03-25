import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_types;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class TourStopStoryChatPage extends StatefulWidget {
  const TourStopStoryChatPage({super.key, required this.stopId});

  final String stopId;

  @override
  State<TourStopStoryChatPage> createState() => _TourStopStoryChatPageState();
}

class _TourStopStoryChatPageState extends State<TourStopStoryChatPage> {
  final uuid = const Uuid();

  String? _langCode;
  List<ChocoTurStopStory>? _stopStories;
  final chat_types.User _bot = const chat_types.User(
    id: "Bot",
  );
  final chat_types.User _user = const chat_types.User(
    id: "Myself",
  );
  final List<chat_types.Message> _messages = [];
  List<String> _inputOptions = [];
  List<chat_types.User> _typingUsers = [];

  Future<List<ChocoTurStopStory>> _getStopStories(BuildContext context) async {
    _stopStories ??= await WebappService.getTourStopStories(
        context, widget.stopId, Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken);

    return _stopStories!;
  }

  void _chatEnd(BuildContext context) async {
    ChocoTurUserTour? activeUserTour = Provider.of<ChocoTurUser>(context, listen: true).activeTour;
    if (activeUserTour == null) {
      LoggerInstance.logger.e("No active user tour at chat end!");
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else {
      await Provider.of<ChocoTurUser>(listen: false, context).advanceTour(context, activeUserTour);
      Navigator.pushReplacementNamed(context, RouteNames.map);
    }
  }

  void _onInputOptionPressed(BuildContext context, int index, String message) async {
    if (message == AppLocalizations.of(context)!.chatOptionSkip) {
      return _chatEnd(context);
    }

    final textMessage = chat_types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: uuid.v4(),
      text: message,
    );

    setState(() {
      _messages.insert(0, textMessage);
      _typingUsers = [_bot];
      _inputOptions = [];
    });

    // TODO: Sleep 1s.

    var botMessages;
    while (true) {
      bool exit = false;
      if (_stopStories![0].type == ChocoTurStopStoryType.text) {
        botMessages.add(chat_types.TextMessage(
          author: _bot,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: uuid.v4(),
          text: _stopStories![0].texts![_langCode]!,
        ));
      } else if (_stopStories![0].type == ChocoTurStopStoryType.image) {
        // TODO: Add image message.
      } else if (_stopStories![0].type == ChocoTurStopStoryType.answers) {
        for (var answer in _stopStories![0].answers!) {
          _inputOptions.add(answer[_langCode]!);
        }

        exit = true;
      } else if (_stopStories![0].type == ChocoTurStopStoryType.onAnswers) {
        botMessages.add(chat_types.TextMessage(
          author: _bot,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: uuid.v4(),
          text: _stopStories![0].onAnswers![index][_langCode]!,
        ));
      }

      _stopStories!.removeAt(0);
      if (_stopStories!.isEmpty) {
        _inputOptions = [AppLocalizations.of(context)!.chatOptionSkip];
        break;
      } else if (exit) {
        break;
      }
    }

    for (var botMessage in botMessages) {
      setState(() {
        _messages.insert(0, botMessage);
      });
    }

    setState(() {
      _typingUsers = [];
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _langCode = Provider.of<ChocoTurUser>(context, listen: true).language;

    _messages.add(chat_types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: uuid.v4(),
      text: AppLocalizations.of(context)!.chatWelcomeMessage,
    ));

    _inputOptions = [];
    _inputOptions.add(AppLocalizations.of(context)!.chatOptionChat);
    _inputOptions.add(AppLocalizations.of(context)!.chatOptionAudio);
    _inputOptions.add(AppLocalizations.of(context)!.chatOptionSkip);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const ChocoTurAppBar(),
        body: FutureBuilder(
          future: _getStopStories(context),
          builder: (context, toursSnapshot) {
            if (toursSnapshot.hasData &&
                toursSnapshot.connectionState == ConnectionState.done &&
                toursSnapshot.data != null) {
              return Chat(
                messages: _messages,
                onSendPressed: (text) {}, // Null on purpose
                theme: const DefaultChatTheme(
                  backgroundColor: Colors.white,
                  inputBackgroundColor: Colors.white,
                ),
                customBottomWidget: Row(
                  children: [
                    for (var i = 0; i < _inputOptions.length; ++i) ...[
                      TextButton(
                        onPressed: () => _onInputOptionPressed(context, i, _inputOptions[i]),
                        style: TextButton.styleFrom(
                          backgroundColor: Styles.redShade,
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          _inputOptions[i],
                          style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ]
                  ],
                ),
                user: _user,
                typingIndicatorOptions: TypingIndicatorOptions(
                  typingUsers: _typingUsers,
                ),
              );
            } else {
              return const LoadingAnimation();
            }
          },
        ),
        bottomNavigationBar: const ChocoTurNavigationBar(),
      ),
    );
  }
}
