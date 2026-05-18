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
import 'student_status_view_bus_car_model.dart';

export 'student_status_view_bus_car_model.dart';

enum _CarFilter { all, atSchool, atHome, pending }

class StudentStatusViewBusCarWidget extends StatefulWidget {
  const StudentStatusViewBusCarWidget({super.key});

  static String routeName = 'StudentStatusViewBusCar';
  static String routePath = '/studentStatusViewBusCar';

  @override
  State<StudentStatusViewBusCarWidget> createState() =>
      _StudentStatusViewBusCarWidgetState();
}

class _StudentStatusViewBusCarWidgetState
    extends State<StudentStatusViewBusCarWidget> {
  late StudentStatusViewBusCarModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  _CarFilter _filter = _CarFilter.all;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StudentStatusViewBusCarModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  bool _pass(MockState mock, Student s) {
    if (studentUsesBusRoster(s)) return false;
    switch (_filter) {
      case _CarFilter.all:
        return true;
      case _CarFilter.atSchool:
        return s.status == StudentStatus.atSchool;
      case _CarFilter.atHome:
        return s.status == StudentStatus.atHome ||
            s.status == StudentStatus.pickedUpByCar;
      case _CarFilter.pending:
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
            'Car / gate student status',
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
                    'car-view-q',
                    const Duration(milliseconds: 260),
                    () => safeSetState(() {}),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search car-line students…',
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
                    _CarChip(
                      label: 'All',
                      sel: _filter == _CarFilter.all,
                      onTap: () =>
                          safeSetState(() => _filter = _CarFilter.all),
                    ),
                    _CarChip(
                      label: 'At school',
                      sel: _filter == _CarFilter.atSchool,
                      onTap: () =>
                          safeSetState(() => _filter = _CarFilter.atSchool),
                    ),
                    _CarChip(
                      label: 'At home',
                      sel: _filter == _CarFilter.atHome,
                      onTap: () =>
                          safeSetState(() => _filter = _CarFilter.atHome),
                    ),
                    _CarChip(
                      label: 'Pending',
                      sel: _filter == _CarFilter.pending,
                      onTap: () =>
                          safeSetState(() => _filter = _CarFilter.pending),
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
                    onOpenDetails: () {},
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

class _CarChip extends StatelessWidget {
  const _CarChip({
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
