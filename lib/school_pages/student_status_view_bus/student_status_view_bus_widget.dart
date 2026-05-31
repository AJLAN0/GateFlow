import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/mock_state.dart';
import 'student_status_view_bus_model.dart';
export 'student_status_view_bus_model.dart';

class StudentStatusViewBusWidget extends StatefulWidget {
  const StudentStatusViewBusWidget({super.key});

  static String routeName = 'StudentStatusViewBus';
  static String routePath = '/studentStatusViewBus';

  @override
  State<StudentStatusViewBusWidget> createState() =>
      _StudentStatusViewBusWidgetState();
}

class _StudentStatusViewBusWidgetState
    extends State<StudentStatusViewBusWidget> {
  late StudentStatusViewBusModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StudentStatusViewBusModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    final sid = GoRouterState.of(context).uri.queryParameters['sid'];
    Student? student;
    if (sid != null) {
      try {
        student = mock.students.firstWhere((s) => s.id == sid);
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: Color(0xFF0C3451),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 60,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'View Student Status ',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.outfit(
                    fontWeight:
                        FlutterFlowTheme.of(context).titleLarge.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleLarge.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  fontSize: 24,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).titleLarge.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).alternate,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFF0C3451),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student?.name ?? 'Unknown student',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Text(
                                  student != null
                                      ? '${student.grade} • ID: ${student.id}'
                                      : '—',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ].divide(SizedBox(height: 4)),
                            ),
                          ),
                        ].divide(SizedBox(width: 12)),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.w600,
                              ),
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          for (final step in _statusSteps)
                            _statusCard(
                              context,
                              icon: step.icon,
                              title: step.title,
                              description: step.description,
                              active: student?.status == step.status,
                            ),
                        ].divide(SizedBox(height: 12)),
                      ),
                    ].divide(SizedBox(height: 8)),
                  ),
                ]
                    .divide(SizedBox(height: 16))
                    .addToStart(SizedBox(height: 16))
                    .addToEnd(SizedBox(height: 24)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const List<_StatusStep> _statusSteps = [
    _StatusStep(StudentStatus.atHome, Icons.home_outlined, 'At Home',
        'The student is at home.'),
    _StatusStep(StudentStatus.onBusToSchool, Icons.directions_bus, 'On Bus',
        'The student is on the bus to school.'),
    _StatusStep(StudentStatus.atSchool, Icons.menu_book, 'At School',
        'Student is currently in school grounds.'),
    _StatusStep(StudentStatus.onBusToHome, Icons.directions_bus_filled,
        'On Bus Home', 'The student is on the bus home.'),
    _StatusStep(StudentStatus.pickedUpByCar, Icons.directions_car_rounded,
        'Picked Up', 'The student was picked up by car.'),
  ];

  Widget _statusCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool active,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: active
            ? Color(0xFF0C3451).withValues(alpha: 0.05)
            : FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? Color(0xFF0C3451) : FlutterFlowTheme.of(context).alternate,
          width: active ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: active
                    ? Color(0xFF0C3451)
                    : FlutterFlowTheme.of(context).secondaryText,
                shape: BoxShape.circle,
              ),
              child: Align(
                alignment: AlignmentDirectional(0, 0),
                child: Icon(
                  icon,
                  color: FlutterFlowTheme.of(context).info,
                  size: 24,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w600,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    description,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ].divide(SizedBox(height: 4)),
              ),
            ),
            if (active)
              Icon(
                Icons.check_circle,
                color: Color(0xFF0C3451),
                size: 24,
              ),
          ].divide(SizedBox(width: 12)),
        ),
      ),
    );
  }
}

class _StatusStep {
  const _StatusStep(this.status, this.icon, this.title, this.description);
  final StudentStatus status;
  final IconData icon;
  final String title;
  final String description;
}
