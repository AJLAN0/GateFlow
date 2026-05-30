import 'package:flutter_test/flutter_test.dart';

import '../support/state_factory.dart';

void main() {
  group('recordDriverBoardingScan phase machine', () {
    test('1st scan → boarded, status onBusToHome, no warning', () {
      final state = StateFactory.fresh();
      final out = state.recordDriverBoardingScan('s1');
      expect(out.phaseAfter, DriverScanPhase.boarded);
      expect(state.studentById('s1').status, StudentStatus.onBusToHome);
      expect(out.warning, isFalse);
      expect(out.showStaffAlert, isFalse);
      expect(out.title, 'On board');
    });

    test('2nd scan → droppedOff, status atHome, no warning', () {
      final state = StateFactory.fresh();
      state.recordDriverBoardingScan('s1'); // boarded
      final out = state.recordDriverBoardingScan('s1'); // dropped off
      expect(out.phaseAfter, DriverScanPhase.droppedOff);
      expect(state.studentById('s1').status, StudentStatus.atHome);
      expect(out.warning, isFalse);
      expect(out.showStaffAlert, isFalse);
      expect(out.title, 'Dropped off');
    });

    test('3rd scan → triple-scan alert, warning + staff alert flag', () {
      final state = StateFactory.fresh();
      state.recordDriverBoardingScan('s1'); // 1
      state.recordDriverBoardingScan('s1'); // 2

      final alertsBefore = state.operationalAlerts.length;
      final out = state.recordDriverBoardingScan('s1'); // 3

      expect(out.phaseAfter, DriverScanPhase.droppedOff);
      expect(out.warning, isTrue);
      expect(out.showStaffAlert, isTrue);
      expect(out.title, 'Multiple scans');
      expect(state.operationalAlerts.length, alertsBefore + 1,
          reason: 'a scan-alert should be appended to operationalAlerts');
      expect(state.operationalAlerts.first.title, contains('scan'));
    });

    test('resetDriverScanDemo returns the phase machine to idle', () {
      final state = StateFactory.fresh();
      state.recordDriverBoardingScan('s1');
      state.resetDriverScanDemo('s1');
      // After reset, the next scan should behave like the first one again.
      final out = state.recordDriverBoardingScan('s1');
      expect(out.phaseAfter, DriverScanPhase.boarded);
    });

    test('phase is tracked per-student independently', () {
      final state = StateFactory.fresh();
      state.recordDriverBoardingScan('s1');   // s1 boarded
      final out = state.recordDriverBoardingScan('s3'); // s3 first scan
      expect(out.phaseAfter, DriverScanPhase.boarded,
          reason: 's3 must not inherit s1\'s phase');
    });

    test('each scan notifies listeners once', () {
      final state = StateFactory.fresh();
      final count = StateFactory.notifyCount(
          state, () => state.recordDriverBoardingScan('s1'));
      expect(count, 1);
    });
  });
}
