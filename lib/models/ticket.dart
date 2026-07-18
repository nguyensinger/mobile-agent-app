// lib/models/ticket.dart

class Ticket {
  final int id;
  final String name;
  final String subject;
  final String? description;
  final String customer;
  final String? device;
  final String? endUser;
  final String? supportType;
  final String priority; // '0'..'3'
  final String state; // new, assigned, in_progress, paused, done, cancelled
  final String? agent;
  final double totalDuration;
  final double billableHours;
  final double amountTotal;
  final bool hasRunningSession;

  Ticket({
    required this.id,
    required this.name,
    required this.subject,
    this.description,
    required this.customer,
    this.device,
    this.endUser,
    this.supportType,
    required this.priority,
    required this.state,
    this.agent,
    this.totalDuration = 0,
    this.billableHours = 0,
    this.amountTotal = 0,
    this.hasRunningSession = false,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    // Odoo trả về false (bool) thay vì null khi field rỗng — cần xử lý cả 2 trường hợp
    String? odooStr(dynamic v) => (v == null || v == false) ? null : v.toString();

    return Ticket(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      description: odooStr(json['description']),
      customer: odooStr(json['customer']) ?? '',
      device: odooStr(json['device']),
      endUser: odooStr(json['end_user']),
      supportType: odooStr(json['support_type']),
      priority: (json['priority'] ?? '1').toString(),
      state: json['state']?.toString() ?? 'new',
      agent: odooStr(json['agent']),
      totalDuration: (json['total_duration'] as num?)?.toDouble() ?? 0,
      billableHours: (json['billable_hours'] as num?)?.toDouble() ?? 0,
      amountTotal: (json['amount_total'] as num?)?.toDouble() ?? 0,
      hasRunningSession: json['has_running_session'] == true,
    );
  }
}