import 'package:supabase_flutter/supabase_flutter.dart';

/// Replace with your Supabase project credentials.
/// Dashboard → Settings → API
const String kSupabaseUrl     = 'YOUR_SUPABASE_PROJECT_URL';
const String kSupabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

bool get isSupabaseConfigured =>
    kSupabaseUrl     != 'YOUR_SUPABASE_PROJECT_URL' &&
    kSupabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';

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
