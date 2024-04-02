import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/Topic.dart';
import 'groupDetailsPage.dart';

class MyGroupsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Groups'),
      ),
      body: StreamBuilder<QuerySnapshot<Object?>>(
        stream: FirebaseFirestore.instance
            .collection('topics')
            .where('joinedUsers', arrayContains: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No groups found.'));
          } else {
            return ListView.separated(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                QueryDocumentSnapshot<Map<String, dynamic>> groupSnapshot =
                    snapshot.data!.docs[index]
                        as QueryDocumentSnapshot<Map<String, dynamic>>;
                Topic topic = Topic.fromMap(groupSnapshot.data());
                return Card(
                  margin: EdgeInsets.all(8),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.group), // Consider replacing with a relevant image/icon
                    title: Text(topic.name),
                    subtitle: Text('Tap to view details'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupDetailsPage(topic: topic),
                        ),
                      );
                    },
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(),
            );
          }
        },
      ),
    );
  }
}
