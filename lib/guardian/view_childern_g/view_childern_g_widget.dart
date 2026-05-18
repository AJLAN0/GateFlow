import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../../data/mock_state.dart';
import '../../shared/child_card.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/role_bottom_nav.dart';
import '../../shared/status_pill.dart';
import '../../shared/student_status_helpers.dart';
import 'view_childern_g_model.dart';

export 'view_childern_g_model.dart';

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
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  static const _emo = ['🧒', '👧', '🧒', '👧'];
  static const _tint = [
    Color(0xFFE8F4FD),
    Color(0xFFFFE9E9),
    Color(0xFFE6F4EA),
    Color(0xFFFCE4EC),
  ];

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    final children = mock.guardianLinkedDemoChildren();
    final presentCount =
        children.where((c) => !c.absentToday).length;

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
            'Assigned children',
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
              _GSummary(total: children.length, present: presentCount),
              const SizedBox(height: 16),
              Text(
                'Guardians cannot edit school records — view & note attendance only (mock).',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: GateFlowColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(children.length, (i) {
                final c = children[i];
                final isBus = c.transport == DemoChildTransport.bus;
                final linked = mock.studentMatchingDemoChild(c);
                final intent = mock.guardianPickupIntentFor(c.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ChildCard(
                        name: c.name,
                        grade: c.grade,
                        transport:
                            isBus ? ChildTransport.bus : ChildTransport.car,
                        emoji: _emo[i % _emo.length],
                        avatarTint: _tint[i % _tint.length],
                        absentToday: c.absentToday,
                        allowAbsentToggle: false,
                        onAbsentTodayChanged: (_) {},
                        statusBadge: linked != null
                            ? statusPillForSchoolStudent(linked)
                            : const StatusPill(
                                label: 'No live status',
                                tone: StatusTone.neutral,
                              ),
                        onTap: () {
                          context.pushNamed(
                            isBus ? BusGWidget.routeName : CarGWidget.routeName,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: GateFlowColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gate action (mock)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: GateFlowColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => mock
                                        .setGuardianPickupIntent(
                                            c.id, GuardianPickupIntent.pick),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          GateFlowColors.brandPrimary,
                                      side: BorderSide(
                                        color: intent ==
                                                GuardianPickupIntent.pick
                                            ? GateFlowColors.brandAccent
                                            : GateFlowColors.divider,
                                        width:
                                            intent == GuardianPickupIntent.pick
                                                ? 2
                                                : 1,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Pick',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => mock
                                        .setGuardianPickupIntent(
                                            c.id, GuardianPickupIntent.drop),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          GateFlowColors.brandPrimary,
                                      side: BorderSide(
                                        color: intent ==
                                                GuardianPickupIntent.drop
                                            ? GateFlowColors.brandAccent
                                            : GateFlowColors.divider,
                                        width:
                                            intent == GuardianPickupIntent.drop
                                                ? 2
                                                : 1,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Drop',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              intent == GuardianPickupIntent.none
                                  ? 'Latest: none selected'
                                  : intent == GuardianPickupIntent.pick
                                      ? 'Latest: Pick-up intent logged'
                                      : 'Latest: Drop-off intent logged',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: GateFlowColors.brandPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _GSummary extends StatelessWidget {
  const _GSummary({required this.total, required this.present});

  final int total;
  final int present;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [GateFlowColors.brandPrimary, GateFlowColors.brandPrimarySoft],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$present of $total expected today',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
