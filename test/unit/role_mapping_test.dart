import 'package:flutter_test/flutter_test.dart';

import '../support/state_factory.dart';

void main() {
  group('roleFromString (DB → enum)', () {
    test('maps the four canonical role strings', () {
      expect(MockState.roleFromString('school_staff'), UserRole.schoolStaff);
      expect(MockState.roleFromString('bus_driver'),   UserRole.busDriver);
      expect(MockState.roleFromString('guardian'),     UserRole.guardian);
      expect(MockState.roleFromString('parent'),       UserRole.parent);
    });

    test('unknown strings safely fall back to parent', () {
      expect(MockState.roleFromString(''),        UserRole.parent);
      expect(MockState.roleFromString('garbage'), UserRole.parent);
    });
  });

  group('inferRoleFromEmail (offline sign-in path)', () {
    test('detects schoolStaff from "school" or "admin" markers', () {
      final state = StateFactory.fresh();
      expect(state.inferRoleFromEmail('staff@demo.gateflow.app'),
          UserRole.schoolStaff);
      expect(state.inferRoleFromEmail('admin@example.com'),
          UserRole.schoolStaff);
    });

    test('detects busDriver from "bus" or "driver" markers', () {
      final state = StateFactory.fresh();
      expect(state.inferRoleFromEmail('driver@demo.gateflow.app'),
          UserRole.busDriver);
      expect(state.inferRoleFromEmail('bus@example.com'),
          UserRole.busDriver);
    });

    test('detects guardian from the "guardian" marker', () {
      final state = StateFactory.fresh();
      expect(state.inferRoleFromEmail('guardian@demo.gateflow.app'),
          UserRole.guardian);
    });

    test('defaults to parent', () {
      final state = StateFactory.fresh();
      expect(state.inferRoleFromEmail('parent@demo.gateflow.app'),
          UserRole.parent);
      expect(state.inferRoleFromEmail('khaled@example.com'),
          UserRole.parent);
    });
  });

  group('loginAs', () {
    test('sets currentUserRole and notifies listeners exactly once', () {
      final state = StateFactory.fresh();
      expect(state.currentUserRole, UserRole.none);
      final count = StateFactory.notifyCount(
          state, () => state.loginAs(UserRole.schoolStaff));
      expect(state.currentUserRole, UserRole.schoolStaff);
      expect(count, 1);
    });
  });

  group('offline signInWithEmailPassword', () {
    test('infers + applies the role from the email', () async {
      final cases = <(String, UserRole)>[
        ('staff@demo.gateflow.app',    UserRole.schoolStaff),
        ('driver@demo.gateflow.app',   UserRole.busDriver),
        ('guardian@demo.gateflow.app', UserRole.guardian),
        ('parent@demo.gateflow.app',   UserRole.parent),
      ];
      for (final pair in cases) {
        final state = StateFactory.fresh();
        final err = await state.signInWithEmailPassword(pair.$1, 'pw');
        expect(err, isNull, reason: 'offline sign-in should not error');
        expect(state.currentUserRole, pair.$2,
            reason: 'expected ${pair.$2} for ${pair.$1}');
      }
    });
  });
}
