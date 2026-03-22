import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';
import '../models/train_model.dart';
import '../services/attendance_import_service.dart';
import '../services/train_service.dart';

class TripwiseAttendanceReportScreen extends StatefulWidget {
  const TripwiseAttendanceReportScreen({super.key});

  @override
  State<TripwiseAttendanceReportScreen> createState() =>
      _TripwiseAttendanceReportScreenState();
}

class _TripwiseAttendanceReportScreenState
    extends State<TripwiseAttendanceReportScreen> {
  final _importService = AttendanceImportService();
  final _trainService = TrainService();

  DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _toDate = DateTime.now();
  List<Train> _trains = [];
  Train? _selectedTrain;

  // Trip (batch) selection
  List<Map<String, String>> _availableBatches = [];
  Map<String, String>? _selectedBatch;
  bool _isLoadingBatches = false;

  List<AttendanceRecord> _records = [];
  bool _isLoading = false;
  bool _isImporting = false;
  bool _showReport = false;

  @override
  void initState() {
    super.initState();
    _loadTrains();
  }

  Future<void> _loadTrains() async {
    final trains = await _trainService.getAllTrains();
    setState(() => _trains = trains);
    await _loadBatches();
  }

  Future<void> _loadBatches() async {
    setState(() => _isLoadingBatches = true);
    final batches = await _importService.getAvailableBatches(
      trainNo: _selectedTrain?.trainNoGoing,
    );
    setState(() {
      _availableBatches = batches;
      _selectedBatch = null;
      _isLoadingBatches = false;
    });
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => isFrom ? _fromDate = picked : _toDate = picked);
    }
  }

  Future<void> _loadRecords() async {
    setState(() { _isLoading = true; _showReport = false; });
    final records = await _importService.getRecords(
      fromDate: _fromDate,
      toDate: _toDate,
      trainNo: _selectedTrain?.trainNoGoing,
      tripId: _selectedBatch?['tripId'],
      batchId: _selectedBatch?['batchId'],
    );
    setState(() {
      _records = records;
      _isLoading = false;
      _showReport = true;
    });
  }

  Future<void> _importExcel() async {
    setState(() => _isImporting = true);
    final result = await _importService.importFromExcel();
    setState(() => _isImporting = false);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(result['success'] ? 'Import Successful' : 'Import Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result['message'] ?? ''),
            if (result['success'] == true) ...[
              const SizedBox(height: 8),
              Text('Total: ${result['totalRecords']}'),
              Text('Saved: ${result['successCount']}'),
              if ((result['errorCount'] ?? 0) > 0)
                Text('Errors: ${result['errorCount']}',
                    style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (result['success'] == true) {
                _loadBatches();
                _loadRecords();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTrip() async {
    if (_selectedBatch == null) return;
    final batchId = _selectedBatch!['batchId']!;
    final label = _tripLabel(_selectedBatch!);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text('Delete ALL attendance records for:\n$label\n\nThis cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _importService.deleteByBatch(batchId);
    await _loadBatches();
    setState(() { _showReport = false; _records = []; });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip deleted successfully'), backgroundColor: Colors.green),
      );
    }
  }

  String _tripLabel(Map<String, String> batch) {
    final tid = batch['tripId'] ?? '';
    if (tid.isNotEmpty) return 'Trip $tid';
    // fallback: show date if no trip id
    return 'Trip (${batch['sDate'] ?? ''})';
  }

  String _fmt(DateTime? dt, {bool timeOnly = false}) {
    if (dt == null) return '';
    if (timeOnly) return DateFormat('HH:mm:ss').format(dt);
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tripwise Attendance Reports'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tripwise Attendance Reports',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 16),
                _dateRow('From Date*', _fromDate, () => _pickDate(true)),
                const SizedBox(height: 12),
                _dateRow('To Date*', _toDate, () => _pickDate(false)),
                const SizedBox(height: 12),

                // Train dropdown
                Row(children: [
                  const SizedBox(width: 120, child: Text('Train No', style: TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonFormField<Train>(
                        value: _selectedTrain,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        hint: const Text('All Trains', style: TextStyle(fontSize: 14)),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<Train>(value: null, child: Text('All Trains')),
                          ..._trains.map((t) => DropdownMenuItem<Train>(
                            value: t,
                            child: Text('${t.trainNoGoing} - ${t.trainNameGoing}',
                                overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                          )),
                        ],
                        onChanged: (t) {
                          setState(() => _selectedTrain = t);
                          _loadBatches();
                        },
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),

                // Trip (batch) dropdown
                Row(children: [
                  const SizedBox(width: 120, child: Text('Select Trip', style: TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _isLoadingBatches
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Text('Loading trips...', style: TextStyle(color: Colors.grey)),
                            )
                          : DropdownButtonFormField<Map<String, String>>(
                              value: _selectedBatch,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                isDense: true,
                              ),
                              hint: const Text('All Trips', style: TextStyle(fontSize: 14)),
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem<Map<String, String>>(
                                  value: null,
                                  child: Text('All Trips'),
                                ),
                                ..._availableBatches.map((b) => DropdownMenuItem<Map<String, String>>(
                                  value: b,
                                  child: Text(_tripLabel(b),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13)),
                                )),
                              ],
                              onChanged: (b) => setState(() => _selectedBatch = b),
                            ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                // Action buttons
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _loadRecords,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Show', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isImporting ? null : _importExcel,
                      icon: _isImporting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.upload_file, size: 18),
                      label: const Text('Import Excel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _selectedBatch == null ? null : _deleteTrip,
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text('Delete Trip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Table
          if (_showReport)
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: _records.isEmpty
                    ? const Center(child: Text('No records found', style: TextStyle(color: Colors.grey)))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text('Total Records: ${_records.length}',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                                  border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
                                  columnSpacing: 12,
                                  dataRowMinHeight: 40,
                                  dataRowMaxHeight: 80,
                                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  dataTextStyle: const TextStyle(fontSize: 11),
                                  columns: const [
                                    DataColumn(label: Text('S.No')),
                                    DataColumn(label: Text('TrainNo')),
                                    DataColumn(label: Text('SDate')),
                                    DataColumn(label: Text('EmpCode')),
                                    DataColumn(label: Text('EmpName')),
                                    DataColumn(label: Text('Punch1')),
                                    DataColumn(label: Text('LatLong')),
                                    DataColumn(label: Text('Punch2')),
                                    DataColumn(label: Text('LatLong')),
                                    DataColumn(label: Text('Punch3')),
                                    DataColumn(label: Text('LatLong')),
                                    DataColumn(label: Text('Total')),
                                  ],
                                  rows: _records.asMap().entries.map((e) {
                                    final i = e.key;
                                    final r = e.value;
                                    return DataRow(cells: [
                                      DataCell(Text('${i + 1}')),
                                      DataCell(Text(r.trainNo)),
                                      DataCell(Text(_fmt(r.sDate))),
                                      DataCell(Text(r.empCode)),
                                      DataCell(Text(r.empName)),
                                      DataCell(Text(_fmt(r.punch1, timeOnly: true))),
                                      DataCell(_latLongCell(r.punch1Lat, r.punch1Long, r.punch1Location)),
                                      DataCell(Text(_fmt(r.punch2, timeOnly: true))),
                                      DataCell(_latLongCell(r.punch2Lat, r.punch2Long, r.punch2Location)),
                                      DataCell(Text(_fmt(r.punch3, timeOnly: true))),
                                      DataCell(_latLongCell(r.punch3Lat, r.punch3Long, r.punch3Location)),
                                      DataCell(Text('${r.total}')),
                                    ]);
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
    );
  }

  Widget _dateRow(String label, DateTime date, VoidCallback onTap) {
    return Row(children: [
      SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
      Expanded(
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd/MM/yyyy').format(date)),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _latLongCell(double? lat, double? lng, String? location) {
    if (lat == null && lng == null) {
      return Text(location ?? '', style: const TextStyle(fontSize: 10));
    }
    return SizedBox(
      width: 120,
      child: Text(
        'Lat: ${lat?.toStringAsFixed(4) ?? ''}\nLong: ${lng?.toStringAsFixed(4) ?? ''}',
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}
