import 'package:flutter/material.dart';
import 'dart:io';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:path_provider/path_provider.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import 'employee_form_screen.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  const EmployeeDetailsScreen({super.key});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  final _employeeService = EmployeeService();
  final _searchController = TextEditingController();
  
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    final employees = await _employeeService.getAllEmployees();
    setState(() {
      _allEmployees = employees;
      _filteredEmployees = employees;
      _isLoading = false;
    });
  }

  void _searchEmployees() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() => _filteredEmployees = _allEmployees);
      return;
    }

    setState(() {
      _filteredEmployees = _allEmployees.where((employee) {
        return employee.employeeName.toLowerCase().contains(query) ||
               employee.employeeCode.toLowerCase().contains(query) ||
               employee.fatherName.toLowerCase().contains(query) ||
               employee.phoneNumber.contains(query) ||
               employee.aadharNo.contains(query);
      }).toList();
    });
  }

  Future<void> _exportToExcel() async {
    try {
      // Create Excel workbook
      var excelFile = excel_pkg.Excel.createExcel();
      excel_pkg.Sheet sheetObject = excelFile['Employee Data'];

      // Add headers
      sheetObject.appendRow([
        excel_pkg.TextCellValue('S.No'),
        excel_pkg.TextCellValue('Paycode'),
        excel_pkg.TextCellValue('EmpName'),
        excel_pkg.TextCellValue('FatherName'),
        excel_pkg.TextCellValue('PhoneNo'),
        excel_pkg.TextCellValue('AadharNo'),
        excel_pkg.TextCellValue('ESI No'),
        excel_pkg.TextCellValue('PF No'),
        excel_pkg.TextCellValue('Pancard No'),
        excel_pkg.TextCellValue('Category'),
      ]);

      // Add data rows
      for (int i = 0; i < _filteredEmployees.length; i++) {
        final emp = _filteredEmployees[i];
        sheetObject.appendRow([
          excel_pkg.IntCellValue(i + 1),
          excel_pkg.TextCellValue(emp.employeeCode),
          excel_pkg.TextCellValue(emp.employeeName),
          excel_pkg.TextCellValue(emp.fatherName),
          excel_pkg.TextCellValue(emp.phoneNumber),
          excel_pkg.TextCellValue(emp.aadharNo),
          excel_pkg.TextCellValue(emp.esiNo),
          excel_pkg.TextCellValue(emp.pfNo),
          excel_pkg.TextCellValue(emp.pancardNo),
          excel_pkg.TextCellValue(emp.employeeCategory),
        ]);
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/employee_data_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      
      final fileBytes = excelFile.save();
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Excel exported successfully to:\n$filePath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting Excel: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteEmployee(String employeeId, String employeeName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete $employeeName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _employeeService.deleteEmployee(employeeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (result['success']) {
          _loadEmployees();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: Column(
          children: [
            // Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Employee Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Search Employee*',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name, code, phone, or aadhar...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) => _searchEmployees(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _searchEmployees,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Search'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _exportToExcel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Export Excel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmployeeFormScreen(),
                            ),
                          ).then((result) {
                            if (result == true) {
                              _loadEmployees();
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Data Table
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredEmployees.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No employees found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.grey.shade200,
                                ),
                                border: TableBorder.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                columnSpacing: 20,
                                horizontalMargin: 12,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'S.No',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Paycode',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'EmpName',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'FatherName',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'PhoneNo',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'AadharNo',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'PhotoName',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'AllDocument',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Edit',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Delete',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                                rows: _filteredEmployees.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final employee = entry.value;
                                  
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${index + 1}')),
                                      DataCell(Text(employee.employeeCode)),
                                      DataCell(Text(employee.employeeName)),
                                      DataCell(Text(employee.fatherName)),
                                      DataCell(Text(employee.phoneNumber)),
                                      DataCell(Text(employee.aadharNo)),
                                      DataCell(
                                        employee.photoUrl != null && employee.photoUrl!.isNotEmpty
                                            ? Image.network(
                                                employee.photoUrl!,
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(Icons.person, size: 40);
                                                },
                                              )
                                            : const Icon(Icons.person, size: 40),
                                      ),
                                      DataCell(
                                        employee.documentUrl != null && employee.documentUrl!.isNotEmpty
                                            ? TextButton(
                                                onPressed: () {
                                                  // TODO: Open document
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Document download feature coming soon'),
                                                    ),
                                                  );
                                                },
                                                child: const Text('Download'),
                                              )
                                            : const Text('-'),
                                      ),
                                      DataCell(
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EmployeeFormScreen(
                                                  employee: employee,
                                                ),
                                              ),
                                            ).then((result) {
                                              if (result == true) {
                                                _loadEmployees();
                                              }
                                            });
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                'assets/edit_icon.png',
                                                width: 20,
                                                height: 20,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.edit,
                                                    color: Colors.orange,
                                                    size: 20,
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                'Edit',
                                                style: TextStyle(color: Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        TextButton(
                                          onPressed: () {
                                            _deleteEmployee(
                                              employee.id!,
                                              employee.employeeName,
                                            );
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
