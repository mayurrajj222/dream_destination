import 'package:flutter/material.dart';
import 'tripwise_psi_report_screen.dart';

class AllTripwisePSIReportScreen extends StatelessWidget {
  const AllTripwisePSIReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen shows all trips combined
    // For now, redirecting to the tripwise report
    // In production, this would show aggregated data from all trips
    return const TripwisePSIReportScreen();
  }
}
