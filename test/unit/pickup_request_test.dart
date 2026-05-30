import 'package:flutter_test/flutter_test.dart';
import 'package:test/data/mock_state.dart';

import '../support/state_factory.dart';

void main() {
  group('submitNewParentRequest', () {
    test('appends a pending request and notifies', () {
      final s = buildState(role: UserRole.parent);
      final notifier = NotifyCounter(s);
      final countBefore = s.requests.length;

      final r = s.submitNewParentRequest(
        studentId:           'pc3',
        type:                'Early Pickup',
        timeLabel:           '3:30 PM',
        pickupPersonSummary: 'Parent · Khalid',
      );

      expect(s.requests.length, countBefore + 1);
      expect(s.requests.last, same(r));
      expect(r.status, RequestStatus.pending);
      expect(r.studentId, 'pc3');
      expect(r.type, 'Early Pickup');
      expect(notifier.value, greaterThanOrEqualTo(1));
      notifier.dispose();
    });
  });

  group('updateRequestStatus', () {
    test('flips status and notifies', () {
      final s = buildState(role: UserRole.schoolStaff);
      final notifier = NotifyCounter(s);

      final pending = s.requests.firstWhere(
        (r) => r.status == RequestStatus.pending,
      );

      s.updateRequestStatus(pending.id, RequestStatus.approved);
      expect(pending.status, RequestStatus.approved);

      s.updateRequestStatus(pending.id, RequestStatus.rejected);
      expect(pending.status, RequestStatus.rejected);

      expect(notifier.value, greaterThanOrEqualTo(2));
      notifier.dispose();
    });
  });

  group('updateSchoolTimeRequest', () {
    test('flips status of a school-time entry and notifies', () {
      final s = buildState(role: UserRole.schoolStaff);
      final notifier = NotifyCounter(s);

      final pending = s.schoolTimeRequests.firstWhere(
        (e) => e.status == RequestStatus.pending,
      );

      s.updateSchoolTimeRequest(pending.id, RequestStatus.approved);
      expect(pending.status, RequestStatus.approved);
      expect(notifier.value, greaterThanOrEqualTo(1));
      notifier.dispose();
    });
  });

  group('studentHasPendingPickupRequest', () {
    test('matches by studentId AND by demo-child name fallback', () {
      final s = buildState(role: UserRole.parent);
      // The 'r1' demo request is keyed on the demo-child id 'pc3', which
      // shares the name 'Noah Khaled' with student s3.
      final noah = s.students.firstWhere((x) => x.name == 'Noah Khaled');
      expect(s.studentHasPendingPickupRequest(noah), isTrue);

      // Khalid Jr. has no pending request.
      final khalid = s.students.firstWhere((x) => x.name == 'Khalid Jr.');
      expect(s.studentHasPendingPickupRequest(khalid), isFalse);
    });
  });
}
