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
      print('ExcelImport: Finding/creating train $trainNo - $trainName');
      
      // First, try to find existing train by train number
      final allTrains = await _trainService.getAllTrains();
      print('ExcelImport: Found ${allTrains.length} existing trains');
      
      for (var train in allTrains) {
        if (train.trainNoGoing == trainNo || train.trainNoComing == trainNo) {
          print('ExcelImport: Train $trainNo already exists with ID: ${train.id}');
          return train.id;
        }
      }
      
      print('ExcelImport: Train $trainNo not found, creating new one');
      
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
      print('ExcelImport: Create train result: $result');
      
      if (result['success'] || result['trainId'] != null) {
        // Return trainId even if it says not success but has trainId (means it already existed)
        return result['trainId'];
      }
      
      print('ExcelImport: Failed to create train: ${result['message']}');
      return null;
    } catch (e) {
      print('ExcelImport: Error finding/creating train: $e');
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
        // Look for "date" in first cell
        if (firstCell.contains('date')) {
          // Check if second cell contains "passenger" or "name"
          if (row.length > 1) {
            final secondCell = row[1]?.value?.toString().toLowerCase() ?? '';
            if (secondCell.contains('passenger') || secondCell.contains('name')) {
              headerRowIndex = i;
              print('ExcelImport: Header row found at index: $headerRowIndex');
              break;
            }
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
      
      print('ExcelImport: Starting data import with train no: "$currentTrainNo"');
      
      for (int i = headerRowIndex + 1; i < table.rows.length; i++) {
        try {
          final row = table.rows[i];
          
          // Skip empty rows
          if (row.isEmpty || row.every((cell) => cell?.value == null)) {
            continue;
          }

          final firstCell = row[0]?.value?.toString() ?? '';
          
          // Check if this is a new train section (e.g., "Train No: 05219")
          if (firstCell.toLowerCase().contains('train') && firstCell.toLowerCase().contains('no')) {
            final trainNoMatch = RegExp(r'(\d{5})').firstMatch(firstCell);
            if (trainNoMatch != null) {
              currentTrainNo = trainNoMatch.group(1)!;
              print('ExcelImport: Found new train section: $currentTrainNo');
              continue;
            }
          }
          
          // Skip if first cell is empty or doesn't look like a date
          if (firstCell.isEmpty) continue;

          // Parse row data
          final dateStr = row[0]?.value?.toString() ?? '';
          final passengerName = row.length > 1 ? (row[1]?.value?.toString() ?? '') : '';
          final pnrNo = row.length > 2 ? (row[2]?.value?.toString() ?? '') : '';
          
          // Skip if essential fields are missing
          if (dateStr.isEmpty || passengerName.isEmpty) {
            continue;
          }

          // Parse date
          final date = _parseDate(dateStr);
          
          // Get other fields
          final mobileNo = row.length > 3 ? (row[3]?.value?.toString() ?? '') : '';
          final coach = row.length > 4 ? (row[4]?.value?.toString() ?? '') : '';
          final seatNo = row.length > 5 ? (row[5]?.value?.toString() ?? '') : '';
          final psiScore = row.length > 6 ? _parseDouble(row[6]?.value?.toString() ?? '100') : 100.0;

          // Use current train number (from metadata or train section header)
          final trainNo = currentTrainNo.isNotEmpty ? currentTrainNo : (metadata['trainNo'] ?? '');
          
          if (trainNo.isEmpty) {
            print('ExcelImport: Warning - No train number for row $i, skipping');
            continue;
          }

          // Create PSI record
          final record = PSIRecord(
            userId: '', // Will be set by PSIService
            trainId: '', // Will be set after finding/creating train
            trainNo: trainNo,
            trainName: metadata['trainName'] ?? 'Train $trainNo',
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
            companyName: metadata['companyName'],
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
        
        if (trainId == null) {
          print('ERROR: Failed to find or create train for Train No: $trainNo');
          return {
            'success': false,
            'message': 'Failed to find or create train (Train No: $trainNo). Please create the train manually first.',
            'totalRecords': records.length,
            'successCount': 0,
            'errorCount': records.length,
          };
        }
      } else {
        print('ERROR: No train number found in Excel file');
        return {
          'success': false,
          'message': 'No train number found in Excel file. Please ensure the Excel file contains train information.',
          'totalRecords': records.length,
          'successCount': 0,
          'errorCount': records.length,
        };
      }

      print('Using Train ID: $trainId for all records');

      // Save records to Supabase
      for (var record in records) {
        try {
          // Update record with trainId (guaranteed to be non-null at this point)
          final recordToSave = record.copyWith(trainId: trainId);
          
          // Log the record being saved for debugging
          print('Saving record: ${record.passengerName}, TrainID: ${recordToSave.trainId}, TripID: ${recordToSave.tripId}');
              
          final result = await _psiService.createPSIRecord(recordToSave);
          if (result['success']) {
            successCount++;
            print('✓ Saved: ${record.passengerName}');
          } else {
            errorCount++;
            final errorMsg = 'Failed to save ${record.passengerName}: ${result['message']}';
            errors.add(errorMsg);
            print('✗ $errorMsg');
          }
        } catch (e) {
          errorCount++;
          final errorMsg = 'Exception saving ${record.passengerName}: ${e.toString()}';
          errors.add(errorMsg);
          print('✗ $errorMsg');
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
      
      print('Parsing date: "$dateStr"');
      
      // Try DD-MM-YYYY format (09-06-2025)
      if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          
          if (day != null && month != null && year != null) {
            // Validate the values
            if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year >= 2000) {
              final parsedDate = DateTime(year, month, day);
              print('Parsed date (DD-MM-YYYY): $parsedDate');
              return parsedDate;
            }
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
            // Validate the values
            if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year >= 2000) {
              final parsedDate = DateTime(year, month, day);
              print('Parsed date (DD/MM/YYYY): $parsedDate');
              return parsedDate;
            }
          }
        }
      }
      
      // Try parsing as DateTime (ISO format)
      final parsedDate = DateTime.parse(dateStr);
      print('Parsed date (ISO): $parsedDate');
      return parsedDate;
    } catch (e) {
      print('Error parsing date "$dateStr": $e, using current date');
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
      final cellValueLower = cellValue.toLowerCase();

      // Extract Company Name from "Trainwise PSI Report" column header
      if (cellValueLower.contains('trainwise') && cellValueLower.contains('psi')) {
        // Look for company name in the same cell or next row
        final lines = cellValue.split('\n');
        if (lines.length > 1) {
          for (int j = 1; j < lines.length; j++) {
            final line = lines[j].trim();
            if (line.isNotEmpty && 
                !line.toLowerCase().contains('ehk') && 
                !line.toLowerCase().contains('trip') &&
                !line.toLowerCase().contains('train') &&
                !line.toLowerCase().contains('period')) {
              metadata['companyName'] = line;
              break;
            }
          }
        }
        
        // Also check the next row
        if (!metadata.containsKey('companyName') && i + 1 < table.rows.length) {
          final nextRow = table.rows[i + 1];
          if (nextRow.isNotEmpty) {
            final nextCellValue = nextRow[0]?.value?.toString().trim() ?? '';
            if (nextCellValue.isNotEmpty && 
                !nextCellValue.contains(':') &&
                !nextCellValue.toLowerCase().contains('ehk') &&
                !nextCellValue.toLowerCase().contains('trip') &&
                !nextCellValue.toLowerCase().contains('train')) {
              metadata['companyName'] = nextCellValue;
            }
          }
        }
      }

      // Extract Train No - flexible matching
      if (cellValueLower.contains('train') && cellValueLower.contains('no')) {
        // Try multiple patterns
        final patterns = [
          RegExp(r'train\s*no:?\s*(\d{5})', caseSensitive: false),
          RegExp(r'train\s*no\.?\s*(\d{5})', caseSensitive: false),
          RegExp(r'train\s*number:?\s*(\d{5})', caseSensitive: false),
        ];
        
        for (var pattern in patterns) {
          final match = pattern.firstMatch(cellValue);
          if (match != null) {
            metadata['trainNo'] = match.group(1)!;
            break;
          }
        }
        
        // Try to extract train name
        final namePatterns = [
          RegExp(r'train\s*no:?\s*\d{5}\s*-\s*([^\n]+)', caseSensitive: false),
          RegExp(r'train\s*no\.?\s*\d{5}\s*-\s*([^\n]+)', caseSensitive: false),
        ];
        
        for (var pattern in namePatterns) {
          final match = pattern.firstMatch(cellValue);
          if (match != null) {
            metadata['trainName'] = match.group(1)!.trim();
            break;
          }
        }
      }

      // Extract EHK Name - flexible matching
      if (cellValueLower.contains('ehk') && cellValueLower.contains('name')) {
        final patterns = [
          RegExp(r'ehk\s*name:?\s*([^\n\r]+)', caseSensitive: false),
          RegExp(r'ehk\s*name\.?\s*([^\n\r]+)', caseSensitive: false),
        ];
        
        for (var pattern in patterns) {
          final match = pattern.firstMatch(cellValue);
          if (match != null) {
            var ehkName = match.group(1)!.trim();
            // Remove any trailing text that looks like it's from another section
            ehkName = ehkName.split(RegExp(r'(trip\s*period|trip\s*id|train\s*no|obhs|trainwise)', caseSensitive: false)).first.trim();
            metadata['ehkName'] = ehkName;
            break;
          }
        }
      }

      // Extract Trip ID - flexible matching
      if (cellValueLower.contains('trip') && cellValueLower.contains('id')) {
        final patterns = [
          RegExp(r'trip\s*id:?\s*([A-Za-z0-9\-]+)', caseSensitive: false),
          RegExp(r'trip\s*id\.?\s*([A-Za-z0-9\-]+)', caseSensitive: false),
        ];
        
        for (var pattern in patterns) {
          final match = pattern.firstMatch(cellValue);
          if (match != null) {
            var tripId = match.group(1)!.trim();
            // Remove any trailing text
            tripId = tripId.split(RegExp(r'(trip\s*period|ehk\s*name|train\s*no|obhs|trainwise)', caseSensitive: false)).first.trim();
            // Extract just the ID part
            final idMatch = RegExp(r'^([A-Za-z0-9\-]+)').firstMatch(tripId);
            if (idMatch != null) {
              metadata['tripId'] = idMatch.group(1)!;
            } else {
              metadata['tripId'] = tripId;
            }
            break;
          }
        }
      }

      // Extract Trip Period
      if (cellValueLower.contains('trip') && cellValueLower.contains('period')) {
        final match = RegExp(r'trip\s*period:?\s*([^\n]+)', caseSensitive: false).firstMatch(cellValue);
        if (match != null) {
          metadata['tripPeriod'] = match.group(1)!.trim();
        }
      }
    }

    // If train name still not found, use train number
    if (!metadata.containsKey('trainName') && metadata.containsKey('trainNo')) {
      metadata['trainName'] = 'Train ${metadata['trainNo']}';
    }

    print('ExcelImport: Extracted metadata: $metadata');
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
