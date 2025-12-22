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
              StatusBadge(status: documentProvider.document.status),
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
          if (!documentProvider.hasCompletedProfile)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Заполните данные',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Введите сведения, чтобы отправить профиль на проверку.',
                      ),
                      const SizedBox(height: 16),
                      DocumentForm(
                        document: documentProvider.document,
                        loading: documentProvider.loading,
                        onSaveDraft: documentProvider.update,
                        onSubmit: (doc) => documentProvider.submit(doc),
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
                        documentProvider.document.fullName,
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
                        ..._buildDetails(documentProvider.document),
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

  List<Widget> _buildDetails(UserDocument doc) {
    return [
      _DetailRow(label: 'ИНН', value: doc.inn),
      _DetailRow(label: 'Адрес регистрации', value: doc.registrationAddress),
      _DetailRow(label: 'Адрес проживания', value: doc.residentialAddress),
      _DetailRow(label: 'Паспорт', value: doc.passport),
      _DetailRow(label: 'Телефон', value: doc.phone),
      _DetailRow(label: 'Банковский счёт', value: doc.bankAccount),
    ];
  }
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