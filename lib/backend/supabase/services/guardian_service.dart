import '../models/db_models.dart';
import '../supabase_config.dart';

class GuardianService {
  GuardianService._();
  static final GuardianService instance = GuardianService._();

  // ---------------------------------------------------------------------------
  // Fetch all guardians submitted by a parent
  // ---------------------------------------------------------------------------
  Future<List<DbGuardian>> fetchByParent({required String parentId}) async {
    final rows = await supabase
        .from('guardians')
        .select('*, guardian_students(student_id)')
        .eq('parent_id', parentId)
        .order('created_at', ascending: false);
    return rows.map(DbGuardian.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Fetch all guardians for a school (admin view)
  // ---------------------------------------------------------------------------
  Future<List<DbGuardian>> fetchBySchool({
    required String schoolId,
    String? statusFilter,
  }) async {
    var query = supabase
        .from('guardians')
        .select('*, profiles!parent_id(school_id), guardian_students(student_id)')
        .eq('profiles.school_id', schoolId);

    if (statusFilter != null) {
      query = query.eq('status', statusFilter);
    }

    final rows = await query.order('created_at', ascending: false);
    return rows.map(DbGuardian.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Real-time stream: parent's guardians
  // ---------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> streamByParent({
    required String parentId,
  }) =>
      supabase
          .from('guardians')
          .stream(primaryKey: ['id'])
          .eq('parent_id', parentId)
          .order('created_at', ascending: false);

  // ---------------------------------------------------------------------------
  // Real-time stream: pending guardians (school admin)
  // ---------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> streamPending() =>
      supabase
          .from('guardians')
          .stream(primaryKey: ['id'])
          .eq('status', 'pending')
          .order('created_at', ascending: false);

  // ---------------------------------------------------------------------------
  // Submit guardian invite (parent)
  // ---------------------------------------------------------------------------
  Future<DbGuardian> submit({
    required String parentId,
    required String fullName,
    required String relationship,
    String? phone,
    String? email,
    String? nationalId,
    String? notes,
    List<String> studentIds = const [],
  }) async {
    final row = await supabase
        .from('guardians')
        .insert({
          'parent_id':    parentId,
          'full_name':    fullName,
          'relationship': relationship,
          'status':       'pending',
          if (phone != null)      'phone':       phone,
          if (email != null)      'email':       email,
          if (nationalId != null) 'national_id': nationalId,
          if (notes != null)      'notes':       notes,
        })
        .select()
        .single();

    final guardian = DbGuardian.fromJson(row);

    // Link to students
    if (studentIds.isNotEmpty) {
      await supabase.from('guardian_students').insert(
        studentIds
            .map((sId) => {
                  'guardian_id': guardian.id,
                  'student_id':  sId,
                })
            .toList(),
      );
    }

    return guardian;
  }

  // ---------------------------------------------------------------------------
  // Approve or reject guardian (admin)
  // ---------------------------------------------------------------------------
  Future<void> reviewGuardian({
    required String id,
    required String status,   // 'approved' | 'rejected'
    required String reviewedBy,
  }) async {
    await supabase.from('guardians').update({
      'status':        status,
      'authorized_by': reviewedBy,
      'authorized_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Delete guardian (parent or admin)
  // ---------------------------------------------------------------------------
  Future<void> delete(String id) async {
    await supabase.from('guardians').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Fetch students linked to a guardian
  // ---------------------------------------------------------------------------
  Future<List<String>> fetchLinkedStudentIds({
    required String guardianId,
  }) async {
    final rows = await supabase
        .from('guardian_students')
        .select('student_id')
        .eq('guardian_id', guardianId);
    return rows.map((e) => e['student_id'] as String).toList();
  }

  // ---------------------------------------------------------------------------
  // Gate lookup by national ID (returns profile + linked students)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> gateLookupByNationalId(
    String nationalId,
  ) async {
    final profile = await supabase
        .from('profiles')
        .select('*, guardian_user_id:guardians(full_name, guardian_user_id)')
        .eq('national_id', nationalId.trim())
        .maybeSingle();
    return profile;
  }

  // ---------------------------------------------------------------------------
  // Gate lookup by phone
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> gateLookupByPhone(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'\D'), '');
    final profile = await supabase
        .from('profiles')
        .select()
        .ilike('phone', '%$normalized%')
        .maybeSingle();
    return profile;
  }
}
