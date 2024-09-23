import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trashmap/firebase_options.dart';
import 'package:trashmap/widgets/controllers/app_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa as notificações locais
  AwesomeNotifications().initialize(
    null, // null significa que não há ícone padrão
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

  // Solicita permissão para enviar notificações
  await AwesomeNotifications().requestPermissionToSendNotifications();

  // Executa o aplicativo
  runApp(const AppWidget());
}