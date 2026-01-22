import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vrum/models/document.dart';
import 'package:vrum/providers/admin_provider.dart';
import 'package:vrum/screens/admin_user_document_screen.dart';
import 'package:vrum/widgets/status_badge.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
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
                    subtitle: Text(user.fullName ?? '—'),
                    trailing: StatusBadge(
                      status: user.documentStatus ?? DocumentStatus.draft,
                    ),
                    onTap: () {
                      final adminProvider = context.read<AdminProvider>();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: adminProvider,
                            child: AdminUserDocumentScreen(user: user),
                          ),
                        ),
                      );
                    },
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
