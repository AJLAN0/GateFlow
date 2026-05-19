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
import 'view_childern_model.dart';

export 'view_childern_model.dart';

class ViewChildernWidget extends StatefulWidget {
  const ViewChildernWidget({super.key});

  static String routeName = 'ViewChildern';
  static String routePath = '/viewChildern';

  @override
  State<ViewChildernWidget> createState() => _ViewChildernWidgetState();
}

class _ViewChildernWidgetState extends State<ViewChildernWidget> {
  late ViewChildernModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ViewChildernModel());
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

              ...List.generate(children.length, (i) {
                final c = children[i];
                final isBus = c.transport == DemoChildTransport.bus;
                final linked = mock.studentMatchingDemoChild(c);
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
                    onAbsentTodayChanged: (v) {
                      context.read<MockState>().toggleChildAbsent(c.id, v);
                    },
                    statusBadge: linked != null
                        ? statusPillForSchoolStudent(linked)
                        : const StatusPill(
                            label: 'No live status',
                            tone: StatusTone.neutral,
                          ),
                    onTap: () {
                      context.pushNamed(
                        isBus ? BusWidget.routeName : CarWidget.routeName,
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

