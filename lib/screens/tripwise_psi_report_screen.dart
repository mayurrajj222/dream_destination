import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/psi_record_model.dart';
import '../models/train_model.dart';
import '../services/psi_service.dart';
import '../services/train_service.dart';
import '../services/pdf_generator_service.dart';
import '../services/excel_import_service.dart';
import 'psi_form_screen.dart';

class TripwisePSIReportScreen extends StatefulWidget {
  const TripwisePSIReportScreen({super.key});

  @override
  State<TripwisePSIReportScreen> createState() => _TripwisePSIReportScreenState();
}

class _TripwisePSIReportScreenState extends State<TripwisePSIReportScreen> {
  final _psiService = PSIService();
  final _excelImportService = ExcelImportService();
  final _trainService = TrainService();
  
  List<PSIRecord> _psiRecords = [];
  List<Train> _trains = [];
  List<String> _availableTrips = ['--Please Select Trips--'];
  String? _selectedTrainId;
  String _selectedTrip = '--Please Select Trips--';
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  bool _isLoading = false;
  bool _showReport = false;
  bool _isLoadingTrains = true;

  @override
  void initState() {
    super.initState();
    _loadTrains();
  }

  Future<void> _loadTrains() async {
    try {
      print('Loading trains...');
      setState(() => _isLoadingTrains = true);
      
      final trains = await _trainService.getAllTrains();
      print('Loaded ${trains.length} trains');
      
      if (trains.isEmpty) {
        print('WARNING: No trains found in database');
      } else {
        for (var train in trains) {
          print('Train: ${train.trainNoGoing} - ${train.trainNameGoing}');
        }
      }
      
      setState(() {
        _trains = trains;
        _isLoadingTrains = false;
        
        // Reset selected train if it no longer exists in the list
        if (_selectedTrainId != null && !trains.any((t) => t.id == _selectedTrainId)) {
          _selectedTrainId = null;
          _availableTrips = ['--Please Select Trips--'];
          _selectedTrip = '--Please Select Trips--';
        }
      });
    } catch (e) {
      print('Error loading trains: $e');
      setState(() => _isLoadingTrains = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trains: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadTripsForTrain() async {
    if (_selectedTrainId == null) return;

    setState(() => _isLoading = true);
    
    try {
      // Get the selected train
      final selectedTrain = _trains.firstWhere((t) => t.id == _selectedTrainId);
      
      // Fetch all PSI records
      final records = await _psiService.getPSIRecordsByDateRange(
        DateTime(2020, 1, 1),
        DateTime.now().add(const Duration(days: 365)),
      );
      
      // Filter by selected train number (check both going and coming)
      final trainRecords = records.where((r) => 
        r.trainNo == selectedTrain.trainNoGoing || 
        r.trainNo == selectedTrain.trainNoComing
      ).toList();
      
      // Group by trip ID and get the first date for each trip
      Map<String, PSIRecord> tripMap = {};
      for (var record in trainRecords) {
        if (!tripMap.containsKey(record.tripId)) {
          tripMap[record.tripId] = record;
        }
      }
      
      // Create trip display strings: "TripID | Date | TrainNo"
      List<String> tripDisplays = tripMap.entries.map((entry) {
        final record = entry.value;
        final dateStr = DateFormat('yyyy-MM-dd').format(record.date);
        return '${record.tripId} | $dateStr | ${record.trainNo}';
      }).toList();
      
      tripDisplays.sort();
      
      setState(() {
        _availableTrips = ['--Please Select Trips--', ...tripDisplays];
        _selectedTrip = '--Please Select Trips--';
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading trips: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  Future<void> _importExcel() async {
    setState(() => _isLoading = true);

    final result = await _excelImportService.importPSIFromExcel();

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        // Reload trains to include newly created train
        await _loadTrains();
        
        // Auto-select the train from imported data
        if (result['metadata'] != null && result['metadata']['trainNo'] != null) {
          final importedTrainNo = result['metadata']['trainNo'];
          for (var train in _trains) {
            if (train.trainNoGoing == importedTrainNo || train.trainNoComing == importedTrainNo) {
              setState(() {
                _selectedTrainId = train.id;
              });
              await _loadTripsForTrain();
              break;
            }
          }
        }
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Successful'),
            content: Column(
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
                const SizedBox(height: 12),
                const Text(
                  'Train has been auto-selected. Click Show to view data.',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadTrains();
                  if (_selectedTrainId != null) {
                    _loadTripsForTrain();
                  }
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

  Future<void> _loadPSIData() async {
    if (_selectedTrainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a train'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _showReport = false;
    });

    try {
      List<PSIRecord> records;
      
      // Get the selected train to get its train number
      final selectedTrain = _trains.firstWhere((t) => t.id == _selectedTrainId);
      
      if (_selectedTrip == '--Please Select Trips--') {
        // Load all PSI records for the selected train and date range
        // Try by trainId first, then fall back to trainNo
        records = await _psiService.getPSIRecordsByTrainAndDateRange(
          _selectedTrainId!,
          _fromDate,
          _toDate,
        );
        
        // If no records found by trainId, try by trainNo
        if (records.isEmpty) {
          final allRecords = await _psiService.getPSIRecordsByDateRange(
            _fromDate,
            _toDate,
          );
          records = allRecords.where((r) => 
            r.trainNo == selectedTrain.trainNoGoing || 
            r.trainNo == selectedTrain.trainNoComing
          ).toList();
        }
      } else {
        // Extract trip ID from display string "TripID | Date | TrainNo"
        final tripId = _selectedTrip.split('|')[0].trim();
        
        // Load PSI records for selected trip
        final allRecords = await _psiService.getPSIRecordsByDateRange(
          _fromDate,
          _toDate,
        );
        
        records = allRecords.where((r) => 
          r.tripId == tripId &&
          (r.trainNo == selectedTrain.trainNoGoing || 
           r.trainNo == selectedTrain.trainNoComing)
        ).toList();
      }

      setState(() {
        _psiRecords = records;
        _isLoading = false;
        _showReport = true;
      });

      if (records.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No PSI records found for the selected criteria'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showReport = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading PSI data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getReportInfo() {
    if (_psiRecords.isEmpty) return '';
    
    final firstRecord = _psiRecords.first;
    return 'EHK Name: ${firstRecord.ehkName}\n'
           'Trip ID: ${firstRecord.tripId}\n'
           'Train No: ${firstRecord.trainNo} - ${firstRecord.trainName}';
  }

  Future<void> _exportToExcel() async {
    try {
      var excelFile = excel_pkg.Excel.createExcel();
      excel_pkg.Sheet sheetObject = excelFile['PSI Report'];

      // Add headers
      sheetObject.appendRow([
        excel_pkg.TextCellValue('Date'),
        excel_pkg.TextCellValue('Passenger Name'),
        excel_pkg.TextCellValue('PNR No'),
        excel_pkg.TextCellValue('Mobile No'),
        excel_pkg.TextCellValue('Coach'),
        excel_pkg.TextCellValue('Seat No'),
        excel_pkg.TextCellValue('PSI'),
        excel_pkg.TextCellValue('Print'),
      ]);

      // Add data rows
      for (var record in _psiRecords) {
        sheetObject.appendRow([
          excel_pkg.TextCellValue(DateFormat('dd/MM/yyyy').format(record.date)),
          excel_pkg.TextCellValue(record.passengerName),
          excel_pkg.TextCellValue(record.pnrNo),
          excel_pkg.TextCellValue(record.mobileNo),
          excel_pkg.TextCellValue(record.coach),
          excel_pkg.TextCellValue(record.seatNo),
          excel_pkg.TextCellValue(record.psiScore.toStringAsFixed(2)),
          excel_pkg.TextCellValue('Print'),
        ]);
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/tripwise_psi_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      
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
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tripwise PSI Reports',
          style: TextStyle(fontSize: isMobile ? 16 : 20),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: Column(
          children: [
            // Filter Section
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(isMobile ? 12 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tripwise PSI Reports',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 20),

                  // From Date
                  Row(
                    children: [
                      SizedBox(
                        width: isMobile ? 80 : 120,
                        child: Text(
                          'From Date*',
                          style: TextStyle(fontSize: isMobile ? 12 : 14),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 8 : 12,
                              vertical: isMobile ? 8 : 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(_fromDate),
                                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                                ),
                                Icon(Icons.calendar_today, size: isMobile ? 16 : 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 12 : 16),

                  // To Date
                  Row(
                    children: [
                      SizedBox(
                        width: isMobile ? 80 : 120,
                        child: Text(
                          'To Date*',
                          style: TextStyle(fontSize: isMobile ? 12 : 14),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 8 : 12,
                              vertical: isMobile ? 8 : 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(_toDate),
                                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                                ),
                                Icon(Icons.calendar_today, size: isMobile ? 16 : 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 12 : 16),

                  // Train Selection
                  Row(
                    children: [
                      SizedBox(
                        width: isMobile ? 80 : 120,
                        child: Text(
                          'Train',
                          style: TextStyle(fontSize: isMobile ? 12 : 14),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: _isLoadingTrains
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: isMobile ? 14 : 16,
                                        height: isMobile ? 14 : 16,
                                        child: const CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      SizedBox(width: isMobile ? 8 : 12),
                                      Text(
                                        'Loading trains...',
                                        style: TextStyle(fontSize: isMobile ? 12 : 14),
                                      ),
                                    ],
                                  ),
                                )
                              : _trains.isEmpty
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
                                      child: Text(
                                        'No trains available. Import Excel to create trains.',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: isMobile ? 11 : 14,
                                        ),
                                      ),
                                    )
                                  : DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _trains.any((t) => t.id == _selectedTrainId) 
                                            ? _selectedTrainId 
                                            : null,
                                        isExpanded: true,
                                        hint: Text(
                                          'Select Train',
                                          style: TextStyle(fontSize: isMobile ? 12 : 14),
                                        ),
                                        style: TextStyle(
                                          fontSize: isMobile ? 12 : 14,
                                          color: Colors.black,
                                        ),
                                        items: _trains.map((train) {
                                          return DropdownMenuItem<String>(
                                            value: train.id,
                                            child: Text('${train.trainNoGoing} - ${train.trainNameGoing}'),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedTrainId = value;
                                            _showReport = false;
                                          });
                                          if (value != null) {
                                            _loadTripsForTrain();
                                          }
                                        },
                                      ),
                                    ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 4 : 8),
                      IconButton(
                        icon: Icon(Icons.refresh, size: isMobile ? 18 : 20),
                        tooltip: 'Refresh trains',
                        onPressed: _isLoadingTrains ? null : _loadTrains,
                        color: Colors.blue,
                        padding: EdgeInsets.all(isMobile ? 4 : 8),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 12 : 16),

                  // Trip Selection
                  Row(
                    children: [
                      SizedBox(
                        width: isMobile ? 80 : 120,
                        child: Text(
                          'Select Trips',
                          style: TextStyle(fontSize: isMobile ? 12 : 14),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTrip,
                              isExpanded: true,
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 14,
                                color: Colors.black,
                              ),
                              items: _availableTrips.map((String trip) {
                                return DropdownMenuItem<String>(
                                  value: trip,
                                  child: Text(trip),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedTrip = newValue;
                                    _showReport = false;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 12 : 20),

                  // Action Buttons
                  Wrap(
                    spacing: isMobile ? 8 : 12,
                    runSpacing: isMobile ? 8 : 0,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _loadPSIData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 32,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        child: Text(
                          'Show',
                          style: TextStyle(fontSize: isMobile ? 13 : 14),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _importExcel,
                        icon: Icon(Icons.upload_file, size: isMobile ? 16 : 18),
                        label: Text(
                          'Import Excel',
                          style: TextStyle(fontSize: isMobile ? 13 : 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 24,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Report Content (only show after clicking Show button)
            if (_showReport) ...[
              // Action Buttons
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 16,
                  vertical: isMobile ? 6 : 8,
                ),
                child: Wrap(
                  spacing: isMobile ? 4 : 8,
                  runSpacing: isMobile ? 4 : 0,
                  alignment: WrapAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _exportToExcel,
                      icon: Icon(Icons.download, size: isMobile ? 16 : 18),
                      label: Text(
                        'Export to Excel',
                        style: TextStyle(fontSize: isMobile ? 12 : 14),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 12,
                          vertical: isMobile ? 6 : 8,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_psiRecords.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No records to print'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        // Print all records with serial numbers starting from 0002
                        for (int i = 0; i < _psiRecords.length; i++) {
                          await PDFGeneratorService.generateFeedbackFormPDF(
                            _psiRecords[i],
                            serialNumber: i + 2,
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 12,
                          vertical: isMobile ? 6 : 8,
                        ),
                      ),
                      child: Text(
                        'All-Print',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Report Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? 8 : 16),
                        child: Container(
                          padding: EdgeInsets.all(isMobile ? 12 : 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Report Header
                              Center(
                                child: Text(
                                  'Passenger Feedback',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: isMobile ? 12 : 16),
                              Text(
                                'Trainwise PSI Report',
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: isMobile ? 2 : 4),
                              Text(
                                'PRABHAKAR ENTERPRISE',
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: isMobile ? 2 : 4),
                              Text(
                                'OBHS Activity & Linen Distribution in AC / NON- AC Coaches',
                                style: TextStyle(fontSize: isMobile ? 11 : 13),
                              ),
                              Text(
                                'in primary based Train at Muzaffarpur Division',
                                style: TextStyle(fontSize: isMobile ? 11 : 13),
                              ),
                              SizedBox(height: isMobile ? 6 : 8),
                              if (_psiRecords.isNotEmpty) ...[
                                Text(
                                  _getReportInfo(),
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              SizedBox(height: isMobile ? 12 : 20),

                              // Data Table
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: isMobile ? screenWidth - 40 : screenWidth - 64,
                                  ),
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      Colors.grey.shade200,
                                    ),
                                    border: TableBorder.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    columnSpacing: isMobile ? 8 : 16,
                                    dataRowMinHeight: isMobile ? 36 : 48,
                                    dataRowMaxHeight: isMobile ? 48 : 64,
                                    headingRowHeight: isMobile ? 40 : 56,
                                    columns: [
                                      DataColumn(
                                        label: Text(
                                          'Date',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 11 : 14,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Passenger-Name',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 11 : 14,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'PNR-No',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 11 : 14,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Mobile-No',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 11 : 14,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Coach',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 11 : 14,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Seat-No',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 11 : 14,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'PSI',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 11 : 14,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Print',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 11 : 14,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Actions',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 11 : 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: _psiRecords.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final record = entry.value;
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(
                                            DateFormat('dd/MM/yyyy').format(record.date),
                                            style: TextStyle(fontSize: isMobile ? 11 : 14),
                                          )),
                                          DataCell(Text(
                                            record.passengerName,
                                            style: TextStyle(fontSize: isMobile ? 11 : 14),
                                          )),
                                          DataCell(Text(
                                            record.pnrNo,
                                            style: TextStyle(fontSize: isMobile ? 11 : 14),
                                          )),
                                          DataCell(Text(
                                            record.mobileNo,
                                            style: TextStyle(fontSize: isMobile ? 11 : 14),
                                          )),
                                          DataCell(Text(
                                            record.coach,
                                            style: TextStyle(fontSize: isMobile ? 11 : 14),
                                          )),
                                          DataCell(Text(
                                            record.seatNo,
                                            style: TextStyle(fontSize: isMobile ? 11 : 14),
                                          )),
                                          DataCell(Text(
                                            record.psiScore.toStringAsFixed(2),
                                            style: TextStyle(fontSize: isMobile ? 11 : 14),
                                          )),
                                          DataCell(
                                            TextButton(
                                              onPressed: () async {
                                                await PDFGeneratorService.generateFeedbackFormPDF(
                                                  record,
                                                  serialNumber: index + 2, // Start from 0002
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: isMobile ? 4 : 8,
                                                  vertical: isMobile ? 2 : 4,
                                                ),
                                              ),
                                              child: Text(
                                                'Print',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: isMobile ? 11 : 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    size: isMobile ? 18 : 20,
                                                  ),
                                                  color: Colors.blue,
                                                  padding: EdgeInsets.all(isMobile ? 4 : 8),
                                                  constraints: const BoxConstraints(),
                                                  onPressed: () async {
                                                    final result = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => PSIFormScreen(record: record),
                                                      ),
                                                    );
                                                    if (result == true) {
                                                      _loadPSIData();
                                                    }
                                                  },
                                                ),
                                                SizedBox(width: isMobile ? 2 : 4),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    size: isMobile ? 18 : 20,
                                                  ),
                                                  color: Colors.red,
                                                  padding: EdgeInsets.all(isMobile ? 4 : 8),
                                                  constraints: const BoxConstraints(),
                                                  onPressed: () async {
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: Text(
                                                          'Delete PSI Record',
                                                          style: TextStyle(fontSize: isMobile ? 16 : 18),
                                                        ),
                                                        content: Text(
                                                          'Are you sure you want to delete this PSI record?',
                                                          style: TextStyle(fontSize: isMobile ? 13 : 14),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context, false),
                                                            child: const Text('Cancel'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context, true),
                                                            child: const Text(
                                                              'Delete',
                                                              style: TextStyle(color: Colors.red),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );

                                                    if (confirm == true && record.id != null) {
                                                      final result = await _psiService.deletePSIRecord(record.id!);
                                                      if (mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text(result['message']),
                                                            backgroundColor: result['success'] 
                                                                ? Colors.green 
                                                                : Colors.red,
                                                          ),
                                                        );
                                                        if (result['success']) {
                                                          _loadPSIData();
                                                        }
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
