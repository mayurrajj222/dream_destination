import 'package:cloud_firestore/cloud_firestore.dart';

class Train {
  final String? id;
  final String trainNoGoing;
  final String trainNameGoing;
  final String stationFrom;
  final String stationTo;
  final int totalJanitor;
  final String departureTimeGoing; // Format: HH:MM:SS
  final String journeyDurationGoing; // Format: HH:MM:SS
  final String trainNoComing;
  final String trainNameComing;
  final String departureTimeComing; // Format: HH:MM:SS
  final String journeyDurationComing; // Format: HH:MM:SS
  
  // Going On days
  final bool goingOnMon;
  final bool goingOnTue;
  final bool goingOnWed;
  final bool goingOnThu;
  final bool goingOnFri;
  final bool goingOnSat;
  final bool goingOnSun;
  
  // Coming On days
  final bool comingOnMon;
  final bool comingOnTue;
  final bool comingOnWed;
  final bool comingOnThu;
  final bool comingOnFri;
  final bool comingOnSat;
  final bool comingOnSun;
  
  // Coaches Details
  final bool coachWGFACC; // WGF ACC W - H A H1 - AC 1st Tier
  final bool coachWGACCWA1; // WGACCW(A1) - AC 2 Tier
  final bool coachWGACCNB1; // WGACCN(B1) - AC 3 Tier
  final bool coachWGSCNSL; // WGSCN SL (SL) - Sleeper
  final bool coachWGCZAC; // WGCZAC(CC) - AC Chair Car
  final bool coachWGSCZD; // WGSCZ(D) - Chair Car
  final bool coachLWFCZAC; // LWFCZAC (E) - Shatabdi 2nd Tier
  final bool coachWGFCNAC; // WGFCNAC (HB) - Shatabdi 1st Tier
  final bool coachM1; // M1 Coach
  final bool coachCE; // CE Coach
  final bool coachGS; // GS - General Class
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Train({
    this.id,
    required this.trainNoGoing,
    required this.trainNameGoing,
    required this.stationFrom,
    required this.stationTo,
    required this.totalJanitor,
    required this.departureTimeGoing,
    required this.journeyDurationGoing,
    required this.trainNoComing,
    required this.trainNameComing,
    required this.departureTimeComing,
    required this.journeyDurationComing,
    this.goingOnMon = false,
    this.goingOnTue = false,
    this.goingOnWed = false,
    this.goingOnThu = false,
    this.goingOnFri = false,
    this.goingOnSat = false,
    this.goingOnSun = false,
    this.comingOnMon = false,
    this.comingOnTue = false,
    this.comingOnWed = false,
    this.comingOnThu = false,
    this.comingOnFri = false,
    this.comingOnSat = false,
    this.comingOnSun = false,
    this.coachWGFACC = false,
    this.coachWGACCWA1 = false,
    this.coachWGACCNB1 = false,
    this.coachWGSCNSL = false,
    this.coachWGCZAC = false,
    this.coachWGSCZD = false,
    this.coachLWFCZAC = false,
    this.coachWGFCNAC = false,
    this.coachM1 = false,
    this.coachCE = false,
    this.coachGS = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'trainNoGoing': trainNoGoing,
      'trainNameGoing': trainNameGoing,
      'stationFrom': stationFrom,
      'stationTo': stationTo,
      'totalJanitor': totalJanitor,
      'departureTimeGoing': departureTimeGoing,
      'journeyDurationGoing': journeyDurationGoing,
      'trainNoComing': trainNoComing,
      'trainNameComing': trainNameComing,
      'departureTimeComing': departureTimeComing,
      'journeyDurationComing': journeyDurationComing,
      'goingOnMon': goingOnMon,
      'goingOnTue': goingOnTue,
      'goingOnWed': goingOnWed,
      'goingOnThu': goingOnThu,
      'goingOnFri': goingOnFri,
      'goingOnSat': goingOnSat,
      'goingOnSun': goingOnSun,
      'comingOnMon': comingOnMon,
      'comingOnTue': comingOnTue,
      'comingOnWed': comingOnWed,
      'comingOnThu': comingOnThu,
      'comingOnFri': comingOnFri,
      'comingOnSat': comingOnSat,
      'comingOnSun': comingOnSun,
      'coachWGFACC': coachWGFACC,
      'coachWGACCWA1': coachWGACCWA1,
      'coachWGACCNB1': coachWGACCNB1,
      'coachWGSCNSL': coachWGSCNSL,
      'coachWGCZAC': coachWGCZAC,
      'coachWGSCZD': coachWGSCZD,
      'coachLWFCZAC': coachLWFCZAC,
      'coachWGFCNAC': coachWGFCNAC,
      'coachM1': coachM1,
      'coachCE': coachCE,
      'coachGS': coachGS,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Train.fromMap(Map<String, dynamic> map, String documentId) {
    return Train(
      id: documentId,
      trainNoGoing: map['trainNoGoing'] ?? '',
      trainNameGoing: map['trainNameGoing'] ?? '',
      stationFrom: map['stationFrom'] ?? '',
      stationTo: map['stationTo'] ?? '',
      totalJanitor: map['totalJanitor'] ?? 0,
      departureTimeGoing: map['departureTimeGoing'] ?? '00:00:00',
      journeyDurationGoing: map['journeyDurationGoing'] ?? '00:00:00',
      trainNoComing: map['trainNoComing'] ?? '',
      trainNameComing: map['trainNameComing'] ?? '',
      departureTimeComing: map['departureTimeComing'] ?? '00:00:00',
      journeyDurationComing: map['journeyDurationComing'] ?? '00:00:00',
      goingOnMon: map['goingOnMon'] ?? false,
      goingOnTue: map['goingOnTue'] ?? false,
      goingOnWed: map['goingOnWed'] ?? false,
      goingOnThu: map['goingOnThu'] ?? false,
      goingOnFri: map['goingOnFri'] ?? false,
      goingOnSat: map['goingOnSat'] ?? false,
      goingOnSun: map['goingOnSun'] ?? false,
      comingOnMon: map['comingOnMon'] ?? false,
      comingOnTue: map['comingOnTue'] ?? false,
      comingOnWed: map['comingOnWed'] ?? false,
      comingOnThu: map['comingOnThu'] ?? false,
      comingOnFri: map['comingOnFri'] ?? false,
      comingOnSat: map['comingOnSat'] ?? false,
      comingOnSun: map['comingOnSun'] ?? false,
      coachWGFACC: map['coachWGFACC'] ?? false,
      coachWGACCWA1: map['coachWGACCWA1'] ?? false,
      coachWGACCNB1: map['coachWGACCNB1'] ?? false,
      coachWGSCNSL: map['coachWGSCNSL'] ?? false,
      coachWGCZAC: map['coachWGCZAC'] ?? false,
      coachWGSCZD: map['coachWGSCZD'] ?? false,
      coachLWFCZAC: map['coachLWFCZAC'] ?? false,
      coachWGFCNAC: map['coachWGFCNAC'] ?? false,
      coachM1: map['coachM1'] ?? false,
      coachCE: map['coachCE'] ?? false,
      coachGS: map['coachGS'] ?? false,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Train copyWith({
    String? id,
    String? trainNoGoing,
    String? trainNameGoing,
    String? stationFrom,
    String? stationTo,
    int? totalJanitor,
    String? departureTimeGoing,
    String? journeyDurationGoing,
    String? trainNoComing,
    String? trainNameComing,
    String? departureTimeComing,
    String? journeyDurationComing,
    bool? goingOnMon,
    bool? goingOnTue,
    bool? goingOnWed,
    bool? goingOnThu,
    bool? goingOnFri,
    bool? goingOnSat,
    bool? goingOnSun,
    bool? comingOnMon,
    bool? comingOnTue,
    bool? comingOnWed,
    bool? comingOnThu,
    bool? comingOnFri,
    bool? comingOnSat,
    bool? comingOnSun,
    bool? coachWGFACC,
    bool? coachWGACCWA1,
    bool? coachWGACCNB1,
    bool? coachWGSCNSL,
    bool? coachWGCZAC,
    bool? coachWGSCZD,
    bool? coachLWFCZAC,
    bool? coachWGFCNAC,
    bool? coachM1,
    bool? coachCE,
    bool? coachGS,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Train(
      id: id ?? this.id,
      trainNoGoing: trainNoGoing ?? this.trainNoGoing,
      trainNameGoing: trainNameGoing ?? this.trainNameGoing,
      stationFrom: stationFrom ?? this.stationFrom,
      stationTo: stationTo ?? this.stationTo,
      totalJanitor: totalJanitor ?? this.totalJanitor,
      departureTimeGoing: departureTimeGoing ?? this.departureTimeGoing,
      journeyDurationGoing: journeyDurationGoing ?? this.journeyDurationGoing,
      trainNoComing: trainNoComing ?? this.trainNoComing,
      trainNameComing: trainNameComing ?? this.trainNameComing,
      departureTimeComing: departureTimeComing ?? this.departureTimeComing,
      journeyDurationComing: journeyDurationComing ?? this.journeyDurationComing,
      goingOnMon: goingOnMon ?? this.goingOnMon,
      goingOnTue: goingOnTue ?? this.goingOnTue,
      goingOnWed: goingOnWed ?? this.goingOnWed,
      goingOnThu: goingOnThu ?? this.goingOnThu,
      goingOnFri: goingOnFri ?? this.goingOnFri,
      goingOnSat: goingOnSat ?? this.goingOnSat,
      goingOnSun: goingOnSun ?? this.goingOnSun,
      comingOnMon: comingOnMon ?? this.comingOnMon,
      comingOnTue: comingOnTue ?? this.comingOnTue,
      comingOnWed: comingOnWed ?? this.comingOnWed,
      comingOnThu: comingOnThu ?? this.comingOnThu,
      comingOnFri: comingOnFri ?? this.comingOnFri,
      comingOnSat: comingOnSat ?? this.comingOnSat,
      comingOnSun: comingOnSun ?? this.comingOnSun,
      coachWGFACC: coachWGFACC ?? this.coachWGFACC,
      coachWGACCWA1: coachWGACCWA1 ?? this.coachWGACCWA1,
      coachWGACCNB1: coachWGACCNB1 ?? this.coachWGACCNB1,
      coachWGSCNSL: coachWGSCNSL ?? this.coachWGSCNSL,
      coachWGCZAC: coachWGCZAC ?? this.coachWGCZAC,
      coachWGSCZD: coachWGSCZD ?? this.coachWGSCZD,
      coachLWFCZAC: coachLWFCZAC ?? this.coachLWFCZAC,
      coachWGFCNAC: coachWGFCNAC ?? this.coachWGFCNAC,
      coachM1: coachM1 ?? this.coachM1,
      coachCE: coachCE ?? this.coachCE,
      coachGS: coachGS ?? this.coachGS,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
