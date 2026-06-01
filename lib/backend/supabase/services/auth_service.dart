import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/db_models.dart';
import '../supabase_config.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  User? get currentUser => supabase.auth.currentUser;
  Session? get currentSession => supabase.auth.currentSession;
  bool get isSignedIn => currentUser != null;

  Stream<AuthState> get onAuthStateChange =>
      supabase.auth.onAuthStateChange;

  // ---------------------------------------------------------------------------
  // Sign in with email + password
  // ---------------------------------------------------------------------------
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email:    email.trim().toLowerCase(),
      password: password,
    );
  }

  // ---------------------------------------------------------------------------
  // Sign up with email + password
  // ---------------------------------------------------------------------------
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? schoolId,
    String? phone,
  }) async {
    return await supabase.auth.signUp(
      email:    email.trim().toLowerCase(),
      password: password,
      data: {
        'full_name': fullName,
        'role':      role,
        if (schoolId != null) 'school_id': schoolId,
        if (phone != null)    'phone':      phone,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // Send password-reset email
  // ---------------------------------------------------------------------------
  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email.trim().toLowerCase());
  }

  // ---------------------------------------------------------------------------
  // Fetch the current user's profile
  // ---------------------------------------------------------------------------
  Future<DbProfile?> fetchProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;

    final row = await supabase
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (row == null) return null;
    return DbProfile.fromJson(row);
  }

  // ---------------------------------------------------------------------------
  // Update profile fields
  // ---------------------------------------------------------------------------
  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? nationalId,
  }) async {
    final uid = currentUser?.id;
    if (uid == null) return;

    await supabase.from('profiles').update({
      if (fullName != null)   'full_name':   fullName,
      if (phone != null)      'phone':       phone,
      if (avatarUrl != null)  'avatar_url':  avatarUrl,
      if (nationalId != null) 'national_id': nationalId,
    }).eq('id', uid);
  }
}
