import 'document.dart';

class UserSummary {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final DocumentStatus? documentStatus;

  const UserSummary({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.documentStatus,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String,
      documentStatus: json['document_status'] != null
          ? parseStatus(json['document_status'] as String)
          : null,
    );
  }
}
