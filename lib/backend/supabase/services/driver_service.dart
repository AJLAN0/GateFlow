import '../models/db_models.dart';
import '../supabase_config.dart';

class DriverService {
  DriverService._();
  static final DriverService instance = DriverService._();

  // ---------------------------------------------------------------------------
  // Record a boarding or drop-off scan
  // ---------------------------------------------------------------------------
  Future<DbDriverScanLog> recordScan({
    required String driverId,
    required String studentId,
    required String action,   // 'boarded' | 'dropped_off'
    String? busId,
    String? notes,
  }) async {
    final row = await supabase
        .from('driver_scan_logs')
        .insert({
          'driver_id':  driverId,
          'student_id': studentId,
          'action':     action,
          if (busId != null) 'bus_id': busId,
          if (notes != null) 'notes':  notes,
        })
        .select()
        .single();
    return DbDriverScanLog.fromJson(row);
  }

  // ---------------------------------------------------------------------------
  // Fetch scan history for a student on today's trip
  // ---------------------------------------------------------------------------
  Future<List<DbDriverScanLog>> fetchTodayScans({
    required String studentId,
  }) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final rows  = await supabase
        .from('driver_scan_logs')
        .select()
        .eq('student_id', studentId)
        .gte('scanned_at', '${today}T00:00:00')
        .lte('scanned_at', '${today}T23:59:59')
        .order('scanned_at', ascending: false);
    return rows.map(DbDriverScanLog.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Fetch the latest scan action for a student (to determine current phase)
  // ---------------------------------------------------------------------------
  Future<DbDriverScanLog?> fetchLatestScan({
    required String studentId,
  }) async {
    final row = await supabase
        .from('driver_scan_logs')
        .select()
        .eq('student_id', studentId)
        .order('scanned_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    return DbDriverScanLog.fromJson(row);
  }

  // ---------------------------------------------------------------------------
  // Fetch all drivers for a school (admin view)
  // ---------------------------------------------------------------------------
  Future<List<DbProfile>> fetchAllDrivers({required String schoolId}) async {
    final rows = await supabase
        .from('profiles')
        .select()
        .eq('school_id', schoolId)
        .eq('role', 'bus_driver')
        .order('full_name');
    return rows.map(DbProfile.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Log gate verification
  // ---------------------------------------------------------------------------
  Future<void> logGateVerification({
    required String verifiedBy,
    String? personNationalId,
    String? personPhone,
    String? personName,
    List<String> studentNames = const [],
    String result = 'approved',
    String? pickupRequestId,
    String? notes,
  }) async {
    await supabase.from('gate_verification_logs').insert({
      'verified_by':          verifiedBy,
      if (personNationalId != null) 'person_national_id': personNationalId,
      if (personPhone != null)      'person_phone':        personPhone,
      if (personName != null)       'person_name':         personName,
      'student_names':              studentNames,
      'verification_result':        result,
      if (pickupRequestId != null)  'pickup_request_id':   pickupRequestId,
      if (notes != null)            'notes':               notes,
    });
  }
}
