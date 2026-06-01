import 'package:flutter_test/flutter_test.dart';
import 'package:test/data/mock_state.dart';

import '../support/state_factory.dart';

void main() {
  group('Role mapping', () {
    test('staff email maps to schoolStaff role', () async {
      final state = await createStateAsRole(
        email: 'admin@school.edu',
        expectedRole: UserRole.schoolStaff,
      );
      expect(state.currentUserRole, UserRole.schoolStaff);
    });

    test('driver email maps to busDriver role', () async {
      final state = await createStateAsRole(
        email: 'driver@bus.demo',
        expectedRole: UserRole.busDriver,
      );
      expect(state.currentUserRole, UserRole.busDriver);
    });

    test('guardian email maps to guardian role', () async {
      final state = await createStateAsRole(
        email: 'guardian@demo.gateflow.app',
        expectedRole: UserRole.guardian,
      );
      expect(state.currentUserRole, UserRole.guardian);
    });

    test('generic email maps to parent role', () async {
      final state = await createStateAsRole(
        email: 'parent@demo.gateflow.app',
        expectedRole: UserRole.parent,
      );
      expect(state.currentUserRole, UserRole.parent);
    });

    test('loginAs sets role and notifies', () {
      final state = createOfflineState();
      var count = 0;
      state.addListener(() => count++);
      state.loginAs(UserRole.schoolStaff);
      expect(state.currentUserRole, UserRole.schoolStaff);
      expect(count, greaterThan(0));
    });

    test('normalizeDigits strips non-digits', () {
      expect(MockState.normalizeDigits('+966 50 111 2233'), '966501112233');
      expect(MockState.normalizeDigits('abc'), '');
    });
  });
}
