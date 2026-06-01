import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/role_bottom_nav.dart';
import '../../shared/status_pill.dart';
import 'assigned_studentslist_model.dart';

export 'assigned_studentslist_model.dart';

/// Bus driver assigned roster (filtered + searchable, mock).
class AssignedStudentslistWidget extends StatefulWidget {
  const AssignedStudentslistWidget({super.key});

  static String routeName = 'AssignedStudentslist';
  static String routePath = '/assignedStudentslist';

  @override
  State<AssignedStudentslistWidget> createState() =>
      _AssignedStudentslistWidgetState();
}

class _AssignedStudentslistWidgetState
    extends State<AssignedStudentslistWidget> {
  late AssignedStudentslistModel _model;

  static const String _all = 'all';
  static const Map<String, String> _filters = {
    _all: 'All statuses',
    'home': 'At home',
    'school': 'At school',
    'bus': 'On bus',
  };

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String _statusKey = _all;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AssignedStudentslistModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  StatusPill _pillForStudent(Student s) {
    switch (s.status) {
      case StudentStatus.atHome:
        return const StatusPill(label: 'At home', tone: StatusTone.success);
      case StudentStatus.atSchool:
        return const StatusPill(label: 'At school', tone: StatusTone.info);
      case StudentStatus.waitingForDismissal:
        return const StatusPill(
          label: 'Waiting dismissal',
          tone: StatusTone.pending,
        );
      case StudentStatus.onBusToSchool:
      case StudentStatus.onBusToHome:
        return const StatusPill(label: 'On bus', tone: StatusTone.pending);
      case StudentStatus.pickedUpByCar:
        return const StatusPill(
            label: 'Car pickup', tone: StatusTone.approved);
    }
  }

  bool _passesStatus(Student s) {
    switch (_statusKey) {
      case 'home':
        return s.status == StudentStatus.atHome ||
            s.status == StudentStatus.pickedUpByCar;
      case 'school':
        return s.status == StudentStatus.atSchool ||
            s.status == StudentStatus.waitingForDismissal;
      case 'bus':
        return s.status == StudentStatus.onBusToSchool ||
            s.status == StudentStatus.onBusToHome;
      default:
        return true;
    }
  }

  Iterable<Student> _visible(MockState mock) {
    final q =
        (_model.textController?.text ?? '').trim().toLowerCase();
    return mock.studentsOnDriverBus.where((s) {
      if (!_passesStatus(s)) return false;
      if (q.isEmpty) return true;
      final bundle = '${s.name} ${s.grade} ${s.id}'.toLowerCase();
      return bundle.contains(q);
    });
  }

  String _initials(String n) {
    final p = n.trim().split(RegExp(r'\s+'));
    if (p.isEmpty) return '?';
    if (p.length == 1) return p.first.substring(0, 1).toUpperCase();
    return (p.first[0] + p.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    mock.resolveDriverBusContext();
    final bus = mock.currentDriverBus;
    final list = _visible(mock).toList();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: GateFlowColors.brandPrimary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 30,
            buttonSize: 56,
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 26),
            onPressed: () => context.safePop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Assigned students',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 20),
              ),
              Text(
                'Select Student Manually',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          elevation: 0,
        ),
        bottomNavigationBar: const RoleBottomNav(current: 'students'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _model.textController,
                  focusNode: _model.textFieldFocusNode,
                  onChanged: (_) => EasyDebounce.debounce(
                    'assigned-q',
                    const Duration(milliseconds: 260),
                    () => safeSetState(() {}),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name, grade, ID…',
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: Color(0xFF57636C)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: _statusKey,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      labelText: 'Status filter',
                    ),
                    items: _filters.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ))
                        .toList(),
                    onChanged: (v) => safeSetState(() => _statusKey = v ?? _all),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${list.length} rider${list.length == 1 ? '' : 's'} on ${bus?.name ?? 'your bus'}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: GateFlowColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Text(
                            'No students match.',
                            style: GoogleFonts.inter(
                              color: GateFlowColors.textTertiary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemBuilder: (_, i) {
                            final s = list[i];
                            return Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => context.pushNamed(
                                  ConfirmBoardingWidget.routeName,
                                  queryParameters: {'sid': s.id},
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: GateFlowColors.divider),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: GateFlowColors.brandPrimary,
                                        child: Text(
                                          _initials(s.name),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              s.name,
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              s.dropOffLocation ??
                                                  '${s.grade} · ${bus?.routeLabel.split('·').first.trim() ?? 'Route'}',
                                              style: GoogleFonts.inter(
                                                fontSize: 12.5,
                                                color: GateFlowColors
                                                    .textSecondary,
                                              ),
                                            ),
                                            Text(
                                              s.lastMockUpdateLabel,
                                              style: GoogleFonts.inter(
                                                fontSize: 11.5,
                                                color: GateFlowColors
                                                    .textTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _pillForStudent(s),
                                      const Icon(Icons.chevron_right_rounded,
                                          color: GateFlowColors.textTertiary),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemCount: list.length,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
