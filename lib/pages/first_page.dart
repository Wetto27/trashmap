import 'package:flutter/material.dart';

class firstPage extends StatefulWidget {
  const firstPage({super.key});

  @override
  State<firstPage> createState() => _firstPageState();
}

class _firstPageState extends State<firstPage> {

  void login() {
      Navigator.pushNamed(context, '/login');
  }
  void register() {
      Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/greentruckicon.png',
                  width: 150,
                  height: 150,
                ),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(
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
                 SizedBox(
                  width: 250,
                    child: OutlinedButton(
                    onPressed: register,
                    child: Text('Criar Conta',
                    style: TextStyle(
                      color: Color(0xFF1B571D)
                    ),
                  ),
                ),
          ),
        ],
       ),
      ) 
    );
  }
}