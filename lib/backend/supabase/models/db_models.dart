// Dart models that map 1-to-1 to Supabase tables.
// These are separate from the UI-layer models in mock_state.dart.

class DbSchool {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final DateTime createdAt;

  const DbSchool({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.logoUrl,
    required this.createdAt,
  });

  factory DbSchool.fromJson(Map<String, dynamic> j) => DbSchool(
        id:        j['id'] as String,
        name:      j['name'] as String,
        address:   j['address'] as String?,
        phone:     j['phone'] as String?,
        email:     j['email'] as String?,
        logoUrl:   j['logo_url'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'name':     name,
        'address':  address,
        'phone':    phone,
        'email':    email,
        'logo_url': logoUrl,
      };
}

class DbProfile {
  final String  id;
  final String  fullName;
  final String? phone;
  final String  role;           // 'parent'|'guardian'|'bus_driver'|'school_staff'
  final String? schoolId;
  final String? nationalId;
  final String? avatarUrl;
  final String? loginEmail;
  final String? initialPassword;
  final bool    isActive;
  final DateTime createdAt;

  const DbProfile({
    required this.id,
    required this.fullName,
    this.phone,
    required this.role,
    this.schoolId,
    this.nationalId,
    this.avatarUrl,
    this.loginEmail,
    this.initialPassword,
    required this.isActive,
    required this.createdAt,
  });

  factory DbProfile.fromJson(Map<String, dynamic> j) => DbProfile(
        id:              j['id'] as String,
        fullName:        j['full_name'] as String,
        phone:           j['phone'] as String?,
        role:            j['role'] as String,
        schoolId:        j['school_id'] as String?,
        nationalId:      j['national_id'] as String?,
        avatarUrl:       j['avatar_url'] as String?,
        loginEmail:      j['login_email'] as String?,
        initialPassword: j['initial_password'] as String?,
        isActive:        (j['is_active'] as bool?) ?? true,
        createdAt:       DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toInsertJson({
    required String fullName,
    required String role,
    String? phone,
    String? schoolId,
    String? nationalId,
  }) =>
      {
        'full_name':   fullName,
        'role':        role,
        if (phone != null)      'phone':       phone,
        if (schoolId != null)   'school_id':   schoolId,
        if (nationalId != null) 'national_id': nationalId,
      };
}

class DbBus {
  final String  id;
  final String  name;
  final String? routeLabel;
  final String? plateNumber;
  final String? driverId;
  final String  status;    // bus_status_enum
  final String  schoolId;
  final String? lastUpdateLabel;
  final DateTime createdAt;

  const DbBus({
    required this.id,
    required this.name,
    this.routeLabel,
    this.plateNumber,
    this.driverId,
    required this.status,
    required this.schoolId,
    this.lastUpdateLabel,
    required this.createdAt,
  });

