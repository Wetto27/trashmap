import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashmap/widgets/recyclers/custom_app_bar_return.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
final TextEditingController workerIdController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showPassword = false;
  bool _isWorker = false;
  
 void register() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      
      // Save additional user info
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': emailController.text,
        'isWorker': _isWorker,
        'workerId': _isWorker ? workerIdController.text : null,
      });

      if (_isWorker) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/user_home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarReturn(context, 'Pagina de cadastro'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
              obscureText: !_showPassword,
            ),
            CheckboxListTile(
              title: Text("I'm a worker"),
              value: _isWorker,
              onChanged: (bool? value) {
                setState(() {
                  _isWorker = value!;
                });
              },
            ),
            if (_isWorker)
              TextField(
                controller: workerIdController,
                decoration: InputDecoration(labelText: 'Worker ID'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Register'),
              onPressed: register,
            ),
          ],
        ),
      ),
    );
  }
}