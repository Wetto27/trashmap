import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trashmap/widgets/recyclers/custom_app_bar_return.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.email ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarReturn(context, 'Pagina de usuario'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, $_userName!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'This is your basic user homepage.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('View Profile'),
              onPressed: () {
                // Navigate to user profile page
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('Settings'),
              onPressed: () {
                // Navigate to settings page
              },
            ),
          ],
        ),
      ),
    );
  }
}