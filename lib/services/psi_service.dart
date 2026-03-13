import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/psi_record_model.dart';

class PSIService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String tableName = 'psi_records';

  // Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Create PSI record
  Future<Map<String, dynamic>> createPSIRecord(PSIRecord record) async {
    try {
      if (currentUserId == null) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      // Ensure userId is set to current user
      final recordData = record.copyWith(userId: currentUserId!).toMap();
      
      final response = await _supabase
          .from(tableName)
          .insert(recordData)
          .select()
          .single();

      return {
        'success': true,
        'message': 'PSI record created successfully',
        'recordId': response['id'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating PSI record: ${e.toString()}',
      };
    }
  }

  // Get PSI records by date range (filtered by current user)
  Future<List<PSIRecord>> getPSIRecordsByDateRange(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    try {
      if (currentUserId == null) return [];

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('user_id', currentUserId!)
          .gte('date', fromDate.toIso8601String())
          .lte('date', toDate.toIso8601String())
          .order('date', ascending: false)  // Changed to descending to get newest first
          .limit(15000);  // Increased limit to 15000 records

      return (response as List)
          .map((data) => PSIRecord.fromMap(data, data['id']))
          .toList();
    } catch (e) {
      print('Error getting PSI records by date range: $e');
      return [];
    }
  }

  // Get PSI records by train and date range (filtered by current user)
  Future<List<PSIRecord>> getPSIRecordsByTrainAndDateRange(
    String trainId,
    DateTime fromDate,
    DateTime toDate,
  ) async {
    try {
      if (currentUserId == null) return [];

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('user_id', currentUserId!)
          .eq('train_id', trainId)
          .gte('date', fromDate.toIso8601String())
          .lte('date', toDate.toIso8601String())
          .order('date', ascending: true);

      return (response as List)
          .map((data) => PSIRecord.fromMap(data, data['id']))
          .toList();
    } catch (e) {
      print('Error getting PSI records by train: $e');
      return [];
    }
  }

  // Get PSI records by trip (filtered by current user)
  Future<List<PSIRecord>> getPSIRecordsByTrip(String tripId) async {
    try {
      if (currentUserId == null) return [];

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('user_id', currentUserId!)
          .eq('trip_id', tripId)
          .order('date', ascending: true);

      return (response as List)
          .map((data) => PSIRecord.fromMap(data, data['id']))
          .toList();
    } catch (e) {
      print('Error getting PSI records by trip: $e');
      return [];
    }
  }

  // Get PSI records with filters (filtered by current user)
  Future<List<PSIRecord>> getPSIRecordsByFilters({
    required DateTime fromDate,
    required DateTime toDate,
    String? trainId,
    String? tripType,
  }) async {
    try {
      if (currentUserId == null) return [];

      var query = _supabase
          .from(tableName)
          .select()
          .eq('user_id', currentUserId!)
          .gte('date', fromDate.toIso8601String())
          .lte('date', toDate.toIso8601String());

      if (trainId != null && trainId.isNotEmpty) {
        query = query.eq('train_id', trainId);
      }

      if (tripType != null && tripType.isNotEmpty && tripType != 'All') {
        query = query.eq('trip_type', tripType);
      }

      final response = await query.order('date', ascending: true);

      return (response as List)
          .map((data) => PSIRecord.fromMap(data, data['id']))
          .toList();
    } catch (e) {
      print('Error getting PSI records by filters: $e');
      return [];
    }
  }

  // Get PSI summary statistics (filtered by current user)
  Future<Map<String, dynamic>> getPSISummary(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    try {
      final records = await getPSIRecordsByDateRange(fromDate, toDate);

      if (records.isEmpty) {
        return {
          'totalRecords': 0,
          'averagePSI': 0.0,
          'highestPSI': 0.0,
          'lowestPSI': 0.0,
          'above90': 0,
          'between70and90': 0,
          'below70': 0,
        };
      }

      final psiScores = records.map((r) => r.psiScore).toList();
      final totalPSI = psiScores.reduce((a, b) => a + b);
      final averagePSI = totalPSI / records.length;
      final highestPSI = psiScores.reduce((a, b) => a > b ? a : b);
      final lowestPSI = psiScores.reduce((a, b) => a < b ? a : b);

      int above90 = 0;
      int between70and90 = 0;
      int below70 = 0;

      for (var score in psiScores) {
        if (score >= 90) {
          above90++;
        } else if (score >= 70) {
          between70and90++;
        } else {
          below70++;
        }
      }

      return {
        'totalRecords': records.length,
        'averagePSI': averagePSI,
        'highestPSI': highestPSI,
        'lowestPSI': lowestPSI,
        'above90': above90,
        'between70and90': between70and90,
        'below70': below70,
      };
    } catch (e) {
      print('Error getting PSI summary: $e');
      return {
        'totalRecords': 0,
        'averagePSI': 0.0,
        'highestPSI': 0.0,
        'lowestPSI': 0.0,
        'above90': 0,
        'between70and90': 0,
        'below70': 0,
      };
    }
  }

  // Bulk create PSI records
  Future<Map<String, dynamic>> bulkCreatePSIRecords(List<PSIRecord> records) async {
    try {
      if (currentUserId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }
      final data = records
          .map((r) => r.copyWith(userId: currentUserId!).toMap())
          .toList();
      await _supabase.from(tableName).insert(data);
      return {
        'success': true,
        'message': '${records.length} record(s) saved successfully',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error saving records: ${e.toString()}'};
    }
  }

  // Update PSI record
  Future<Map<String, dynamic>> updatePSIRecord(PSIRecord record) async {
    try {
      if (currentUserId == null) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      if (record.id == null) {
        return {
          'success': false,
          'message': 'Record ID is required for update',
        };
      }

      final recordData = record.toMap();
      recordData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from(tableName)
          .update(recordData)
          .eq('id', record.id!)
          .eq('user_id', currentUserId!);

      return {
        'success': true,
        'message': 'PSI record updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating PSI record: ${e.toString()}',
      };
    }
  }

  // Delete PSI record
  Future<Map<String, dynamic>> deletePSIRecord(String recordId) async {
    try {
      if (currentUserId == null) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      await _supabase
          .from(tableName)
          .delete()
          .eq('id', recordId)
          .eq('user_id', currentUserId!);

      return {
        'success': true,
        'message': 'PSI record deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting PSI record: ${e.toString()}',
      };
    }
  }
}
