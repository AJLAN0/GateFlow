import 'package:flutter_test/flutter_test.dart';
import 'package:test/data/mock_state.dart';

import '../support/state_factory.dart';

void main() {
  group('loginAs (offline)', () {
    test('sets role and notifies listeners', () {
      final s = buildState(role: UserRole.none);
      final notifier = NotifyCounter(s);

      s.loginAs(UserRole.busDriver);
      expect(s.currentUserRole, UserRole.busDriver);
      expect(notifier.value, greaterThanOrEqualTo(1));

      s.loginAs(UserRole.parent);
      expect(s.currentUserRole, UserRole.parent);
      notifier.dispose();
    });
  });

  group('email → role inference (via signInWithEmailPassword offline)', () {
    // signInWithEmailPassword, when Supabase is not configured, calls
    // loginAs(_inferRoleFromEmail(email)). That lets us cover the private
    // mapping table indirectly without exposing it.
    Future<UserRole> roleFor(String email) async {
      final s = MockState();
      await s.signInWithEmailPassword(email, 'anything');
      return s.currentUserRole;
    }

    test('school / admin → schoolStaff', () async {
      expect(await roleFor('noura@school.test'), UserRole.schoolStaff);
      expect(await roleFor('admin@gateflow.test'), UserRole.schoolStaff);
    });

    test('bus / driver → busDriver', () async {
      expect(await roleFor('omar@bus.test'), UserRole.busDriver);
      expect(await roleFor('hassan.driver@x.test'), UserRole.busDriver);
    });

    test('guardian → guardian', () async {
      expect(await roleFor('mohammed@guardian.test'), UserRole.guardian);
    });

    test('anything else → parent', () async {
      expect(await roleFor('khalid@otaibi.test'), UserRole.parent);
      expect(await roleFor(''), UserRole.parent);
    });
  });
}
