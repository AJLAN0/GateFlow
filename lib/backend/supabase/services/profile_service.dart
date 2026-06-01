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
    var filter = supabase
        .from('profiles')
        .select()
        .eq('school_id', schoolId);

    if (roleFilter != null) {
      filter = filter.eq('role', roleFilter);
    }

    final rows = await filter.order('full_name');
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
    final trimmed = nationalId.trim();
    if (trimmed.isEmpty) return null;

    final normalized = trimmed.replaceAll(RegExp(r'\D'), '');
    final candidates = <String>{
      trimmed,
      if (normalized.isNotEmpty) normalized,
    };

    for (final candidate in candidates) {
      final row = await supabase
          .from('profiles')
          .select()
          .eq('national_id', candidate)
          .maybeSingle();
      if (row != null) return DbProfile.fromJson(row);
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Linked student names for gate pickup (parent or guardian profile)
  // ---------------------------------------------------------------------------
  Future<List<String>> fetchGateLinkedStudentNames({
    required String profileId,
    required String role,
  }) async {
    if (role == 'parent') {
      final rows = await supabase
          .from('parent_students')
          .select('students(name)')
          .eq('parent_id', profileId);
      return _studentNamesFromJoinRows(rows);
    }

    if (role == 'guardian') {
      final guardianRows = await supabase
          .from('guardians')
          .select('id')
          .eq('guardian_user_id', profileId);
      if (guardianRows.isEmpty) return [];

      final names = <String>[];
      for (final g in guardianRows) {
        final guardianId = g['id'] as String;
        final rows = await supabase
            .from('guardian_students')
            .select('students(name)')
            .eq('guardian_id', guardianId);
        names.addAll(_studentNamesFromJoinRows(rows));
      }
      return names;
    }

    return [];
  }

  List<String> _studentNamesFromJoinRows(List<dynamic> rows) {
    final names = <String>[];
    for (final row in rows) {
      final student = row['students'];
      if (student is Map && student['name'] != null) {
        names.add(student['name'].toString());
      }
    }
    return names;
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
