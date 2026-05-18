import 'package:flutter/foundation.dart';

enum StudentStatus { atHome, onBusToSchool, atSchool, onBusToHome, pickedUpByCar }
enum RequestStatus { pending, approved, rejected }
enum BusStatus { stationary, onRouteToSchool, onRouteToHome }
enum UserRole { parent, schoolStaff, busDriver, guardian, none }

/// Parent-side demo child (bus vs car). IDs are used by parent requests UI.
enum DemoChildTransport { bus, car }

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

/// School Early/Late pickup coordination (staff-only mock list).
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

/// Guardian mock profile shown on guardian profile screen.
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

/// Staff operational bulletin (shown as “Operational Alerts”).
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

/// Guardian-declared intent for an assigned child (mock gate coordination).
enum GuardianPickupIntent { none, pick, drop }

/// Person type returned by gate verification lookup (mock directory).
enum GatePickupPersonKind { parent, guardian }

/// Mock profile used by [MockState.lookupGatePickupPerson].
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

/// Single mock session for MVP driver scan sequencing (per student id).
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

class MockState extends ChangeNotifier {
  UserRole currentUserRole = UserRole.none;

  final GuardianDemoProfile guardianProfile = const GuardianDemoProfile(
    fullName: 'Mohammed Ali',
    phone: '+966 50 000 4411',
    email: 'm.ali.demo@gateflow.app',
    relationship: 'Uncle · Authorized guardian',
    authorizationNote: 'Active · Verified by school',
    assignedChildNames: ['Saad Khaled', 'Sara Khaled'],
    notificationsEnabled: true,
  );

  List<OperationalAlert> operationalAlerts = [
    OperationalAlert(
      id: 'a1',
      title: 'Bus 12A departure delayed',
      body: 'North route running ~8 min behind. Gate team notified.',
      createdAt: DateTime.now(),
    ),
    OperationalAlert(
      id: 'a2',
      title: 'Early pickup spike',
      body: '3 early dismissals clustered at 12:30 PM — monitor gate queue.',
      createdAt: DateTime.now(),
    ),
  ];

  List<DemoParentChild> parentDemoChildren = [
    DemoParentChild(
      id: 'pc1',
      name: 'Saad Khaled',
      grade: 'Grade 6',
      transport: DemoChildTransport.car,
    ),
    DemoParentChild(
      id: 'pc2',
      name: 'Sara Khaled',
      grade: 'Grade 6',
      transport: DemoChildTransport.car,
    ),
    DemoParentChild(
      id: 'pc3',
      name: 'Noah Khaled',
      grade: 'Grade 1',
      transport: DemoChildTransport.bus,
      busId: 'b1',
    ),
    DemoParentChild(
      id: 'pc4',
      name: 'Lama Khaled',
      grade: 'Grade 1',
      transport: DemoChildTransport.bus,
      busId: 'b1',
    ),
  ];

  List<Student> students = [
    Student(
      id: 's1',
      name: 'Khalid Jr.',
      grade: 'Grade 3',
      status: StudentStatus.atSchool,
      busId: 'b1',
      lastMockUpdateLabel: '7:45 AM · Arrived school',
    ),
    Student(
      id: 's2',
      name: 'Aisha',
      grade: 'Grade 1',
      status: StudentStatus.atHome,
      lastMockUpdateLabel: 'Yesterday · Picked up by car',
    ),
    Student(
      id: 's3',
      name: 'Noah Khaled',
      grade: 'Grade 1',
      status: StudentStatus.onBusToSchool,
      busId: 'b1',
      lastMockUpdateLabel: '7:50 AM · Boarded (mock)',
    ),
    Student(
      id: 's4',
      name: 'Lama Khaled',
      grade: 'Grade 1',
      status: StudentStatus.atSchool,
      busId: 'b1',
      lastMockUpdateLabel: '7:40 AM · Arrived school',
    ),
  ];

  List<Bus> buses = [
    Bus(
      id: 'b1',
      name: 'Bus 12A',
      routeLabel: 'North Route · Zones A–D',
      driverName: 'Hassan (You)',
      driverId: 'd1',
      status: BusStatus.onRouteToHome,
      lastUpdateLabel: '2 min ago · GPS mock',
    ),
  ];

