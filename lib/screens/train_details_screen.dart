import 'package:flutter/material.dart';
import '../models/train_model.dart';
import '../services/train_service.dart';
import 'train_form_screen.dart';

class TrainDetailsScreen extends StatefulWidget {
  const TrainDetailsScreen({super.key});

  @override
  State<TrainDetailsScreen> createState() => _TrainDetailsScreenState();
}

class _TrainDetailsScreenState extends State<TrainDetailsScreen> {
  final _trainService = TrainService();
  List<Train> _trains = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrains();
  }

  Future<void> _loadTrains() async {
    setState(() => _isLoading = true);
    final trains = await _trainService.getAllTrains();
    setState(() {
      _trains = trains;
      _isLoading = false;
    });
  }

  Future<void> _deleteTrain(String trainId, String trainName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete $trainName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _trainService.deleteTrain(trainId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (result['success']) {
          _loadTrains();
        }
      }
    }
  }

  String _formatDays(Train train, bool isGoing) {
    List<String> days = [];
    if (isGoing) {
      if (train.goingOnMon) days.add('Mon');
      if (train.goingOnTue) days.add('Tue');
      if (train.goingOnWed) days.add('Wed');
      if (train.goingOnThu) days.add('Thu');
      if (train.goingOnFri) days.add('Fri');
      if (train.goingOnSat) days.add('Sat');
      if (train.goingOnSun) days.add('Sun');
    } else {
      if (train.comingOnMon) days.add('Mon');
      if (train.comingOnTue) days.add('Tue');
      if (train.comingOnWed) days.add('Wed');
      if (train.comingOnThu) days.add('Thu');
      if (train.comingOnFri) days.add('Fri');
      if (train.comingOnSat) days.add('Sat');
      if (train.comingOnSun) days.add('Sun');
    }
    return days.isEmpty ? '-' : days.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Train Details'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrainFormScreen(),
                  ),
                ).then((result) {
                  if (result == true) {
                    _loadTrains();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Train'),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trains.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.train,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No trains found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first train',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTrains,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _trains.length,
                    itemBuilder: (context, index) {
                      final train = _trains[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with actions
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          train.trainNameGoing,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Train No: ${train.trainNoGoing}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TrainFormScreen(
                                                train: train,
                                              ),
                                            ),
                                          ).then((result) {
                                            if (result == true) {
                                              _loadTrains();
                                            }
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          _deleteTrain(
                                            train.id!,
                                            train.trainNameGoing,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              
                              // Going Train Details
                              _buildSectionTitle('Going Train'),
                              const SizedBox(height: 8),
                              _buildInfoRow('Route', '${train.stationFrom} → ${train.stationTo}'),
                              _buildInfoRow('Departure', train.departureTimeGoing),
                              _buildInfoRow('Duration', train.journeyDurationGoing),
                              _buildInfoRow('Days', _formatDays(train, true)),
                              const SizedBox(height: 12),
                              
                              // Coming Train Details
                              _buildSectionTitle('Coming Train'),
                              const SizedBox(height: 8),
                              _buildInfoRow('Train No', train.trainNoComing),
                              _buildInfoRow('Train Name', train.trainNameComing),
                              _buildInfoRow('Departure', train.departureTimeComing),
                              _buildInfoRow('Duration', train.journeyDurationComing),
                              _buildInfoRow('Days', _formatDays(train, false)),
                              const SizedBox(height: 12),
                              
                              // Additional Info
                              _buildInfoRow('Total Janitor', train.totalJanitor.toString()),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
