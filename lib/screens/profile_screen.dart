import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
import '../providers/auth_provider.dart';
import '../providers/document_provider.dart';
import '../widgets/document_form.dart';
import '../widgets/status_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final documentProvider = context.watch<DocumentProvider>();

    if (auth.profileLoading && auth.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isAdmin = (auth.profile?.role ?? '').toLowerCase() == 'admin';
    if (isAdmin) {
      return _AdminProfile(auth: auth);
    }

    final resolvedData = _ProfileData(
      fullName: _resolveValue(
        auth.profile?.fullName,
        documentProvider.document.fullName,
      ),
      inn: _resolveValue(
        auth.profile?.inn,
        documentProvider.document.inn,
      ),
      registrationAddress: _resolveValue(
        auth.profile?.registrationAddress,
        documentProvider.document.registrationAddress,
      ),
      residentialAddress: _resolveValue(
        auth.profile?.residentialAddress,
        documentProvider.document.residentialAddress,
      ),
      passport: _resolveValue(
        auth.profile?.passport,
        documentProvider.document.passport,
      ),
      phone: _resolveValue(
        auth.profile?.phone,
        documentProvider.document.phone,
      ),
      bankAccount: _resolveValue(
        auth.profile?.bankAccount,
        documentProvider.document.bankAccount,
      ),
    );

    final resolvedStatus = _resolveStatus(
      documentProvider.document.status,
      auth.profile?.documentStatus,
    );

    final displayStatus = _normalizeStatus(resolvedStatus, resolvedData);

    final showForm =
        displayStatus == DocumentStatus.draft ||
        displayStatus == DocumentStatus.rejected;

    final formDocument = documentProvider.document.copyWith(
      fullName: resolvedData.fullName,
      inn: resolvedData.inn,
      registrationAddress: resolvedData.registrationAddress,
      residentialAddress: resolvedData.residentialAddress,
      passport: resolvedData.passport,
      phone: resolvedData.phone,
      bankAccount: resolvedData.bankAccount,
      status: displayStatus,
    );

    return RefreshIndicator(
      onRefresh: () async {
        await auth.loadProfile(trackLoading: false);
        await documentProvider.fetch();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Text(
                'Профиль',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: displayStatus),
              const Spacer(),
              IconButton(
                onPressed: documentProvider.loading
                    ? null
                    : () async {
                        await auth.loadProfile(trackLoading: false);
                        await documentProvider.fetch();
                      },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (documentProvider.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                documentProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (showForm)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Заполните данные',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (displayStatus == DocumentStatus.rejected) ...[
                            const SizedBox(width: 8),
                            StatusBadge(status: displayStatus),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayStatus == DocumentStatus.rejected
                            ? 'Данные отклонены. Исправьте сведения и отправьте снова.'
                            : 'Введите сведения, чтобы отправить профиль на проверку.',
                      ),
                       if (displayStatus == DocumentStatus.rejected) ...[
                        const SizedBox(height: 8),
                        _DetailRow(
                          label: 'Причина отклонения',
                          value:
                              (documentProvider.document.rejectionReason ?? '')
                                      .trim()
                                      .isEmpty
                                  ? '—'
                                  : documentProvider.document.rejectionReason!,
                        ),
                      ],
                      const SizedBox(height: 16),
                      DocumentForm(
                        document: formDocument,
                        loading: documentProvider.loading,
                        onSaveDraft: documentProvider.update,
                        onSubmit: documentProvider.submit,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resolvedData.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(auth.profile?.email ?? ''),
                      const SizedBox(height: 6),
                      Text('ID: ${auth.profile?.id ?? '-'}'),
                      Text('Роль: ${auth.profile?.role ?? '-'}'),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Статус проверки',
                        value: _statusLabel(displayStatus),
                      ),
                      _DetailRow(
                        label: 'Комментарий',
                        value: (documentProvider.document.rejectionReason ??
                                '')
                            .trim()
                            .isEmpty
                            ? '—'
                            : documentProvider.document.rejectionReason!,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _showDetails = !_showDetails;
                          });
                        },
                        child: Text(_showDetails
                            ? 'Скрыть подробности'
                            : 'Подробная информация'),
                      ),
                      if (_showDetails) ...[
                        const SizedBox(height: 12),
                        ..._buildDetails(resolvedData),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildDetails(_ProfileData data) {
    return [
      _DetailRow(label: 'ИНН', value: data.inn),
      _DetailRow(label: 'Адрес регистрации', value: data.registrationAddress),
      _DetailRow(label: 'Адрес проживания', value: data.residentialAddress),
      _DetailRow(label: 'Паспорт', value: data.passport),
      _DetailRow(label: 'Телефон', value: data.phone),
      _DetailRow(label: 'Банковский счёт', value: data.bankAccount),
    ];
  }

  String _resolveValue(String? primary, String fallback) {
    if (primary != null && primary.trim().isNotEmpty) {
      return primary;
    }
    return fallback;
  }

  DocumentStatus _resolveStatus(
    DocumentStatus documentStatus,
    DocumentStatus? profileStatus,
  ) {
    if (profileStatus != null && documentStatus == DocumentStatus.draft) {
      return profileStatus;
    }
    return documentStatus;
  }

  DocumentStatus _normalizeStatus(
    DocumentStatus status,
    _ProfileData data,
  ) {
    if (status == DocumentStatus.draft && data.isComplete) {
      return DocumentStatus.pending;
    }
    return status;
  }

  String _statusLabel(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return 'Черновик';
      case DocumentStatus.pending:
        return 'На проверке';
      case DocumentStatus.approved:
        return 'Одобрено';
      case DocumentStatus.rejected:
        return 'Отклонено';
    }
  }
}

class _ProfileData {
  const _ProfileData({
    required this.fullName,
    required this.inn,
    required this.registrationAddress,
    required this.residentialAddress,
    required this.passport,
    required this.phone,
    required this.bankAccount,
  });

  final String fullName;
  final String inn;
  final String registrationAddress;
  final String residentialAddress;
  final String passport;
  final String phone;
  final String bankAccount;

  bool get isComplete =>
      fullName.isNotEmpty &&
      inn.isNotEmpty &&
      registrationAddress.isNotEmpty &&
      residentialAddress.isNotEmpty &&
      passport.isNotEmpty &&
      phone.isNotEmpty &&
      bankAccount.isNotEmpty;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
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

class _AdminProfile extends StatelessWidget {
  const _AdminProfile({required this.auth});

  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Профиль администратора',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${auth.profile?.email ?? '-'}'),
                const SizedBox(height: 8),
                Text('ID: ${auth.profile?.id ?? '-'}'),
                const SizedBox(height: 8),
                Text('Роль: ${auth.profile?.role ?? '-'}'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
