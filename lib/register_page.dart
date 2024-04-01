import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/UserData.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isValidPhoneNumber(String phoneNumber) {
    // Regular expression to match phone numbers with 10 to 11 digits
    RegExp phoneNumberRegex = RegExp(r'^\d{10,11}$');
    return phoneNumberRegex.hasMatch(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text.trim();
                String email = emailController.text.trim();
                String password = passwordController.text.trim();
                String phone = phoneController.text.trim();

                if (name.isEmpty ||
                    email.isEmpty ||
                    password.isEmpty ||
                    phone.isEmpty) {
                  _showErrorDialog(
                      context, 'Error', 'Please fill in all fields.');
                  return;
                }

                if (!isValidPhoneNumber(phone)) {
                  _showErrorDialog(context, 'Error',
                      'Please enter a valid phone number (10 to 11 digits).');
                  return;
                }

                try {
                  UserCredential userCredential =
                      await _auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  if (userCredential.user != null) {
                    UserData userData = UserData(
                      name: name,
                      email: email,
                      phoneNumber: phone,
                      password: password, // Include password
                    );

                    // Save user data to Firestore only if user registration succeeds
                    await _firestore
                        .collection('users')
                        .doc(userCredential.user!.uid)
                        .set(userData.toJson());

                    Navigator.pushReplacementNamed(context, '/home');
                  }
                } catch (e) {
                  print('Error registering user: $e');
                  String errorMessage =
                      'An error occurred. Please try again later.';

                  if (e is FirebaseAuthException) {
                    switch (e.code) {
                      case 'email-already-in-use':
                        errorMessage =
                            'The email address is already in use by another account.';
                        break;
                      case 'invalid-email':
                        errorMessage = 'Invalid email address format.';
                        break;
                      case 'weak-password':
                        errorMessage =
                            'Password should be at least 6 characters.';
                        break;
                      default:
                        errorMessage =
                            'An error occurred. Please try again later.';
                    }
                  }

                  _showErrorDialog(context, 'Error', errorMessage);
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
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
