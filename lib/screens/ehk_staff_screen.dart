import 'package:flutter/material.dart';
import '../models/ehk_staff_model.dart';
import '../services/ehk_staff_service.dart';

class EHKStaffScreen extends StatefulWidget {
  const EHKStaffScreen({super.key});

  @override
  State<EHKStaffScreen> createState() => _EHKStaffScreenState();
}

class _EHKStaffScreenState extends State<EHKStaffScreen> {
  final _staffService = EHKStaffService();
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userNameController = TextEditingController();

  List<EHKStaff> _staffList = [];
  bool _isLoading = true;
  EHKStaff? _editingStaff;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    final staff = await _staffService.getAllStaff();
    setState(() {
      _staffList = staff;
      _isLoading = false;
    });
  }

  void _clearForm() {
    _userIdController.clear();
    _passwordController.clear();
    _userNameController.clear();
    setState(() => _editingStaff = null);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final staff = EHKStaff(
      id: _editingStaff?.id,
      userId: _userIdController.text.trim(),
      password: _passwordController.text.trim(),
      userName: _userNameController.text.trim(),
      createdAt: _editingStaff?.createdAt ?? DateTime.now(),
    );

    Map<String, dynamic> result;
    if (_editingStaff != null) {
      result = await _staffService.updateStaff(_editingStaff!.id!, staff);
    } else {
      result = await _staffService.addStaff(staff);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      if (result['success']) {
        _clearForm();
        _loadStaff();
      }
    }
  }

  void _editStaff(EHKStaff staff) {
    setState(() {
      _editingStaff = staff;
      _userIdController.text = staff.userId;
      _passwordController.text = staff.password;
      _userNameController.text = staff.userName;
    });
  }

  Future<void> _deleteStaff(String id, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete $userName?'),
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
      final result = await _staffService.deleteStaff(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
        if (result['success']) {
          _loadStaff();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingStaff != null ? 'Update EHK Staff' : 'EHK Staff'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Form Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _editingStaff != null ? 'Update EHK Staff' : 'Add EHK Staff',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _userIdController,
                    decoration: const InputDecoration(
                      labelText: 'User ID*',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter User ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password*',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      labelText: 'User Name*',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter User Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: Text(_editingStaff != null ? 'Update' : 'Submit'),
                      ),
                      if (_editingStaff != null) ...[
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: _clearForm,
                          child: const Text('Cancel'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Staff List Section
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _staffList.isEmpty
                      ? const Center(
                          child: Text(
                            'No staff members found',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'EHK Staff Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      Colors.grey.shade200,
                                    ),
                                    border: TableBorder.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'S.No',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'UserID',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Password',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'UserName',
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
                                    rows: _staffList.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final staff = entry.value;
                                      return DataRow(
                                        cells: [
                                          DataCell(Text('${index + 1}')),
                                          DataCell(Text(staff.userId)),
                                          DataCell(Text(staff.password)),
                                          DataCell(Text(staff.userName)),
                                          DataCell(
                                            TextButton(
                                              onPressed: () => _editStaff(staff),
                                              child: const Text(
                                                'Edit',
                                                style: TextStyle(color: Colors.blue),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            TextButton(
                                              onPressed: () => _deleteStaff(
                                                staff.id!,
                                                staff.userName,
                                              ),
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
                              ],
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
