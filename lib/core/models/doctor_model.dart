/// Represents a doctor available for patient assignment.
class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.fullName,
    required this.specialty,
    this.email,
  });

  final String id;
  final String fullName;
  final String specialty;
  final String? email;

  /// Construct from Supabase user metadata.
  factory DoctorModel.fromSupabaseUser(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ??
          json['user_metadata']?['full_name'] as String? ??
          'Unknown Doctor',
      specialty: json['specialty'] as String? ??
          json['user_metadata']?['specialty'] as String? ??
          '-',
      email: json['email'] as String?,
    );
  }

  /// Display text for dropdown / selection UI.
  String get displayLabel => '$fullName • $specialty';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
