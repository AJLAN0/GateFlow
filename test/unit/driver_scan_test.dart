import 'package:flutter_test/flutter_test.dart';
import 'package:test/data/mock_state.dart';

import '../support/state_factory.dart';

void main() {
  group('Driver scan', () {
    late MockState state;

    setUp(() {
      state = createOfflineState();
      state.loginAs(UserRole.busDriver);
    });

    test('morning scan boards student from home', () {
      const studentId = 's2';
      state.updateStudentStatus(studentId, StudentStatus.atHome);
      state.resetDriverScanDemo(studentId);

      final outcome = state.recordDriverBoardingScan(studentId);
      expect(outcome.phaseAfter, DriverScanPhase.boarded);
      expect(outcome.warning, isFalse);
      expect(
        state.students.firstWhere((s) => s.id == studentId).status,
        StudentStatus.onBusToSchool,
      );
    });

    test('afternoon scan boards student after dismissal', () {
      const studentId = 's4';
      state.updateStudentStatus(
        studentId,
        StudentStatus.waitingForDismissal,
      );
      state.resetDriverScanDemo(studentId);

      final outcome = state.recordDriverBoardingScan(studentId);
      expect(outcome.phaseAfter, DriverScanPhase.boarded);
      expect(
        state.students.firstWhere((s) => s.id == studentId).status,
        StudentStatus.onBusToHome,
      );
    });

    test('second scan drops off student on afternoon route', () {
      const studentId = 's4';
      state.updateStudentStatus(
        studentId,
        StudentStatus.waitingForDismissal,
      );
      state.resetDriverScanDemo(studentId);
      state.recordDriverBoardingScan(studentId);

      final outcome = state.recordDriverBoardingScan(studentId);
      expect(outcome.phaseAfter, DriverScanPhase.droppedOff);
      expect(outcome.title, 'Dropped off');
      expect(
        state.students.firstWhere((s) => s.id == studentId).status,
        StudentStatus.atHome,
      );
    });

    test('cannot board student still at school without dismissal', () {
      const studentId = 's1';
      state.updateStudentStatus(studentId, StudentStatus.atSchool);
      state.resetDriverScanDemo(studentId);

      final outcome = state.recordDriverBoardingScan(studentId);
      expect(outcome.warning, isTrue);
      expect(outcome.title, 'Cannot board');
    });

    test('third scan triggers staff alert (triple-scan)', () {
      const studentId = 's4';
      state.updateStudentStatus(
        studentId,
        StudentStatus.waitingForDismissal,
      );
      state.resetDriverScanDemo(studentId);
      state.recordDriverBoardingScan(studentId);
      state.recordDriverBoardingScan(studentId);

      final beforeAlerts = state.operationalAlerts.length;
      final outcome = state.recordDriverBoardingScan(studentId);

      expect(outcome.warning, isTrue);
      expect(outcome.showStaffAlert, isTrue);
      expect(outcome.title, 'Multiple scans');
      expect(state.operationalAlerts.length, greaterThan(beforeAlerts));
    });

    test('resetDriverScanDemo clears phase', () {
      const studentId = 's2';
      state.updateStudentStatus(studentId, StudentStatus.atHome);
      state.recordDriverBoardingScan(studentId);
      state.resetDriverScanDemo(studentId);
      state.updateStudentStatus(studentId, StudentStatus.atHome);
      final outcome = state.recordDriverBoardingScan(studentId);
      expect(outcome.phaseAfter, DriverScanPhase.boarded);
    });
  });
}
