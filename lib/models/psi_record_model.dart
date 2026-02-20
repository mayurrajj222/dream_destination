import 'package:cloud_firestore/cloud_firestore.dart';

class PSIRecord {
  final String? id;
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
  final String ehkName; // EHK (Employee) Name
  
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
      'trainId': trainId,
      'trainNo': trainNo,
      'trainName': trainName,
      'scheduleId': scheduleId,
      'tripId': tripId,
      'date': Timestamp.fromDate(date),
      'passengerName': passengerName,
      'pnrNo': pnrNo,
      'mobileNo': mobileNo,
      'coach': coach,
      'seatNo': seatNo,
      'psiScore': psiScore,
      'feedback': feedback,
      'tripType': tripType,
      'ehkName': ehkName,
      'service1Rating': service1Rating,
      'service2Rating': service2Rating,
      'service3Rating': service3Rating,
      'service4Rating': service4Rating,
      'service5Rating': service5Rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory PSIRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return PSIRecord(
      id: documentId,
      trainId: map['trainId'] ?? '',
      trainNo: map['trainNo'] ?? '',
      trainName: map['trainName'] ?? '',
      scheduleId: map['scheduleId'] ?? '',
      tripId: map['tripId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      passengerName: map['passengerName'] ?? '',
      pnrNo: map['pnrNo'] ?? '',
      mobileNo: map['mobileNo'] ?? '',
      coach: map['coach'] ?? '',
      seatNo: map['seatNo'] ?? '',
      psiScore: (map['psiScore'] ?? 0).toDouble(),
      feedback: map['feedback'],
      tripType: map['tripType'] ?? 'Going',
      ehkName: map['ehkName'] ?? '',
      service1Rating: map['service1Rating'],
      service2Rating: map['service2Rating'],
      service3Rating: map['service3Rating'],
      service4Rating: map['service4Rating'],
      service5Rating: map['service5Rating'],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  PSIRecord copyWith({
    String? id,
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
