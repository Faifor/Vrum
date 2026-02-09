import 'package:flutter/material.dart';

import '../models/contract_document.dart';

class ContractCard extends StatelessWidget {
  const ContractCard({
    super.key,
    required this.contract,
    this.onTap,
  });

  final ContractDocument contract;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = contract.active;
    final theme = Theme.of(context);
    return Card(
      color: isActive ? Colors.green.shade50 : null,
      elevation: isActive ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive
              ? Colors.green.shade200
              : theme.dividerColor.withOpacity(0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      contract.contractNumber.isEmpty
                          ? 'Договор'
                          : 'Договор №${contract.contractNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Активный',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: 'Период',
                value: _formatPeriod(contract.filledDate, contract.endDate),
              ),
              if (contract.amountText.isNotEmpty)
                _InfoRow(label: 'Сумма', value: contract.amountText),
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: const [
                      Icon(Icons.open_in_new, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Открыть договор',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
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

String _formatPeriod(String start, String end) {
  if (start.isEmpty && end.isEmpty) {
    return '—';
  }
  if (start.isEmpty) {
    return 'до $end';
  }
  if (end.isEmpty) {
    return 'с $start';
  }
  return '$start — $end';
}

