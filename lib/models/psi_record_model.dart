class PSIRecord {
  final String? id;
  final String userId; // User ID who created this record
  final String trainId;
  final String trainNo;
  final String trainName;
  final String scheduleId;
  final String tripId;
  final DateTime date;
  final String passengerName;
  final String pnrNo;
  final String mobileNo;
  final String coach;
  final String seatNo;
  final double psiScore; // PSI score (0-100)
  final String? feedback;
  final String tripType; // 'Going' or 'Coming'
  final String ehkName; // EHK (Employee) Name - e.g., "Dharmander Kumar"
  final String? companyName; // Company Name - e.g., "R. N. INDUSTRIES"
  final String? importBatchId; // Unique ID for each import session to track records from same import
  
  // Service ratings (for AC coaches - 5 services)
  final String? service1Rating; // Toiletries availability
  final String? service2Rating; // Passenger compartment cleaning
  final String? service3Rating; // Garbage collection
  final String? service4Rating; // Mosquito/Cockroach repellent
  final String? service5Rating; // Behaviour/Response of staff
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  PSIRecord({
    this.id,
    required this.userId,
    required this.trainId,
    required this.trainNo,
    required this.trainName,
    required this.scheduleId,
    required this.tripId,
    required this.date,
    required this.passengerName,
    required this.pnrNo,
    required this.mobileNo,
    required this.coach,
    required this.seatNo,
    required this.psiScore,
    this.feedback,
    required this.tripType,
    required this.ehkName,
    this.companyName,
    this.importBatchId,
    this.service1Rating,
    this.service2Rating,
    this.service3Rating,
    this.service4Rating,
    this.service5Rating,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'train_id': trainId.isEmpty ? null : trainId,
      'train_no': trainNo,
      'train_name': trainName,
      'schedule_id': scheduleId.isEmpty ? null : scheduleId,
      'trip_id': tripId,
      'date': date.toIso8601String(),
      'passenger_name': passengerName,
      'pnr_no': pnrNo,
      'mobile_no': mobileNo,
      'coach': coach,
      'seat_no': seatNo,
      'psi_score': psiScore,
      'feedback': feedback,
      'trip_type': tripType,
      'ehk_name': ehkName,
      'company_name': companyName,
      'import_batch_id': importBatchId,
      'service1_rating': service1Rating,
      'service2_rating': service2Rating,
      'service3_rating': service3Rating,
      'service4_rating': service4Rating,
      'service5_rating': service5Rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory PSIRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return PSIRecord(
      id: documentId,
      userId: map['user_id'] ?? '',
      trainId: map['train_id'] ?? '',
      trainNo: map['train_no'] ?? '',
      trainName: map['train_name'] ?? '',
      scheduleId: map['schedule_id'] ?? '',
      tripId: map['trip_id'] ?? '',
      date: DateTime.parse(map['date']),
      passengerName: map['passenger_name'] ?? '',
      pnrNo: map['pnr_no'] ?? '',
      mobileNo: map['mobile_no'] ?? '',
      coach: map['coach'] ?? '',
      seatNo: map['seat_no'] ?? '',
      psiScore: (map['psi_score'] ?? 0).toDouble(),
      feedback: map['feedback'],
      tripType: map['trip_type'] ?? 'Going',
      ehkName: map['ehk_name'] ?? '',
      companyName: map['company_name'],
      importBatchId: map['import_batch_id'],
      service1Rating: map['service1_rating'],
      service2Rating: map['service2_rating'],
      service3Rating: map['service3_rating'],
      service4Rating: map['service4_rating'],
      service5Rating: map['service5_rating'],
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  PSIRecord copyWith({
    String? id,
    String? userId,
    String? trainId,
    String? trainNo,
    String? trainName,
    String? scheduleId,
    String? tripId,
    DateTime? date,
    String? passengerName,
    String? pnrNo,
    String? mobileNo,
    String? coach,
    String? seatNo,
    double? psiScore,
    String? feedback,
    String? tripType,
    String? ehkName,
    String? companyName,
    String? importBatchId,
    String? service1Rating,
    String? service2Rating,
    String? service3Rating,
    String? service4Rating,
    String? service5Rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PSIRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trainId: trainId ?? this.trainId,
      trainNo: trainNo ?? this.trainNo,
      trainName: trainName ?? this.trainName,
      scheduleId: scheduleId ?? this.scheduleId,
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      passengerName: passengerName ?? this.passengerName,
      pnrNo: pnrNo ?? this.pnrNo,
      mobileNo: mobileNo ?? this.mobileNo,
      coach: coach ?? this.coach,
      seatNo: seatNo ?? this.seatNo,
      psiScore: psiScore ?? this.psiScore,
      feedback: feedback ?? this.feedback,
      tripType: tripType ?? this.tripType,
      ehkName: ehkName ?? this.ehkName,
      companyName: companyName ?? this.companyName,
      importBatchId: importBatchId ?? this.importBatchId,
      service1Rating: service1Rating ?? this.service1Rating,
      service2Rating: service2Rating ?? this.service2Rating,
      service3Rating: service3Rating ?? this.service3Rating,
      service4Rating: service4Rating ?? this.service4Rating,
      service5Rating: service5Rating ?? this.service5Rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
