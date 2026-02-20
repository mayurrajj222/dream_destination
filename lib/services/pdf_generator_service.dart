import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/psi_record_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

class PDFGeneratorService {
  // Helper function to determine if a coach is AC or Non-AC
  static bool _isACCoach(String coachCode) {
    final coach = coachCode.toUpperCase().trim();
    
    // AC coach patterns
    if (coach.startsWith('A') || // A1, A2, etc
        coach.startsWith('B') || // B1, B2, etc
        coach.startsWith('H') || // H, HA, H1, HB, etc
        coach == 'CC' ||         // AC Chair Car
        coach == 'E' ||          // Shatabdi 2nd Tier
        coach == 'M1') {         // M1 AC coach
      return true;
    }
    
    // Non-AC coaches
    if (coach.startsWith('S') || // S, SL, S1, S2, S3, S4, etc (Sleeper)
        coach.startsWith('D') || // D (Chair Car Non-AC)
        coach == 'GS' ||         // General Sleeper
        coach == 'CE') {         // CE Non-AC
      return false;
    }
    
    // Default to Non-AC if unknown
    return false;
  }
  
  // Auto-generate ratings based on PSI score if no ratings exist
  static Map<String, String> _generateRatingsFromPSI(double psiScore, bool isAC) {
    final numServices = isAC ? 5 : 3;
    String rating;
    
    // Determine rating based on PSI score
    if (psiScore >= 95) {
      rating = 'Excellent';
    } else if (psiScore >= 85) {
      rating = 'Very Good';
    } else if (psiScore >= 75) {
      rating = 'Good';
    } else if (psiScore >= 50) {
      rating = 'Average';
    } else {
      rating = 'Poor';
    }
    
    // Set all services to the same rating
    return {
      'service1': isAC ? rating : '',
      'service2': rating,
      'service3': rating,
      'service4': isAC ? rating : '',
      'service5': rating,
    };
  }

  static Future<void> generateFeedbackFormPDF(
    PSIRecord record, {
    int? serialNumber,
  }) async {
    // Auto-detect if coach is AC or Non-AC based on coach code
    final bool isAC = _isACCoach(record.coach);
    
    print('Generating PDF for ${record.passengerName}');
    print('Coach: ${record.coach}, isAC: $isAC');
    print('PSI Score: ${record.psiScore}');
    print('Ratings: S1=${record.service1Rating}, S2=${record.service2Rating}, S3=${record.service3Rating}, S4=${record.service4Rating}, S5=${record.service5Rating}');
    
    // Load checkbox images
    pw.ImageProvider? checkImage;
    pw.ImageProvider? crossImage;
    
    try {
      final checkBytes = await rootBundle.load('assets/checkmark.png');
      checkImage = pw.MemoryImage(checkBytes.buffer.asUint8List());
      
      final crossBytes = await rootBundle.load('assets/cross.png');
      crossImage = pw.MemoryImage(crossBytes.buffer.asUint8List());
      
      print('Checkbox images loaded successfully');
    } catch (e) {
      print('Error loading checkbox images: $e');
    }
    
    // If no ratings exist, auto-generate from PSI score
    Map<String, String?> ratings = {
      'service1': record.service1Rating,
      'service2': record.service2Rating,
      'service3': record.service3Rating,
      'service4': record.service4Rating,
      'service5': record.service5Rating,
    };
    
    // Check if any rating exists
    final hasRatings = ratings.values.any((r) => r != null && r.isNotEmpty);
    
    if (!hasRatings) {
      // Auto-generate ratings from PSI score
      final autoRatings = _generateRatingsFromPSI(record.psiScore, isAC);
      ratings = autoRatings;
      print('Auto-generated ratings from PSI score: $autoRatings');
    }
    
    final pdf = pw.Document();
    
    // Generate serial number in format 0001, 0002, etc.
    final sNo = serialNumber != null 
        ? serialNumber.toString().padLeft(4, '0')
        : '0001';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'FEEDBACK FORM FOR ON BOARD HOUSEKEEPING SERVICES',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 5),
              
