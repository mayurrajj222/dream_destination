import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/psi_record_model.dart';
import '../services/psi_service.dart';
import '../services/train_service.dart';
import '../models/train_model.dart';

// ── Passenger row data holder ─────────────────────────────────────────────────
class _PassengerRow {
  final TextEditingController name = TextEditingController();
  final TextEditingController pnr = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController coach = TextEditingController();
  final TextEditingController seat = TextEditingController();
  final TextEditingController psi = TextEditingController(text: '100');
  final TextEditingController feedback = TextEditingController();
  DateTime date = DateTime.now();

  void dispose() {
    name.dispose();
    pnr.dispose();
    mobile.dispose();
    coach.dispose();
    seat.dispose();
    psi.dispose();
    feedback.dispose();
  }
}

class PSIFormScreen extends StatefulWidget {
  final PSIRecord? record; // non-null = edit mode (single record)
  const PSIFormScreen({super.key, this.record});

  @override
  State<PSIFormScreen> createState() => _PSIFormScreenState();
}

class _PSIFormScreenState extends State<PSIFormScreen> {
  final _headerKey = GlobalKey<FormState>();
  final _psiService = PSIService();
  final _trainService = TrainService();

  // ── Header fields ────────────────────────────────────────────────────────
  final _companyCtrl = TextEditingController();
  final _ehkCtrl = TextEditingController();
  final _tripIdCtrl = TextEditingController();
  DateTime _tripStart = DateTime.now();
  DateTime _tripEnd = DateTime.now().add(const Duration(days: 1));
  String _tripType = 'Going';
  String? _selectedTrainId;
  List<Train> _trains = [];

