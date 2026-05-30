import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/role_bottom_nav.dart';
import '../../shared/school_student_row_card.dart';
import '../../shared/student_status_helpers.dart';
import '../student_status_view_bus/student_status_view_bus_widget.dart';
import '../student_status_view_bus_car/student_status_view_bus_car_widget.dart';
import 'student_status_model.dart';

export 'student_status_model.dart';

enum _StudentFilterKey { all, atSchool, onBus, atHome, pending }

class StudentStatusWidget extends StatefulWidget {
  const StudentStatusWidget({super.key});

  static String routeName = 'StudentStatus';
  static String routePath = '/studentStatus';

  @override
  State<StudentStatusWidget> createState() => _StudentStatusWidgetState();
}

class _StudentStatusWidgetState extends State<StudentStatusWidget> {
  late StudentStatusModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  _StudentFilterKey _filter = _StudentFilterKey.all;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StudentStatusModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  bool _passesFilter(MockState mock, Student s) {
    switch (_filter) {
      case _StudentFilterKey.all:
        return true;
      case _StudentFilterKey.atSchool:
        return s.status == StudentStatus.atSchool;
      case _StudentFilterKey.onBus:
        return s.status == StudentStatus.onBusToSchool ||
            s.status == StudentStatus.onBusToHome;
      case _StudentFilterKey.atHome:
        return s.status == StudentStatus.atHome ||
            s.status == StudentStatus.pickedUpByCar;
      case _StudentFilterKey.pending:
        return mock.studentHasPendingPickupRequest(s);
    }
  }

  List<Student> _visible(MockState mock) {
    final q = (_model.textController?.text ?? '').trim().toLowerCase();
    return mock.students.where((s) {
      if (!_passesFilter(mock, s)) return false;
      if (q.isEmpty) return true;
      final bundle = '${s.name} ${s.grade} ${s.id}'.toLowerCase();
      return bundle.contains(q);
    }).toList();
  }

  void _openDetails(BuildContext context, Student s) {
    if (studentUsesBusRoster(s)) {
      context.pushNamed(
        StudentStatusViewBusWidget.routeName,
        queryParameters: {'sid': s.id},
      );
    } else {
      context.pushNamed(
        StudentStatusViewBusCarWidget.routeName,
        queryParameters: {'sid': s.id},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    final list = _visible(mock);

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
            'Student status',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
          elevation: 0,
        ),
        bottomNavigationBar: const RoleBottomNav(current: 'monitor'),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TextFormField(
                  controller: _model.textController,
                  focusNode: _model.textFieldFocusNode,
                  onChanged: (_) => EasyDebounce.debounce(
                    'stu-status-q',
                    const Duration(milliseconds: 280),
                    () => safeSetState(() {}),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search name, grade, or student ID…',
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: Color(0xFF57636C)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: GateFlowColors.divider),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _filter == _StudentFilterKey.all,
                      onTap: () =>
                          safeSetState(() => _filter = _StudentFilterKey.all),
                    ),
                    _FilterChip(
                      label: 'At school',
                      selected: _filter == _StudentFilterKey.atSchool,
                      onTap: () => safeSetState(
                          () => _filter = _StudentFilterKey.atSchool),
                    ),
                    _FilterChip(
                      label: 'On bus',
                      selected: _filter == _StudentFilterKey.onBus,
                      onTap: () =>
                          safeSetState(() => _filter = _StudentFilterKey.onBus),
                    ),
                    _FilterChip(
                      label: 'At home',
                      selected: _filter == _StudentFilterKey.atHome,
                      onTap: () => safeSetState(
                          () => _filter = _StudentFilterKey.atHome),
                    ),
                    _FilterChip(
                      label: 'Pending',
                      selected: _filter == _StudentFilterKey.pending,
                      onTap: () => safeSetState(
                          () => _filter = _StudentFilterKey.pending),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  '${list.length} student${list.length == 1 ? '' : 's'}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: GateFlowColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                          'No students match this filter.',
                          style: GoogleFonts.inter(
                            color: GateFlowColors.textTertiary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final s = list[i];
                          return SchoolStudentRowCard(
                            student: s,
                            mock: mock,
                            onOpenDetails: () => _openDetails(context, s),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? GateFlowColors.brandPrimary : Colors.white,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color:
                    selected ? GateFlowColors.brandPrimary : GateFlowColors.divider,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : GateFlowColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
