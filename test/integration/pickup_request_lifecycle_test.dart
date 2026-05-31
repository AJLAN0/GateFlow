import 'package:flutter_test/flutter_test.dart';
import 'package:test/backend/supabase/services/profile_service.dart';
import 'package:test/backend/supabase/services/request_service.dart';

import 'support/test_env.dart';

void main() {
  final env = IntegrationTestEnv.instance;

  integrationGroup('Pickup request lifecycle (remote)', () {
    setUpAll(() async {
      await env.ensureInitialized();
    });

    tearDownAll(() async {
      await env.tearDownAll();
    });

    integrationTest(
        'parent submit -> staff approve -> gate release', () async {
      await env.signInParent();
      final parentId = await env.currentUserId();
      expect(parentId, isNotNull);

      final studentIds =
          await ProfileService.instance.fetchParentStudentIds(parentId: parentId!);
      expect(studentIds, isNotEmpty);

      final req = await RequestService.instance.submit(
        studentId:           studentIds.first,
        requestedBy:         parentId,
        type:                'Early Pickup',
        timeLabel:           '2:30 PM',
        pickupPersonSummary: 'Parent · Integration Test',
      );
      env.tracker.trackRequest(req.id);
      expect(req.status, 'pending');

      await env.signInStaff();
      final staffId = await env.currentUserId();
      await RequestService.instance.reviewRequest(
        id:         req.id,
        status:     'approved',
        reviewedBy: staffId!,
      );

      final approved = await env.client
          .from('pickup_requests')
          .select('status')
          .eq('id', req.id)
          .single();
      expect(approved['status'], 'approved');

      await RequestService.instance.releaseAtGate(req.id);

      final released = await env.client
          .from('pickup_requests')
          .select('released_at_gate')
          .eq('id', req.id)
          .single();
      expect(released['released_at_gate'], isTrue);
    });

    integrationTest('parent can delete own pending request', () async {
      await env.signInParent();
      final parentId = await env.currentUserId();
      final studentIds =
          await ProfileService.instance.fetchParentStudentIds(parentId: parentId!);
      expect(studentIds, isNotEmpty);

      final req = await RequestService.instance.submit(
        studentId:   studentIds.first,
        requestedBy: parentId,
        type:        'Late Drop-off',
        timeLabel:   '9:00 AM',
      );

      await RequestService.instance.delete(req.id);

      final gone = await env.client
          .from('pickup_requests')
          .select('id')
          .eq('id', req.id)
          .maybeSingle();
      expect(gone, isNull);
    });
  });
}
