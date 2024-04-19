import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weatherly Login"),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Login Anonymously'),
          onPressed: () async {
            await _auth.signInAnonymously();
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
    );
  }
}