  List<ParentRequest> requests = [
    ParentRequest(
      id: 'r1',
      studentId: 'pc3',
      type: 'Early Pickup',
      status: RequestStatus.pending,
      date: DateTime.now(),
      pickupPersonSummary: 'Parent · Khalid',
      timeLabel: '3:30 PM',
    ),
    ParentRequest(
      id: 'r0',
      studentId: 'pc2',
      type: 'Late Drop-off',
      status: RequestStatus.approved,
      date: DateTime.now().subtract(const Duration(days: 1)),
      pickupPersonSummary: 'Guardian · Deem',
      timeLabel: '4:00 PM',
    ),
  ];

  List<SchoolTimeRequestEntry> schoolTimeRequests = [
    SchoolTimeRequestEntry(
      id: 'tr_e1',
      childName: 'Saad Ahmed',
      grade: 'Grade 4',
      reason: 'Doctor appointment',
      timeLabel: '12:30 PM',
      requestedBy: 'Parent · Ahmed',
      isEarly: true,
      status: RequestStatus.pending,
    ),
    SchoolTimeRequestEntry(
      id: 'tr_e2',
      childName: 'Sara Khaled',
      grade: 'Grade 6',
      reason: 'Family event',
      timeLabel: '1:00 PM',
      requestedBy: 'Guardian · Deem',
      isEarly: true,
      status: RequestStatus.pending,
    ),
    SchoolTimeRequestEntry(
      id: 'tr_l1',
      childName: 'Noah Khaled',
      grade: 'Grade 1',
      reason: 'Traffic delay',
      timeLabel: '8:30 AM',
      requestedBy: 'Parent · Khalid',
      isEarly: false,
      status: RequestStatus.pending,
    ),
    SchoolTimeRequestEntry(
      id: 'tr_l2',
      childName: 'Yousef Ali',
      grade: 'Grade 5',
      reason: 'Doctor appointment',
      timeLabel: '9:15 AM',
      requestedBy: 'Parent · Ali',
      isEarly: false,
      status: RequestStatus.approved,
    ),
  ];

  PendingGuardianInvite? latestGuardianSubmission;

  /// Demo directory for staff gate verification (ID / phone lookup).
  final List<GatePickupPersonProfile> gatePickupDirectory = [
    const GatePickupPersonProfile(
      nationalId: '1234567890',
      phoneDigits: '966501112233',
      displayPhone: '+966 50 111 2233',
      fullName: 'Khalid Al-Otaibi',
      kind: GatePickupPersonKind.parent,
      linkedChildren: ['Noah Khaled', 'Lama Khaled'],
      authorizationLabel: 'Verified parent · Active',
      allowedActionLabel: 'Pickup & drop-off',
    ),
    const GatePickupPersonProfile(
      nationalId: '9876543210',
      phoneDigits: '96650004411',
      displayPhone: '+966 50 000 4411',
      fullName: 'Mohammed Ali',
      kind: GatePickupPersonKind.guardian,
      linkedChildren: ['Saad Khaled', 'Sara Khaled'],
      authorizationLabel: 'Verified guardian · School approved',
      allowedActionLabel: 'Pickup only (mock)',
    ),
    const GatePickupPersonProfile(
      nationalId: '5555555555',
      phoneDigits: '966551234567',
      displayPhone: '+966 55 123 4567',
      fullName: 'Fatima Hassan',
      kind: GatePickupPersonKind.parent,
      linkedChildren: ['Khalid Jr.'],
      authorizationLabel: 'Verified parent',
      allowedActionLabel: 'Pickup & drop-off',
    ),
  ];

  /// Per demo child id (`pc1`…): last guardian intent at gate (mock).
  final Map<String, GuardianPickupIntent> guardianPickupIntentByChildId = {};

  /// Guardian profile screen toggles (mock).
  bool guardianNotifyEnabled = true;

