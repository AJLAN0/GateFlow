import 'package:flutter_test/flutter_test.dart';

import 'package:test/backend/supabase/services/request_service.dart';
import 'support/test_env.dart';

void main() {
  onlyIfIntegrationEnabled('Pickup request lifecycle', () {
    final env = TestEnv.I;

    setUpAll(() async => env.ensureReady());
    tearDownAll(() async => env.teardown());

    test('parent submits → staff approves → gate releases → row reflects it',
        () async {
      // PARENT: pick a student we are linked to.
      await env.signIn(kParentEmail, kDemoPassword);
      final parentId = await env.currentUserId();

      final children = await env.client
          .from('parent_students')
          .select('student_id')
          .eq('parent_id', parentId);
      expect(children, isNotEmpty,
          reason: 'demo seed should link a child to the parent');
      final studentId = children.first['student_id'] as String;

      final submitted = await RequestService.instance.submit(
        studentId:           studentId,
        requestedBy:         parentId,
        type:                'Early Pickup',
        timeLabel:           '2:00 PM',
        pickupPersonSummary: 'Parent · Integration Test',
        notes:               'integration-test pickup',
      );
      env.track('pickup_requests', submitted.id);
      expect(submitted.status, 'pending');
      await env.signOut();

      // STAFF: approve.
      await env.signIn(kStaffEmail, kDemoPassword);
      final staffId = await env.currentUserId();
      await RequestService.instance.reviewRequest(
        id:         submitted.id,
        status:     'approved',
        reviewedBy: staffId,
      );

      // GATE: release.
      await RequestService.instance.releaseAtGate(submitted.id);

      final row = await env.client
          .from('pickup_requests')
          .select('status, released_at_gate, released_at')
          .eq('id', submitted.id)
          .single();
      expect(row['status'], 'approved');
      expect(row['released_at_gate'], true);
      expect(row['released_at'], isNotNull);
    });

    test('parent CAN delete their own pending request', () async {
      await env.signOut();
      await env.signIn(kParentEmail, kDemoPassword);
      final parentId = await env.currentUserId();

      final children = await env.client
          .from('parent_students')
          .select('student_id')
          .eq('parent_id', parentId);
      final studentId = children.first['student_id'] as String;

      final r = await RequestService.instance.submit(
        studentId:           studentId,
        requestedBy:         parentId,
        type:                'Early Pickup',
        timeLabel:           '3:00 PM',
        pickupPersonSummary: 'Parent · cancel test',
      );
      env.track('pickup_requests', r.id);

      await RequestService.instance.delete(r.id);

      final still = await env.client
          .from('pickup_requests')
          .select('id')
          .eq('id', r.id);
      expect(still, isEmpty);
    });
  });
}
