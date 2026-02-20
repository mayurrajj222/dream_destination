import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ehk_staff_model.dart';

class EHKStaffService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'ehk_staff';

  // Get all EHK staff
  Future<List<EHKStaff>> getAllStaff() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EHKStaff.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting staff: $e');
      return [];
    }
  }

  // Get staff by ID
  Future<EHKStaff?> getStaffById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return EHKStaff.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting staff: $e');
      return null;
    }
  }

  // Add new staff and create Firebase Auth user
  Future<Map<String, dynamic>> addStaff(EHKStaff staff) async {
    try {
      // Check if userId already exists
      final existing = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: staff.userId)
          .get();

      if (existing.docs.isNotEmpty) {
        return {'success': false, 'message': 'User ID already exists'};
      }

      // Create email format: userId@dreamdestination.com
      final email = '${staff.userId}@dreamdestination.com';

      // Create Firebase Auth user
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: staff.password,
        );

        // Store staff details in Firestore
        await _firestore.collection(_collection).add(staff.toMap());

        return {'success': true, 'message': 'Staff added successfully'};
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          return {'success': false, 'message': 'User ID already registered'};
        }
        return {'success': false, 'message': 'Auth error: ${e.message}'};
      }
    } catch (e) {
      print('Error adding staff: $e');
      return {'success': false, 'message': 'Failed to add staff: $e'};
    }
  }

  // Update staff
  Future<Map<String, dynamic>> updateStaff(String id, EHKStaff staff) async {
    try {
      await _firestore.collection(_collection).doc(id).update(staff.toMap());
      return {'success': true, 'message': 'Staff updated successfully'};
    } catch (e) {
      print('Error updating staff: $e');
      return {'success': false, 'message': 'Failed to update staff: $e'};
    }
  }

  // Delete staff
  Future<Map<String, dynamic>> deleteStaff(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return {'success': true, 'message': 'Staff deleted successfully'};
    } catch (e) {
      print('Error deleting staff: $e');
      return {'success': false, 'message': 'Failed to delete staff: $e'};
    }
  }
}
