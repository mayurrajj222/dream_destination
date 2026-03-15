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

      // Generate unique import batch ID for this import session
      final importBatchId = 'batch_${DateTime.now().millisecondsSinceEpoch}';
      print('ExcelImport: Generated import batch ID: $importBatchId');

      List<PSIRecord> records = [];
      int successCount = 0;
      int errorCount = 0;
      List<String> errors = [];
      
      // Extract metadata first
      final metadata = _extractMetadata(table);
      
      // Find the header row (contains "Date", "Passenger-Name", etc.)
      // Be very flexible - look for any row that looks like a header
      int headerRowIndex = -1;
      for (int i = 0; i < table.rows.length && i < 30; i++) {
        final row = table.rows[i];
        if (row.isEmpty) continue;
        
        // Check multiple cells for header indicators
        bool hasDateHeader = false;
        bool hasPassengerHeader = false;
        
        for (int j = 0; j < row.length && j < 10; j++) {
          final cellValue = row[j]?.value?.toString().toLowerCase() ?? '';
          if (cellValue.contains('date')) hasDateHeader = true;
          if (cellValue.contains('passenger') || cellValue.contains('name')) hasPassengerHeader = true;
        }
        
        if (hasDateHeader && hasPassengerHeader) {
          headerRowIndex = i;
          print('ExcelImport: Header row found at index: $headerRowIndex');
          break;
        }
      }
      
      if (headerRowIndex == -1) {
        // If no header found, assume data starts at row 0 or after metadata
        // Try to find first row with date-like data
        print('WARNING: No header row found, attempting to find data start');
        for (int i = 0; i < table.rows.length && i < 30; i++) {
          final row = table.rows[i];
          if (row.isEmpty) continue;
          
          final firstCell = row[0]?.value?.toString() ?? '';
          // Check if first cell looks like a date
          if (firstCell.contains('/') || firstCell.contains('-')) {
            // Try to parse as date
            try {
              _parseDate(firstCell);
              headerRowIndex = i - 1; // Assume previous row was header
              print('ExcelImport: Data appears to start at row $i, using ${i-1} as header');
              break;
            } catch (e) {
              // Not a date, continue
            }
          }
        }
      }
      
      if (headerRowIndex == -1) {
        print('ERROR: Could not find header or data start row');
        print('First 15 rows:');
        for (int i = 0; i < table.rows.length && i < 15; i++) {
          final row = table.rows[i];
          print('Row $i: ${row.map((c) => c?.value?.toString() ?? "null").join(" | ")}');
        }
        // Don't fail - try to import starting from row 5 (common metadata size)
        headerRowIndex = 4;
        print('ExcelImport: Defaulting to row 5 as data start');
      }

      print('Header row found at index: $headerRowIndex');

      // Process data rows (skip header row)
      String currentTrainNo = metadata['trainNo'] ?? '';
      String currentTripType = 'Going'; // first section is always Going
      bool firstTrainSectionSeen = false;
      // If metadata already has a train number, the first section is already known
      if (currentTrainNo.isNotEmpty) firstTrainSectionSeen = true;
      
      print('ExcelImport: Starting data import with train no: "$currentTrainNo"');
      
      for (int i = headerRowIndex + 1; i < table.rows.length; i++) {
        try {
          final row = table.rows[i];
          
          // Skip completely empty rows
          if (row.isEmpty || row.every((cell) => cell?.value == null || cell?.value.toString().trim().isEmpty == true)) {
            continue;
          }

          final firstCell = row[0]?.value?.toString().trim() ?? '';

          // Skip summary/total rows
          if (firstCell.toLowerCase().contains('total') ||
              firstCell.toLowerCase().contains('feedback') ||
              firstCell.toLowerCase().contains('attended') ||
              firstCell.toLowerCase().contains('not attended')) {
            print('ExcelImport: Skipping summary row at $i: $firstCell');
            continue;
          }
          
          // Check if this is a new train section (e.g., "Train No: 05219")
          if (firstCell.toLowerCase().contains('train') && firstCell.toLowerCase().contains('no')) {
            final trainNoMatch = RegExp(r'(\d{5})').firstMatch(firstCell);
            if (trainNoMatch != null) {
              final newTrainNo = trainNoMatch.group(1)!;
              if (!firstTrainSectionSeen) {
                // First train section = Going
                currentTrainNo = newTrainNo;
                currentTripType = 'Going';
                firstTrainSectionSeen = true;
              } else {
                // Subsequent train sections = Coming
                currentTrainNo = newTrainNo;
                currentTripType = 'Coming';
              }
              print('ExcelImport: Found new train section: $currentTrainNo, tripType: $currentTripType');
              continue;
            }
          }
          
          // Parse row data - be very flexible
          final dateStr = row.length > 0 ? (row[0]?.value?.toString().trim() ?? '') : '';
          final passengerName = row.length > 1 ? (row[1]?.value?.toString().trim() ?? '') : '';
          final pnrNo = row.length > 2 ? (row[2]?.value?.toString().trim() ?? '') : '';
          final mobileNo = row.length > 3 ? (row[3]?.value?.toString().trim() ?? '') : '';
          final coach = row.length > 4 ? (row[4]?.value?.toString().trim() ?? '') : '';
          final seatNo = row.length > 5 ? (row[5]?.value?.toString().trim() ?? '') : '';
          final psiScore = row.length > 6 ? _parseDouble(row[6]?.value?.toString() ?? '100') : 100.0;
          
          // CRITICAL: Don't skip rows with missing data - import them anyway!
          // Only skip if BOTH date AND passenger name are empty
          if (dateStr.isEmpty && passengerName.isEmpty) {
            continue;
          }
          
          // If date is empty but passenger name exists, use current date
          DateTime date;
          if (dateStr.isEmpty) {
            print('ExcelImport: Row $i has no date, using current date');
            date = DateTime.now();
          } else {
            try {
              date = _parseDate(dateStr);
            } catch (e) {
              print('ExcelImport: Row $i date parse failed, using current date. Error: $e');
              date = DateTime.now();
            }
          }
          
          // If passenger name is empty, use placeholder
          final finalPassengerName = passengerName.isEmpty ? 'Passenger-${i}' : passengerName;

          // Use current train number (from metadata or train section header)
          String trainNo = currentTrainNo.isNotEmpty ? currentTrainNo : (metadata['trainNo'] ?? '');
          
          // If still no train number, try to extract from any cell in the row
          if (trainNo.isEmpty) {
            for (var cell in row) {
              final cellValue = cell?.value?.toString() ?? '';
              final trainMatch = RegExp(r'(\d{5})').firstMatch(cellValue);
              if (trainMatch != null) {
                trainNo = trainMatch.group(1)!;
                print('ExcelImport: Found train number in row $i: $trainNo');
                break;
              }
            }
          }
          
          // Last resort: use a default train number
          if (trainNo.isEmpty) {
            trainNo = '00000';
            print('ExcelImport: Row $i has no train number, using default: $trainNo');
          }

          // Create PSI record - ALWAYS create it, even with missing data
          final record = PSIRecord(
            userId: '', // Will be set by PSIService
            trainId: '', // Will be set after finding/creating train
            trainNo: trainNo,
            trainName: metadata['trainName'] ?? 'Train $trainNo',
            scheduleId: '',
            tripId: metadata['tripId'] ?? 'Unknown',
            date: date,
            passengerName: finalPassengerName,
            pnrNo: pnrNo,
            mobileNo: mobileNo,
            coach: coach,
            seatNo: seatNo,
            psiScore: psiScore,
            tripType: currentTripType,
            ehkName: metadata['ehkName'] ?? 'Unknown',
            companyName: metadata['companyName'],
            importBatchId: importBatchId, // Set the import batch ID
            createdAt: DateTime.now(),
          );

          records.add(record);
          print('ExcelImport: Row $i imported - Passenger: $finalPassengerName, Train: $trainNo, Date: $date');
        } catch (e) {
          // Don't fail the entire import - just log the error and continue
          errorCount++;
          final errorMsg = 'Row ${i + 1}: ${e.toString()}';
          errors.add(errorMsg);
          print('ExcelImport: ERROR on row $i: $e');
          print('ExcelImport: Continuing with next row...');
        }
      }

      if (records.isEmpty) {
        print('WARNING: No records created from Excel');
        print('Metadata: $metadata');
        print('This might be due to unexpected Excel format');
        // Don't fail completely - return partial success
        return {
          'success': false,
          'message': 'No valid data rows found in Excel file. Please check the Excel format.',
          'metadata': metadata,
          'totalRecords': 0,
          'successCount': 0,
          'errorCount': errorCount,
          'errors': errors,
        };
      }

      print('Created ${records.length} PSI records from Excel');
      print('Metadata: $metadata');

      // Find or create train for the records
      // Try multiple sources for train number
      String trainNo = metadata['trainNo'] ?? '';
      if (trainNo.isEmpty && records.isNotEmpty) {
        trainNo = records.first.trainNo;
      }
      if (trainNo == '00000') {
        // Default train number was used, try to find a real one
        for (var record in records) {
          if (record.trainNo != '00000') {
            trainNo = record.trainNo;
            break;
          }
        }
      }
      
      final trainName = metadata['trainName'] ?? 'Train $trainNo';
      
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

      // Build a cache of trainNo -> trainId to handle multi-train Excel files
      final Map<String, String> trainIdCache = {trainNo: trainId!};

      // Fetch existing mobile numbers to skip duplicates
      final existingMobiles = await _psiService.getExistingMobileNumbers();
      print('ExcelImport: ${existingMobiles.length} existing mobile numbers found');

      // Save records to Supabase
      int skippedCount = 0;
      for (var record in records) {
        // Skip if mobile number already exists
        if (record.mobileNo.isNotEmpty && existingMobiles.contains(record.mobileNo)) {
          skippedCount++;
          print('⟳ Skipped duplicate mobile: ${record.mobileNo} (${record.passengerName})');
          continue;
        }
        try {
          // Resolve trainId for this record's train number
          String? resolvedTrainId = trainIdCache[record.trainNo];
          if (resolvedTrainId == null) {
            resolvedTrainId = await _findOrCreateTrain(record.trainNo, 'Train ${record.trainNo}');
            if (resolvedTrainId != null) {
              trainIdCache[record.trainNo] = resolvedTrainId;
            }
          }

          if (resolvedTrainId == null) {
            errorCount++;
            errors.add('Could not resolve train for ${record.passengerName} (Train: ${record.trainNo})');
            continue;
          }

          final recordToSave = record.copyWith(trainId: resolvedTrainId);
          
          print('Saving record: ${record.passengerName}, TrainID: ${recordToSave.trainId}, TripType: ${recordToSave.tripType}');
              
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
        'skippedCount': skippedCount,
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

  /// Parse date from various formats - VERY FLEXIBLE
  DateTime _parseDate(String dateStr) {
    try {
      // Remove any extra whitespace
      dateStr = dateStr.trim();
      
      print('Parsing date: "$dateStr"');
      
      // Handle Excel numeric dates (days since 1900-01-01)
      if (RegExp(r'^\d+$').hasMatch(dateStr)) {
        try {
          final days = int.parse(dateStr);
          if (days > 40000 && days < 60000) { // Reasonable range for Excel dates (2009-2064)
            final excelEpoch = DateTime(1899, 12, 30); // Excel's epoch
            final parsedDate = excelEpoch.add(Duration(days: days));
            print('Parsed date (Excel numeric): $parsedDate');
            return parsedDate;
          }
        } catch (e) {
          // Not an Excel date, continue with other formats
        }
      }
      
      // Try DD-MM-YYYY format (09-06-2025)
      if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          
          if (day != null && month != null && year != null) {
            // Handle 2-digit years
            int fullYear = year;
            if (year < 100) {
              fullYear = year < 50 ? 2000 + year : 1900 + year;
            }
            
            // Validate the values
            if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && fullYear >= 1900) {
              final parsedDate = DateTime(fullYear, month, day);
              print('Parsed date (DD-MM-YYYY): $parsedDate');
              return parsedDate;
            }
          }
        }
      }
      
      // Try DD/MM/YYYY or MM/DD/YYYY format
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final part1 = int.tryParse(parts[0]);
          final part2 = int.tryParse(parts[1]);
          var year = int.tryParse(parts[2]);
          
          if (part1 != null && part2 != null && year != null) {
            // Handle 2-digit years
            if (year < 100) {
              year = year < 50 ? 2000 + year : 1900 + year;
            }
            
            if (year >= 1900) {
              // Try DD/MM/YYYY first (day > 12 means it must be DD/MM/YYYY)
              if (part1 > 12) {
                final day = part1;
                final month = part2;
                if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
                  final parsedDate = DateTime(year, month, day);
                  print('Parsed date (DD/MM/YYYY): $parsedDate');
                  return parsedDate;
                }
              }
              // Try MM/DD/YYYY (month > 12 means it must be MM/DD/YYYY)
              else if (part2 > 12) {
                final month = part1;
                final day = part2;
                if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
                  final parsedDate = DateTime(year, month, day);
                  print('Parsed date (MM/DD/YYYY): $parsedDate');
                  return parsedDate;
                }
              }
              // Ambiguous case (both <= 12), try DD/MM/YYYY first
              else {
                final day = part1;
                final month = part2;
                if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
                  final parsedDate = DateTime(year, month, day);
                  print('Parsed date (DD/MM/YYYY - ambiguous): $parsedDate');
                  return parsedDate;
                }
              }
            }
          }
        }
      }
      
      // Try parsing as DateTime (ISO format: YYYY-MM-DD)
      try {
        final parsedDate = DateTime.parse(dateStr);
        print('Parsed date (ISO): $parsedDate');
        return parsedDate;
      } catch (e) {
        // Continue to fallback
      }
      
      // Last resort: return current date
      print('Could not parse date "$dateStr", using current date');
      return DateTime.now();
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
