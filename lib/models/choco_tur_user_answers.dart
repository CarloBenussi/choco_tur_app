import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:flutter/material.dart';

class ChocoTurUserAnswers extends ChangeNotifier {
  static Future<ChocoTurUserAnswers> init(ChocoTurUser user) async {
    List<ChocoTurUserAnswer>? userAnswers;
    if (user.loggedIn) {
      userAnswers = await WebappService.getUserAnswers(user.loginAccessToken);
    }

    return ChocoTurUserAnswers(user: user, userAnswers: userAnswers);
  }

  ChocoTurUserAnswers({
    required this.user,
    this.userAnswers,
  }) {
    user.addListener(_onLoginChange);
  }

  ChocoTurUser user;
  List<ChocoTurUserAnswer>? userAnswers;

  void _onLoginChange() async {
    // If we logged in (no previous user answers and user is logged), download answers.
    if ((userAnswers == null) && user.loggedIn) {
      userAnswers = await WebappService.getUserAnswers(user.loginAccessToken);
    }
    // If we logged out (previous user answers and user is not logged), nullify answers.
    else if ((userAnswers != null) && !user.loggedIn) {
      userAnswers = null;
    }
    notifyListeners();
  }

  Future<void> recordAnswer(BuildContext context, String answerId) async {
    bool recordAnswerSuccess = await WebappService.recordUserAnswer(context, user.loginAccessToken, answerId);
    if (!recordAnswerSuccess) {
      LoggerInstance.logger.e('Failed to record answer $answerId on webapp');
    }

    // NOTE: Should not happen.
    if (userAnswers == null) {
      userAnswers = [
        ChocoTurUserAnswer.fromMap({"id": answerId})
      ];
    } else {
      userAnswers!.add(ChocoTurUserAnswer.fromMap({"id": answerId}));
    }
    notifyListeners();
  }

  bool containsAnswer(String answerId) {
    if (userAnswers != null) {
      for (var userAnswer in userAnswers!) {
        if (userAnswer.id == answerId) return true;
      }
    }

    return false;
  }

  @override
  void dispose() {
    user.removeListener(_onLoginChange);
    super.dispose();
  }
}
