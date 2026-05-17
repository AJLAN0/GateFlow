import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import '../request_status/request_status_widget.dart';
import 'parent_requests_list_model.dart';

export 'parent_requests_list_model.dart';

/// Root list for parent pickup/dismissal requests (Bottom Nav destination).
///
/// Tabs open **this** route; detail timeline is [RequestStatusWidget] pushed
/// with `rid` query parameter — no bottom navigation on detail.
class ParentRequestsListWidget extends StatefulWidget {
  const ParentRequestsListWidget({super.key});

  static String routeName = 'ParentRequestsList';
  static String routePath = '/parentRequestsList';

  @override
  State<ParentRequestsListWidget> createState() =>
      _ParentRequestsListWidgetState();
}

class _ParentRequestsListWidgetState extends State<ParentRequestsListWidget> {
  late ParentRequestsListModel _model;
  final _searchCtrl = TextEditingController();
  String _q = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ParentRequestsListModel());
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
    final list = mock.requests.reversed.where((r) {
      if (_q.isEmpty) return true;
      final n = _q.toLowerCase();
      return mock.demoChildName(r.studentId).toLowerCase().contains(n) ||
          r.type.toLowerCase().contains(n) ||
          r.status.name.contains(n);
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: GateFlowColors.surface,
        appBar: AppBar(
          backgroundColor: GateFlowColors.brandPrimary,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'My Requests',
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
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _q = v),
                  decoration: InputDecoration(
                    hintText: 'Search by child, type, or status',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: GateFlowColors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: GateFlowColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: GateFlowColors.divider),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No requests match your search.',
                            style: GoogleFonts.inter(
                                color: GateFlowColors.textSecondary),
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        children: [
                          for (var i = 0; i < list.length; i++) ...[
                            if (i > 0) const SizedBox(height: 10),
                            Builder(
                              builder: (context) {
                                final r = list[i];
                                return _RequestRow(
                                  childName: mock.demoChildName(r.studentId),
                                  type: r.type,
                                  status: r.status,
                                  time: r.timeLabel ?? '—',
                                  onTap: () => context.pushNamed(
                                    RequestStatusWidget.routeName,
                                    queryParameters: {'rid': r.id},
                                  ),
                                );
                              },
                            ),
                          ],
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

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.childName,
    required this.type,
    required this.status,
    required this.time,
    required this.onTap,
  });

  final String childName;
  final String type;
  final RequestStatus status;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _tone(status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
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
                  color: GateFlowColors.brandPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.event_note_rounded,
                    color: GateFlowColors.brandPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: GateFlowColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$childName · $time',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: GateFlowColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
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

  (Color bg, Color fg, String label) _tone(RequestStatus s) {
    switch (s) {
      case RequestStatus.pending:
        return (GateFlowColors.pending, GateFlowColors.pendingText, 'Pending');
      case RequestStatus.approved:
        return (
          GateFlowColors.approved,
          GateFlowColors.approvedText,
          'Approved'
        );
      case RequestStatus.rejected:
        return (
          GateFlowColors.rejected,
          GateFlowColors.rejectedText,
          'Rejected'
        );
    }
  }
}
