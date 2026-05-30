// =============================================================================
// State factory — builds an offline MockState for Tier 1 unit tests.
//
// Because `isSupabaseConfigured` is `false` whenever SUPABASE_URL is empty
// (the default under `flutter test`), MockState() falls back to its in-memory
// demo seed. All mutations are guarded by `if (isSupabaseConfigured)` so no
// network call ever fires. That gives Tier 1 a clean, deterministic substrate
// without any DI plumbing.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:test/data/mock_state.dart';

/// Build a fresh MockState seeded with demo data, with [role] set.
MockState buildState({UserRole role = UserRole.parent}) {
  // Sanity check — if a developer runs `flutter test` with --dart-define
  // SUPABASE_URL set, the demo seed wouldn't load and the tests would
  // silently behave differently.
  final s = MockState();
  expect(
    s.students.isNotEmpty,
    isTrue,
    reason: 'MockState must load demo seed for unit tests. '
        'Did SUPABASE_URL get set in the test env?',
  );
  s.loginAs(role);
  return s;
}

/// Counts how many times the ChangeNotifier fires.
class NotifyCounter {
  NotifyCounter(this.state) {
    state.addListener(_inc);
  }
  final MockState state;
  int value = 0;
  void _inc() => value++;
  void dispose() => state.removeListener(_inc);
}
