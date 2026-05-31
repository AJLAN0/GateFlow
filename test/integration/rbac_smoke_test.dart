import 'package:flutter_test/flutter_test.dart';
import 'package:test/backend/supabase/services/request_service.dart';

import 'support/test_env.dart';

void main() {
  final env = IntegrationTestEnv.instance;

  integrationGroup('RBAC smoke (remote)', () {
    setUpAll(() async {
      await env.ensureInitialized();
    });

    tearDownAll(() async {
      await env.tearDownAll();
    });

    integrationTest('parent sees only own pickup requests', () async {
      await env.signInParent();
      final parentId = await env.currentUserId();
      expect(parentId, isNotNull);

      final own = await RequestService.instance.fetchByParent(parentId: parentId!);
      for (final r in own) {
        expect(r.requestedBy, parentId);
      }
    });

    integrationTest('staff can fetch school-wide requests', () async {
      await env.signInStaff();
      final schoolId = await env.currentSchoolId();
      expect(schoolId, isNotNull,
          reason: 'Staff profile must have school_id — run seed SQL if null');

      final schoolReqs =
          await RequestService.instance.fetchBySchool(schoolId: schoolId!);
      // Smoke: query succeeds under staff JWT (RLS allows school scope).
      expect(schoolReqs, isA<List>());
    });

    integrationTest('parent cannot fetch school-wide admin view', () async {
      await env.signInParent();
      final schoolId = await env.currentSchoolId();
      if (schoolId == null) return;

      // Direct table query as parent — RLS should filter to own rows only.
      final rows = await env.client
          .from('pickup_requests')
          .select('requested_by');

      final parentId = await env.currentUserId();
      for (final row in rows) {
        expect(row['requested_by'], parentId);
      }
    });
  });
}
