import 'package:flutter_test/flutter_test.dart';
import 'package:test/data/mock_state.dart';

import '../support/state_factory.dart';

void main() {
  group('Gate verification', () {
    late MockState state;

    setUp(() {
      state = createOfflineState();
    });

    test('releaseStudentAfterVerification rejects pending request', () {
      expect(state.releaseStudentAfterVerification('r1'), isFalse);
    });

    test('releaseStudentAfterVerification rejects unknown id', () {
      expect(state.releaseStudentAfterVerification('nonexistent'), isFalse);
    });

    test('releaseStudentAfterVerification succeeds for approved request', () {
      state.requests = [
        ParentRequest(
          id: 'approved1',
          studentId: 's1',
          type: 'Early Pickup',
          status: RequestStatus.approved,
          date: DateTime.now(),
        ),
      ];
      expect(state.releaseStudentAfterVerification('approved1'), isTrue);
      expect(state.releasedPickupRequestIds, contains('approved1'));
    });

    test('approvedParentRequestsAwaitingPickup excludes released', () {
      state.requests = [
        ParentRequest(
          id: 'a',
          studentId: 's1',
          type: 'Early Pickup',
          status: RequestStatus.approved,
          date: DateTime.now(),
        ),
        ParentRequest(
          id: 'b',
          studentId: 's2',
          type: 'Late Drop-off',
          status: RequestStatus.approved,
          date: DateTime.now(),
        ),
      ];
      state.releasedPickupRequestIds.add('a');
      final awaiting = state.approvedParentRequestsAwaitingPickup();
      expect(awaiting.map((r) => r.id), ['b']);
    });

    test('lookupGatePickupPersonByNationalId finds demo parent', () {
      final person =
          state.lookupGatePickupPersonByNationalId('1234567890');
      expect(person, isNotNull);
      expect(person!.fullName, 'Khalid Al-Otaibi');
      expect(person.kind, GatePickupPersonKind.parent);
    });

    test('lookupGatePickupPersonByNationalId accepts formatted ID', () {
      final person =
          state.lookupGatePickupPersonByNationalId('1234-5678-90');
      expect(person, isNotNull);
      expect(person!.nationalId, '1234567890');
    });

    test('lookupGatePickupPersonByPhone finds partial match', () {
      final person = state.lookupGatePickupPersonByPhone('501112233');
      expect(person, isNotNull);
      expect(person!.phoneDigits, contains('966501112233'));
    });

    test('lookupGatePickupPersonByNationalId returns null when empty', () {
      expect(state.lookupGatePickupPersonByNationalId(''), isNull);
      expect(state.lookupGatePickupPersonByNationalId('0000000000'), isNull);
    });

    test('releaseStudentAtGate blocked until waiting dismissal', () {
      final student = state.students.firstWhere((s) => s.name == 'Noah Khaled');
      expect(student.status, StudentStatus.onBusToSchool);
      expect(state.releaseStudentAtGate(student.id), isFalse);

      state.staffCheckInStudent(student.id);
      expect(state.releaseStudentAtGate(student.id), isFalse);

      state.staffMarkWaitingDismissal(student.id);
      expect(state.releaseStudentAtGate(student.id), isTrue);
    });
  });
}
