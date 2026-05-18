import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/status_pill.dart';
import 'parent_verification_model.dart';

export 'parent_verification_model.dart';

/// Gate pickup verification: mock scan UI + ID/phone directory lookup + queue release.
class ParentVerificationWidget extends StatefulWidget {
  const ParentVerificationWidget({super.key});

  static String routeName = 'ParentVerification';
  static String routePath = '/parentVerification';

  @override
  State<ParentVerificationWidget> createState() =>
      _ParentVerificationWidgetState();
}

class _ParentVerificationWidgetState extends State<ParentVerificationWidget> {
  late ParentVerificationModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  GatePickupPersonProfile? _lookupResult;
  ParentRequest? _queueSelected;
  bool? _mockScanPositive;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ParentVerificationModel());
    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  StatusPill _reqPill(RequestStatus s) {
    switch (s) {
      case RequestStatus.pending:
        return const StatusPill(label: 'Pending', tone: StatusTone.pending);
      case RequestStatus.approved:
        return const StatusPill(label: 'Approved', tone: StatusTone.approved);
      case RequestStatus.rejected:
        return const StatusPill(label: 'Rejected', tone: StatusTone.rejected);
    }
  }

  List<ParentRequest> _filteredQueue(MockState m, String q) {
    final base = m.approvedParentRequestsAwaitingPickup();
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return base;
    return base.where((r) {
      final name = m.demoChildName(r.studentId).toLowerCase();
      final who = (r.pickupPersonSummary ?? '').toLowerCase();
      return name.contains(s) ||
          who.contains(s) ||
          r.type.toLowerCase().contains(s);
    }).toList();
  }

  void _lookupById(MockState mock) {
    FocusScope.of(context).unfocus();
    final raw = _model.textController1?.text ?? '';
    final hit = mock.lookupGatePickupPersonByNationalId(raw);
    setState(() {
      _lookupResult = hit;
      _mockScanPositive = null;
      _queueSelected = null;
    });
  }

  void _lookupByPhone(MockState mock) {
    FocusScope.of(context).unfocus();
    final raw = _model.textController2?.text ?? '';
    final hit = mock.lookupGatePickupPersonByPhone(raw);
    setState(() {
      _lookupResult = hit;
      _mockScanPositive = null;
      _queueSelected = null;
    });
  }

  void _simulateQr(MockState mock) {
    FocusScope.of(context).unfocus();
    final hit =
        mock.lookupGatePickupPersonByNationalId('9876543210'); // demo guardian
    setState(() {
      _lookupResult = hit;
      _model.textController1?.text = hit?.nationalId ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    final queueQ = _model.textController3?.text ?? '';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: GateFlowColors.brandPrimary,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            buttonSize: 56,
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 26),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'Verify pickup',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              Text(
                'Scan mode',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: GateFlowColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 3 / 3.4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: GateFlowColors.brandAccent.withValues(alpha: .5),
                        width: 2),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ScanFramePainter(),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_scanner_rounded,
                                color: Colors.white.withValues(alpha: 0.85),
                                size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Align ID / QR within the frame',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Camera preview (mock)',
                              style: GoogleFonts.inter(
                                  color: Colors.white38, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              FFButtonWidget(
                onPressed: () => _simulateQr(mock),
                text: 'Simulate successful scan',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 48,
                  color: GateFlowColors.brandPrimary,
                  textStyle: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Manual verification',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: GateFlowColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try National ID `1234567890` (parent) or `9876543210` (guardian).\nPhone: `+966 50 111 2233` or `0500004411`.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: GateFlowColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'National ID / Iqama',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: GateFlowColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _model.textController1,
                focusNode: _model.textFieldFocusNode1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter ID number',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FFButtonWidget(
                onPressed: () => _lookupById(mock),
                text: 'Verify by ID',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 46,
                  color: GateFlowColors.brandAccent,
                  textStyle: GoogleFonts.inter(
                    color: GateFlowColors.brandPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Phone number',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: GateFlowColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _model.textController2,
                focusNode: _model.textFieldFocusNode2,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+9665XXXXXXXX',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FFButtonWidget(
                onPressed: () => _lookupByPhone(mock),
                text: 'Verify by phone',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 46,
                  color: GateFlowColors.surface,
                  textStyle: GoogleFonts.inter(
                    color: GateFlowColors.brandPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                  borderSide: const BorderSide(color: GateFlowColors.divider),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              if (_lookupResult != null) ...[
                const SizedBox(height: 22),
                _PersonResultCard(profile: _lookupResult!),
              ],
              const SizedBox(height: 28),
              const Divider(height: 32),
              Text(
                'Approved pickup queue',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _model.textController3,
                focusNode: _model.textFieldFocusNode3,
                onChanged: (_) => safeSetState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search guardian or student…',
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: Color(0xFF57636C)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (_filteredQueue(mock, queueQ).isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    mock.approvedParentRequestsAwaitingPickup().isEmpty &&
                            mock.requests
                                .where((r) => r.status == RequestStatus.approved)
                                .isNotEmpty
                        ? 'All approved pickups are already released.'
                        : 'No approved pickup request found.',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: GateFlowColors.textSecondary,
                    ),
                  ),
                ),
              ..._filteredQueue(mock, queueQ).map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() {
                          _queueSelected = r;
                          _mockScanPositive = null;
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: GateFlowColors.divider),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mock.demoChildName(r.studentId),
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      r.type,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color:
                                            GateFlowColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _reqPill(r.status),
                                  ],
                                ),
                              ),
                              Icon(
                                _queueSelected?.id == r.id
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: _queueSelected?.id == r.id
                                    ? GateFlowColors.brandPrimary
                                    : GateFlowColors.divider,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
              if (_queueSelected != null) ...[
                const SizedBox(height: 14),
                Text(
                  'Confirm pickup person',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GateFlowColors.brandPrimary.withValues(alpha: .92),
                        GateFlowColors.brandPrimarySoft,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.qr_code_scanner_rounded,
                              color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Mock scanner',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Simulate reading the pickup person’s QR for the selected queue row.',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 12.8,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: () => safeSetState(
                                  () => _mockScanPositive = true),
                              text: 'Valid scan',
                              options: FFButtonOptions(
                                height: 44,
                                color: Colors.white,
                                textStyle: GoogleFonts.inter(
                                  color: GateFlowColors.brandPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: () => safeSetState(
                                  () => _mockScanPositive = false),
                              text: 'Invalid scan',
                              options: FFButtonOptions(
                                height: 44,
                                color:
                                    Colors.white.withValues(alpha: 0.18),
                                textStyle: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (_mockScanPositive == true) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: GateFlowColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const StatusPill(
                          label: 'Verified',
                          tone: StatusTone.success,
                          icon: Icons.verified_rounded,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mock.guardianProfile.fullName,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Authorized pickup for ${mock.demoChildName(_queueSelected!.studentId)}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: GateFlowColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${_queueSelected!.type} · ${_queueSelected!.timeLabel ?? '—'}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FFButtonWidget(
                          onPressed: () {
                            final ok = mock.releaseStudentAfterVerification(
                                _queueSelected!.id);
                            if (!ok || !mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                backgroundColor: GateFlowColors.success,
                                content: Text(
                                  'Student released · ${_queueSelected!.type} marked complete.',
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            );
                            setState(() {
                              _queueSelected = null;
                              _mockScanPositive = null;
                            });
                          },
                          text: 'Confirm · release student',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 52,
                            color: GateFlowColors.success,
                            textStyle: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_mockScanPositive == false) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            GateFlowColors.rejectedText.withValues(alpha: .35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_rounded,
                            color: GateFlowColors.rejectedText),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Unauthorized pickup — no matching approved request for this person (mock).',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonResultCard extends StatelessWidget {
  const _PersonResultCard({required this.profile});

  final GatePickupPersonProfile profile;

  @override
  Widget build(BuildContext context) {
    final kindLabel =
        profile.kind == GatePickupPersonKind.parent ? 'Parent' : 'Guardian';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GateFlowColors.divider),
        boxShadow: const [
          BoxShadow(color: Color(0x0F0C3451), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusPill(
            label: kindLabel,
            tone: profile.kind == GatePickupPersonKind.parent
                ? StatusTone.info
                : StatusTone.approved,
            icon: Icons.badge_rounded,
          ),
          const SizedBox(height: 12),
          Text(
            profile.fullName,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ID · ${profile.nationalId}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: GateFlowColors.textSecondary,
            ),
          ),
          Text(
            'Phone · ${profile.displayPhone}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: GateFlowColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Linked children',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: GateFlowColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            profile.linkedChildren.join(', '),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.authorizationLabel,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: GateFlowColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Allowed: ${profile.allowedActionLabel}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: GateFlowColors.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width * 0.18, size.height * 0.22,
        size.width * 0.64, size.height * 0.42);
    final paint = Paint()
      ..color = GateFlowColors.brandAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const corner = 28.0;
    final path = Path()
      ..moveTo(rect.left, rect.top + corner)
      ..lineTo(rect.left, rect.top)
      ..lineTo(rect.left + corner, rect.top)
      ..moveTo(rect.right - corner, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.top + corner)
      ..moveTo(rect.right, rect.bottom - corner)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.right - corner, rect.bottom)
      ..moveTo(rect.left + corner, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.bottom - corner);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
