// lib/models/chat_message.dart

class ChatMessage {
  final int id;
  final String author;
  final String body;
  final DateTime? date;

  ChatMessage({required this.id, required this.author, required this.body, this.date});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Odoo trả về false (bool) thay vì null khi field rỗng — xử lý cả 2 trường hợp.
    String? odooStr(dynamic v) => (v == null || v == false) ? null : v.toString();

    DateTime? parsedDate;
    final rawDate = odooStr(json['date']);
    if (rawDate != null) {
      try {
        parsedDate = DateTime.parse(rawDate);
      } catch (_) {
        parsedDate = null;
      }
    }
    return ChatMessage(
      id: json['id'] as int,
      author: odooStr(json['author']) ?? 'IT Support',
      body: _stripHtml(odooStr(json['body']) ?? ''),
      date: parsedDate,
    );
  }

  // Odoo message_post lưu body dạng HTML (thường bọc trong <p>...</p>), nên loại bỏ tag
  // để hiển thị dạng text thuần trên app di động cho gọn. Đổi <br>/</p> thành newline
  // TRƯỚC khi xoá các tag còn lại - nếu không, tin nhắn nhiều dòng (vd tin chào tự động
  // khi End User tạo ticket từ Desktop Client) sẽ bị dồn lại thành 1 dòng dài.
  static String _stripHtml(String htmlText) {
    final withBreaks = htmlText
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>\s*<p[^>]*>', caseSensitive: false), '\n\n');
    return withBreaks.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}