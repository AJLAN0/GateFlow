import 'package:supabase_flutter/supabase_flutter.dart';

/// Replace with your Supabase project credentials.
/// Dashboard → Settings → API
const String kSupabaseUrl     = 'https://orghflnphjkkxxnslxjd.supabase.co';
const String kSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9yZ2hmbG5waGpra3h4bnNseGpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyMTU5NTgsImV4cCI6MjA5NDc5MTk1OH0.HBCAIyhn7WSl5VBdfvmeGQx3CeNYE7K1qxll-_CJ6_0';

/// Real credentials are configured — always true.
/// Set to false manually to force offline/demo mode.
const bool isSupabaseConfigured = true;

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
