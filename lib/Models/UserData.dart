import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;

  UserData({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }
}
