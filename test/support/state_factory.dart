import 'package:test/data/mock_state.dart';

/// Builds an offline [MockState] (demo data, no Supabase network calls).
MockState createOfflineState() => MockState();

/// Logs in via offline email inference and returns the state.
Future<MockState> createStateAsRole({
  required String email,
  UserRole? expectedRole,
}) async {
  final state = createOfflineState();
  final err = await state.signInWithEmailPassword(email, 'test-password');
  assert(err == null, 'Offline sign-in failed: $err');

  if (expectedRole != null) {
    assert(
      state.currentUserRole == expectedRole,
      'Expected $expectedRole but got ${state.currentUserRole}',
    );
  }
  return state;
}

/// Returns a listener that increments [counter] on each notify.
void Function() attachNotifyCounter(MockState state, List<int> counter) {
  void listener() => counter[0]++;
  state.addListener(listener);
  return listener;
}
