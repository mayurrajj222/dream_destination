// import 'package:cloud_firestore/cloud_firestore.dart'; // TODO: Migrate to Supabase

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
      'train_no_going': trainNoGoing,
      'train_name_going': trainNameGoing,
      'station_from': stationFrom,
      'station_to': stationTo,
      'total_janitor': totalJanitor,
      'departure_time_going': departureTimeGoing,
      'journey_duration_going': journeyDurationGoing,
      'train_no_coming': trainNoComing,
      'train_name_coming': trainNameComing,
      'departure_time_coming': departureTimeComing,
      'journey_duration_coming': journeyDurationComing,
      'going_on_mon': goingOnMon,
      'going_on_tue': goingOnTue,
      'going_on_wed': goingOnWed,
      'going_on_thu': goingOnThu,
      'going_on_fri': goingOnFri,
      'going_on_sat': goingOnSat,
      'going_on_sun': goingOnSun,
      'coming_on_mon': comingOnMon,
      'coming_on_tue': comingOnTue,
      'coming_on_wed': comingOnWed,
      'coming_on_thu': comingOnThu,
      'coming_on_fri': comingOnFri,
      'coming_on_sat': comingOnSat,
      'coming_on_sun': comingOnSun,
      'coach_wgfacc': coachWGFACC,
      'coach_wgaccwa1': coachWGACCWA1,
      'coach_wgaccnb1': coachWGACCNB1,
      'coach_wgscnsl': coachWGSCNSL,
      'coach_wgczac': coachWGCZAC,
      'coach_wgsczd': coachWGSCZD,
      'coach_lwfczac': coachLWFCZAC,
      'coach_wgfcnac': coachWGFCNAC,
      'coach_m1': coachM1,
      'coach_ce': coachCE,
      'coach_gs': coachGS,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory Train.fromMap(Map<String, dynamic> map, String documentId) {
    return Train(
      id: documentId,
      trainNoGoing: map['train_no_going'] ?? '',
      trainNameGoing: map['train_name_going'] ?? '',
      stationFrom: map['station_from'] ?? '',
      stationTo: map['station_to'] ?? '',
      totalJanitor: map['total_janitor'] ?? 0,
      departureTimeGoing: map['departure_time_going'] ?? '00:00:00',
      journeyDurationGoing: map['journey_duration_going'] ?? '00:00:00',
      trainNoComing: map['train_no_coming'] ?? '',
      trainNameComing: map['train_name_coming'] ?? '',
      departureTimeComing: map['departure_time_coming'] ?? '00:00:00',
      journeyDurationComing: map['journey_duration_coming'] ?? '00:00:00',
      goingOnMon: map['going_on_mon'] ?? false,
      goingOnTue: map['going_on_tue'] ?? false,
      goingOnWed: map['going_on_wed'] ?? false,
      goingOnThu: map['going_on_thu'] ?? false,
      goingOnFri: map['going_on_fri'] ?? false,
      goingOnSat: map['going_on_sat'] ?? false,
      goingOnSun: map['going_on_sun'] ?? false,
      comingOnMon: map['coming_on_mon'] ?? false,
      comingOnTue: map['coming_on_tue'] ?? false,
      comingOnWed: map['coming_on_wed'] ?? false,
      comingOnThu: map['coming_on_thu'] ?? false,
      comingOnFri: map['coming_on_fri'] ?? false,
      comingOnSat: map['coming_on_sat'] ?? false,
      comingOnSun: map['coming_on_sun'] ?? false,
      coachWGFACC: map['coach_wgfacc'] ?? false,
      coachWGACCWA1: map['coach_wgaccwa1'] ?? false,
      coachWGACCNB1: map['coach_wgaccnb1'] ?? false,
      coachWGSCNSL: map['coach_wgscnsl'] ?? false,
      coachWGCZAC: map['coach_wgczac'] ?? false,
      coachWGSCZD: map['coach_wgsczd'] ?? false,
      coachLWFCZAC: map['coach_lwfczac'] ?? false,
      coachWGFCNAC: map['coach_wgfcnac'] ?? false,
      coachM1: map['coach_m1'] ?? false,
      coachCE: map['coach_ce'] ?? false,
      coachGS: map['coach_gs'] ?? false,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
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
