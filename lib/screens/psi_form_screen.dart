import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/psi_record_model.dart';
import '../services/psi_service.dart';
import '../services/train_service.dart';
import '../models/train_model.dart';

class PSIFormScreen extends StatefulWidget {
  final PSIRecord? record;

  const PSIFormScreen({super.key, this.record});

  @override
  State<PSIFormScreen> createState() => _PSIFormScreenState();
}

class _PSIFormScreenState extends State<PSIFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _psiService = PSIService();
  final _trainService = TrainService();

  // Form controllers
  final _passengerNameController = TextEditingController();
  final _pnrNoController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _coachController = TextEditingController();
  final _seatNoController = TextEditingController();
  final _psiScoreController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _ehkNameController = TextEditingController();
  final _tripIdController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedTrainId;
  String _selectedTripType = 'Going';
  List<Train> _trains = [];
  bool _isLoading = false;
  
  // Service ratings
  String? _service1Rating; // Toiletries
  String? _service2Rating; // Compartment cleaning
  String? _service3Rating; // Garbage collection
  String? _service4Rating; // Mosquito repellent (AC only)
  String? _service5Rating; // Staff behaviour
  
  final List<String> _ratingOptions = ['Excellent', 'Very Good', 'Good', 'Average', 'Poor'];

  @override
  void initState() {
    super.initState();
    _loadTrains();
    if (widget.record != null) {
      _populateForm();
    }
  }

  Future<void> _loadTrains() async {
    try {
      final trains = await _trainService.getAllTrains();
      setState(() {
        _trains = trains;
        
        // Validate selected train ID still exists
        if (_selectedTrainId != null && !trains.any((t) => t.id == _selectedTrainId)) {
          _selectedTrainId = null;
        }
        
        // If editing and train ID exists, ensure it's in the list
        if (widget.record != null && widget.record!.trainId.isNotEmpty) {
          _selectedTrainId = widget.record!.trainId;
        }
      });
    } catch (e) {
      print('Error loading trains: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trains: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _populateForm() {
    final record = widget.record!;
    _passengerNameController.text = record.passengerName;
    _pnrNoController.text = record.pnrNo;
    _mobileNoController.text = record.mobileNo;
    _coachController.text = record.coach;
    _seatNoController.text = record.seatNo;
    _psiScoreController.text = record.psiScore.toString();
    _feedbackController.text = record.feedback ?? '';
    _ehkNameController.text = record.ehkName;
    _tripIdController.text = record.tripId;
    _selectedDate = record.date;
    _selectedTrainId = record.trainId;
    _selectedTripType = record.tripType;
    _service1Rating = record.service1Rating;
    _service2Rating = record.service2Rating;
    _service3Rating = record.service3Rating;
    _service4Rating = record.service4Rating;
    _service5Rating = record.service5Rating;
    
    // Recalculate PSI if ratings exist
    if (_service1Rating != null || _service2Rating != null || 
        _service3Rating != null || _service4Rating != null || 
        _service5Rating != null) {
      _psiScoreController.text = _calculatePSI().toStringAsFixed(2);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  // Helper to check if coach is AC
  bool _isACCoach(String coach) {
    final c = coach.toUpperCase().trim();
    return c.startsWith('A') || c.startsWith('B') || c.startsWith('H') || 
           c == 'CC' || c == 'E' || c == 'M1';
  }
  
  // Calculate PSI score based on ratings
  double _calculatePSI() {
    final isAC = _isACCoach(_coachController.text);
    final maxServices = isAC ? 5 : 3;
    
    double totalScore = 0;
    int ratedServices = 0;
    
    final ratings = isAC 
        ? [_service1Rating, _service2Rating, _service3Rating, _service4Rating, _service5Rating]
        : [_service2Rating, _service3Rating, _service5Rating]; // Non-AC uses services 2, 3, 5
    
    for (var rating in ratings) {
      if (rating != null) {
        ratedServices++;
        switch (rating) {
          case 'Excellent':
            totalScore += 1.0;
            break;
          case 'Very Good':
            totalScore += 0.9;
            break;
          case 'Good':
            totalScore += 0.8;
            break;
          case 'Average':
            totalScore += 0.5;
            break;
          case 'Poor':
            totalScore += 0.2;
            break;
        }
      }
    }
    
    if (ratedServices == 0) return 0;
    final psi = (totalScore / maxServices) * 100;
    print('Calculated PSI: $psi (Total: $totalScore, Max: $maxServices, Rated: $ratedServices)');
    return psi;
  }
  
  // Set all ratings to Excellent
  void _setDefaultExcellent() {
    setState(() {
      final isAC = _isACCoach(_coachController.text);
      if (isAC) {
        _service1Rating = 'Excellent';
        _service2Rating = 'Excellent';
        _service3Rating = 'Excellent';
        _service4Rating = 'Excellent';
        _service5Rating = 'Excellent';
      } else {
        _service2Rating = 'Excellent';
        _service3Rating = 'Excellent';
        _service5Rating = 'Excellent';
      }
      _psiScoreController.text = _calculatePSI().toStringAsFixed(2);
    });
  }

  Future<void> _savePSIRecord() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTrainId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a train'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final selectedTrain = _trains.firstWhere((t) => t.id == _selectedTrainId);
      
      // Calculate PSI from ratings
      final calculatedPSI = _calculatePSI();

      final record = PSIRecord(
        id: widget.record?.id,
        trainId: _selectedTrainId!,
        trainNo: selectedTrain.trainNoGoing,
        trainName: selectedTrain.trainNameGoing,
        scheduleId: widget.record?.scheduleId ?? '',
        tripId: _tripIdController.text.trim(),
        date: _selectedDate,
        passengerName: _passengerNameController.text.trim(),
        pnrNo: _pnrNoController.text.trim(),
        mobileNo: _mobileNoController.text.trim(),
        coach: _coachController.text.trim(),
        seatNo: _seatNoController.text.trim(),
        psiScore: calculatedPSI,
        feedback: _feedbackController.text.trim().isEmpty 
            ? null 
            : _feedbackController.text.trim(),
        tripType: _selectedTripType,
        ehkName: _ehkNameController.text.trim(),
        service1Rating: _service1Rating,
        service2Rating: _service2Rating,
        service3Rating: _service3Rating,
        service4Rating: _service4Rating,
        service5Rating: _service5Rating,
        createdAt: widget.record?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = widget.record == null
          ? await _psiService.createPSIRecord(record)
          : await _psiService.updatePSIRecord(widget.record!.id!, record);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );

        if (result['success']) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  @override
  void dispose() {
    _passengerNameController.dispose();
    _pnrNoController.dispose();
    _mobileNoController.dispose();
    _coachController.dispose();
    _seatNoController.dispose();
    _psiScoreController.dispose();
    _feedbackController.dispose();
    _ehkNameController.dispose();
    _tripIdController.dispose();
    super.dispose();
  }
  
  // Build rating row widget
  Widget _buildRatingRow(String serviceLabel, String? currentRating, Function(String) onRatingChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          serviceLabel,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: _ratingOptions.map((rating) {
            final isSelected = currentRating == rating;
            return Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    onRatingChanged(rating);
                    _psiScoreController.text = _calculatePSI().toStringAsFixed(2);
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.shade100 : Colors.grey.shade100,
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.grey.shade400,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rating,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.green.shade900 : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record == null ? 'Add PSI Record' : 'Edit PSI Record'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Train Selection
                    DropdownButtonFormField<String>(
                      value: _trains.any((t) => t.id == _selectedTrainId) 
                          ? _selectedTrainId 
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Train',
                        border: OutlineInputBorder(),
                      ),
                      items: _trains.map((train) {
                        return DropdownMenuItem(
                          value: train.id,
                          child: Text('${train.trainNoGoing} - ${train.trainNameGoing}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedTrainId = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a train';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Trip ID
                    TextFormField(
                      controller: _tripIdController,
                      decoration: const InputDecoration(
                        labelText: 'Trip ID',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter trip ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date Selection
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Passenger Name
                    TextFormField(
                      controller: _passengerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Passenger Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter passenger name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // PNR Number
                    TextFormField(
                      controller: _pnrNoController,
                      decoration: const InputDecoration(
                        labelText: 'PNR Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter PNR number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mobile Number
                    TextFormField(
                      controller: _mobileNoController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Coach
                    TextFormField(
                      controller: _coachController,
                      decoration: const InputDecoration(
                        labelText: 'Coach',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter coach';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Seat Number
                    TextFormField(
                      controller: _seatNoController,
                      decoration: const InputDecoration(
                        labelText: 'Seat Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter seat number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Trip Type
                    DropdownButtonFormField<String>(
                      value: _selectedTripType,
                      decoration: const InputDecoration(
                        labelText: 'Trip Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Going', 'Coming'].map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedTripType = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // EHK Name
                    TextFormField(
                      controller: _ehkNameController,
                      decoration: const InputDecoration(
                        labelText: 'EHK Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter EHK name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Service Ratings Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Service Ratings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _coachController.text.isEmpty 
                                    ? null 
                                    : _setDefaultExcellent,
                                icon: const Icon(Icons.star, size: 18),
                                label: const Text('All Excellent'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isACCoach(_coachController.text) ? 'AC Coach - 5 Services' : 'Non-AC/Sleeper - 3 Services',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Show ratings based on coach type
                          if (_isACCoach(_coachController.text)) ...[
                            _buildRatingRow(
                              '1. Toiletries availability',
                              _service1Rating,
                              (rating) => _service1Rating = rating,
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          _buildRatingRow(
                            '${_isACCoach(_coachController.text) ? '2' : '1'}. Passenger compartment cleaning',
                            _service2Rating,
                            (rating) => _service2Rating = rating,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildRatingRow(
                            '${_isACCoach(_coachController.text) ? '3' : '2'}. Garbage collection',
                            _service3Rating,
                            (rating) => _service3Rating = rating,
                          ),
                          const SizedBox(height: 16),
                          
                          if (_isACCoach(_coachController.text)) ...[
                            _buildRatingRow(
                              '4. Mosquito/Cockroach repellent',
                              _service4Rating,
                              (rating) => _service4Rating = rating,
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          _buildRatingRow(
                            '${_isACCoach(_coachController.text) ? '5' : '3'}. Staff behaviour/response',
                            _service5Rating,
                            (rating) => _service5Rating = rating,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // PSI Score (Auto-calculated, read-only)
                    TextFormField(
                      controller: _psiScoreController,
                      decoration: const InputDecoration(
                        labelText: 'PSI Score (Auto-calculated)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey,
                      ),
                      readOnly: true,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Feedback (Optional)
                    TextFormField(
                      controller: _feedbackController,
                      decoration: const InputDecoration(
                        labelText: 'Feedback (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _savePSIRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          widget.record == null ? 'Add PSI Record' : 'Update PSI Record',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
