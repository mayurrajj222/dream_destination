import 'package:flutter/material.dart';
import 'tripwise_psi_report_screen.dart';

class TrainwisePSIReportScreen extends StatelessWidget {
  const TrainwisePSIReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen shows PSI data grouped by train
    // For now, using the same layout as tripwise
    // In production, this would group data by train number
    return const TripwisePSIReportScreen();
  }
}
