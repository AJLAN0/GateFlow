import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../backend/supabase/supabase_config.dart';
import '../backend/supabase/models/db_models.dart';
import '../backend/supabase/services/auth_service.dart';
import '../backend/supabase/services/student_service.dart';
import '../backend/supabase/services/bus_service.dart';
import '../backend/supabase/services/request_service.dart';
import '../backend/supabase/services/guardian_service.dart';
import '../backend/supabase/services/operational_alert_service.dart';
import '../backend/supabase/services/driver_service.dart';
import '../backend/supabase/services/notification_service.dart';

// =============================================================================
// Enums (UI-layer, unchanged)
// =============================================================================
enum StudentStatus { atHome, onBusToSchool, atSchool, onBusToHome, pickedUpByCar }
enum RequestStatus { pending, approved, rejected }
enum BusStatus     { stationary, onRouteToSchool, onRouteToHome }
enum UserRole      { parent, schoolStaff, busDriver, guardian, none }
enum DemoChildTransport { bus, car }

// =============================================================================
// UI-layer model classes (same interface as before)
// =============================================================================

class DemoParentChild {
  DemoParentChild({
    required this.id,
    required this.name,
    required this.grade,
    required this.transport,
    this.busId,
    this.absentToday = false,
  });
  final String id;
  final String name;
  final String grade;
  final DemoChildTransport transport;
  final String? busId;
  bool absentToday;
}

class SchoolTimeRequestEntry {
  SchoolTimeRequestEntry({
    required this.id,
    required this.childName,
    required this.grade,
    required this.reason,
    required this.timeLabel,
    required this.requestedBy,
    required this.isEarly,
    required this.status,
  });
  final String id;
  final String childName;
  final String grade;
  final String reason;
  final String timeLabel;
  final String requestedBy;
  final bool isEarly;
  RequestStatus status;
}

class GuardianDemoProfile {
  const GuardianDemoProfile({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.relationship,
    required this.authorizationNote,
    required this.assignedChildNames,
    this.notificationsEnabled = true,
  });
  final String fullName;
  final String phone;
  final String email;
  final String relationship;
  final String authorizationNote;
  final List<String> assignedChildNames;
  final bool notificationsEnabled;
}

class OperationalAlert {
  OperationalAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
}

class PendingGuardianInvite {
  PendingGuardianInvite({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.relationship,
    required this.forChildrenSummary,
    this.status = GuardianInviteStatus.pending,
  });
  final String id;
  final String fullName;
  final String phone;
  final String relationship;
  final String forChildrenSummary;
  GuardianInviteStatus status;
}

enum GuardianInviteStatus { pending, approvedBySchool }
enum GuardianPickupIntent { none, pick, drop }
enum GatePickupPersonKind { parent, guardian }

class GatePickupPersonProfile {
  const GatePickupPersonProfile({
    required this.nationalId,
    required this.phoneDigits,
    required this.displayPhone,
    required this.fullName,
    required this.kind,
    required this.linkedChildren,
    required this.authorizationLabel,
    required this.allowedActionLabel,
  });
  final String nationalId;
  final String phoneDigits;
  final String displayPhone;
  final String fullName;
  final GatePickupPersonKind kind;
  final List<String> linkedChildren;
  final String authorizationLabel;
  final String allowedActionLabel;
}

class Student {
  Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.status,
    this.busId,
    this.lastMockUpdateLabel = '',
  });
  final String id;
  final String name;
  final String grade;
  StudentStatus status;
  final String? busId;
  String lastMockUpdateLabel;
}

class Bus {
  Bus({
    required this.id,
    required this.name,
    required this.routeLabel,
    required this.driverName,
    required this.driverId,
    required this.status,
    this.lastUpdateLabel,
  });
  final String id;
  final String name;
  final String routeLabel;
  final String driverName;
  final String driverId;
  BusStatus status;
  String? lastUpdateLabel;
}

class ParentRequest {
  ParentRequest({
    required this.id,
    required this.studentId,
    required this.type,
    required this.status,
    required this.date,
    this.pickupPersonSummary,
    this.timeLabel,
  });
  final String id;
  final String studentId;
  final String type;
  RequestStatus status;
  final DateTime date;
  final String? pickupPersonSummary;
  final String? timeLabel;
}

