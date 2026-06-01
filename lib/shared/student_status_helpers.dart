import '../../data/mock_state.dart';
import 'status_pill.dart';

/// Maps live school roster entry to a gate-facing status pill.
StatusPill statusPillForSchoolStudent(Student s) {
  switch (s.status) {
    case StudentStatus.atHome:
      return const StatusPill(label: 'At home', tone: StatusTone.success);
    case StudentStatus.atSchool:
      return const StatusPill(label: 'At school', tone: StatusTone.info);
    case StudentStatus.waitingForDismissal:
      return const StatusPill(
        label: 'Waiting dismissal',
        tone: StatusTone.pending,
      );
    case StudentStatus.onBusToSchool:
    case StudentStatus.onBusToHome:
      return const StatusPill(label: 'On bus', tone: StatusTone.pending);
    case StudentStatus.pickedUpByCar:
      return const StatusPill(label: 'Car pickup', tone: StatusTone.approved);
  }
}

String studentStatusCopy(Student s) {
  switch (s.status) {
    case StudentStatus.atHome:
      return 'At home';
    case StudentStatus.atSchool:
      return 'At school · checked in';
    case StudentStatus.waitingForDismissal:
      return 'Waiting dismissal · ready for pickup';
    case StudentStatus.onBusToSchool:
      return 'On bus · to school';
    case StudentStatus.onBusToHome:
      return 'On bus · going home';
    case StudentStatus.pickedUpByCar:
      return 'Picked up by car';
  }
}

bool studentUsesBusRoster(Student s) =>
    (s.busId ?? '').isNotEmpty || 
    s.status == StudentStatus.onBusToSchool ||
    s.status == StudentStatus.onBusToHome;
