import 'package:flutter_test/flutter_test.dart';

import '../support/state_factory.dart';

void main() {
  group('submitNewParentRequest', () {
    test('appends a pending request and notifies listeners', () {
      final state = StateFactory.fresh();
      final before = state.requests.length;

      ParentRequest? created;
      final notifications = StateFactory.notifyCount(state, () {
        created = state.submitNewParentRequest(
          studentId: 'pc3',
          type: 'Early Pickup',
          timeLabel: '2:30 PM',
          pickupPersonSummary: 'Parent · Tester',
        );
      });

      expect(created, isNotNull);
      expect(created!.status, RequestStatus.pending);
      expect(created!.studentId, 'pc3');
      expect(created!.type, 'Early Pickup');
      expect(state.requests.length, before + 1);
      expect(state.requests.last.id, created!.id);
      expect(notifications, 1);
    });

    test('every submission gets a unique id', () {
      final state = StateFactory.fresh();
      final a = state.submitNewParentRequest(
        studentId: 'pc3',
        type: 'Early Pickup',
        timeLabel: '2:30 PM',
        pickupPersonSummary: 'Parent · Tester',
      );
      final b = state.submitNewParentRequest(
        studentId: 'pc3',
        type: 'Late Drop-off',
        timeLabel: '9:00 AM',
        pickupPersonSummary: 'Parent · Tester',
      );
      expect(a.id, isNot(equals(b.id)));
    });
  });

  group('updateRequestStatus', () {
    test('flips the pending request to approved and notifies', () {
      final state = StateFactory.fresh();
      // r1 is pending in the demo seed
      expect(state.requestById(kDemoPendingRequestId).status,
          RequestStatus.pending);

      final notifications = StateFactory.notifyCount(state, () {
        state.updateRequestStatus(
            kDemoPendingRequestId, RequestStatus.approved);
      });

      expect(state.requestById(kDemoPendingRequestId).status,
          RequestStatus.approved);
      expect(notifications, 1);
    });

    test('rejected ⇒ rejected', () {
      final state = StateFactory.fresh();
      state.updateRequestStatus(kDemoPendingRequestId, RequestStatus.rejected);
      expect(state.requestById(kDemoPendingRequestId).status,
          RequestStatus.rejected);
    });
  });

  group('updateSchoolTimeRequest', () {
    test('mutates the time-request entry and notifies', () {
      final state = StateFactory.fresh();
      final entry = state.schoolTimeRequests.first;
      expect(entry.status, RequestStatus.pending);

      final notifications = StateFactory.notifyCount(state, () {
        state.updateSchoolTimeRequest(entry.id, RequestStatus.approved);
      });

      expect(state.schoolTimeRequests.first.status, RequestStatus.approved);
      expect(notifications, 1);
    });
  });

  group('studentHasPendingPickupRequest', () {
    test('returns true when a pending request matches the student name', () {
      final state = StateFactory.fresh();
      // r1 pending references demo-child pc3 ("Noah Khaled"); demo student s3
      // has the same name. studentHasPendingPickupRequest matches by name too.
      final s = state.studentById('s3');
      expect(state.studentHasPendingPickupRequest(s), isTrue);
    });

    test('returns false when no pending requests reference the student', () {
      final state = StateFactory.fresh();
      // Resolve any pending request that mentions s2 by either id or demo-child
      // name; demo seed has none referencing s2 ("Aisha").
      final s = state.studentById('s2');
      expect(state.studentHasPendingPickupRequest(s), isFalse);
    });
  });
}
