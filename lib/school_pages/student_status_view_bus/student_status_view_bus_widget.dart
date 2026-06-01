import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '../../data/mock_state.dart';
import '../../shared/staff_student_status_actions.dart';
import '../../shared/student_daily_journey.dart';
import '../../shared/student_status_timeline_widgets.dart';
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

  Student? _resolveStudent(MockState mock) {
    final sid = GoRouterState.of(context).uri.queryParameters['sid'];
    if (sid == null) return null;
    try {
      return mock.students.firstWhere((s) => s.id == sid);
    } catch (_) {
      return null;
    }
  }

  String? _busName(MockState mock, Student student) {
    final busId = student.busId;
    if (busId == null || busId.isEmpty) return null;
    try {
      return mock.buses.firstWhere((b) => b.id == busId).name;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    final student = _resolveStudent(mock);

    if (student == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0C3451),
          title: const Text('View Student Status'),
        ),
        body: const Center(child: Text('Student not found')),
      );
    }

    final journey = StudentDailyJourney.fromStudent(
      student,
      busName: _busName(mock, student),
    );

    return StudentStatusDetailScreen(
      journey: journey,
      onBack: () => context.safePop(),
      footer: StaffStudentStatusActions(student: student),
    );
  }
}
