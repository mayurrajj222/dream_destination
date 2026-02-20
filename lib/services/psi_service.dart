import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/psi_record_model.dart';

class PSIService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'psi_records';

  // Create PSI record
  Future<Map<String, dynamic>> createPSIRecord(PSIRecord record) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(collectionName)
          .add(record.toMap());

      return {
        'success': true,
        'message': 'PSI record created successfully',
        'recordId': docRef.id,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating PSI record: ${e.toString()}',
      };
    }
  }

  // Get PSI records by date range
  Future<List<PSIRecord>> getPSIRecordsByDateRange(
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
          .map((doc) => PSIRecord.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting PSI records by date range: $e');
      return [];
    }
  }

  // Get PSI records by train and date range
  Future<List<PSIRecord>> getPSIRecordsByTrainAndDateRange(
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
          .map((doc) => PSIRecord.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting PSI records by train: $e');
      return [];
    }
  }

  // Get PSI records by trip
  Future<List<PSIRecord>> getPSIRecordsByTrip(String tripId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('tripId', isEqualTo: tripId)
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => PSIRecord.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting PSI records by trip: $e');
      return [];
    }
  }

  // Get PSI records with filters
  Future<List<PSIRecord>> getPSIRecordsByFilters({
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
          .map((doc) => PSIRecord.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting PSI records by filters: $e');
      return [];
    }
  }

  // Get PSI summary statistics
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

      double totalPSI = 0;
      double highestPSI = records.first.psiScore;
      double lowestPSI = records.first.psiScore;
      int above90 = 0;
      int between70and90 = 0;
      int below70 = 0;

      for (var record in records) {
        totalPSI += record.psiScore;
        if (record.psiScore > highestPSI) highestPSI = record.psiScore;
        if (record.psiScore < lowestPSI) lowestPSI = record.psiScore;

        if (record.psiScore >= 90) {
          above90++;
        } else if (record.psiScore >= 70) {
          between70and90++;
        } else {
          below70++;
        }
      }

      return {
        'totalRecords': records.length,
        'averagePSI': totalPSI / records.length,
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

  // Get trainwise PSI summary
  Future<Map<String, Map<String, dynamic>>> getTrainwisePSISummary(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    try {
      final records = await getPSIRecordsByDateRange(fromDate, toDate);
      Map<String, List<PSIRecord>> trainGroups = {};

      // Group by train
      for (var record in records) {
        if (!trainGroups.containsKey(record.trainNo)) {
          trainGroups[record.trainNo] = [];
        }
        trainGroups[record.trainNo]!.add(record);
      }

      // Calculate summary for each train
      Map<String, Map<String, dynamic>> summary = {};
      trainGroups.forEach((trainNo, trainRecords) {
        double totalPSI = 0;
        for (var record in trainRecords) {
          totalPSI += record.psiScore;
        }

        summary[trainNo] = {
          'trainName': trainRecords.first.trainName,
          'totalRecords': trainRecords.length,
          'averagePSI': totalPSI / trainRecords.length,
        };
      });

      return summary;
    } catch (e) {
      print('Error getting trainwise PSI summary: $e');
      return {};
    }
  }

  // Update PSI record
  Future<Map<String, dynamic>> updatePSIRecord(
    String recordId,
    PSIRecord record,
  ) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(recordId)
          .update(record.toMap());

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
      await _firestore.collection(collectionName).doc(recordId).delete();

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
