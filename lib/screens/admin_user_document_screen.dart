import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:vrum/models/admin_contract.dart';
import 'package:vrum/models/admin_user_details.dart';
import 'package:vrum/models/document.dart';
import 'package:vrum/models/user_summary.dart';
import 'package:vrum/providers/admin_provider.dart';
import 'package:vrum/screens/admin_user_contracts_screen.dart';
import 'package:vrum/widgets/status_badge.dart';

class AdminUserDocumentScreen extends StatefulWidget {
  const AdminUserDocumentScreen({super.key, required this.user});

  final UserSummary user;

  @override
  State<AdminUserDocumentScreen> createState() =>
      _AdminUserDocumentScreenState();
}

class _AdminUserDocumentScreenState extends State<AdminUserDocumentScreen> {
  final _reasonController = TextEditingController();
  final _bikeSerialController = TextEditingController();
  final _akb1SerialController = TextEditingController();
  final _akb2SerialController = TextEditingController();
  final _akb3SerialController = TextEditingController();
  final _amountController = TextEditingController();
  final _weeksCountController = TextEditingController();
  final _filledDateController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  AdminContract? _activeContract;
  bool _showContractForm = true;
  bool _submittingContract = false;
  DateTime? _filledDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<AdminProvider>();
        provider.fetchUserDetails(widget.user.id);
      }
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _bikeSerialController.dispose();
    _akb1SerialController.dispose();
    _akb2SerialController.dispose();
    _akb3SerialController.dispose();
    _amountController.dispose();
    _weeksCountController.dispose();
    _filledDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          final userDetails = provider.selectedUser;
          final isLoading = provider.loading && userDetails == null;
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.user.fullName ?? widget.user.email),
            ),
            body: TabBarView(
              children: [
                _buildInfoTab(context, provider, userDetails, isLoading),
                _buildContractTab(context, provider, userDetails, isLoading),
              ],
            ),
            bottomNavigationBar: Material(
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                top: false,
                child: TabBar(
                  labelColor: Theme.of(context).colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Информация'),
                    Tab(text: 'Договор'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTab(
    BuildContext context,
    AdminProvider provider,
    AdminUserDetails? userDetails,
    bool isLoading,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (provider.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              provider.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(),
          ),
        if (userDetails != null) ...[
          _UserInfoCard(
            user: userDetails,
            status: userDetails.status,
            reasonController: _reasonController,
            onApprove: provider.loading
                ? null
                : () async {
                    await provider.approve(widget.user.id);
                    await provider.fetchUserDetails(widget.user.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Документ одобрен')),
                      );
                    }
                  },
            onReject: provider.loading
                ? null
                : () async {
                    final reason = _reasonController.text.trim();
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Укажите комментарий для отклонения',
                          ),
                        ),
                      );
                      return;
                    }
                    await provider.reject(widget.user.id, reason);
                    await provider.fetchUserDetails(widget.user.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Документ отклонён')),
                      );
                    }
                  },
          ),
        ] else if (!isLoading)
          const Text('Данные пользователя не найдены.'),
      ],
    );
  }

  Widget _buildContractTab(
    BuildContext context,
    AdminProvider provider,
    AdminUserDetails? userDetails,
    bool isLoading,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (provider.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              provider.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(),
          ),
        if (userDetails == null && !isLoading)
          const Text('Данные пользователя не найдены.')
        else if (userDetails != null) ...[
          if (userDetails.status != DocumentStatus.approved)
            _buildPlaceholderCard('Пользователь не заполнил данные')
          else if (!_showContractForm && _activeContract != null)
            _buildActiveContractCard(context)
          else
            _buildContractForm(context, provider),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.description_outlined),
            label: const Text('Договора'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AdminUserContractsScreen(),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildContractForm(
    BuildContext context,
    AdminProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Данные для договора',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ContractTextField(
              label: 'Серийный номер велосипеда',
              controller: _bikeSerialController,
            ),
            _ContractTextField(
              label: 'Серийный номер АКБ 1',
              controller: _akb1SerialController,
            ),
            _ContractTextField(
              label: 'Серийный номер АКБ 2',
              controller: _akb2SerialController,
            ),
            _ContractTextField(
              label: 'Серийный номер АКБ 3',
              controller: _akb3SerialController,
            ),
            _ContractTextField(
              label: 'Сумма',
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
            _ContractTextField(
              label: 'Количество недель',
              controller: _weeksCountController,
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _filledDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Дата заполнения',
                border: OutlineInputBorder(),
              ),
              onTap: _submittingContract
                  ? null
                  : () async {
                      final picked = await _pickFilledDate(context);
                      if (picked == null) {
                        return;
                      }
                      setState(() {
                        _filledDate = picked;
                        _filledDateController.text =
                            _dateFormat.format(picked);
                      });
                    },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submittingContract
                    ? null
                    : () => _submitContract(context, provider),
                child: _submittingContract
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Сформировать договор'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildActiveContractCard(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Есть активный договор до ${_activeContract?.endDate ?? '—'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    _showContractForm = true;
                  });
                },
                child: const Text('Создать новый договор'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard(String text) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<DateTime?> _pickFilledDate(BuildContext context) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: _filledDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
  }

  Future<void> _submitContract(
    BuildContext context,
    AdminProvider provider,
  ) async {
    final bikeSerial = _bikeSerialController.text.trim();
    final akb1Serial = _akb1SerialController.text.trim();
    final akb2Serial = _akb2SerialController.text.trim();
    final akb3Serial = _akb3SerialController.text.trim();
    final filledDate = _filledDateController.text.trim();
    final amountText = _amountController.text.trim();
    final weeksText = _weeksCountController.text.trim();

    if (bikeSerial.isEmpty ||
        akb1Serial.isEmpty ||
        akb2Serial.isEmpty ||
        akb3Serial.isEmpty ||
        filledDate.isEmpty ||
        amountText.isEmpty ||
        weeksText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля договора')),
      );
      return;
    }

    final amount = num.tryParse(amountText.replaceAll(',', '.'));
    final weeksCount = int.tryParse(weeksText);
    if (amount == null || weeksCount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Проверьте сумму и количество недель')),
      );
      return;
    }

    setState(() {
      _submittingContract = true;
    });

    try {
      final contract = await provider.createContract(
        userId: widget.user.id,
        draft: AdminContractDraft(
          bikeSerial: bikeSerial,
          akb1Serial: akb1Serial,
          akb2Serial: akb2Serial,
          akb3Serial: akb3Serial,
          amount: amount,
          weeksCount: weeksCount,
          filledDate: filledDate,
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _activeContract = contract;
        _showContractForm = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Договор сформирован')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      final message = provider.error ?? 'Не удалось сформировать договор';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submittingContract = false;
        });
      }
    }
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({
    required this.user,
    required this.status,
    required this.reasonController,
    required this.onApprove,
    required this.onReject,
  });

  final AdminUserDetails user;
  final DocumentStatus status;
  final TextEditingController reasonController;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final rows = <_UserInfoRow>[
      _UserInfoRow(label: 'Email', value: user.email),
      _UserInfoRow(label: 'ФИО', value: user.fullName ?? '—'),
      _UserInfoRow(label: 'ИНН', value: user.inn),
      _UserInfoRow(label: 'Адрес регистрации', value: user.registrationAddress),
      _UserInfoRow(label: 'Адрес проживания', value: user.residentialAddress),
      _UserInfoRow(label: 'Паспорт', value: user.passport),
      _UserInfoRow(label: 'Телефон', value: user.phone),
      _UserInfoRow(label: 'Банковский счёт', value: user.bankAccount),
      _UserInfoRow(label: 'Роль', value: user.role),
      _UserInfoRow(label: 'Статус', value: _statusLabel(user.status)),
      _UserInfoRow(
        label: 'Причина отклонения',
        value: user.rejectionReason ?? '—',
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Информация пользователя',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 12),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        row.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(child: Text(row.value)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Комментарий',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Отклонить'),
                    onPressed: onReject,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Одобрить'),
                    onPressed: onApprove,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractTextField extends StatelessWidget {
  const _ContractTextField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _UserInfoRow {
  const _UserInfoRow({required this.label, required this.value});

  final String label;
  final String value;
}

String _statusLabel(DocumentStatus status) {
  switch (status) {
    case DocumentStatus.pending:
      return 'На проверке';
    case DocumentStatus.approved:
      return 'Одобрен';
    case DocumentStatus.rejected:
      return 'Отклонён';
    case DocumentStatus.draft:
    default:
      return 'Черновик';
  }
}