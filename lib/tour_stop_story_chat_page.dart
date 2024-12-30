import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:choco_tur/map_page.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/models/choco_tur_user_answers.dart';
import 'package:choco_tur/models/choco_tur_user_coins.dart';
import 'package:choco_tur/services/firebase_service.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/audio_message.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_types;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class UserInputOption {
  final String option;
  final ChocoTurStoryAnswerAction action;
  final bool? correct;
  final String? uuid;

  UserInputOption(this.option, [this.action = ChocoTurStoryAnswerAction.none, this.correct, this.uuid]);
}

class TourStopStoryChatPage extends StatefulWidget {
  const TourStopStoryChatPage({
    super.key,
    required this.stopStories,
    required this.audioId,
    required this.tastingId,
  });

  final List<ChocoTurStopStory> stopStories;
  final String? audioId;
  final String? tastingId;

  @override
  State<TourStopStoryChatPage> createState() => _TourStopStoryChatPageState();
}

class _TourStopStoryChatPageState extends State<TourStopStoryChatPage> {
  final uuid = const Uuid();
  String? _langCode;

  final chat_types.User _bot = const chat_types.User(
    id: "Bot",
    firstName: "ChocoTur",
  );
  late final chat_types.User? _user;
  final List<chat_types.Message> _messages = [];
  List<UserInputOption> _inputOptions = [];
  List<chat_types.User> _typingUsers = [];

  ChocoTurStoryAnswerAction _actionFromAnswer(Map<String, dynamic> answer) {
    ChocoTurStoryAnswerAction ret = ChocoTurStoryAnswerAction.none;
    if (answer.containsKey("action")) {
      if (ChocoTurStoryAnswerAction.skip.name == answer["action"]) {
        ret = ChocoTurStoryAnswerAction.skip;
      } else if (ChocoTurStoryAnswerAction.skipOptions.name == answer["action"]) {
        ret = ChocoTurStoryAnswerAction.skipOptions;
      } else if (ChocoTurStoryAnswerAction.audio.name == answer["action"]) {
        ret = ChocoTurStoryAnswerAction.audio;
      } else if (ChocoTurStoryAnswerAction.finishWithPause.name == answer["action"]) {
        ret = ChocoTurStoryAnswerAction.finishWithPause;
      }
    }

    return ret;
  }

  bool _isAnswerCorrect(Map<String, dynamic> answer) {
    bool ret = false;
    if (answer.containsKey("correct")) {
      ret = answer["correct"];
    }

    return ret;
  }

  IconData _getIconForInputOption(UserInputOption inputOption) {
    if (inputOption.action == ChocoTurStoryAnswerAction.skip) {
      return Icons.arrow_forward_outlined;
    } else if (inputOption.action == ChocoTurStoryAnswerAction.skipOptions) {
      return Icons.arrow_circle_right_outlined;
    } else if (inputOption.action == ChocoTurStoryAnswerAction.audio) {
      return Icons.audiotrack_outlined;
    } else if (inputOption.action == ChocoTurStoryAnswerAction.finishWithPause) {
      return Icons.emoji_food_beverage_outlined;
    } else if (inputOption.option == AppLocalizations.of(context)!.chatOptionChat) {
      return Icons.chat_bubble_outlined;
    } else {
      return Icons.circle_rounded;
    }
  }

