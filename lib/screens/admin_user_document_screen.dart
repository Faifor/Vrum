import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vrum/models/admin_user_details.dart';
import 'package:vrum/models/document.dart';
import 'package:vrum/models/user_summary.dart';
import 'package:vrum/providers/admin_provider.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final userDetails = provider.selectedUser;
        final isLoading = provider.loading && userDetails == null;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.user.fullName ?? widget.user.email),
          ),
          body: ListView(
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
                _UserInfoCard(user: userDetails),
                const SizedBox(height: 12),
                _DocumentReview(
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
                  documentText: _buildDocumentText(userDetails),
                ),
              ] else if (!isLoading)
                const Text('Данные пользователя не найдены.'),
            ],
          ),
        );
      },
    );
  }

  String _buildDocumentText(AdminUserDetails user) {
    return '''${user.fullName ?? user.email}
ИНН: ${user.inn}
Адрес регистрации: ${user.registrationAddress}
Адрес проживания: ${user.residentialAddress}
Паспорт: ${user.passport}
Телефон: ${user.phone}
Банковский счёт: ${user.bankAccount}
Статус: ${_statusLabel(user.status)}
Причина отклонения: ${user.rejectionReason ?? '—'}''';
  }
}

class _DocumentReview extends StatelessWidget {
  const _DocumentReview({
    required this.status,
    required this.reasonController,
    required this.onApprove,
    required this.onReject,
    required this.documentText,
  });

  final DocumentStatus status;
  final TextEditingController reasonController;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final String documentText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Документ пользователя',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 12),
            Text(documentText),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Комментарий или причина отклонения',
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

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({required this.user});

  final AdminUserDetails user;

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
            const Text(
              'Информация пользователя',
              style: TextStyle(fontWeight: FontWeight.bold),
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
          ],
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