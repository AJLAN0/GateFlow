import '../data/mock_state.dart';

enum RouteStopPhase { completed, active, pending }

/// One stop on the driver route — school, student drop-off, or route end.
class DriverRouteStop {
  const DriverRouteStop({
    required this.title,
    required this.location,
    required this.detail,
    required this.phase,
    this.studentId,
  });

  final String title;
  final String location;
  final String detail;
  final RouteStopPhase phase;
  final String? studentId;
}

/// Parsed multi-stop driver route with current leg progress.
class DriverRouteProgress {
  const DriverRouteProgress({
    required this.stops,
    required this.routeStops,
    required this.currentLegIndex,
    required this.legProgress,
    required this.overallProgress,
    required this.completedDropoffs,
    required this.totalRiders,
    required this.estimatedMinutesRemaining,
  });

  final List<String> stops;
  final List<DriverRouteStop> routeStops;
  final int currentLegIndex;
  final double legProgress;
  final double overallProgress;
  final int completedDropoffs;
  final int totalRiders;
  final int estimatedMinutesRemaining;

  int get legCount => stops.length > 1 ? stops.length - 1 : 0;

  String get currentFrom => stops[currentLegIndex.clamp(0, stops.length - 1)];

  String get currentTo =>
      stops[(currentLegIndex + 1).clamp(0, stops.length - 1)];

  String get legSummary => '$currentFrom → $currentTo';

  int get legPercent => (legProgress.clamp(0.0, 1.0) * 100).round();

  int get overallPercent => (overallProgress.clamp(0.0, 1.0) * 100).round();

  int get remainingPercent => (100 - overallPercent).clamp(0, 100);

  bool isStopCompleted(int index) {
    if (index < routeStops.length) {
      return routeStops[index].phase == RouteStopPhase.completed;
    }
    if (index == 0) return overallProgress > 0 || completedDropoffs > 0;
    final threshold = index / (stops.length - 1);
    return overallProgress >= threshold - 0.001;
  }

  bool isStopCurrent(int index) {
    if (index < routeStops.length) {
      return routeStops[index].phase == RouteStopPhase.active;
    }
    return index == currentLegIndex || index == currentLegIndex + 1;
  }
}

/// Build stop names from the bus route label (e.g. "North Route · Zones A–D").
List<String> parseRouteStops({String? routeLabel, BusStatus? busStatus}) {
  final zones = <String>[];
  final label = (routeLabel ?? '').toLowerCase();
  if (label.contains('a')) zones.add('Zone A');
  if (label.contains('b')) zones.add('Zone B');
  if (label.contains('c')) zones.add('Zone C');
  if (label.contains('d')) zones.add('Zone D');
  if (zones.isEmpty) {
    zones.addAll(['Zone A', 'Zone B', 'Zone C', 'Zone D']);
  }

  final goingToSchool = busStatus == BusStatus.onRouteToSchool;
  if (goingToSchool) {
    return ['Depot', ...zones, 'School'];
  }
  return ['School', ...zones, 'Route end'];
}

String _studentLocation(Student s, int index) {
  if (s.dropOffLocation != null && s.dropOffLocation!.trim().isNotEmpty) {
    return s.dropOffLocation!.trim();
  }
  const zones = ['Zone A', 'Zone B', 'Zone C', 'Zone D'];
  return '${zones[index % zones.length]} · ${s.name} stop';
}

String _studentDetail(Student s) {
  switch (s.status) {
    case StudentStatus.atHome:
    case StudentStatus.pickedUpByCar:
      return s.lastMockUpdateLabel.isNotEmpty
          ? 'Dropped off · ${s.lastMockUpdateLabel}'
          : 'Dropped off';
    case StudentStatus.onBusToHome:
    case StudentStatus.onBusToSchool:
      return s.lastMockUpdateLabel.isNotEmpty
          ? 'On bus · ${s.lastMockUpdateLabel}'
          : 'On bus — next stop';
    case StudentStatus.atSchool:
      return 'On campus · checked in';
    case StudentStatus.waitingForDismissal:
      return 'Ready for afternoon pickup / bus';
  }
}

bool _studentDropped(Student s) =>
    s.status == StudentStatus.atHome ||
    s.status == StudentStatus.pickedUpByCar;

