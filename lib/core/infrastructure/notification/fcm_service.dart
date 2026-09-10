import 'dart:io';
import 'dart:math';

import 'package:fimber/fimber.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_preferences.dart';

class PushNotificationService {
  static const channelId = 'com.registroelettronico/notification';
  static const channelName = 'Registro elettronico';
  static const channelDescription = 'Send and receive notifications';

  Future initialise() async {
    Fimber.i('🔔 [FCM] Called initialisation...');

    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission();
    }

    if (kDebugMode) {
      final token = await FirebaseMessaging.instance.getToken();
      Fimber.i("🔔 [FCM] Got token $token");
    }

    AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: initializationSettingsIOS,
    );

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final prefs = await SharedPreferences.getInstance();
    FirebaseMessaging.onMessage.listen((message) async {
      Fimber.i('🔔 [FCM] Got FCM Message $message');

      final category = NotificationPreferences.categoryFromMessage(message.data);
      if (category != null && !NotificationPreferences.isEnabled(prefs, category)) {
        return;
      }

      final title = message.notification?.title ?? message.data['title'];
      final body = message.notification?.body ?? message.data['body'];
      if (title is! String || body is! String) return;

      await flutterLocalNotificationsPlugin.show(
        _randomId(),
        title,
        body,
        platformChannelSpecifics,
      );
    });
  }

  int _randomId() {
    return Random().nextInt(10000) + 0;
  }
}
