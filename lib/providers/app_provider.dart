// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:msm/models/commands/command_executer.dart';
import 'package:msm/models/folder_configuration.dart';
import 'package:msm/models/local_notification.dart';
import 'package:msm/models/server.dart';
import 'package:msm/models/server_details.dart';
import 'package:msm/models/server_functions.dart';
import 'package:msm/models/storage.dart';

class AppService with ChangeNotifier {
  //TODO add server class also here for having the connection status
  bool _connectionState = false;
  bool _initialized = false;
  Storage storage;
  Server server;
  late CommandExecuter commandExecuter;
  late Notifications notifications;

  AppService({required this.storage, required this.server});

  bool get connectionState => _connectionState;
  bool get initialized => _initialized;

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
}
