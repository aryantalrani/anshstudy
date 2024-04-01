import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Models/Topic.dart';

class CreateGroupPage extends StatelessWidget {
  final TextEditingController topicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: topicController,
              decoration: InputDecoration(labelText: 'Enter Topic'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _createGroup(context);
              },
              child: Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }

  void _createGroup(BuildContext context) async {
    String topicName = topicController.text.trim();

    if (topicName.isEmpty) {
      _showErrorDialog(context, 'Error', 'Please enter a topic.');
      return;
    }

    try {
      String topicId = FirebaseFirestore.instance.collection('topics').doc().id;
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('topics').doc(topicId).set({
        'id': topicId,
        'name': topicName,
        'createdBy': userId,
        'joinedUsers': [userId], // Add the creator to the joined users list
      });

      _showSuccessDialog(context);
    } catch (e) {
      print('Error creating group: $e');
      _showErrorDialog(
          context, 'Error', 'Failed to create group. Please try again later.');
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Group created successfully!'),
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
