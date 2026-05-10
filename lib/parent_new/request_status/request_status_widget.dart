import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import 'request_status_model.dart';

export 'request_status_model.dart';

/// Request **detail** timeline (push only — no BottomNavigationBar).
///
/// Open with `queryParameters['rid']` from [ParentRequestsListWidget].
/// If `rid` is missing, falls back to the most recent mock request.
class RequestStatusWidget extends StatefulWidget {
  const RequestStatusWidget({super.key});

  static String routeName = 'RequestStatus';
  static String routePath = '/requestStatus';

  @override
  State<RequestStatusWidget> createState() => _RequestStatusWidgetState();
}

class _RequestStatusWidgetState extends State<RequestStatusWidget> {
  late RequestStatusModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RequestStatusModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  ParentRequest? _resolve(MockState m, String? rid) {
    if (rid != null && rid.isNotEmpty) {
      try {
        return m.requests.firstWhere((r) => r.id == rid);
      } catch (_) {}
    }
    return m.requests.isNotEmpty ? m.requests.last : null;
  }

  @override
  Widget build(BuildContext context) {
    final rid = GoRouterState.of(context).uri.queryParameters['rid'];
    final mock = context.watch<MockState>();
    final req = _resolve(mock, rid);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: GateFlowColors.surface,
        appBar: AppBar(
          backgroundColor: GateFlowColors.brandPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'Request details',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20),
          ),
        ),
        body: req == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No request data (mock). Submit a request first.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: GateFlowColors.textSecondary),
                  ),
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryCard(mock: mock, r: req),
                      const SizedBox(height: 16),
                      Text(
                        'Timeline',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: GateFlowColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Timeline(
                        r: req,
                        released: mock.releasedPickupRequestIds.contains(req.id),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.mock, required this.r});

  final MockState mock;
  final ParentRequest r;

  @override
  Widget build(BuildContext context) {
    final name = mock.demoChildName(r.studentId);
    final grade = mock.demoChild(r.studentId)?.grade ?? '—';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GateFlowColors.divider),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 6),
            color: Color(0x0F0C3451),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.type.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: GateFlowColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: GateFlowColors.textPrimary,
            ),
          ),
          Text(
            grade,
            style: GoogleFonts.inter(
                fontSize: 13, color: GateFlowColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip(label: 'Time', value: r.timeLabel ?? '—'),
              _MiniChip(
                  label: 'Pickup', value: r.pickupPersonSummary ?? '—'),
              _MiniChip(label: 'Status', value: r.status.name),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: GateFlowColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GateFlowColors.divider),
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
              fontSize: 12, color: GateFlowColors.textSecondary),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(
                text: value,
                style: TextStyle(color: GateFlowColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.r, required this.released});

  final ParentRequest r;
  final bool released;

  @override
  Widget build(BuildContext context) {
    final steps = <_TStep>[
      _TStep(
        title: 'Submitted',
        subtitle: 'You sent the request',
        done: true,
      ),
      _TStep(
        title: 'School review',
        subtitle: r.status == RequestStatus.pending
            ? 'Awaiting staff review'
            : 'Staff processed your request',
        done: r.status != RequestStatus.pending,
        highlight: r.status == RequestStatus.pending,
      ),
      _TStep(
        title: 'Decision',
        subtitle: r.status == RequestStatus.approved
            ? 'Approved for your pickup window'
            : r.status == RequestStatus.rejected
                ? 'Not approved · contact the school desk'
                : 'Pending decision',
        done: r.status == RequestStatus.approved ||
            r.status == RequestStatus.rejected,
        warning: r.status == RequestStatus.rejected,
      ),
      _TStep(
        title: 'Gate release',
        subtitle: released
            ? 'Student released · request completed'
            : (r.status == RequestStatus.approved
                ? 'Waiting for pickup verification'
                : '—'),
        done: released,
      ),
    ];

    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final last = i == steps.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: s.done
                        ? GateFlowColors.success
                        : GateFlowColors.divider,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: s.done
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                if (!last)
                  Container(
                      width: 2,
                      height: 48,
                      color: GateFlowColors.divider),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: s.warning
                        ? GateFlowColors.rejected.withValues(alpha: 0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GateFlowColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        s.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: GateFlowColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _TStep {
  _TStep({
    required this.title,
    required this.subtitle,
    required this.done,
    this.highlight = false,
    this.warning = false,
  });

  final String title;
  final String subtitle;
  final bool done;
  final bool highlight;
  final bool warning;
}