  // ── Passenger rows ───────────────────────────────────────────────────────
  final List<_PassengerRow> _rows = [];

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadTrains();
    if (widget.record != null) {
      _isEditMode = true;
      _prefillEdit(widget.record!);
    } else {
      _rows.add(_PassengerRow()); // start with one empty row
    }
  }

  void _prefillEdit(PSIRecord r) {
    _companyCtrl.text = r.companyName ?? '';
    _ehkCtrl.text = r.ehkName;
    _tripIdCtrl.text = r.tripId;
    _tripType = r.tripType;
    _selectedTrainId = r.trainId;
    final row = _PassengerRow();
    row.name.text = r.passengerName;
    row.pnr.text = r.pnrNo;
    row.mobile.text = r.mobileNo;
    row.coach.text = r.coach;
    row.seat.text = r.seatNo;
    row.psi.text = r.psiScore.toString();
    row.feedback.text = r.feedback ?? '';
    row.date = r.date;
    _rows.add(row);
  }

  Future<void> _loadTrains() async {
    try {
      final trains = await _trainService.getAllTrains();
      setState(() {
        _trains = trains;
        if (widget.record != null && widget.record!.trainId.isNotEmpty) {
          _selectedTrainId = widget.record!.trainId;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading trains: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _tripStart : _tripEnd,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() => isStart ? _tripStart = picked : _tripEnd = picked);
  }

  Future<void> _pickRowDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _rows[index].date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _rows[index].date = picked);
  }

  void _addRow() => setState(() => _rows.add(_PassengerRow()));

  void _removeRow(int i) {
    if (_rows.length == 1) return; // keep at least one
    setState(() {
      _rows[i].dispose();
      _rows.removeAt(i);
    });
  }

  Future<void> _save() async {
    if (!_headerKey.currentState!.validate()) return;
    if (_selectedTrainId == null) {
      _snack('Please select a train', Colors.red);
      return;
    }

    // Validate rows
    for (int i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      if (r.name.text.trim().isEmpty || r.pnr.text.trim().isEmpty ||
          r.mobile.text.trim().isEmpty || r.coach.text.trim().isEmpty ||
          r.seat.text.trim().isEmpty) {
        _snack('Row ${i + 1}: fill all required fields', Colors.red);
        return;
      }
      final score = double.tryParse(r.psi.text);
      if (score == null || score < 0 || score > 100) {
        _snack('Row ${i + 1}: PSI score must be 0–100', Colors.red);
        return;
      }
    }

    setState(() => _isLoading = true);
    final train = _trains.firstWhere((t) => t.id == _selectedTrainId);

    if (_isEditMode) {
      // Single record update
      final r = _rows[0];
      final updated = widget.record!.copyWith(
        trainId: _selectedTrainId,
        trainNo: train.trainNoGoing,
        trainName: train.trainNameGoing,
        tripId: _tripIdCtrl.text.trim(),
        date: r.date,
        passengerName: r.name.text.trim(),
        pnrNo: r.pnr.text.trim(),
        mobileNo: r.mobile.text.trim(),
        coach: r.coach.text.trim(),
        seatNo: r.seat.text.trim(),
        psiScore: double.parse(r.psi.text),
        feedback: r.feedback.text.trim().isEmpty ? null : r.feedback.text.trim(),
        tripType: _tripType,
        ehkName: _ehkCtrl.text.trim(),
        companyName: _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
        updatedAt: DateTime.now(),
      );
      final result = await _psiService.updatePSIRecord(updated);
      setState(() => _isLoading = false);
      if (mounted) {
        _snack(result['message'], result['success'] ? Colors.green : Colors.red);
        if (result['success']) Navigator.pop(context, true);
      }
    } else {
      // Bulk insert
      final now = DateTime.now();
      final records = _rows.map((r) => PSIRecord(
        userId: '',
        trainId: _selectedTrainId!,
        trainNo: train.trainNoGoing,
        trainName: train.trainNameGoing,
        scheduleId: '',
        tripId: _tripIdCtrl.text.trim(),
        date: r.date,
        passengerName: r.name.text.trim(),
        pnrNo: r.pnr.text.trim(),
        mobileNo: r.mobile.text.trim(),
        coach: r.coach.text.trim(),
        seatNo: r.seat.text.trim(),
        psiScore: double.parse(r.psi.text),
        feedback: r.feedback.text.trim().isEmpty ? null : r.feedback.text.trim(),
        tripType: _tripType,
        ehkName: _ehkCtrl.text.trim(),
        companyName: _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
        createdAt: now,
        updatedAt: now,
      )).toList();

      final result = await _psiService.bulkCreatePSIRecords(records);
      setState(() => _isLoading = false);
      if (mounted) {
        _snack(result['message'], result['success'] ? Colors.green : Colors.red);
        if (result['success']) Navigator.pop(context, true);
      }
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _ehkCtrl.dispose();
    _tripIdCtrl.dispose();
    for (final r in _rows) r.dispose();
    super.dispose();
  }

  // ── UI helpers ────────────────────────────────────────────────────────────

  static const _hdrColor = Color(0xFFBDD7EE);
  static const _secColor = Color(0xFFDEEBF7);
  static const _titleColor = Color(0xFF1F4E79);

  InputDecoration _cellDeco() => const InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF2196F3), width: 1.5),
    ),
    errorStyle: TextStyle(fontSize: 0, height: 0),
  );

  Widget _headerField(String label, Widget input, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            color: _hdrColor,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          Container(color: Colors.white, child: input),
        ]),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit PSI Record' : 'Add PSI Records'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Scrollable content ──────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title bar
                        Container(
                          width: double.infinity,
                          color: _titleColor,
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          child: const Column(
                            children: [
                              Text('Passenger Feedback',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Trainwise PSI Report',
                                  style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),

                        // ── HEADER SECTION ──────────────────────────────
                        Form(
                          key: _headerKey,
                          child: Container(
                            color: _secColor,
                            padding: const EdgeInsets.all(8),
                            child: Column(children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 6),
                                  child: Text('HEADER INFORMATION',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _titleColor)),
                                ),
                              ),
                              Row(children: [
                                _headerField('Company Name',
                                  TextFormField(controller: _companyCtrl, style: const TextStyle(fontSize: 13), decoration: _cellDeco()),
                                ),
                              ]),
                              Row(children: [
                                _headerField('EHK Name *', TextFormField(
                                  controller: _ehkCtrl,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: _cellDeco(),
                                  validator: (v) => (v == null || v.isEmpty) ? '' : null,
                                ), flex: 2),
                                _headerField('Trip Type *',
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _tripType,
                                      isExpanded: true, isDense: true,
                                      style: const TextStyle(fontSize: 13, color: Colors.black),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      items: ['Going', 'Coming'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                      onChanged: (v) => setState(() => _tripType = v!),
                                    ),
                                  ),
                                ),
                              ]),
                              Row(children: [
                                _headerField('Trip Start *',
                                  InkWell(
                                    onTap: () => _pickDate(true),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                                      child: Row(children: [
                                        Expanded(child: Text(DateFormat('dd-MM-yyyy').format(_tripStart), style: const TextStyle(fontSize: 13))),
                                        const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                                      ]),
                                    ),
                                  ),
                                ),
                                _headerField('Trip End *',
                                  InkWell(
                                    onTap: () => _pickDate(false),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                                      child: Row(children: [
                                        Expanded(child: Text(DateFormat('dd-MM-yyyy').format(_tripEnd), style: const TextStyle(fontSize: 13))),
                                        const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                                      ]),
                                    ),
                                  ),
                                ),
                              ]),
                              Row(children: [
                                _headerField('Trip ID *', TextFormField(
                                  controller: _tripIdCtrl,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: _cellDeco(),
                                  validator: (v) => (v == null || v.isEmpty) ? '' : null,
                                )),
                                _headerField('Train No *',
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _trains.any((t) => t.id == _selectedTrainId) ? _selectedTrainId : null,
                                      isExpanded: true, isDense: true,
                                      hint: const Text('Select', style: TextStyle(fontSize: 12)),
                                      style: const TextStyle(fontSize: 13, color: Colors.black),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      items: _trains.map((t) => DropdownMenuItem(
                                        value: t.id,
                                        child: Text('${t.trainNoGoing} - ${t.trainNameGoing}', overflow: TextOverflow.ellipsis),
                                      )).toList(),
                                      onChanged: (v) => setState(() => _selectedTrainId = v),
                                    ),
                                  ),
                                  flex: 2,
                                ),
                              ]),
                            ]),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ── PASSENGER TABLE ─────────────────────────────
                        Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Table header row
                              Container(
                                color: _titleColor,
                                child: Row(children: [
                                  _th('Date', flex: 2),
                                  _th('Passenger Name', flex: 3),
                                  _th('PNR No', flex: 2),
                                  _th('Mobile No', flex: 2),
                                  _th('Coach', flex: 1),
                                  _th('Seat', flex: 1),
                                  _th('PSI', flex: 1),
                                  _th('Feedback', flex: 2),
                                  const SizedBox(width: 32), // delete col
                                ]),
                              ),
                              // Data rows
                              ...List.generate(_rows.length, (i) => _buildRow(i)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Add Row button
                        if (!_isEditMode)
                          OutlinedButton.icon(
                            onPressed: _addRow,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Row'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _titleColor,
                              side: const BorderSide(color: _titleColor),
                            ),
                          ),

                        const SizedBox(height: 80), // space for bottom bar
                      ],
                    ),
                  ),
                ),

                // ── Bottom save bar ─────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      if (!_isEditMode)
                        Text('${_rows.length} passenger(s)',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _titleColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Text(
                          _isEditMode ? 'Update Record' : 'Save All Records',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _th(String label, {int flex = 1}) => Expanded(
    flex: flex,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildRow(int i) {
    final row = _rows[i];
    final bg = i.isEven ? Colors.white : const Color(0xFFF5F9FF);
    return Container(
      color: bg,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDDDDDD))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Date
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _pickRowDate(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(DateFormat('dd-MM-yyyy').format(row.date),
                    style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
          _rowCell(row.name, flex: 3),
          _rowCell(row.pnr, keyboardType: TextInputType.number, flex: 2),
          _rowCell(row.mobile, keyboardType: TextInputType.phone, flex: 2),
          _rowCell(row.coach, flex: 1),
          _rowCell(row.seat, flex: 1),
          _rowCell(row.psi, keyboardType: TextInputType.number, flex: 1),
          _rowCell(row.feedback, flex: 2),
          // Delete
          SizedBox(
            width: 32,
            child: _rows.length > 1
                ? IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _removeRow(i),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _rowCell(TextEditingController ctrl, {int flex = 1, TextInputType? keyboardType}) {
    return Expanded(
      flex: flex,
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 12),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2196F3), width: 1.5),
          ),
        ),
      ),
    );
  }
}
