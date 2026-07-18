// lib/widgets/ticket_card.dart

import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../models/ticket_labels.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  Color _priorityColor(BuildContext context) {
    switch (ticket.priority) {
      case '3':
        return Theme.of(context).colorScheme.error;
      case '2':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  Color _stateColor(BuildContext context) {
    switch (ticket.state) {
      case 'done':
        return Colors.green;
      case 'in_progress':
        return Theme.of(context).colorScheme.primary;
      case 'cancelled':
        return Theme.of(context).colorScheme.outline;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: _priorityColor(context), shape: BoxShape.circle),
                  ),
                  Expanded(
                    child: Text(
                      ticket.name,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  if (ticket.hasRunningSession)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.timer, size: 16, color: Colors.green),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                ticket.subject,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                ticket.customer,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    label: Text(ticket.stateLabel(context)),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: _stateColor(context).withValues(alpha: 0.12),
                    labelStyle: TextStyle(color: _stateColor(context), fontSize: 12),
                    side: BorderSide.none,
                  ),
                  if (ticket.supportType != null)
                    Chip(
                      label: Text(ticket.supportType!),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                  if (ticket.agent != null)
                    Chip(
                      avatar: const Icon(Icons.person, size: 14),
                      label: Text(ticket.agent!),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
