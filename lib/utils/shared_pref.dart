import 'package:bible/utils/shared_pref_constraints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  Future<String?> getChapterName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstraints.chapterName);
  }

  Future<int?> getChapterNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstraints.chapterNumber);
  }

  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstraints.language);
  }

  setChapterName(String val) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConstraints.chapterName, val);
  }

  setChapterNumber(int val) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(AppConstraints.chapterNumber, val);
  }

  setLanguage(String val) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConstraints.language, val);
  }
}
