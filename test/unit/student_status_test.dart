import 'package:flutter_test/flutter_test.dart';
import 'package:test/data/mock_state.dart';

import '../support/state_factory.dart';

void main() {
  group('Student status', () {
    late MockState state;

    setUp(() {
      state = createOfflineState();
    });

    test('updateStudentStatus changes status for known student', () {
      state.updateStudentStatus('s1', StudentStatus.onBusToHome);
      final student = state.students.firstWhere((s) => s.id == 's1');
      expect(student.status, StudentStatus.onBusToHome);
    });

    test('updateStudentStatus notifies listeners', () {
      var count = 0;
      state.addListener(() => count++);
      state.updateStudentStatus('s1', StudentStatus.atHome);
      expect(count, greaterThan(0));
    });

    test('all five statuses can be applied', () {
      const statuses = [
        StudentStatus.atHome,
        StudentStatus.onBusToSchool,
        StudentStatus.atSchool,
        StudentStatus.onBusToHome,
        StudentStatus.pickedUpByCar,
      ];
      for (final status in statuses) {
        state.updateStudentStatus('s2', status);
        expect(
          state.students.firstWhere((s) => s.id == 's2').status,
          status,
        );
      }
    });

    test('updateBusStatus changes bus status', () {
      state.updateBusStatus('b1', BusStatus.stationary);
      expect(
        state.buses.firstWhere((b) => b.id == 'b1').status,
        BusStatus.stationary,
      );
    });
  });
}