enum DriverScanPhase { idle, boarded, droppedOff }

class DriverScanOutcome {
  const DriverScanOutcome({
    required this.phaseAfter,
    required this.studentName,
    required this.title,
    required this.detail,
    required this.warning,
    this.showStaffAlert = false,
  });
  final DriverScanPhase phaseAfter;
  final String studentName;
  final String title;
  final String detail;
  final bool warning;
  final bool showStaffAlert;
}

// =============================================================================
// MockState — Supabase-backed ChangeNotifier
//
// Public API is identical to the original mock so all 60 pages compile
// without changes. Internally, data is loaded from / written to Supabase
// when configured, and falls back to the demo dataset when Supabase is not
// yet set up (i.e. kSupabaseUrl is still the placeholder).
// =============================================================================
class MockState extends ChangeNotifier {

  // ── Auth ──────────────────────────────────────────────────────────────────
  User? supabaseUser;
  DbProfile? currentProfile;
  bool isLoading = false;
  String? authError;

  UserRole _role = UserRole.none;
  UserRole get currentUserRole => _role;

  // ── Realtime subscriptions ────────────────────────────────────────────────
  StreamSubscription<AuthState>? _authSub;
  StreamSubscription<List<Map<String, dynamic>>>? _studentsSub;
  StreamSubscription<List<Map<String, dynamic>>>? _busesSub;
  StreamSubscription<List<Map<String, dynamic>>>? _requestsSub;
  StreamSubscription<List<Map<String, dynamic>>>? _alertsSub;

  // ── Data ──────────────────────────────────────────────────────────────────
  List<Student>              students            = [];
  List<Bus>                  buses               = [];
  List<ParentRequest>        requests            = [];
  List<SchoolTimeRequestEntry> schoolTimeRequests = [];
  List<OperationalAlert>     operationalAlerts   = [];
  List<DemoParentChild>      parentDemoChildren  = [];

  GuardianDemoProfile guardianProfile = const GuardianDemoProfile(
    fullName:           'Mohammed Ali',
    phone:              '+966 50 000 4411',
    email:              'm.ali.demo@gateflow.app',
    relationship:       'Uncle · Authorized guardian',
    authorizationNote:  'Active · Verified by school',
    assignedChildNames: ['Saad Khaled', 'Sara Khaled'],
  );

  PendingGuardianInvite? latestGuardianSubmission;
  bool guardianNotifyEnabled = true;

  final Set<String> releasedPickupRequestIds = {};
  final Map<String, DriverScanPhase>   _driverScanPhase          = {};
  final Map<String, GuardianPickupIntent> guardianPickupIntentByChildId = {};

  // Demo gate directory — used when Supabase is not configured
  List<GatePickupPersonProfile> gatePickupDirectory = [
    const GatePickupPersonProfile(
      nationalId:       '1234567890',
      phoneDigits:      '966501112233',
      displayPhone:     '+966 50 111 2233',
      fullName:         'Khalid Al-Otaibi',
      kind:             GatePickupPersonKind.parent,
      linkedChildren:   ['Noah Khaled', 'Lama Khaled'],
      authorizationLabel:  'Verified parent · Active',
      allowedActionLabel:  'Pickup & drop-off',
    ),
    const GatePickupPersonProfile(
      nationalId:       '9876543210',
      phoneDigits:      '96650004411',
      displayPhone:     '+966 50 000 4411',
      fullName:         'Mohammed Ali',
      kind:             GatePickupPersonKind.guardian,
      linkedChildren:   ['Saad Khaled', 'Sara Khaled'],
      authorizationLabel:  'Verified guardian · School approved',
      allowedActionLabel:  'Pickup only',
    ),
    const GatePickupPersonProfile(
      nationalId:       '5555555555',
      phoneDigits:      '966551234567',
      displayPhone:     '+966 55 123 4567',
      fullName:         'Fatima Hassan',
      kind:             GatePickupPersonKind.parent,
      linkedChildren:   ['Khalid Jr.'],
      authorizationLabel:  'Verified parent',
      allowedActionLabel:  'Pickup & drop-off',
    ),
  ];

  // ── Constructor ───────────────────────────────────────────────────────────
  MockState() {
    _loadDemoData();
    if (isSupabaseConfigured) {
      _initSupabase();
    }
  }

