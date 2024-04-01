import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studymatcherf/Models/UserData.dart';
import '../Models/Topic.dart';

class GroupDetailsPage extends StatefulWidget {
  final Topic topic;

  const GroupDetailsPage({required this.topic});

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  final TextEditingController _messageController = TextEditingController();
  late String _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    // Fetch user data from Firestore
    DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    // Extract the name field from the user data
    String? name = (userDataSnapshot.data() as Map<String, dynamic>?)?['name'];

    // Update the _userName state with the fetched name
    setState(() {
      _userName = name ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Group Name'),
            subtitle: Text(widget.topic.name),
          ),
          ListTile(
            title: Text('Group ID'),
            subtitle: Text(widget.topic.id),
          ),
          ListTile(
            title: Text('Users in Group'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.topic.joinedUsers
                  .map((userId) =>
                      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              !snapshot.data!.exists) {
                            return Text('User not found');
                          } else {
                            var userData = snapshot.data!.data()!;
                            return Text(
                                '${userData['name']} (${userData['email']})');
                          }
                        },
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groupChats')
                  .doc(widget.topic.id)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                } else {
                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var messageData = snapshot.data!.docs[index].data()!;
                      var messageDataMap = messageData as Map<String, dynamic>;
                      return ListTile(
                        title: Text(messageDataMap['text'] ?? ''),
                        subtitle: Text(messageDataMap['sender'] ?? 'Unknown'),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Type your message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(widget.topic.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String groupId) async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('groupChats')
          .doc(groupId)
          .collection('messages')
          .add({
        'text': messageText,
        'sender': _userName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      // Handle error
    }
  }
}
