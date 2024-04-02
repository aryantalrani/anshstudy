import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studymatcherf/MyGroupsPage.dart';
import '../Models/UserData.dart';
import 'Functions/create_group.dart'; // Import the CreateGroupPage
import 'searchgroups_page.dart'; // Import the SearchGroupsPage

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Drawer(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              UserData userData = UserData.fromJson(snapshot.data!.data()!);
              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(userData.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    accountEmail: Text(userData.email),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(userData.photoUrl ?? 'https://placekitten.com/200/200'), // Placeholder or actual image
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.group_add,
                    text: 'Create Group',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateGroupPage(),
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.search,
                    text: 'Search Groups',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchGroupsPage(),
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    text: 'Settings',
                    onTap: () {
                      // Navigate to settings page
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.exit_to_app,
                    text: 'Log Out',
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                  Divider(),
                  _buildDrawerItem(
                    icon: Icons.group,
                    text: 'My Groups',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyGroupsPage(),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String text, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Welcome to StudyMatcher!'),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('Join a Group'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchGroupsPage()),
              );
            },
          ),
          ElevatedButton(
            child: Text('Create a Group'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateGroupPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
