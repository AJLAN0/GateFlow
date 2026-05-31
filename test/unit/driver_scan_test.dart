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

    test('first scan boards student (idle -> boarded)', () {
      const studentId = 's3';
      state.resetDriverScanDemo(studentId);

      final outcome = state.recordDriverBoardingScan(studentId);
      expect(outcome.phaseAfter, DriverScanPhase.boarded);
      expect(outcome.warning, isFalse);
      expect(outcome.title, 'On board');
      expect(
        state.students.firstWhere((s) => s.id == studentId).status,
        StudentStatus.onBusToHome,
      );
    });

    test('second scan drops off student (boarded -> droppedOff)', () {
      const studentId = 's3';
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

    test('third scan triggers staff alert (triple-scan)', () {
      const studentId = 's3';
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
      const studentId = 's3';
      state.recordDriverBoardingScan(studentId);
      state.resetDriverScanDemo(studentId);
      // After reset, next scan should board again
      final outcome = state.recordDriverBoardingScan(studentId);
      expect(outcome.phaseAfter, DriverScanPhase.boarded);
    });
  });
}
