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
    );
  }
}
