import '../models/db_models.dart';
import '../supabase_config.dart';

class ScheduleService {
  ScheduleService._();
  static final ScheduleService instance = ScheduleService._();

  // ---------------------------------------------------------------------------
  // Fetch schedules for today's date
  // ---------------------------------------------------------------------------
  Future<List<DbDailySchedule>> fetchToday({required String schoolId}) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final rows  = await supabase
        .from('daily_schedules')
        .select()
        .eq('school_id', schoolId)
        .eq('date', today)
        .order('class_name');
    return rows.map(DbDailySchedule.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Fetch schedules for a specific date
  // ---------------------------------------------------------------------------
  Future<List<DbDailySchedule>> fetchByDate({
    required String schoolId,
    required DateTime date,
  }) async {
    final dateStr = date.toIso8601String().split('T').first;
    final rows    = await supabase
        .from('daily_schedules')
        .select()
        .eq('school_id', schoolId)
        .eq('date', dateStr)
        .order('class_name');
    return rows.map(DbDailySchedule.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Real-time stream for today's schedules
  // ---------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> streamToday({required String schoolId}) {
    final today = DateTime.now().toIso8601String().split('T').first;
    return supabase
        .from('daily_schedules')
        .stream(primaryKey: ['id'])
        .eq('school_id', schoolId)
        .order('class_name');
  }

  // ---------------------------------------------------------------------------
  // Create a schedule entry (admin only)
  // ---------------------------------------------------------------------------
  Future<DbDailySchedule> create({
    required String schoolId,
    required String className,
    required String grade,
    required DateTime date,
    String? arrivalTime,
    String? departureTime,
    String? notes,
    String? createdBy,
  }) async {
    final row = await supabase
        .from('daily_schedules')
        .insert({
          'school_id':      schoolId,
          'class_name':     className,
          'grade':          grade,
          'date':           date.toIso8601String().split('T').first,
          if (arrivalTime != null)    'arrival_time':   arrivalTime,
          if (departureTime != null)  'departure_time': departureTime,
          if (notes != null)          'notes':          notes,
          if (createdBy != null)      'created_by':     createdBy,
        })
        .select()
        .single();
    return DbDailySchedule.fromJson(row);
  }

  // ---------------------------------------------------------------------------
  // Update a schedule entry
  // ---------------------------------------------------------------------------
  Future<void> update({
    required String id,
    String? className,
    String? grade,
    DateTime? date,
    String? arrivalTime,
    String? departureTime,
    String? notes,
  }) async {
    await supabase.from('daily_schedules').update({
      if (className != null)      'class_name':     className,
      if (grade != null)          'grade':          grade,
      if (date != null)           'date':           date.toIso8601String().split('T').first,
      if (arrivalTime != null)    'arrival_time':   arrivalTime,
      if (departureTime != null)  'departure_time': departureTime,
      if (notes != null)          'notes':          notes,
    }).eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Delete a schedule entry
  // ---------------------------------------------------------------------------
  Future<void> delete(String id) async {
    await supabase.from('daily_schedules').delete().eq('id', id);
  }
}
