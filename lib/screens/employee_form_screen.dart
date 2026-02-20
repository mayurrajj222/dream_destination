import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee; // For update mode

  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeService = EmployeeService();

  // Controllers
  late TextEditingController _employeeCodeController;
  late TextEditingController _employeeNameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _esiNoController;
  late TextEditingController _pfNoController;
  late TextEditingController _pancardNoController;
  late TextEditingController _aadharNoController;

  String _selectedCategory = 'User';
  bool _isPhotoUpload = false;
  bool _isLoading = false;

  final List<String> _categories = ['User', 'Admin', 'Manager', 'Staff'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if updating
    _employeeCodeController = TextEditingController(
      text: widget.employee?.employeeCode ?? '',
    );
    _employeeNameController = TextEditingController(
      text: widget.employee?.employeeName ?? '',
    );
    _fatherNameController = TextEditingController(
      text: widget.employee?.fatherName ?? '',
    );
    _phoneNumberController = TextEditingController(
      text: widget.employee?.phoneNumber ?? '',
    );
    _esiNoController = TextEditingController(
      text: widget.employee?.esiNo ?? '',
    );
    _pfNoController = TextEditingController(
      text: widget.employee?.pfNo ?? '',
    );
    _pancardNoController = TextEditingController(
      text: widget.employee?.pancardNo ?? '',
    );
    _aadharNoController = TextEditingController(
      text: widget.employee?.aadharNo ?? '',
    );

    if (widget.employee != null) {
      _selectedCategory = widget.employee!.employeeCategory;
      _isPhotoUpload = widget.employee!.isPhotoUpload;
    }
  }

  @override
  void dispose() {
    _employeeCodeController.dispose();
    _employeeNameController.dispose();
    _fatherNameController.dispose();
    _phoneNumberController.dispose();
    _esiNoController.dispose();
    _pfNoController.dispose();
    _pancardNoController.dispose();
    _aadharNoController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final employee = Employee(
        id: widget.employee?.id,
        employeeCode: _employeeCodeController.text.trim(),
        employeeName: _employeeNameController.text.trim(),
        fatherName: _fatherNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        esiNo: _esiNoController.text.trim(),
        pfNo: _pfNoController.text.trim(),
        pancardNo: _pancardNoController.text.trim(),
        aadharNo: _aadharNoController.text.trim(),
        employeeCategory: _selectedCategory,
        isPhotoUpload: _isPhotoUpload,
      );

      Map<String, dynamic> result;
      if (widget.employee == null) {
        // Create new employee
        result = await _employeeService.createEmployee(employee);
      } else {
        // Update existing employee
        result = await _employeeService.updateEmployee(
          widget.employee!.id!,
          employee,
        );
      }

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      if (result['success']) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.employee != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Update Employee' : 'Add Employee'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Is Photo Upload Dropdown
                _buildDropdown(
                  label: 'Is Photo Upload',
                  value: _isPhotoUpload ? 'Yes' : 'No',
                  items: ['Yes', 'No'],
                  onChanged: (value) {
                    setState(() => _isPhotoUpload = value == 'Yes');
                  },
                ),
                const SizedBox(height: 16),

                // Employee Code
                _buildTextField(
                  controller: _employeeCodeController,
                  label: 'Employee Code*',
                  enabled: !isUpdate, // Disable in update mode
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter employee code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Employee Name
                _buildTextField(
                  controller: _employeeNameController,
                  label: 'Employee Name*',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter employee name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Father Name
                _buildTextField(
                  controller: _fatherNameController,
                  label: 'Father Name',
                ),
                const SizedBox(height: 16),

                // Phone Number
                _buildTextField(
                  controller: _phoneNumberController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // ESI No.
                _buildTextField(
                  controller: _esiNoController,
                  label: 'ESI No.',
                ),
                const SizedBox(height: 16),

                // PF No.
                _buildTextField(
                  controller: _pfNoController,
                  label: 'PF No.',
                ),
                const SizedBox(height: 16),

                // Pancard No.
                _buildTextField(
                  controller: _pancardNoController,
                  label: 'Pancard No.',
                ),
                const SizedBox(height: 16),

                // Aadhar No.
                _buildTextField(
                  controller: _aadharNoController,
                  label: 'Aadhar No.',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Employee Category
                _buildDropdown(
                  label: 'Employee Category',
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                ),
                const SizedBox(height: 16),

                // Photo Upload (placeholder)
                _buildFileUploadField(
                  label: 'Photo',
                  onTap: () {
                    // TODO: Implement photo upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photo upload feature coming soon'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // All Document Upload (placeholder)
                _buildFileUploadField(
                  label: 'All Document',
                  onTap: () {
                    // TODO: Implement document upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Document upload feature coming soon'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadField({
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Choose file',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'No file chosen',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
