// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}

class Notifications {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Notifications() {
    _intialize(flutterLocalNotificationsPlugin);
  }

  Future<void> _intialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('msm');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  void _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  Future<void> uploadNotification(
      {required String id,
      required String name,
      required String location,
      required int progress,
      required int fileSize}) async {
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
        'Upload Started For $name',
        'Saving to $location \n ${filesize(progress)}/${filesize(fileSize)}',
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
