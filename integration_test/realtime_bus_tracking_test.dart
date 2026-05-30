import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:test/backend/supabase/services/bus_service.dart';
import 'support/test_env.dart';

void main() {
  onlyIfIntegrationEnabled('Realtime bus tracking', () {
    final env = TestEnv.I;

    setUpAll(() async => env.ensureReady());
    tearDownAll(() async => env.teardown());

    test('a status change on one client is emitted to a subscriber',
        () async {
      await env.signIn(kStaffEmail, kDemoPassword);
      final schoolId = await env.currentSchoolId();

      final buses = await BusService.instance.fetchAll(schoolId: schoolId);
      expect(buses, isNotEmpty,
          reason: 'demo seed should have at least one bus');
      final bus = buses.first;

      final completer = Completer<String>();
      late StreamSubscription sub;
      sub = BusService.instance.streamSchool(schoolId: schoolId).listen((rows) {
        for (final r in rows) {
          if (r['id'] == bus.id &&
              r['status'] != bus.status &&
              !completer.isCompleted) {
            completer.complete(r['status'] as String);
          }
        }
      });

      // Flip to a new status.
      final newStatus = bus.status == 'on_route_to_school'
          ? 'on_route_to_home'
          : 'on_route_to_school';
      await BusService.instance.updateStatus(id: bus.id, status: newStatus);

      final emitted = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => 'TIMEOUT',
      );
      await sub.cancel();

      expect(emitted, newStatus,
          reason: 'realtime stream should emit the new status within 15s');

      // Restore.
      await BusService.instance.updateStatus(id: bus.id, status: bus.status);
    });
  });
}
