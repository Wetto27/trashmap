import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashmap/pages/map_page.dart';
import 'package:trashmap/widgets/recyclers/custom_app_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _showPassword = false;

  Future<void> login() async {
  setState(() {
    _isLoading = true;
  });

  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (userDoc.exists) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(userId: userCredential.user!.uid, isWorker: false),
        ),
      );
    } else {
      // Check in workers collection
      DocumentSnapshot workerDoc = await FirebaseFirestore.instance
          .collection('workers')
          .doc(userCredential.user!.uid)
          .get();

      if (workerDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(userId: userCredential.user!.uid, isWorker: true),
          ),
        );
      } else {
        _showMessage('No user found with this email.');
      }
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      _showMessage('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      _showMessage('Wrong password provided for that user.');
    } else {
      _showMessage('Login failed: $e');
    }
  } catch (e) {
    _showMessage('An unexpected error occurred. Please try again later.');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

void _showMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Pagina de login'),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/greentruckicon.png',
                  width: 150,
                  height: 150,
                ),
                SizedBox(
                  width: 325,
                  child: TextField(  
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1B571D)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 325,
                  child: TextField(
                    textInputAction: TextInputAction.go,
                    controller: passwordController,
                    obscureText: _showPassword == false ? true : false,
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        child: Icon(_showPassword == false ? Icons.visibility_off : Icons.visibility),
                        onTap: (){
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                      labelText: 'Senha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 325,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        Color(0xFF1B571D),
                      ),
                    ),
                    onPressed: login,
                    child: Text('Entrar',
                    style: TextStyle(
                      color: Colors.white
                    ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Text('Criar conta'),
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
              ],
            ),
          ),
        ),
      );
  }
}