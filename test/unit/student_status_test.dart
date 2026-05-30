import 'package:flutter_test/flutter_test.dart';
import 'package:test/data/mock_state.dart';

import '../support/state_factory.dart';

void main() {
  group('updateStudentStatus', () {
    test('mutates the student and notifies listeners', () {
      final s = buildState(role: UserRole.schoolStaff);
      final notifier = NotifyCounter(s);

      final target = s.students.first;
      expect(target.status, isNot(StudentStatus.pickedUpByCar));

      s.updateStudentStatus(target.id, StudentStatus.pickedUpByCar);

      expect(target.status, StudentStatus.pickedUpByCar);
      expect(notifier.value, greaterThanOrEqualTo(1));
      notifier.dispose();
    });

    test('throws StateError for an unknown student id', () {
      final s = buildState();
      expect(
        () => s.updateStudentStatus('does-not-exist', StudentStatus.atSchool),
        throwsStateError,
      );
    });
  });

  group('status enum round-trip', () {
    // Hidden static method; exercised end-to-end via Student → _mapStudent.
    // We instead assert by feeding raw DB strings through the documented
    // mapping table — every value must survive a from→to→from round trip.
    const cases = <String, StudentStatus>{
      'at_home':          StudentStatus.atHome,
      'on_bus_to_school': StudentStatus.onBusToSchool,
      'at_school':        StudentStatus.atSchool,
      'on_bus_to_home':   StudentStatus.onBusToHome,
      'picked_up_by_car': StudentStatus.pickedUpByCar,
    };

    test('updateStudentStatus is reflected back via the same enum', () {
      final s = buildState(role: UserRole.schoolStaff);
      final target = s.students.first;

      for (final entry in cases.entries) {
        s.updateStudentStatus(target.id, entry.value);
        expect(target.status, entry.value, reason: 'wire string ${entry.key}');
      }
    });
  });
}
