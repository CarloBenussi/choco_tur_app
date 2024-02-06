import 'package:choco_tur/utils/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLoginService {
  /// The scopes required by this application.
  // #docregion Initialize
  static const List<String> scopes = <String>[
    'email',
  ];

  static final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: scopes,
  );

  static Future<GoogleSignInAccount?> signInWithGoogleWithToken(
      String email, String accessToken) async {
    // TODO: Implement.
    return null;
  }

  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    // Try to sign in using a previous login.
    GoogleSignInAccount? account = await GoogleLoginService.googleSignIn
        .signInSilently(suppressErrors: true);
    account ??= await GoogleLoginService.googleSignIn.signIn();
    if (account == null) {
      LoggerInstance.logger.e("Failed to sign in with Google (null account)");
      return null;
    }

    bool authorized = await GoogleLoginService.googleSignIn
        .requestScopes(GoogleLoginService.scopes);
    if (!authorized) {
      LoggerInstance.logger.e("User not authorized!");
      return null;
    }

    return account;
  }
}
