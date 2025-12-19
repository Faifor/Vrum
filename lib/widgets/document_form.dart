import 'package:flutter/material.dart';

import '../models/document.dart';

class DocumentForm extends StatefulWidget {
  const DocumentForm({
    super.key,
    required this.document,
    required this.onSaveDraft,
    required this.onSubmit,
    this.loading = false,
  });

  final UserDocument document;
  final bool loading;
  final Future<void> Function(UserDocument) onSaveDraft;
  final Future<void> Function() onSubmit;

  @override
  State<DocumentForm> createState() => _DocumentFormState();
}

class _DocumentFormState extends State<DocumentForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(DocumentForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document != widget.document) {
      _syncWithDocument();
    }
  }

  void _initControllers() {
    _controllers['full_name'] =
        TextEditingController(text: widget.document.fullName);
    _controllers['address'] =
        TextEditingController(text: widget.document.address);
    _controllers['passport'] =
        TextEditingController(text: widget.document.passport);
    _controllers['phone'] =
        TextEditingController(text: widget.document.phone);
    _controllers['bank_account'] =
        TextEditingController(text: widget.document.bankAccount ?? '');
    _controllers['contract_number'] =
        TextEditingController(text: widget.document.contractNumber ?? '');
    _controllers['bike_serial'] =
        TextEditingController(text: widget.document.bikeSerial ?? '');
    _controllers['akb1_serial'] =
        TextEditingController(text: widget.document.akb1Serial ?? '');
    _controllers['akb2_serial'] =
        TextEditingController(text: widget.document.akb2Serial ?? '');
    _controllers['akb3_serial'] =
        TextEditingController(text: widget.document.akb3Serial ?? '');
    _controllers['amount'] =
        TextEditingController(text: widget.document.amount ?? '');
    _controllers['amount_text'] =
        TextEditingController(text: widget.document.amountText ?? '');
    _controllers['weeks_count'] = TextEditingController(
      text: widget.document.weeksCount?.toString() ?? '',
    );
    _controllers['filled_date'] =
        TextEditingController(text: widget.document.filledDate ?? '');
    _controllers['end_date'] =
        TextEditingController(text: widget.document.endDate ?? '');
  }

  void _syncWithDocument() {
    for (final entry in _controllers.entries) {
      final value = _valueForKey(entry.key);
      entry.value.text = value ?? '';
    }
  }

  String? _valueForKey(String key) {
    switch (key) {
      case 'full_name':
        return widget.document.fullName;
      case 'address':
        return widget.document.address;
      case 'passport':
        return widget.document.passport;
      case 'phone':
        return widget.document.phone;
      case 'bank_account':
        return widget.document.bankAccount;
      case 'contract_number':
        return widget.document.contractNumber;
      case 'bike_serial':
        return widget.document.bikeSerial;
      case 'akb1_serial':
        return widget.document.akb1Serial;
      case 'akb2_serial':
        return widget.document.akb2Serial;
      case 'akb3_serial':
        return widget.document.akb3Serial;
      case 'amount':
        return widget.document.amount;
      case 'amount_text':
        return widget.document.amountText;
      case 'weeks_count':
        return widget.document.weeksCount?.toString();
      case 'filled_date':
        return widget.document.filledDate;
      case 'end_date':
        return widget.document.endDate;
    }
    return '';
  }

  UserDocument _buildDocument() {
    return widget.document.copyWith(
      fullName: _controllers['full_name']!.text,
      address: _controllers['address']!.text,
      passport: _controllers['passport']!.text,
      phone: _controllers['phone']!.text,
      bankAccount: _controllers['bank_account']!.text,
      contractNumber: _controllers['contract_number']!.text,
      bikeSerial: _controllers['bike_serial']!.text,
      akb1Serial: _controllers['akb1_serial']!.text,
      akb2Serial: _controllers['akb2_serial']!.text,
      akb3Serial: _controllers['akb3_serial']!.text,
      amount: _controllers['amount']!.text,
      amountText: _controllers['amount_text']!.text,
      weeksCount: int.tryParse(_controllers['weeks_count']!.text),
      filledDate: _controllers['filled_date']!.text,
      endDate: _controllers['end_date']!.text,
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildField('full_name', 'ФИО', required: true),
              _buildField('address', 'Адрес', required: true),
              _buildField('passport', 'Паспорт', required: true),
              _buildField('phone', 'Телефон', required: true),
              _buildField('bank_account', 'Банковский счёт'),
              _buildField('contract_number', 'Номер договора'),
              _buildField('bike_serial', 'Серийный номер велосипеда'),
              _buildField('akb1_serial', 'АКБ 1'),
              _buildField('akb2_serial', 'АКБ 2'),
              _buildField('akb3_serial', 'АКБ 3'),
              _buildField('amount', 'Сумма платежа'),
              _buildField('amount_text', 'Сумма прописью'),
              _buildField(
                'weeks_count',
                'Количество недель',
                keyboardType: TextInputType.number,
              ),
              _buildField(
                'filled_date',
                'Дата заполнения (ГГГГ-ММ-ДД)',
              ),
              _buildField(
                'end_date',
                'Дата окончания (ГГГГ-ММ-ДД)',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  onPressed: widget.loading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            await widget.onSaveDraft(_buildDocument());
                          }
                        },
                  label: const Text('Сохранить черновик'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.send_outlined),
                  onPressed: widget.loading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            await widget.onSaveDraft(_buildDocument());
                            await widget.onSubmit();
                          }
                        },
                  label: widget.loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Отправить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String key,
    String label, {
    bool required = false,
    TextInputType? keyboardType,
  }) {
    final controller = _controllers[key]!;
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboardType,
        validator: required
            ? (value) =>
                (value == null || value.isEmpty) ? 'Поле обязательно' : null
            : null,
      ),
    );
  }
}
