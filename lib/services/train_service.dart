import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/train_model.dart';

class TrainService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String tableName = 'trains';

  // Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Create new train
  Future<Map<String, dynamic>> createTrain(Train train) async {
    try {
      print('TrainService: Creating train ${train.trainNoGoing}');
      
      if (currentUserId == null) {
        print('TrainService: User not authenticated');
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      print('TrainService: Current user ID: $currentUserId');

      // Check if train number already exists for this user
      final existing = await _supabase
          .from(tableName)
          .select()
          .eq('user_id', currentUserId!)
          .eq('train_no_going', train.trainNoGoing)
          .maybeSingle();

      if (existing != null) {
        print('TrainService: Train already exists: ${existing['id']}');
        return {
          'success': false,
          'message': 'Train number already exists',
          'trainId': existing['id'], // Return existing train ID
        };
      }

      final trainData = train.toMap();
      trainData['user_id'] = currentUserId;

      print('TrainService: Inserting train data: $trainData');

      final response = await _supabase
          .from(tableName)
          .insert(trainData)
          .select()
          .single();

      print('TrainService: Train created successfully: ${response['id']}');

      return {
        'success': true,
        'message': 'Train created successfully',
        'trainId': response['id'],
      };
    } catch (e) {
      print('TrainService: Error creating train: $e');
      return {
        'success': false,
        'message': 'Error creating train: ${e.toString()}',
      };
    }
  }

  // Get train by ID
  Future<Train?> getTrainById(String trainId) async {
    try {
      if (currentUserId == null) return null;

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', trainId)
          .eq('user_id', currentUserId!)
          .maybeSingle();

      if (response != null) {
        return Train.fromMap(response, response['id']);
      }
      return null;
    } catch (e) {
      print('Error getting train: $e');
      return null;
    }
  }

  // Get train by train number
  Future<Train?> getTrainByNumber(String trainNo) async {
    try {
      if (currentUserId == null) return null;

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('user_id', currentUserId!)
          .eq('train_no_going', trainNo)
          .maybeSingle();

      if (response != null) {
        return Train.fromMap(response, response['id']);
      }
      return null;
    } catch (e) {
      print('Error getting train by number: $e');
      return null;
    }
  }

  // Get all trains for current user
  Future<List<Train>> getAllTrains() async {
    try {
      if (currentUserId == null) return [];

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('user_id', currentUserId!)
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => Train.fromMap(data, data['id']))
          .toList();
    } catch (e) {
      print('Error getting all trains: $e');
      return [];
    }
  }

  // Get trains by station
  Future<List<Train>> getTrainsByStation(String station) async {
    try {
      if (currentUserId == null) return [];

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('user_id', currentUserId!)
          .eq('station_from', station)
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => Train.fromMap(data, data['id']))
          .toList();
    } catch (e) {
      print('Error getting trains by station: $e');
      return [];
    }
  }

  // Update train
  Future<Map<String, dynamic>> updateTrain(String trainId, Train train) async {
    try {
      if (currentUserId == null) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      final trainData = train.toMap();
      trainData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from(tableName)
          .update(trainData)
          .eq('id', trainId)
          .eq('user_id', currentUserId!);

      return {
        'success': true,
        'message': 'Train updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating train: ${e.toString()}',
      };
    }
  }

  // Delete train
  Future<Map<String, dynamic>> deleteTrain(String trainId) async {
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
          .eq('id', trainId)
          .eq('user_id', currentUserId!);

      return {
        'success': true,
        'message': 'Train deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting train: ${e.toString()}',
      };
    }
  }

  // Search trains
  Future<List<Train>> searchTrains(String searchTerm) async {
    try {
      if (currentUserId == null) return [];

      final lowerSearch = searchTerm.toLowerCase();

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('user_id', currentUserId!)
          .order('created_at', ascending: false);

      final trains = (response as List)
          .map((data) => Train.fromMap(data, data['id']))
          .toList();

      // Filter in memory for text search
      return trains.where((train) {
        return train.trainNoGoing.toLowerCase().contains(lowerSearch) ||
            train.trainNameGoing.toLowerCase().contains(lowerSearch) ||
            train.stationFrom.toLowerCase().contains(lowerSearch) ||
            train.stationTo.toLowerCase().contains(lowerSearch);
      }).toList();
    } catch (e) {
      print('Error searching trains: $e');
      return [];
    }
  }

  // Get total train count
  Future<int> getTotalTrainCount() async {
    try {
      if (currentUserId == null) return 0;

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('user_id', currentUserId!);

      return (response as List).length;
    } catch (e) {
      print('Error counting trains: $e');
      return 0;
    }
  }
}
