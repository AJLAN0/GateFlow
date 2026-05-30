import 'package:flutter_test/flutter_test.dart';
import 'package:test/data/mock_state.dart';

import '../support/state_factory.dart';

void main() {
  group('releaseStudentAfterVerification', () {
    test('returns false for an unknown request id', () {
      final s = buildState(role: UserRole.schoolStaff);
      expect(s.releaseStudentAfterVerification('nope'), isFalse);
      expect(s.releasedPickupRequestIds, isEmpty);
    });

    test('returns false when the request is still pending', () {
      final s = buildState(role: UserRole.schoolStaff);
      final pending = s.requests.firstWhere(
        (r) => r.status == RequestStatus.pending,
      );

      expect(s.releaseStudentAfterVerification(pending.id), isFalse);
      expect(s.releasedPickupRequestIds, isNot(contains(pending.id)));
    });

    test('releases an approved request and tracks the id', () {
      final s = buildState(role: UserRole.schoolStaff);
      final notifier = NotifyCounter(s);

      final approved = s.requests.firstWhere(
        (r) => r.status == RequestStatus.approved,
      );

      expect(s.releaseStudentAfterVerification(approved.id), isTrue);
      expect(s.releasedPickupRequestIds, contains(approved.id));
      expect(notifier.value, greaterThanOrEqualTo(1));
      notifier.dispose();
    });
  });

  group('approvedParentRequestsAwaitingPickup', () {
    test('excludes a request once it has been released', () {
      final s = buildState(role: UserRole.schoolStaff);
      final approved = s.requests.firstWhere(
        (r) => r.status == RequestStatus.approved,
      );

      final before = s.approvedParentRequestsAwaitingPickup();
      expect(before.map((r) => r.id), contains(approved.id));

      expect(s.releaseStudentAfterVerification(approved.id), isTrue);

      final after = s.approvedParentRequestsAwaitingPickup();
      expect(after.map((r) => r.id), isNot(contains(approved.id)));
    });

    test('never includes pending or rejected requests', () {
      final s = buildState(role: UserRole.schoolStaff);
      // Flip something to rejected and verify it stays excluded.
      final pending = s.requests.firstWhere(
        (r) => r.status == RequestStatus.pending,
      );
      s.updateRequestStatus(pending.id, RequestStatus.rejected);

      final awaiting = s.approvedParentRequestsAwaitingPickup();
      expect(
        awaiting.every((r) => r.status == RequestStatus.approved),
        isTrue,
      );
      expect(awaiting.map((r) => r.id), isNot(contains(pending.id)));
    });
  });

  group('gate lookup (offline demo directory)', () {
    test('finds a parent by national id and matches the QR mock payload', () {
      final s = buildState(role: UserRole.schoolStaff);
      final hit = s.lookupGatePickupPersonByNationalId('1234567890');
      expect(hit, isNotNull);
      expect(hit!.kind, GatePickupPersonKind.parent);
      // Simulated QR equivalent (verifyPickupQrMock is a thin passthrough).
      expect(s.verifyPickupQrMock(valid: true), isTrue);
      expect(s.verifyPickupQrMock(valid: false), isFalse);
    });

    test('finds a guardian by phone with mixed punctuation', () {
      final s = buildState(role: UserRole.schoolStaff);
      final hit = s.lookupGatePickupPersonByPhone('+966 50 004411');
      expect(hit, isNotNull);
      expect(hit!.kind, GatePickupPersonKind.guardian);
    });

    test('returns null when nothing matches', () {
      final s = buildState(role: UserRole.schoolStaff);
      expect(s.lookupGatePickupPersonByNationalId('0000'), isNull);
      expect(s.lookupGatePickupPersonByPhone(''), isNull);
    });
  });
}
