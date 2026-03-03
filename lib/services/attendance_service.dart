import '../models/attendance_model.dart';

class AttendanceService {
  final String collectionName = 'attendance';

  Future<Map<String, dynamic>> createAttendance(Attendance attendance) async {
    return {
      'success': false,
      'message': 'Attendance service not yet migrated to Supabase',
    };
  }

  Future<Attendance?> getAttendanceById(String attendanceId) async {
    return null;
  }

  Future<List<Attendance>> getAttendanceByDateRange(DateTime fromDate, DateTime toDate) async {
    return [];
  }

  Future<List<Attendance>> getAttendanceByTrainAndDateRange(
    String trainId,
    DateTime fromDate,
    DateTime toDate,
  ) async {
    return [];
  }

  Future<List<Attendance>> getAttendanceByFilters({
    required DateTime fromDate,
    required DateTime toDate,
    String? trainId,
    String? tripType,
  }) async {
    return [];
  }

  Future<Map<String, dynamic>> updateAttendance(String attendanceId, Attendance attendance) async {
    return {
      'success': false,
      'message': 'Attendance service not yet migrated to Supabase',
    };
  }

  Future<Map<String, dynamic>> deleteAttendance(String attendanceId) async {
    return {
      'success': false,
      'message': 'Attendance service not yet migrated to Supabase',
    };
  }
}
