import 'package:supabase_flutter/supabase_flutter.dart';

/// Credentials are injected at build time via --dart-define-from-file=.env.json
/// Never hardcode these values here — keep .env.json in .gitignore.
///
/// Run the app with:
///   flutter run --dart-define-from-file=.env.json
///
/// Build with:
///   flutter build web --dart-define-from-file=.env.json
const String kSupabaseUrl =
    String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const String kSupabaseAnonKey =
    String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

const bool isSupabaseConfigured =
    kSupabaseUrl.length > 0 && kSupabaseAnonKey.length > 0;

Future<void> initSupabase() async {
  await Supabase.initialize(
    url:     kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );
}

SupabaseClient get supabase => Supabase.instance.client;
