import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/Topic.dart'; // Ensure this class is defined properly

class SearchGroupsPage extends StatefulWidget {
  @override
  _SearchGroupsPageState createState() => _SearchGroupsPageState();
}

class _SearchGroupsPageState extends State<SearchGroupsPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _joinedGroups = {};

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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Rebuild widget to trigger filter in StreamBuilder
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('topics').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No groups found.'));
                } else {
                  List<Topic> groups = snapshot.data!.docs
                      .map((doc) => Topic.fromMap(doc.data()!))
                      .where((topic) => topic.name.toLowerCase().contains(_searchController.text.toLowerCase()))
                      .toList();

                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      Topic topic = groups[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(topic.name),
                          trailing: _joinedGroups.contains(topic.id) ? Icon(Icons.check, color: Colors.green) : ElevatedButton(
                            onPressed: () => _joinGroup(topic.id),
                            child: Text('Join'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                            ),
                          ),
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

  void _joinGroup(String groupId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('topics').doc(groupId).update({
        'joinedUsers': FieldValue.arrayUnion([userId]),
      });
      setState(() {
        _joinedGroups.add(groupId); // Add groupId to the set to update UI
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error joining group: $e')));
    }
  }
}
