// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const firstTime = 'firsttime';

  SharedPreferences? _prefs;
  static final Storage _instance = Storage._();

  factory Storage() => _instance;

  Storage._() {
    SharedPreferences.getInstance().then((value) => _prefs = value);
  }

  void clearAll() => _prefs?.clear();

  Future<bool> getFirstTimeInstall() async =>
      _prefs?.getBool(firstTime) ?? true;
  void setFirstTimeInstall(bool value) async =>
      _prefs?.setBool(firstTime, value);
}
