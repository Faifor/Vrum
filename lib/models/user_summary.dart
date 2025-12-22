import 'document.dart';

class UserSummary {
  final int id;
  final String email;
  final String? fullName;
  final String role;
  final DocumentStatus? documentStatus;

  const UserSummary({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.documentStatus,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    String? fullName;
    if (json['full_name'] is String) {
      fullName = json['full_name'] as String;
    } else if (json['first_name'] is String || json['last_name'] is String) {
      final first = (json['first_name'] as String?) ?? '';
      final last = (json['last_name'] as String?) ?? '';
      fullName = '$first $last'.trim();
    }
    return UserSummary(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: fullName?.isEmpty ?? true ? null : fullName,
      role: json['role'] as String,
      documentStatus: json['document_status'] != null
          ? parseStatus(json['document_status'] as String)
          : null,
    );
  }
}
