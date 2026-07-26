// lib/models/booking_request.dart

class BookingRequest {
  final int id;
  final String name;
  final String? companyType;
  final String? companyName;
  final String? email;
  final String? phone;
  final DateTime? requestedStart;
  final double duration;
  final String? message;

  BookingRequest({
    required this.id,
    required this.name,
    this.companyType,
    this.companyName,
    this.email,
    this.phone,
    this.requestedStart,
    this.duration = 1.0,
    this.message,
  });

  /// "ABC Nail Salon (Nguyen Van A)" nếu có company, ngược lại chỉ tên liên hệ -
  /// cùng quy ước hiển thị với Desktop Agent App (renderer.js: contactLabel).
  String get contactLabel =>
      (companyName != null && companyName!.isNotEmpty) ? '$companyName ($name)' : name;

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    // Odoo trả về false (bool) thay vì null khi field rỗng — cần xử lý cả 2 trường hợp
    String? odooStr(dynamic v) => (v == null || v == false) ? null : v.toString();

    DateTime? parseUtc(dynamic v) {
      final s = odooStr(v);
      if (s == null) return null;
      // Odoo trả chuỗi UTC-naive "YYYY-MM-DD HH:MM:SS" - ép kiểu UTC tường minh
      // trước khi parse rồi để DateTime tự quy đổi ra giờ local khi hiển thị,
      // tránh bị lệch theo offset (giống cách Desktop Agent App xử lý
      // requested_start trong renderer.js: formatBookingTime).
      return DateTime.parse('${s.replaceAll(' ', 'T')}Z').toLocal();
    }

    return BookingRequest(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      companyType: odooStr(json['company_type']),
      companyName: odooStr(json['company_name']),
      email: odooStr(json['email']),
      phone: odooStr(json['phone']),
      requestedStart: parseUtc(json['requested_start']),
      duration: (json['duration'] as num?)?.toDouble() ?? 1.0,
      message: odooStr(json['message']),
    );
  }
}
