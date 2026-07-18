// lib/models/ticket_labels.dart
//
// Helper lấy label hiển thị (đã dịch) cho field priority/state của Ticket.
// Tách riêng khỏi model Ticket vì cần BuildContext để truy cập AppLocalizations -
// model dữ liệu thuần không nên phụ thuộc vào UI/ngôn ngữ hiển thị.

import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';
import 'ticket.dart';

extension TicketLabels on Ticket {
  String priorityLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (priority) {
      case '0':
        return l10n.priorityLow;
      case '2':
        return l10n.priorityHigh;
      case '3':
        return l10n.priorityUrgent;
      default:
        return l10n.priorityNormal;
    }
  }

  String stateLabel(BuildContext context) {
    return ticketStateLabel(context, state);
  }
}

/// Dùng trực tiếp khi chỉ có state (String) mà không có toàn bộ object Ticket,
/// ví dụ khi hiển thị state của 1 session hoặc dữ liệu phụ khác.
String ticketStateLabel(BuildContext context, String state) {
  final l10n = AppLocalizations.of(context);
  switch (state) {
    case 'new':
      return l10n.stateNew;
    case 'assigned':
      return l10n.stateAssigned;
    case 'in_progress':
      return l10n.stateInProgress;
    case 'paused':
      return l10n.statePaused;
    case 'done':
      return l10n.stateDone;
    case 'cancelled':
      return l10n.stateCancelled;
    default:
      return state;
  }
}
