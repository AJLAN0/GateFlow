import 'package:flutter_test/flutter_test.dart';

import 'package:test/backend/supabase/services/notification_service.dart';
import 'support/test_env.dart';

void main() {
  onlyIfIntegrationEnabled('Notifications', () {
    final env = TestEnv.I;

    setUpAll(() async => env.ensureReady());
    tearDownAll(() async => env.teardown());

    test('NotificationService.send inserts a row and updates unreadCount',
        () async {
      await env.signIn(kParentEmail, kDemoPassword);
      final userId = await env.currentUserId();

      final before = await NotificationService.instance.unreadCount(userId: userId);

      await NotificationService.instance.send(
        userId: userId,
        title:  'IT notification',
        body:   'integration-test body',
        type:   'info',
      );

      final after = await NotificationService.instance.unreadCount(userId: userId);
      expect(after, before + 1);

      await NotificationService.instance.markAllRead(userId: userId);
      final cleared = await NotificationService.instance.unreadCount(userId: userId);
      expect(cleared, 0);

      // Cleanup: delete the IT row.
      try {
        await env.client
            .from('notifications')
            .delete()
            .eq('user_id', userId)
            .eq('title', 'IT notification');
      } catch (_) {}
    });

    test('broadcastToSchool RPC fans out to school users', () async {
      await env.signOut();
      await env.signIn(kStaffEmail, kDemoPassword);
      final schoolId = await env.currentSchoolId();

      final unique = DateTime.now().millisecondsSinceEpoch.toString();
      final title  = 'IT broadcast $unique';

      await NotificationService.instance.broadcastToSchool(
        schoolId: schoolId,
        title:    title,
        body:     'integration-test broadcast',
      );

      // As staff we can read our own notifications row (own-notifications policy).
      final me = await env.currentUserId();
      final myRow = await env.client
          .from('notifications')
          .select('id, title')
          .eq('user_id', me)
          .eq('title', title)
          .maybeSingle();
      expect(myRow, isNotNull,
          reason: 'broadcast must reach the school_staff caller themselves');

      // Cleanup ours; the rest persist past the test as a known cost (the rows
      // are only readable by their owners under RLS, so we can't sweep them up
      // from this client without a service-role key).
      if (myRow != null) {
        await env.client.from('notifications').delete().eq('id', myRow['id'] as String);
      }
    });
  });
}
