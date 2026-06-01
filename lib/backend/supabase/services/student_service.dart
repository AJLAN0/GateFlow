import '../models/db_models.dart';
import '../supabase_config.dart';

class StudentService {
  StudentService._();
  static final StudentService instance = StudentService._();

  // ---------------------------------------------------------------------------
  // Fetch all students in a school
  // ---------------------------------------------------------------------------
  Future<List<DbStudent>> fetchAll({required String schoolId}) async {
    final rows = await supabase
        .from('students')
        .select()
        .eq('school_id', schoolId)
        .order('name');
    return rows.map(DbStudent.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Fetch students assigned to a parent
  // ---------------------------------------------------------------------------
  Future<List<DbStudent>> fetchForParent({required String parentId}) async {
    final links = await supabase
        .from('parent_students')
        .select('student_id')
        .eq('parent_id', parentId);

    final ids = links.map((e) => e['student_id'] as String).toList();
    if (ids.isEmpty) return [];

    final rows = await supabase
        .from('students')
        .select()
        .inFilter('id', ids)
        .order('name');
    return rows.map(DbStudent.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Fetch students on a specific bus
  // ---------------------------------------------------------------------------
  Future<List<DbStudent>> fetchForBus({required String busId}) async {
    final rows = await supabase
        .from('students')
        .select()
        .eq('bus_id', busId)
        .order('name');
    return rows.map(DbStudent.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Real-time stream for school students (admin / driver view)
  // ---------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> streamSchool({required String schoolId}) =>
      supabase
          .from('students')
          .stream(primaryKey: ['id'])
          .eq('school_id', schoolId)
          .order('name');

  // ---------------------------------------------------------------------------
  // Real-time stream for a parent's students (uses parent_students join)
  // Note: Supabase realtime stream doesn't support joins; poll or subscribe
  // to parent_students channel instead.
  // ---------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> streamParentStudents({
    required String parentId,
  }) =>
      supabase
          .from('parent_students')
          .stream(primaryKey: ['id'])
          .eq('parent_id', parentId);

  // ---------------------------------------------------------------------------
  // Add student (admin only)
  // ---------------------------------------------------------------------------
  Future<DbStudent> add({
    required String name,
    required String grade,
    required String schoolId,
    String transportType = 'car',
    String? busId,
    String? pickupLocationLabel,
    double? latitude,
    double? longitude,
  }) async {
    final row = await supabase
        .from('students')
        .insert({
          'name':           name,
          'grade':          grade,
          'school_id':      schoolId,
          'transport_type': transportType,
          if (busId != null) 'bus_id': busId,
          if (pickupLocationLabel != null)
            'pickup_location_label': pickupLocationLabel,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        })
        .select()
        .single();
    return DbStudent.fromJson(row);
  }

  // ---------------------------------------------------------------------------
  // Update student basic info
  // ---------------------------------------------------------------------------
  Future<void> update({
    required String id,
    String? name,
    String? grade,
    String? transportType,
    String? busId,
  }) async {
    await supabase.from('students').update({
      if (name != null)          'name':           name,
      if (grade != null)         'grade':          grade,
      if (transportType != null) 'transport_type': transportType,
      if (busId != null)         'bus_id':         busId,
    }).eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Update student status (driver scan / admin)
  // ---------------------------------------------------------------------------
  Future<void> updateStatus({
    required String id,
    required String status,
    String? label,
  }) async {
    await supabase.from('students').update({
      'status':            status,
      'last_update_label': label ??
          '${DateTime.now().hour.toString().padLeft(2, '0')}:'
              '${DateTime.now().minute.toString().padLeft(2, '0')}',
    }).eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Delete student (admin only)
  // ---------------------------------------------------------------------------
  Future<void> delete(String id) async {
    await supabase.from('students').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Link student to parent
  // ---------------------------------------------------------------------------
  Future<void> linkToParent({
    required String studentId,
    required String parentId,
  }) async {
    await supabase.from('parent_students').upsert({
      'parent_id':  parentId,
      'student_id': studentId,
    });
  }

  // ---------------------------------------------------------------------------
  // Unlink student from parent
  // ---------------------------------------------------------------------------
  Future<void> unlinkFromParent({
    required String studentId,
    required String parentId,
  }) async {
    await supabase
        .from('parent_students')
        .delete()
        .eq('parent_id', parentId)
        .eq('student_id', studentId);
  }
}
