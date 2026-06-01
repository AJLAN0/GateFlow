import 'package:flutter_test/flutter_test.dart';
import 'package:test/backend/supabase/services/schedule_service.dart';

import 'support/test_env.dart';

void main() {
  final env = IntegrationTestEnv.instance;

  integrationGroup('Schedule setup (remote)', () {
    setUpAll(() async {
      await env.ensureInitialized();
    });

    tearDownAll(() async {
      await env.tearDownAll();
    });

    integrationTest('staff creates, updates, and deletes today schedule', () async {
      await env.signInStaff();
      final schoolId = await env.currentSchoolId();
      final staffId = await env.currentUserId();
      expect(schoolId, isNotNull);
      expect(staffId, isNotNull);

      final created = await ScheduleService.instance.create(
        schoolId:   schoolId!,
        className:  'IT Test Class',
        grade:      'Grade IT',
        date:       DateTime.now(),
        arrivalTime: '07:30',
        createdBy:  staffId,
      );
      env.tracker.trackSchedule(created.id);

      final today =
          await ScheduleService.instance.fetchToday(schoolId: schoolId);
      expect(today.any((s) => s.id == created.id), isTrue);

      await ScheduleService.instance.update(
        id:        created.id,
        className: 'IT Test Class Updated',
      );

      final updated = await env.client
          .from('daily_schedules')
          .select('class_name')
          .eq('id', created.id)
          .single();
      expect(updated['class_name'], 'IT Test Class Updated');

      await ScheduleService.instance.delete(created.id);
      // Already deleted; remove from tracker so teardown does not error.
      env.tracker.untrackSchedule(created.id);

      final afterDelete = await ScheduleService.instance.fetchToday(
        schoolId: schoolId,
      );
      expect(afterDelete.any((s) => s.id == created.id), isFalse);
    });
  });
}
