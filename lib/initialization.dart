// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

// Project imports:
import 'package:msm/models/background_tasks.dart';
import 'package:msm/models/commands/command_executer.dart';
import 'package:msm/models/local_notification.dart';
import 'package:msm/models/server.dart';
import 'package:msm/models/storage.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/providers/folder_configuration_provider.dart';
import 'package:msm/providers/upload_provider.dart';

class Init {
  late AppService appService;
  late UploadState uploadService;
  late FileListingState fileListingService;
  late FolderConfigState folderConfigState;

  Future<Map<String, dynamic>> initialize({bool background = false}) async {
    if (!background) {
      _requestStoragePermissions();
      _setAppOrientation();
    }
    WidgetsFlutterBinding.ensureInitialized();
    Workmanager().initialize(backGroundTaskDispatcher, isInDebugMode: false);
    Storage storage = await _getUserPreferences();
    AppService appService = AppService(
        server: Server(
            serverData: storage.getServerData,
            folderConfiguration: storage.getFolderConfigurations,
            serverFunctionsData: storage.getServerFunctions),
        storage: storage);
    appService.kindleData = storage.getKindleData;
    UploadState uploadService = UploadState();
    FileListingState fileListingService = FileListingState();
    fileListingService.folderConfiguration =
        appService.server.folderConfiguration;
    FolderConfigState folderConfigState = FolderConfigState();
    appService.commandExecuter = CommandExecuter(
        serverData: appService.server.serverData,
        folderConfiguration: appService.server.folderConfiguration,
        serverFunctionsData: appService.server.serverFunctionsData,
        client: null,
        sftp: null,
        notifications: null);
    await makeConnections(appService, uploadState: uploadService);
    return {
      "appService": appService,
      "uploadService": uploadService,
      "fileListingService": fileListingService,
      "folderConfigState": folderConfigState
    };
  }

  static Future<Storage> _getUserPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Storage storage = Storage(prefs: sharedPreferences);
    return storage;
  }

  static Future<void> makeConnections(AppService appService,
      {UploadState? uploadState}) async {
    try {
      appService.initialized = true;
      appService.server.state = ServerState.connecting;
      if (appService.server.serverData.detailsAvailable) {
        SSHClient? client = await appService.server.connect().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            appService.connectionState = false;
            return null;
          },
        );
        if (client != null) {
          final SftpClient sftpClient = await client.sftp();
          Notifications notifications = Notifications(
              flutterLocalNotificationsPlugin: await notificationIntialize());
          appService.notifications = notifications;
          appService.commandExecuter = CommandExecuter(
              serverData: appService.server.serverData,
              folderConfiguration: appService.server.folderConfiguration,
              serverFunctionsData: appService.server.serverFunctionsData,
              client: client,
              sftp: sftpClient,
              notifications: notifications);
          appService.connectionState = true;
          appService.server.state = ServerState.connected;
        }
      }
    } catch (_) {}
  }

  static void _requestStoragePermissions() async {
    await [
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.accessNotificationPolicy,
      Permission.notification
    ].request();
  }

  static void _setAppOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Future<FlutterLocalNotificationsPlugin> notificationIntialize() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('msm');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          Notifications.onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    return flutterLocalNotificationsPlugin;
  }
}
