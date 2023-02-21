// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:msm/models/folder_configuration.dart';
import 'package:msm/models/server.dart';
import 'package:msm/models/server_details.dart';
import 'package:msm/models/server_functions.dart';
import 'package:msm/models/storage.dart';

class AppService with ChangeNotifier {
  //TODO add server class also here for having the connection status
  bool _connectionState = true;
  bool _initialized = false;
  bool _onboarding = false;
  Storage storage;
  Server server;

  AppService({required this.storage, required this.server});

  bool get loginState => _connectionState;
  bool get initialized => _initialized;
  bool get onboarding => _onboarding;

  set setServer(Server server) {
    server = server;
  }

  set updateServerDetails(ServerData serverData) {
    server.serverData = serverData;
  }

  set updateFolderConfigurations(FolderConfiguration folderConfiguration) {
    server.folderConfiguration = folderConfiguration;
  }

  set updateServerFunctions(ServerFunctionsData serverFunctionsData) {
    server.serverFunctionsData = serverFunctionsData;
  }

  set connectionState(bool state) {
    _connectionState = state;
    notifyListeners();
  }

  set initialized(bool value) {
    _initialized = value;
    notifyListeners();
  }

  set onboarding(bool value) {
    storage.setFirstTimeInstall(value);
    _onboarding = value;
    notifyListeners();
  }

  Future<void> onAppStart() async {
    _onboarding = await storage.getFirstTimeInstall();
    _initialized = true;
    notifyListeners();
  }
}
