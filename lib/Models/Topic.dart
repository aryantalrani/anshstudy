class Topic {
  String id;
  String name;
  String createdBy;
  List<String> joinedUsers;

  Topic({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.joinedUsers,
  });

  Topic.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        createdBy = map['createdBy'],
        joinedUsers = List<String>.from(map['joinedUsers'] ?? []);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'joinedUsers': joinedUsers,
    };
  }
}
