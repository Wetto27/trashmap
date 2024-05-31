import 'package:flutter/material.dart';

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
<<<<<<< HEAD
        backgroundColor: const Color(0xFF1B571D),
=======
        backgroundColor: const Color.fromARGB(255, 255, 89, 0),
>>>>>>> d3ffb2e69186f4f721ccd473852a3ffccf1dc822
        centerTitle: true,
        title: const Text('TRASHMAP',
                    style: TextStyle(
                      color: Colors.white
                    ),),
      ),
    );
  }
}