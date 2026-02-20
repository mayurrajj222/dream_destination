import 'package:flutter/material.dart';
import '../models/train_model.dart';
import '../services/train_service.dart';

class TrainFormScreen extends StatefulWidget {
  final Train? train;

  const TrainFormScreen({super.key, this.train});

  @override
  State<TrainFormScreen> createState() => _TrainFormScreenState();
}

class _TrainFormScreenState extends State<TrainFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trainService = TrainService();

  // Controllers
  late TextEditingController _trainNoGoingController;
  late TextEditingController _trainNameGoingController;
  late TextEditingController _stationFromController;
  late TextEditingController _stationToController;
  late TextEditingController _totalJanitorController;
  late TextEditingController _departureTimeGoingController;
  late TextEditingController _journeyDurationGoingController;
  late TextEditingController _trainNoComingController;
  late TextEditingController _trainNameComingController;
  late TextEditingController _departureTimeComingController;
  late TextEditingController _journeyDurationComingController;

  // Going On days
  bool _goingOnMon = false;
  bool _goingOnTue = false;
  bool _goingOnWed = false;
  bool _goingOnThu = false;
  bool _goingOnFri = false;
  bool _goingOnSat = false;
  bool _goingOnSun = false;

  // Coming On days
  bool _comingOnMon = false;
  bool _comingOnTue = false;
  bool _comingOnWed = false;
  bool _comingOnThu = false;
  bool _comingOnFri = false;
  bool _comingOnSat = false;
  bool _comingOnSun = false;

  // Coaches
  bool _coachWGFACC = false;
  bool _coachWGACCWA1 = false;
  bool _coachWGACCNB1 = false;
  bool _coachWGSCNSL = false;
  bool _coachWGCZAC = false;
  bool _coachWGSCZD = false;
  bool _coachLWFCZAC = false;
  bool _coachWGFCNAC = false;
  bool _coachM1 = false;
  bool _coachCE = false;
  bool _coachGS = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _trainNoGoingController = TextEditingController(
      text: widget.train?.trainNoGoing ?? '',
    );
    _trainNameGoingController = TextEditingController(
      text: widget.train?.trainNameGoing ?? '',
    );
    _stationFromController = TextEditingController(
      text: widget.train?.stationFrom ?? '',
    );
    _stationToController = TextEditingController(
      text: widget.train?.stationTo ?? '',
    );
    _totalJanitorController = TextEditingController(
      text: widget.train?.totalJanitor.toString() ?? '0',
    );
    _departureTimeGoingController = TextEditingController(
      text: widget.train?.departureTimeGoing ?? '00:00:00',
    );
    _journeyDurationGoingController = TextEditingController(
      text: widget.train?.journeyDurationGoing ?? '00:00:00',
    );
    _trainNoComingController = TextEditingController(
      text: widget.train?.trainNoComing ?? '',
    );
    _trainNameComingController = TextEditingController(
      text: widget.train?.trainNameComing ?? '',
    );
    _departureTimeComingController = TextEditingController(
      text: widget.train?.departureTimeComing ?? '00:00:00',
    );
    _journeyDurationComingController = TextEditingController(
      text: widget.train?.journeyDurationComing ?? '00:00:00',
    );

    if (widget.train != null) {
      _goingOnMon = widget.train!.goingOnMon;
      _goingOnTue = widget.train!.goingOnTue;
      _goingOnWed = widget.train!.goingOnWed;
      _goingOnThu = widget.train!.goingOnThu;
      _goingOnFri = widget.train!.goingOnFri;
      _goingOnSat = widget.train!.goingOnSat;
      _goingOnSun = widget.train!.goingOnSun;
      _comingOnMon = widget.train!.comingOnMon;
      _comingOnTue = widget.train!.comingOnTue;
      _comingOnWed = widget.train!.comingOnWed;
      _comingOnThu = widget.train!.comingOnThu;
      _comingOnFri = widget.train!.comingOnFri;
      _comingOnSat = widget.train!.comingOnSat;
      _comingOnSun = widget.train!.comingOnSun;
      _coachWGFACC = widget.train!.coachWGFACC;
      _coachWGACCWA1 = widget.train!.coachWGACCWA1;
      _coachWGACCNB1 = widget.train!.coachWGACCNB1;
      _coachWGSCNSL = widget.train!.coachWGSCNSL;
      _coachWGCZAC = widget.train!.coachWGCZAC;
      _coachWGSCZD = widget.train!.coachWGSCZD;
      _coachLWFCZAC = widget.train!.coachLWFCZAC;
      _coachWGFCNAC = widget.train!.coachWGFCNAC;
      _coachM1 = widget.train!.coachM1;
      _coachCE = widget.train!.coachCE;
      _coachGS = widget.train!.coachGS;
    }
  }

  @override
  void dispose() {
    _trainNoGoingController.dispose();
    _trainNameGoingController.dispose();
    _stationFromController.dispose();
    _stationToController.dispose();
    _totalJanitorController.dispose();
    _departureTimeGoingController.dispose();
    _journeyDurationGoingController.dispose();
    _trainNoComingController.dispose();
    _trainNameComingController.dispose();
    _departureTimeComingController.dispose();
    _journeyDurationComingController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final train = Train(
        id: widget.train?.id,
        trainNoGoing: _trainNoGoingController.text.trim(),
        trainNameGoing: _trainNameGoingController.text.trim(),
        stationFrom: _stationFromController.text.trim(),
        stationTo: _stationToController.text.trim(),
        totalJanitor: int.tryParse(_totalJanitorController.text) ?? 0,
        departureTimeGoing: _departureTimeGoingController.text.trim(),
        journeyDurationGoing: _journeyDurationGoingController.text.trim(),
        trainNoComing: _trainNoComingController.text.trim(),
        trainNameComing: _trainNameComingController.text.trim(),
        departureTimeComing: _departureTimeComingController.text.trim(),
        journeyDurationComing: _journeyDurationComingController.text.trim(),
        goingOnMon: _goingOnMon,
        goingOnTue: _goingOnTue,
        goingOnWed: _goingOnWed,
        goingOnThu: _goingOnThu,
        goingOnFri: _goingOnFri,
        goingOnSat: _goingOnSat,
        goingOnSun: _goingOnSun,
        comingOnMon: _comingOnMon,
        comingOnTue: _comingOnTue,
        comingOnWed: _comingOnWed,
        comingOnThu: _comingOnThu,
        comingOnFri: _comingOnFri,
        comingOnSat: _comingOnSat,
        comingOnSun: _comingOnSun,
        coachWGFACC: _coachWGFACC,
        coachWGACCWA1: _coachWGACCWA1,
        coachWGACCNB1: _coachWGACCNB1,
        coachWGSCNSL: _coachWGSCNSL,
        coachWGCZAC: _coachWGCZAC,
        coachWGSCZD: _coachWGSCZD,
        coachLWFCZAC: _coachLWFCZAC,
        coachWGFCNAC: _coachWGFCNAC,
        coachM1: _coachM1,
        coachCE: _coachCE,
        coachGS: _coachGS,
      );

      Map<String, dynamic> result;
      if (widget.train == null) {
        result = await _trainService.createTrain(train);
      } else {
        result = await _trainService.updateTrain(widget.train!.id!, train);
      }

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (result['success']) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.train != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Update Train' : 'Add Train'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUpdate ? 'Update Train' : 'Add Train',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),

                // GOING TRAIN SECTION
                _buildSectionTitle('Going Train Details'),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _trainNoGoingController,
                  label: 'Train No. *',
                  enabled: !isUpdate,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter train number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _trainNameGoingController,
                  label: 'Train Name *',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter train name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _stationFromController,
                  label: 'Station From *',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter station from';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _stationToController,
                  label: 'Station To *',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter station to';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _totalJanitorController,
                  label: 'Total Janitor *',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter total janitor';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _departureTimeGoingController,
                  label: 'Departure Time Going* (00:00:00)',
                  hint: 'HH:MM:SS',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter departure time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _journeyDurationGoingController,
                  label: 'Journey Duration Going* (00:00:00)',
                  hint: 'HH:MM:SS',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter journey duration';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Going On Days
                _buildSectionTitle('Going On'),
                const SizedBox(height: 12),
                _buildDayCheckboxes(
                  mon: _goingOnMon,
                  tue: _goingOnTue,
                  wed: _goingOnWed,
                  thu: _goingOnThu,
                  fri: _goingOnFri,
                  sat: _goingOnSat,
                  sun: _goingOnSun,
                  onMonChanged: (val) => setState(() => _goingOnMon = val!),
                  onTueChanged: (val) => setState(() => _goingOnTue = val!),
                  onWedChanged: (val) => setState(() => _goingOnWed = val!),
                  onThuChanged: (val) => setState(() => _goingOnThu = val!),
                  onFriChanged: (val) => setState(() => _goingOnFri = val!),
                  onSatChanged: (val) => setState(() => _goingOnSat = val!),
                  onSunChanged: (val) => setState(() => _goingOnSun = val!),
                ),
                const SizedBox(height: 24),

                // COMING TRAIN SECTION
                _buildSectionTitle('Coming Train Details'),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _trainNoComingController,
                  label: 'Train No Coming*',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter train number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _trainNameComingController,
                  label: 'Train Name*',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter train name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _departureTimeComingController,
                  label: 'Departure Time Coming* (00:00:00)',
                  hint: 'HH:MM:SS',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter departure time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _journeyDurationComingController,
                  label: 'Journey Duration Coming* (00:00:00)',
                  hint: 'HH:MM:SS',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter journey duration';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Coming On Days
                _buildSectionTitle('Coming On'),
                const SizedBox(height: 12),
                _buildDayCheckboxes(
                  mon: _comingOnMon,
                  tue: _comingOnTue,
                  wed: _comingOnWed,
                  thu: _comingOnThu,
                  fri: _comingOnFri,
                  sat: _comingOnSat,
                  sun: _comingOnSun,
                  onMonChanged: (val) => setState(() => _comingOnMon = val!),
                  onTueChanged: (val) => setState(() => _comingOnTue = val!),
                  onWedChanged: (val) => setState(() => _comingOnWed = val!),
                  onThuChanged: (val) => setState(() => _comingOnThu = val!),
                  onFriChanged: (val) => setState(() => _comingOnFri = val!),
                  onSatChanged: (val) => setState(() => _comingOnSat = val!),
                  onSunChanged: (val) => setState(() => _comingOnSun = val!),
                ),
                const SizedBox(height: 24),

                // COACHES DETAIL
                _buildSectionTitle('COACHES DETAIL'),
                const SizedBox(height: 12),
                _buildCoachCheckbox(
                  'WGF ACC W - H A H1 - AC 1st Tier',
                  _coachWGFACC,
                  (val) => setState(() => _coachWGFACC = val!),
                ),
                _buildCoachCheckbox(
                  'WGACCW(A1) - AC 2 Tier',
                  _coachWGACCWA1,
                  (val) => setState(() => _coachWGACCWA1 = val!),
                ),
                _buildCoachCheckbox(
                  'WGACCN(B1) - AC 3 Tier',
                  _coachWGACCNB1,
                  (val) => setState(() => _coachWGACCNB1 = val!),
                ),
                _buildCoachCheckbox(
                  'WGSCN SL (SL) - Sleeper',
                  _coachWGSCNSL,
                  (val) => setState(() => _coachWGSCNSL = val!),
                ),
                _buildCoachCheckbox(
                  'WGCZAC(CC) - AC Chair Car',
                  _coachWGCZAC,
                  (val) => setState(() => _coachWGCZAC = val!),
                ),
                _buildCoachCheckbox(
                  'WGSCZ(D) - Chair Car',
                  _coachWGSCZD,
                  (val) => setState(() => _coachWGSCZD = val!),
                ),
                _buildCoachCheckbox(
                  'LWFCZAC (E) - Shatabdi 2nd Tier',
                  _coachLWFCZAC,
                  (val) => setState(() => _coachLWFCZAC = val!),
                ),
                _buildCoachCheckbox(
                  'WGFCNAC (HB) - Shatabdi 1st Tier',
                  _coachWGFCNAC,
                  (val) => setState(() => _coachWGFCNAC = val!),
                ),
                _buildCoachCheckbox(
                  'M1 Coach',
                  _coachM1,
                  (val) => setState(() => _coachM1 = val!),
                ),
                _buildCoachCheckbox(
                  'CE Coach',
                  _coachCE,
                  (val) => setState(() => _coachCE = val!),
                ),
                _buildCoachCheckbox(
                  'GS - General Class',
                  _coachGS,
                  (val) => setState(() => _coachGS = val!),
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDayCheckboxes({
    required bool mon,
    required bool tue,
    required bool wed,
    required bool thu,
    required bool fri,
    required bool sat,
    required bool sun,
    required Function(bool?) onMonChanged,
    required Function(bool?) onTueChanged,
    required Function(bool?) onWedChanged,
    required Function(bool?) onThuChanged,
    required Function(bool?) onFriChanged,
    required Function(bool?) onSatChanged,
    required Function(bool?) onSunChanged,
  }) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildCheckbox('Mon', mon, onMonChanged),
        _buildCheckbox('Tue', tue, onTueChanged),
        _buildCheckbox('Wed', wed, onWedChanged),
        _buildCheckbox('Thu', thu, onThuChanged),
        _buildCheckbox('Fri', fri, onFriChanged),
        _buildCheckbox('Sat', sat, onSatChanged),
        _buildCheckbox('Sun', sun, onSunChanged),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue.shade700,
        ),
        Text(label),
      ],
    );
  }

  Widget _buildCoachCheckbox(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue.shade700,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
