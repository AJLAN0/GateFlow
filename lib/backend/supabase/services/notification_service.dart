import '../models/db_models.dart';
import '../supabase_config.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // ---------------------------------------------------------------------------
  // Fetch notifications for current user
  // ---------------------------------------------------------------------------
  Future<List<DbNotification>> fetchForUser({
    required String userId,
    int limit = 50,
  }) async {
    final rows = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map(DbNotification.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // Unread count
  // ---------------------------------------------------------------------------
  Future<int> unreadCount({required String userId}) async {
    final response = await supabase
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);
    return response.length;
  }

  // ---------------------------------------------------------------------------
  // Real-time stream for user's notifications
  // ---------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> streamForUser({
    required String userId,
  }) =>
      supabase
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at', ascending: false);

  // ---------------------------------------------------------------------------
  // Mark a single notification as read
  // ---------------------------------------------------------------------------
  Future<void> markRead(String id) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Mark all as read for a user
  // ---------------------------------------------------------------------------
  Future<void> markAllRead({required String userId}) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  // ---------------------------------------------------------------------------
  // Create a notification for a single user (internal use)
  // ---------------------------------------------------------------------------
  Future<void> send({
    required String userId,
    required String title,
    required String body,
    String type = 'info',
    String? referenceId,
    String? referenceType,
  }) async {
    await supabase.from('notifications').insert({
      'user_id': userId,
      'title':   title,
      'body':    body,
      'type':    type,
      if (referenceId != null)   'reference_id':   referenceId,
      if (referenceType != null) 'reference_type': referenceType,
    });
  }

  // ---------------------------------------------------------------------------
  // Broadcast to all users of given roles in a school
  // (calls Supabase DB function broadcast_school_notification)
  // ---------------------------------------------------------------------------
  Future<void> broadcastToSchool({
    required String schoolId,
    required String title,
    required String body,
    String type = 'info',
    List<String> roles = const [
      'parent',
      'guardian',
      'bus_driver',
      'school_staff',
    ],
  }) async {
    await supabase.rpc('broadcast_school_notification', params: {
      'p_school_id': schoolId,
      'p_title':     title,
      'p_body':      body,
      'p_type':      type,
      'p_roles':     roles,
    });
  }
}
