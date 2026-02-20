import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String? id;
  final String employeeCode;
  final String employeeName;
  final String fatherName;
  final String phoneNumber;
  final String esiNo;
  final String pfNo;
  final String pancardNo;
  final String aadharNo;
  final String employeeCategory;
  final String? photoUrl;
  final String? documentUrl;
  final bool isPhotoUpload;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Employee({
    this.id,
    required this.employeeCode,
    required this.employeeName,
    required this.fatherName,
    required this.phoneNumber,
    required this.esiNo,
    required this.pfNo,
    required this.pancardNo,
    required this.aadharNo,
    required this.employeeCategory,
    this.photoUrl,
    this.documentUrl,
    this.isPhotoUpload = false,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Employee to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'employeeCode': employeeCode,
      'employeeName': employeeName,
      'fatherName': fatherName,
      'phoneNumber': phoneNumber,
      'esiNo': esiNo,
      'pfNo': pfNo,
      'pancardNo': pancardNo,
      'aadharNo': aadharNo,
      'employeeCategory': employeeCategory,
      'photoUrl': photoUrl,
      'documentUrl': documentUrl,
      'isPhotoUpload': isPhotoUpload,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create Employee from Firestore document
  factory Employee.fromMap(Map<String, dynamic> map, String documentId) {
    return Employee(
      id: documentId,
      employeeCode: map['employeeCode'] ?? '',
      employeeName: map['employeeName'] ?? '',
      fatherName: map['fatherName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      esiNo: map['esiNo'] ?? '',
      pfNo: map['pfNo'] ?? '',
      pancardNo: map['pancardNo'] ?? '',
      aadharNo: map['aadharNo'] ?? '',
      employeeCategory: map['employeeCategory'] ?? 'User',
      photoUrl: map['photoUrl'],
      documentUrl: map['documentUrl'],
      isPhotoUpload: map['isPhotoUpload'] ?? false,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Copy with method for updates
  Employee copyWith({
    String? id,
    String? employeeCode,
    String? employeeName,
    String? fatherName,
    String? phoneNumber,
    String? esiNo,
    String? pfNo,
    String? pancardNo,
    String? aadharNo,
    String? employeeCategory,
    String? photoUrl,
    String? documentUrl,
    bool? isPhotoUpload,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      employeeName: employeeName ?? this.employeeName,
      fatherName: fatherName ?? this.fatherName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      esiNo: esiNo ?? this.esiNo,
      pfNo: pfNo ?? this.pfNo,
      pancardNo: pancardNo ?? this.pancardNo,
      aadharNo: aadharNo ?? this.aadharNo,
      employeeCategory: employeeCategory ?? this.employeeCategory,
      photoUrl: photoUrl ?? this.photoUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      isPhotoUpload: isPhotoUpload ?? this.isPhotoUpload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