  // ── Supabase initialization ───────────────────────────────────────────────
  void _initSupabase() {
    _authSub = supabase.auth.onAuthStateChange.listen((event) {
      supabaseUser = event.session?.user;
      if (supabaseUser != null) {
        _onUserSignedIn();
      } else {
        _loadDemoData();
        _role = UserRole.none;
      }
      notifyListeners();
    });

    // Restore session if the app was re-opened
    final existing = supabase.auth.currentSession;
    if (existing != null) {
      supabaseUser = existing.user;
      _onUserSignedIn();
    }
  }

  Future<void> _onUserSignedIn() async {
    isLoading = true;
    notifyListeners();

    try {
      currentProfile = await AuthService.instance.fetchProfile();
      if (currentProfile == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      _role = _roleFromString(currentProfile!.role);
      await _loadRealData();
      _setupRealtimeSubscriptions();
    } catch (e) {
      debugPrint('GateFlow: error loading user data: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadRealData() async {
    final profile = currentProfile;
    if (profile == null) return;
    final schoolId = profile.schoolId;

    // Load students
    if (schoolId != null) {
      switch (_role) {
        case UserRole.schoolStaff:
        case UserRole.busDriver:
          final dbStudents = await StudentService.instance
              .fetchAll(schoolId: schoolId);
          students = dbStudents.map(_mapStudent).toList();
          break;
        case UserRole.parent:
          final dbStudents = await StudentService.instance
              .fetchForParent(parentId: profile.id);
          students  = dbStudents.map(_mapStudent).toList();
          parentDemoChildren = dbStudents.map(_mapDemoChild).toList();
          break;
        case UserRole.guardian:
          students = [];
          break;
        case UserRole.none:
          break;
      }
    }

    // Load buses
    if (schoolId != null &&
        (_role == UserRole.schoolStaff ||
            _role == UserRole.busDriver ||
            _role == UserRole.parent)) {
      final dbBuses = await BusService.instance.fetchAll(schoolId: schoolId);
      buses = dbBuses.map(_mapBus).toList();
    }

    // Load requests
    if (_role == UserRole.parent) {
      final dbRequests =
          await RequestService.instance.fetchByParent(parentId: profile.id);
      requests = dbRequests.map(_mapRequest).toList();
    }
    if (_role == UserRole.schoolStaff && schoolId != null) {
      final dbRequests =
          await RequestService.instance.fetchBySchool(schoolId: schoolId);
      requests = dbRequests.map(_mapRequest).toList();
      schoolTimeRequests = dbRequests
          .where((r) =>
              r.type == 'Early Pickup' || r.type == 'Late Drop-off')
          .map(_mapTimeRequest)
          .toList();
    }

    // Load operational alerts
    if (schoolId != null &&
        (_role == UserRole.schoolStaff || _role == UserRole.busDriver)) {
      final dbAlerts = await OperationalAlertService.instance
          .fetchActive(schoolId: schoolId);
      operationalAlerts = dbAlerts
          .map((a) => OperationalAlert(
                id:        a.id,
                title:     a.title,
                body:      a.body,
                createdAt: a.createdAt,
              ))
          .toList();
    }
  }

  void _setupRealtimeSubscriptions() {
    final profile  = currentProfile;
    final schoolId = profile?.schoolId;
    if (schoolId == null) return;

    // Students
    _studentsSub?.cancel();
    _studentsSub = StudentService.instance
        .streamSchool(schoolId: schoolId)
        .listen((rows) {
      students = rows.map((r) => _mapStudent(DbStudent.fromJson(r))).toList();
      notifyListeners();
    });

    // Buses
    _busesSub?.cancel();
    _busesSub = BusService.instance
        .streamSchool(schoolId: schoolId)
        .listen((rows) {
      buses = rows.map((r) => _mapBus(DbBus.fromJson(r))).toList();
      notifyListeners();
    });

    // Requests (all roles see relevant updates)
    if (profile != null) {
      _requestsSub?.cancel();
      _requestsSub = RequestService.instance
          .streamByParent(parentId: profile.id)
          .listen((rows) {
        requests =
            rows.map((r) => _mapRequest(DbPickupRequest.fromJson(r))).toList();
        notifyListeners();
      });
    }

    // Operational alerts
    _alertsSub?.cancel();
    _alertsSub = OperationalAlertService.instance
        .streamActive(schoolId: schoolId)
        .listen((rows) {
      operationalAlerts = rows
          .map((r) => DbOperationalAlert.fromJson(r))
          .map((a) => OperationalAlert(
                id:        a.id,
                title:     a.title,
                body:      a.body,
                createdAt: a.createdAt,
              ))
          .toList();
      notifyListeners();
    });
  }

  // ── Demo data fallback ────────────────────────────────────────────────────
  void _loadDemoData() {
    students = [
      Student(id: 's1', name: 'Khalid Jr.',  grade: 'Grade 3', status: StudentStatus.atSchool,      busId: 'b1', lastMockUpdateLabel: '7:45 AM · Arrived school'),
      Student(id: 's2', name: 'Aisha',        grade: 'Grade 1', status: StudentStatus.atHome,         lastMockUpdateLabel: 'Yesterday · Picked up by car'),
      Student(id: 's3', name: 'Noah Khaled',  grade: 'Grade 1', status: StudentStatus.onBusToSchool, busId: 'b1', lastMockUpdateLabel: '7:50 AM · Boarded'),
      Student(id: 's4', name: 'Lama Khaled',  grade: 'Grade 1', status: StudentStatus.atSchool,      busId: 'b1', lastMockUpdateLabel: '7:40 AM · Arrived school'),
    ];
    buses = [
      Bus(id: 'b1', name: 'Bus 12A', routeLabel: 'North Route · Zones A–D',
          driverName: 'Hassan (You)', driverId: 'd1',
          status: BusStatus.onRouteToHome, lastUpdateLabel: '2 min ago · GPS'),
    ];
    parentDemoChildren = [
      DemoParentChild(id: 'pc1', name: 'Saad Khaled', grade: 'Grade 6', transport: DemoChildTransport.car),
      DemoParentChild(id: 'pc2', name: 'Sara Khaled', grade: 'Grade 6', transport: DemoChildTransport.car),
      DemoParentChild(id: 'pc3', name: 'Noah Khaled', grade: 'Grade 1', transport: DemoChildTransport.bus, busId: 'b1'),
      DemoParentChild(id: 'pc4', name: 'Lama Khaled', grade: 'Grade 1', transport: DemoChildTransport.bus, busId: 'b1'),
    ];
    requests = [
      ParentRequest(id: 'r1', studentId: 'pc3', type: 'Early Pickup',  status: RequestStatus.pending,   date: DateTime.now(),                              pickupPersonSummary: 'Parent · Khalid', timeLabel: '3:30 PM'),
      ParentRequest(id: 'r0', studentId: 'pc2', type: 'Late Drop-off', status: RequestStatus.approved,  date: DateTime.now().subtract(const Duration(days: 1)), pickupPersonSummary: 'Guardian · Deem', timeLabel: '4:00 PM'),
    ];
    schoolTimeRequests = [
      SchoolTimeRequestEntry(id: 'tr_e1', childName: 'Saad Ahmed',   grade: 'Grade 4', reason: 'Doctor appointment', timeLabel: '12:30 PM', requestedBy: 'Parent · Ahmed',   isEarly: true,  status: RequestStatus.pending),
      SchoolTimeRequestEntry(id: 'tr_e2', childName: 'Sara Khaled',  grade: 'Grade 6', reason: 'Family event',       timeLabel: '1:00 PM',  requestedBy: 'Guardian · Deem', isEarly: true,  status: RequestStatus.pending),
      SchoolTimeRequestEntry(id: 'tr_l1', childName: 'Noah Khaled',  grade: 'Grade 1', reason: 'Traffic delay',      timeLabel: '8:30 AM',  requestedBy: 'Parent · Khalid', isEarly: false, status: RequestStatus.pending),
      SchoolTimeRequestEntry(id: 'tr_l2', childName: 'Yousef Ali',   grade: 'Grade 5', reason: 'Doctor appointment', timeLabel: '9:15 AM',  requestedBy: 'Parent · Ali',    isEarly: false, status: RequestStatus.approved),
    ];
    operationalAlerts = [
      OperationalAlert(id: 'a1', title: 'Bus 12A departure delayed',   body: 'North route running ~8 min behind. Gate team notified.', createdAt: DateTime.now()),
      OperationalAlert(id: 'a2', title: 'Early pickup spike',           body: '3 early dismissals clustered at 12:30 PM — monitor gate queue.', createdAt: DateTime.now()),
    ];
  }

  // ── DB → UI-model converters ──────────────────────────────────────────────
  static StudentStatus _studentStatusFromDb(String s) {
    switch (s) {
      case 'on_bus_to_school': return StudentStatus.onBusToSchool;
      case 'at_school':        return StudentStatus.atSchool;
      case 'on_bus_to_home':   return StudentStatus.onBusToHome;
      case 'picked_up_by_car': return StudentStatus.pickedUpByCar;
      default:                 return StudentStatus.atHome;
    }
  }

  static String _studentStatusToDb(StudentStatus s) {
    switch (s) {
      case StudentStatus.onBusToSchool: return 'on_bus_to_school';
      case StudentStatus.atSchool:      return 'at_school';
      case StudentStatus.onBusToHome:   return 'on_bus_to_home';
      case StudentStatus.pickedUpByCar: return 'picked_up_by_car';
      default:                          return 'at_home';
    }
  }

  static BusStatus _busStatusFromDb(String s) {
    switch (s) {
      case 'on_route_to_school': return BusStatus.onRouteToSchool;
      case 'on_route_to_home':   return BusStatus.onRouteToHome;
      default:                   return BusStatus.stationary;
    }
  }

  static String _busStatusToDb(BusStatus s) {
    switch (s) {
      case BusStatus.onRouteToSchool: return 'on_route_to_school';
      case BusStatus.onRouteToHome:   return 'on_route_to_home';
      default:                        return 'stationary';
    }
  }

  static RequestStatus _requestStatusFromDb(String s) {
    switch (s) {
      case 'approved': return RequestStatus.approved;
      case 'rejected': return RequestStatus.rejected;
      default:         return RequestStatus.pending;
    }
  }

  static UserRole _roleFromString(String r) {
    switch (r) {
      case 'school_staff': return UserRole.schoolStaff;
      case 'bus_driver':   return UserRole.busDriver;
      case 'guardian':     return UserRole.guardian;
      default:             return UserRole.parent;
    }
  }

  static Student _mapStudent(DbStudent db) => Student(
        id:                   db.id,
        name:                 db.name,
        grade:                db.grade,
        status:               _studentStatusFromDb(db.status),
        busId:                db.busId,
        lastMockUpdateLabel:  db.lastUpdateLabel ?? '',
      );

  static DemoParentChild _mapDemoChild(DbStudent db) => DemoParentChild(
        id:        db.id,
        name:      db.name,
        grade:     db.grade,
        transport: db.transportType == 'bus'
            ? DemoChildTransport.bus
            : DemoChildTransport.car,
        busId: db.busId,
      );

  static Bus _mapBus(DbBus db) => Bus(
        id:             db.id,
        name:           db.name,
        routeLabel:     db.routeLabel ?? '',
        driverName:     'Driver',
        driverId:       db.driverId ?? '',
        status:         _busStatusFromDb(db.status),
        lastUpdateLabel: db.lastUpdateLabel,
      );

  static ParentRequest _mapRequest(DbPickupRequest db) => ParentRequest(
        id:                   db.id,
        studentId:            db.studentId,
        type:                 db.type,
        status:               _requestStatusFromDb(db.status),
        date:                 db.createdAt,
        pickupPersonSummary:  db.pickupPersonSummary,
        timeLabel:            db.timeLabel,
      );

  static SchoolTimeRequestEntry _mapTimeRequest(DbPickupRequest db) =>
      SchoolTimeRequestEntry(
        id:          db.id,
        childName:   db.studentId,
        grade:       '',
        reason:      db.notes ?? '',
        timeLabel:   db.timeLabel ?? '',
        requestedBy: db.requestedBy,
        isEarly:     db.type == 'Early Pickup',
        status:      _requestStatusFromDb(db.status),
      );

  // ── Auth actions ──────────────────────────────────────────────────────────

  Future<String?> signInWithEmailPassword(String email, String password) async {
    if (!isSupabaseConfigured) {
      loginAs(_inferRoleFromEmail(email));
      return null;
    }
    try {
      authError = null;
      await AuthService.instance.signIn(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      authError = e.message;
      notifyListeners();
      return e.message;
    } catch (e) {
      authError = e.toString();
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _authSub?.cancel();
    await _studentsSub?.cancel();
    await _busesSub?.cancel();
    await _requestsSub?.cancel();
    await _alertsSub?.cancel();

    if (isSupabaseConfigured) {
      await AuthService.instance.signOut();
    }

    supabaseUser    = null;
    currentProfile  = null;
    _role           = UserRole.none;
    _loadDemoData();
    notifyListeners();
  }

  // Keep the original demo-mode login for the quick-access chips
  void loginAs(UserRole role) {
    _role = role;
    notifyListeners();
  }

  UserRole _inferRoleFromEmail(String email) {
    if (email.contains('school') || email.contains('admin'))  return UserRole.schoolStaff;
    if (email.contains('bus')   || email.contains('driver'))  return UserRole.busDriver;
    if (email.contains('guardian'))                           return UserRole.guardian;
    return UserRole.parent;
  }

  // ── Student mutations ─────────────────────────────────────────────────────

  void updateStudentStatus(String id, StudentStatus newStatus) {
    final student = students.firstWhere((s) => s.id == id);
    student.status = newStatus;
    notifyListeners();

    if (isSupabaseConfigured) {
      StudentService.instance.updateStatus(
        id:     id,
        status: _studentStatusToDb(newStatus),
      );
    }
  }

  void toggleChildAbsent(String childId, bool absent) {
    final c = parentDemoChildren.firstWhere((e) => e.id == childId);
    c.absentToday = absent;
    notifyListeners();
  }

  // ── Bus mutations ─────────────────────────────────────────────────────────

  void updateBusStatus(String id, BusStatus newStatus) {
    final bus = buses.firstWhere((b) => b.id == id);
    bus.status = newStatus;
    notifyListeners();

    if (isSupabaseConfigured) {
      BusService.instance.updateStatus(
        id:     id,
        status: _busStatusToDb(newStatus),
      );
    }
  }

  // ── Request mutations ─────────────────────────────────────────────────────

  ParentRequest submitNewParentRequest({
    required String studentId,
    required String type,
    required String timeLabel,
    required String pickupPersonSummary,
  }) {
    final id  = 'r${DateTime.now().millisecondsSinceEpoch}';
    final req = ParentRequest(
      id:                  id,
      studentId:           studentId,
      type:                type,
      status:              RequestStatus.pending,
      date:                DateTime.now(),
      pickupPersonSummary: pickupPersonSummary,
      timeLabel:           timeLabel,
    );
    requests = [...requests, req];
    notifyListeners();

    if (isSupabaseConfigured && currentProfile != null) {
      RequestService.instance.submit(
        studentId:           studentId,
        requestedBy:         currentProfile!.id,
        type:                type,
        timeLabel:           timeLabel,
        pickupPersonSummary: pickupPersonSummary,
      );
    }

    return req;
  }

  void updateRequestStatus(String id, RequestStatus newStatus) {
    final req = requests.firstWhere((r) => r.id == id);
    req.status = newStatus;
    notifyListeners();

    if (isSupabaseConfigured && currentProfile != null) {
      RequestService.instance.reviewRequest(
        id:         id,
        status:     newStatus == RequestStatus.approved ? 'approved' : 'rejected',
        reviewedBy: currentProfile!.id,
      );
    }
  }

  void updateSchoolTimeRequest(String id, RequestStatus status) {
    final entry = schoolTimeRequests.firstWhere((x) => x.id == id);
    entry.status = status;
    notifyListeners();

    if (isSupabaseConfigured && currentProfile != null) {
      RequestService.instance.reviewRequest(
        id:         id,
        status:     status == RequestStatus.approved ? 'approved' : 'rejected',
        reviewedBy: currentProfile!.id,
      );
    }
  }

  bool releaseStudentAfterVerification(String requestId) {
    try {
      final r = requests.firstWhere((e) => e.id == requestId);
      if (r.status != RequestStatus.approved) return false;
      releasedPickupRequestIds.add(requestId);
      notifyListeners();

      if (isSupabaseConfigured) {
        RequestService.instance.releaseAtGate(requestId);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  List<ParentRequest> approvedParentRequestsAwaitingPickup() => requests
      .where((r) =>
          r.status == RequestStatus.approved &&
          !releasedPickupRequestIds.contains(r.id))
      .toList();

  // ── Guardian mutations ────────────────────────────────────────────────────

  void submitPendingGuardianInvite(PendingGuardianInvite invite) {
    latestGuardianSubmission = invite;
    notifyListeners();

    if (isSupabaseConfigured && currentProfile != null) {
      GuardianService.instance.submit(
        parentId:     currentProfile!.id,
        fullName:     invite.fullName,
        relationship: invite.relationship,
        phone:        invite.phone,
      );
    }
  }

  void setGuardianNotifyEnabled(bool value) {
    guardianNotifyEnabled = value;
    notifyListeners();
  }

  // ── Operational alerts ────────────────────────────────────────────────────

  Future<void> addOperationalAlert({
    required String title,
    required String body,
  }) async {
    final alert = OperationalAlert(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      title:     title,
      body:      body,
      createdAt: DateTime.now(),
    );
    operationalAlerts.insert(0, alert);
    notifyListeners();

    if (isSupabaseConfigured && currentProfile?.schoolId != null) {
      await OperationalAlertService.instance.create(
        schoolId: currentProfile!.schoolId!,
        title:    title,
        body:     body,
      );
    }
  }

  // ── Driver scan logic ─────────────────────────────────────────────────────

  DriverScanOutcome recordDriverBoardingScan(String studentId) {
    final student = students.firstWhere((s) => s.id == studentId);
    final prev    = _driverScanPhase[studentId] ?? DriverScanPhase.idle;
    DriverScanPhase next = prev;

    switch (prev) {
      case DriverScanPhase.idle:
        next           = DriverScanPhase.boarded;
        student.status = StudentStatus.onBusToHome;
        break;
      case DriverScanPhase.boarded:
        next           = DriverScanPhase.droppedOff;
        student.status = StudentStatus.atHome;
        break;
      case DriverScanPhase.droppedOff:
        operationalAlerts.insert(
          0,
          OperationalAlert(
            id:        'scan_${studentId}_${DateTime.now().millisecondsSinceEpoch}',
            title:     'Driver scan alert',
            body:      '${student.name} scanned again after drop-off · School notified',
            createdAt: DateTime.now(),
          ),
        );
        break;
    }

    _driverScanPhase[studentId] = next;
    final nowLabel =
        '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    student.lastMockUpdateLabel = '$nowLabel · Scan';
    notifyListeners();

    if (isSupabaseConfigured && currentProfile != null) {
      final action = prev == DriverScanPhase.idle ? 'boarded' : 'dropped_off';
      final busId  = buses.isNotEmpty ? buses.first.id : null;
      DriverService.instance.recordScan(
        driverId:  currentProfile!.id,
        studentId: studentId,
        action:    action,
        busId:     busId,
      );
      StudentService.instance.updateStatus(
        id:     studentId,
        status: _studentStatusToDb(student.status),
        label:  '$nowLabel · Scan',
      );
    }

    switch (prev) {
      case DriverScanPhase.idle:
        return DriverScanOutcome(
          phaseAfter:  DriverScanPhase.boarded,
          studentName: student.name,
          title:       'On board',
          detail:      '${student.name} marked as pickup / on bus.',
          warning:     false,
        );
      case DriverScanPhase.boarded:
        return DriverScanOutcome(
          phaseAfter:  DriverScanPhase.droppedOff,
          studentName: student.name,
          title:       'Dropped off',
          detail:      '${student.name} safely dropped off.',
          warning:     false,
        );
      case DriverScanPhase.droppedOff:
        return DriverScanOutcome(
          phaseAfter:  DriverScanPhase.droppedOff,
          studentName: student.name,
          title:       'Multiple scans',
          detail:
              'This student already completed drop-off. Please verify with dispatch.',
          warning:        true,
          showStaffAlert: true,
        );
    }
  }

  void resetDriverScanDemo(String studentId) {
    _driverScanPhase.remove(studentId);
    notifyListeners();
  }

  // ── Gate lookup ───────────────────────────────────────────────────────────

  static String normalizeDigits(String raw) =>
      raw.replaceAll(RegExp(r'\D'), '');

  GatePickupPersonProfile? lookupGatePickupPersonByNationalId(String raw) {
    final q = raw.trim();
    if (q.isEmpty) return null;
    for (final p in gatePickupDirectory) {
      if (p.nationalId == q) return p;
    }
    return null;
  }

  GatePickupPersonProfile? lookupGatePickupPersonByPhone(String raw) {
    final d = normalizeDigits(raw);
    if (d.isEmpty) return null;
    for (final p in gatePickupDirectory) {
      if (p.phoneDigits == d ||
          d.endsWith(p.phoneDigits) ||
          p.phoneDigits.endsWith(d)) return p;
    }
    return null;
  }

  // Async Supabase gate lookup (returns null when not configured)
  Future<GatePickupPersonProfile?> lookupGatePersonAsync({
    String? nationalId,
    String? phone,
  }) async {
    if (!isSupabaseConfigured) {
      if (nationalId != null) return lookupGatePickupPersonByNationalId(nationalId);
      if (phone != null)      return lookupGatePickupPersonByPhone(phone);
      return null;
    }

    try {
      final profileService = supabase.from('profiles');
      Map<String, dynamic>? row;

      if (nationalId != null && nationalId.trim().isNotEmpty) {
        row = await profileService
            .select('*, parent_students(student_id), guardian_students:guardians(id)')
            .eq('national_id', nationalId.trim())
            .maybeSingle();
      } else if (phone != null && phone.isNotEmpty) {
        final d = normalizeDigits(phone);
        final rows = await profileService
            .select()
            .ilike('phone', '%$d%')
            .limit(1);
        row = rows.isNotEmpty ? rows.first : null;
      }

      if (row == null) return null;

      return GatePickupPersonProfile(
        nationalId:          (row['national_id'] as String?) ?? '',
        phoneDigits:         normalizeDigits((row['phone'] as String?) ?? ''),
        displayPhone:        (row['phone'] as String?) ?? '',
        fullName:            row['full_name'] as String,
        kind:                (row['role'] as String) == 'guardian'
            ? GatePickupPersonKind.guardian
            : GatePickupPersonKind.parent,
        linkedChildren:      [],
        authorizationLabel:  'Verified · Active',
        allowedActionLabel:  'Pickup & drop-off',
      );
    } catch (_) {
      return null;
    }
  }

  // ── Guardian helpers ──────────────────────────────────────────────────────

  bool isGuardianAssignedChild(DemoParentChild c) =>
      guardianProfile.assignedChildNames.contains(c.name);

  List<DemoParentChild> guardianLinkedDemoChildren() =>
      parentDemoChildren.where(isGuardianAssignedChild).toList();

  Student? studentMatchingDemoChild(DemoParentChild c) {
    try {
      return students.firstWhere((s) => s.name == c.name);
    } catch (_) {
      return null;
    }
  }

  void setGuardianPickupIntent(String demoChildId, GuardianPickupIntent intent) {
    guardianPickupIntentByChildId[demoChildId] = intent;
    notifyListeners();
  }

  GuardianPickupIntent guardianPickupIntentFor(String demoChildId) =>
      guardianPickupIntentByChildId[demoChildId] ?? GuardianPickupIntent.none;

  // ── Misc helpers ──────────────────────────────────────────────────────────

  bool studentHasPendingPickupRequest(Student s) {
    for (final r in requests) {
      if (r.status != RequestStatus.pending) continue;
      if (r.studentId == s.id)   return true;
      if (demoChildName(r.studentId) == s.name) return true;
    }
    return false;
  }

  DemoParentChild? demoChild(String id) {
    try {
      return parentDemoChildren.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  String demoChildName(String studentId) {
    final d = demoChild(studentId);
    if (d != null) return d.name;
    try {
      return students.firstWhere((s) => s.id == studentId).name;
    } catch (_) {
      return studentId;
    }
  }

  bool verifyPickupQrMock({required bool valid}) => valid;

  int countStudentsWhere(bool Function(Student s) predicate) =>
      students.where(predicate).length;

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _authSub?.cancel();
    _studentsSub?.cancel();
    _busesSub?.cancel();
    _requestsSub?.cancel();
    _alertsSub?.cancel();
    super.dispose();
  }
}
