import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trashmap/firebase_options.dart';
import 'package:trashmap/widgets/controllers/app_widget.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
);

AwesomeNotifications().initialize(
    null, // null means no default icon
    [
      NotificationChannel(
        channelKey: 'worker_proximity',
        channelName: 'Worker Proximity Notifications',
        channelDescription: 'Notifications when the worker is near your home location',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        playSound: true,
        soundSource: 'resource://raw/notification_sound',
        importance: NotificationImportance.Max,
      ),
    ],
  );

  await AwesomeNotifications().requestPermissionToSendNotifications();

  runApp(const AppWidget());
}