import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_card_model.dart';

class TripCardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'trip_cards';

  // Get all trip cards
  Future<List<TripCard>> getAllTripCards() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TripCard.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting trip cards: $e');
      return [];
    }
  }

  // Get trip card by ID
  Future<TripCard?> getTripCardById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return TripCard.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting trip card: $e');
      return null;
    }
  }

  // Add new trip card
  Future<Map<String, dynamic>> addTripCard(TripCard tripCard) async {
    try {
      await _firestore.collection(_collection).add(tripCard.toMap());
      return {'success': true, 'message': 'Trip card added successfully'};
    } catch (e) {
      print('Error adding trip card: $e');
      return {'success': false, 'message': 'Failed to add trip card: $e'};
    }
  }

  // Update trip card
  Future<Map<String, dynamic>> updateTripCard(
      String id, TripCard tripCard) async {
    try {
      await _firestore.collection(_collection).doc(id).update(tripCard.toMap());
      return {'success': true, 'message': 'Trip card updated successfully'};
    } catch (e) {
      print('Error updating trip card: $e');
      return {'success': false, 'message': 'Failed to update trip card: $e'};
    }
  }

  // Delete trip card
  Future<Map<String, dynamic>> deleteTripCard(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return {'success': true, 'message': 'Trip card deleted successfully'};
    } catch (e) {
      print('Error deleting trip card: $e');
      return {'success': false, 'message': 'Failed to delete trip card: $e'};
    }
  }

  // Search trip cards
  Future<List<TripCard>> searchTripCards(String query) async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final allCards = snapshot.docs
          .map((doc) => TripCard.fromMap(doc.data(), doc.id))
          .toList();

      return allCards.where((card) {
        final searchLower = query.toLowerCase();
        return card.tripId.toLowerCase().contains(searchLower) ||
            card.trainNo.toLowerCase().contains(searchLower) ||
            card.trainName.toLowerCase().contains(searchLower) ||
            card.ehkName.toLowerCase().contains(searchLower);
      }).toList();
    } catch (e) {
      print('Error searching trip cards: $e');
      return [];
    }
  }
}
