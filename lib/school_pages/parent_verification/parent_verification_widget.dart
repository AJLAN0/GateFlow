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

  bool _lookingUp = false;

  Future<void> _lookupById(MockState mock) async {
    FocusScope.of(context).unfocus();
    final raw = _model.textController1?.text ?? '';
    if (raw.trim().isEmpty) return;
    setState(() => _lookingUp = true);
    final hit = await mock.lookupGatePersonAsync(nationalId: raw);
    if (!mounted) return;
    setState(() {
      _lookupResult = hit;
      _mockScanPositive = null;
      _queueSelected = null;
      _lookingUp = false;
    });
    if (hit == null) _notFound();
  }

  Future<void> _lookupByPhone(MockState mock) async {
    FocusScope.of(context).unfocus();
    final raw = _model.textController2?.text ?? '';
    if (raw.trim().isEmpty) return;
    setState(() => _lookingUp = true);
    final hit = await mock.lookupGatePersonAsync(phone: raw);
    if (!mounted) return;
    setState(() {
      _lookupResult = hit;
      _mockScanPositive = null;
      _queueSelected = null;
      _lookingUp = false;
    });
    if (hit == null) _notFound();
  }

  Future<void> _simulateQr(MockState mock) async {
    FocusScope.of(context).unfocus();
    setState(() => _lookingUp = true);
    final hit =
        await mock.lookupGatePersonAsync(nationalId: '9876543210');
    if (!mounted) return;
    setState(() {
      _lookupResult = hit;
      _model.textController1?.text = hit?.nationalId ?? '';
      _lookingUp = false;
    });
    if (hit == null) _notFound();
  }

  void _notFound() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No matching person found.')),
    );
  }

  void _release(MockState mock, String childName) {
    Student? s;
    try {
      s = mock.students.firstWhere((st) => st.name == childName);
    } catch (_) {}
    if (s == null) return;

    ParentRequest? req;
    try {
      req = mock.approvedParentRequestsAwaitingPickup().firstWhere(
            (r) => mock.demoChildName(r.studentId) == childName ||
                r.studentId == s!.id,
          );
    } catch (_) {}

    if (req != null) {
      mock.releaseStudentAfterVerification(req.id);
    }
    mock.updateStudentStatus(s.id, StudentStatus.pickedUpByCar);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        backgroundColor: GateFlowColors.success,
        content: Text(
          '$childName released.',
          style: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
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
            'Person Verification',
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
                'Option 1: QR Verification',
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
              const SizedBox(height: 24),
              const Divider(height: 1, thickness: 1, color: GateFlowColors.divider),
              Text(
                'Option 2: Manual Verification',
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
                const SizedBox(height: 28),
                const Divider(height: 32),
                Text(
                  'Select Student(s):',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ..._lookupResult!.linkedChildren.map((childName) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: GateFlowColors.divider),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        childName,
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                                FFButtonWidget(
                                  onPressed: () => _release(mock, childName),
                                  text: 'Release',
                                  options: FFButtonOptions(
                                    height: 36,
                                    color: GateFlowColors.brandPrimary,
                                    textStyle: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
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
