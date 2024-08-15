import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
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

  final Location _location = Location();
  bool _showPassword = false;
  bool _isWorker = false;
  bool _isLoading = false;
  
 Future<void> register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      LocationData? _locationData;
      if (!_isWorker) {
        bool _serviceEnabled;
        PermissionStatus _permissionGranted;

        _serviceEnabled = await _location.serviceEnabled();
        if (!_serviceEnabled) {
          _serviceEnabled = await _location.requestService();
          if (!_serviceEnabled) {
            throw Exception('Location services are disabled.');
          }
        }

        _permissionGranted = await _location.hasPermission();
        if (_permissionGranted == PermissionStatus.denied) {
          _permissionGranted = await _location.requestPermission();
          if (_permissionGranted != PermissionStatus.granted) {
            throw Exception('Location permission not granted.');
          }
        }

        _locationData = await _location.getLocation();
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      Map<String, dynamic> userData = {
        'email': emailController.text,
        'role': _isWorker ? 'worker' : 'user',
      };

    if (_isWorker) {
      userData['workerId'] = workerIdController.text;
    } else if (_locationData != null) {
      userData['latitude'] = _locationData.latitude;
      userData['longitude'] = _locationData.longitude;
    }

      String collection = _isWorker ? 'workers' : 'users';

      await FirebaseFirestore.instance
        .collection(collection)
        .doc(userCredential.user!.uid)
        .set(userData);

      if (_isWorker) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarReturn(context, 'Pagina de registro'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
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
              title: const Text("Register as Worker"),
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
                decoration: const InputDecoration(labelText: 'Worker ID'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : register,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}