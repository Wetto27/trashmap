import 'package:flutter/material.dart';
import 'package:trashmap/pages/login_page.dart';
import 'package:trashmap/pages/register_page.dart';
import 'package:trashmap/pages/map_page.dart';
import 'package:trashmap/pages/select_location_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/selectHomeLocation': (context) => SelectHomeLocationPage(userId: ModalRoute.of(context)!.settings.arguments as String),
        '/userMap': (context) => MapPage(userId: ModalRoute.of(context)!.settings.arguments as String, isWorker: false),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B571D)),
        useMaterial3: true,
      ),
    );
  }
}