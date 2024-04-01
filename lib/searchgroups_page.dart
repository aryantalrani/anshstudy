import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/Topic.dart'; // Import the Topic class

class SearchGroupsPage extends StatefulWidget {
  @override
  _SearchGroupsPageState createState() => _SearchGroupsPageState();
}

class _SearchGroupsPageState extends State<SearchGroupsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Groups'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter group name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Trigger search logic here
                // You may want to use a debouncer or delay before triggering the search
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance.collection('topics').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No groups found.'));
                } else {
                  List<Topic> groups = snapshot.data!.docs
                      .map((doc) => Topic.fromMap(doc.data()!))
                      .toList();

                  // Filter groups based on search query
                  if (_searchController.text.isNotEmpty) {
                    final query = _searchController.text.toLowerCase();
                    groups = groups
                        .where(
                            (group) => group.name.toLowerCase().contains(query))
                        .toList();
                  }

                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      Topic topic = groups[index];
                      return GestureDetector(
                        onTap: () {
                          _joinGroup(topic.id);
                        },
                        child: ListTile(
                          title: Text(topic.name),
                          trailing: _buildJoinButton(topic),
                          // Add any other relevant information about the group
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton(Topic topic) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    bool isUserJoined = topic.joinedUsers.contains(userId);
    return ElevatedButton(
      onPressed: isUserJoined ? null : () => _joinGroup(topic.id),
      child: Text(isUserJoined ? 'Joined' : 'Join'),
    );
  }

  void _joinGroup(String groupId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(groupId)
          .update({
        'joinedUsers': FieldValue.arrayUnion([userId]),
      });
      // Show success message or navigate to a different page
    } catch (e) {
      print('Error joining group: $e');
      // Show error message
    }
  }
}
