// lib/screens/ticket_list_screen.dart

import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/realtime_service.dart';
import '../widgets/ticket_card.dart';
import '../l10n/app_localizations.dart';
import 'ticket_detail_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'booking_requests_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final RealtimeService _realtime = RealtimeService();
  late TabController _tabController;

  List<Ticket> _myTickets = [];
  List<Ticket> _unassignedTickets = [];
  bool _loading = true;
  String? _error;
  int _newTicketBadge = 0;
  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTickets();
    _subscribeDispatch();
    _loadManagerFlag();
  }

  Future<void> _loadManagerFlag() async {
    final isManager = await AuthService().getIsManager();
    if (mounted) setState(() => _isManager = isManager);
  }

  @override
  void dispose() {
    _realtime.stop();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _subscribeDispatch() async {
    try {
      final channel = await _api.getDispatchChannel();
      _realtime.subscribe(channel).listen((notifications) {
        // Có ticket mới được tạo -> báo hiệu và tự refresh danh sách "chưa gán"
        setState(() => _newTicketBadge += notifications.length);
        _loadTickets(silent: true);
      });
    } catch (_) {
      // Không chặn UI nếu không subscribe được - người dùng vẫn pull-to-refresh thủ công được.
    }
  }

  Future<void> _loadTickets({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final mine = await _api.getTickets(mine: true);
      final unassigned = await _api.getTickets(state: 'new');
      setState(() {
        _myTickets = mine;
        _unassignedTickets = unassigned.where((t) => t.agent == null).toList();
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

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    // pushAndRemoveUntil((route) => false) xoá sạch stack, kể cả route hiện tại của
    // chính widget này -> context ở đây sẽ bị huỷ (defunct) ngay sau lệnh này chạy
    // xong. Vì vậy onLoggedIn KHÔNG được dùng lại context đó (Navigator.of trên context
    // đã huỷ chỉ bị assert chặn ở debug mode - ở release mode assert bị strip nên rơi
    // thẳng vào "Null check operator used on a null value" khi đăng nhập lại thành công).
    // Dùng routeContext (context riêng của chính LoginScreen, còn sống lúc onLoggedIn
    // chạy) và push (không phải pop, vì stack đã rỗng, không có gì để quay lại) một
    // TicketListScreen mới, giống hệt cách _RootRouter xử lý lần đăng nhập đầu tiên.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (routeContext) => LoginScreen(
          onLoggedIn: () {
            Navigator.of(routeContext).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const TicketListScreen()),
              (route) => false,
            );
          },
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _openTicket(Ticket ticket) async {
    setState(() => _newTicketBadge = 0);
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TicketDetailScreen(ticketId: ticket.id)),
    );
    _loadTickets(silent: true); // refresh sau khi quay lại (trạng thái có thể đã đổi)
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _openBookingRequests() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BookingRequestsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(l10n.appBarTitle),
            if (_newTicketBadge > 0) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 10,
                backgroundColor: Theme.of(context).colorScheme.error,
                child: Text(
                  '$_newTicketBadge',
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => _loadTickets()),
          if (_isManager)
            IconButton(
              icon: const Icon(Icons.event_available),
              tooltip: l10n.bookingRequestsTooltip,
              onPressed: _openBookingRequests,
            ),
          IconButton(icon: const Icon(Icons.settings), onPressed: _openSettings),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.tabMine(_myTickets.length)),
            Tab(text: l10n.tabUnassigned(_unassignedTickets.length)),
          ],
        ),
      ),
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
              FilledButton(onPressed: () => _loadTickets(), child: Text(l10n.retryButton)),
            ],
          ),
        ),
      );
    }
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTicketList(_myTickets, emptyText: l10n.emptyMyTickets),
        _buildTicketList(_unassignedTickets, emptyText: l10n.emptyUnassignedTickets),
      ],
    );
  }

  Widget _buildTicketList(List<Ticket> tickets, {required String emptyText}) {
    return RefreshIndicator(
      onRefresh: () => _loadTickets(),
      child: tickets.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 80),
                Icon(Icons.inbox, size: 48, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 12),
                Center(child: Text(emptyText, textAlign: TextAlign.center)),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: tickets.length,
              itemBuilder: (context, i) => TicketCard(
                ticket: tickets[i],
                onTap: () => _openTicket(tickets[i]),
              ),
            ),
    );
  }
}
