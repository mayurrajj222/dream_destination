import 'package:excel/excel.dart' as excel_pkg;
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_model.dart';

class AttendanceImportService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String tableName = 'attendance_records';

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<Map<String, dynamic>> importFromExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.single.bytes == null) {
        return {'success': false, 'message': 'No file selected'};
      }

      final bytes = result.files.single.bytes!;
      final workbook = excel_pkg.Excel.decodeBytes(bytes);
      final sheet = workbook.tables[workbook.tables.keys.first];

      if (sheet == null || sheet.rows.isEmpty) {
        return {'success': false, 'message': 'Excel file is empty'};
      }

      // Find header row — look for row containing 'EmpCode' or 'TrainNo'
      int headerRow = -1;
      Map<String, int> colIndex = {};

      for (int i = 0; i < sheet.rows.length && i < 20; i++) {
        final row = sheet.rows[i];
        for (int j = 0; j < row.length; j++) {
          final val = row[j]?.value?.toString().toLowerCase().trim() ?? '';
          if (val.contains('trainno') || val == 'trainno' || val == 'train no') colIndex['trainNo'] = j;
          if (val.contains('sdate') || val == 'sdate' || val == 's.date') colIndex['sDate'] = j;
          if (val.contains('empcode') || val == 'empcode') colIndex['empCode'] = j;
          if (val.contains('empname') || val == 'empname') colIndex['empName'] = j;
          if (val == 'punch1' || val.contains('punch1')) colIndex['punch1'] = j;
          if (val == 'punch2' || val.contains('punch2')) colIndex['punch2'] = j;
          if (val == 'punch3' || val.contains('punch3')) colIndex['punch3'] = j;
          if (val == 'total') colIndex['total'] = j;
        }
        if (colIndex.containsKey('empCode') || colIndex.containsKey('empName')) {
          headerRow = i;
          break;
        }
      }

      // Fallback: assume standard column order from the screenshot
      // S.No | TrainNo | SDate | EmpCode | EmpName | Punch1 | LatLong | Punch2 | LatLong | Punch3 | LatLong | Total
      if (headerRow == -1) {
        headerRow = 0;
        colIndex = {
          'trainNo': 1, 'sDate': 2, 'empCode': 3, 'empName': 4,
          'punch1': 5, 'punch1LatLong': 6,
          'punch2': 7, 'punch2LatLong': 8,
          'punch3': 9, 'punch3LatLong': 10,
          'total': 11,
        };
      } else {
        // After finding header, also look for LatLong columns after each punch
        final headerRowData = sheet.rows[headerRow];
        for (int j = 0; j < headerRowData.length; j++) {
          final val = headerRowData[j]?.value?.toString().toLowerCase().trim() ?? '';
          if (val.contains('latlng') || val.contains('latlong') || val == 'lat/long') {
            // Assign to the punch before it
            if (colIndex.containsKey('punch1') && j > colIndex['punch1']! && !colIndex.containsKey('punch1LatLong')) {
              colIndex['punch1LatLong'] = j;
            } else if (colIndex.containsKey('punch2') && j > colIndex['punch2']! && !colIndex.containsKey('punch2LatLong')) {
              colIndex['punch2LatLong'] = j;
            } else if (colIndex.containsKey('punch3') && j > colIndex['punch3']! && !colIndex.containsKey('punch3LatLong')) {
              colIndex['punch3LatLong'] = j;
            }
          }
        }
      }

      final batchId = 'batch_${DateTime.now().millisecondsSinceEpoch}';
      final List<Map<String, dynamic>> records = [];
      int errorCount = 0;

      for (int i = headerRow + 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty || row.every((c) => c?.value == null)) continue;

        try {
          final trainNo = _cellStr(row, colIndex['trainNo']);
          final empCode = _cellStr(row, colIndex['empCode']);
          final empName = _cellStr(row, colIndex['empName']);

          if (empCode.isEmpty && empName.isEmpty) continue;

          final sDateStr = _cellStr(row, colIndex['sDate']);
          final sDate = sDateStr.isNotEmpty ? _parseDate(row, colIndex['sDate']!) : DateTime.now();

          final punch1Str = _cellStr(row, colIndex['punch1']);
          final punch2Str = _cellStr(row, colIndex['punch2']);
          final punch3Str = _cellStr(row, colIndex['punch3']);

          final punch1LatLong = _cellStr(row, colIndex['punch1LatLong']);
          final punch2LatLong = _cellStr(row, colIndex['punch2LatLong']);
          final punch3LatLong = _cellStr(row, colIndex['punch3LatLong']);

          final totalStr = _cellStr(row, colIndex['total']);

          records.add({
            'user_id': currentUserId,
            'train_no': trainNo,
            's_date': sDate.toIso8601String().split('T').first,
            'emp_code': empCode,
            'emp_name': empName,
            'punch1': _parseTimeStr(punch1Str, sDate),
            'punch1_lat': _parseLat(punch1LatLong),
            'punch1_long': _parseLong(punch1LatLong),
            'punch1_location': punch1LatLong.isNotEmpty ? punch1LatLong : null,
            'punch2': _parseTimeStr(punch2Str, sDate),
            'punch2_lat': _parseLat(punch2LatLong),
            'punch2_long': _parseLong(punch2LatLong),
            'punch2_location': punch2LatLong.isNotEmpty ? punch2LatLong : null,
            'punch3': _parseTimeStr(punch3Str, sDate),
            'punch3_lat': _parseLat(punch3LatLong),
            'punch3_long': _parseLong(punch3LatLong),
            'punch3_location': punch3LatLong.isNotEmpty ? punch3LatLong : null,
            'total': int.tryParse(totalStr) ?? 0,
            'import_batch_id': batchId,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          errorCount++;
          print('AttendanceImport: Error on row $i: $e');
        }
      }

      if (records.isEmpty) {
        return {'success': false, 'message': 'No valid records found in Excel'};
      }

      // Insert in batches of 100
      int saved = 0;
      for (int i = 0; i < records.length; i += 100) {
        final batch = records.sublist(i, i + 100 > records.length ? records.length : i + 100);
        await _supabase.from(tableName).insert(batch);
        saved += batch.length;
      }

      return {
        'success': true,
        'message': 'Import completed',
        'totalRecords': records.length,
        'successCount': saved,
        'errorCount': errorCount,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<List<AttendanceRecord>> getRecords({
    required DateTime fromDate,
    required DateTime toDate,
    String? trainNo,
  }) async {
    try {
      if (currentUserId == null) return [];
      var query = _supabase
          .from(tableName)
          .select()
          .eq('user_id', currentUserId!)
          .gte('s_date', fromDate.toIso8601String().split('T').first)
          .lte('s_date', toDate.toIso8601String().split('T').first);

      if (trainNo != null && trainNo.isNotEmpty) {
        query = query.eq('train_no', trainNo);
      }

      final response = await query.order('s_date', ascending: true);
      return (response as List).map((r) => AttendanceRecord.fromMap(r)).toList();
    } catch (e) {
      print('AttendanceImport: Error fetching records: $e');
      return [];
    }
  }

  // --- helpers ---

  String _cellStr(List<excel_pkg.Data?> row, int? colIdx) {
    if (colIdx == null || colIdx >= row.length) return '';
    return row[colIdx]?.value?.toString().trim() ?? '';
  }

  DateTime _parseDate(List<excel_pkg.Data?> row, int colIdx) {
    final cell = row[colIdx];
    if (cell?.value is excel_pkg.DateCellValue) {
      final d = cell!.value as excel_pkg.DateCellValue;
      // Swap if ambiguous (Indian DD-MM format)
      if (d.month <= 12 && d.day <= 12 && d.month != d.day) {
        return DateTime(d.year, d.day, d.month);
      }
      return d.asDateTimeLocal();
    }
    final str = cell?.value?.toString().trim() ?? '';
    return _parseDateStr(str);
  }

  DateTime _parseDateStr(String s) {
    if (s.isEmpty) return DateTime.now();
    final sep = s.contains('/') ? '/' : s.contains('-') ? '-' : null;
    if (sep != null) {
      final parts = s.split(sep);
      if (parts.length == 3) {
        final a = int.tryParse(parts[0]);
        final b = int.tryParse(parts[1]);
        var y = int.tryParse(parts[2]);
        if (a != null && b != null && y != null) {
          if (y < 100) y = y < 50 ? 2000 + y : 1900 + y;
          return DateTime(y, b, a); // DD-MM-YYYY
        }
      }
    }
    try { return DateTime.parse(s); } catch (_) { return DateTime.now(); }
  }

  String? _parseTimeStr(String timeStr, DateTime baseDate) {
    if (timeStr.isEmpty) return null;
    // Format: "03/11/2025 07:27:00" or "07:27:00"
    try {
      if (timeStr.contains(' ')) {
        final parts = timeStr.split(' ');
        final date = _parseDateStr(parts[0]);
        final timeParts = parts[1].split(':');
        return DateTime(date.year, date.month, date.day,
          int.parse(timeParts[0]), int.parse(timeParts[1]),
          timeParts.length > 2 ? int.parse(timeParts[2]) : 0).toIso8601String();
      } else if (timeStr.contains(':')) {
        final timeParts = timeStr.split(':');
        return DateTime(baseDate.year, baseDate.month, baseDate.day,
          int.parse(timeParts[0]), int.parse(timeParts[1]),
          timeParts.length > 2 ? int.parse(timeParts[2]) : 0).toIso8601String();
      }
    } catch (_) {}
    return null;
  }

  double? _parseLat(String latLong) {
    if (latLong.isEmpty) return null;
    final match = RegExp(r'[Ll]at[:\s]*(-?\d+\.?\d*)').firstMatch(latLong);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }

  double? _parseLong(String latLong) {
    if (latLong.isEmpty) return null;
    final match = RegExp(r'[Ll]on[g]?[:\s]*(-?\d+\.?\d*)').firstMatch(latLong);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }
}
