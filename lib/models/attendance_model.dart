import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String? id;
  final String employeeId;
  final String employeeCode;
  final String employeeName;
  final String trainId;
  final String trainNo;
  final String trainName;
  final String scheduleId;
  final DateTime date;
  final String tripType; // 'Going' or 'Coming'
  final bool isPresent;
  final String? remarks;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Attendance({
    this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.trainId,
    required this.trainNo,
    required this.trainName,
    required this.scheduleId,
    required this.date,
    required this.tripType,
    this.isPresent = true,
    this.remarks,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'employeeCode': employeeCode,
      'employeeName': employeeName,
      'trainId': trainId,
      'trainNo': trainNo,
      'trainName': trainName,
      'scheduleId': scheduleId,
      'date': Timestamp.fromDate(date),
      'tripType': tripType,
      'isPresent': isPresent,
      'remarks': remarks,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map, String documentId) {
    return Attendance(
      id: documentId,
      employeeId: map['employeeId'] ?? '',
      employeeCode: map['employeeCode'] ?? '',
      employeeName: map['employeeName'] ?? '',
      trainId: map['trainId'] ?? '',
      trainNo: map['trainNo'] ?? '',
      trainName: map['trainName'] ?? '',
      scheduleId: map['scheduleId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      tripType: map['tripType'] ?? 'Going',
      isPresent: map['isPresent'] ?? true,
      remarks: map['remarks'],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Attendance copyWith({
    String? id,
    String? employeeId,
    String? employeeCode,
    String? employeeName,
    String? trainId,
    String? trainNo,
    String? trainName,
    String? scheduleId,
    DateTime? date,
    String? tripType,
    bool? isPresent,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      employeeName: employeeName ?? this.employeeName,
      trainId: trainId ?? this.trainId,
      trainNo: trainNo ?? this.trainNo,
      trainName: trainName ?? this.trainName,
      scheduleId: scheduleId ?? this.scheduleId,
      date: date ?? this.date,
      tripType: tripType ?? this.tripType,
      isPresent: isPresent ?? this.isPresent,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
