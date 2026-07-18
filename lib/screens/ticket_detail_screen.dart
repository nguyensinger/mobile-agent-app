// lib/screens/ticket_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../models/ticket_labels.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/realtime_service.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final ApiService _api = ApiService();
  final RealtimeService _realtime = RealtimeService();
  final _chatInputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  Ticket? _ticket;
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sessionActionLoading = false;
  String? _myAgentName;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _realtime.stop();
    _chatInputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _myAgentName = await AuthService().getAgentName();
    await _loadAll();
    _subscribeRealtime();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final ticket = await _api.getTicketDetail(widget.ticketId);
      final messages = await _api.getMessages(widget.ticketId);
      setState(() {
        _ticket = ticket;
        _messages = messages;
        _loading = false;
        _error = null;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _subscribeRealtime() async {
    try {
      final channel = await _api.getRealtimeChannel(widget.ticketId);
      _realtime.subscribe(channel).listen((_) {
        // Có event mới (chat, đổi trạng thái, session start/end từ thiết bị khác) -> tải lại
        _loadAll();
      });
    } catch (_) {
      // Bỏ qua nếu không subscribe được - người dùng vẫn có thể kéo để tải lại thủ công.
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _assignToMe() async {
    setState(() => _sessionActionLoading = true);
    try {
      await _api.assignToMe(widget.ticketId);
      await _loadAll();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _sessionActionLoading = false);
    }
  }

  Future<void> _startSession() async {
    final mode = await _pickSupportMode();
    if (mode == null) return;
    setState(() => _sessionActionLoading = true);
    try {
      await _api.startSession(widget.ticketId, supportMode: mode);
      await _loadAll();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _sessionActionLoading = false);
    }
  }

  Future<String?> _pickSupportMode() {
    final l10n = AppLocalizations.of(context);
    return showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.supportModeDialogTitle),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'online'),
            child: Row(children: [const Icon(Icons.wifi), const SizedBox(width: 12), Text(l10n.supportModeOnline)]),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'onsite'),
            child: Row(children: [const Icon(Icons.directions_car), const SizedBox(width: 12), Text(l10n.supportModeOnsite)]),
          ),
        ],
      ),
    );
  }

  Future<void> _endSession() async {
    final result = await _askEndSessionDetails();
    if (result == null) return; // user cancelled
    setState(() => _sessionActionLoading = true);
    try {
      await _api.endSession(
        widget.ticketId,
        note: result.note,
        resolutionStatus: result.resolutionStatus,
      );
      await _loadAll();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _sessionActionLoading = false);
    }
  }

  /// Dialog "End Session" - resolution status (dropdown) và note (mô tả công việc)
  /// đều BẮT BUỘC trước khi có thể xác nhận. Trả về null nếu người dùng bấm Cancel.
  Future<_EndSessionResult?> _askEndSessionDetails() {
    final l10n = AppLocalizations.of(context);
    final noteCtrl = TextEditingController();
    String? resolutionStatus;
    String? errorText;

    return showDialog<_EndSessionResult>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(l10n.endSessionDialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.endSessionResolutionStatusLabel,
                        style: Theme.of(ctx).textTheme.labelMedium),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: resolutionStatus,
                      decoration: InputDecoration(
                        hintText: l10n.endSessionResolutionStatusHint,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem(value: 'resolved', child: Text(l10n.resolutionStatusResolved)),
                        DropdownMenuItem(
                            value: 'partially_resolved', child: Text(l10n.resolutionStatusPartiallyResolved)),
                        DropdownMenuItem(value: 'not_resolved', child: Text(l10n.resolutionStatusNotResolved)),
                        DropdownMenuItem(value: 'escalated', child: Text(l10n.resolutionStatusEscalated)),
                      ],
                      onChanged: (v) => setDialogState(() => resolutionStatus = v),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.endSessionNoteHint, style: Theme.of(ctx).textTheme.labelMedium),
                    const SizedBox(height: 4),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(errorText!, style: TextStyle(color: Theme.of(ctx).colorScheme.error, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancelButton)),
                FilledButton(
                  onPressed: () {
                    if (resolutionStatus == null) {
                      setDialogState(() => errorText = l10n.endSessionResolutionRequiredError);
                      return;
                    }
                    final note = noteCtrl.text.trim();
                    if (note.isEmpty) {
                      setDialogState(() => errorText = l10n.endSessionNoteRequiredError);
                      return;
                    }
                    Navigator.pop(ctx, _EndSessionResult(note: note, resolutionStatus: resolutionStatus!));
                  },
                  child: Text(l10n.confirmButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _markDone() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.markDoneDialogTitle),
        content: Text(l10n.markDoneDialogContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancelButton)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.confirmButton)),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _sessionActionLoading = true);
    try {
      await _api.markDone(widget.ticketId);
      await _loadAll();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _sessionActionLoading = false);
    }
  }

  Future<void> _sendChat() async {
    final body = _chatInputCtrl.text.trim();
    if (body.isEmpty) return;
    _chatInputCtrl.clear();
    try {
      await _api.postMessage(widget.ticketId, body);
      await _loadAll();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_ticket?.name ?? l10n.ticketFallbackTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    _buildTicketHeader(l10n),
                    _buildActionBar(l10n),
                    const Divider(height: 1),
                    Expanded(child: _buildChat(l10n)),
                    _buildChatInput(l10n),
                  ],
                ),
    );
  }

  Widget _buildTicketHeader(AppLocalizations l10n) {
    final t = _ticket!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.subject, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${t.customer} · ${t.device ?? l10n.noDeviceLabel}',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(t.stateLabel(context)), visualDensity: VisualDensity.compact),
              Chip(label: Text(t.priorityLabel(context)), visualDensity: VisualDensity.compact),
              if (t.supportType != null)
                Chip(label: Text(t.supportType!), visualDensity: VisualDensity.compact),
              Chip(
                label: Text(l10n.hoursLabel(t.totalDuration.toStringAsFixed(2))),
                visualDensity: VisualDensity.compact,
                avatar: const Icon(Icons.timer_outlined, size: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(AppLocalizations l10n) {
    final t = _ticket!;
    final isClosed = t.state == 'done' || t.state == 'cancelled';
    if (isClosed) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          if (t.agent == null)
            Expanded(
              child: FilledButton.icon(
                onPressed: _sessionActionLoading ? null : _assignToMe,
                icon: const Icon(Icons.how_to_reg),
                label: Text(l10n.assignToMeButton),
              ),
            )
          else if (!t.hasRunningSession)
            Expanded(
              child: FilledButton.icon(
                onPressed: _sessionActionLoading ? null : _startSession,
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.startButton),
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
              ),
            )
          else
            Expanded(
              child: FilledButton.icon(
                onPressed: _sessionActionLoading ? null : _endSession,
                icon: const Icon(Icons.stop),
                label: Text(l10n.endButton),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          const SizedBox(width: 8),
          if (t.agent != null)
            OutlinedButton.icon(
              onPressed: _sessionActionLoading ? null : _markDone,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(l10n.markDoneButton),
            ),
        ],
      ),
    );
  }

  Widget _buildChat(AppLocalizations l10n) {
    if (_messages.isEmpty) {
      return Center(child: Text(l10n.noMessagesYet));
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(12),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final m = _messages[i];
        final isMine = m.author == _myAgentName;
        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isMine
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.author,
                  style: TextStyle(
                    fontSize: 11,
                    color: isMine ? Colors.white70 : Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  m.body,
                  style: TextStyle(color: isMine ? Colors.white : null),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatInput(AppLocalizations l10n) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatInputCtrl,
                decoration: InputDecoration(
                  hintText: l10n.chatInputHint,
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendChat(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _sendChat, icon: const Icon(Icons.send)),
          ],
        ),
      ),
    );
  }
}

/// Kết quả người dùng nhập trong dialog End Session (_askEndSessionDetails).
class _EndSessionResult {
  final String note;
  final String resolutionStatus;
  _EndSessionResult({required this.note, required this.resolutionStatus});
}
