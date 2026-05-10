import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../../data/mock_state.dart';
import '../../shared/child_card.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/role_bottom_nav.dart';
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
    final children = mock.parentDemoChildren;
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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ChildCard(
                    name: c.name,
                    grade: c.grade,
                    transport:
                        isBus ? ChildTransport.bus : ChildTransport.car,
                    emoji: _emo[i % _emo.length],
                    avatarTint: _tint[i % _tint.length],
                    absentToday: c.absentToday,
                    allowAbsentToggle: false,
                    onAbsentTodayChanged: (_) {},
                    onTap: () {
                      context.pushNamed(
                        isBus ? BusGWidget.routeName : CarGWidget.routeName,
                      );
                    },
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
