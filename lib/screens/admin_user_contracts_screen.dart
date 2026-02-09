import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contract_document.dart';
import '../providers/admin_provider.dart';
import '../widgets/contract_card.dart';
import '../utils/contract_launcher.dart';

class AdminUserContractsScreen extends StatefulWidget {
  const AdminUserContractsScreen({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  State<AdminUserContractsScreen> createState() =>
      _AdminUserContractsScreenState();
}

class _AdminUserContractsScreenState extends State<AdminUserContractsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<AdminProvider>().fetchUserContracts(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final contracts = _sortContracts(provider.selectedContracts);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Договора'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Обновить',
                onPressed: provider.loading
                    ? null
                    : () => provider.fetchUserContracts(widget.userId),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.fetchUserContracts(widget.userId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (provider.loading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(),
                  ),
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (!provider.loading && contracts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text('Договоров пока нет.'),
                    ),
                  )
                else
                  ...contracts.map(
                    (contract) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ContractCard(
                        contract: contract,
                        onTap: contract.contractDocxUrl?.isEmpty ?? true
                            ? null
                            : () => _openContract(context, contract),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

List<ContractDocument> _sortContracts(List<ContractDocument> contracts) {
  final sorted = List<ContractDocument>.from(contracts);
  sorted.sort(
    (a, b) {
      if (a.active == b.active) {
        return 0;
      }
      return a.active ? -1 : 1;
    },
  );
  return sorted;
}

Future<void> _openContract(
  BuildContext context,
  ContractDocument contract,
) async {
  final error = await openContractUrl(contract.contractDocxUrl);
  if (!context.mounted || error == null) {
    return;
  }
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.showSnackBar(SnackBar(content: Text(error)));
}