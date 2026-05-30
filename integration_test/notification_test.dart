import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:test/backend/supabase/supabase_config.dart';
import 'package:test/backend/supabase/services/auth_service.dart';
import 'package:test/backend/supabase/services/notification_service.dart';

import 'support/test_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final created = CreatedIds();

  setUpAll(TestEnv.ensureInit);
  tearDownAll(() async {
    // Best-effort cleanup of broadcast rows we made for the demo school.
    await TestEnv.signInAs(TestEnv.staffEmail);
    await supabase
        .from('notifications')
        .delete()
        .like('title', 'IT-NOTIF-%');
    await created.teardown();
    await TestEnv.signOut();
  });

  test('NotificationService.send → unreadCount → markAllRead', () async {
    if (!TestEnv.enabled) {
      markTestSkipped('GATEFLOW_IT is off');
      return;
    }

    await TestEnv.signInAs(TestEnv.parentEmail);
    final me = await AuthService.instance.fetchProfile();
    expect(me, isNotNull);

    final baseline = await NotificationService.instance.unreadCount(
      userId: me!.id,
    );

    await NotificationService.instance.send(
      userId: me.id,
      title:  'IT-NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      body:   'integration_test self-target',
    );

    final after = await NotificationService.instance.unreadCount(
      userId: me.id,
    );
    expect(after, baseline + 1);

    await NotificationService.instance.markAllRead(userId: me.id);

    final cleared = await NotificationService.instance.unreadCount(
      userId: me.id,
    );
    expect(cleared, 0);
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('broadcastToSchool RPC fans out to in-school users', () async {
    if (!TestEnv.enabled) {
      markTestSkipped('GATEFLOW_IT is off');
      return;
    }

    await TestEnv.signInAs(TestEnv.staffEmail);
    final staff = await AuthService.instance.fetchProfile();
    expect(staff?.schoolId, isNotNull);

    final tag = 'IT-NOTIF-BROADCAST-${DateTime.now().millisecondsSinceEpoch}';

    await NotificationService.instance.broadcastToSchool(
      schoolId: staff!.schoolId!,
      title:    tag,
      body:     'integration_test broadcast',
      type:     'info',
      roles:    const ['parent', 'school_staff'],
    );

    // The staff member is themself a school_staff in the same school, so the
    // RPC should produce at least one row visible to them.
    final rows = await supabase
        .from('notifications')
        .select('id, user_id, title')
        .eq('title', tag);

    expect(rows, isNotEmpty,
        reason: 'broadcast_school_notification did not insert rows '
            'visible to the calling staff');
  }, timeout: const Timeout(Duration(seconds: 60)));
}
