import 'user_profile.dart';

/// Shared helper to safely parse an integer from dynamic API values.
int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse('$value') ?? 0;
}

class PatientSummary {
  const PatientSummary({
    required this.id,
    required this.fullName,
    required this.medicalRecordNumber,
    required this.treatmentDay,
    required this.adherencePercent,
    required this.riskStatus,
    required this.badge,
    this.phase = 'Intensif',
  });

  final String id;
  final String fullName;
  final String medicalRecordNumber;
  final int treatmentDay;
  final int adherencePercent;
  final String riskStatus;
  final String badge;
  final String phase;

  factory PatientSummary.fromJson(Map<String, dynamic> json) {
    return PatientSummary(
      id: json['patientProfileId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Pasien tanpa nama',
      medicalRecordNumber: json['medicalRecordNumber']?.toString() ?? '',
      treatmentDay: _asInt(json['treatmentDay']),
      adherencePercent: _asInt(json['adherencePercent']),
      riskStatus: _parseRisk(json['currentRisk']),
      badge: json['badge']?.toString() ?? '',
      phase: json['phase']?.toString() ?? 'Intensif',
    );
  }

  String get treatmentLabel {
    if (treatmentDay <= 0) return 'Hari pengobatan belum diatur';
    return 'Hari ke-$treatmentDay';
  }

  String get adherenceLabel => '$adherencePercent%';

  String get riskLabel {
    switch (riskStatus.toLowerCase()) {
      case 'high':
        return 'Risiko tinggi';
      case 'moderate':
        return 'Risiko sedang';
      case 'low':
        return 'Stabil';
      default:
        return 'Perlu data';
    }
  }

  static String _parseRisk(dynamic risk) {
    if (risk == null) return 'low';
    final val = risk.toString().toLowerCase();
    if (val == '1' || val == 'low') return 'low';
    if (val == '2' || val == 'moderate') return 'moderate';
    if (val == '3' || val == 'high') return 'high';
    return 'low';
  }
}

class TreatmentSummary {
  const TreatmentSummary({
    required this.treatmentDay,
    required this.totalDays,
    required this.completionPercent,
    required this.adherencePercent,
    required this.streakDays,
    required this.phase,
    required this.medicineSummary,
    required this.nextDoseLabel,
  });

  final int treatmentDay;
  final int totalDays;
  final int completionPercent;
  final int adherencePercent;
  final int streakDays;
  final String phase;
  final String medicineSummary;
  final String nextDoseLabel;

  int get streak => streakDays;

  factory TreatmentSummary.fromJson(Map<String, dynamic> json) {
    return TreatmentSummary(
      treatmentDay: _asInt(json['treatmentDay']),
      totalDays: _asInt(json['totalDays']),
      completionPercent: _asInt(json['completionPercent']),
      adherencePercent: _asInt(json['adherencePercent']),
      streakDays: _asInt(json['streakDays']),
      phase: json['phase']?.toString() ?? 'Intensif',
      medicineSummary: json['medicineSummary']?.toString() ?? '',
      nextDoseLabel: json['nextDoseLabel']?.toString() ?? '',
    );
  }
}

class PatientDashboardData {
  const PatientDashboardData({
    required this.profile, 
    this.treatment,
    this.doctorName,
    this.medicalRecordNumber,
    this.weight,
    this.comorbidities,
  });

  final UserProfile profile;
  final TreatmentSummary? treatment;
  final String? doctorName;
  final String? medicalRecordNumber;
  final double? weight;
  final String? comorbidities;
}

class MedicationLogEntry {
  const MedicationLogEntry({
    required this.title,
    required this.status,
    required this.createdAt,
  });

  final String title;
  final String status;
  final DateTime? createdAt;

  factory MedicationLogEntry.fromJson(Map<String, dynamic> json) {
    return MedicationLogEntry(
      title: json['title'] as String? ?? 'Catatan pengobatan',
      status: json['type'] as String? ?? 'info',
      createdAt: DateTime.tryParse('${json['createdAt']}'),
    );
  }
}

class NotificationEntryData {
  const NotificationEntryData({
    this.id = '',
    required this.type,
    required this.title,
    required this.body,
    required this.status,
    required this.severity,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String status;
  final String severity;
  final bool isRead;
  final DateTime? createdAt;

  factory NotificationEntryData.fromJson(Map<String, dynamic> json) {
    return NotificationEntryData(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString().toLowerCase() ?? 'reminder',
      title: json['title'] as String? ?? json['patientName'] as String? ?? 'Notifikasi',
      body: json['message'] as String? ?? '',
      status: json['status']?.toString() ?? 'Info',
      severity: json['severity']?.toString() ?? 'normal',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse('${json['createdAt'] ?? json['scheduledAt']}'),
    );
  }
}
