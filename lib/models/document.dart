enum DocumentStatus { draft, pending, approved, rejected }

DocumentStatus parseStatus(String? value) {
  switch (value) {
    case 'pending':
      return DocumentStatus.pending;
    case 'approved':
      return DocumentStatus.approved;
    case 'rejected':
      return DocumentStatus.rejected;
    case 'draft':
    default:
      return DocumentStatus.draft;
  }
}

class UserDocument {
  final int? id;
  final String fullName;
  final String inn;
  final String registrationAddress;
  final String residentialAddress;
  final String passport;
  final String phone;
  final String bankAccount;
  final DocumentStatus status;
  final String? rejectionReason;
  final String? contractText;

  const UserDocument({
    this.id,
    required this.fullName,
    required this.inn,
    required this.registrationAddress,
    required this.residentialAddress,
    required this.passport,
    required this.phone,
    required this.bankAccount,
    this.status = DocumentStatus.draft,
    this.rejectionReason,
    this.contractText,
  });

  factory UserDocument.empty() {
    return const UserDocument(
      fullName: '',
      inn: '',
      registrationAddress: '',
      residentialAddress: '',
      passport: '',
      phone: '',
      bankAccount: '',
      status: DocumentStatus.draft,
    );
  }

  factory UserDocument.fromJson(Map<String, dynamic> json) {
    return UserDocument(
      id: json['id'] as int?,
      fullName: json['full_name'] as String? ?? '',
      inn: json['inn']?.toString() ?? '',
      registrationAddress: json['registration_address'] as String? ?? '',
      residentialAddress: json['residential_address'] as String? ?? '',
      passport: json['passport']?.toString() ?? '',
      phone: json['phone'] as String? ?? '',
      bankAccount: json['bank_account']?.toString() ?? '',
      status: parseStatus(json['status'] as String?),
      rejectionReason: json['rejection_reason'] as String?,
      contractText: json['contract_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'inn': inn,
      'registration_address': registrationAddress,
      'residential_address': residentialAddress,
      'passport': passport,
      'phone': phone,
      'bank_account': bankAccount,
    };
  }

  UserDocument copyWith({
    int? id,
    String? fullName,
    String? inn,
    String? registrationAddress,
    String? residentialAddress,
    String? passport,
    String? phone,
    String? bankAccount,
    DocumentStatus? status,
    String? rejectionReason,
    String? contractText,
  }) {
    return UserDocument(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      inn: inn ?? this.inn,
      registrationAddress: registrationAddress ?? this.registrationAddress,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      passport: passport ?? this.passport,
      phone: phone ?? this.phone,
      bankAccount: bankAccount ?? this.bankAccount,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      contractText: contractText ?? this.contractText,
    );
  }
}
