import '../models/db_models.dart';
import '../supabase_config.dart';

class BusService {
  BusService._();
  static final BusService instance = BusService._();

  // ---------------------------------------------------------------------------
  // Fetch all buses for a school
  // ---------------------------------------------------------------------------
  Future<List<DbBus>> fetchAll({required String schoolId}) async {
    final rows = await supabase
        .from('buses')
        .select()
        .eq('school_id', schoolId)
        .order('name');
    return rows.map(DbBus.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Fetch the bus assigned to the current driver
  // ---------------------------------------------------------------------------
  Future<DbBus?> fetchDriverBus({required String driverId}) async {
    final row = await supabase
        .from('buses')
        .select()
        .eq('driver_id', driverId)
        .maybeSingle();
    if (row == null) return null;
    return DbBus.fromJson(row);
  }

  // ---------------------------------------------------------------------------
  // Real-time stream for a school's buses
  // ---------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> streamSchool({required String schoolId}) =>
      supabase
          .from('buses')
          .stream(primaryKey: ['id'])
          .eq('school_id', schoolId)
          .order('name');

  // ---------------------------------------------------------------------------
  // Add bus (admin only)
  // ---------------------------------------------------------------------------
  Future<DbBus> add({
    required String name,
    required String schoolId,
    String? routeLabel,
    String? plateNumber,
    String? driverId,
  }) async {
    final row = await supabase
        .from('buses')
        .insert({
          'name':         name,
          'school_id':    schoolId,
          if (routeLabel != null)   'route_label':  routeLabel,
          if (plateNumber != null)  'plate_number': plateNumber,
          if (driverId != null)     'driver_id':    driverId,
        })
        .select()
        .single();
    return DbBus.fromJson(row);
  }

  // ---------------------------------------------------------------------------
  // Update bus info
  // ---------------------------------------------------------------------------
  Future<void> update({
    required String id,
    String? name,
    String? routeLabel,
    String? plateNumber,
    String? driverId,
  }) async {
    await supabase.from('buses').update({
      if (name != null)        'name':         name,
      if (routeLabel != null)  'route_label':  routeLabel,
      if (plateNumber != null) 'plate_number': plateNumber,
      if (driverId != null)    'driver_id':    driverId,
    }).eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Update bus status (driver or admin)
  // ---------------------------------------------------------------------------
  Future<void> updateStatus({
    required String id,
    required String status,   // 'stationary'|'on_route_to_school'|'on_route_to_home'
    String? label,
  }) async {
    await supabase.from('buses').update({
      'status':            status,
      'last_update_label': label ?? DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Delete bus (admin only)
  // ---------------------------------------------------------------------------
  Future<void> delete(String id) async {
    await supabase.from('buses').delete().eq('id', id);
  }
}
