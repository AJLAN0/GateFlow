import 'package:flutter_test/flutter_test.dart';
import 'package:test/data/mock_state.dart';

import '../support/state_factory.dart';

void main() {
  group('Pickup requests', () {
    late MockState state;

    setUp(() {
      state = createOfflineState();
    });

    test('submitNewParentRequest appends pending request', () {
      final before = state.requests.length;
      final req = state.submitNewParentRequest(
        studentId: 'pc1',
        type: 'Early Pickup',
        timeLabel: '2:00 PM',
        pickupPersonSummary: 'Parent · Test',
      );
      expect(state.requests.length, before + 1);
      expect(req.status, RequestStatus.pending);
      expect(state.requests.last.id, req.id);
    });

    test('updateRequestStatus approves request', () {
      final id = state.requests.first.id;
      state.updateRequestStatus(id, RequestStatus.approved);
      expect(
        state.requests.firstWhere((r) => r.id == id).status,
        RequestStatus.approved,
      );
    });

    test('updateRequestStatus rejects request', () {
      final id = state.requests.first.id;
      state.updateRequestStatus(id, RequestStatus.rejected);
      expect(
        state.requests.firstWhere((r) => r.id == id).status,
        RequestStatus.rejected,
      );
    });

    test('updateSchoolTimeRequest changes staff queue status', () {
      final id = state.schoolTimeRequests.first.id;
      state.updateSchoolTimeRequest(id, RequestStatus.approved);
      expect(
        state.schoolTimeRequests.firstWhere((x) => x.id == id).status,
        RequestStatus.approved,
      );
    });

    test('demo data includes early and late request types', () {
      expect(state.requests.any((r) => r.type.contains('Early')), isTrue);
      expect(state.schoolTimeRequests.any((e) => e.isEarly), isTrue);
      expect(state.schoolTimeRequests.any((e) => !e.isEarly), isTrue);
    });
  });
}
