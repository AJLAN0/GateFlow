import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:test/backend/supabase/supabase_config.dart';
import 'package:test/backend/supabase/services/auth_service.dart';
import 'package:test/backend/supabase/services/request_service.dart';
import 'package:test/backend/supabase/services/student_service.dart';

import 'support/test_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final created = CreatedIds();

  setUpAll(TestEnv.ensureInit);
  tearDownAll(created.teardown);

  test('parent submit → staff approve → gate release → parent delete pending',
      () async {
    if (!TestEnv.enabled) {
      markTestSkipped('GATEFLOW_IT is off');
      return;
    }

    // -- Parent submits --------------------------------------------------
    await TestEnv.signInAs(TestEnv.parentEmail);
    final parent = await AuthService.instance.fetchProfile();
    expect(parent, isNotNull);

    final children = await StudentService.instance.fetchForParent(
      parentId: parent!.id,
    );
    if (children.isEmpty) {
      markTestSkipped('demo parent has no linked students');
      return;
    }
    final student = children.first;

    // Request A (approved-and-released)
    final reqA = await RequestService.instance.submit(
      studentId:           student.id,
      requestedBy:         parent.id,
      type:                'Early Pickup',
      timeLabel:           '3:30 PM',
      pickupPersonSummary: 'IT suite',
    );
    created.requests.add(reqA.id);

    // Request B (pending, to be deleted by parent below)
    final reqB = await RequestService.instance.submit(
      studentId:           student.id,
      requestedBy:         parent.id,
      type:                'Late Drop-off',
      timeLabel:           '4:00 PM',
      pickupPersonSummary: 'IT suite (deletable)',
    );
    created.requests.add(reqB.id);

    expect(reqA.status, 'pending');

    // -- Staff approves request A ---------------------------------------
    await TestEnv.signInAs(TestEnv.staffEmail);
    final staff = await AuthService.instance.fetchProfile();
    expect(staff, isNotNull);

    await RequestService.instance.reviewRequest(
      id:         reqA.id,
      status:     'approved',
      reviewedBy: staff!.id,
    );
    await RequestService.instance.releaseAtGate(reqA.id);

    final releasedRow = await supabase
        .from('pickup_requests')
        .select()
        .eq('id', reqA.id)
        .single();
    expect(releasedRow['status'], 'approved');
    expect(releasedRow['released_at_gate'], true);
    expect(releasedRow['released_at'], isNotNull);

    // -- Parent deletes their own pending request B ---------------------
    await TestEnv.signInAs(TestEnv.parentEmail);
    await RequestService.instance.delete(reqB.id);

    final remaining = await supabase
        .from('pickup_requests')
        .select('id')
        .eq('id', reqB.id);
    expect(remaining, isEmpty,
        reason: 'parent should be able to delete their own pending request');

    // Cleanup of B by parent succeeded; remove from tracker so teardown
    // doesn't try to delete it again.
    created.requests.remove(reqB.id);

    await TestEnv.signOut();
  }, timeout: const Timeout(Duration(seconds: 120)));
}
