import 'package:choco_tur/utils/logger.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

class FacebookLoginService {
  /// The permissions required by this application.
  // #docregion Initialize
  static const List<FacebookPermission> permissions = <FacebookPermission>[
    FacebookPermission.email,
    FacebookPermission.userBirthday,
    FacebookPermission.userGender,
    FacebookPermission.userHometown
  ];

  static final FacebookLogin facebookLogin = FacebookLogin();

  static Future<FacebookLoginResult?> signInWithFacebook() async {
    // Try express login.
    FacebookLoginResult res = await facebookLogin.expressLogin();
    if (res.status == FacebookLoginStatus.success) {
      LoggerInstance.logger.i("Used express Facebook login.");
      return res;
    }

    res = await facebookLogin.logIn(permissions: FacebookLoginService.permissions);

    switch (res.status) {
      case FacebookLoginStatus.success:
        return res;
      case FacebookLoginStatus.cancel:
        LoggerInstance.logger.e("Facebook login canceled.");
        return null;
      case FacebookLoginStatus.error:
        LoggerInstance.logger.e("Facebook login failed: ${res.error.toString()}.");
        return null;
    }
  }
}
