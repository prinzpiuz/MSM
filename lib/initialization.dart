// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wake_on_lan/wake_on_lan.dart';

// Project imports:
import 'package:msm/constants/constants.dart';
import 'package:msm/utils/background_tasks.dart';
import 'package:msm/utils/commands/command_executer.dart';
import 'package:msm/utils/local_notification.dart';
import 'package:msm/utils/server.dart';
import 'package:msm/utils/storage.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/providers/folder_configuration_provider.dart';
import 'package:msm/providers/upload_provider.dart';

class Init {
  late AppService appService;
  late UploadState uploadService;
  late FileListingState fileListingService;
  late FolderConfigState folderConfigState;

  Future<Map<String, dynamic>> initialize() async {
    _requestStoragePermissions();
    _setAppOrientation();
    WidgetsFlutterBinding.ensureInitialized();
    Storage storage = await _getUserPreferences();
    FlutterBackgroundService backgroundService = FlutterBackgroundService();
    AppService appService = AppService(
        server: Server(
            serverData: storage.getServerData,
            folderConfiguration: storage.getFolderConfigurations,
            serverFunctionsData: storage.getServerFunctions),
        backgroundService: backgroundService,
        storage: storage);
    configureBackgroundService(backgroundService);
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
    await makeConnections(appService);
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
      {bool wol = false}) async {
    try {
      appService.initialized = true;
      appService.server.state = ServerState.connecting;
      if (appService.server.serverData.detailsAvailable) {
        SSHClient? client = await appService.server.connect().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            appService.connectionState = false;
            if (wol) {
              _wakeOnLAN(appService: appService);
            }
            return null;
          },
        );
        if (client != null) {
          final SftpClient sftpClient = await client.sftp();
          Notifications notifications = Notifications(
              flutterLocalNotificationsPlugin: await notificationInitialize());
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

  static void _wakeOnLAN({required AppService appService}) async {
    try {
      MACAddress macAddress =
          MACAddress(appService.server.serverData.macAddress);
      IPAddress iPv4Address =
          IPAddress(appService.server.serverData.serverHost);
      if (macAddress.address.isNotEmpty && iPv4Address.address.isNotEmpty) {
        WakeOnLAN wakeOnLan = WakeOnLAN(iPv4Address, macAddress);
        await wakeOnLan.wake(
          repeat: 5,
        );
        appService.server.state = ServerState.connecting;
      }
    } catch (_) {
      appService.connectionState = false;
    }
  }

  static void _setAppOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static void configureBackgroundService(
      FlutterBackgroundService backgroundService) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      BackGroundTaskRelated.notificationChannelId, // id
      BackGroundTaskRelated.initialNotificationTitle, // title
      importance: Importance.low, // importance must be at low or higher level
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await backgroundService.configure(
      androidConfiguration: AndroidConfiguration(
          onStart: backGroundTaskDispatcher,
          autoStart: false,
          autoStartOnBoot: false,
          isForegroundMode: true,
          notificationChannelId: BackGroundTaskRelated.notificationChannelId,
          foregroundServiceNotificationId:
              BackGroundTaskRelated.foregroundServiceNotificationId,
          initialNotificationContent:
              BackGroundTaskRelated.initialNotificationContent,
          initialNotificationTitle:
              BackGroundTaskRelated.initialNotificationTitle),
      iosConfiguration: IosConfiguration(),
    );
  }

  static Future<FlutterLocalNotificationsPlugin>
      notificationInitialize() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('msm');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    return flutterLocalNotificationsPlugin;
  }
}
