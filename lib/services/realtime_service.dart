// lib/services/realtime_service.dart

import 'dart:async';
import 'api_service.dart';

/// Quản lý 1 vòng lặp long-polling cho 1 channel duy nhất tại 1 thời điểm.
/// Dùng cho cả channel dispatch (ticket mới) và channel của 1 ticket cụ thể (chat, đổi trạng thái).
class RealtimeService {
  final ApiService _api = ApiService();
  StreamController<List<dynamic>>? _controller;
  bool _stopped = true;
  String? _activeChannel;

  Stream<List<dynamic>> subscribe(String channel) {
    // Dừng vòng lặp cũ (nếu có) trước khi bắt đầu lắng nghe channel mới.
    stop();
    _stopped = false;
    _activeChannel = channel;
    _controller = StreamController<List<dynamic>>.broadcast(onCancel: stop);
    _loop(channel);
    return _controller!.stream;
  }

  Future<void> _loop(String channel) async {
    int last = 0;
    while (!_stopped && _activeChannel == channel) {
      try {
        final notifications = await _api.poll([channel], last: last);
        if (_stopped || _activeChannel != channel) break;
        if (notifications.isNotEmpty) {
          for (final n in notifications) {
            if (n is Map && n['id'] != null) {
              final id = n['id'] as int;
              if (id > last) last = id;
            }
          }
          _controller?.add(notifications);
        }
      } catch (e) {
        // Lỗi mạng tạm thời (mất kết nối, server restart...) - chờ rồi thử lại,
        // không làm crash app hoặc dừng hẳn polling.
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  void stop() {
    _stopped = true;
    _activeChannel = null;
    _controller?.close();
    _controller = null;
  }
}
