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
  final String address;
  final String passport;
  final String phone;
  final String? bankAccount;
  final String? contractNumber;
  final String? bikeSerial;
  final String? akb1Serial;
  final String? akb2Serial;
  final String? akb3Serial;
  final String? amount;
  final String? amountText;
  final int? weeksCount;
  final String? filledDate;
  final String? endDate;
  final DocumentStatus status;
  final String? rejectionReason;
  final String? contractText;

  const UserDocument({
    this.id,
    required this.fullName,
    required this.address,
    required this.passport,
    required this.phone,
    this.bankAccount,
    this.contractNumber,
    this.bikeSerial,
    this.akb1Serial,
    this.akb2Serial,
    this.akb3Serial,
    this.amount,
    this.amountText,
    this.weeksCount,
    this.filledDate,
    this.endDate,
    this.status = DocumentStatus.draft,
    this.rejectionReason,
    this.contractText,
  });

  factory UserDocument.empty() {
    return const UserDocument(
      fullName: '',
      address: '',
      passport: '',
      phone: '',
      status: DocumentStatus.draft,
    );
  }

  factory UserDocument.fromJson(Map<String, dynamic> json) {
    return UserDocument(
      id: json['id'] as int?,
      fullName: json['full_name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      passport: json['passport'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      bankAccount: json['bank_account'] as String?,
      contractNumber: json['contract_number'] as String?,
      bikeSerial: json['bike_serial'] as String?,
      akb1Serial: json['akb1_serial'] as String?,
      akb2Serial: json['akb2_serial'] as String?,
      akb3Serial: json['akb3_serial'] as String?,
      amount: json['amount'] as String?,
      amountText: json['amount_text'] as String?,
      weeksCount: json['weeks_count'] as int?,
      filledDate: json['filled_date'] as String?,
      endDate: json['end_date'] as String?,
      status: parseStatus(json['status'] as String?),
      rejectionReason: json['rejection_reason'] as String?,
      contractText: json['contract_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'address': address,
      'passport': passport,
      'phone': phone,
      'bank_account': bankAccount,
      'contract_number': contractNumber,
      'bike_serial': bikeSerial,
      'akb1_serial': akb1Serial,
      'akb2_serial': akb2Serial,
      'akb3_serial': akb3Serial,
      'amount': amount,
      'amount_text': amountText,
      'weeks_count': weeksCount,
      'filled_date': filledDate,
      'end_date': endDate,
    };
  }

  UserDocument copyWith({
    int? id,
    String? fullName,
    String? address,
    String? passport,
    String? phone,
    String? bankAccount,
    String? contractNumber,
    String? bikeSerial,
    String? akb1Serial,
    String? akb2Serial,
    String? akb3Serial,
    String? amount,
    String? amountText,
    int? weeksCount,
    String? filledDate,
    String? endDate,
    DocumentStatus? status,
    String? rejectionReason,
    String? contractText,
  }) {
    return UserDocument(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      passport: passport ?? this.passport,
      phone: phone ?? this.phone,
      bankAccount: bankAccount ?? this.bankAccount,
      contractNumber: contractNumber ?? this.contractNumber,
      bikeSerial: bikeSerial ?? this.bikeSerial,
      akb1Serial: akb1Serial ?? this.akb1Serial,
      akb2Serial: akb2Serial ?? this.akb2Serial,
      akb3Serial: akb3Serial ?? this.akb3Serial,
      amount: amount ?? this.amount,
      amountText: amountText ?? this.amountText,
      weeksCount: weeksCount ?? this.weeksCount,
      filledDate: filledDate ?? this.filledDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      contractText: contractText ?? this.contractText,
    );
  }
}
