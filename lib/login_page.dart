import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studymatcherf/google_auth.dart';

class LoginPage extends StatelessWidget {
  final GoogleAuth googleAuth = GoogleAuth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              User? user = await googleAuth.signInWithGoogle();
              if (user != null) {
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                // Handle sign-in failure
              }
            } catch (e) {
              print('Error signing in with Google: $e');
              // Handle error
            }
          },
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}
