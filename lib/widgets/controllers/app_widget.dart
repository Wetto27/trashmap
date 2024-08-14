import 'package:flutter/material.dart';
import 'package:trashmap/pages/user_home_page.dart';
import 'package:trashmap/pages/worker_home_page.dart';
import 'package:trashmap/pages/login_page.dart';
import 'package:trashmap/pages/register_page.dart';


class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register':(context) => const RegisterPage(),
        '/worker_home': (context) => const WorkerHomePage(),
        '/user_home': (context) => const UserHomePage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1B571D)),
        useMaterial3: true,
      ),
    );
  }
}