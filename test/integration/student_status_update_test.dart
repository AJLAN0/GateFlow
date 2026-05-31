import 'package:flutter_test/flutter_test.dart';
import 'package:test/backend/supabase/services/student_service.dart';

import 'support/test_env.dart';

void main() {
  final env = IntegrationTestEnv.instance;

  integrationGroup('Student status update (remote)', () {
    setUpAll(() async {
      await env.ensureInitialized();
    });

    tearDownAll(() async {
      await env.tearDownAll();
    });

    integrationTest('staff updates student status and it persists', () async {
      await env.signInStaff();
      final schoolId = await env.currentSchoolId();
      expect(schoolId, isNotNull);

      final student = await StudentService.instance.add(
        name:          'IT Status Student',
        grade:         'Grade IT',
        schoolId:      schoolId!,
        transportType: 'car',
      );
      env.tracker.trackStudent(student.id);

      await StudentService.instance.updateStatus(
        id:     student.id,
        status: 'on_bus_to_school',
        label:  'Integration test',
      );

      final row = await env.client
          .from('students')
          .select('status')
          .eq('id', student.id)
          .single();
      expect(row['status'], 'on_bus_to_school');

      await StudentService.instance.updateStatus(
        id:     student.id,
        status: 'at_school',
      );
      final row2 = await env.client
          .from('students')
          .select('status')
          .eq('id', student.id)
          .single();
      expect(row2['status'], 'at_school');
    });
  });
}
