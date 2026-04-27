import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/role_bottom_nav.dart';
import 'time_request_model.dart';

export 'time_request_model.dart';

/// School staff time-request review page.
///
/// Modernized: brand app bar, segmented tab control, live search,
/// reusable request rows, status pills, and clear empty states.
/// Each row is tappable and routes to the request detail screen.
class TimeRequestWidget extends StatefulWidget {
  const TimeRequestWidget({super.key});

  static String routeName = 'TimeRequest';
  static String routePath = '/timeRequest';

  @override
  State<TimeRequestWidget> createState() => _TimeRequestWidgetState();
}

class _TimeRequestWidgetState extends State<TimeRequestWidget>
    with TickerProviderStateMixin {
  late TimeRequestModel _model;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TimeRequestModel());
    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _model.dispose();
    super.dispose();
  }

  // Mock data — kept as in-file fixtures since the legacy page used the
  // exact same hardcoded items repeated across tabs.
  static const _earlyRequests = <_TimeRequest>[
    _TimeRequest(
      childName: 'Saad Ahmed',
      grade: 'Grade 4',
      reason: 'Doctor appointment',
      time: '12:30 PM',
      requestedBy: 'Khalid (Parent)',
    ),
    _TimeRequest(
      childName: 'Sara Khaled',
      grade: 'Grade 6',
      reason: 'Family event',
      time: '1:00 PM',
      requestedBy: 'Deem (Guardian)',
    ),
    _TimeRequest(
      childName: 'Omar Yousef',
      grade: 'Grade 2',
      reason: 'Medical follow-up',
      time: '11:45 AM',
      requestedBy: 'Yousef (Parent)',
    ),
    _TimeRequest(
      childName: 'Lama Khaled',
      grade: 'Grade 1',
      reason: 'Family travel',
      time: '12:00 PM',
      requestedBy: 'Khalid (Parent)',
    ),
  ];

  static const _lateRequests = <_TimeRequest>[
    _TimeRequest(
      childName: 'Noah Khaled',
      grade: 'Grade 1',
      reason: 'Traffic delay',
      time: '8:30 AM',
      requestedBy: 'Khalid (Parent)',
    ),
    _TimeRequest(
      childName: 'Lina Adel',
      grade: 'Grade 3',
      reason: 'Personal',
      time: '8:45 AM',
      requestedBy: 'Adel (Parent)',
    ),
    _TimeRequest(
      childName: 'Yousef Ali',
      grade: 'Grade 5',
      reason: 'Doctor appointment',
      time: '9:15 AM',
      requestedBy: 'Ali (Parent)',
    ),
    _TimeRequest(
      childName: 'Maya Hassan',
      grade: 'Grade 2',
      reason: 'Late arrival',
      time: '8:50 AM',
      requestedBy: 'Hassan (Parent)',
    ),
  ];

  List<_TimeRequest> _filter(List<_TimeRequest> list) {
    if (_query.trim().isEmpty) return list;
    final q = _query.toLowerCase();
    return list
        .where((r) =>
            r.childName.toLowerCase().contains(q) ||
            r.grade.toLowerCase().contains(q) ||
            r.reason.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final earlyFiltered = _filter(_earlyRequests);
    final lateFiltered = _filter(_lateRequests);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: GateFlowColors.surface,
        bottomNavigationBar: const RoleBottomNav(current: 'requests'),
        appBar: AppBar(
          backgroundColor: GateFlowColors.brandPrimary,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 26),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'Early / Late Requests',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: _SearchField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SegmentedTabs(
                  controller: _model.tabBarController!,
                  earlyCount: earlyFiltered.length,
                  lateCount: lateFiltered.length,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _model.tabBarController,
                  children: [
                    _RequestList(
                      requests: earlyFiltered,
                      tone: const _Tone(
                        accent: GateFlowColors.warning,
                        chipBg: GateFlowColors.pending,
                        chipFg: GateFlowColors.pendingText,
                        label: 'Early',
                      ),
                    ),
                    _RequestList(
                      requests: lateFiltered,
                      tone: const _Tone(
                        accent: Color(0xFFD81B60),
                        chipBg: Color(0xFFFCE4EC),
                        chipFg: Color(0xFFD81B60),
                        label: 'Late',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeRequest {
  const _TimeRequest({
    required this.childName,
    required this.grade,
    required this.reason,
    required this.time,
    required this.requestedBy,
  });

  final String childName;
  final String grade;
  final String reason;
  final String time;
  final String requestedBy;
}

class _Tone {
  const _Tone({
    required this.accent,
    required this.chipBg,
    required this.chipFg,
    required this.label,
  });

  final Color accent;
  final Color chipBg;
  final Color chipFg;
  final String label;
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GateFlowColors.divider),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by name, grade, or reason',
          hintStyle: GoogleFonts.inter(
            fontSize: 13.5,
            color: GateFlowColors.textTertiary,
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: GateFlowColors.textTertiary, size: 22),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.controller,
    required this.earlyCount,
    required this.lateCount,
  });

  final TabController controller;
  final int earlyCount;
  final int lateCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GateFlowColors.divider),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: GateFlowColors.brandPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: GateFlowColors.textSecondary,
        labelStyle: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(text: 'Early ($earlyCount)'),
          Tab(text: 'Late ($lateCount)'),
        ],
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({required this.requests, required this.tone});

  final List<_TimeRequest> requests;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: GateFlowColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.inbox_outlined,
                    color: GateFlowColors.textTertiary, size: 32),
              ),
              const SizedBox(height: 14),
              Text(
                'No ${tone.label.toLowerCase()} requests',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: GateFlowColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You\'re all caught up.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: GateFlowColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemBuilder: (_, i) => _RequestRow(request: requests[i], tone: tone),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: requests.length,
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.request, required this.tone});

  final _TimeRequest request;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.pushNamed('TimeRequestD'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GateFlowColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tone.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tone.label == 'Early'
                      ? Icons.timer_outlined
                      : Icons.schedule_rounded,
                  color: tone.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.childName,
                            style: GoogleFonts.outfit(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: GateFlowColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tone.chipBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            request.time,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: tone.chipFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${request.grade} · ${request.reason}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: GateFlowColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 13, color: GateFlowColors.textTertiary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            request.requestedBy,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: GateFlowColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: GateFlowColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