List<DriverRouteStop> buildDriverRouteStops({
  required Bus? bus,
  required List<Student> riders,
  required double overallProgress,
}) {
  final sorted = [...riders]
    ..sort((a, b) => _studentLocation(a, 0).compareTo(_studentLocation(b, 0)));

  final routeStops = <DriverRouteStop>[];
  final departed = overallProgress > 0.02 ||
      sorted.any((s) =>
          s.status == StudentStatus.onBusToHome ||
          s.status == StudentStatus.onBusToSchool ||
          _studentDropped(s));

  routeStops.add(DriverRouteStop(
    title: 'School',
    location: 'Main campus · Gate A',
    detail: departed ? 'Departed · students loaded' : 'Morning pickup point',
    phase: departed ? RouteStopPhase.completed : RouteStopPhase.active,
  ));

  var activeAssigned = false;
  for (var i = 0; i < sorted.length; i++) {
    final s = sorted[i];
    RouteStopPhase phase;
    if (_studentDropped(s)) {
      phase = RouteStopPhase.completed;
    } else if (!activeAssigned && departed) {
      phase = RouteStopPhase.active;
      activeAssigned = true;
    } else {
      phase = RouteStopPhase.pending;
    }

    routeStops.add(DriverRouteStop(
      title: s.name,
      location: _studentLocation(s, i),
      detail: _studentDetail(s),
      phase: phase,
      studentId: s.id,
    ));
  }

  if (sorted.isEmpty) {
    for (var i = 0; i < parseRouteStops(routeLabel: bus?.routeLabel).length - 2;
        i++) {
      final zone = 'Zone ${String.fromCharCode(65 + i)}';
      routeStops.add(DriverRouteStop(
        title: zone,
        location: '$zone · North district',
        detail: 'No riders assigned',
        phase: RouteStopPhase.pending,
      ));
    }
  }

  final allDone =
      sorted.isNotEmpty && sorted.every(_studentDropped);
  routeStops.add(DriverRouteStop(
    title: 'Route complete',
    location: bus?.routeLabel ?? 'End of line',
    detail: allDone ? 'All riders delivered' : 'Final checkpoint',
    phase: allDone ? RouteStopPhase.completed : RouteStopPhase.pending,
  ));

  if (!activeAssigned && departed && !allDone) {
    for (var i = 0; i < routeStops.length; i++) {
      if (routeStops[i].studentId != null &&
          routeStops[i].phase == RouteStopPhase.pending) {
        routeStops[i] = DriverRouteStop(
          title: routeStops[i].title,
          location: routeStops[i].location,
          detail: routeStops[i].detail,
          phase: RouteStopPhase.active,
          studentId: routeStops[i].studentId,
        );
        break;
      }
    }
  }

  return routeStops;
}

DriverRouteProgress computeDriverRouteProgress({
  required Bus? bus,
  required List<Student> riders,
}) {
  final stops = parseRouteStops(
    routeLabel: bus?.routeLabel,
    busStatus: bus?.status,
  );
  final total = riders.length;
  final dropped = riders.where(_studentDropped).length;

  final onRoute = bus?.status == BusStatus.onRouteToHome ||
      bus?.status == BusStatus.onRouteToSchool;

  double overall = total == 0 ? 0.0 : dropped / total;
  if (onRoute && overall < 0.04) overall = 0.06;

  final legCount = stops.length - 1;
  final scaled = overall * legCount;
  final legIndex = scaled.floor().clamp(0, legCount - 1);
  final legProg = legCount == 0 ? 0.0 : (scaled - legIndex).clamp(0.0, 1.0);

  final routeStops = buildDriverRouteStops(
    bus: bus,
    riders: riders,
    overallProgress: overall,
  );

  final pendingStops =
      routeStops.where((s) => s.phase != RouteStopPhase.completed).length;
  final eta = pendingStops * 8;

  return DriverRouteProgress(
    stops: stops,
    routeStops: routeStops,
    currentLegIndex: legIndex,
    legProgress: legProg,
    overallProgress: overall,
    completedDropoffs: dropped,
    totalRiders: total,
    estimatedMinutesRemaining: eta,
  );
}
