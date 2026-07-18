// lib/services/fcm_service.dart
//
// Quản lý Firebase Cloud Messaging cho Flutter app:
// - Xin quyền notification khi app khởi động lần đầu (Android 13+)
// - Lấy FCM token và gửi lên Odoo backend để backend biết cần push về đâu
// - Xử lý notification khi app đang foreground (hiện SnackBar/dialog)
// - Xử lý notification tap khi app ở background/terminated (navigate đến ticket)
//
// Device fingerprint: UUID tạo 1 lần khi app cài đặt, lưu SharedPreferences.
// Dùng để Odoo upsert token (cùng thiết bị nhưng token FCM mới -> cập nhật,
// không tạo thêm bản ghi).

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'api_service.dart';

/// Background message handler — phải là top-level function (không phải method),
/// chạy trong isolate riêng khi app bị killed hoặc ở background.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Không cần làm gì ở đây vì FCM tự hiển thị notification khi app ở background.
  // Nếu muốn xử lý data payload khi background, thêm logic tại đây.
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Callback được gọi khi user tap notification -> app navigate đến ticket
  // Được set từ main.dart sau khi app đã build xong
  Function(int ticketId)? onNotificationTap;

  /// Khởi tạo Firebase và đăng ký handlers. Gọi 1 lần trong main() sau runApp().
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Xin quyền notification, lấy token, đăng ký với Odoo.
  /// Gọi sau khi user đăng nhập thành công (có API key hợp lệ).
  Future<void> setup() async {
    // Xin quyền (Android 13+ bắt buộc, các version cũ tự grant)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // User từ chối — không gửi notification, không crash app
      return;
    }

    // Lấy token và đăng ký lên Odoo
    await _registerToken();

    // Token có thể bị refresh bởi FCM -> đăng ký lại ngay khi có token mới
    _messaging.onTokenRefresh.listen((newToken) async {
      await _registerToken(token: newToken);
    });

    // Xử lý notification khi app đang FOREGROUND
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Xử lý tap notification khi app ở BACKGROUND (app chưa bị killed)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Kiểm tra notification đã tap khi app bị TERMINATED (app mở từ notification)
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleNotificationTap(initial);
    }
  }

  Future<void> _registerToken({String? token}) async {
    final fcmToken = token ?? await _messaging.getToken();
    if (fcmToken == null) return;

    final fingerprint = await _getOrCreateDeviceFingerprint();
    try {
      await ApiService().registerFcmToken(
        fcmToken: fcmToken,
        deviceFingerprint: fingerprint,
      );
    } catch (e) {
      // Lỗi mạng hoặc server — không crash app, sẽ thử lại lần sau
      debugPrint('[FCM] Failed to register token: $e');
    }
  }

  Future<String> _getOrCreateDeviceFingerprint() async {
    final prefs = await SharedPreferences.getInstance();
    var fingerprint = prefs.getString('device_fingerprint');
    if (fingerprint == null) {
      // Tạo UUID đơn giản không cần package uuid
      final rand = Random.secure();
      fingerprint = List.generate(32, (_) => rand.nextInt(16).toRadixString(16)).join();
      await prefs.setString('device_fingerprint', fingerprint);
    }
    return fingerprint;
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Khi app đang mở, FCM không tự hiển thị notification banner trên Android
    // -> hiển thị qua callback để UI có thể show SnackBar hoặc in-app banner
    final ticketId = _parseTicketId(message);
    if (onNotificationTap != null && ticketId != null) {
      // Nếu có handler -> delegate cho UI xử lý (hiện banner, navigate nếu muốn)
    }
    debugPrint('[FCM] Foreground message: ${message.notification?.title}');
  }

  void _handleNotificationTap(RemoteMessage message) {
    final ticketId = _parseTicketId(message);
    if (ticketId != null && onNotificationTap != null) {
      onNotificationTap!(ticketId);
    }
  }

  int? _parseTicketId(RemoteMessage message) {
    final raw = message.data['ticket_id'];
    if (raw == null) return null;
    return int.tryParse(raw.toString());
  }
}
