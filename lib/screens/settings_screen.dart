// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentLang = 'en';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final lang = await AuthService().getLanguage();
    if (mounted) setState(() => _currentLang = lang ?? 'en');
  }

  // Tách thành 2 phần: lưu async, rồi apply locale sync sau mounted check.
  // Không dùng context sau await — thay vào đó dùng setState + didChangeDependencies
  // để apply locale qua ItSupportAgentApp.setLocale() chỉ khi widget vẫn còn mounted.
  Future<void> _changeLanguage(String? lang) async {
    if (lang == null) return;
    // 1. Lưu vào SharedPreferences (async)
    await AuthService().saveLanguage(lang);
    // 2. Sau await: kiểm tra mounted, rồi mới dùng context
    if (!mounted) return;
    setState(() => _currentLang = lang);
    // ignore: use_build_context_synchronously
    ItSupportAgentApp.setLocale(context, Locale(lang));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.languageLabel),
            trailing: DropdownButton<String>(
              value: _currentLang,
              onChanged: _changeLanguage,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                DropdownMenuItem(value: 'fr', child: Text('Français')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