  factory DbBus.fromJson(Map<String, dynamic> j) => DbBus(
        id:               j['id'] as String,
        name:             j['name'] as String,
        routeLabel:       j['route_label'] as String?,
        plateNumber:      j['plate_number'] as String?,
        driverId:         j['driver_id'] as String?,
        status:           j['status'] as String,
        schoolId:         j['school_id'] as String,
        lastUpdateLabel:  j['last_update_label'] as String?,
        createdAt:        DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toInsertJson() => {
        'name':              name,
        'route_label':       routeLabel,
        'plate_number':      plateNumber,
        'driver_id':         driverId,
        'status':            status,
        'school_id':         schoolId,
        'last_update_label': lastUpdateLabel,
      };
}

class DbStudent {
  final String  id;
  final String  name;
  final String  grade;
  final String  schoolId;
  final String  status;          // student_status_enum
  final String  transportType;   // 'bus'|'car'
  final String? busId;
  final String? lastUpdateLabel;
  final String? profilePhotoUrl;
  final String? pickupLocationLabel;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  const DbStudent({
    required this.id,
    required this.name,
    required this.grade,
    required this.schoolId,
    required this.status,
    required this.transportType,
    this.busId,
    this.lastUpdateLabel,
    this.profilePhotoUrl,
    this.pickupLocationLabel,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory DbStudent.fromJson(Map<String, dynamic> j) => DbStudent(
        id:                   j['id'] as String,
        name:                 j['name'] as String,
        grade:                j['grade'] as String,
        schoolId:             j['school_id'] as String,
        status:               j['status'] as String,
        transportType:        j['transport_type'] as String,
        busId:                j['bus_id'] as String?,
        lastUpdateLabel:      j['last_update_label'] as String?,
        profilePhotoUrl:      j['profile_photo_url'] as String?,
        pickupLocationLabel:  j['pickup_location_label'] as String?,
        latitude:             (j['latitude'] as num?)?.toDouble(),
        longitude:            (j['longitude'] as num?)?.toDouble(),
        createdAt:            DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toInsertJson() => {
        'name':              name,
        'grade':             grade,
        'school_id':         schoolId,
        'status':            status,
        'transport_type':    transportType,
        if (busId != null)   'bus_id': busId,
        'last_update_label': lastUpdateLabel,
        if (pickupLocationLabel != null)
          'pickup_location_label': pickupLocationLabel,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}

class DbParentStudent {
  final String id;
  final String parentId;
  final String studentId;
  final DateTime createdAt;

  const DbParentStudent({
    required this.id,
    required this.parentId,
    required this.studentId,
    required this.createdAt,
  });

  factory DbParentStudent.fromJson(Map<String, dynamic> j) => DbParentStudent(
        id:        j['id'] as String,
        parentId:  j['parent_id'] as String,
        studentId: j['student_id'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class DbGuardian {
  final String  id;
  final String? guardianUserId;
  final String  parentId;
  final String  fullName;
  final String? phone;
  final String? email;
  final String? relationship;
  final String? nationalId;
  final String  status;    // guardian_status_enum
  final String? authorizedBy;
  final DateTime? authorizedAt;
  final String? notes;
  final DateTime createdAt;
  final List<String> studentIds;

  const DbGuardian({
    required this.id,
    this.guardianUserId,
    required this.parentId,
    required this.fullName,
    this.phone,
    this.email,
    this.relationship,
    this.nationalId,
    required this.status,
    this.authorizedBy,
    this.authorizedAt,
    this.notes,
    required this.createdAt,
    this.studentIds = const [],
  });

  factory DbGuardian.fromJson(Map<String, dynamic> j) => DbGuardian(
        id:              j['id'] as String,
        guardianUserId:  j['guardian_user_id'] as String?,
        parentId:        j['parent_id'] as String,
        fullName:        j['full_name'] as String,
        phone:           j['phone'] as String?,
        email:           j['email'] as String?,
        relationship:    j['relationship'] as String?,
        nationalId:      j['national_id'] as String?,
        status:          j['status'] as String,
        authorizedBy:    j['authorized_by'] as String?,
        authorizedAt:    j['authorized_at'] != null
            ? DateTime.parse(j['authorized_at'] as String)
            : null,
        notes:           j['notes'] as String?,
        createdAt:       DateTime.parse(j['created_at'] as String),
        studentIds: (j['guardian_students'] as List<dynamic>?)
                ?.map((e) => e['student_id'] as String)
                .toList() ??
            [],
      );

  Map<String, dynamic> toInsertJson() => {
        'parent_id':    parentId,
        'full_name':    fullName,
        'phone':        phone,
        'email':        email,
        'relationship': relationship,
        'national_id':  nationalId,
        'status':       'pending',
        if (notes != null) 'notes': notes,
      };
}

class DbPickupRequest {
  final String  id;
  final String  studentId;
  final String  requestedBy;
  final String  type;
  final String  status;
  final String? timeLabel;
  final String? pickupPersonSummary;
  final String  date;
  final String? notes;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final bool    releasedAtGate;
  final DateTime? releasedAt;
  final DateTime createdAt;

  const DbPickupRequest({
    required this.id,
    required this.studentId,
    required this.requestedBy,
    required this.type,
    required this.status,
    this.timeLabel,
    this.pickupPersonSummary,
    required this.date,
    this.notes,
    this.reviewedBy,
    this.reviewedAt,
    required this.releasedAtGate,
    this.releasedAt,
    required this.createdAt,
  });

  factory DbPickupRequest.fromJson(Map<String, dynamic> j) => DbPickupRequest(
        id:                   j['id'] as String,
        studentId:            j['student_id'] as String,
        requestedBy:          j['requested_by'] as String,
        type:                 j['type'] as String,
        status:               j['status'] as String,
        timeLabel:            j['time_label'] as String?,
        pickupPersonSummary:  j['pickup_person_summary'] as String?,
        date:                 j['date'] as String,
        notes:                j['notes'] as String?,
        reviewedBy:           j['reviewed_by'] as String?,
        reviewedAt:           j['reviewed_at'] != null
            ? DateTime.parse(j['reviewed_at'] as String)
            : null,
        releasedAtGate:       (j['released_at_gate'] as bool?) ?? false,
        releasedAt:           j['released_at'] != null
            ? DateTime.parse(j['released_at'] as String)
            : null,
        createdAt:            DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toInsertJson() => {
        'student_id':             studentId,
        'requested_by':           requestedBy,
        'type':                   type,
        'status':                 'pending',
        if (timeLabel != null)            'time_label':            timeLabel,
        if (pickupPersonSummary != null)  'pickup_person_summary': pickupPersonSummary,
        'date':                   date,
        if (notes != null)                'notes':                 notes,
      };
}

class DbDailySchedule {
  final String  id;
  final String  schoolId;
  final String  className;
  final String? grade;
  final String  date;
  final String? arrivalTime;
  final String? departureTime;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;

  const DbDailySchedule({
    required this.id,
    required this.schoolId,
    required this.className,
    this.grade,
    required this.date,
    this.arrivalTime,
    this.departureTime,
    this.notes,
    this.createdBy,
    required this.createdAt,
  });

  factory DbDailySchedule.fromJson(Map<String, dynamic> j) => DbDailySchedule(
        id:            j['id'] as String,
        schoolId:      j['school_id'] as String,
        className:     j['class_name'] as String,
        grade:         j['grade'] as String?,
        date:          j['date'] as String,
        arrivalTime:   j['arrival_time'] as String?,
        departureTime: j['departure_time'] as String?,
        notes:         j['notes'] as String?,
        createdBy:     j['created_by'] as String?,
        createdAt:     DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toInsertJson() => {
        'school_id':      schoolId,
        'class_name':     className,
        if (grade != null)          'grade':          grade,
        'date':           date,
        if (arrivalTime != null)    'arrival_time':   arrivalTime,
        if (departureTime != null)  'departure_time': departureTime,
        if (notes != null)          'notes':          notes,
        if (createdBy != null)      'created_by':     createdBy,
      };
}

class DbNotification {
  final String  id;
  final String  userId;
  final String  title;
  final String  body;
  final String  type;
  final bool    isRead;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;

  const DbNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
  });

  factory DbNotification.fromJson(Map<String, dynamic> j) => DbNotification(
        id:            j['id'] as String,
        userId:        j['user_id'] as String,
        title:         j['title'] as String,
        body:          j['body'] as String,
        type:          j['type'] as String? ?? 'info',
        isRead:        (j['is_read'] as bool?) ?? false,
        referenceId:   j['reference_id'] as String?,
        referenceType: j['reference_type'] as String?,
        createdAt:     DateTime.parse(j['created_at'] as String),
      );
}

class DbOperationalAlert {
  final String id;
  final String schoolId;
  final String title;
  final String body;
  final String severity;
  final bool   isResolved;
  final String? createdBy;
  final DateTime createdAt;

  const DbOperationalAlert({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.body,
    required this.severity,
    required this.isResolved,
    this.createdBy,
    required this.createdAt,
  });

  factory DbOperationalAlert.fromJson(Map<String, dynamic> j) =>
      DbOperationalAlert(
        id:         j['id'] as String,
        schoolId:   j['school_id'] as String,
        title:      j['title'] as String,
        body:       j['body'] as String,
        severity:   j['severity'] as String? ?? 'info',
        isResolved: (j['is_resolved'] as bool?) ?? false,
        createdBy:  j['created_by'] as String?,
        createdAt:  DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toInsertJson() => {
        'school_id': schoolId,
        'title':     title,
        'body':      body,
        'severity':  severity,
      };
}

class DbDriverScanLog {
  final String  id;
  final String  driverId;
  final String  studentId;
  final String? busId;
  final String  action;    // 'boarded'|'dropped_off'
  final String? notes;
  final DateTime scannedAt;

  const DbDriverScanLog({
    required this.id,
    required this.driverId,
    required this.studentId,
    this.busId,
    required this.action,
    this.notes,
    required this.scannedAt,
  });

  factory DbDriverScanLog.fromJson(Map<String, dynamic> j) => DbDriverScanLog(
        id:        j['id'] as String,
        driverId:  j['driver_id'] as String,
        studentId: j['student_id'] as String,
        busId:     j['bus_id'] as String?,
        action:    j['action'] as String,
        notes:     j['notes'] as String?,
        scannedAt: DateTime.parse(j['scanned_at'] as String),
      );

  Map<String, dynamic> toInsertJson() => {
        'driver_id':  driverId,
        'student_id': studentId,
        if (busId != null) 'bus_id': busId,
        'action':     action,
        if (notes != null) 'notes': notes,
      };
}
