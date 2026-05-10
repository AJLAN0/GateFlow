import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/role_bottom_nav.dart';
import '../time_request_d/time_request_d_widget.dart';
import 'time_request_model.dart';

export 'time_request_model.dart';

/// School staff early/late list (root for Requests tab).
class TimeRequestWidget extends StatefulWidget {
  const TimeRequestWidget({super.key});

  static String routeName = 'TimeRequest';
  static String routePath = '/timeRequest';

  @override
  State<TimeRequestWidget> createState() => _TimeRequestWidgetState();
}

class _TimeRequestWidgetState extends State<TimeRequestWidget>
    with SingleTickerProviderStateMixin {
  late TimeRequestModel _model;
  final _searchCtrl = TextEditingController();
  String _q = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TimeRequestModel());
    _model.tabBarController = TabController(length: 2, vsync: this)
      ..addListener(() => safeSetState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    final early = mock.schoolTimeRequests.where((e) => e.isEarly).toList();
    final late = mock.schoolTimeRequests.where((e) => !e.isEarly).toList();
    final filteredEarly = _filterList(early, _q);
    final filteredLate = _filterList(late, _q);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: GateFlowColors.surface,
        bottomNavigationBar: const RoleBottomNav(current: 'requests'),
        appBar: AppBar(
          backgroundColor: GateFlowColors.brandPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'Early / Late Requests',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _q = v),
                  decoration: InputDecoration(
                    hintText: 'Search name, reason, or requester',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: GateFlowColors.divider),
                  ),
                  child: TabBar(
                    controller: _model.tabBarController!,
                    indicator: BoxDecoration(
                      color: GateFlowColors.brandPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: GateFlowColors.textSecondary,
                    tabs: [
                      Tab(text: 'Early (${early.length})'),
                      Tab(text: 'Late (${late.length})'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _model.tabBarController,
                  children: [
                    _ListPane(items: filteredEarly, isEarly: true),
                    _ListPane(items: filteredLate, isEarly: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<SchoolTimeRequestEntry> _filterList(
      List<SchoolTimeRequestEntry> base, String raw) {
    final q = raw.trim().toLowerCase();
    if (q.isEmpty) return base;
    return base
        .where((e) =>
            e.childName.toLowerCase().contains(q) ||
            e.reason.toLowerCase().contains(q) ||
            e.requestedBy.toLowerCase().contains(q))
        .toList();
  }
}

class _ListPane extends StatelessWidget {
  const _ListPane({required this.items, required this.isEarly});

  final List<SchoolTimeRequestEntry> items;
  final bool isEarly;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No requests',
          style: GoogleFonts.inter(color: GateFlowColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final e = items[i];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.pushNamed(
              TimeRequestDWidget.routeName,
              queryParameters: {'tid': e.id},
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GateFlowColors.divider),
              ),
              child: Row(
                children: [
                  Icon(
                    isEarly ? Icons.timer_outlined : Icons.schedule_rounded,
                    color: isEarly ? GateFlowColors.warning : const Color(0xFFD81B60),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.childName,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Text(
                          '${e.grade} · ${e.reason}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: GateFlowColors.textSecondary),
                        ),
                        Text(
                          e.requestedBy,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: GateFlowColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        e.timeLabel,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: GateFlowColors.brandPrimary),
                      ),
                      _StatusMini(s: e.status),
                    ],
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: GateFlowColors.textTertiary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusMini extends StatelessWidget {
  const _StatusMini({required this.s});

  final RequestStatus s;

  @override
  Widget build(BuildContext context) {
    late String t;
    late Color c;
    switch (s) {
      case RequestStatus.pending:
        t = 'Pending';
        c = GateFlowColors.pendingText;
        break;
      case RequestStatus.approved:
        t = 'Approved';
        c = GateFlowColors.approvedText;
        break;
      case RequestStatus.rejected:
        t = 'Rejected';
        c = GateFlowColors.rejectedText;
        break;
    }
    return Text(
      t,
      style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w700, color: c),
    );
  }
}
