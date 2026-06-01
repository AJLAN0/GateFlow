import 'package:flutter_test/flutter_test.dart';
import 'package:test/backend/supabase/services/notification_service.dart';

import 'support/test_env.dart';

void main() {
  final env = IntegrationTestEnv.instance;

  integrationGroup('In-app notifications (remote)', () {
    setUpAll(() async {
      await env.ensureInitialized();
    });

    tearDownAll(() async {
      await env.tearDownAll();
    });

    integrationTest('send, unread count, mark all read', () async {
      await env.signInParent();
      final parentId = await env.currentUserId();
      expect(parentId, isNotNull);

      await env.signInStaff();
      await NotificationService.instance.send(
        userId: parentId!,
        title: 'IT Test Notification',
        body:  'Integration test body',
        type:  'info',
      );

      await env.signInParent();
      final rows = await env.client
          .from('notifications')
          .select('id')
          .eq('user_id', parentId)
          .eq('title', 'IT Test Notification')
          .order('created_at', ascending: false)
          .limit(1);
      expect(rows, isNotEmpty);
      env.tracker.trackNotification(rows.first['id'] as String);

      final unreadBefore =
          await NotificationService.instance.unreadCount(userId: parentId);
      expect(unreadBefore, greaterThan(0));

      await NotificationService.instance.markAllRead(userId: parentId);
      final unreadAfter =
          await NotificationService.instance.unreadCount(userId: parentId);
      expect(unreadAfter, 0);
    });

    integrationTest('broadcastToSchool RPC inserts rows for school roles', () async {
      await env.signInStaff();
      final schoolId = await env.currentSchoolId();
      expect(schoolId, isNotNull);

      await NotificationService.instance.broadcastToSchool(
        schoolId: schoolId!,
        title:    'IT Broadcast',
        body:     'School-wide integration test',
        roles:    ['parent'],
      );

      await env.signInParent();
      final broadcastRows = await env.client
          .from('notifications')
          .select('id, user_id')
          .eq('title', 'IT Broadcast')
          .limit(20);

      expect(broadcastRows, isNotEmpty);

      for (final row in broadcastRows) {
        env.tracker.trackNotification(row['id'] as String);
      }
    });
  });
}
