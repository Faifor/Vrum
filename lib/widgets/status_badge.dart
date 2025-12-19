import 'package:flutter/material.dart';

import '../models/document.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final DocumentStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;

    switch (status) {
      case DocumentStatus.draft:
        color = Colors.grey;
        label = 'Черновик';
        break;
      case DocumentStatus.pending:
        color = Colors.orange;
        label = 'На проверке';
        break;
      case DocumentStatus.approved:
        color = Colors.green;
        label = 'Одобрено';
        break;
      case DocumentStatus.rejected:
        color = Colors.red;
        label = 'Отклонено';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color, // можно оставить так, без shade700
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
