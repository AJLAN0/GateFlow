// =============================================================================
// Realtime bus tracking — verify a bus_status change propagates to a
// second listener within a reasonable window.
//
// Strategy: a single Supabase client is enough — we subscribe via the streaming
// API, then perform the write from the same session. Realtime delivery still
// goes through the WebSocket channel, so the assertion proves the path.
// =============================================================================

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:test/backend/supabase/supabase_config.dart';
import 'package:test/backend/supabase/services/auth_service.dart';
import 'package:test/backend/supabase/services/bus_service.dart';

import 'support/test_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(TestEnv.ensureInit);

  test('bus status update propagates over realtime stream', () async {
    if (!TestEnv.enabled) {
      markTestSkipped('GATEFLOW_IT is off');
      return;
    }

    await TestEnv.signInAs(TestEnv.staffEmail);
    final staff = await AuthService.instance.fetchProfile();
    expect(staff?.schoolId, isNotNull);

    final buses = await BusService.instance.fetchAll(
      schoolId: staff!.schoolId!,
    );
    if (buses.isEmpty) {
      markTestSkipped('no buses in the demo school');
      return;
    }
    final bus      = buses.first;
    final original = bus.status;
    final next     =
        original == 'on_route_to_school' ? 'stationary' : 'on_route_to_school';

    final completer = Completer<String>();
    late StreamSubscription sub;

    sub = BusService.instance
        .streamSchool(schoolId: staff.schoolId!)
        .listen((rows) {
      for (final r in rows) {
        if (r['id'] == bus.id && r['status'] == next) {
          if (!completer.isCompleted) completer.complete(r['status'] as String);
        }
      }
    });

    // Give the subscription time to attach, then trigger the change.
    await Future<void>.delayed(const Duration(seconds: 2));
    await BusService.instance.updateStatus(id: bus.id, status: next);

    final observed = await completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () => 'TIMEOUT',
    );
    await sub.cancel();

    // Always restore status, even on failure, so the test is idempotent.
    await BusService.instance.updateStatus(id: bus.id, status: original);

    expect(observed, next,
        reason: 'realtime stream did not deliver the bus status change');

    await TestEnv.signOut();
  }, timeout: const Timeout(Duration(seconds: 60)));
}
