import 'package:flutter/material.dart';
import 'package:trashmap/pages/map_controller.dart';
import 'package:trashmap/pages/map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B571D),
        centerTitle: true,
        title: const Text('TRASHMAP',
                    style: TextStyle(
                      color: Colors.white
                    ),),
      ),
      body: MyApp(),
    );
  }
}