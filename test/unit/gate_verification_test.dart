import 'package:flutter_test/flutter_test.dart';

import '../support/state_factory.dart';

void main() {
  group('releaseStudentAfterVerification', () {
    test('returns false for unknown request ids and does not mutate state', () {
      final state = StateFactory.fresh();
      final released = state.releasedPickupRequestIds.toSet();

      final ok = state.releaseStudentAfterVerification('does-not-exist');

      expect(ok, isFalse);
      expect(state.releasedPickupRequestIds, released);
    });

    test('returns false for pending requests', () {
      final state = StateFactory.fresh();
      // r1 is pending in the demo seed
      expect(state.requestById(kDemoPendingRequestId).status,
          RequestStatus.pending);

      final ok = state.releaseStudentAfterVerification(kDemoPendingRequestId);

      expect(ok, isFalse);
      expect(state.releasedPickupRequestIds.contains(kDemoPendingRequestId),
          isFalse);
    });

    test('returns true for approved requests and tracks the release', () {
      final state = StateFactory.fresh();
      // r0 is approved in the demo seed
      expect(state.requestById(kDemoApprovedRequestId).status,
          RequestStatus.approved);

      final notifications = StateFactory.notifyCount(state, () {
        final ok =
            state.releaseStudentAfterVerification(kDemoApprovedRequestId);
        expect(ok, isTrue);
      });

      expect(state.releasedPickupRequestIds.contains(kDemoApprovedRequestId),
          isTrue);
      expect(notifications, 1, reason: 'release should notify listeners once');
    });
  });

  group('approvedParentRequestsAwaitingPickup', () {
    test('includes approved requests that have not been released yet', () {
      final state = StateFactory.fresh();
      final awaiting = state.approvedParentRequestsAwaitingPickup();
      expect(awaiting.map((r) => r.id).toSet(),
          contains(kDemoApprovedRequestId));
    });

    test('excludes a request after it is released at the gate', () {
      final state = StateFactory.fresh();
      state.releaseStudentAfterVerification(kDemoApprovedRequestId);
      final awaiting = state.approvedParentRequestsAwaitingPickup();
      expect(awaiting.map((r) => r.id).toSet(),
          isNot(contains(kDemoApprovedRequestId)));
    });

    test('excludes pending and rejected requests entirely', () {
      final state = StateFactory.fresh();
      final ids = state
          .approvedParentRequestsAwaitingPickup()
          .map((r) => r.id)
          .toSet();
      expect(ids, isNot(contains(kDemoPendingRequestId)));
    });
  });

  group('gate directory lookup (offline)', () {
    test('finds the seeded parent by national ID', () {
      final state = StateFactory.fresh();
      final p = state.lookupGatePickupPersonByNationalId('1234567890');
      expect(p, isNotNull);
      expect(p!.kind, GatePickupPersonKind.parent);
      expect(p.fullName, 'Khalid Al-Otaibi');
    });

    test('finds the seeded guardian by phone (handles formatting)', () {
      final state = StateFactory.fresh();
      final p = state.lookupGatePickupPersonByPhone('+966 50 000 4411');
      expect(p, isNotNull);
      expect(p!.kind, GatePickupPersonKind.guardian);
    });

    test('returns null for unknown national IDs', () {
      final state = StateFactory.fresh();
      expect(state.lookupGatePickupPersonByNationalId('0000000000'), isNull);
      expect(state.lookupGatePickupPersonByNationalId(''), isNull);
    });
  });

  group('verifyPickupQrMock', () {
    test('passes through the boolean — simulated-QR payload check', () {
      final state = StateFactory.fresh();
      expect(state.verifyPickupQrMock(valid: true), isTrue);
      expect(state.verifyPickupQrMock(valid: false), isFalse);
    });
  });
}
