// End-to-end RBAC sanity. The deep coverage lives in the Tier 2 pgTAP tests;
// this just confirms that real signed-in sessions see what RLS lets them see.
import 'package:flutter_test/flutter_test.dart';

import 'support/test_env.dart';

void main() {
  onlyIfIntegrationEnabled('RBAC smoke', () {
    final env = TestEnv.I;

    setUpAll(() async => env.ensureReady());
    tearDownAll(() async => env.teardown());

    test('parent sees ONLY their own pickup requests', () async {
      await env.signIn(kParentEmail, kDemoPassword);
      final uid = await env.currentUserId();

      final rows = await env.client.from('pickup_requests').select('id, requested_by');
      for (final r in rows) {
        expect(r['requested_by'], uid,
            reason: 'RLS must hide other parents\' requests');
      }

      await env.signOut();
    });

    test('staff sees the school-wide request list (≥ parent\'s)', () async {
      await env.signIn(kParentEmail, kDemoPassword);
      final parentRows = await env.client.from('pickup_requests').select('id');
      final parentCount = parentRows.length;
      await env.signOut();

      await env.signIn(kStaffEmail, kDemoPassword);
      final staffRows = await env.client.from('pickup_requests').select('id');
      expect(staffRows.length, greaterThanOrEqualTo(parentCount),
          reason: 'staff RLS scope is school-wide');
    });

    test('parent CANNOT insert a row into daily_schedules', () async {
      await env.signIn(kParentEmail, kDemoPassword);
      final schoolId = await env.currentSchoolId();

      Object? err;
      try {
        await env.client.from('daily_schedules').insert({
          'school_id':  schoolId,
          'class_name': 'parent-attempt',
          'grade':      'G1',
          'date':       DateTime.now().toIso8601String().split('T').first,
        });
      } catch (e) {
        err = e;
      }
      expect(err, isNotNull,
          reason: 'RLS must reject schedule inserts from non-staff');

      await env.signOut();
    });
  });
}
