// Flutter imports:

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/background_tasks.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.actionId == BackGroundTaskRelated.stopActionId) {
    BackgroundTasks.cancel();
  }
}

enum NotificationType {
  upload,
  download,
  kindle,
  update;

  String get getString {
    switch (this) {
      case NotificationType.upload:
        return "Upload";
      case NotificationType.download:
        return "Download";
      case NotificationType.kindle:
        return "Kindle";
      case NotificationType.update:
        return "Update";
    }
  }
}

class Notifications {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Notifications({required this.flutterLocalNotificationsPlugin});

  String _status(int? total, int? progress, NotificationType notificationType) {
    switch (notificationType) {
      case NotificationType.upload:
        if (total == progress) {
          return "Completed";
        }
        return "Started";
      case NotificationType.download:
        if (total == progress) {
          return "Completed";
        }
        return "Started";
      case NotificationType.kindle:
        if (total == progress) {
          return "Sent";
        }
        return "Sending";
      case NotificationType.update:
        return "Updated";
    }
  }

  Future<void> uploadNotification(
      {required String name,
      required String location,
      required int progress,
      required int fileSize,
      required NotificationType notificationType}) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      BackGroundTaskRelated.uploadChannelId,
      BackGroundTaskRelated.uploadChannelName,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      channelShowBadge: false,
      enableVibration: true,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: fileSize,
      progress: progress,
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        name.hashCode,
        '${notificationType.getString} ${_status(fileSize, progress, notificationType)} For $name',
        'Saving to $location \n ${filesize(progress)}/${filesize(fileSize)}',
        notificationDetails);
  }

  Future<void> sendToKindle(
      {required String id,
      required String name,
      required int progress,
      required int total,
      required NotificationType notificationType}) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      id,
      'upload notification',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      channelShowBadge: false,
      enableVibration: true,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: total,
      progress: progress,
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        name.hashCode,
        name,
        'Succesfully ${_status(total, progress, notificationType)} To ${notificationType.getString} \n ${filesize(progress)}/${filesize(total)}',
        notificationDetails);
  }

  Future<void> systemUpdate(
      {required String id,
      required String name,
      required NotificationType notificationType}) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      id,
      'system update notification',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      channelShowBadge: false,
      enableVibration: true,
      onlyAlertOnce: true,
      showProgress: false,
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        name.hashCode,
        name,
        'Succesfully ${_status(null, null, notificationType)} System',
        notificationDetails);
  }

  Future<void> uploadError({required String error}) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
            "upload error", 'upload error notification',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            actions: []);
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        error.hashCode, 'Error 😞', 'Error: $error', notificationDetails,
        payload: 'item x');
  }
}
