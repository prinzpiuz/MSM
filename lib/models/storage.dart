// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:msm/models/server_details.dart';
import 'package:msm/models/server_functions.dart';

enum StorageKeys { firstTime, serverData, serverFunctions }

extension StorageKeysExtension on StorageKeys {
  String get key {
    switch (this) {
      case StorageKeys.firstTime:
        return "firsttime";
      case StorageKeys.serverData:
        return "serverData";
      case StorageKeys.serverFunctions:
        return "serverFunctions";
    }
  }
}

class Storage {
  SharedPreferences? _prefs;
  static final Storage _instance = Storage._();

  factory Storage() => _instance;

  Storage._() {
    SharedPreferences.getInstance().then((value) => _prefs = value);
  }

  void clearAll() => _prefs?.clear();

  Map<String, dynamic>? _getJson(String key) {
    final String? jsonString = _prefs?.getString(key);
    if (jsonString != null) {
      Map<String, dynamic> stringToJson = jsonDecode(jsonString);
      return stringToJson;
    }
    return null;
  }

  void saveObject(String key, dynamic object) async {
    String objectToString = jsonEncode(object);
    await _prefs!.setString(key, objectToString);
  }

  ServerData get getServerData {
    Map<String, dynamic>? data = _getJson(StorageKeys.serverData.key);
    if (data != null) {
      return ServerData.fromJson(data);
    }
    return ServerData();
  }

  ServerFunctionsData get getServerFunctions {
    Map<String, dynamic>? data = _getJson(StorageKeys.serverFunctions.key);
    if (data != null) {
      return ServerFunctionsData.fromJson(data);
    }
    return ServerFunctionsData();
  }

  Future<bool> getFirstTimeInstall() async =>
      _prefs!.getBool(StorageKeys.firstTime.key) ?? true;
  void setFirstTimeInstall(bool value) async =>
      _prefs!.setBool(StorageKeys.firstTime.key, value);
}
