import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import 'time_request_d_model.dart';

export 'time_request_d_model.dart';

/// Detail + approve/reject for a school Early/Late record (push only).
class TimeRequestDWidget extends StatefulWidget {
  const TimeRequestDWidget({super.key});

  static String routeName = 'TimeRequestD';
  static String routePath = '/timeRequestD';

  @override
  State<TimeRequestDWidget> createState() => _TimeRequestDWidgetState();
}

class _TimeRequestDWidgetState extends State<TimeRequestDWidget> {
  late TimeRequestDModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TimeRequestDModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  SchoolTimeRequestEntry? _entry(MockState m, String? tid) {
    if (tid == null || tid.isEmpty) return null;
    try {
      return m.schoolTimeRequests.firstWhere((e) => e.id == tid);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tid = GoRouterState.of(context).uri.queryParameters['tid'];
    final mock = context.watch<MockState>();
    final e = _entry(mock, tid);

    return Scaffold(
      backgroundColor: GateFlowColors.surface,
      appBar: AppBar(
        backgroundColor: GateFlowColors.brandPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Request details',
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20),
        ),
      ),
      body: e == null
          ? const Center(child: Text('Request not found (mock)'))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.childName,
                      style: GoogleFonts.outfit(
                          fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${e.grade} · ${e.isEarly ? 'Early' : 'Late'} window',
                      style: GoogleFonts.inter(
                          color: GateFlowColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(icon: Icons.schedule, label: 'Time', value: e.timeLabel),
                    _InfoRow(icon: Icons.message_outlined, label: 'Reason', value: e.reason),
                    _InfoRow(icon: Icons.person_outline, label: 'Requested by', value: e.requestedBy),
                    _InfoRow(icon: Icons.flag_outlined, label: 'Status', value: e.status.name),
                    const Spacer(),
                    if (e.status == RequestStatus.pending) ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            context
                                .read<MockState>()
                                .updateSchoolTimeRequest(e.id, RequestStatus.approved);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Approved (mock)')),
                            );
                            context.safePop();
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Approve'),
                          style: FilledButton.styleFrom(
                            backgroundColor: GateFlowColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context
                                .read<MockState>()
                                .updateSchoolTimeRequest(e.id, RequestStatus.rejected);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Declined (mock)')),
                            );
                            context.safePop();
                          },
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Decline'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: GateFlowColors.danger,
                          ),
                        ),
                      ),
                    ] else
                      Text(
                        'No further actions · status is final for this MVP row.',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: GateFlowColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: GateFlowColors.brandPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: GateFlowColors.textTertiary),
                ),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
