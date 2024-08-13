import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trashmap/widgets/controllers/app_widget.dart';
import 'package:trashmap/services/notification_services.dart';

void main() async {
  
    WidgetsFlutterBinding.ensureInitialized();
    await NotificationService.initializeNotification();
    await Firebase.initializeApp(
  options: FirebaseOptions(
    apiKey: 'AIzaSyDYv02W_296o_kMTOrl4DKwSfn_AbP_gG0',
    appId: '1:580059447245:android:a31c5e05b8c0d58ed64e84',
    messagingSenderId: '580059447245',
    projectId: 'trashteste-c635c',
    storageBucket: 'trashteste-c635c.appspot.com',
  )
);
  runApp(const AppWidget());
}