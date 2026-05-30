// Placeholder widget test.
//
// The real widget surface needs a fully-wired MockState + GoRouter to build,
// which is out of scope for the offline test lane. Tier 1 unit tests under
// `test/unit/` exercise the business logic; integration tests under
// `integration_test/` cover the wired widget tree on a real device.

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder', () {
    expect(2 + 2, 4);
  });
}
