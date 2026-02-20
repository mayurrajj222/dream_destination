import 'package:flutter/material.dart';
import '../models/trip_card_model.dart';
import '../services/trip_card_service.dart';
import 'package:intl/intl.dart';

class TripCardScreen extends StatefulWidget {
  const TripCardScreen({super.key});

  @override
  State<TripCardScreen> createState() => _TripCardScreenState();
}

class _TripCardScreenState extends State<TripCardScreen> {
  final _tripCardService = TripCardService();
  List<TripCard> _tripCards = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTripCards();
  }

  Future<void> _loadTripCards() async {
    setState(() => _isLoading = true);
    final cards = await _tripCardService.getAllTripCards();
    setState(() {
      _tripCards = cards;
      _isLoading = false;
    });
  }

  Future<void> _searchTripCards(String query) async {
    if (query.isEmpty) {
      _loadTripCards();
      return;
    }
    setState(() => _isLoading = true);
    final cards = await _tripCardService.searchTripCards(query);
    setState(() {
      _tripCards = cards;
      _isLoading = false;
    });
  }

  Future<void> _deleteTripCard(String id, String tripId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete Trip $tripId?'),
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
      final result = await _tripCardService.deleteTripCard(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
        if (result['success']) {
          _loadTripCards();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Card'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Trip ID, Train No, Name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _searchTripCards(value);
              },
            ),
          ),

          // Trip Cards List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tripCards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No trip cards found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTripCards,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _tripCards.length,
                          itemBuilder: (context, index) {
                            final card = _tripCards[index];
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Trip ID: ${card.tripId}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Train: ${card.trainNo} - ${card.trainName}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            _deleteTripCard(
                                                card.id!, card.tripId);
                                          },
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    _buildInfoRow('EHK Name', card.ehkName),
                                    _buildInfoRow(
                                      'Trip Period',
                                      '${DateFormat('dd/MM/yyyy').format(card.tripStartDate)} to ${DateFormat('dd/MM/yyyy').format(card.tripEndDate)}',
                                    ),
                                    _buildInfoRow(
                                      'Route',
                                      '${card.stationFrom} → ${card.stationTo}',
                                    ),
                                    _buildInfoRow('Division', card.division),
                                    _buildInfoRow('Activity', card.activity),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
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
            width: 100,
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
