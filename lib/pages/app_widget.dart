import 'package:flutter/material.dart';
import 'package:trashmap/pages/home_page.dart';
import 'package:trashmap/pages/login_page.dart';
import 'package:trashmap/pages/first_page.dart';
import 'package:trashmap/pages/register_page.dart';


class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/firstPage',
      routes: {
        '/firstPage': (context) => const firstPage(),
        '/login': (context) => const LoginPage(),
        '/register':(context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}