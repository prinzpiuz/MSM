// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_background_service/flutter_background_service.dart';

// Project imports:
import 'package:msm/initialization.dart';
import 'package:msm/providers/file_listing_provider.dart' show FileListingState;
import 'package:msm/utils/commands/command_executer.dart';
import 'package:msm/utils/folder_configuration.dart';
import 'package:msm/utils/local_notification.dart';
import 'package:msm/utils/send_to_kindle.dart';
import 'package:msm/utils/server.dart';
import 'package:msm/utils/server_details.dart';
import 'package:msm/utils/server_functions.dart';
import 'package:msm/utils/storage.dart';

class AppService with ChangeNotifier {
  bool _connectionState = false;
  bool _initialized = false;
  Storage storage;
  Server server;
  FlutterBackgroundService backgroundService;
  KindleData kindleData = KindleData();
  late CommandExecuter commandExecuter;
  late Notifications notifications;
  late FileListingState fileListingService;

  AppService(
      {required this.storage,
      required this.server,
      required this.backgroundService});

  bool get connectionState =>
      _connectionState && server.state == ServerState.connected;
  bool get initialized => _initialized;

  void get turnOffSendToKindle {
    server.serverFunctionsData.sendTokindle = false;
    notifyListeners();
  }

  void get turnOnSendToKindle {
    server.serverFunctionsData.sendTokindle = true;
    notifyListeners();
  }

  void get pageRefresh {
    notifyListeners();
  }

  set setServer(Server server) {
    server = server;
  }

  set updateServerDetails(ServerData serverData) {
    server.serverData = serverData;
    Init.makeConnections(this);
  }

  set updateFolderConfigurations(FolderConfiguration folderConfiguration) {
    server.folderConfiguration = folderConfiguration;
    commandExecuter.folderConfiguration = folderConfiguration;
    fileListingService.folderConfiguration = folderConfiguration;
  }

  set updateServerFunctions(ServerFunctionsData serverFunctionsData) {
    server.serverFunctionsData = serverFunctionsData;
    commandExecuter.serverFunctionsData = serverFunctionsData;
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
