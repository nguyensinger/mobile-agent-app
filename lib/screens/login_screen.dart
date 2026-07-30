// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoggedIn;
  const LoginScreen({super.key, required this.onLoggedIn});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baseUrlCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    // Capture l10n TRƯỚC khi bất kỳ await nào — tránh dùng context sau async gap.
    // nullable-getter: false nên of() trả về non-nullable, không cần ! hay ?.
    final l10n = AppLocalizations.of(context);

    final auth = AuthService();
    final baseUrl = _baseUrlCtrl.text.trim();

    try {
      // /api/v1/agent/login đã tự kiểm tra email/password VÀ quyền Agent/Manager
      // phía server - nếu gọi thành công thì chắc chắn hợp lệ, không cần whoami()
      // riêng nữa. Server trả luôn 1 API key mới, dùng cho mọi request sau này y
      // hệt như khi dán tay 1 key có sẵn trước đây.
      final result = await ApiService().login(baseUrl, _emailCtrl.text.trim(), _passwordCtrl.text);
      await auth.saveServerCredentials(baseUrl: baseUrl, apiKey: result['api_key'] as String);
      await auth.saveAgentIdentity(
        userId: result['user_id'] as int,
        name: result['name'] as String,
        isManager: result['is_manager'] == true,
      );
      _passwordCtrl.clear();
      if (mounted) widget.onLoggedIn();
    } catch (e) {
      await auth.logout();
      if (mounted) {
        setState(() => _error = l10n.errorConnectionFailed(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.support_agent, size: 56, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _baseUrlCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.serverAddressLabel,
                      hintText: 'https://erp.yourcompany.com',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.errorEnterServerAddress : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.errorEnterEmail : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.passwordLabel,
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    validator: (v) => (v == null || v.isEmpty) ? l10n.errorEnterPassword : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.signInButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
