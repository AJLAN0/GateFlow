import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test/backend/supabase/supabase_config.dart';

/// Set via `--dart-define=GATEFLOW_IT=true` when running integration tests.
const bool kRunIntegrationTests =
    bool.fromEnvironment('GATEFLOW_IT', defaultValue: false);

/// Demo credentials from [SeedService] / [kDemoAccounts].
const String kDemoPassword = 'GateFlow@2024';

class IntegrationTestEnv {
  IntegrationTestEnv._();
  static final IntegrationTestEnv instance = IntegrationTestEnv._();

  static SupabaseClient? _client;
  bool _initialized = false;
  final CreatedResourceTracker tracker = CreatedResourceTracker();

  SupabaseClient get client {
    final c = _client;
    if (c == null) {
      throw StateError('Call ensureInitialized() before using the client.');
    }
    return c;
  }

  /// Plain Dart Supabase client — same HTTP path as curl verify (no Flutter auth storage).
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (!isSupabaseConfigured) {
      throw StateError(
        'Supabase not configured. Run with --dart-define-from-file=.env.json',
      );
    }
    _client = SupabaseClient(kSupabaseUrl, kSupabaseAnonKey);
    setIntegrationTestClient(_client);
    _initialized = true;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final auth = client.auth;
    if (auth.currentSession != null) {
      try {
        await auth.signOut();
      } catch (_) {
        // Ignore sign-out errors when switching test users.
      }
    }
    try {
      final res = await auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      if (res.user == null) {
        throw StateError(
          'Sign-in returned no user for $email. '
          'Run: export GATEFLOW_DB_URL=... && ./tool/seed_demo.sh',
        );
      }
    } on AuthException catch (e) {
      throw StateError(
        'Sign-in failed for $email (${e.statusCode ?? '?'}): ${e.message}\n'
        'Run: ./tool/verify_demo_auth.sh $email\n'
        'If verify passes but tests fail, re-run with --concurrency=1.',
      );
    }
  }

  Future<void> signInStaff() => signIn(
        email: 'staff@demo.gateflow.app',
        password: kDemoPassword,
      );

  Future<void> signInParent() => signIn(
        email: 'parent@demo.gateflow.app',
        password: kDemoPassword,
      );

  Future<void> signInDriver() => signIn(
        email: 'driver@demo.gateflow.app',
        password: kDemoPassword,
      );

  Future<String?> currentUserId() async => client.auth.currentUser?.id;

  Future<String?> currentSchoolId() async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await client
        .from('profiles')
        .select('school_id')
        .eq('id', uid)
        .maybeSingle();
    return row?['school_id'] as String?;
  }

  Future<void> tearDownAll() async {
    await tracker.cleanup(client);
    if (client.auth.currentSession != null) {
      try {
        await client.auth.signOut();
      } catch (_) {}
    }
    _client = null;
    setIntegrationTestClient(null);
    _initialized = false;
  }
}

/// Tracks rows created during integration tests and deletes them on teardown.
class CreatedResourceTracker {
  final List<String> _scheduleIds = [];
  final List<String> _guardianIds = [];
  final List<String> _requestIds = [];
  final List<String> _studentIds = [];
  final List<String> _busIds = [];
  final List<String> _notificationIds = [];

  void trackSchedule(String id) => _scheduleIds.add(id);
  void untrackSchedule(String id) => _scheduleIds.remove(id);
  void trackGuardian(String id) => _guardianIds.add(id);
  void trackRequest(String id) => _requestIds.add(id);
  void trackStudent(String id) => _studentIds.add(id);
  void trackBus(String id) => _busIds.add(id);
  void trackNotification(String id) => _notificationIds.add(id);

  Future<void> cleanup(SupabaseClient client) async {
    for (final id in _notificationIds) {
      await client.from('notifications').delete().eq('id', id);
    }
    for (final id in _requestIds) {
      await client.from('pickup_requests').delete().eq('id', id);
    }
    for (final id in _guardianIds) {
      await client.from('guardian_students').delete().eq('guardian_id', id);
      await client.from('guardians').delete().eq('id', id);
    }
    for (final id in _scheduleIds) {
      await client.from('daily_schedules').delete().eq('id', id);
    }
    for (final id in _studentIds) {
      await client.from('parent_students').delete().eq('student_id', id);
      await client.from('students').delete().eq('id', id);
    }
    for (final id in _busIds) {
      await client.from('buses').delete().eq('id', id);
    }
    _notificationIds.clear();
    _requestIds.clear();
    _guardianIds.clear();
    _scheduleIds.clear();
    _studentIds.clear();
    _busIds.clear();
  }
}

/// Wraps a test body; skips when [kRunIntegrationTests] is false.
void integrationTest(String description, Future<void> Function() body) {
  test(description, body, skip: kRunIntegrationTests ? false : 'GATEFLOW_IT not set');
}

void integrationGroup(String description, void Function() body) {
  group(description, body, skip: kRunIntegrationTests ? false : 'GATEFLOW_IT not set');
}
