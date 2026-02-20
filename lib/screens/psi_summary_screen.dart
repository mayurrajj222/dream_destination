import 'package:flutter/material.dart';
import '../services/psi_service.dart';

class PSISummaryScreen extends StatefulWidget {
  const PSISummaryScreen({super.key});

  @override
  State<PSISummaryScreen> createState() => _PSISummaryScreenState();
}

class _PSISummaryScreenState extends State<PSISummaryScreen> {
  final _psiService = PSIService();
  Map<String, dynamic> _summary = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    
    // Load summary for last 30 days
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    
    final summary = await _psiService.getPSISummary(startDate, endDate);
    
    setState(() {
      _summary = summary;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PSI Summary'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PSI Summary (Last 30 Days)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildSummaryCard(
                          'Total Records',
                          _summary['totalRecords'].toString(),
                          Colors.blue,
                          Icons.assignment,
                        ),
                        _buildSummaryCard(
                          'Average PSI',
                          _summary['averagePSI'].toStringAsFixed(2),
                          Colors.green,
                          Icons.trending_up,
                        ),
                        _buildSummaryCard(
                          'Highest PSI',
                          _summary['highestPSI'].toStringAsFixed(2),
                          Colors.orange,
                          Icons.star,
                        ),
                        _buildSummaryCard(
                          'Lowest PSI',
                          _summary['lowestPSI'].toStringAsFixed(2),
                          Colors.red,
                          Icons.trending_down,
                        ),
                        _buildSummaryCard(
                          'Above 90%',
                          _summary['above90'].toString(),
                          Colors.teal,
                          Icons.thumb_up,
                        ),
                        _buildSummaryCard(
                          'Below 70%',
                          _summary['below70'].toString(),
                          Colors.deepOrange,
                          Icons.thumb_down,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
