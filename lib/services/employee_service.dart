import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_model.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'employee';

  // Create new employee
  Future<Map<String, dynamic>> createEmployee(Employee employee) async {
    try {
      // Check if employee code already exists
      final existingEmployee = await _firestore
          .collection(collectionName)
          .where('employeeCode', isEqualTo: employee.employeeCode)
          .get();

      if (existingEmployee.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Employee code already exists',
        };
      }

      // Add employee to Firestore
      DocumentReference docRef = await _firestore
          .collection(collectionName)
          .add(employee.toMap());

      return {
        'success': true,
        'message': 'Employee created successfully',
        'employeeId': docRef.id,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating employee: ${e.toString()}',
      };
    }
  }

  // Get employee by ID
  Future<Employee?> getEmployeeById(String employeeId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(collectionName)
          .doc(employeeId)
          .get();

      if (doc.exists) {
        return Employee.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting employee: $e');
      return null;
    }
  }

  // Get employee by employee code
  Future<Employee?> getEmployeeByCode(String employeeCode) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('employeeCode', isEqualTo: employeeCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Employee.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>,
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting employee by code: $e');
      return null;
    }
  }

  // Get all employees
  Future<List<Employee>> getAllEmployees() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Employee.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting all employees: $e');
      return [];
    }
  }

  // Get employees by category
  Future<List<Employee>> getEmployeesByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('employeeCategory', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Employee.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting employees by category: $e');
      return [];
    }
  }

  // Update employee
  Future<Map<String, dynamic>> updateEmployee(
    String employeeId,
    Employee employee,
  ) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(employeeId)
          .update(employee.toMap());

      return {
        'success': true,
        'message': 'Employee updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating employee: ${e.toString()}',
      };
    }
  }

  // Delete employee
  Future<Map<String, dynamic>> deleteEmployee(String employeeId) async {
    try {
      await _firestore.collection(collectionName).doc(employeeId).delete();

      return {
        'success': true,
        'message': 'Employee deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting employee: ${e.toString()}',
      };
    }
  }

  // Search employees by name
  Future<List<Employee>> searchEmployeesByName(String searchTerm) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .orderBy('employeeName')
          .startAt([searchTerm])
          .endAt(['$searchTerm\uf8ff'])
          .get();

      return querySnapshot.docs
          .map((doc) => Employee.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error searching employees: $e');
      return [];
    }
  }

  // Get employees stream (real-time updates)
  Stream<List<Employee>> getEmployeesStream() {
    return _firestore
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Employee.fromMap(
                  doc.data(),
                  doc.id,
                ))
            .toList());
  }

  // Count total employees
  Future<int> getTotalEmployeeCount() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionName).get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error counting employees: $e');
      return 0;
    }
  }

  // Count employees by category
  Future<int> getEmployeeCountByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('employeeCategory', isEqualTo: category)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error counting employees by category: $e');
      return 0;
    }
  }
}
