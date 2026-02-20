import 'package:cloud_firestore/cloud_firestore.dart';

class EHKStaff {
  final String? id;
  final String userId;
  final String password;
  final String userName;
  final DateTime createdAt;

  EHKStaff({
    this.id,
    required this.userId,
    required this.password,
    required this.userName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'password': password,
      'userName': userName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory EHKStaff.fromMap(Map<String, dynamic> map, String id) {
    return EHKStaff(
      id: id,
      userId: map['userId'] ?? '',
      password: map['password'] ?? '',
      userName: map['userName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
