import '../models/db_models.dart';
import '../supabase_config.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  // ---------------------------------------------------------------------------
  // Fetch all profiles for a school (admin view)
  // ---------------------------------------------------------------------------
  Future<List<DbProfile>> fetchBySchool({
    required String schoolId,
    String? roleFilter,
  }) async {
    var query = supabase
        .from('profiles')
        .select()
        .eq('school_id', schoolId)
        .order('full_name');

    if (roleFilter != null) {
      query = query.eq('role', roleFilter);
    }

    final rows = await query;
    return rows.map(DbProfile.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Fetch a single profile by ID
  // ---------------------------------------------------------------------------
  Future<DbProfile?> fetchById(String id) async {
    final row = await supabase
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return DbProfile.fromJson(row);
  }

  // ---------------------------------------------------------------------------
  // Lookup by national ID (gate verification)
  // ---------------------------------------------------------------------------
  Future<DbProfile?> lookupByNationalId(String nationalId) async {
    final row = await supabase
        .from('profiles')
        .select()
        .eq('national_id', nationalId.trim())
        .maybeSingle();
    if (row == null) return null;
    return DbProfile.fromJson(row);
  }

  // ---------------------------------------------------------------------------
  // Lookup by phone (gate verification) – partial match
  // ---------------------------------------------------------------------------
  Future<DbProfile?> lookupByPhone(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'\D'), '');
    if (normalized.isEmpty) return null;

    final rows = await supabase
        .from('profiles')
        .select()
        .ilike('phone', '%$normalized%')
        .limit(1);

    if (rows.isEmpty) return null;
    return DbProfile.fromJson(rows.first);
  }

  // ---------------------------------------------------------------------------
  // Fetch parent's linked student IDs
  // ---------------------------------------------------------------------------
  Future<List<String>> fetchParentStudentIds({required String parentId}) async {
    final rows = await supabase
        .from('parent_students')
        .select('student_id')
        .eq('parent_id', parentId);
    return rows.map((e) => e['student_id'] as String).toList();
  }

  // ---------------------------------------------------------------------------
  // Update profile
  // ---------------------------------------------------------------------------
  Future<void> update({
    required String id,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? nationalId,
    bool?   isActive,
  }) async {
    await supabase.from('profiles').update({
      if (fullName != null)   'full_name':   fullName,
      if (phone != null)      'phone':       phone,
      if (avatarUrl != null)  'avatar_url':  avatarUrl,
      if (nationalId != null) 'national_id': nationalId,
      if (isActive != null)   'is_active':   isActive,
    }).eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Deactivate (soft-delete) a profile (admin only)
  // ---------------------------------------------------------------------------
  Future<void> deactivate(String id) async {
    await supabase
        .from('profiles')
        .update({'is_active': false})
        .eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Real-time stream for school profiles
  // ---------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> streamBySchool({
    required String schoolId,
  }) =>
      supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('school_id', schoolId)
          .order('full_name');
}
