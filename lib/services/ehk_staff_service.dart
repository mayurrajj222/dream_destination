// import 'package:cloud_firestore/cloud_firestore.dart'; // TODO: Migrate to Supabase
// import 'package:firebase_auth/firebase_auth.dart'; // TODO: Migrate to Supabase
import '../models/ehk_staff_model.dart';

class EHKStaffService {
  // TODO: Migrate to Supabase
  // This service is temporarily stubbed to allow PSI functionality to work
  // Full migration to Supabase pending
  
  final String _collection = 'ehk_staff';

  // Get all EHK staff
  Future<List<EHKStaff>> getAllEHKStaff() async {
    return [];
  }

  // Get EHK staff by ID
  Future<EHKStaff?> getEHKStaffById(String id) async {
    return null;
  }

  // Get EHK staff by customer ID
  Future<EHKStaff?> getEHKStaffByCustomerId(String customerId) async {
    return null;
  }

  // Create EHK staff
  Future<Map<String, dynamic>> createEHKStaff(EHKStaff staff) async {
    return {
      'success': false,
      'message': 'EHK staff service not yet migrated to Supabase',
    };
  }

  // Update EHK staff
  Future<Map<String, dynamic>> updateEHKStaff(String id, EHKStaff staff) async {
    return {
      'success': false,
      'message': 'EHK staff service not yet migrated to Supabase',
    };
  }

  // Delete EHK staff
  Future<Map<String, dynamic>> deleteEHKStaff(String id) async {
    return {
      'success': false,
      'message': 'EHK staff service not yet migrated to Supabase',
    };
  }

  // Login EHK staff
  Future<Map<String, dynamic>> loginEHKStaff(String userId, String password) async {
    return {
      'success': false,
      'message': 'EHK staff service not yet migrated to Supabase',
    };
  }

  // Get all staff (alias for getAllEHKStaff)
  Future<List<EHKStaff>> getAllStaff() async {
    return getAllEHKStaff();
  }

  // Add staff (alias for createEHKStaff)
  Future<Map<String, dynamic>> addStaff(EHKStaff staff) async {
    return createEHKStaff(staff);
  }

  // Update staff (alias for updateEHKStaff)
  Future<Map<String, dynamic>> updateStaff(String id, EHKStaff staff) async {
    return updateEHKStaff(id, staff);
  }

  // Delete staff (alias for deleteEHKStaff)
  Future<Map<String, dynamic>> deleteStaff(String id) async {
    return deleteEHKStaff(id);
  }
}
