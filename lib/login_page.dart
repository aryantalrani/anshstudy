import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Models/UserData.dart'; // Adjust the path as needed
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
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
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();
                String password = passwordController.text.trim();

                if (email.isEmpty || password.isEmpty) {
                  _showErrorDialog(
                      context, 'Error', 'Please fill in all fields.');
                  return;
                }

                try {
                  UserCredential userCredential =
                      await _auth.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  if (userCredential.user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } else {
                    _showErrorDialog(
                        context, 'Error', 'Invalid email or password.');
                  }
                } catch (e) {
                  print('Error signing in: $e');
                  String errorMessage =
                      'An error occurred. Please try again later.';
                  if (e is FirebaseAuthException) {
                    switch (e.code) {
                      case 'invalid-email':
                        errorMessage = 'Invalid email address format.';
                        break;
                      case 'user-not-found':
                        errorMessage =
                            'User not found. Please check your email.';
                        break;
                      case 'wrong-password':
                        errorMessage = 'Invalid password. Please try again.';
                        break;
                      case 'invalid-credential':
                        errorMessage = 'Invalid authentication credentials.';
                        break;
                      default:
                        errorMessage =
                            'An error occurred. Please try again later.';
                    }
                  }
                  _showErrorDialog(context, 'Error', errorMessage);
                }
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _signInWithGoogle(context),
              icon: Icon(Icons.login),
              label: Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }

  void _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Sign in the user with the Google credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      // Check if the user exists in the Firestore database
      DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();
      if (userDataSnapshot.exists) {
        // User exists, navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // User doesn't exist, display account not found alert
        _showErrorDialog(context, 'Account Not Found',
            'This Google account is not registered.');
      }
    } catch (error) {
      print('Error signing in with Google: $error');
      // Handle error here
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
