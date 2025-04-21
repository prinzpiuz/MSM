// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:msm/models/folder_configuration.dart';
import 'package:msm/models/send_to_kindle.dart';
import 'package:msm/models/server.dart';
import 'package:msm/models/server_details.dart';
import 'package:msm/models/server_functions.dart';

enum StorageKeys {
  firstTime,
  serverData,
  serverFunctions,
  folderConfigurations,
  kindleData,
  serverOS
}

extension StorageKeysExtension on StorageKeys {
  String get key {
    switch (this) {
      case StorageKeys.firstTime:
        return "firsttime";
      case StorageKeys.serverData:
        return "serverData";
      case StorageKeys.serverFunctions:
        return "serverFunctions";
      case StorageKeys.folderConfigurations:
        return "folderConfigurations";
      case StorageKeys.kindleData:
        return "kindleData";
      case StorageKeys.serverOS:
        return "serverOS";
    }
  }
}

class Storage {
  SharedPreferences prefs;

  Storage({required this.prefs});

  void clearAll() => prefs.clear();

  Map<String, dynamic>? _getJson(String key) {
    final String? jsonString = prefs.getString(key);
    if (jsonString != null) {
      Map<String, dynamic> stringToJson = jsonDecode(jsonString);
      return stringToJson;
    }
    return null;
  }

  void saveObject(String key, dynamic object) async {
    String objectToString = jsonEncode(object);
    await prefs.setString(key, objectToString);
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

  FolderConfiguration get getFolderConfigurations {
    Map<String, dynamic>? data = _getJson(StorageKeys.folderConfigurations.key);
    if (data != null) {
      return FolderConfiguration.fromJson(data);
    }
    return FolderConfiguration();
  }

  KindleData get getKindleData {
    Map<String, dynamic>? data = _getJson(StorageKeys.kindleData.key);
    if (data != null) {
      return KindleData.fromJson(data);
    }
    return KindleData();
  }

  Future<bool> getFirstTimeInstall() async =>
      prefs.getBool(StorageKeys.firstTime.key) ?? true;
  void setFirstTimeInstall(bool value) async =>
      prefs.setBool(StorageKeys.firstTime.key, value);
}
