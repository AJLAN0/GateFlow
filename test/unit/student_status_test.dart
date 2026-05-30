import 'package:flutter_test/flutter_test.dart';

import '../support/state_factory.dart';

void main() {
  group('updateStudentStatus', () {
    test('mutates the targeted student and fires notifyListeners exactly once',
        () {
      final state = StateFactory.fresh();
      final before = state.studentById('s2').status;
      expect(before, StudentStatus.atHome,
          reason: 'demo seed should start s2 atHome');

      final notifications = StateFactory.notifyCount(
        state,
        () => state.updateStudentStatus('s2', StudentStatus.onBusToSchool),
      );

      expect(state.studentById('s2').status, StudentStatus.onBusToSchool);
      expect(notifications, 1);
    });

    test('does not touch other students', () {
      final state = StateFactory.fresh();
      final s1Before = state.studentById('s1').status;
      state.updateStudentStatus('s3', StudentStatus.atHome);
      expect(state.studentById('s1').status, s1Before);
    });
  });

  group('studentStatus DB ↔ UI round-trip', () {
    test('round-trips all 5 enum values', () {
      for (final v in StudentStatus.values) {
        final db = MockState.studentStatusToDb(v);
        final ui = MockState.studentStatusFromDb(db);
        expect(ui, v, reason: 'round-trip failed for $v (db="$db")');
      }
    });

    test('maps the canonical Postgres strings', () {
      expect(MockState.studentStatusFromDb('at_home'), StudentStatus.atHome);
      expect(MockState.studentStatusFromDb('on_bus_to_school'),
          StudentStatus.onBusToSchool);
      expect(MockState.studentStatusFromDb('at_school'),
          StudentStatus.atSchool);
      expect(MockState.studentStatusFromDb('on_bus_to_home'),
          StudentStatus.onBusToHome);
      expect(MockState.studentStatusFromDb('picked_up_by_car'),
          StudentStatus.pickedUpByCar);

      expect(MockState.studentStatusToDb(StudentStatus.atHome), 'at_home');
      expect(MockState.studentStatusToDb(StudentStatus.onBusToSchool),
          'on_bus_to_school');
      expect(MockState.studentStatusToDb(StudentStatus.atSchool), 'at_school');
      expect(MockState.studentStatusToDb(StudentStatus.onBusToHome),
          'on_bus_to_home');
      expect(MockState.studentStatusToDb(StudentStatus.pickedUpByCar),
          'picked_up_by_car');
    });

    test('unknown DB strings safely fall back to atHome', () {
      expect(MockState.studentStatusFromDb('garbage'), StudentStatus.atHome);
      expect(MockState.studentStatusFromDb(''), StudentStatus.atHome);
    });
  });

  group('countStudentsWhere', () {
    test('reflects state mutations', () {
      final state = StateFactory.fresh();
      final initial = state
          .countStudentsWhere((s) => s.status == StudentStatus.atSchool);
      expect(initial, 2, reason: 'demo seed has s1 + s4 at school');

      state.updateStudentStatus('s2', StudentStatus.atSchool);
      final after = state
          .countStudentsWhere((s) => s.status == StudentStatus.atSchool);
      expect(after, initial + 1);
    });
  });
}
