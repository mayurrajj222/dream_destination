// import 'package:cloud_firestore/cloud_firestore.dart'; // TODO: Migrate to Supabase

class EHKStaff {
  final String? id;
  final String customerId;
  final String userId;
  final String password;
  final String userName;
  final DateTime createdAt;

  EHKStaff({
    this.id,
    required this.customerId,
    required this.userId,
    required this.password,
    required this.userName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'userId': userId,
      'password': password,
      'userName': userName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EHKStaff.fromMap(Map<String, dynamic> map, String id) {
    return EHKStaff(
      id: id,
      customerId: map['customerId'] ?? '',
      userId: map['userId'] ?? '',
      password: map['password'] ?? '',
      userName: map['userName'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
