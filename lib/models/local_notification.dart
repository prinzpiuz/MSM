// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}

enum NotificationType {
  upload,
  download,
  kindle;

  String get getString {
    switch (this) {
      case NotificationType.upload:
        return "Upload";
      case NotificationType.download:
        return "Download";
      case NotificationType.kindle:
        return "Kindle";
    }
  }
}

class Notifications {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Notifications({required this.flutterLocalNotificationsPlugin});

  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  String _uploadStatus(
      int total, int progress, NotificationType notificationType) {
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
    }
  }

  Future<void> uploadNotification(
      {required String id,
      required String name,
      required String location,
      required int progress,
      required int fileSize,
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
      maxProgress: fileSize,
      progress: progress,
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        name.hashCode,
        '${notificationType.getString} ${_uploadStatus(fileSize, progress, notificationType)} For $name',
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
        'Succesfully ${_uploadStatus(total, progress, notificationType)} To ${notificationType.getString} \n ${filesize(progress)}/${filesize(total)}',
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
