import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:test/backend/supabase/supabase_config.dart';
import 'package:test/backend/supabase/services/auth_service.dart';
import 'package:test/backend/supabase/services/bus_service.dart';
import 'package:test/backend/supabase/services/student_service.dart';

import 'support/test_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(TestEnv.ensureInit);

  test(
      'driver: status update succeeds on own bus, fails on other bus',
      () async {
    if (!TestEnv.enabled) {
      markTestSkipped('GATEFLOW_IT is off');
      return;
    }

    // -- Sign in as driver, find own bus + own-bus student --------------
    await TestEnv.signInAs(TestEnv.driverEmail);
    final driver = await AuthService.instance.fetchProfile();
    expect(driver?.role, 'bus_driver');

    final ownBus = await BusService.instance.fetchDriverBus(
      driverId: driver!.id,
    );
    if (ownBus == null) {
      markTestSkipped('driver has no assigned bus in this environment');
      return;
    }
    final onOwn = await StudentService.instance.fetchForBus(busId: ownBus.id);
    if (onOwn.isEmpty) {
      markTestSkipped('driver has no students on their bus');
      return;
    }

    // -- 1. driver updates an own-bus student → succeeds ----------------
    final target = onOwn.first;
    final prevStatus = target.status;
    final nextStatus =
        prevStatus == 'on_bus_to_school' ? 'at_school' : 'on_bus_to_school';

    await StudentService.instance.updateStatus(
      id:     target.id,
      status: nextStatus,
      label:  'IT suite scan',
    );

    final after = await supabase
        .from('students')
        .select('status, last_update_label')
        .eq('id', target.id)
        .single();
    expect(after['status'], nextStatus);
    expect(after['last_update_label'], 'IT suite scan');

    // Restore so future runs are idempotent.
    await StudentService.instance.updateStatus(
      id:     target.id,
      status: prevStatus,
      label:  after['last_update_label'] ?? 'reset',
    );

    // -- 2. driver tries to update a student on a different bus -------
    final allBuses = await BusService.instance.fetchAll(
      schoolId: driver.schoolId!,
    );
    final otherBus = allBuses.firstWhere(
      (b) => b.id != ownBus.id,
      orElse: () => ownBus,
    );

    if (otherBus.id == ownBus.id) {
      // Single-bus environment — the negative case is impossible here.
      return;
    }

    final onOther =
        await StudentService.instance.fetchForBus(busId: otherBus.id);
    if (onOther.isEmpty) {
      return;
    }
    final foreign = onOther.first;
    final foreignBefore = foreign.status;

    await StudentService.instance.updateStatus(
      id:     foreign.id,
      status: foreignBefore == 'at_school' ? 'at_home' : 'at_school',
      label:  'SHOULD_NOT_PERSIST',
    );

    final foreignAfter = await supabase
        .from('students')
        .select('status, last_update_label')
        .eq('id', foreign.id)
        .single();
    expect(
      foreignAfter['status'],
      foreignBefore,
      reason: 'driver must not change status on a different bus',
    );
    expect(foreignAfter['last_update_label'],
        isNot(equals('SHOULD_NOT_PERSIST')));

    await TestEnv.signOut();
  }, timeout: const Timeout(Duration(seconds: 90)));
}
