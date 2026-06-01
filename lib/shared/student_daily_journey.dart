import '../data/mock_state.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum AttendanceStatus {
  present,
  absent,
  notScheduled,
  holiday,
  emergencyHold,
}

enum MorningPickupStatus {
  notStarted,
  waitingAtHome,
  pickupScheduled,
  busArriving,
  boardedBusToSchool,
  pickedUpByCarToSchool,
  onWayToSchool,
  arrivedAtSchool,
  checkedInSchool,
  missedPickup,
  pickupCancelled,
  latePickup,
  manualReview,
}

enum AfternoonDropoffStatus {
  notStarted,
  atSchool,
  waitingForDismissal,
  waitingForPickup,
  guardianVerification,
  handedOverToGuardian,
  boardedBusHome,
  onBusHome,
  droppedOffHome,
  atHome,
  unauthorizedGuardian,
  guardianNoShow,
  dropoffFailed,
  lateDropoff,
  staffAlert,
}

enum TimelineVisualState { completed, current, pending, error, skipped }

enum JourneyPhaseStatus { notStarted, inProgress, completed, skipped }

enum StudentTransportMode { bus, car }

// ─── View models ─────────────────────────────────────────────────────────────

class TimelineStepData {
  const TimelineStepData({
    required this.title,
    required this.description,
    required this.visualState,
    this.timestamp,
    this.icon,
  });

  final String title;
  final String description;
  final TimelineVisualState visualState;
  final String? timestamp;
  final String? icon; // emoji hint for docs; UI uses IconData mapping
}

class StudentDailyJourney {
  const StudentDailyJourney({
    required this.studentName,
    required this.grade,
    required this.studentId,
    required this.transportMode,
    required this.transportLabel,
    required this.attendance,
    required this.currentStatusLabel,
    required this.morningPhase,
    required this.afternoonPhase,
    required this.morningSteps,
    required this.afternoonSteps,
  });

  final String studentName;
  final String grade;
  final String studentId;
  final StudentTransportMode transportMode;
  final String transportLabel;
  final AttendanceStatus attendance;
  final String currentStatusLabel;
  final JourneyPhaseStatus morningPhase;
  final JourneyPhaseStatus afternoonPhase;
  final List<TimelineStepData> morningSteps;
  final List<TimelineStepData> afternoonSteps;

