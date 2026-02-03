class ContractDocument {
  const ContractDocument({
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
    required this.contractDocxUrl,
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
  final String? contractDocxUrl;

  factory ContractDocument.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic value) {
      if (value is num) {
        return value;
      }
      if (value is String) {
        return num.tryParse(value.replaceAll(',', '.'));
      }
      return null;
    }

    int? parseInt(dynamic value) {
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    bool parseBool(dynamic value) {
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        final normalized = value.toLowerCase().trim();
        return normalized == 'true' || normalized == '1' || normalized == 'yes';
      }
      return false;
    }

    return ContractDocument(
      contractNumber: json['contract_number']?.toString() ?? '',
      bikeSerial: json['bike_serial']?.toString() ?? '',
      akb1Serial: json['akb1_serial']?.toString() ?? '',
      akb2Serial: json['akb2_serial']?.toString() ?? '',
      akb3Serial: json['akb3_serial']?.toString() ?? '',
      amount: parseNum(json['amount']) ?? 0,
      amountText: json['amount_text']?.toString() ?? '',
      weeksCount: parseInt(json['weeks_count']) ?? 0,
      filledDate: json['filled_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      inn: json['inn']?.toString() ?? '',
      registrationAddress: json['registration_address']?.toString() ?? '',
      residentialAddress: json['residential_address']?.toString() ?? '',
      passport: json['passport']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      bankAccount: json['bank_account']?.toString() ?? '',
      id: parseInt(json['id']) ?? 0,
      status: json['status']?.toString() ?? '',
      rejectionReason: json['rejection_reason']?.toString(),
      active: parseBool(json['active']),
      contractText: json['contract_text']?.toString(),
      contractDocxUrl: json['contract_docx_url']?.toString(),
    );
  }
}