  void _chatEnd(BuildContext context, ChocoTurStoryAnswerAction action) async {
    bool skipOptions =
        ((action == ChocoTurStoryAnswerAction.skipOptions) || (action == ChocoTurStoryAnswerAction.finishWithPause));
    ChocoTurUserTour? activeUserTour = Provider.of<ChocoTurUser>(context, listen: false).activeTour;
    if (activeUserTour == null) {
      LoggerInstance.logger.e("No active user tour at chat end!");
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else {
      await Provider.of<ChocoTurUser>(listen: false, context).advanceTour(context, activeUserTour, skipOptions);
      // Select the intro window depending on tasting present or pause.
      IntroDialogType introDialogType = (widget.tastingId != null)
          ? IntroDialogType.askForTastingReview
          : (action == ChocoTurStoryAnswerAction.finishWithPause)
              ? IntroDialogType.goToNextStopAfterPause
              : IntroDialogType.goToNextStop;
      IntroDialog introDialog = IntroDialog(introDialogType, widget.tastingId);
      Navigator.pushReplacementNamed(context, RouteNames.map, arguments: introDialog);
    }
  }

  Future<void> _recordUserAnswer(String answerId, bool correct) async {
    if (Provider.of<ChocoTurUserAnswers>(listen: false, context).containsAnswer(answerId)) {
      LoggerInstance.logger.i('Answer with ID $answerId is already registered for user');
      return;
    }

    await Provider.of<ChocoTurUserAnswers>(listen: false, context).recordAnswer(context, answerId);
    if (correct) {
      await Provider.of<ChocoTurUserCoins>(listen: false, context).addCollectedCoins(context, 1);
    }
  }

  void _onInputOptionPressed(BuildContext context, int index, UserInputOption inputOption) async {
    final textMessage = chat_types.TextMessage(
      author: _user!,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: uuid.v4(),
      text: inputOption.option,
    );

    setState(() {
      _messages.insert(0, textMessage);
      _inputOptions = [];
    });

    if ([
      ChocoTurStoryAnswerAction.skip,
      ChocoTurStoryAnswerAction.skipOptions,
      ChocoTurStoryAnswerAction.finishWithPause
    ].contains(inputOption.action)) {
      return _chatEnd(context, inputOption.action);
    } else if (inputOption.action == ChocoTurStoryAnswerAction.audio) {
      setState(() {
        _typingUsers = [_bot];
      });

      Uint8List audio = await FirebaseService.downloadAudio(_langCode!, widget.audioId!);
      Directory privateFileDir = await getApplicationDocumentsDirectory();
      File file = File('${privateFileDir.path}/${widget.audioId!}');
      file.writeAsBytes(audio);

      var audioMessage = chat_types.AudioMessage(
        author: _bot,
        duration: Duration(milliseconds: (audio.length * 8 / 190).round()),
        id: uuid.v4(),
        name: widget.audioId!,
        size: audio.length,
        uri: file.path,
        mimeType: "mp3",
      );

      setState(() {
        _messages.insert(0, audioMessage);
        _typingUsers = [];
        _inputOptions.add(UserInputOption(AppLocalizations.of(context)!.chatOptionChat));
        _inputOptions
            .add(UserInputOption(AppLocalizations.of(context)!.chatOptionSkip, ChocoTurStoryAnswerAction.skip));
      });
    } else {
      setState(() {
        _typingUsers = [_bot];
      });

      await Future.delayed(const Duration(milliseconds: 200));

      // TRICKY: We identify answers that need to be recorded for the user only the ones
      // that are marked with the 'correct' flag, as they are the only ones that might lead to
      // coins gain.
      if ((inputOption.correct != null) && (inputOption.uuid != null)) {
        await _recordUserAnswer(inputOption.uuid!, inputOption.correct!);
      }

      var botMessages = [];
      List<UserInputOption> inputOptions = [];
      while (true) {
        bool exit = false;
        ChocoTurStopStory story = widget.stopStories[0];
        if (story.type == ChocoTurStopStoryType.text) {
          botMessages.add(chat_types.TextMessage(
            author: _bot,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: uuid.v4(),
            text: story.texts![_langCode]!,
          ));
        } else if (story.type == ChocoTurStopStoryType.image) {
          // TODO: Add image message.
        } else if (story.type == ChocoTurStopStoryType.answers) {
          for (var answer in story.answers!) {
            inputOptions.add(UserInputOption(
              answer[_langCode]!,
              _actionFromAnswer(answer),
              _isAnswerCorrect(answer),
              story.id,
            ));
          }

          // We have some options for the user, exit the loop.
          exit = true;
        } else if (story.type == ChocoTurStopStoryType.onAnswers) {
          botMessages.add(chat_types.TextMessage(
            author: _bot,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: uuid.v4(),
            text: story.onAnswers![index][_langCode]!,
          ));
        }

        widget.stopStories.removeAt(0);
        if (widget.stopStories.isEmpty && inputOptions.isEmpty) {
          inputOptions = [UserInputOption(AppLocalizations.of(context)!.chatOptionEnd, ChocoTurStoryAnswerAction.skip)];
          break;
        } else if (exit) {
          break;
        }
      }

      for (var botMessage in botMessages) {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _messages.insert(0, botMessage);
        });
      }

      setState(() {
        _inputOptions = inputOptions;
        _typingUsers = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _langCode = Provider.of<ChocoTurUser>(context, listen: false).language;
    _user = chat_types.User(
      id: "Myself",
      firstName: AppLocalizations.of(context)!.you,
    );

    _inputOptions = [];
    if (widget.audioId != null) {
      _messages.add(chat_types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: uuid.v4(),
        text: AppLocalizations.of(context)!.chatWelcomeMessageOptions,
      ));

      _inputOptions.add(UserInputOption(AppLocalizations.of(context)!.chatOptionChat));
      _inputOptions
          .add(UserInputOption(AppLocalizations.of(context)!.chatOptionAudio, ChocoTurStoryAnswerAction.audio));
      _inputOptions.add(UserInputOption(AppLocalizations.of(context)!.chatOptionSkip, ChocoTurStoryAnswerAction.skip));
    } else {
      _messages.add(chat_types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: uuid.v4(),
        text: AppLocalizations.of(context)!.chatWelcomeMessageChat,
      ));

      _inputOptions.add(UserInputOption(AppLocalizations.of(context)!.chatOptionChat));
      _inputOptions.add(UserInputOption(AppLocalizations.of(context)!.chatOptionSkip, ChocoTurStoryAnswerAction.skip));
    }
    // Add skip all input options

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ChatTheme theme = DefaultChatTheme(
      backgroundColor: Colors.white,
      inputBackgroundColor: Colors.white,
      primaryColor: Styles.pinkShade,
      secondaryColor: Styles.redShade,
      receivedMessageBodyTextStyle: const TextStyle(color: Colors.white),
      sentMessageBodyTextStyle: const TextStyle(color: Colors.white),
    );
    return SafeArea(
      child: Center(
        child: Chat(
          messages: _messages,
          user: _user!,
          typingIndicatorOptions: TypingIndicatorOptions(
            typingUsers: _typingUsers,
          ),
          onSendPressed: (text) {}, // Null on purpose
          theme: theme,
          audioMessageBuilder: (chat_types.AudioMessage message, {required int messageWidth}) {
            return AudioMessage(
              message: message,
              messageWidth: messageWidth,
              theme: theme,
            );
          },
          customBottomWidget: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1.5,
                  color: Styles.pinkShade,
                ),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              direction: Axis.horizontal,
              spacing: 10.0,
              children: [
                for (var i = 0; i < _inputOptions.length; ++i) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _onInputOptionPressed(context, i, _inputOptions[i]),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.pinkShade,
                        minimumSize: Size.zero,
                      ),
                      label: Text(
                        _inputOptions[i].option,
                        style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.white),
                        overflow: TextOverflow.visible,
                      ),
                      icon: Icon(_getIconForInputOption(_inputOptions[i]), color: Colors.white),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
