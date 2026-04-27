import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../../shared/child_card.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/role_bottom_nav.dart';
import 'view_childern_g_model.dart';

export 'view_childern_g_model.dart';

/// Children's tracking page for guardians.
///
/// Shows a clean list of child cards. Each card is tappable and routes to
/// the correct guardian-side details screen based on transportation type
/// (Bus → BusGWidget, Private Car → CarGWidget). Attendance toggles work
/// independently from card navigation.
class ViewChildernGWidget extends StatefulWidget {
  const ViewChildernGWidget({super.key});

  static String routeName = 'ViewChildernG';
  static String routePath = '/viewChildernG';

  @override
  State<ViewChildernGWidget> createState() => _ViewChildernGWidgetState();
}

class _ViewChildernGWidgetState extends State<ViewChildernGWidget> {
  late ViewChildernGModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ViewChildernGModel());
    _model.checkboxValue1 ??= true;
    _model.checkboxValue2 ??= false;
    _model.checkboxValue3 ??= true;
    _model.checkboxValue4 ??= false;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <_GChild>[
      _GChild(
        name: 'Saad Khaled',
        grade: 'Grade 6',
        transport: ChildTransport.car,
        emoji: '🧒',
        tint: const Color(0xFFE8F4FD),
        getValue: () => _model.checkboxValue1 ?? true,
        setValue: (v) => _model.checkboxValue1 = v,
      ),
      _GChild(
        name: 'Sara Khaled',
        grade: 'Grade 6',
        transport: ChildTransport.car,
        emoji: '👧',
        tint: const Color(0xFFFFE9E9),
        getValue: () => _model.checkboxValue2 ?? false,
        setValue: (v) => _model.checkboxValue2 = v,
      ),
      _GChild(
        name: 'Noah Khaled',
        grade: 'Grade 1',
        transport: ChildTransport.bus,
        emoji: '🧒',
        tint: const Color(0xFFE6F4EA),
        getValue: () => _model.checkboxValue3 ?? true,
        setValue: (v) => _model.checkboxValue3 = v,
      ),
      _GChild(
        name: 'Lama Khaled',
        grade: 'Grade 1',
        transport: ChildTransport.bus,
        emoji: '👧',
        tint: const Color(0xFFFCE4EC),
        getValue: () => _model.checkboxValue4 ?? false,
        setValue: (v) => _model.checkboxValue4 = v,
      ),
    ];

    final presentCount = children.where((c) => c.getValue()).length;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: GateFlowColors.surface,
        bottomNavigationBar: const RoleBottomNav(current: 'children'),
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
            "Children's Tracking",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _GuardianSummaryHeader(
                total: children.length,
                present: presentCount,
              ),
              const SizedBox(height: 16),
              ...children.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ChildCard(
                      name: c.name,
                      grade: c.grade,
                      transport: c.transport,
                      emoji: c.emoji,
                      avatarTint: c.tint,
                      attendancePresent: c.getValue(),
                      onAttendanceChanged: (v) {
                        safeSetState(() => c.setValue(v));
                      },
                      onTap: () {
                        context.pushNamed(
                          c.transport == ChildTransport.bus
                              ? BusGWidget.routeName
                              : CarGWidget.routeName,
                        );
                      },
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _GChild {
  _GChild({
    required this.name,
    required this.grade,
    required this.transport,
    required this.emoji,
    required this.tint,
    required this.getValue,
    required this.setValue,
  });

  final String name;
  final String grade;
  final ChildTransport transport;
  final String emoji;
  final Color tint;
  final bool Function() getValue;
  final void Function(bool) setValue;
}

class _GuardianSummaryHeader extends StatelessWidget {
  const _GuardianSummaryHeader({required this.total, required this.present});

  final int total;
  final int present;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [GateFlowColors.brandPrimary, GateFlowColors.brandPrimarySoft],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Attendance",
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$present of $total marked present',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: GateFlowColors.brandAccent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$total kids',
              style: GoogleFonts.inter(
                color: GateFlowColors.brandPrimaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