  String get attendanceLabel {
    switch (attendance) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.notScheduled:
        return 'Not scheduled';
      case AttendanceStatus.holiday:
        return 'Holiday';
      case AttendanceStatus.emergencyHold:
        return 'Emergency hold';
    }
  }

  String get morningPhaseLabel {
    switch (morningPhase) {
      case JourneyPhaseStatus.notStarted:
        return 'Not started';
      case JourneyPhaseStatus.inProgress:
        return 'In progress';
      case JourneyPhaseStatus.completed:
        return 'Completed';
      case JourneyPhaseStatus.skipped:
        return 'Skipped';
    }
  }

  String get afternoonPhaseLabel {
    switch (afternoonPhase) {
      case JourneyPhaseStatus.notStarted:
        return 'Not started';
      case JourneyPhaseStatus.inProgress:
        return 'In progress';
      case JourneyPhaseStatus.completed:
        return 'Completed';
      case JourneyPhaseStatus.skipped:
        return 'Skipped';
    }
  }

  /// Builds journey UI from live [Student] + optional bus name.
  factory StudentDailyJourney.fromStudent(
    Student student, {
    String? busName,
    AttendanceStatus attendance = AttendanceStatus.present,
  }) {
    final isBus = (student.busId ?? '').isNotEmpty ||
        student.status == StudentStatus.onBusToSchool ||
        student.status == StudentStatus.onBusToHome;
    final mode =
        isBus ? StudentTransportMode.bus : StudentTransportMode.car;
    final transportLabel = isBus
        ? (busName != null && busName.isNotEmpty ? 'Bus · $busName' : 'School bus')
        : 'Private car / guardian';

    if (attendance == AttendanceStatus.absent) {
      return StudentDailyJourney._absent(
        student: student,
        transportLabel: transportLabel,
        mode: mode,
      );
    }

    final morning = _buildMorningSteps(student, mode);
    final afternoon = _buildAfternoonSteps(student, mode);
    final morningPhase = _morningPhase(student, morning);
    final afternoonPhase = _afternoonPhase(student, afternoon);

    return StudentDailyJourney(
      studentName: student.name,
      grade: student.grade,
      studentId: _shortId(student.id),
      transportMode: mode,
      transportLabel: transportLabel,
      attendance: attendance,
      currentStatusLabel: _currentStatusLabel(student),
      morningPhase: morningPhase,
      afternoonPhase: afternoonPhase,
      morningSteps: morning,
      afternoonSteps: afternoon,
    );
  }

  /// Sample bus student — mid-day at school.
  static StudentDailyJourney sampleBus() {
    return StudentDailyJourney.fromStudent(
      Student(
        id: 's-demo-bus',
        name: 'Noah Khaled',
        grade: 'Grade 1',
        status: StudentStatus.atSchool,
        busId: 'b1',
        dropOffLocation: 'Zone A · Al Narjis',
        lastMockUpdateLabel: '8:15 AM · Checked in',
      ),
      busName: 'Bus 12A',
    );
  }

  /// Sample car/guardian student — afternoon pickup in progress.
  static StudentDailyJourney sampleCar() {
    return StudentDailyJourney.fromStudent(
      Student(
        id: 's-demo-car',
        name: 'Lama Khaled',
        grade: 'Grade 1',
        status: StudentStatus.pickedUpByCar,
        lastMockUpdateLabel: '2:40 PM · Handed to guardian',
      ),
    );
  }

  static StudentDailyJourney _absent({
    required Student student,
    required String transportLabel,
    required StudentTransportMode mode,
  }) {
    TimelineStepData skipped(String title, String desc) => TimelineStepData(
          title: title,
          description: desc,
          visualState: TimelineVisualState.skipped,
        );

    final morning = mode == StudentTransportMode.bus
        ? [
            skipped('At Home', 'No pickup today'),
            skipped('Pickup Scheduled', 'Absent — not scheduled'),
            skipped('Boarded Bus to School', 'Skipped'),
            skipped('On Way to School', 'Skipped'),
            skipped('Arrived at School', 'Skipped'),
            skipped('Checked In', 'Skipped'),
          ]
        : [
            skipped('At Home', 'No pickup today'),
            skipped('Pickup Scheduled', 'Absent'),
            skipped('Picked Up by Car', 'Skipped'),
            skipped('On Way to School', 'Skipped'),
            skipped('Arrived at School', 'Skipped'),
            skipped('Checked In', 'Skipped'),
          ];

    final afternoon = mode == StudentTransportMode.bus
        ? [
            skipped('At School', 'Absent today'),
            skipped('Waiting Dismissal', 'Skipped'),
            skipped('Boarded Bus Home', 'Skipped'),
            skipped('On Bus Home', 'Skipped'),
            skipped('Dropped Off Home', 'Skipped'),
            skipped('At Home', 'Skipped'),
          ]
        : [
            skipped('At School', 'Absent today'),
            skipped('Waiting Dismissal', 'Skipped'),
            skipped('Waiting Pickup', 'Skipped'),
            skipped('Guardian Verification', 'Skipped'),
            skipped('Handed Over to Guardian', 'Skipped'),
            skipped('At Home', 'Skipped'),
          ];

    return StudentDailyJourney(
      studentName: student.name,
      grade: student.grade,
      studentId: _shortId(student.id),
      transportMode: mode,
      transportLabel: transportLabel,
      attendance: AttendanceStatus.absent,
      currentStatusLabel: 'Absent today',
      morningPhase: JourneyPhaseStatus.skipped,
      afternoonPhase: JourneyPhaseStatus.skipped,
      morningSteps: morning,
      afternoonSteps: afternoon,
    );
  }

  static String _shortId(String id) {
    if (id.length <= 8) return id;
    return id.substring(0, 8);
  }

  static String _currentStatusLabel(Student s) {
    switch (s.status) {
      case StudentStatus.atHome:
        return 'At home';
      case StudentStatus.onBusToSchool:
        return 'On bus · to school';
      case StudentStatus.atSchool:
        return 'At school · checked in';
      case StudentStatus.waitingForDismissal:
        return 'Waiting dismissal · ready for pickup';
      case StudentStatus.onBusToHome:
        return 'On bus · going home';
      case StudentStatus.pickedUpByCar:
        return 'Picked up by car / guardian';
    }
  }

  static int _morningActiveIndex(Student s, StudentTransportMode mode) {
    switch (s.status) {
      case StudentStatus.atHome:
        return 0;
      case StudentStatus.onBusToSchool:
        return 3;
      case StudentStatus.atSchool:
      case StudentStatus.waitingForDismissal:
      case StudentStatus.onBusToHome:
      case StudentStatus.pickedUpByCar:
        return 999; // morning leg complete
    }
  }

  static int _afternoonActiveIndex(Student s, StudentTransportMode mode) {
    switch (s.status) {
      case StudentStatus.atHome:
        return -1;
      case StudentStatus.onBusToSchool:
        return -1;
      case StudentStatus.atSchool:
        return 0;
      case StudentStatus.waitingForDismissal:
        return 1;
      case StudentStatus.onBusToHome:
        return mode == StudentTransportMode.bus ? 3 : -1;
      case StudentStatus.pickedUpByCar:
        return mode == StudentTransportMode.car ? 4 : -1;
    }
  }

  static JourneyPhaseStatus _morningPhase(
    Student s,
    List<TimelineStepData> steps,
  ) {
    if (steps.every((e) => e.visualState == TimelineVisualState.skipped)) {
      return JourneyPhaseStatus.skipped;
    }
    final idx = steps.indexWhere((e) => e.visualState == TimelineVisualState.current);
    if (idx < 0 && steps.last.visualState == TimelineVisualState.completed) {
      return JourneyPhaseStatus.completed;
    }
    if (idx <= 0 && s.status == StudentStatus.atHome) {
      return JourneyPhaseStatus.notStarted;
    }
    if (idx >= 0 || s.status == StudentStatus.onBusToSchool) {
      return JourneyPhaseStatus.inProgress;
    }
    if (s.status == StudentStatus.atSchool ||
        s.status == StudentStatus.waitingForDismissal ||
        s.status == StudentStatus.onBusToHome ||
        s.status == StudentStatus.pickedUpByCar) {
      return JourneyPhaseStatus.completed;
    }
    return JourneyPhaseStatus.notStarted;
  }

  static JourneyPhaseStatus _afternoonPhase(
    Student s,
    List<TimelineStepData> steps,
  ) {
    if (steps.every((e) => e.visualState == TimelineVisualState.skipped)) {
      return JourneyPhaseStatus.skipped;
    }
    if (s.status == StudentStatus.atHome ||
        s.status == StudentStatus.onBusToSchool) {
      return JourneyPhaseStatus.notStarted;
    }
    final idx = steps.indexWhere((e) => e.visualState == TimelineVisualState.current);
    if (steps.last.visualState == TimelineVisualState.completed) {
      return JourneyPhaseStatus.completed;
    }
    if (idx >= 0) return JourneyPhaseStatus.inProgress;
    if (s.status == StudentStatus.atSchool ||
        s.status == StudentStatus.waitingForDismissal) {
      return JourneyPhaseStatus.inProgress;
    }
    return JourneyPhaseStatus.notStarted;
  }

  static List<TimelineStepData> _buildMorningSteps(
    Student s,
    StudentTransportMode mode,
  ) {
    final active = _morningActiveIndex(s, mode);
    final ts = s.lastMockUpdateLabel.isNotEmpty ? s.lastMockUpdateLabel : null;

    if (mode == StudentTransportMode.bus) {
      return _timelineFromTitles(
        activeIndex: active,
        titles: const [
          ('At Home', 'Student is at home before morning pickup.'),
          ('Pickup Scheduled', 'Bus route assigned for today.'),
          ('Boarded Bus to School', 'Student scanned onto the morning bus.'),
          ('On Way to School', 'Bus is en route to campus.'),
          ('Arrived at School', 'Bus reached school gate.'),
          ('Checked In', 'Student checked in on campus.'),
        ],
        timestamp: ts,
      );
    }

    return _timelineFromTitles(
      activeIndex: active,
      titles: const [
        ('At Home', 'Student is at home before morning pickup.'),
        ('Pickup Scheduled', 'Parent/car pickup scheduled.'),
        ('Picked Up by Car', 'Parent or driver picked up the student.'),
        ('On Way to School', 'Traveling to school.'),
        ('Arrived at School', 'Reached school gate.'),
        ('Checked In', 'Student checked in on campus.'),
      ],
      timestamp: ts,
    );
  }

  static List<TimelineStepData> _buildAfternoonSteps(
    Student s,
    StudentTransportMode mode,
  ) {
    final active = _afternoonActiveIndex(s, mode);
    final ts = s.lastMockUpdateLabel.isNotEmpty ? s.lastMockUpdateLabel : null;

    if (mode == StudentTransportMode.bus) {
      return _timelineFromTitles(
        activeIndex: active,
        titles: const [
          ('At School', 'Student is on campus after morning arrival.'),
          ('Waiting Dismissal', 'Class ended — preparing for departure.'),
          ('Boarded Bus Home', 'Student scanned onto afternoon bus.'),
          ('On Bus Home', 'Bus is en route to drop-off stops.'),
          ('Dropped Off Home', 'Student delivered at home stop.'),
          ('At Home', 'Safely at home for the day.'),
        ],
        timestamp: ts,
      );
    }

    return _timelineFromTitles(
      activeIndex: active,
      titles: const [
        ('At School', 'Student is on campus.'),
        ('Waiting Dismissal', 'Ready for afternoon pickup at gate.'),
        ('Waiting Pickup', 'Parent or guardian en route to gate.'),
        ('Guardian Verification', 'ID / QR verified at pickup gate.'),
        ('Handed Over to Guardian', 'Student released to authorized adult.'),
        ('At Home', 'Safely at home for the day.'),
      ],
      timestamp: ts,
    );
  }

  static List<TimelineStepData> _timelineFromTitles({
    required int activeIndex,
    required List<(String, String)> titles,
    String? timestamp,
  }) {
    if (activeIndex >= titles.length) {
      return List.generate(titles.length, (i) {
        return TimelineStepData(
          title: titles[i].$1,
          description: titles[i].$2,
          visualState: TimelineVisualState.completed,
          timestamp: i == titles.length - 1 ? timestamp : null,
        );
      });
    }

    return List.generate(titles.length, (i) {
      TimelineVisualState state;
      if (activeIndex < 0) {
        state = TimelineVisualState.pending;
      } else if (i < activeIndex) {
        state = TimelineVisualState.completed;
      } else if (i == activeIndex) {
        state = TimelineVisualState.current;
      } else {
        state = TimelineVisualState.pending;
      }

      return TimelineStepData(
        title: titles[i].$1,
        description: titles[i].$2,
        visualState: state,
        timestamp: state == TimelineVisualState.current ? timestamp : null,
      );
    });
  }
}
