import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  bool _showPassword = false;

  void login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      
      // Check if the user is a worker
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      
    if (userDoc.exists) {
      String role = userDoc.get('role') ?? 'user'; // Default to 'user' if the role field is missing

      if (role == 'worker') {
        Navigator.pushReplacementNamed(context, '/worker_home');
      } else {
        Navigator.pushReplacementNamed(context, '/user_home');
      }
    } else {
      // Handle case where user data does not exist in Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data does not exist in Firestore')),
      );
    }
  } catch (e) {
    // Handle login errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: $e')),
    );
   }
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