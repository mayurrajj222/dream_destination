import 'dart:io';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:file_picker/file_picker.dart';
import '../models/psi_record_model.dart';
import '../models/train_model.dart';
import 'psi_service.dart';
import 'train_service.dart';

class ExcelImportService {
  final PSIService _psiService = PSIService();
  final TrainService _trainService = TrainService();

  /// Find or create train by train number
  Future<String?> _findOrCreateTrain(String trainNo, String trainName) async {
    try {
      // First, try to find existing train by train number
      final allTrains = await _trainService.getAllTrains();
      
      for (var train in allTrains) {
        if (train.trainNoGoing == trainNo || train.trainNoComing == trainNo) {
          return train.id;
        }
      }
      
      // Train not found, create a new one
      final newTrain = Train(
        trainNoGoing: trainNo,
        trainNameGoing: trainName,
        stationFrom: 'Unknown',
        stationTo: 'Unknown',
        totalJanitor: 0,
        departureTimeGoing: '00:00:00',
        journeyDurationGoing: '00:00:00',
        trainNoComing: trainNo,
        trainNameComing: trainName,
        departureTimeComing: '00:00:00',
        journeyDurationComing: '00:00:00',
        createdAt: DateTime.now(),
      );
      
      final result = await _trainService.createTrain(newTrain);
      
      if (result['success']) {
        return result['trainId'];
      }
      
      return null;
    } catch (e) {
      print('Error finding/creating train: $e');
      return null;
    }
  }

