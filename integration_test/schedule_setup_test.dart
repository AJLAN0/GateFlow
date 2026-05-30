import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:test/backend/supabase/supabase_config.dart';
import 'package:test/backend/supabase/services/auth_service.dart';
import 'package:test/backend/supabase/services/schedule_service.dart';

import 'support/test_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final created = CreatedIds();

  setUpAll(TestEnv.ensureInit);
  tearDownAll(created.teardown);

  test('staff CRUD on schedules + parent insert is denied', () async {
    if (!TestEnv.enabled) {
      markTestSkipped('GATEFLOW_IT is off');
      return;
    }

    // -- Staff: create / update / list ------------------------------------
    await TestEnv.signInAs(TestEnv.staffEmail);
    final staff = await AuthService.instance.fetchProfile();
    expect(staff?.schoolId, isNotNull);

    final today = DateTime.now();
    final sched = await ScheduleService.instance.create(
      schoolId:  staff!.schoolId!,
      className: 'IT-Class-${today.millisecondsSinceEpoch}',
      grade:     'G99',
      date:      today,
      arrivalTime:   '08:00',
      departureTime: '14:00',
      createdBy:     staff.id,
    );
    created.schedules.add(sched.id);

    await ScheduleService.instance.update(
      id:    sched.id,
      notes: 'updated by IT suite',
    );

    final list = await ScheduleService.instance.fetchToday(
      schoolId: staff.schoolId!,
    );
    final found = list.firstWhere((e) => e.id == sched.id);
    expect(found.notes, 'updated by IT suite');

    // -- Parent: should be blocked from inserting --------------------------
    await TestEnv.signInAs(TestEnv.parentEmail);
    final parent = await AuthService.instance.fetchProfile();
    expect(parent?.role, 'parent');

    bool blocked = false;
    try {
      await supabase.from('daily_schedules').insert({
        'school_id':  parent!.schoolId ?? staff.schoolId!,
        'class_name': 'forbidden',
        'grade':      'G1',
        'date':       today.toIso8601String().split('T').first,
      });
    } catch (_) {
      blocked = true;
    }
    expect(
      blocked,
      isTrue,
      reason: 'parent INSERT into daily_schedules must be rejected by RLS',
    );

    await TestEnv.signOut();
  }, timeout: const Timeout(Duration(seconds: 90)));
}
