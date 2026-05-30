import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:test/backend/supabase/supabase_config.dart';

/// `true` when the tests should actually talk to the remote Supabase.
/// Run with:  flutter test integration_test --dart-define GATEFLOW_IT=true \
///                                          --dart-define-from-file=.env.json
const bool runIt = bool.fromEnvironment('GATEFLOW_IT');

/// Demo accounts seeded by SeedService.  All share kDemoPassword.
const kDemoPassword = 'GateFlow@2024';

const kStaffEmail    = 'staff@demo.gateflow.app';
const kParentEmail   = 'parent@demo.gateflow.app';
const kDriverEmail   = 'driver@demo.gateflow.app';
const kGuardianEmail = 'guardian@demo.gateflow.app';

class TestEnv {
  TestEnv._();
  static final TestEnv I = TestEnv._();

  /// Initialise Supabase once per test run. Safe to call multiple times.
  static bool _initialised = false;
  Future<void> ensureReady() async {
    if (_initialised) return;
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    if (!isSupabaseConfigured) {
      throw StateError(
        'GateFlow integration tests require SUPABASE_URL + SUPABASE_ANON_KEY. '
        'Run with --dart-define-from-file=.env.json',
      );
    }
    await initSupabase();
    _initialised = true;
  }

  SupabaseClient get client => Supabase.instance.client;

  Future<Session> signIn(String email, String password) async {
    final res = await client.auth.signInWithPassword(
      email:    email,
      password: password,
    );
    if (res.session == null) {
      throw StateError('Sign-in failed for $email (no session)');
    }
    return res.session!;
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (_) {/* idempotent */}
  }

  Future<String> currentSchoolId() async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');
    final row = await client
        .from('profiles')
        .select('school_id')
        .eq('id', uid)
        .maybeSingle();
    final sid = row?['school_id'] as String?;
    if (sid == null) throw StateError('Signed-in user has no school_id');
    return sid;
  }

  Future<String> currentUserId() async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');
    return uid;
  }

  /// Tracker of every row created by the test run so it can be torn down.
  /// Format: ('table', 'id').
  final List<(String, String)> _created = <(String, String)>[];

  void track(String table, String id) => _created.add((table, id));

  Future<void> teardown() async {
    // Use the most-privileged signed-in user to clean up. The harness runs
    // teardown while still authenticated as the last sign-in (typically
    // staff), so RLS deletes succeed for in-school rows.
    for (final entry in _created.reversed) {
      try {
        await client.from(entry.$1).delete().eq('id', entry.$2);
      } catch (_) {/* best-effort */}
    }
    _created.clear();
    await signOut();
  }
}

/// Skips the test group entirely when GATEFLOW_IT is not set.
void onlyIfIntegrationEnabled(String description, Function() body) {
  if (!runIt) {
    test(description, () {}, skip: 'GATEFLOW_IT not set');
    return;
  }
  group(description, () => body());
}
