// =============================================================================
// Tier 3 integration test environment
// =============================================================================
// • Gated by GATEFLOW_IT=true — every flow test starts with
//     if (!TestEnv.enabled) return;
//   so `flutter test integration_test` is a no-op unless the flag is set.
// • Initialises Supabase once per process using the same .env.json the
//   running app uses.
// • Provides sign-in helpers + an ID tracker so each test cleans up after
//   itself in tearDownAll.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:test/backend/supabase/supabase_config.dart';
import 'package:test/backend/supabase/services/seed_service.dart';

class TestEnv {
  static const bool enabled = bool.fromEnvironment('GATEFLOW_IT');
  static bool _inited = false;

  /// Initialise Supabase exactly once per process.
  static Future<void> ensureInit() async {
    if (_inited) return;
    if (!isSupabaseConfigured) {
      throw StateError(
        'GATEFLOW_IT is set but SUPABASE_URL / SUPABASE_ANON_KEY are missing. '
        'Pass --dart-define-from-file=.env.json.',
      );
    }
    try {
      await initSupabase();
    } catch (_) {
      // Already initialised on a prior test file in the same isolate.
    }
    _inited = true;
  }

  // Demo accounts — created by SeedService on first run.
  static const parentEmail   = 'parent@demo.gateflow.app';
  static const staffEmail    = 'staff@demo.gateflow.app';
  static const driverEmail   = 'driver@demo.gateflow.app';
  static const guardianEmail = 'guardian@demo.gateflow.app';
  static const password      = kDemoPassword;

  /// Sign in as the given demo account; returns the auth uid.
  static Future<String> signInAs(String email) async {
    await supabase.auth.signOut(); // make sure we start clean
    final res = await supabase.auth.signInWithPassword(
      email:    email,
      password: password,
    );
    final id = res.user?.id;
    if (id == null) {
      throw StateError('Demo account $email did not return a user id.');
    }
    return id;
  }

  static Future<void> signOut() => supabase.auth.signOut();

  /// Skip-marker for the harness when the flag is off.
  static void skipIfDisabled() {
    if (!enabled) {
      markTestSkipped(
        'GATEFLOW_IT is not set — Tier 3 integration suite skipped.',
      );
    }
  }
}

/// Buckets the rows we created so tearDownAll can roll them back.
class CreatedIds {
  final List<String> requests        = [];
  final List<String> guardians       = [];
  final List<String> schedules       = [];
  final List<String> notifications   = [];
  final List<String> opAlerts        = [];

  Future<void> teardown() async {
    if (!TestEnv.enabled) return;

    // Order matters: child rows before parents.
    if (requests.isNotEmpty) {
      await supabase.from('pickup_requests').delete().inFilter('id', requests);
    }
    if (guardians.isNotEmpty) {
      await supabase
          .from('guardian_students')
          .delete()
          .inFilter('guardian_id', guardians);
      await supabase.from('guardians').delete().inFilter('id', guardians);
    }
    if (schedules.isNotEmpty) {
      await supabase
          .from('daily_schedules')
          .delete()
          .inFilter('id', schedules);
    }
    if (notifications.isNotEmpty) {
      await supabase
          .from('notifications')
          .delete()
          .inFilter('id', notifications);
    }
    if (opAlerts.isNotEmpty) {
      await supabase
          .from('operational_alerts')
          .delete()
          .inFilter('id', opAlerts);
    }
  }
}
