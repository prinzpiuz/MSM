// Package imports:
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:msm/models/local_notification.dart';
import 'package:workmanager/workmanager.dart';

// Project imports:
import 'package:msm/constants/constants.dart';
import 'package:msm/initialization.dart';
import 'package:msm/providers/app_provider.dart';

@pragma('vm:entry-point')
void backGroundTaskDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case BackgroundTaskUniqueNames.upload:
        // await Init().initialize(background: true).then((value) async {
        //   AppService appservice = value["appService"];
        //   if (inputData != null) {
        //     await appservice.server.connect().then((client) async {
        //       final SftpClient sftpClient = await client!.sftp();
        //       FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        //           await Init.notificationIntialize();
        //       Notifications notifications = Notifications(
        //           flutterLocalNotificationsPlugin:
        //               flutterLocalNotificationsPlugin);
        //       appservice.commandExecuter.client = client;
        //       appservice.commandExecuter.sftp = sftpClient;
        //       appservice.commandExecuter.notifications = notifications;
        //       await appservice.commandExecuter.sendFile(
        //           directory: inputData[AppDictKeys.directory],
        //           filePath: inputData[AppDictKeys.filePath],
        //           fileSize: inputData[AppDictKeys.fileSize]);
        //       return Future.value(true);
        //     });
        //   }
        // });
        return Future.value(true);
      case BackgroundTaskUniqueNames.update:
        break;
      case BackgroundTaskUniqueNames.cleanServer:
        break;
    }
    return Future.value(true);
  });
}

enum Tasks { upload, update, cleanServer }

extension TasksExtension on Tasks {
  String get uniqueName {
    switch (this) {
      case Tasks.upload:
        return BackgroundTaskUniqueNames.upload;
      case Tasks.update:
        return BackgroundTaskUniqueNames.update;
      case Tasks.cleanServer:
        return BackgroundTaskUniqueNames.cleanServer;
    }
  }
}

Constraints get constraints => Constraints(
    networkType: NetworkType.connected,
    requiresBatteryNotLow: true,
    requiresCharging: false,
    requiresDeviceIdle: false,
    requiresStorageNotLow: false);

class BackgroundTasks {
  BackgroundTasks() {
    //TODO flavor app to automatically select debug mode
    WidgetsFlutterBinding.ensureInitialized();
    Workmanager().initialize(backGroundTaskDispatcher, isInDebugMode: false);
  }

  void uploadTask({data}) {
    Workmanager().registerOneOffTask(
        Tasks.upload.uniqueName, Tasks.upload.uniqueName,
        inputData: data,
        tag: data[AppDictKeys.filePath].hashCode.toString(),
        constraints: constraints,
        existingWorkPolicy: ExistingWorkPolicy.append,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(seconds: 10));
  }

  static void get cancel => Workmanager().cancelAll();
}
