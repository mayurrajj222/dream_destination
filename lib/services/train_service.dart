import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/train_model.dart';

class TrainService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'trains';

  // Create new train
  Future<Map<String, dynamic>> createTrain(Train train) async {
    try {
      // Check if train number already exists
      final existingTrain = await _firestore
          .collection(collectionName)
          .where('trainNoGoing', isEqualTo: train.trainNoGoing)
          .get();

      if (existingTrain.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Train number already exists',
        };
      }

      DocumentReference docRef = await _firestore
          .collection(collectionName)
          .add(train.toMap());

      return {
        'success': true,
        'message': 'Train created successfully',
        'trainId': docRef.id,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating train: ${e.toString()}',
      };
    }
  }

  // Get train by ID
  Future<Train?> getTrainById(String trainId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(collectionName)
          .doc(trainId)
          .get();

      if (doc.exists) {
        return Train.fromMap(doc.data() as Map<String, dynamic>, doc.id);
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
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('trainNoGoing', isEqualTo: trainNo)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Train.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>,
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting train by number: $e');
      return null;
    }
  }

  // Get all trains
  Future<List<Train>> getAllTrains() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Train.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting all trains: $e');
      return [];
    }
  }

  // Get trains by station
  Future<List<Train>> getTrainsByStation(String station) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('stationFrom', isEqualTo: station)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Train.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting trains by station: $e');
      return [];
    }
  }

  // Update train
  Future<Map<String, dynamic>> updateTrain(
    String trainId,
    Train train,
  ) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(trainId)
          .update(train.toMap());

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
      await _firestore.collection(collectionName).doc(trainId).delete();

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

  // Search trains by name or number
  Future<List<Train>> searchTrains(String searchTerm) async {
    try {
      final lowerSearch = searchTerm.toLowerCase();
      
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .get();

      return querySnapshot.docs
          .map((doc) => Train.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .where((train) =>
              train.trainNoGoing.toLowerCase().contains(lowerSearch) ||
              train.trainNameGoing.toLowerCase().contains(lowerSearch) ||
              train.trainNoComing.toLowerCase().contains(lowerSearch) ||
              train.trainNameComing.toLowerCase().contains(lowerSearch) ||
              train.stationFrom.toLowerCase().contains(lowerSearch) ||
              train.stationTo.toLowerCase().contains(lowerSearch))
          .toList();
    } catch (e) {
      print('Error searching trains: $e');
      return [];
    }
  }

  // Get trains stream (real-time updates)
  Stream<List<Train>> getTrainsStream() {
    return _firestore
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Train.fromMap(
                  doc.data(),
                  doc.id,
                ))
            .toList());
  }

  // Count total trains
  Future<int> getTotalTrainCount() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionName).get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error counting trains: $e');
      return 0;
    }
  }
}
