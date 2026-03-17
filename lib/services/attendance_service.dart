import '../models/attendance_model.dart';

// Legacy stub — actual attendance now handled by AttendanceImportService
class AttendanceService {
  Future<List<Attendance>> getAttendanceByFilters({
    required DateTime fromDate,
    required DateTime toDate,
    String? trainId,
    String? tripType,
  }) async => [];

  Future<Map<String, dynamic>> createAttendance(Attendance attendance) async =>
      {'success': false, 'message': 'Use AttendanceImportService'};

  Future<Attendance?> getAttendanceById(String id) async => null;

  Future<List<Attendance>> getAttendanceByDateRange(DateTime from, DateTime to) async => [];

  Future<List<Attendance>> getAttendanceByTrainAndDateRange(
      String trainId, DateTime from, DateTime to) async => [];

  Future<Map<String, dynamic>> updateAttendance(String id, Attendance a) async =>
      {'success': false, 'message': 'Use AttendanceImportService'};

  Future<Map<String, dynamic>> deleteAttendance(String id) async =>
      {'success': false, 'message': 'Use AttendanceImportService'};
}
