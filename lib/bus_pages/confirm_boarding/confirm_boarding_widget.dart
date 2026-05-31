import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/status_pill.dart';
import 'confirm_boarding_model.dart';

export 'confirm_boarding_model.dart';

/// Driver scan flow: pick a bus rider → record real status via [MockState].
class ConfirmBoardingWidget extends StatefulWidget {
  const ConfirmBoardingWidget({super.key});

  static String routeName = 'ConfirmBoarding';
  static String routePath = '/confirmBoarding';

  @override
  State<ConfirmBoardingWidget> createState() => _ConfirmBoardingWidgetState();
}

class _ConfirmBoardingWidgetState extends State<ConfirmBoardingWidget> {
  late ConfirmBoardingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  _ScanPhase _phase = _ScanPhase.camera;
  DriverScanOutcome? _outcome;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ConfirmBoardingModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sid = GoRouterState.of(context).uri.queryParameters['sid'];
      if (sid != null && sid.isNotEmpty && mounted) {
        final mock = context.read<MockState>();
        mock.resolveDriverBusContext();
        try {
          final s = mock.studentsOnDriverBus.firstWhere((e) => e.id == sid);
          _simulateScanFor(mock, s);
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _applyOutcome(DriverScanOutcome o) {
    setState(() {
      _outcome = o;
      _phase = _ScanPhase.summary;
    });
  }

  void _simulateScanFor(MockState mock, Student s) {
    final o = mock.recordDriverBoardingScan(s.id);
    _applyOutcome(o);
  }

  Future<void> _pickStudentAndScan(BuildContext context, MockState mock) async {
    mock.resolveDriverBusContext();
    final list = mock.studentsOnDriverBus;
    if (list.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students assigned to your bus yet.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final picked = await showModalBottomSheet<Student>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select student to scan',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...list.map((s) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: GateFlowColors.brandPrimary,
                        child: Text(
                          s.name.isNotEmpty ? s.name[0] : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(s.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${s.grade} · ${s.status.name}'),
                      onTap: () => Navigator.pop(ctx, s),
                    )),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null && mounted) {
      _simulateScanFor(mock, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    mock.resolveDriverBusContext();
    final riderCount = mock.studentsOnDriverBus.length;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: GateFlowColors.brandPrimary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 56,
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 26),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'Scan student',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: _phase == _ScanPhase.summary && _outcome != null
              ? _SummaryPane(
                  outcome: _outcome!,
                  onScanAnother: () => setState(() {
                    _phase = _ScanPhase.camera;
                    _outcome = null;
                  }),
                )
              : _CameraPane(
                  riderCount: riderCount,
                  onScan: () => _pickStudentAndScan(context, mock),
                  onManual: () => context.pushNamed(
                    AssignedStudentslistWidget.routeName,
                  ),
                ),
        ),
      ),
    );
  }
}

enum _ScanPhase { camera, summary }

class _CameraPane extends StatelessWidget {
  const _CameraPane({
    required this.riderCount,
    required this.onScan,
    required this.onManual,
  });

  final int riderCount;
  final VoidCallback onScan;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Scan updates student status on your bus ($riderCount riders)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: GateFlowColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner_rounded,
                            size: 72,
                            color: Colors.white.withValues(alpha: 0.35)),
                        Center(
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: GateFlowColors.brandAccent
                                    .withValues(alpha: 0.95),
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          left: 24,
                          right: 24,
                          child: Text(
                            'QR hardware optional · pick rider to record boarding/drop-off',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                FFButtonWidget(
                  onPressed: onScan,
                  text: 'Scan student',
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 54,
                    color: GateFlowColors.brandPrimary,
                    textStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    elevation: 0,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onManual,
              icon: const Icon(Icons.list_alt_rounded, size: 20),
              label: Text(
                'Pick from student list',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: GateFlowColors.brandPrimary,
                side: BorderSide(color: GateFlowColors.divider),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryPane extends StatelessWidget {
  const _SummaryPane({
    required this.outcome,
    required this.onScanAnother,
  });

  final DriverScanOutcome outcome;
  final VoidCallback onScanAnother;

  @override
  Widget build(BuildContext context) {
    final tone = outcome.warning ? StatusTone.rejected : StatusTone.success;
    final time =
        '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GateFlowColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      outcome.warning
                          ? Icons.warning_amber_rounded
                          : Icons.verified_rounded,
                      color: outcome.warning
                          ? GateFlowColors.warning
                          : GateFlowColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        outcome.title,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(outcome.studentName,
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(outcome.detail,
                    style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: GateFlowColors.textSecondary,
                        height: 1.35)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusPill(
                      label: outcome.warning ? 'Alert' : 'Status saved',
                      tone: tone,
                    ),
                    StatusPill(label: time, tone: StatusTone.neutral),
                  ],
                ),
                if (outcome.showStaffAlert) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'School staff notified via operational alert.',
                      style: GoogleFonts.inter(fontSize: 12.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          FFButtonWidget(
            onPressed: onScanAnother,
            text: 'Scan another student',
            options: FFButtonOptions(
              width: double.infinity,
              height: 52,
              color: GateFlowColors.brandPrimary,
              textStyle: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }
}
