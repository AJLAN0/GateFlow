/// Run with:  dart run tool/seed_accounts.dart
///
/// Creates one Supabase auth user + profile row for each role.
/// Safe to re-run — existing accounts are reported and skipped.
///
/// If you get "Email not confirmed" errors, disable email confirmation in:
///   Supabase Dashboard → Authentication → Providers → Email → uncheck "Confirm email"
library;

import 'dart:convert';
import 'dart:io';

// ─── Project credentials ────────────────────────────────────────────────────
const _url     = 'https://orghflnphjkkxxnslxjd.supabase.co';
const _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
    '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9yZ2hmbG5waGpra3h4bnNseGpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyMTU5NTgsImV4cCI6MjA5NDc5MTk1OH0'
    '.HBCAIyhn7WSl5VBdfvmeGQx3CeNYE7K1qxll-_CJ6_0';

// ─── Demo accounts ──────────────────────────────────────────────────────────
const _password = 'GateFlow@2024';

const _accounts = [
  {
    'email':    'parent@demo.gateflow.app',
    'fullName': 'Khaled Al-Otaibi',
    'role':     'parent',
  },
  {
    'email':    'staff@demo.gateflow.app',
    'fullName': 'Noura Al-Zahrani',
    'role':     'school_staff',
  },
  {
    'email':    'driver@demo.gateflow.app',
    'fullName': 'Omar Bin Saleh',
    'role':     'bus_driver',
  },
  {
    'email':    'guardian@demo.gateflow.app',
    'fullName': 'Mohammed Ali',
    'role':     'guardian',
  },
];

// ─── Main ───────────────────────────────────────────────────────────────────
Future<void> main() async {
  final client = HttpClient();
  print('\n═══════════════════════════════════════════');
  print(' GateFlow — Supabase demo account seeder');
  print('═══════════════════════════════════════════\n');

  for (final account in _accounts) {
    final email    = account['email']!;
    final fullName = account['fullName']!;
    final role     = account['role']!;

    stdout.write('  ${role.padRight(14)} $email  →  ');

    try {
      final uri = Uri.parse('$_url/auth/v1/signup');
      final req = await client.postUrl(uri);
      req.headers
        ..set('apikey',       _anonKey)
        ..set('Content-Type', 'application/json');

      req.write(jsonEncode({
        'email':    email,
        'password': _password,
        'data': {
          'full_name': fullName,
          'role':      role,
        },
      }));

      final res  = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (res.statusCode == 200 && json['id'] != null) {
        print('✓ Created  (id: ${json['id']})');
      } else if (res.statusCode == 400) {
        final msg = (json['msg'] ?? json['message'] ?? '').toString().toLowerCase();
        if (msg.contains('already registered') || msg.contains('already exists')) {
          print('– Already exists');
        } else {
          print('✗ ${json['msg'] ?? json['message'] ?? body}');
        }
      } else if (res.statusCode == 422) {
        print('– Already exists');
      } else {
        print('✗ HTTP ${res.statusCode}: ${json['msg'] ?? json['error_description'] ?? body}');
      }
    } catch (e) {
      print('✗ Error: $e');
    }
  }

  client.close();

  print('\n───────────────────────────────────────────');
  print(' Password for all accounts: $_password');
  print('───────────────────────────────────────────\n');
  print('Tip: if accounts were created but you need email');
  print('confirmation disabled, go to:');
  print('  Supabase Dashboard → Authentication → Providers');
  print('  → Email → uncheck "Confirm email"\n');
}
