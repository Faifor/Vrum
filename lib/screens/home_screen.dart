import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_client.dart';

enum AuthMode {
  signIn,
  signUp,
  forgotRequest,
  forgotReset,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  AuthMode _mode = AuthMode.signIn;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForMode(_mode)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ..._buildFields(),
                      const SizedBox(height: 20),
                      _buildPrimaryAction(authProvider),
                      const SizedBox(height: 12),
                      _buildSecondaryActions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFields() {
    final List<Widget> fields = <Widget>[
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Почта',
          hintText: 'user@example.com',
          border: OutlineInputBorder(),
        ),
        autofillHints: const <String>[
          AutofillHints.username,
          AutofillHints.email,
        ],
        textInputAction: TextInputAction.next,
        validator: (String? value) {
          if (value == null || value.trim().isEmpty) {
            return 'Введите почту';
          }
          if (!value.contains('@')) {
            return 'Некорректный адрес почты';
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
    ];

    switch (_mode) {
      case AuthMode.signIn:
        fields.addAll(_passwordFields(
          controller: _passwordController,
          label: 'Пароль',
          autofillHints: const <String>[AutofillHints.password],
        ));
        break;
      case AuthMode.signUp:
        fields.addAll(_passwordFields(
          controller: _passwordController,
          label: 'Пароль',
          confirmController: _confirmPasswordController,
          autofillHints: const <String>[AutofillHints.newPassword],
        ));
        break;
      case AuthMode.forgotRequest:
        // Only email is required.
        break;
      case AuthMode.forgotReset:
        fields
          ..add(
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Код подтверждения',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите код из письма';
                }
                return null;
              },
            ),
          )
          ..add(const SizedBox(height: 12))
          ..addAll(
            _passwordFields(
              controller: _newPasswordController,
              label: 'Новый пароль',
              confirmController: _confirmNewPasswordController,
              autofillHints: const <String>[AutofillHints.newPassword],
            ),
          );
        break;
    }

    return fields;
  }

  List<Widget> _passwordFields({
    required TextEditingController controller,
    required String label,
    TextEditingController? confirmController,
    List<String>? autofillHints,
  }) {
    return <Widget>[
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        textInputAction: confirmController == null
            ? TextInputAction.done
            : TextInputAction.next,
        autofillHints: autofillHints,
        obscureText: true,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Введите пароль';
          }
          if (value.length < 6) {
            return 'Пароль должен быть длиннее 6 символов';
          }
          return null;
        },
      ),
      if (confirmController != null) ...<Widget>[
        const SizedBox(height: 12),
        TextFormField(
          controller: confirmController,
          decoration: const InputDecoration(
            labelText: 'Повторите пароль',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          autofillHints: autofillHints,
          obscureText: true,
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Повторите пароль';
            }
            if (value != controller.text) {
              return 'Пароли должны совпадать';
            }
            return null;
          },
        ),
      ],
    ];
  }

  Widget _buildPrimaryAction(AuthProvider authProvider) {
    final bool isLoading = authProvider.isLoading;
    return FilledButton(
      onPressed: isLoading ? null : () => _submit(authProvider),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Text(_primaryButtonLabel(_mode)),
      ),
    );
  }

  Widget _buildSecondaryActions() {
    switch (_mode) {
      case AuthMode.signIn:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OutlinedButton(
              onPressed: () => _switchMode(AuthMode.signUp),
              child: const Text('Зарегистрироваться'),
            ),
            TextButton(
              onPressed: () => _switchMode(AuthMode.forgotRequest),
              child: const Text('Забыли пароль?'),
            ),
          ],
        );
      case AuthMode.signUp:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OutlinedButton(
              onPressed: () => _switchMode(AuthMode.signIn),
              child: const Text('У меня уже есть аккаунт'),
            ),
            TextButton(
              onPressed: () => _switchMode(AuthMode.forgotRequest),
              child: const Text('Забыли пароль?'),
            ),
          ],
        );
      case AuthMode.forgotRequest:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OutlinedButton(
              onPressed: () => _switchMode(AuthMode.signIn),
              child: const Text('Вернуться ко входу'),
            ),
            TextButton(
              onPressed: () => _switchMode(AuthMode.forgotReset),
              child: const Text('Код уже получен? Ввести код'),
            ),
          ],
        );
      case AuthMode.forgotReset:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OutlinedButton(
              onPressed: () => _switchMode(AuthMode.signIn),
              child: const Text('Вернуться ко входу'),
            ),
            TextButton(
              onPressed: () => _switchMode(AuthMode.forgotRequest),
              child: const Text('Запросить код повторно'),
            ),
          ],
        );
    }
  }

  Future<void> _submit(AuthProvider authProvider) async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      switch (_mode) {
        case AuthMode.signIn:
          await authProvider.login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          _showSnackBar('Успешный вход');
          break;
        case AuthMode.signUp:
          await authProvider.register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          _showSnackBar('Регистрация прошла успешно');
          break;
        case AuthMode.forgotRequest:
          await authProvider.requestPasswordResetCode(
            email: _emailController.text.trim(),
          );
          _showSnackBar('Код отправлен на указанную почту');
          _switchMode(AuthMode.forgotReset);
          break;
        case AuthMode.forgotReset:
          await authProvider.resetPassword(
            email: _emailController.text.trim(),
            code: _codeController.text.trim(),
            newPassword: _newPasswordController.text,
          );
          _showSnackBar('Пароль успешно обновлён');
          _switchMode(AuthMode.signIn);
          break;
      }
    } on ApiException catch (error) {
      _showSnackBar(error.message, isError: true);
    } catch (error) {
      _showSnackBar('Не удалось выполнить запрос: $error', isError: true);
    }
  }

  void _switchMode(AuthMode mode) {
    setState(() {
      _mode = mode;
      _formKey.currentState?.reset();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _codeController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();
    });
  }

  String _titleForMode(AuthMode mode) {
    switch (mode) {
      case AuthMode.signIn:
        return 'Авторизация';
      case AuthMode.signUp:
        return 'Регистрация';
      case AuthMode.forgotRequest:
        return 'Восстановление пароля';
      case AuthMode.forgotReset:
        return 'Сброс пароля';
    }
  }

  String _primaryButtonLabel(AuthMode mode) {
    switch (mode) {
      case AuthMode.signIn:
        return 'Войти';
      case AuthMode.signUp:
        return 'Зарегистрироваться';
      case AuthMode.forgotRequest:
        return 'Получить код';
      case AuthMode.forgotReset:
        return 'Установить пароль';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }
}
