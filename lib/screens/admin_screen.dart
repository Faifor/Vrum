import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
import '../providers/admin_provider.dart';
import '../widgets/status_badge.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminProvider>().refreshUsers();
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
        return RefreshIndicator(
          onRefresh: provider.refreshUsers,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  const Text(
                    'Панель администратора',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed:
                        provider.loading ? null : provider.refreshUsers,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                if (provider.loading) const LinearProgressIndicator(),
              ...provider.users.map(
                (user) => Card(
                  child: ListTile(
                    title: Text(user.email),
                    subtitle: Text('${user.firstName} ${user.lastName}'),
                    trailing: StatusBadge(
                      status:
                          user.documentStatus ?? DocumentStatus.draft,
                    ),
                    onTap: () => provider.fetchDocument(user.id),
                  ),
                ),
              ),
              if (provider.selectedDocument != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _DocumentReview(
                    status: provider.selectedDocument!.status,
                    reasonController: _reasonController,
                    onApprove: () =>
                        provider.approve(provider.selectedUserId ?? 0),
                    onReject: () => provider.reject(
                      provider.selectedUserId ?? 0,
                      _reasonController.text,
                    ),
                    documentText: _buildDocumentText(
                      provider.selectedDocument!,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _buildDocumentText(UserDocument document) {
    return '''${document.fullName}
${document.address}
${document.passport}
Телефон: ${document.phone}
Серийный номер: ${document.bikeSerial ?? '-'}
Сумма: ${document.amount ?? '-'}''';
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
  final VoidCallback onApprove;
  final VoidCallback onReject;
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
