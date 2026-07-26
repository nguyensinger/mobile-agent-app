// lib/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';

/// Quản lý thông tin đăng nhập / cấu hình lưu cục bộ trên máy.
/// Mỗi IT support nên có API key riêng (tạo tại Odoo Settings > Users & Companies >
/// Users > [user đó] > Account Security > New API Key, chọn "Persistent Key") để
/// request.env.user trong backend đúng là người đang xử lý ticket khi start/end session.
///
/// QUAN TRỌNG: tên hiển thị của agent (agentName) KHÔNG được nhập tay - nó luôn được
/// lấy từ server qua API /api/v1/whoami ngay sau khi xác thực API key thành công, để
/// đảm bảo tên hiển thị luôn khớp đúng với chính user thật đứng sau API key đó. Nếu
/// cho phép tự nhập tay, người dùng có thể gõ sai/để trống, khiến logic "tin nhắn của
/// tôi" trong khung chat so sánh sai.
class AuthService {
  static const _keyBaseUrl = 'odoo_base_url';
  static const _keyApiKey = 'odoo_api_key';
  static const _keyAgentName = 'agent_name';
  static const _keyAgentUserId = 'agent_user_id';
  static const _keyIsManager = 'agent_is_manager';
  static const _keyLanguage = 'app_language';

  Future<bool> isConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString(_keyBaseUrl);
    final apiKey = prefs.getString(_keyApiKey);
    final agentName = prefs.getString(_keyAgentName);
    return baseUrl != null && baseUrl.isNotEmpty && apiKey != null && apiKey.isNotEmpty &&
        agentName != null && agentName.isNotEmpty;
  }

  Future<void> saveServerCredentials({
    required String baseUrl,
    required String apiKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, baseUrl.trim());
    await prefs.setString(_keyApiKey, apiKey.trim());
  }

  /// Lưu identity thật lấy từ server (gọi sau khi xác thực API key thành công qua
  /// ApiService.whoami()) - đây là nguồn duy nhất để biết "agent này là ai".
  /// isManager quyết định có hiện màn hình Booking Requests hay không (tính năng
  /// chỉ dành cho IT Support Manager, backend cũng chặn ở API nếu không đúng nhóm).
  Future<void> saveAgentIdentity({
    required int userId,
    required String name,
    bool isManager = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAgentUserId, userId);
    await prefs.setString(_keyAgentName, name);
    await prefs.setBool(_keyIsManager, isManager);
  }

  Future<String?> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBaseUrl);
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyApiKey);
  }

  Future<String?> getAgentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAgentName);
  }

  Future<int?> getAgentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAgentUserId);
  }

  Future<bool> getIsManager() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsManager) ?? false;
  }

  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, langCode);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBaseUrl);
    await prefs.remove(_keyApiKey);
    await prefs.remove(_keyAgentName);
    await prefs.remove(_keyAgentUserId);
    await prefs.remove(_keyIsManager);
  }
}
