import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studymatcherf/Functions/google_auth.dart';

class ProfilePage extends StatelessWidget {
  final GoogleAuth _googleAuth = GoogleAuth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No data found'));
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (userData['photoUrl'] != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userData['photoUrl']),
                  ),
                SizedBox(height: 20),
                Card(
                  child: ListTile(
                    title: Text('Name'),
                    subtitle: Text(userData['name']),
                    leading: Icon(Icons.person),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Email'),
                    subtitle: Text(userData['email']),
                    leading: Icon(Icons.email),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Phone Number'),
                    subtitle: Text(userData['phoneNumber'] ?? 'Not provided'),
                    leading: Icon(Icons.phone),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _googleAuth.signOut();
                    Navigator.pushNamed(context, '/');
                  },
                  icon: Icon(Icons.logout),
                  label: Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
