// import 'package:cloud_firestore/cloud_firestore.dart'; // TODO: Migrate to Supabase
import '../models/employee_model.dart';

class EmployeeService {
  // TODO: Migrate to Supabase
  // This service is temporarily stubbed to allow PSI functionality to work
  // Full migration to Supabase pending
  
  final String collectionName = 'employee';

  // Create new employee
  Future<Map<String, dynamic>> createEmployee(Employee employee) async {
    return {
      'success': false,
      'message': 'Employee service not yet migrated to Supabase',
    };
  }

  // Get employee by ID
  Future<Employee?> getEmployeeById(String employeeId) async {
    return null;
  }

  // Get employee by code
  Future<Employee?> getEmployeeByCode(String employeeCode) async {
    return null;
  }

  // Get all employees
  Future<List<Employee>> getAllEmployees() async {
    return [];
  }

  // Get employees by category
  Future<List<Employee>> getEmployeesByCategory(String category) async {
    return [];
  }

  // Update employee
  Future<Map<String, dynamic>> updateEmployee(String employeeId, Employee employee) async {
    return {
      'success': false,
      'message': 'Employee service not yet migrated to Supabase',
    };
  }

  // Delete employee
  Future<Map<String, dynamic>> deleteEmployee(String employeeId) async {
    return {
      'success': false,
      'message': 'Employee service not yet migrated to Supabase',
    };
  }

  // Search employees
  Future<List<Employee>> searchEmployees(String searchTerm) async {
    return [];
  }

  // Get total employee count
  Future<int> getTotalEmployeeCount() async {
    return 0;
  }
}
