class AttendanceRecord {
  final String? id;
  final String userId;
  final String trainNo;
  final DateTime sDate;
  final String empCode;
  final String empName;
  final DateTime? punch1;
  final double? punch1Lat;
  final double? punch1Long;
  final String? punch1Location;
  final DateTime? punch2;
  final double? punch2Lat;
  final double? punch2Long;
  final String? punch2Location;
  final DateTime? punch3;
  final double? punch3Lat;
  final double? punch3Long;
  final String? punch3Location;
  final int total;
  final String? importBatchId;
  final DateTime createdAt;

  AttendanceRecord({
    this.id,
    required this.userId,
    required this.trainNo,
    required this.sDate,
    required this.empCode,
    required this.empName,
    this.punch1,
    this.punch1Lat,
    this.punch1Long,
    this.punch1Location,
    this.punch2,
    this.punch2Lat,
    this.punch2Long,
    this.punch2Location,
    this.punch3,
    this.punch3Lat,
    this.punch3Long,
    this.punch3Location,
    this.total = 0,
    this.importBatchId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'train_no': trainNo,
      's_date': sDate.toIso8601String().split('T').first,
      'emp_code': empCode,
      'emp_name': empName,
      'punch1': punch1?.toIso8601String(),
      'punch1_lat': punch1Lat,
      'punch1_long': punch1Long,
      'punch1_location': punch1Location,
      'punch2': punch2?.toIso8601String(),
      'punch2_lat': punch2Lat,
      'punch2_long': punch2Long,
      'punch2_location': punch2Location,
      'punch3': punch3?.toIso8601String(),
      'punch3_lat': punch3Lat,
      'punch3_long': punch3Long,
      'punch3_location': punch3Location,
      'total': total,
      'import_batch_id': importBatchId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      userId: map['user_id'] ?? '',
      trainNo: map['train_no'] ?? '',
      sDate: DateTime.parse(map['s_date']),
      empCode: map['emp_code'] ?? '',
      empName: map['emp_name'] ?? '',
      punch1: map['punch1'] != null ? DateTime.parse(map['punch1']) : null,
      punch1Lat: (map['punch1_lat'] as num?)?.toDouble(),
      punch1Long: (map['punch1_long'] as num?)?.toDouble(),
      punch1Location: map['punch1_location'],
      punch2: map['punch2'] != null ? DateTime.parse(map['punch2']) : null,
      punch2Lat: (map['punch2_lat'] as num?)?.toDouble(),
      punch2Long: (map['punch2_long'] as num?)?.toDouble(),
      punch2Location: map['punch2_location'],
      punch3: map['punch3'] != null ? DateTime.parse(map['punch3']) : null,
      punch3Lat: (map['punch3_lat'] as num?)?.toDouble(),
      punch3Long: (map['punch3_long'] as num?)?.toDouble(),
      punch3Location: map['punch3_location'],
      total: map['total'] ?? 0,
      importBatchId: map['import_batch_id'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}

// Keep old Attendance class for backward compatibility
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
  final String tripType;
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
}
