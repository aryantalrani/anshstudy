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
  final FocusNode _messageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    WidgetsBinding.instance.addPostFrameCallback((_) => _messageFocusNode.requestFocus());
  }

  Future<void> _fetchUserName() async {
    DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    String? name = (userDataSnapshot.data() as Map<String, dynamic>?)?['name'];

    setState(() {
      _userName = name ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _leaveGroup(),
          ),
        ],
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
          // Users in Group ListTile omitted for brevity
          Expanded(child: _buildMessagesList()),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
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
              bool isSentByMe = messageDataMap['sender'] == _userName;
              return Align(
                alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: isSentByMe ? Colors.blue[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(messageDataMap['text'] ?? ''),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildMessageInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _messageFocusNode,
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending message')));
    }
  }

  void _leaveGroup() {
    // Implement the logic to leave the group
    print('Leaving group...');
  }
}

