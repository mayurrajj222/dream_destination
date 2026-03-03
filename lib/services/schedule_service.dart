// import 'package:cloud_firestore/cloud_firestore.dart'; // TODO: Migrate to Supabase
import '../models/schedule_model.dart';

class ScheduleService {
  // TODO: Migrate to Supabase
  // This service is temporarily stubbed to allow PSI functionality to work
  // Full migration to Supabase pending
  
  final String collectionName = 'schedules';

  // Create new schedule
  Future<Map<String, dynamic>> createSchedule(Schedule schedule) async {
    return {
      'success': false,
      'message': 'Schedule service not yet migrated to Supabase',
    };
  }

  // Get schedule by ID
  Future<Schedule?> getScheduleById(String scheduleId) async {
    return null;
  }

  // Get all schedules
  Future<List<Schedule>> getAllSchedules() async {
    return [];
  }

  // Get schedules by train
  Future<List<Schedule>> getSchedulesByTrain(String trainId) async {
    return [];
  }

  // Get active schedules
  Future<List<Schedule>> getActiveSchedules() async {
    return [];
  }

  // Get upcoming schedules
  Future<List<Schedule>> getUpcomingSchedules() async {
    return [];
  }

  // Update schedule
  Future<Map<String, dynamic>> updateSchedule(String scheduleId, Schedule schedule) async {
    return {
      'success': false,
      'message': 'Schedule service not yet migrated to Supabase',
    };
  }

  // Delete schedule
  Future<Map<String, dynamic>> deleteSchedule(String scheduleId) async {
    return {
      'success': false,
      'message': 'Schedule service not yet migrated to Supabase',
    };
  }

  // Search schedules
  Future<List<Schedule>> searchSchedules(String searchTerm) async {
    return [];
  }

  // Get total schedule count
  Future<int> getTotalScheduleCount() async {
    return 0;
  }
}
