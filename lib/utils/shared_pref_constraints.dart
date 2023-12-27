import 'package:bible/utils/shared_pref.dart';

class AppConstraints {
  // list of constraints
  static const String chapterName = "ChapterName";
  static const String chapterNumber = "ChapterNumber";
  static const String language = "Language";

  static String? chapterNameVal;
  static int? chapterNumberVal;
  static String? languageVal;
}

SharedPref sharedPref = SharedPref();
