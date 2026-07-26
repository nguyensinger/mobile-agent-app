// lib/screens/booking_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_request.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import 'ticket_detail_screen.dart';

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  final ApiService _api = ApiService();
  List<BookingRequest> _bookings = [];
  bool _loading = true;
  String? _error;
  int? _confirmingBookingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final bookings = await _api.getBookingRequests();
      setState(() {
        _bookings = bookings;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _confirmBooking(BookingRequest booking) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bookingConfirmDialogTitle),
        content: Text(l10n.bookingConfirmDialogContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancelButton)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.confirmButton)),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _confirmingBookingId = booking.id);
    try {
      final result = await _api.createTicketFromBooking(booking.id);
      await _load();
      final ticketId = result['ticket_id'] as int?;
      if (ticketId != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TicketDetailScreen(ticketId: ticketId)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _confirmingBookingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingRequestsTitle)),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 48, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: Text(l10n.retryButton)),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: _bookings.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 80),
                Icon(Icons.event_available, size: 48, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 12),
                Center(child: Text(l10n.emptyBookingRequests, textAlign: TextAlign.center)),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: _bookings.length,
              itemBuilder: (context, i) => _BookingCard(
                booking: _bookings[i],
                loading: _confirmingBookingId == _bookings[i].id,
                onConfirm: () => _confirmBooking(_bookings[i]),
              ),
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingRequest booking;
  final bool loading;
  final VoidCallback onConfirm;

  const _BookingCard({required this.booking, required this.loading, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateLabel = booking.requestedStart != null
        ? DateFormat('EEE, MMM d, h:mm a').format(booking.requestedStart!)
        : '';
    final contactLine = [booking.phone, booking.email]
        .where((s) => s != null && s.isNotEmpty)
        .join(' · ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(dateLabel, style: Theme.of(context).textTheme.labelLarge)),
                Chip(
                  label: Text(l10n.hoursLabel(booking.duration.toStringAsFixed(1))),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                  labelStyle: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(booking.contactLabel, style: Theme.of(context).textTheme.titleMedium),
            if (contactLine.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(contactLine, style: Theme.of(context).textTheme.bodySmall),
            ],
            if (booking.message != null && booking.message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(booking.message!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: loading ? null : onConfirm,
                icon: loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(l10n.bookingConfirmButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
