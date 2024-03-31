import 'package:flutter/material.dart';
import 'package:studymatcherf/google_auth.dart';

class HomePage extends StatelessWidget {
  final GoogleAuth googleAuth = GoogleAuth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Logged in successfully!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await googleAuth.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
