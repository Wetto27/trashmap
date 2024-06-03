import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trashmap/pages/app_widget.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
  options: FirebaseOptions(
    apiKey: 'AIzaSyAPCBvdjymPaEGOWuHe6PZ148Z2rNv-5Mc',
    appId: '1:182989999223:android:0a3a2a48d07d0f7b3d8a72',
    messagingSenderId: '182989999223',
    projectId: 'trashmap-7c4e9',
    storageBucket: 'trashmap-7c4e9.appspot.com',
  )
);
  runApp(const AppWidget());
}