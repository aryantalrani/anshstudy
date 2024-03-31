import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studymatcherf/login_page.dart';

class RegistrationPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            UserCredential? userCredential = await _auth.signInAnonymously();
            if (userCredential != null) {
              // Registration successful, navigate to login page
              Navigator.pushReplacementNamed(context, '/');
              // Show registration success prompt
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Registration successful!')),
              );
            } else {
              // Handle registration failure
            }
          },
          child: Text('Register'),
        ),
      ),
    );
  }
}
