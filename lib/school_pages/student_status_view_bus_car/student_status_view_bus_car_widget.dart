import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '../../data/mock_state.dart';
import '../../shared/staff_student_status_actions.dart';
import '../../shared/student_daily_journey.dart';
import '../../shared/student_status_timeline_widgets.dart';
import 'student_status_view_bus_car_model.dart';
export 'student_status_view_bus_car_model.dart';

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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StudentStatusViewBusCarModel());
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

  AttendanceStatus _attendance(MockState mock, Student student) {
    final absent = GoRouterState.of(context).uri.queryParameters['absent'];
    if (absent == '1' || absent == 'true') {
      return AttendanceStatus.absent;
    }
    return AttendanceStatus.present;
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
      attendance: _attendance(mock, student),
    );

    return StudentStatusDetailScreen(
      journey: journey,
      onBack: () => context.safePop(),
      footer: StaffStudentStatusActions(student: student),
    );
  }
}
