import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';
import 'auth_service.dart';

// ---------------------------------------------------------------------------
// Demo account definitions — one per role
// ---------------------------------------------------------------------------
class DemoAccount {
  final String email;
  final String password;
  final String fullName;
  final String role;        // matches profiles.role / DB strings
  final String description;

  const DemoAccount({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    required this.description,
  });
}

const kDemoPassword = 'GateFlow@2024';

const List<DemoAccount> kDemoAccounts = [
  DemoAccount(
    email:       'parent@demo.gateflow.app',
    password:    kDemoPassword,
    fullName:    'Khaled Al-Otaibi',
    role:        'parent',
    description: 'Parent — pickup requests, guardian invites, child tracking',
  ),
  DemoAccount(
    email:       'staff@demo.gateflow.app',
    password:    kDemoPassword,
    fullName:    'Noura Al-Zahrani',
    role:        'school_staff',
    description: 'School Staff — approve requests, manage students & alerts',
  ),
  DemoAccount(
    email:       'driver@demo.gateflow.app',
    password:    kDemoPassword,
    fullName:    'Omar Bin Saleh',
    role:        'bus_driver',
    description: 'Bus Driver — scan students on/off the bus',
  ),
  DemoAccount(
    email:       'guardian@demo.gateflow.app',
    password:    kDemoPassword,
    fullName:    'Mohammed Ali',
    role:        'guardian',
    description: 'Guardian — view assigned children, gate pickup',
  ),
];

// ---------------------------------------------------------------------------
// SeedService
// ---------------------------------------------------------------------------
class SeedService {
  SeedService._();
  static final SeedService instance = SeedService._();

  /// Attempts to sign up every demo account.
  /// If an account already exists the error is swallowed (idempotent).
  /// Returns a list of human-readable status lines.
  Future<List<String>> seedDemoAccounts() async {
    final results = <String>[];

    for (final account in kDemoAccounts) {
      try {
        await AuthService.instance.signUp(
          email:    account.email,
          password: account.password,
          fullName: account.fullName,
          role:     account.role,
        );
        results.add('✓ Created  ${account.role}  (${account.email})');
      } on AuthException catch (e) {
        if (_isAlreadyRegistered(e)) {
          results.add('– Exists   ${account.role}  (${account.email})');
        } else {
          results.add('✗ Failed   ${account.role}  (${account.email}): ${e.message}');
        }
      } catch (e) {
        results.add('✗ Failed   ${account.role}  (${account.email}): $e');
      }
    }

    // Sign back out after seeding so the app stays on the login screen.
    try {
      await supabase.auth.signOut();
    } catch (_) {}

    return results;
  }

  bool _isAlreadyRegistered(AuthException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('already registered') ||
        msg.contains('already exists') ||
        msg.contains('user already') ||
        e.statusCode == '422';
  }
}