  /// Pick and import Excel file containing PSI data
  Future<Map<String, dynamic>> importPSIFromExcel() async {
    try {
      // Pick Excel file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // Important for web - loads file as bytes
      );

      if (result == null || result.files.single.bytes == null) {
        return {
          'success': false,
          'message': 'No file selected',
        };
      }

      // Use bytes directly (works on web and mobile)
      final bytes = result.files.single.bytes!;
      final excel = excel_pkg.Excel.decodeBytes(bytes);

      // Get the first sheet
      final sheet = excel.tables.keys.first;
      final table = excel.tables[sheet];

      if (table == null || table.rows.isEmpty) {
        return {
          'success': false,
          'message': 'Excel file is empty',
        };
      }

      print('Excel loaded: ${table.rows.length} rows found');

      List<PSIRecord> records = [];
      int successCount = 0;
      int errorCount = 0;
      List<String> errors = [];
      
      // Extract metadata first
      final metadata = _extractMetadata(table);
      
      // Find the header row (contains "Date", "Passenger-Name", etc.)
      int headerRowIndex = -1;
      for (int i = 0; i < table.rows.length; i++) {
        final row = table.rows[i];
        if (row.isEmpty) continue;
        
        final firstCell = row[0]?.value?.toString().toLowerCase() ?? '';
        if (firstCell.contains('date') && row.length > 1) {
          final secondCell = row[1]?.value?.toString().toLowerCase() ?? '';
          if (secondCell.contains('passenger')) {
            headerRowIndex = i;
            break;
          }
        }
      }
      
      if (headerRowIndex == -1) {
        print('ERROR: Could not find header row');
        print('First 10 rows:');
        for (int i = 0; i < table.rows.length && i < 10; i++) {
          final row = table.rows[i];
          print('Row $i: ${row.map((c) => c?.value?.toString() ?? "null").join(" | ")}');
        }
        return {
          'success': false,
          'message': 'Could not find data header row in Excel file',
        };
      }

      print('Header row found at index: $headerRowIndex');

      // Process data rows (skip header row)
      String currentTrainNo = metadata['trainNo'] ?? '';
      
      for (int i = headerRowIndex + 1; i < table.rows.length; i++) {
        try {
          final row = table.rows[i];
          
          // Skip empty rows
          if (row.isEmpty || row.every((cell) => cell?.value == null)) {
            continue;
          }

          final firstCell = row[0]?.value?.toString() ?? '';
          
          // Check if this is a new train section (e.g., "Train No: 05219")
          if (firstCell.contains('Train No:')) {
            currentTrainNo = firstCell.replaceAll('Train No:', '').trim();
            continue;
          }
          
          // Skip if first cell is empty or doesn't look like a date
          if (firstCell.isEmpty) continue;

          // Parse row data
          // Expected format: Date | Passenger-Name | PNR-No | ...
          final dateStr = row[0]?.value?.toString() ?? '';
          final passengerName = row.length > 1 ? (row[1]?.value?.toString() ?? '') : '';
          final pnrNo = row.length > 2 ? (row[2]?.value?.toString() ?? '') : '';
          
          // Skip if essential fields are missing
          if (dateStr.isEmpty || passengerName.isEmpty) {
            continue;
          }

          // Parse date
          final date = _parseDate(dateStr);
          
          // Get other fields (adjust indices based on your Excel structure)
          final mobileNo = row.length > 3 ? (row[3]?.value?.toString() ?? '') : '';
          final coach = row.length > 4 ? (row[4]?.value?.toString() ?? '') : '';
          final seatNo = row.length > 5 ? (row[5]?.value?.toString() ?? '') : '';
          final psiScore = row.length > 6 ? _parseDouble(row[6]?.value?.toString() ?? '100') : 100.0;

          // Create PSI record
          final record = PSIRecord(
            trainId: '', // Will be set after finding/creating train
            trainNo: currentTrainNo.isNotEmpty ? currentTrainNo : (metadata['trainNo'] ?? ''),
            trainName: metadata['trainName'] ?? 'Unknown Train',
            scheduleId: '',
            tripId: metadata['tripId'] ?? 'Unknown',
            date: date,
            passengerName: passengerName,
            pnrNo: pnrNo,
            mobileNo: mobileNo,
            coach: coach,
            seatNo: seatNo,
            psiScore: psiScore,
            tripType: 'Going',
            ehkName: metadata['ehkName'] ?? 'Unknown',
            createdAt: DateTime.now(),
          );

          records.add(record);
        } catch (e) {
          errorCount++;
          errors.add('Row ${i + 1}: ${e.toString()}');
        }
      }

      if (records.isEmpty) {
        print('ERROR: No records created');
        print('Metadata: $metadata');
        return {
          'success': false,
          'message': 'No valid data rows found in Excel file',
          'metadata': metadata,
        };
      }

      print('Created ${records.length} PSI records');
      print('Metadata: $metadata');

      // Find or create train for the records
      final trainNo = metadata['trainNo'] ?? records.first.trainNo;
      final trainName = metadata['trainName'] ?? records.first.trainName;
      
      String? trainId;
      if (trainNo.isNotEmpty) {
        trainId = await _findOrCreateTrain(trainNo, trainName);
      }

      // Save records to Firebase
      for (var record in records) {
        // Update record with trainId if found/created
        final recordToSave = trainId != null 
            ? record.copyWith(trainId: trainId)
            : record;
            
        final result = await _psiService.createPSIRecord(recordToSave);
        if (result['success']) {
          successCount++;
        } else {
          errorCount++;
          errors.add('Failed to save: ${record.passengerName}');
        }
      }

      return {
        'success': true,
        'message': 'Import completed',
        'totalRecords': records.length,
        'successCount': successCount,
        'errorCount': errorCount,
        'errors': errors,
        'metadata': metadata,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error importing Excel: ${e.toString()}',
      };
    }
  }

  /// Parse date from various formats
  DateTime _parseDate(String dateStr) {
    try {
      // Remove any extra whitespace
      dateStr = dateStr.trim();
      
      // Try DD-MM-YYYY format (22-06-2025)
      if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          
          if (day != null && month != null && year != null) {
            return DateTime(year, month, day);
          }
        }
      }
      
      // Try DD/MM/YYYY format
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          
          if (day != null && month != null && year != null) {
            return DateTime(year, month, day);
          }
        }
      }
      
      // Try parsing as DateTime
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Parse double from string
  double _parseDouble(String value) {
    try {
      return double.parse(value.replaceAll(',', '.'));
    } catch (e) {
      return 0.0;
    }
  }

  /// Extract metadata from Excel sheet
  Map<String, String> _extractMetadata(excel_pkg.Sheet table) {
    Map<String, String> metadata = {};

    // Look for metadata in the first few rows before the data table
    for (int i = 0; i < table.rows.length && i < 20; i++) {
      final row = table.rows[i];
      if (row.isEmpty) continue;

      final cellValue = row[0]?.value?.toString() ?? '';

      // Extract Train No from "Train No: XXXXX" format
      if (cellValue.contains('Train No:')) {
        final trainNo = cellValue.replaceAll('Train No:', '').trim();
        metadata['trainNo'] = trainNo;
        // Use train number as train name if not found
        if (!metadata.containsKey('trainName')) {
          metadata['trainName'] = 'Train $trainNo';
        }
      }

      // Extract EHK Name
      if (cellValue.contains('EHK Name:')) {
        metadata['ehkName'] = cellValue.replaceAll('EHK Name:', '').trim();
      }

      // Extract Trip ID
      if (cellValue.contains('Trip ID:')) {
        metadata['tripId'] = cellValue.replaceAll('Trip ID:', '').trim();
      }

      // Extract Trip Period for date range
      if (cellValue.contains('Trip Period:')) {
        metadata['tripPeriod'] = cellValue.replaceAll('Trip Period:', '').trim();
      }

      // Check for "Trainwise PSI Report" or "Passenger Feedback" headers
      if (cellValue.contains('Trainwise PSI Report') || 
          cellValue.contains('Passenger Feedback')) {
        // Next few rows might have train info
        continue;
      }
    }

    // If no metadata found, try to extract from first data row
    if (metadata.isEmpty || !metadata.containsKey('trainNo')) {
      // Look for train number in the data section
      for (int i = 0; i < table.rows.length; i++) {
        final row = table.rows[i];
        if (row.isEmpty) continue;
        
        // Check if this looks like a header row
        final firstCell = row[0]?.value?.toString() ?? '';
        if (firstCell.toLowerCase().contains('date') || 
            firstCell.toLowerCase().contains('passenger')) {
          continue;
        }
        
        // Try to find train number in the sheet
        for (var cell in row) {
          final value = cell?.value?.toString() ?? '';
          // Look for 5-digit train numbers
          if (RegExp(r'^\d{5}$').hasMatch(value)) {
            metadata['trainNo'] = value;
            metadata['trainName'] = 'Train $value';
            break;
          }
        }
        
        if (metadata.containsKey('trainNo')) break;
      }
    }

    return metadata;
  }

  /// Analyze Excel data and return statistics
  Future<Map<String, dynamic>> analyzeExcelFile(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = file.readAsBytesSync();
      final excel = excel_pkg.Excel.decodeBytes(bytes);

      final sheet = excel.tables.keys.first;
      final table = excel.tables[sheet];

      if (table == null || table.rows.isEmpty) {
        return {
          'success': false,
          'message': 'Excel file is empty',
        };
      }

      // Extract metadata
      final metadata = _extractMetadata(table);

      // Analyze PSI scores
      List<double> psiScores = [];
      int totalRecords = 0;
      Map<String, int> coachDistribution = {};
      
      for (int i = 1; i < table.rows.length; i++) {
        final row = table.rows[i];
        if (row.isEmpty || row.every((cell) => cell?.value == null)) continue;

        // Check if this is a data row (has passenger name)
        final passengerName = row[1]?.value?.toString() ?? '';
        if (passengerName.isEmpty) continue;

        totalRecords++;

        // Get PSI score
        final psiScore = _parseDouble(row[6]?.value?.toString() ?? '0');
        psiScores.add(psiScore);

        // Get coach
        final coach = row[4]?.value?.toString() ?? '';
        if (coach.isNotEmpty) {
          coachDistribution[coach] = (coachDistribution[coach] ?? 0) + 1;
        }
      }

      // Calculate statistics
      double averagePSI = 0;
      double highestPSI = 0;
      double lowestPSI = 100;
      int above90 = 0;
      int between70and90 = 0;
      int below70 = 0;

      if (psiScores.isNotEmpty) {
        averagePSI = psiScores.reduce((a, b) => a + b) / psiScores.length;
        highestPSI = psiScores.reduce((a, b) => a > b ? a : b);
        lowestPSI = psiScores.reduce((a, b) => a < b ? a : b);

        for (var score in psiScores) {
          if (score >= 90) {
            above90++;
          } else if (score >= 70) {
            between70and90++;
          } else {
            below70++;
          }
        }
      }

      return {
        'success': true,
        'metadata': metadata,
        'statistics': {
          'totalRecords': totalRecords,
          'averagePSI': averagePSI,
          'highestPSI': highestPSI,
          'lowestPSI': lowestPSI,
          'above90': above90,
          'between70and90': between70and90,
          'below70': below70,
          'coachDistribution': coachDistribution,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error analyzing Excel: ${e.toString()}',
      };
    }
  }
}
