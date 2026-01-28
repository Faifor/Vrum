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
    _AdminStatusTab('Ждёт', AdminUserStatusFilter.pending),
    _AdminStatusTab('Отказ', AdminUserStatusFilter.rejected),
    _AdminStatusTab('Принят', AdminUserStatusFilter.approved),
    _AdminStatusTab('Новый', AdminUserStatusFilter.draft),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.zero,
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.black54,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: _tabs
                      .map(
                        (tab) => Tab(
                          child: Center(child: Text(tab.label)),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
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
