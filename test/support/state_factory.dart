import 'package:test/data/mock_state.dart';

/// Tier 1 test helpers. All of these assume `isSupabaseConfigured == false`
/// (the default when running `flutter test` without --dart-define), so every
/// MockState mutation stays in-memory and never touches network/Supabase.
class StateFactory {
  /// Build a fresh MockState seeded with the offline demo dataset.
  static MockState fresh({UserRole? loginAs}) {
    final s = MockState();
    if (loginAs != null) s.loginAs(loginAs);
    return s;
  }

  /// Counts how many times `state` calls `notifyListeners()` while [action]
  /// runs. Useful for asserting that mutations actually notify the UI.
  static int notifyCount(MockState state, void Function() action) {
    var count = 0;
    void listener() => count++;
    state.addListener(listener);
    try {
      action();
    } finally {
      state.removeListener(listener);
    }
    return count;
  }

  /// Async variant of [notifyCount].
  static Future<int> notifyCountAsync(
    MockState state,
    Future<void> Function() action,
  ) async {
    var count = 0;
    void listener() => count++;
    state.addListener(listener);
    try {
      await action();
    } finally {
      state.removeListener(listener);
    }
    return count;
  }
}

/// Convenience accessor: every demo student id seeded by `_loadDemoData`.
const kDemoStudentIds = <String>['s1', 's2', 's3', 's4'];
const kDemoApprovedRequestId = 'r0';
const kDemoPendingRequestId  = 'r1';

/// Quick sanity util so tests can assert on `ChangeNotifier` integration
/// without hand-rolling a listener.
extension MockStateTestX on MockState {
  /// Returns the requests list filtered by request id; throws if missing.
  ParentRequest requestById(String id) =>
      requests.firstWhere((r) => r.id == id);

  /// Returns the demo student by id; throws if missing.
  Student studentById(String id) => students.firstWhere((s) => s.id == id);
}

// re-export so test files only need this single import.
export 'package:test/data/mock_state.dart';
