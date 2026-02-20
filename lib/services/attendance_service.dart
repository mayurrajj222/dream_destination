import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'attendance';

  // Create attendance record
  Future<Map<String, dynamic>> createAttendance(Attendance attendance) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(collectionName)
          .add(attendance.toMap());

      return {
        'success': true,
        'message': 'Attendance recorded successfully',
        'attendanceId': docRef.id,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error recording attendance: ${e.toString()}',
      };
    }
  }

  // Get attendance by ID
  Future<Attendance?> getAttendanceById(String attendanceId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(collectionName)
          .doc(attendanceId)
          .get();

      if (doc.exists) {
        return Attendance.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting attendance: $e');
      return null;
    }
  }

  // Get attendance by date range
  Future<List<Attendance>> getAttendanceByDateRange(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(toDate))
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Attendance.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting attendance by date range: $e');
      return [];
    }
  }

  // Get attendance by train and date range
  Future<List<Attendance>> getAttendanceByTrainAndDateRange(
    String trainId,
    DateTime fromDate,
    DateTime toDate,
  ) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('trainId', isEqualTo: trainId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(toDate))
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Attendance.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting attendance by train and date range: $e');
      return [];
    }
  }

  // Get attendance by train, trip type, and date range
  Future<List<Attendance>> getAttendanceByFilters({
    required DateTime fromDate,
    required DateTime toDate,
    String? trainId,
    String? tripType,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);

      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(toDate));

      if (trainId != null && trainId.isNotEmpty) {
        query = query.where('trainId', isEqualTo: trainId);
      }

      if (tripType != null && tripType.isNotEmpty && tripType != 'All') {
        query = query.where('tripType', isEqualTo: tripType);
      }

      QuerySnapshot querySnapshot = await query.orderBy('date', descending: false).get();

      return querySnapshot.docs
          .map((doc) => Attendance.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting attendance by filters: $e');
      return [];
    }
  }

  // Get attendance by employee
  Future<List<Attendance>> getAttendanceByEmployee(String employeeId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Attendance.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting attendance by employee: $e');
      return [];
    }
  }

  // Update attendance
  Future<Map<String, dynamic>> updateAttendance(
    String attendanceId,
    Attendance attendance,
  ) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(attendanceId)
          .update(attendance.toMap());

      return {
        'success': true,
        'message': 'Attendance updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating attendance: ${e.toString()}',
      };
    }
  }

  // Delete attendance
  Future<Map<String, dynamic>> deleteAttendance(String attendanceId) async {
    try {
      await _firestore.collection(collectionName).doc(attendanceId).delete();

      return {
        'success': true,
        'message': 'Attendance deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting attendance: ${e.toString()}',
      };
    }
  }

  // Get attendance statistics
  Future<Map<String, int>> getAttendanceStats(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    try {
      final attendances = await getAttendanceByDateRange(fromDate, toDate);
      
      int totalRecords = attendances.length;
      int presentCount = attendances.where((a) => a.isPresent).length;
      int absentCount = totalRecords - presentCount;

      return {
        'total': totalRecords,
        'present': presentCount,
        'absent': absentCount,
      };
    } catch (e) {
      print('Error getting attendance stats: $e');
      return {
        'total': 0,
        'present': 0,
        'absent': 0,
      };
    }
  }

  // Get attendance stream (real-time updates)
  Stream<List<Attendance>> getAttendanceStream() {
    return _firestore
        .collection(collectionName)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Attendance.fromMap(
                  doc.data(),
                  doc.id,
                ))
            .toList());
  }
}
