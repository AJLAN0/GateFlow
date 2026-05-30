import 'package:flutter_test/flutter_test.dart';
import 'package:test/data/mock_state.dart';

import '../support/state_factory.dart';

void main() {
  group('recordDriverBoardingScan phase machine', () {
    test('idle → boarded transitions the student onto the bus', () {
      final s = buildState(role: UserRole.busDriver);
      final student = s.students.first;

      final out = s.recordDriverBoardingScan(student.id);

      expect(out.phaseAfter, DriverScanPhase.boarded);
      expect(out.title, 'On board');
      expect(out.warning, isFalse);
      expect(out.showStaffAlert, isFalse);
      expect(student.status, StudentStatus.onBusToHome);
    });

    test('boarded → droppedOff completes the trip', () {
      final s = buildState(role: UserRole.busDriver);
      final student = s.students.first;

      s.recordDriverBoardingScan(student.id);                 // → boarded
      final out = s.recordDriverBoardingScan(student.id);     // → droppedOff

      expect(out.phaseAfter, DriverScanPhase.droppedOff);
      expect(out.title, 'Dropped off');
      expect(out.warning, isFalse);
      expect(student.status, StudentStatus.atHome);
    });

    test('droppedOff → droppedOff raises a staff alert (triple-scan)', () {
      final s = buildState(role: UserRole.busDriver);
      final student = s.students.first;
      final alertsBefore = s.operationalAlerts.length;

      s.recordDriverBoardingScan(student.id); // boarded
      s.recordDriverBoardingScan(student.id); // droppedOff
      final out = s.recordDriverBoardingScan(student.id); // 3rd scan

      expect(out.phaseAfter, DriverScanPhase.droppedOff);
      expect(out.warning, isTrue);
      expect(out.showStaffAlert, isTrue);
      // A new operational alert row should have been prepended.
      expect(s.operationalAlerts.length, greaterThan(alertsBefore));
      expect(s.operationalAlerts.first.title, contains('Driver scan alert'));
    });

    test('resetDriverScanDemo returns the student to idle', () {
      final s = buildState(role: UserRole.busDriver);
      final student = s.students.first;

      s.recordDriverBoardingScan(student.id); // boarded
      s.resetDriverScanDemo(student.id);

      final out = s.recordDriverBoardingScan(student.id);
      expect(out.phaseAfter, DriverScanPhase.boarded,
          reason: 'After reset, the next scan should start over from idle.');
    });

    test('updates lastMockUpdateLabel on every scan', () {
      final s = buildState(role: UserRole.busDriver);
      final student = s.students.first;
      student.lastMockUpdateLabel = '';

      s.recordDriverBoardingScan(student.id);
      expect(student.lastMockUpdateLabel, contains('Scan'));
    });
  });
}
