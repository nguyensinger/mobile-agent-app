// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/auth_service.dart';
import 'services/fcm_service.dart';
import 'screens/login_screen.dart';
import 'screens/ticket_list_screen.dart';
import 'screens/ticket_detail_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo Firebase trước khi runApp — bắt buộc với firebase_core
  await FcmService.initialize();
  runApp(const ItSupportAgentApp());
}

class ItSupportAgentApp extends StatefulWidget {
  const ItSupportAgentApp({super.key});

  /// Cho phép bất kỳ widget con nào đổi ngôn ngữ runtime (không cần restart app),
  /// theo đúng pattern chuẩn của Flutter cho việc đổi locale động: tìm lên
  /// _ItSupportAgentAppState gần nhất qua context và gọi setState ở đó.
  static void setLocale(BuildContext context, Locale newLocale) {
    final state = context.findAncestorStateOfType<_ItSupportAgentAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<ItSupportAgentApp> createState() => _ItSupportAgentAppState();
}

class _ItSupportAgentAppState extends State<ItSupportAgentApp> {
  Locale _locale = const Locale('en');
  // Navigator key để navigate từ FCM notification tap (ngoài context widget tree)
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
    _setupFcmTapHandler();
  }

  Future<void> _loadSavedLocale() async {
    final saved = await AuthService().getLanguage();
    if (saved != null && mounted) {
      setState(() => _locale = Locale(saved));
    }
  }

  void _setupFcmTapHandler() {
    // Khi user tap vào push notification -> navigate đến ticket detail screen
    FcmService().onNotificationTap = (int ticketId) {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => TicketDetailScreen(ticketId: ticketId),
        ),
      );
    };
  }

  void setLocale(Locale newLocale) {
    setState(() => _locale = newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'IT Support Agent',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF255AA8),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F84C9),
          brightness: Brightness.dark,
        ),
      ),
      home: const _RootRouter(),
    );
  }
}

/// Quyết định màn hình khởi đầu: đã đăng nhập -> danh sách ticket, chưa -> màn login.
class _RootRouter extends StatefulWidget {
  const _RootRouter();

  @override
  State<_RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<_RootRouter> {
  final AuthService _auth = AuthService();
  bool _loading = true;
  bool _configured = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final configured = await _auth.isConfigured();
    if (configured) {
      // Đã đăng nhập -> setup FCM (lấy token, đăng ký với Odoo)
      // Chạy nền, không block UI
      FcmService().setup().catchError((e) {
        debugPrint('[FCM] setup error: $e');
      });
    }
    if (mounted) {
      setState(() {
        _configured = configured;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _configured
        ? const TicketListScreen()
        : LoginScreen(onLoggedIn: () {
            // Sau khi login thành công -> setup FCM ngay
            FcmService().setup().catchError((e) {
              debugPrint('[FCM] setup error after login: $e');
            });
            setState(() => _configured = true);
          });
  }
}
