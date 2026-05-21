import '../models/db_models.dart';
import '../supabase_config.dart';

class OperationalAlertService {
  OperationalAlertService._();
  static final OperationalAlertService instance = OperationalAlertService._();

  // ---------------------------------------------------------------------------
  // Fetch active (unresolved) alerts for a school
  // ---------------------------------------------------------------------------
  Future<List<DbOperationalAlert>> fetchActive({
    required String schoolId,
  }) async {
    final rows = await supabase
        .from('operational_alerts')
        .select()
        .eq('school_id', schoolId)
        .eq('is_resolved', false)
        .order('created_at', ascending: false);
    return rows.map(DbOperationalAlert.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Real-time stream for a school's active alerts
  // ---------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> streamActive({
    required String schoolId,
  }) =>
      supabase
          .from('operational_alerts')
          .stream(primaryKey: ['id'])
          .eq('school_id', schoolId)
          .order('created_at', ascending: false);

  // ---------------------------------------------------------------------------
  // Create an alert (admin / system)
  // ---------------------------------------------------------------------------
  Future<DbOperationalAlert> create({
    required String schoolId,
    required String title,
    required String body,
    String severity = 'info',
    String? createdBy,
  }) async {
    final row = await supabase
        .from('operational_alerts')
        .insert({
          'school_id':  schoolId,
          'title':      title,
          'body':       body,
          'severity':   severity,
          if (createdBy != null) 'created_by': createdBy,
        })
        .select()
        .single();
    return DbOperationalAlert.fromJson(row);
  }

  // ---------------------------------------------------------------------------
  // Resolve (dismiss) an alert
  // ---------------------------------------------------------------------------
  Future<void> resolve(String id) async {
    await supabase
        .from('operational_alerts')
        .update({'is_resolved': true})
        .eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Delete an alert permanently
  // ---------------------------------------------------------------------------
  Future<void> delete(String id) async {
    await supabase.from('operational_alerts').delete().eq('id', id);
  }
}
