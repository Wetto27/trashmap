import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trashmap/firebase_options.dart';
import 'package:trashmap/widgets/controllers/app_widget.dart';
import 'package:trashmap/services/notification_services.dart';

void main() async {
  
    WidgetsFlutterBinding.ensureInitialized();
    await NotificationService.initializeNotification();
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
);
  runApp(const AppWidget());
}