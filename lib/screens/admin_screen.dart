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

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<_AdminStatusTab> _tabs = const [
    _AdminStatusTab('Ожидают', AdminUserStatusFilter.pending),
    _AdminStatusTab('Отказы', AdminUserStatusFilter.rejected),
    _AdminStatusTab('Одобрены', AdminUserStatusFilter.approved),
    _AdminStatusTab('Новые', AdminUserStatusFilter.draft),
    _AdminStatusTab('Все', AdminUserStatusFilter.all),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<AdminProvider>()
            .setStatusFilter(_tabs[_tabController.index].filter);
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    context
        .read<AdminProvider>()
        .setStatusFilter(_tabs[_tabController.index].filter);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
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
              ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: _tabs
                  .map((tab) => Tab(text: tab.label))
                  .toList(growable: false),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.refreshUsers,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                            final adminProvider =
                                context.read<AdminProvider>();
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
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AdminStatusTab {
  final String label;
  final AdminUserStatusFilter filter;

  const _AdminStatusTab(this.label, this.filter);
}
