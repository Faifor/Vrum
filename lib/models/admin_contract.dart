class AdminContractDraft {
  const AdminContractDraft({
    required this.bikeSerial,
    required this.akb1Serial,
    required this.akb2Serial,
    required this.akb3Serial,
    required this.amount,
    required this.weeksCount,
    required this.filledDate,
  });

  final String bikeSerial;
  final String akb1Serial;
  final String akb2Serial;
  final String akb3Serial;
  final num amount;
  final int weeksCount;
  final String filledDate;

  Map<String, dynamic> toJson() {
    return {
      'bike_serial': bikeSerial,
      'akb1_serial': akb1Serial,
      'akb2_serial': akb2Serial,
      'akb3_serial': akb3Serial,
      'amount': amount,
      'weeks_count': weeksCount,
      'filled_date': filledDate,
    };
  }
}

class AdminContract {
  const AdminContract({
    required this.contractNumber,
    required this.bikeSerial,
    required this.akb1Serial,
    required this.akb2Serial,
    required this.akb3Serial,
    required this.amount,
    required this.amountText,
    required this.weeksCount,
    required this.filledDate,
    required this.endDate,
    required this.fullName,
    required this.inn,
    required this.registrationAddress,
    required this.residentialAddress,
    required this.passport,
    required this.phone,
    required this.bankAccount,
    required this.id,
    required this.status,
    required this.rejectionReason,
    required this.active,
    required this.contractText,
  });

  final String contractNumber;
  final String bikeSerial;
  final String akb1Serial;
  final String akb2Serial;
  final String akb3Serial;
  final num amount;
  final String amountText;
  final int weeksCount;
  final String filledDate;
  final String endDate;
  final String fullName;
  final String inn;
  final String registrationAddress;
  final String residentialAddress;
  final String passport;
  final String phone;
  final String bankAccount;
  final int id;
  final String status;
  final String? rejectionReason;
  final bool active;
  final String? contractText;

  factory AdminContract.fromJson(Map<String, dynamic> json) {
    return AdminContract(
      contractNumber: json['contract_number']?.toString() ?? '',
      bikeSerial: json['bike_serial']?.toString() ?? '',
      akb1Serial: json['akb1_serial']?.toString() ?? '',
      akb2Serial: json['akb2_serial']?.toString() ?? '',
      akb3Serial: json['akb3_serial']?.toString() ?? '',
      amount: json['amount'] as num? ?? 0,
      amountText: json['amount_text']?.toString() ?? '',
      weeksCount: (json['weeks_count'] as num?)?.toInt() ?? 0,
      filledDate: json['filled_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      inn: json['inn']?.toString() ?? '',
      registrationAddress: json['registration_address']?.toString() ?? '',
      residentialAddress: json['residential_address']?.toString() ?? '',
      passport: json['passport']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      bankAccount: json['bank_account']?.toString() ?? '',
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      rejectionReason: json['rejection_reason']?.toString(),
      active: json['active'] as bool? ?? false,
      contractText: json['contract_text']?.toString(),
    );
  }
}