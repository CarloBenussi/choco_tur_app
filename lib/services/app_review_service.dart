import 'package:in_app_review/in_app_review.dart';

class AppReviewService {
  static final InAppReview _inAppReview = InAppReview.instance;

  static review() async {
    if (await _inAppReview.isAvailable()) {
      _inAppReview.requestReview();
    } else {
      _inAppReview.openStoreListing();
    }
  }
}
