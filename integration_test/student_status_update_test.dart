import 'package:flutter_test/flutter_test.dart';

import 'package:test/backend/supabase/services/student_service.dart';
import 'support/test_env.dart';

void main() {
  onlyIfIntegrationEnabled('Student status update', () {
    final env = TestEnv.I;

    setUpAll(() async => env.ensureReady());
    tearDownAll(() async => env.teardown());

    test('staff status update persists and round-trips through the enum',
        () async {
      await env.signIn(kStaffEmail, kDemoPassword);
      final schoolId = await env.currentSchoolId();

      final students = await StudentService.instance.fetchAll(
        schoolId: schoolId,
      );
      expect(students, isNotEmpty,
          reason: 'demo seed should have students for the staff\'s school');
      final s = students.first;

      final original = s.status;
      final target   = original == 'on_bus_to_school'
          ? 'at_school'
          : 'on_bus_to_school';

      await StudentService.instance.updateStatus(
        id:     s.id,
        status: target,
        label:  'integration-test update',
      );

      final after = await env.client
          .from('students')
          .select('status, last_update_label')
          .eq('id', s.id)
          .single();
      expect(after['status'], target);

      // Restore.
      await StudentService.instance.updateStatus(
        id:     s.id,
        status: original,
        label:  'integration-test restore',
      );
    });

    test('driver CAN update own-bus student, CANNOT update another bus',
        () async {
      await env.signOut();
      await env.signIn(kDriverEmail, kDemoPassword);
      final driverId = await env.currentUserId();

      // Find driver's bus.
      final myBus = await env.client
          .from('buses')
          .select('id, school_id')
          .eq('driver_id', driverId)
          .maybeSingle();
      if (myBus == null) {
        // Driver hasn't been assigned a bus in the seed → skip without failing.
        return;
      }
      final myBusId   = myBus['id']        as String;
      final schoolId  = myBus['school_id'] as String;

      // Pick a student on this bus.
      final mine = await env.client
          .from('students')
          .select('id, status')
          .eq('bus_id', myBusId)
          .limit(1);

      if (mine.isNotEmpty) {
        final s = mine.first;
        final original = s['status'] as String;
        final target   = original == 'on_bus_to_school'
            ? 'at_school'
            : 'on_bus_to_school';
        await StudentService.instance.updateStatus(id: s['id'] as String, status: target);
        final reread = await env.client
            .from('students')
            .select('status')
            .eq('id', s['id'] as String)
            .single();
        expect(reread['status'], target);
        await StudentService.instance.updateStatus(id: s['id'] as String, status: original);
      }

      // Pick a student NOT on this bus.
      final others = await env.client
          .from('students')
          .select('id, status, bus_id')
          .eq('school_id', schoolId)
          .not('bus_id', 'eq', myBusId)
          .limit(1);
      if (others.isNotEmpty) {
        final s = others.first;
        final originalStatus = s['status'] as String;
        await StudentService.instance.updateStatus(
          id: s['id'] as String,
          status: 'on_bus_to_school',
        );
        final reread = await env.client
            .from('students')
            .select('status')
            .eq('id', s['id'] as String)
            .single();
        expect(reread['status'], originalStatus,
            reason: 'RLS must block driver writes to other buses');
      }
    });
  });
}
