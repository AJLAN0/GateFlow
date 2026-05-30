import 'package:flutter_test/flutter_test.dart';

import 'package:test/backend/supabase/services/schedule_service.dart';
import 'support/test_env.dart';

void main() {
  onlyIfIntegrationEnabled('Schedule setup', () {
    final env = TestEnv.I;

    setUpAll(() async => env.ensureReady());
    tearDownAll(() async => env.teardown());

    test('staff CRUD round-trip: create → update → fetchToday → delete',
        () async {
      await env.signIn(kStaffEmail, kDemoPassword);
      final schoolId = await env.currentSchoolId();
      final staffId  = await env.currentUserId();

      final unique  = DateTime.now().millisecondsSinceEpoch.toString();
      final created = await ScheduleService.instance.create(
        schoolId:    schoolId,
        className:   'IT Class $unique',
        grade:       'G99',
        date:        DateTime.now(),
        arrivalTime: '08:00:00',
        notes:       'created by integration test',
        createdBy:   staffId,
      );
      env.track('daily_schedules', created.id);
      expect(created.className, contains('IT Class'));

      await ScheduleService.instance.update(
        id:         created.id,
        notes:      'edited by integration test',
        arrivalTime:'09:15:00',
      );

      final todays = await ScheduleService.instance.fetchToday(
        schoolId: schoolId,
      );
      final mine = todays.where((s) => s.id == created.id).toList();
      expect(mine, isNotEmpty);
      expect(mine.first.notes, 'edited by integration test');

      await ScheduleService.instance.delete(created.id);

      final after = await ScheduleService.instance.fetchToday(
        schoolId: schoolId,
      );
      expect(after.any((s) => s.id == created.id), isFalse);
    });

    test('non-staff (parent) CANNOT insert a schedule', () async {
      await env.signOut();
      await env.signIn(kParentEmail, kDemoPassword);
      final schoolId = await env.currentSchoolId();

      Object? err;
      try {
        await ScheduleService.instance.create(
          schoolId:  schoolId,
          className: 'Parent Attempt',
          grade:     'G1',
          date:      DateTime.now(),
        );
      } catch (e) {
        err = e;
      }
      expect(err, isNotNull,
          reason: 'RLS must reject schedule inserts from non-staff');
    });
  });
}
