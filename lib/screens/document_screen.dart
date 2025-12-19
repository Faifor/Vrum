import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/document_provider.dart';
import '../widgets/document_form.dart';
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
                    'Моя заявка',
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
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DocumentForm(
                    document: provider.document,
                    loading: provider.loading,
                    onSaveDraft: (value) =>
                        provider.update(provider.document.copyWith(
                      fullName: value.fullName,
                      address: value.address,
                      passport: value.passport,
                      phone: value.phone,
                      bankAccount: value.bankAccount,
                      contractNumber: value.contractNumber,
                      bikeSerial: value.bikeSerial,
                      akb1Serial: value.akb1Serial,
                      akb2Serial: value.akb2Serial,
                      akb3Serial: value.akb3Serial,
                      amount: value.amount,
                      amountText: value.amountText,
                      weeksCount: value.weeksCount,
                      filledDate: value.filledDate,
                      endDate: value.endDate,
                    )),
                    onSubmit: () => provider.submit(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
}
