// import 'package:cloud_firestore/cloud_firestore.dart'; // TODO: Migrate to Supabase
import '../models/trip_card_model.dart';

class TripCardService {
  // TODO: Migrate to Supabase
  // This service is temporarily stubbed to allow PSI functionality to work
  // Full migration to Supabase pending
  
  final String _collection = 'trip_cards';

  // Get all trip cards
  Future<List<TripCard>> getAllTripCards() async {
    return [];
  }

  // Get trip card by ID
  Future<TripCard?> getTripCardById(String id) async {
    return null;
  }

  // Create trip card
  Future<Map<String, dynamic>> createTripCard(TripCard tripCard) async {
    return {
      'success': false,
      'message': 'Trip card service not yet migrated to Supabase',
    };
  }

  // Update trip card
  Future<Map<String, dynamic>> updateTripCard(String id, TripCard tripCard) async {
    return {
      'success': false,
      'message': 'Trip card service not yet migrated to Supabase',
    };
  }

  // Delete trip card
  Future<Map<String, dynamic>> deleteTripCard(String id) async {
    return {
      'success': false,
      'message': 'Trip card service not yet migrated to Supabase',
    };
  }

  // Search trip cards
  Future<List<TripCard>> searchTripCards(String query) async {
    return [];
  }
}
