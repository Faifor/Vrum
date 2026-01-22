import 'document.dart';

class UserProfile {
  final int id;
  final String email;
  final String fullName;
  final String inn;
  final String registrationAddress;
  final String residentialAddress;
  final String passport;
  final String phone;
  final String bankAccount;
  final String role;
  final DocumentStatus? documentStatus;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.inn,
    required this.registrationAddress,
    required this.residentialAddress,
    required this.passport,
    required this.phone,
    required this.bankAccount,
    required this.role,
    this.documentStatus,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      inn: json['inn']?.toString() ?? '',
      registrationAddress: json['registration_address'] as String? ?? '',
      residentialAddress: json['residential_address'] as String? ?? '',
      passport: json['passport']?.toString() ?? '',
      phone: json['phone'] as String? ?? '',
      bankAccount: json['bank_account']?.toString() ?? '',
      role: json['role'] as String? ?? '',
      documentStatus: _parseDocumentStatus(json),
    );
  }

  static DocumentStatus? _parseDocumentStatus(Map<String, dynamic> json) {
    final dynamic statusValue = json['document_status'] ??
        json['status'] ??
        (json['document'] is Map<String, dynamic>
            ? (json['document'] as Map<String, dynamic>)['status']
            : null);

    if (statusValue == null) {
      return null;
    }

    return parseStatusValue(statusValue);
  }
}
