import 'package:flutter_test/flutter_test.dart';
import 'package:test/backend/supabase/services/guardian_service.dart';
import 'package:test/backend/supabase/services/profile_service.dart';

import 'support/test_env.dart';

void main() {
  final env = IntegrationTestEnv.instance;
  const testNationalId = '9988776655';

  integrationGroup('Guardian authorization (remote)', () {
    setUpAll(() async {
      await env.ensureInitialized();
    });

    tearDownAll(() async {
      await env.tearDownAll();
    });

    integrationTest('parent submit -> staff approve -> gate lookup', () async {
      await env.signInParent();
      final parentId = await env.currentUserId();
      expect(parentId, isNotNull);

      // Resolve a linked student for the demo parent.
      final studentIds =
          await ProfileService.instance.fetchParentStudentIds(parentId: parentId!);
      expect(studentIds, isNotEmpty,
          reason: 'Demo parent needs linked students');

      final guardian = await GuardianService.instance.submit(
        parentId:    parentId,
        fullName:    'IT Test Guardian',
        relationship: 'Uncle',
        nationalId:  testNationalId,
        phone:       '+966509998877',
        studentIds:  [studentIds.first],
      );
      env.tracker.trackGuardian(guardian.id);
      expect(guardian.status, 'pending');

      await env.signInStaff();
      final staffId = await env.currentUserId();
      expect(staffId, isNotNull);

      await GuardianService.instance.reviewGuardian(
        id:         guardian.id,
        status:     'approved',
        reviewedBy: staffId!,
      );

      final row = await env.client
          .from('guardians')
          .select('status, national_id')
          .eq('id', guardian.id)
          .single();
      expect(row['status'], 'approved');
      expect(row['national_id'], testNationalId);

      // Staff can still read the approved guardian record.
      await env.signInStaff();
      final staffView = await GuardianService.instance.fetchBySchool(
        schoolId: (await env.currentSchoolId())!,
        statusFilter: 'approved',
      );
      expect(staffView.any((g) => g.id == guardian.id), isTrue);
    });
  });
}
