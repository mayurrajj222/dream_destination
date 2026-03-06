import 'dart:io';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:file_picker/file_picker.dart';
import '../models/psi_record_model.dart';
import '../models/train_model.dart';
import 'psi_service.dart';
import 'train_service.dart';

class PSISummaryImportService {
  final PSIService _psiService = PSIService();
  final TrainService _trainService = TrainService();

  /// Find or create train by train number
  Future<String?> _findOrCreateTrain(String trainNo, String trainName) async {
    try {
      print('SummaryImport: Finding/creating train $trainNo - $trainName');
      
      final allTrains = await _trainService.getAllTrains();
      print('SummaryImport: Found ${allTrains.length} existing trains');
      
      for (var train in allTrains) {
        if (train.trainNoGoing == trainNo || train.trainNoComing == trainNo) {
          print('SummaryImport: Train $trainNo already exists with ID: ${train.id}');
          return train.id;
        }
      }
      
      print('SummaryImport: Train $trainNo not found, creating new one');
      
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
      print('SummaryImport: Create train result: $result');
      
      if (result['success'] || result['trainId'] != null) {
        return result['trainId'];
      }
      
      print('SummaryImport: Failed to create train: ${result['message']}');
      return null;
    } catch (e) {
      print('SummaryImport: Error finding/creating train: $e');
      return null;
    }
  }

  /// Import PSI Summary Excel file
  Future<Map<String, dynamic>> importPSISummaryFromExcel() async {
    try {
      // Pick Excel file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.single.bytes == null) {
        return {
          'success': false,
          'message': 'No file selected',
        };
      }

      final bytes = result.files.single.bytes!;
      final excel = excel_pkg.Excel.decodeBytes(bytes);

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
      
      // Find the header row (contains "Train no.", "Trip id", "Date", "EHK")
      int headerRowIndex = -1;
      for (int i = 0; i < table.rows.length; i++) {
        final row = table.rows[i];
        if (row.isEmpty) continue;
        
        final firstCell = row[0]?.value?.toString().toLowerCase() ?? '';
        if (firstCell.contains('train') && firstCell.contains('no')) {
          headerRowIndex = i;
          print('Header row found at index: $headerRowIndex');
          break;
        }
      }
      
      if (headerRowIndex == -1) {
        return {
          'success': false,
          'message': 'Could not find header row with "Train no." in Excel file',
        };
      }

      // Process data rows (skip header row)
      for (int i = headerRowIndex + 1; i < table.rows.length; i++) {
        try {
          final row = table.rows[i];
          
          // Skip empty rows
          if (row.isEmpty || row.every((cell) => cell?.value == null)) {
            continue;
          }

          // Parse row data
          // Expected format: Train no. | Trip id | Date | EHK | Total Required | Actual | Short | PSI
          final trainNo = row.length > 0 ? (row[0]?.value?.toString() ?? '') : '';
          final tripId = row.length > 1 ? (row[1]?.value?.toString() ?? '') : '';
          final dateStr = row.length > 2 ? (row[2]?.value?.toString() ?? '') : '';
          final ehkName = row.length > 3 ? (row[3]?.value?.toString() ?? '') : '';
          final totalRequired = row.length > 4 ? (row[4]?.value?.toString() ?? '64') : '64';
          final actual = row.length > 5 ? (row[5]?.value?.toString() ?? '64') : '64';
          final short = row.length > 6 ? (row[6]?.value?.toString() ?? '0') : '0';
          final psiScore = row.length > 7 ? _parseDouble(row[7]?.value?.toString() ?? '100') : 100.0;
          
          // Skip if essential fields are missing
          if (trainNo.isEmpty || tripId.isEmpty || dateStr.isEmpty) {
            continue;
          }

          // Parse date
          final date = _parseDate(dateStr);
          
          // Create PSI record (one record per trip summary)
          final record = PSIRecord(
            userId: '', // Will be set by PSIService
            trainId: '', // Will be set after finding/creating train
            trainNo: trainNo,
            trainName: 'Train $trainNo',
            scheduleId: '',
            tripId: tripId,
            date: date,
            passengerName: 'Summary Record', // Placeholder for summary
            pnrNo: 'SUMMARY-$tripId',
            mobileNo: '',
            coach: '',
            seatNo: '',
            psiScore: psiScore,
            tripType: 'Going',
            ehkName: ehkName,
            companyName: null,
            createdAt: DateTime.now(),
          );

          records.add(record);
        } catch (e) {
          errorCount++;
          errors.add('Row ${i + 1}: ${e.toString()}');
          print('Error parsing row ${i + 1}: $e');
        }
      }

      if (records.isEmpty) {
        return {
          'success': false,
          'message': 'No valid data rows found in Excel file',
        };
      }

      print('Created ${records.length} PSI summary records');

      // Group records by train number
      Map<String, List<PSIRecord>> recordsByTrain = {};
      for (var record in records) {
        if (!recordsByTrain.containsKey(record.trainNo)) {
          recordsByTrain[record.trainNo] = [];
        }
        recordsByTrain[record.trainNo]!.add(record);
      }

      // Process each train's records
      for (var trainNo in recordsByTrain.keys) {
        final trainRecords = recordsByTrain[trainNo]!;
        
        // Find or create train
        String? trainId = await _findOrCreateTrain(trainNo, 'Train $trainNo');
        
        if (trainId == null) {
          errorCount += trainRecords.length;
          errors.add('Failed to create train $trainNo - skipped ${trainRecords.length} records');
          continue;
        }

        // Save records for this train
        for (var record in trainRecords) {
          final recordToSave = record.copyWith(trainId: trainId);
          
          print('Saving summary record: Train $trainNo, Trip ${record.tripId}, PSI ${record.psiScore}');
          
          final result = await _psiService.createPSIRecord(recordToSave);
          if (result['success']) {
            successCount++;
            print('✓ Saved: Train $trainNo, Trip ${record.tripId}');
          } else {
            errorCount++;
            final errorMsg = 'Failed to save Train $trainNo, Trip ${record.tripId}: ${result['message']}';
            errors.add(errorMsg);
            print('✗ $errorMsg');
          }
        }
      }

      return {
        'success': true,
        'message': 'Import completed',
        'totalRecords': records.length,
        'successCount': successCount,
        'errorCount': errorCount,
        'errors': errors,
      };
    } catch (e) {
      print('SummaryImport: Error importing Excel: $e');
      return {
        'success': false,
        'message': 'Error importing Excel: ${e.toString()}',
      };
    }
  }

  /// Parse date from various formats
  DateTime _parseDate(String dateStr) {
    try {
      dateStr = dateStr.trim();
      
      // Try DD-MM-YYYY format
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
      print('Error parsing date "$dateStr": $e');
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
}
