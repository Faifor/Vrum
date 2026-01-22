import 'document.dart';

class AdminUserDetails {
  final int id;
  final String email;
  final String? fullName;
  final String inn;
  final String registrationAddress;
  final String residentialAddress;
  final String passport;
  final String phone;
  final String bankAccount;
  final String role;
  final DocumentStatus status;
  final String? rejectionReason;

  const AdminUserDetails({
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
    required this.status,
    this.rejectionReason,
  });

  factory AdminUserDetails.fromJson(Map<String, dynamic> json) {
    String? fullName;
    if (json['full_name'] is String) {
      fullName = json['full_name'] as String;
    } else if (json['first_name'] is String || json['last_name'] is String) {
      final first = (json['first_name'] as String?) ?? '';
      final last = (json['last_name'] as String?) ?? '';
      fullName = '$first $last'.trim();
    }
    return AdminUserDetails(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      fullName: fullName?.isEmpty ?? true ? null : fullName,
      inn: json['inn']?.toString() ?? '',
      registrationAddress: json['registration_address'] as String? ?? '',
      residentialAddress: json['residential_address'] as String? ?? '',
      passport: json['passport']?.toString() ?? '',
      phone: json['phone'] as String? ?? '',
      bankAccount: json['bank_account']?.toString() ?? '',
      role: json['role'] as String? ?? '',
      status: parseStatus(json['status'] as String?),
      rejectionReason: json['rejection_reason'] as String?,
    );
  }
}