import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String? id;
  final String trainId;
  final String trainNo;
  final String trainName;
  final DateTime fromDate;
  final DateTime toDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Schedule({
    this.id,
    required this.trainId,
    required this.trainNo,
    required this.trainName,
    required this.fromDate,
    required this.toDate,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'trainId': trainId,
      'trainNo': trainNo,
      'trainName': trainName,
      'fromDate': Timestamp.fromDate(fromDate),
      'toDate': Timestamp.fromDate(toDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map, String documentId) {
    return Schedule(
      id: documentId,
      trainId: map['trainId'] ?? '',
      trainNo: map['trainNo'] ?? '',
      trainName: map['trainName'] ?? '',
      fromDate: (map['fromDate'] as Timestamp).toDate(),
      toDate: (map['toDate'] as Timestamp).toDate(),
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Schedule copyWith({
    String? id,
    String? trainId,
    String? trainNo,
    String? trainName,
    DateTime? fromDate,
    DateTime? toDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      trainId: trainId ?? this.trainId,
      trainNo: trainNo ?? this.trainNo,
      trainName: trainName ?? this.trainName,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to get date range as string
  String getDateRange() {
    final fromStr = '${fromDate.day.toString().padLeft(2, '0')}/${fromDate.month.toString().padLeft(2, '0')}/${fromDate.year}';
    final toStr = '${toDate.day.toString().padLeft(2, '0')}/${toDate.month.toString().padLeft(2, '0')}/${toDate.year}';
    return '$fromStr - $toStr';
  }

  // Helper method to calculate duration in days
  int getDurationInDays() {
    return toDate.difference(fromDate).inDays + 1;
  }
}