  static String normalizeDigits(String raw) =>
      raw.replaceAll(RegExp(r'\D'), '');

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
      if (p.phoneDigits == d || d.endsWith(p.phoneDigits) || p.phoneDigits.endsWith(d)) {
        return p;
      }
    }
    return null;
  }

  void setGuardianPickupIntent(String demoChildId, GuardianPickupIntent intent) {
    guardianPickupIntentByChildId[demoChildId] = intent;
    notifyListeners();
  }

  GuardianPickupIntent guardianPickupIntentFor(String demoChildId) =>
      guardianPickupIntentByChildId[demoChildId] ?? GuardianPickupIntent.none;

  bool studentHasPendingPickupRequest(Student s) {
    for (final r in requests) {
      if (r.status != RequestStatus.pending) continue;
      if (r.studentId == s.id) return true;
      if (demoChildName(r.studentId) == s.name) return true;
    }
    return false;
  }

  void setGuardianNotifyEnabled(bool value) {
    guardianNotifyEnabled = value;
    notifyListeners();
  }

  final Set<String> releasedPickupRequestIds = {};

  final Map<String, DriverScanPhase> _driverScanPhase = {};

  DriverScanOutcome recordDriverBoardingScan(String studentId) {
    final student = students.firstWhere((s) => s.id == studentId);
    final prev = _driverScanPhase[studentId] ?? DriverScanPhase.idle;
    DriverScanPhase next = prev;

    switch (prev) {
      case DriverScanPhase.idle:
        next = DriverScanPhase.boarded;
        student.status = StudentStatus.onBusToHome;
        break;
      case DriverScanPhase.boarded:
        next = DriverScanPhase.droppedOff;
        student.status = StudentStatus.atHome;
        break;
      case DriverScanPhase.droppedOff:
        operationalAlerts.insert(
          0,
          OperationalAlert(
            id: 'scan_${studentId}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Driver scan alert',
            body:
                '${student.name} scanned again after drop-off · School notified (mock)',
            createdAt: DateTime.now(),
          ),
        );
        break;
    }
    _driverScanPhase[studentId] = next;
    final nowLabel = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    student.lastMockUpdateLabel = '$nowLabel · Scan';

    notifyListeners();

    switch (prev) {
      case DriverScanPhase.idle:
        return DriverScanOutcome(
          phaseAfter: DriverScanPhase.boarded,
          studentName: student.name,
          title: 'On board',
          detail: '${student.name} marked as pickup / on bus.',
          warning: false,
        );
      case DriverScanPhase.boarded:
        return DriverScanOutcome(
          phaseAfter: DriverScanPhase.droppedOff,
          studentName: student.name,
          title: 'Dropped off',
          detail: '${student.name} safely dropped off.',
          warning: false,
        );
      case DriverScanPhase.droppedOff:
        return DriverScanOutcome(
          phaseAfter: DriverScanPhase.droppedOff,
          studentName: student.name,
          title: 'Multiple scans',
          detail:
              'This student already completed drop-off. Please verify with dispatch.',
          warning: true,
          showStaffAlert: true,
        );
    }
  }

  void resetDriverScanDemo(String studentId) {
    _driverScanPhase.remove(studentId);
    notifyListeners();
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

  /// Marks an approved pickup request as released at the gate (mock).
  bool releaseStudentAfterVerification(String requestId) {
    try {
      final r = requests.firstWhere((e) => e.id == requestId);
      if (r.status != RequestStatus.approved) return false;
      releasedPickupRequestIds.add(requestId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void toggleChildAbsent(String childId, bool absent) {
    final c = parentDemoChildren.firstWhere((e) => e.id == childId);
    c.absentToday = absent;
    notifyListeners();
  }

  ParentRequest submitNewParentRequest({
    required String studentId,
    required String type,
    required String timeLabel,
    required String pickupPersonSummary,
  }) {
    final id = 'r${DateTime.now().millisecondsSinceEpoch}';
    final r = ParentRequest(
      id: id,
      studentId: studentId,
      type: type,
      status: RequestStatus.pending,
      date: DateTime.now(),
      pickupPersonSummary: pickupPersonSummary,
      timeLabel: timeLabel,
    );
    requests = [...requests, r];
    notifyListeners();
    return r;
  }

  void submitPendingGuardianInvite(PendingGuardianInvite invite) {
    latestGuardianSubmission = invite;
    notifyListeners();
  }

  void updateSchoolTimeRequest(String id, RequestStatus status) {
    final e = schoolTimeRequests.firstWhere((x) => x.id == id);
    e.status = status;
    notifyListeners();
  }

  void updateStudentStatus(String id, StudentStatus newStatus) {
    var student = students.firstWhere((s) => s.id == id);
    student.status = newStatus;
    notifyListeners();
  }

  void updateRequestStatus(String id, RequestStatus newStatus) {
    var req = requests.firstWhere((r) => r.id == id);
    req.status = newStatus;
    notifyListeners();
  }

  void updateBusStatus(String id, BusStatus newStatus) {
    var bus = buses.firstWhere((b) => b.id == id);
    bus.status = newStatus;
    notifyListeners();
  }

  void loginAs(UserRole role) {
    currentUserRole = role;
    notifyListeners();
  }

  int countStudentsWhere(bool Function(Student s) predicate) =>
      students.where(predicate).length;

  List<ParentRequest> approvedParentRequestsAwaitingPickup() => requests
      .where((r) =>
          r.status == RequestStatus.approved &&
          !releasedPickupRequestIds.contains(r.id))
      .toList();
}
