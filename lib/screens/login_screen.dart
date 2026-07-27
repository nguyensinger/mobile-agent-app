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
  final _apiKeyCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
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
    await auth.saveServerCredentials(
      baseUrl: _baseUrlCtrl.text,
      apiKey: _apiKeyCtrl.text,
    );

    try {
      final who = await ApiService().whoami();
      if (who['is_agent'] != true && who['is_manager'] != true) {
        throw Exception(l10n.errorNotAgent);
      }
      await auth.saveAgentIdentity(
        userId: who['user_id'] as int,
        name: who['name'] as String,
        isManager: who['is_manager'] == true,
      );
      if (mounted) widget.onLoggedIn();
    } catch (e, stackTrace) {
      await auth.logout();
      // TEMP DEBUG: include the top of the stack trace in the visible error text
      // so a screenshot pinpoints exactly which line threw - "Null check operator
      // used on a null value" alone doesn't say where. Remove once the crash
      // reported after logout->relogin is confirmed fixed.
      debugPrint('[login] error: $e\n$stackTrace');
      if (mounted) {
        final trace = stackTrace.toString().split('\n').take(4).join('\n');
        setState(() => _error = '${l10n.errorConnectionFailed(e.toString())}\n\n$trace');
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
                    controller: _apiKeyCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.apiKeyLabel,
                      hintText: l10n.apiKeyHint,
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.errorEnterApiKey : null,
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
                  // TEMP DEBUG marker - confirms which build is actually installed.
                  // Remove together with the stack-trace debug block in _submit().
                  const SizedBox(height: 12),
                  Text(
                    'debug build DBG-002',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline),
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
