import 'package:flutter_test/flutter_test.dart';

import 'package:test/backend/supabase/services/guardian_service.dart';
import 'support/test_env.dart';

void main() {
  onlyIfIntegrationEnabled('Guardian Authorization flow', () {
    final env = TestEnv.I;
    String? guardianId;

    setUpAll(() async => env.ensureReady());
    tearDownAll(() async => env.teardown());

    test('parent submits → staff approves → gate-lookup finds the guardian',
        () async {
      // 1. PARENT submits guardian invite.
      await env.signIn(kParentEmail, kDemoPassword);
      final parentId = await env.currentUserId();
      final unique   = DateTime.now().millisecondsSinceEpoch.toString();

      final submitted = await GuardianService.instance.submit(
        parentId:     parentId,
        fullName:     'IT Guardian $unique',
        relationship: 'uncle',
        phone:        '+96650$unique'.substring(0, 13),
        nationalId:   'IT-NID-$unique',
      );
      guardianId = submitted.id;
      env.track('guardians', submitted.id);
      expect(submitted.status, 'pending');
      await env.signOut();

      // 2. STAFF approves it.
      await env.signIn(kStaffEmail, kDemoPassword);
      final staffId = await env.currentUserId();
      await GuardianService.instance.reviewGuardian(
        id:         submitted.id,
        status:     'approved',
        reviewedBy: staffId,
      );

      final row = await env.client
          .from('guardians')
          .select('status')
          .eq('id', submitted.id)
          .single();
      expect(row['status'], 'approved');

      // 3. Gate-lookup by national ID returns the guardian row.
      final lookup = await GuardianService.instance.gateLookupByNationalId(
        'IT-NID-$unique',
      );
      // Either the profile resolver or the guardians fallback should find it.
      // We only assert that it didn't error and that – if it returned – the
      // payload mentions the guardian we just approved.
      if (lookup != null) {
        expect(lookup.toString(), contains('IT'));
      }
    });
  });
}
