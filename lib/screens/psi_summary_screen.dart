import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/psi_service.dart';
import '../services/psi_summary_import_service.dart';
import '../services/train_service.dart';
import '../models/psi_record_model.dart';
import '../models/train_model.dart';

class PSISummaryScreen extends StatefulWidget {
  const PSISummaryScreen({super.key});

  @override
  State<PSISummaryScreen> createState() => _PSISummaryScreenState();
}

class _PSISummaryScreenState extends State<PSISummaryScreen> {
  final _psiService = PSIService();
  final _summaryImportService = PSISummaryImportService();
  final _trainService = TrainService();
  
  Map<String, dynamic> _summary = {};
  List<PSIRecord> _psiRecords = [];
  List<Train> _trains = [];
  bool _isLoading = true;
  
  // Date range
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  
  // Train selection
  String? _selectedTrainId;

  @override
  void initState() {
    super.initState();
    _loadTrains();
  }

  Future<void> _loadTrains() async {
    try {
      final trains = await _trainService.getAllTrains();
      setState(() {
        _trains = trains;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading trains: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    
    List<PSIRecord> records;
    
    if (_selectedTrainId != null && _selectedTrainId!.isNotEmpty) {
      // Load records for specific train
      records = await _psiService.getPSIRecordsByTrainAndDateRange(
        _selectedTrainId!,
        _fromDate,
        _toDate,
      );
    } else {
      // Load all records
      records = await _psiService.getPSIRecordsByDateRange(_fromDate, _toDate);
    }
    
    // Calculate summary from records
    final summary = _calculateSummary(records);
    
    setState(() {
      _summary = summary;
      _psiRecords = records;
      _isLoading = false;
    });
  }

  Map<String, dynamic> _calculateSummary(List<PSIRecord> records) {
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

    final psiScores = records.map((r) => r.psiScore).toList();
    final totalPSI = psiScores.reduce((a, b) => a + b);
    final averagePSI = totalPSI / records.length;
    final highestPSI = psiScores.reduce((a, b) => a > b ? a : b);
    final lowestPSI = psiScores.reduce((a, b) => a < b ? a : b);

    int above90 = 0;
    int between70and90 = 0;
    int below70 = 0;

    for (var score in psiScores) {
      if (score >= 90) {
        above90++;
      } else if (score >= 70) {
        between70and90++;
      } else {
        below70++;
      }
    }

    return {
      'totalRecords': records.length,
      'averagePSI': averagePSI,
      'highestPSI': highestPSI,
      'lowestPSI': lowestPSI,
      'above90': above90,
      'between70and90': between70and90,
      'below70': below70,
    };
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: _toDate,
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
      _loadSummary();
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
      _loadSummary();
    }
  }

  Future<void> _importExcel() async {
    setState(() => _isLoading = true);

    final result = await _summaryImportService.importPSISummaryFromExcel();

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Successful'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Records: ${result['totalRecords']}'),
                  Text('Successfully Imported: ${result['successCount']}'),
                  if (result['errorCount'] > 0)
                    Text(
                      'Errors: ${result['errorCount']}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 12),
                  if (result['metadata'] != null) ...[
                    const Text(
                      'Metadata:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('EHK Name: ${result['metadata']['ehkName'] ?? 'N/A'}'),
                    Text('Trip ID: ${result['metadata']['tripId'] ?? 'N/A'}'),
                    Text('Train No: ${result['metadata']['trainNo'] ?? 'N/A'}'),
                  ],
                  if (result['errorCount'] > 0 && result['errors'] != null && (result['errors'] as List).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Error Details:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (result['errors'] as List).take(10).map((error) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $error',
                                style: const TextStyle(fontSize: 12, color: Colors.red),
                              ),
                            )
                          ).toList(),
                        ),
                      ),
                    ),
                    if ((result['errors'] as List).length > 10)
                      Text(
                        '... and ${(result['errors'] as List).length - 10} more errors',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadSummary();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tripwise PSI Summary'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _isLoading ? null : _importExcel,
            tooltip: 'Import Excel',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  // Date Selection Section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tripwise PSI Summary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Train Selection
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Train',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedTrainId,
                                    hint: const Text('---All Train---'),
                                    isExpanded: true,
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('---All Train---'),
                                      ),
                                      ..._trains.map((train) {
                                        return DropdownMenuItem<String>(
                                          value: train.id,
                                          child: Text('${train.trainNoGoing} - ${train.trainNameGoing}'),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedTrainId = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // From Date
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'From Date*',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: InkWell(
                                onTap: () => _selectFromDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(_fromDate),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // To Date
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'To Date*',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: InkWell(
                                onTap: () => _selectToDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(_toDate),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _loadSummary,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: const Text('Show'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _importExcel,
                                icon: const Icon(Icons.upload_file, size: 18),
                                label: const Text('Import Excel'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // PSI Records Table
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'PSI Summary',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Total Records: ${_psiRecords.length}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Table Content
                          Expanded(
                            child: _psiRecords.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inbox_outlined,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No PSI records found for selected date range',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      child: DataTable(
                                        headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                                        border: TableBorder.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                        columnSpacing: 20,
                                        horizontalMargin: 16,
                                        columns: const [
                                          DataColumn(
                                            label: Text(
                                              'Train no.',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Trip id',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Date',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'EHK',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Total Required',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            numeric: true,
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Actual',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            numeric: true,
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Short',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            numeric: true,
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'PSI',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            numeric: true,
                                          ),
                                        ],
                                        rows: _psiRecords.map((record) {
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(record.trainNo)),
                                              DataCell(Text(record.tripId)),
                                              DataCell(Text(DateFormat('dd-MM-yyyy').format(record.date))),
                                              DataCell(Text(record.ehkName)),
                                              DataCell(Text('64')), // Placeholder - you may need to add this field
                                              DataCell(Text('64')), // Placeholder - you may need to add this field
                                              DataCell(Text('0')), // Placeholder - calculated field
                                              DataCell(
                                                Text(
                                                  record.psiScore.toStringAsFixed(2),
                                                  style: TextStyle(
                                                    color: record.psiScore >= 90
                                                        ? Colors.green
                                                        : record.psiScore >= 70
                                                            ? Colors.orange
                                                            : Colors.red,
                                                    fontWeight: FontWeight.bold,
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
