import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:test/backend/supabase/supabase_config.dart';
import 'package:test/backend/supabase/services/auth_service.dart';

import 'support/test_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(TestEnv.ensureInit);

  test('RBAC smoke: parent vs staff see different rowsets', () async {
    if (!TestEnv.enabled) {
      markTestSkipped('GATEFLOW_IT is off');
      return;
    }

    // -- Parent view ---------------------------------------------------------
    await TestEnv.signInAs(TestEnv.parentEmail);
    final parentProfile = await AuthService.instance.fetchProfile();
    expect(parentProfile, isNotNull);
    expect(parentProfile!.role, 'parent');

    final parentRequests = await supabase
        .from('pickup_requests')
        .select('id, requested_by');

    // RLS guarantees the parent only sees their own rows.
    for (final r in parentRequests) {
      expect(r['requested_by'], parentProfile.id);
    }

    // -- Staff view ----------------------------------------------------------
    await TestEnv.signInAs(TestEnv.staffEmail);
    final staffProfile = await AuthService.instance.fetchProfile();
    expect(staffProfile, isNotNull);
    expect(staffProfile!.role, 'school_staff');

    final staffRequests = await supabase
        .from('pickup_requests')
        .select('id');

    // Staff should see at least as many requests as the parent did.
    expect(
      staffRequests.length,
      greaterThanOrEqualTo(parentRequests.length),
      reason: 'staff should see ≥ everything the parent sees in the school',
    );

    await TestEnv.signOut();
  }, timeout: const Timeout(Duration(seconds: 60)));
}
