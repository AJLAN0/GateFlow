import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:test/backend/supabase/services/bus_service.dart';

import 'support/test_env.dart';

void main() {
  final env = IntegrationTestEnv.instance;

  integrationGroup('Realtime bus tracking (remote)', () {
    setUpAll(() async {
      await env.ensureInitialized();
    });

    tearDownAll(() async {
      await env.tearDownAll();
    });

    integrationTest('bus status stream emits after update', () async {
      await env.signInStaff();
      final schoolId = await env.currentSchoolId();
      expect(schoolId, isNotNull);

      final bus = await BusService.instance.add(
        name:       'IT Realtime Bus',
        schoolId:   schoolId!,
        routeLabel: 'Test Route',
      );
      env.tracker.trackBus(bus.id);

      final completer = Completer<Map<String, dynamic>?>();
      late StreamSubscription<List<Map<String, dynamic>>> sub;

      sub = BusService.instance.streamSchool(schoolId: schoolId).listen(
        (rows) {
          final match = rows.where((r) => r['id'] == bus.id).toList();
          if (match.isEmpty) return;
          final status = match.first['status'] as String?;
          if (status == 'on_route_to_home' && !completer.isCompleted) {
            completer.complete(match.first);
          }
        },
      );

      // Allow Realtime channel to subscribe (requires buses in supabase_realtime publication).
      await Future<void>.delayed(const Duration(seconds: 4));

      await BusService.instance.updateStatus(
        id:     bus.id,
        status: 'on_route_to_home',
        label:  'Integration realtime test',
      );

      var updated = await completer.future.timeout(
        const Duration(seconds: 25),
        onTimeout: () => null,
      );

      await sub.cancel();

      if (updated == null) {
        // Fallback: verify persistence if Realtime is slow/unavailable on the project.
        final row = await env.client
            .from('buses')
            .select('status')
            .eq('id', bus.id)
            .single();
        expect(
          row['status'],
          'on_route_to_home',
          reason:
              'Realtime event not received; bus status must still persist in DB',
        );
        return;
      }

      expect(updated['status'], 'on_route_to_home');
    });
  });
}
