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

/// Gate pickup verification — ties to approved parent requests only (mock).
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

  ParentRequest? _selected;
  bool? _mockScanPositive;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ParentVerificationModel());
    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
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

  List<ParentRequest> _filtered(MockState m, String q) {
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

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    final query = _model.textController1?.text ?? '';

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
                'Approved requests queued for pickup',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: GateFlowColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pick a row, simulate a guardian QR scan, then release the student.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: GateFlowColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _model.textController1,
                focusNode: _model.textFieldFocusNode1,
                onChanged: (_) => safeSetState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search guardian or student…',
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: Color(0xFF57636C)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: GateFlowColors.divider, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: GateFlowColors.divider, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: GateFlowColors.brandPrimary.withValues(alpha: .45),
                        width: 1.3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_filtered(mock, query).isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: GateFlowColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.inbox_outlined,
                          size: 32, color: GateFlowColors.textTertiary),
                      const SizedBox(height: 10),
                      Text(
                        mock.approvedParentRequestsAwaitingPickup().isEmpty &&
                                mock.requests
                                    .where((r) =>
                                        r.status == RequestStatus.approved)
                                    .isNotEmpty
                            ? 'All approved pickups are already released.'
                            : 'No approved pickup request found.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: GateFlowColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ..._filtered(mock, query).map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() {
                          _selected = r;
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          color: GateFlowColors.textSecondary),
                                    ),
                                    const SizedBox(height: 8),
                                    _reqPill(r.status),
                                  ],
                                ),
                              ),
                              Icon(
                                _selected?.id == r.id
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: _selected?.id == r.id
                                    ? GateFlowColors.brandPrimary
                                    : GateFlowColors.divider,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
              if (_selected != null) ...[
                const SizedBox(height: 14),
                Text(
                  'Scan & confirm',
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
                        'Simulate reading the pickup person’s QR. Invalid scans stop before release.',
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
                          label: 'Verified guardian',
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
                          'Authorized pickup for ${mock.demoChildName(_selected!.studentId)}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: GateFlowColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${_selected!.type} · ${_selected!.timeLabel ?? '—'}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FFButtonWidget(
                          onPressed: () {
                            final ok = mock.releaseStudentAfterVerification(
                                _selected!.id);
                            if (!ok || !mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                backgroundColor: GateFlowColors.success,
                                content: Text(
                                  'Student released · ${_selected!.type} marked complete.',
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            );
                            setState(() {
                              _selected = null;
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
