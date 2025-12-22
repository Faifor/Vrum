import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/document_provider.dart';
import '../widgets/status_badge.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: provider.fetch,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  const Text(
                    'Мой договор',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  StatusBadge(status: provider.document.status),
                  const Spacer(),
                  IconButton(
                    onPressed: provider.loading ? null : provider.fetch,
                    tooltip: 'Обновить',
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              if (provider.loading) const LinearProgressIndicator(),
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (!provider.hasCompletedProfile)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Заполните профиль',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Чтобы увидеть договор, сначала заполните данные в профиле и отправьте их на проверку.',
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Основные данные',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._buildInfoRows(provider),
                      ],
                    ),
                  ),
                ),
              ],
              if (provider.document.rejectionReason != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Причина отклонения: ${provider.document.rejectionReason}',
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ),
              if (provider.document.contractText != null)
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      provider.document.contractText!,
                      style: TextStyle(color: Colors.green.shade900),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  List<Widget> _buildInfoRows(DocumentProvider provider) {
    final doc = provider.document;
    return [
      _InfoRow(label: 'ФИО', value: doc.fullName),
      _InfoRow(label: 'ИНН', value: doc.inn),
      _InfoRow(label: 'Адрес регистрации', value: doc.registrationAddress),
      _InfoRow(label: 'Адрес проживания', value: doc.residentialAddress),
      _InfoRow(label: 'Паспорт', value: doc.passport),
      _InfoRow(label: 'Телефон', value: doc.phone),
      _InfoRow(label: 'Банковский счёт', value: doc.bankAccount),
    ];
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