              // FOR AC / FOR NON-AC
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 2),
                  color: PdfColors.grey200,
                ),
                child: pw.Text(
                  isAC ? 'FOR AC COACHES' : 'FOR NON-AC / SLEEPER COACHES',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              
              // Coach Type Indicator
              pw.Container(
                padding: const pw.EdgeInsets.all(3),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                ),
                child: pw.Text(
                  'Coach: ${record.coach} (${isAC ? 'AC' : 'Non-AC/Sleeper'})',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              
              // S. No.
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                ),
                child: pw.Text(
                  'S. No. :$sNo',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),
              pw.SizedBox(height: 10),
              
              // Dear Passenger
              pw.Text(
                'Dear Passenger,',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 10),
              
              // Introduction text
              pw.Text(
                'Our endeavor is to provide you the most hygienic On Board Housekeeping Services. Services during 5.00 to 22.00 hrs',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Feedback : Passengers are requested to give feedbak regarding services provided by OBHS staff, in the forms available with OBHS staff, Based on your Feedback payment to the contractor will be made & it will help us to serve you better, kindly spare minutes and rate the area as given in table below:',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 15),
              
              // Passengers Feedback Header
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Passengers Feedback',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              
              // Train, Date, Seat, Passenger info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Train:${record.trainNo}', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Date:${DateFormat('dd/MM/yyyy').format(record.date)}', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text('Seat:${record.coach}-${record.seatNo}', style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(width: 20),
                  pw.Text('Passenger :${record.passengerName} | ${record.mobileNo}', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 10),
              
              // Feedback Table with checkboxes (filled based on ratings)
              _buildFeedbackTable(isAC, ratings, checkImage, crossImage),
              
              pw.SizedBox(height: 15),
              
              // PSI Calculation
              pw.Text(
                'Calculation of PSI : - ${record.psiScore.toStringAsFixed(0)}%',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                '• Maximum Marks will be ${isAC ? '5' : '3'} For ${isAC ? 'AC' : 'Non-AC'} Coaches. This will be counted as under:',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '•Excellent -1.0, Very Good - 0.9 Marks, Good - 0.8 Marks, Average - 0.5 Poor - 0.2 Mark. PSI in the % of Marks Achieved in Feedback form from total Marks.',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          );
        },
      ),
    );

    // Print or share the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildFeedbackTable(
    bool isAC, 
    Map<String, String?> ratings,
    pw.ImageProvider? checkImage,
    pw.ImageProvider? crossImage,
  ) {
    // Services list for AC coaches
    final acServices = [
      {'label': 'Availability of toiletries in AC coaches (liquid soap,tissue paper in western type lavatories & deodorants etc.', 'rating': ratings['service1']},
      {'label': 'Cleaning of Passenger compartment ((including cleaning of passenger aisle vestibule area Doorway area and doorway wash basin spraying of air freshner and cleaning of dustbin)', 'rating': ratings['service2']},
      {'label': 'Collection of garbage from the coach compartments and clearance of dustbins.', 'rating': ratings['service3']},
      {'label': 'Spraying of Mosquito/Cockroch/Fly repellent and providing Glue Board whenever required or on demand by passengers', 'rating': ratings['service4']},
      {'label': 'Behaviour/Respose of Janitors/Supervisor (Including hygiene & cleanliness of Janitors/Supervisor.)', 'rating': ratings['service5']},
    ];
    
    // Services list for Non-AC coaches (typically fewer services)
    final nonAcServices = [
      {'label': 'Cleaning of Passenger compartment and doorway area', 'rating': ratings['service2']},
      {'label': 'Collection of garbage from the coach compartments and clearance of dustbins.', 'rating': ratings['service3']},
      {'label': 'Behaviour/Respose of Janitors/Supervisor (Including hygiene & cleanliness of Janitors/Supervisor.)', 'rating': ratings['service5']},
    ];
    
    final services = isAC ? acServices : nonAcServices;

    return pw.Table(
      border: pw.TableBorder.all(width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Areas of Cleaning / Services', isHeader: true),
            _buildTableCell('Excellent', isHeader: true),
            _buildTableCell('Very Good', isHeader: true),
            _buildTableCell('Good', isHeader: true),
            _buildTableCell('Average', isHeader: true),
            _buildTableCell('Poor', isHeader: true),
          ],
        ),
        // Data Rows with ticks/crosses based on ratings
        ...services.map((service) => _buildFeedbackRow(
          service['label'] as String, 
          service['rating'] as String?,
          checkImage,
          crossImage,
        )),
      ],
    );
  }

  static pw.TableRow _buildFeedbackRow(
    String service, 
    String? selectedRating,
    pw.ImageProvider? checkImage,
    pw.ImageProvider? crossImage,
  ) {
    return pw.TableRow(
      children: [
        _buildTableCell(service),
        _buildCheckboxCell('Excellent', selectedRating, checkImage, crossImage),
        _buildCheckboxCell('Very Good', selectedRating, checkImage, crossImage),
        _buildCheckboxCell('Good', selectedRating, checkImage, crossImage),
        _buildCheckboxCell('Average', selectedRating, checkImage, crossImage),
        _buildCheckboxCell('Poor', selectedRating, checkImage, crossImage),
      ],
    );
  }
  
  static pw.Widget _buildCheckboxCell(
    String rating, 
    String? selectedRating,
    pw.ImageProvider? checkImage,
    pw.ImageProvider? crossImage,
  ) {
    final isSelected = selectedRating == rating;
    final hasSelection = selectedRating != null;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.center,
      child: pw.Container(
        width: 22,
        height: 22,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 1.5, color: PdfColors.black),
        ),
        child: pw.Center(
          child: isSelected && checkImage != null
              ? pw.Image(checkImage, width: 18, height: 18, fit: pw.BoxFit.contain)
              : hasSelection && crossImage != null
                  ? pw.Image(crossImage, width: 18, height: 18, fit: pw.BoxFit.contain)
                  : pw.Container(), // Empty box
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }
}
