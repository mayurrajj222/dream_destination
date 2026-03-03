// import 'package:cloud_firestore/cloud_firestore.dart'; // TODO: Migrate to Supabase

class TripCard {
  final String? id;
  final String tripId;
  final String trainNo;
  final String trainName;
  final String ehkName;
  final DateTime tripStartDate;
  final DateTime tripEndDate;
  final String stationFrom;
  final String stationTo;
  final String division;
  final String activity;
  final DateTime createdAt;

  TripCard({
    this.id,
    required this.tripId,
    required this.trainNo,
    required this.trainName,
    required this.ehkName,
    required this.tripStartDate,
    required this.tripEndDate,
    required this.stationFrom,
    required this.stationTo,
    required this.division,
    required this.activity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'trainNo': trainNo,
      'trainName': trainName,
      'ehkName': ehkName,
      'tripStartDate': tripStartDate.toIso8601String(),
      'tripEndDate': tripEndDate.toIso8601String(),
      'stationFrom': stationFrom,
      'stationTo': stationTo,
      'division': division,
      'activity': activity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TripCard.fromMap(Map<String, dynamic> map, String id) {
    return TripCard(
      id: id,
      tripId: map['tripId'] ?? '',
      trainNo: map['trainNo'] ?? '',
      trainName: map['trainName'] ?? '',
      ehkName: map['ehkName'] ?? '',
      tripStartDate: DateTime.parse(map['tripStartDate']),
      tripEndDate: DateTime.parse(map['tripEndDate']),
      stationFrom: map['stationFrom'] ?? '',
      stationTo: map['stationTo'] ?? '',
      division: map['division'] ?? '',
      activity: map['activity'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
