import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

/// Result of an admin user-creation call.
class AdminCreateResult {
  const AdminCreateResult({
    this.userId,
    this.error,
    this.tempPassword,
    this.email,
  });
  final String? userId;
  final String? error;

  /// One-time temporary password generated for the new account. The staff
  /// member shares it with the user, who should change it on first login.
  final String? tempPassword;
  final String? email;
}

/// Wraps the `admin-create-user` Supabase Edge Function, which creates an
/// auth user (and its profile) using the service-role key on the server.
///
/// Creating parents / bus drivers from the admin panel must go through this
/// function because `profiles.id` references `auth.users(id)` — a profile
/// cannot exist without a backing auth account, and the service-role key must
/// never be shipped in the client.
class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  static const String _functionName = 'admin-create-user';

  /// Creates a user and returns the new auth user id (plus an error message
  /// when the call fails).
  Future<AdminCreateResult> createUserReturningId({
    required String email,
    required String fullName,
    required String role,
    required String schoolId,
    String? phone,
    String? nationalId,
  }) async {
    if (!isSupabaseConfigured) {
      return const AdminCreateResult(error: 'Supabase is not configured.');
    }
    try {
      final res = await supabase.functions.invoke(
        _functionName,
        body: {
          'email':       email.trim().toLowerCase(),
          'full_name':   fullName.trim(),
          'role':        role,
          'school_id':   schoolId,
          if (phone != null)      'phone':       phone.trim(),
          if (nationalId != null) 'national_id': nationalId.trim(),
        },
      );

      final data = res.data;
      if (data is Map && data['error'] != null) {
        return AdminCreateResult(error: data['error'].toString());
      }
      final userId = (data is Map) ? data['user_id'] as String? : null;
      final tempPassword =
          (data is Map) ? data['temp_password'] as String? : null;
      final returnedEmail = (data is Map) ? data['email'] as String? : null;
      return AdminCreateResult(
        userId: userId,
        tempPassword: tempPassword,
        email: returnedEmail ?? email,
      );
    } on FunctionException catch (e) {
      final details = e.details;
      final msg = (details is Map && details['error'] != null)
          ? details['error'].toString()
          : 'Failed to create account (status ${e.status}).';
      return AdminCreateResult(error: msg);
    } catch (e) {
      return AdminCreateResult(error: e.toString());
    }
  }

  /// Convenience wrapper that only reports success / failure.
  Future<String?> createUser({
    required String email,
    required String fullName,
    required String role,
    required String schoolId,
    String? phone,
    String? nationalId,
  }) async {
    final result = await createUserReturningId(
      email:      email,
      fullName:   fullName,
      role:       role,
      schoolId:   schoolId,
      phone:      phone,
      nationalId: nationalId,
    );
    return result.error;
  }

  /// Generate a new temporary password for an existing parent/driver/guardian.
  Future<AdminCreateResult> resetUserPassword({required String userId}) async {
    if (!isSupabaseConfigured) {
      return const AdminCreateResult(error: 'Supabase is not configured.');
    }
    try {
      final res = await supabase.functions.invoke(
        _functionName,
        body: {
          'action':  'reset_password',
          'user_id': userId,
        },
      );

      final data = res.data;
      if (data is Map && data['error'] != null) {
        return AdminCreateResult(error: data['error'].toString());
      }
      return AdminCreateResult(
        userId: (data is Map) ? data['user_id'] as String? : userId,
        tempPassword: (data is Map) ? data['temp_password'] as String? : null,
        email: (data is Map) ? data['email'] as String? : null,
      );
    } on FunctionException catch (e) {
      final details = e.details;
      final msg = (details is Map && details['error'] != null)
          ? details['error'].toString()
          : 'Failed to reset password (status ${e.status}).';
      return AdminCreateResult(error: msg);
    } catch (e) {
      return AdminCreateResult(error: e.toString());
    }
  }
}
