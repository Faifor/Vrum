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
  final Future<void> Function(UserDocument) onSubmit;

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
    _controllers['inn'] = TextEditingController(text: widget.document.inn);
    _controllers['registration_address'] = TextEditingController(
      text: widget.document.registrationAddress,
    );
    _controllers['residential_address'] = TextEditingController(
      text: widget.document.residentialAddress,
    );
    _controllers['passport'] =
        TextEditingController(text: widget.document.passport);
    _controllers['phone'] =
        TextEditingController(text: widget.document.phone);
    _controllers['bank_account'] =
        TextEditingController(text: widget.document.bankAccount);
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
      case 'inn':
        return widget.document.inn;
      case 'registration_address':
        return widget.document.registrationAddress;
      case 'residential_address':
        return widget.document.residentialAddress;
      case 'passport':
        return widget.document.passport;
      case 'phone':
        return widget.document.phone;
      case 'bank_account':
        return widget.document.bankAccount;
    }
    return '';
  }

  UserDocument _buildDocument() {
    return widget.document.copyWith(
      fullName: _controllers['full_name']!.text,
      inn: _controllers['inn']!.text,
      registrationAddress: _controllers['registration_address']!.text,
      residentialAddress: _controllers['residential_address']!.text,
      passport: _controllers['passport']!.text,
      phone: _controllers['phone']!.text,
      bankAccount: _controllers['bank_account']!.text,
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
              _buildField(
                'inn',
                'ИНН',
                required: true,
                keyboardType: TextInputType.number,
              ),
              _buildField(
                'registration_address',
                'Адрес регистрации',
                required: true,
              ),
              _buildField(
                'residential_address',
                'Адрес проживания',
                required: true,
              ),
              _buildField(
                'passport',
                'Паспорт',
                required: true,
                keyboardType: TextInputType.number,
              ),
              _buildField(
                'phone',
                'Телефон',
                required: true,
                keyboardType: TextInputType.phone,
              ),
              _buildField(
                'bank_account',
                'Банковский счёт',
                required: true,
                keyboardType: TextInputType.number,
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
                            final doc = _buildDocument();
                            await widget.onSaveDraft(doc);
                            await widget.onSubmit(doc);
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
