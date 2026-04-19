import 'package:flutter/foundation.dart';

enum StudentStatus { atHome, onBusToSchool, atSchool, onBusToHome, pickedUpByCar }
enum RequestStatus { pending, approved, rejected }
enum BusStatus { stationary, onRouteToSchool, onRouteToHome }
enum UserRole { parent, schoolStaff, busDriver, guardian, none }

class Student {
  final String id;
  final String name;
  final String grade;
  StudentStatus status;
  final String? busId;

  Student({required this.id, required this.name, required this.grade, required this.status, this.busId});
}

class Bus {
  final String id;
  final String name;
  final String driverId;
  BusStatus status;

  Bus({required this.id, required this.name, required this.driverId, required this.status});
}

class ParentRequest {
  final String id;
  final String studentId;
  final String type; // 'early_dismissal' or 'absence'.
  RequestStatus status;
  final DateTime date;

  ParentRequest({required this.id, required this.studentId, required this.type, required this.status, required this.date});
}

class MockState extends ChangeNotifier {
  UserRole currentUserRole = UserRole.none;

  List<Student> students = [
    Student(id: 's1', name: 'Khalid Jr.', grade: 'Grade 3', status: StudentStatus.atSchool, busId: 'b1'),
    Student(id: 's2', name: 'Aisha', grade: 'Grade 1', status: StudentStatus.atHome),
  ];

  List<Bus> buses = [
    Bus(id: 'b1', name: 'Bus 12A - North Route', driverId: 'd1', status: BusStatus.stationary),
  ];

  List<ParentRequest> requests = [
    ParentRequest(id: 'r1', studentId: 's1', type: 'Early Pickup', status: RequestStatus.pending, date: DateTime.now()),
  ];

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
}
