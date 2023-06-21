// Flutter imports:
// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:msm/initialization.dart';
import 'package:msm/models/local_notification.dart';
import 'package:msm/models/upload_and_download.dart';

// Project imports:
import 'package:msm/constants/constants.dart';
import 'package:msm/providers/app_provider.dart';

@pragma('vm:entry-point')
void backGroundTaskDispatcher(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin backgroundNotifications =
      FlutterLocalNotificationsPlugin();
  Notifications localNotifications = Notifications(
      flutterLocalNotificationsPlugin: await Init.notificationIntialize());
  try {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        backgroundNotifications.show(
          BackGroundTaskRelated.foregroundServiceNotificationId,
          BackGroundTaskRelated.initialNotificationTitle,
          BackGroundTaskRelated.runningBody,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              BackGroundTaskRelated.notificationChannelId,
              BackGroundTaskRelated.initialNotificationTitle,
              icon: BackGroundTaskRelated.icon,
              playSound: false,
              ongoing: true,
              actions: <AndroidNotificationAction>[
                AndroidNotificationAction(BackGroundTaskRelated.stopActionId,
                    BackGroundTaskRelated.stopActionTitle),
              ],
            ),
          ),
        );
      }
      service.on(Task.upload.uniqueName).listen((event) async {
        if (event != null) {
          final SftpClient sftpClient = await getSFTPClient(event);
          upload(
              newFolders: event["newFolders"].cast<String>(),
              insidPath: event["insidPath"],
              directory: event["directory"],
              filePaths: event["filePaths"].cast<String>(),
              notifications: localNotifications,
              sftp: sftpClient);
        }
      });
      service.on(Task.download.uniqueName).listen((event) async {
        if (event != null) {
          final SftpClient sftpClient = await getSFTPClient(event);
          download(
              notifications: localNotifications,
              sftp: sftpClient,
              fullPath: event["fullPath"],
              name: event["name"]);
        }
      });
      service.on('stopService').listen((event) {
        service.stopSelf();
      });
    }
  } catch (_) {}
}

enum Task { upload, download, update, cleanServer }

extension TasksExtension on Task {
  String get uniqueName {
    switch (this) {
      case Task.upload:
        return BackgroundTaskUniqueNames.upload;
      case Task.update:
        return BackgroundTaskUniqueNames.update;
      case Task.cleanServer:
        return BackgroundTaskUniqueNames.cleanServer;
      case Task.download:
        return BackgroundTaskUniqueNames.download;
    }
  }
}

class BackgroundTasks {
  BackgroundTasks() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  void task(
      {required Task task,
      required Map<String, dynamic> data,
      required AppService appService}) async {
    data.addAll(appService.server.serverData.toJson());
    final service = appService.backgroundService;
    bool isRunning = await service.isRunning();
    if (!isRunning) {
      service.startService();
    }
    switch (task) {
      case Task.upload:
        service.invoke(Task.upload.uniqueName, data);
        break;
      case Task.download:
        service.invoke(Task.download.uniqueName, data);
        break;
      case Task.update:
        // TODO: Handle this case.
        break;
      case Task.cleanServer:
        // TODO: Handle this case.
        break;
    }
  }

  static void start() async {
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();
    if (!isRunning) {
      service.startService();
    }
  }

  static void cancel() async {
    final FlutterBackgroundService service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke("stopService");
    }
  }
}
