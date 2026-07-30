// lib/services/api_service.dart

import 'package:dio/dio.dart';
import '../models/ticket.dart';
import '../models/chat_message.dart';
import '../models/booking_request.dart';
import 'auth_service.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// Client gọi REST API của module Odoo it_support_management.
/// Mọi endpoint dùng type='json' của Odoo controller -> body theo JSON-RPC 2.0:
/// { jsonrpc: "2.0", method: "call", params: {...} }
class ApiService {
  final AuthService _auth = AuthService();

  Future<Dio> _client({Duration? timeout}) async {
    final baseUrl = await _auth.getBaseUrl();
    final apiKey = await _auth.getApiKey();
    if (baseUrl == null || apiKey == null) {
      throw ApiException('Chưa đăng nhập. Vui lòng cấu hình server và API key.');
    }
    return Dio(BaseOptions(
      baseUrl: baseUrl.replaceAll(RegExp(r'/+$'), ''),
      connectTimeout: timeout ?? const Duration(seconds: 15),
      receiveTimeout: timeout ?? const Duration(seconds: 15),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<dynamic> _call(String path, Map<String, dynamic> params, {Duration? timeout}) async {
    final dio = await _client(timeout: timeout);
    try {
      final response = await dio.post(path, data: {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': params,
      });
      final data = response.data;

      // Lỗi JSON-RPC chuẩn của Odoo (exception ném ra từ code, ví dụ UserError, lỗi server 500)
      // -> nằm ở top-level data['error'], là object có message/data.message
      if (data is Map && data['error'] != null) {
        final error = data['error'];
        final message = (error['data']?['message'] ?? error['message'] ?? 'Lỗi không xác định').toString();
        throw ApiException(message);
      }

      final result = data is Map ? data['result'] : null;

      // Lỗi nghiệp vụ tự định nghĩa trong controller (ví dụ "Ticket không tồn tại")
      // -> nằm trong result['error'], là string thuần (xem _json_error trong controller Odoo)
      if (result is Map && result['error'] != null) {
        throw ApiException(result['error'].toString());
      }

      return result;
    } on DioException catch (e) {
      if (e.response?.data is Map && e.response?.data['error'] != null) {
        final error = e.response!.data['error'];
        throw ApiException((error['data']?['message'] ?? error['message']).toString());
      }
      throw ApiException(_describeDioError(e));
    }
  }

  /// Đăng nhập bằng email + password thay vì API key dán tay. Không dùng _client()/
  /// _call() ở đây - chưa có apiKey lúc này (đây chính là bước lấy nó), và endpoint
  /// auth='public' nên không cần header Authorization.
  Future<Map<String, dynamic>> login(String baseUrl, String email, String password) async {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl.replaceAll(RegExp(r'/+$'), ''),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    try {
      final response = await dio.post('/api/v1/agent/login', data: {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {'login': email, 'password': password},
      });
      final data = response.data;
      if (data is Map && data['error'] != null) {
        final error = data['error'];
        final message = (error['data']?['message'] ?? error['message'] ?? 'Lỗi không xác định').toString();
        throw ApiException(message);
      }
      final result = data is Map ? data['result'] : null;
      if (result is Map && result['error'] != null) {
        throw ApiException(result['error'].toString());
      }
      return (result as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      if (e.response?.data is Map && e.response?.data['error'] != null) {
        final error = e.response!.data['error'];
        throw ApiException((error['data']?['message'] ?? error['message']).toString());
      }
      throw ApiException(_describeDioError(e));
    }
  }

  String _describeDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối tới server quá thời gian chờ. Kiểm tra mạng hoặc địa chỉ server.';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối tới server. Kiểm tra địa chỉ server và mạng.';
      default:
        return 'Lỗi kết nối: ${e.message}';
    }
  }

  // ---------------- Identity ----------------

  Future<Map<String, dynamic>> whoami() async {
    final result = await _call('/api/v1/whoami', {});
    return result as Map<String, dynamic>;
  }

  Future<void> registerFcmToken({
    required String fcmToken,
    required String deviceFingerprint,
  }) async {
    await _call('/api/v1/agent/register_fcm_token', {
      'fcm_token': fcmToken,
      'device_fingerprint': deviceFingerprint,
    });
  }

  // ---------------- Tickets ----------------

  Future<List<Ticket>> getTickets({String? state, bool mine = false}) async {
    final params = <String, dynamic>{};
    if (state != null) params['state'] = state;
    if (mine) params['mine'] = 1;
    final result = await _call('/api/v1/tickets', params);
    final list = (result as List).cast<Map<String, dynamic>>();
    return list.map((j) => Ticket.fromJson(j)).toList();
  }

  Future<Ticket> getTicketDetail(int ticketId) async {
    final result = await _call('/api/v1/ticket/$ticketId', {});
    return Ticket.fromJson(result as Map<String, dynamic>);
  }

  Future<void> assignToMe(int ticketId) async {
    await _call('/api/v1/ticket/$ticketId/assign', {});
  }

  Future<Map<String, dynamic>> startSession(int ticketId, {String? supportMode}) async {
    final result = await _call('/api/v1/ticket/$ticketId/session/start', {
      if (supportMode != null) 'support_mode': supportMode,
    });
    return result as Map<String, dynamic>;
  }

  /// `note` (mô tả công việc đã làm) và `resolutionStatus` (một trong: resolved /
  /// partially_resolved / not_resolved / escalated) đều BẮT BUỘC - backend
  /// (it.support.session.action_end_session) sẽ từ chối đóng session nếu thiếu.
  Future<Map<String, dynamic>> endSession(
    int ticketId, {
    required String note,
    required String resolutionStatus,
  }) async {
    final result = await _call('/api/v1/ticket/$ticketId/session/end', {
      'note': note,
      'resolution_status': resolutionStatus,
    });
    return result as Map<String, dynamic>;
  }

  Future<void> markDone(int ticketId) async {
    await _call('/api/v1/ticket/$ticketId/done', {});
  }

  // ---------------- Chat ----------------

  Future<List<ChatMessage>> getMessages(int ticketId) async {
    final result = await _call('/api/v1/ticket/$ticketId/messages', {});
    final list = (result as List).cast<Map<String, dynamic>>();
    return list.map((j) => ChatMessage.fromJson(j)).toList();
  }

  Future<void> postMessage(int ticketId, String body) async {
    await _call('/api/v1/ticket/$ticketId/message', {'body': body});
  }

  // ---------------- Realtime (long-polling) ----------------

  Future<String> getRealtimeChannel(int ticketId) async {
    final result = await _call('/api/v1/ticket/$ticketId/realtime_channel', {});
    return (result as Map)['channel'] as String;
  }

  Future<String> getDispatchChannel() async {
    final result = await _call('/api/v1/dispatch_channel', {});
    return (result as Map)['channel'] as String;
  }

  /// Long-polling: request này có thể treo trên server vài chục giây chờ event mới,
  /// nên dùng timeout dài hơn các API khác.
  Future<List<dynamic>> poll(List<String> channels, {int last = 0}) async {
    final result = await _call(
      '/api/v1/poll',
      {'channels': channels, 'last': last},
      timeout: const Duration(seconds: 65),
    );
    return result as List<dynamic>;
  }

  // ---------------- Bookings (Manager-only) ----------------

  Future<List<BookingRequest>> getBookingRequests() async {
    final result = await _call('/api/v1/booking/list', {});
    final list = (result as List).cast<Map<String, dynamic>>();
    return list.map((j) => BookingRequest.fromJson(j)).toList();
  }

  Future<Map<String, dynamic>> createTicketFromBooking(int bookingId) async {
    final result = await _call('/api/v1/booking/$bookingId/create_ticket', {});
    return result as Map<String, dynamic>;
  }
}
