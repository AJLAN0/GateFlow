import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/school_student_row_card.dart';
import '../../shared/student_status_helpers.dart';
import 'student_status_view_bus_model.dart';

export 'student_status_view_bus_model.dart';

enum _BusFilter { all, atSchool, onBus, atHome, pending }

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
  _BusFilter _filter = _BusFilter.all;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StudentStatusViewBusModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  bool _pass(MockState mock, Student s) {
    if (!studentUsesBusRoster(s)) return false;
    switch (_filter) {
      case _BusFilter.all:
        return true;
      case _BusFilter.atSchool:
        return s.status == StudentStatus.atSchool;
      case _BusFilter.onBus:
        return s.status == StudentStatus.onBusToSchool ||
            s.status == StudentStatus.onBusToHome;
      case _BusFilter.atHome:
        return s.status == StudentStatus.atHome;
      case _BusFilter.pending:
        return mock.studentHasPendingPickupRequest(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    final q = (_model.textController?.text ?? '').trim().toLowerCase();
    final list = mock.students.where((s) {
      if (!_pass(mock, s)) return false;
      if (q.isEmpty) return true;
      return '${s.name} ${s.grade} ${s.id}'.toLowerCase().contains(q);
    }).toList();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: GateFlowColors.surface,
        appBar: AppBar(
          backgroundColor: GateFlowColors.brandPrimary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 56,
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 26),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'Bus student status',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: TextFormField(
                  controller: _model.textController,
                  focusNode: _model.textFieldFocusNode,
                  onChanged: (_) => EasyDebounce.debounce(
                    'bus-view-q',
                    const Duration(milliseconds: 260),
                    () => safeSetState(() {}),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search bus riders…',
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: Color(0xFF57636C)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _Chip(
                      label: 'All',
                      onTap: () => safeSetState(() => _filter = _BusFilter.all),
                      sel: _filter == _BusFilter.all,
                    ),
                    _Chip(
                      label: 'At school',
                      onTap: () =>
                          safeSetState(() => _filter = _BusFilter.atSchool),
                      sel: _filter == _BusFilter.atSchool,
                    ),
                    _Chip(
                      label: 'On bus',
                      onTap: () => safeSetState(() => _filter = _BusFilter.onBus),
                      sel: _filter == _BusFilter.onBus,
                    ),
                    _Chip(
                      label: 'At home',
                      onTap: () =>
                          safeSetState(() => _filter = _BusFilter.atHome),
                      sel: _filter == _BusFilter.atHome,
                    ),
                    _Chip(
                      label: 'Pending',
                      onTap: () =>
                          safeSetState(() => _filter = _BusFilter.pending),
                      sel: _filter == _BusFilter.pending,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => SchoolStudentRowCard(
                    student: list[i],
                    mock: mock,
                    onOpenDetails: () {}, // Already scoped to bus list (mock drill-down optional)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onTap,
    required this.sel,
  });

  final String label;
  final VoidCallback onTap;
  final bool sel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: sel ? GateFlowColors.brandPrimary : Colors.white,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: sel ? Colors.white : GateFlowColors.textPrimary,
        ),
        side: BorderSide(
          color: sel ? GateFlowColors.brandPrimary : GateFlowColors.divider,
        ),
      ),
    );
  }
}
