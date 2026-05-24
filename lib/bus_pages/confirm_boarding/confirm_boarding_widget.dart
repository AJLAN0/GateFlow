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

/// Mock camera / QR scan flow for drivers (no real camera).
///
/// First scan in a session → On bus · Second → Dropped off · Third → alert.
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

  /// `camera` = scanning UI · `summary` = last outcome card.
  _ScanPhase _phase = _ScanPhase.camera;
  DriverScanOutcome? _outcome;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ConfirmBoardingModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  List<Student> _assigned(MockState m) {
    final busId = m.currentDriverBusId;
    if (busId == null || busId.isEmpty) return [];
    return m.students.where((s) => s.busId == busId).toList();
  }

  Student? _pickDefault(MockState m) {
    final list = _assigned(m);
    return list.isNotEmpty ? list.first : null;
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

  Future<void> _openManualPicker(BuildContext context) async {
    if (!context.mounted) return;
    context.pushNamed(AssignedStudentslistWidget.routeName);
  }

  String _statusReadable(StudentStatus s) {
    switch (s) {
      case StudentStatus.atHome:
        return 'At home';
      case StudentStatus.onBusToSchool:
        return 'On bus (to school)';
      case StudentStatus.atSchool:
        return 'At school';
      case StudentStatus.onBusToHome:
        return 'On bus (home)';
      case StudentStatus.pickedUpByCar:
        return 'Car pickup';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();

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
                  onSimulate: () {
                    final s = _pickDefault(mock);
                    if (s == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Assign students to the bus route first.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    _simulateScanFor(mock, s);
                  },
                  onManual: () => _openManualPicker(context),
                ),
        ),
      ),
    );
  }
}

enum _ScanPhase { camera, summary }

class _CameraPane extends StatelessWidget {
  const _CameraPane({
    required this.onSimulate,
    required this.onManual,
  });

  final VoidCallback onSimulate;
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
                  'Align the QR code inside the frame',
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
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 22,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.06),
                                  Colors.black.withValues(alpha: 0.35),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Icon(Icons.photo_camera_outlined,
                            size: 56, color: Colors.white.withValues(alpha: 0.35)),
                        Center(
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: GateFlowColors.brandAccent.withValues(alpha: 0.95),
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
                            'Camera preview (mock) · Indoor lighting simulated',
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
                  onPressed: onSimulate,
                  text: 'Simulate scan',
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
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: Text(
                'Manual Scan',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                ),
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
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F0C3451),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
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
                          color: GateFlowColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  outcome.studentName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  outcome.detail,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: GateFlowColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusPill(
                      label: outcome.warning ? 'Alert' : 'Updated',
                      tone: tone,
                      icon: outcome.warning
                          ? Icons.report_gmailerrorred_outlined
                          : Icons.check_circle_outline,
                    ),
                    StatusPill(
                      label: time,
                      tone: StatusTone.neutral,
                      icon: Icons.schedule_rounded,
                    ),
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
                      border: Border.all(
                        color: GateFlowColors.warning.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      'School staff has been alerted in Operations (mock).',
                      style: GoogleFonts.inter(
                        fontSize: 12.8,
                        color: GateFlowColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
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
