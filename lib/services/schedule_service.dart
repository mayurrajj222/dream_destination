import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'schedules';

  // Create new schedule
  Future<Map<String, dynamic>> createSchedule(Schedule schedule) async {
    try {
      // Check for overlapping schedules for the same train
      final overlapping = await _firestore
          .collection(collectionName)
          .where('trainId', isEqualTo: schedule.trainId)
          .get();

      for (var doc in overlapping.docs) {
        final existing = Schedule.fromMap(doc.data(), doc.id);
        
        // Check if dates overlap
        if ((schedule.fromDate.isBefore(existing.toDate) || 
             schedule.fromDate.isAtSameMomentAs(existing.toDate)) &&
            (schedule.toDate.isAfter(existing.fromDate) || 
             schedule.toDate.isAtSameMomentAs(existing.fromDate))) {
          return {
            'success': false,
            'message': 'Schedule overlaps with existing schedule for this train',
          };
        }
      }

      DocumentReference docRef = await _firestore
          .collection(collectionName)
          .add(schedule.toMap());

      return {
        'success': true,
        'message': 'Schedule created successfully',
        'scheduleId': docRef.id,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating schedule: ${e.toString()}',
      };
    }
  }

  // Get schedule by ID
  Future<Schedule?> getScheduleById(String scheduleId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(collectionName)
          .doc(scheduleId)
          .get();

      if (doc.exists) {
        return Schedule.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting schedule: $e');
      return null;
    }
  }

  // Get all schedules
  Future<List<Schedule>> getAllSchedules() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .orderBy('fromDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Schedule.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting all schedules: $e');
      return [];
    }
  }

  // Get schedules by train
  Future<List<Schedule>> getSchedulesByTrain(String trainId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('trainId', isEqualTo: trainId)
          .orderBy('fromDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Schedule.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting schedules by train: $e');
      return [];
    }
  }

  // Get active schedules (current date within range)
  Future<List<Schedule>> getActiveSchedules() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('fromDate', isLessThanOrEqualTo: Timestamp.fromDate(today))
          .where('toDate', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
          .get();

      return querySnapshot.docs
          .map((doc) => Schedule.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting active schedules: $e');
      return [];
    }
  }

  // Get upcoming schedules
  Future<List<Schedule>> getUpcomingSchedules() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('fromDate', isGreaterThan: Timestamp.fromDate(today))
          .orderBy('fromDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Schedule.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting upcoming schedules: $e');
      return [];
    }
  }

  // Update schedule
  Future<Map<String, dynamic>> updateSchedule(
    String scheduleId,
    Schedule schedule,
  ) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(scheduleId)
          .update(schedule.toMap());

      return {
        'success': true,
        'message': 'Schedule updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating schedule: ${e.toString()}',
      };
    }
  }

  // Delete schedule
  Future<Map<String, dynamic>> deleteSchedule(String scheduleId) async {
    try {
      await _firestore.collection(collectionName).doc(scheduleId).delete();

      return {
        'success': true,
        'message': 'Schedule deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting schedule: ${e.toString()}',
      };
    }
  }

  // Search schedules by train number or name
  Future<List<Schedule>> searchSchedules(String searchTerm) async {
    try {
      final lowerSearch = searchTerm.toLowerCase();
      
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .get();

      return querySnapshot.docs
          .map((doc) => Schedule.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .where((schedule) =>
              schedule.trainNo.toLowerCase().contains(lowerSearch) ||
              schedule.trainName.toLowerCase().contains(lowerSearch))
          .toList();
    } catch (e) {
      print('Error searching schedules: $e');
      return [];
    }
  }

  // Get schedules stream (real-time updates)
  Stream<List<Schedule>> getSchedulesStream() {
    return _firestore
        .collection(collectionName)
        .orderBy('fromDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromMap(
                  doc.data(),
                  doc.id,
                ))
            .toList());
  }

  // Count total schedules
  Future<int> getTotalScheduleCount() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionName).get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error counting schedules: $e');
      return 0;
    }
  }
}
