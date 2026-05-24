import '../models/db_models.dart';
import '../supabase_config.dart';

class RequestService {
  RequestService._();
  static final RequestService instance = RequestService._();

  // ---------------------------------------------------------------------------
  // Fetch requests made by the current parent
  // ---------------------------------------------------------------------------
  Future<List<DbPickupRequest>> fetchByParent({
    required String parentId,
  }) async {
    final rows = await supabase
        .from('pickup_requests')
        .select()
        .eq('requested_by', parentId)
        .order('created_at', ascending: false);
    return rows.map(DbPickupRequest.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Fetch requests for a school (admin view)
  // ---------------------------------------------------------------------------
  Future<List<DbPickupRequest>> fetchBySchool({
    required String schoolId,
    String? statusFilter,
  }) async {
    var query = supabase
        .from('pickup_requests')
        .select('*, students!inner(school_id)')
        .eq('students.school_id', schoolId);

    if (statusFilter != null) {
      query = query.eq('status', statusFilter);
    }

    final rows = await query.order('created_at', ascending: false);
    return rows.map(DbPickupRequest.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Real-time stream: parent's own requests
  // ---------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> streamByParent({
    required String parentId,
  }) =>
      supabase
          .from('pickup_requests')
          .stream(primaryKey: ['id'])
          .eq('requested_by', parentId)
          .order('created_at', ascending: false);

  // ---------------------------------------------------------------------------
  // Real-time stream: all pending requests for a school (admin/gate staff)
  // ---------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> streamPending() =>
      supabase
          .from('pickup_requests')
          .stream(primaryKey: ['id'])
          .eq('status', 'pending')
          .order('created_at', ascending: false);

  // ---------------------------------------------------------------------------
  // Submit new pickup/dropoff request
  // ---------------------------------------------------------------------------
  Future<DbPickupRequest> submit({
    required String studentId,
    required String requestedBy,
    required String type,
    String? timeLabel,
    String? pickupPersonSummary,
    String? notes,
  }) async {
    final row = await supabase
        .from('pickup_requests')
        .insert({
          'student_id':            studentId,
          'requested_by':          requestedBy,
          'type':                  type,
          'status':                'pending',
          'date':                  DateTime.now().toIso8601String().split('T').first,
          if (timeLabel != null)            'time_label':            timeLabel,
          if (pickupPersonSummary != null)  'pickup_person_summary': pickupPersonSummary,
          if (notes != null)                'notes':                 notes,
        })
        .select()
        .single();
    return DbPickupRequest.fromJson(row);
  }

  // ---------------------------------------------------------------------------
  // Approve or reject a request (admin / staff)
  // ---------------------------------------------------------------------------
  Future<void> reviewRequest({
    required String id,
    required String status,    // 'approved' | 'rejected'
    required String reviewedBy,
  }) async {
    await supabase.from('pickup_requests').update({
      'status':      status,
      'reviewed_by': reviewedBy,
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Mark request as released at gate
  // ---------------------------------------------------------------------------
  Future<void> releaseAtGate(String id) async {
    await supabase.from('pickup_requests').update({
      'released_at_gate': true,
      'released_at':      DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Delete a request (parent only, while still pending)
  // ---------------------------------------------------------------------------
  Future<void> delete(String id) async {
    await supabase.from('pickup_requests').delete().eq('id', id);
  }
}
