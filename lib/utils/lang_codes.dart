import 'package:choco_tur/utils/logger.dart';

class LanguageCodes {
  static const String EN = "en";
  static const String IT = "it";

  static String? langCodeToLabel(String langCode) {
    if (langCode == EN) {
      return "English";
    } else if (langCode == IT) {
      return "Italiano";
    } else {
      LoggerInstance.logger.e('Unknown language code $langCode.');
      return null;
    }
  }
}
