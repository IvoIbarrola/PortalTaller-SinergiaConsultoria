import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/message.dart';
import '../models/repair_case.dart';
import '../models/user.dart';
import '../models/vehicle.dart';
import '../models/workshop.dart';

class AppState extends ChangeNotifier {
  AppState._internal();

  static final AppState _instance = AppState._internal();

  factory AppState() => _instance;

  User? _currentUser;

  final List<User> users = List<User>.from(mockUsers);
  final List<Vehicle> vehicles = List<Vehicle>.from(mockVehicles);
  final List<Workshop> workshops = List<Workshop>.from(mockWorkshops);
  final List<RepairCase> repairCases = List<RepairCase>.from(mockRepairCases);
  final List<Message> messages = List<Message>.from(mockMessages);

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  List<RepairCase> get allCases => List<RepairCase>.from(repairCases);

  List<RepairCase> get casesForCurrentUser {
    if (_currentUser == null) {
      return const [];
    }

    switch (_currentUser!.role) {
      case UserRole.insured:
        return repairCases
            .where((repairCase) => repairCase.insuredUserId == _currentUser!.id)
            .toList();
      case UserRole.workshop:
        return repairCases
            .where((repairCase) => repairCase.workshopId == _currentUser!.workshopId)
            .toList();
      case UserRole.consultant:
        return List<RepairCase>.from(repairCases);
    }
  }

  User? getUserById(String id) {
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (_) {
      return null;
    }
  }

  Vehicle? getVehicleById(String id) {
    try {
      return vehicles.firstWhere((vehicle) => vehicle.id == id);
    } catch (_) {
      return null;
    }
  }

  Workshop? getWorkshopById(String id) {
    try {
      return workshops.firstWhere((workshop) => workshop.id == id);
    } catch (_) {
      return null;
    }
  }

  RepairCase? getCaseById(String id) {
    try {
      return repairCases.firstWhere((repairCase) => repairCase.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Message> messagesForCase(String caseId) {
    final sorted = messages
        .where((message) => message.caseId == caseId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  void loginAs(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void createCase({
    required String insuredUserId,
    required String vehicleId,
    required String claimNumber,
    required String description,
    String? workshopId,
  }) {
    final id = 'SINI-${DateTime.now().millisecondsSinceEpoch}';
    final repairCase = RepairCase(
      id: id,
      vehicleId: vehicleId,
      insuredUserId: insuredUserId,
      claimNumber: claimNumber,
      description: description,
      status: RepairCaseStatus.pending,
      entryDate: DateTime.now(),
      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 12)),
      progress: 0,
      workshopId: workshopId,
    );

    repairCases.add(repairCase);
    notifyListeners();
  }

  void assignWorkshop(String caseId, String workshopId) {
    final index = repairCases.indexWhere((repairCase) => repairCase.id == caseId);
    if (index == -1) {
      return;
    }

    repairCases[index] = repairCases[index].copyWith(workshopId: workshopId);
    notifyListeners();
  }

  void updateCaseStatus(String caseId, RepairCaseStatus status) {
    final index = repairCases.indexWhere((repairCase) => repairCase.id == caseId);
    if (index == -1) {
      return;
    }

    repairCases[index] = repairCases[index].copyWith(status: status);
    notifyListeners();
  }

  void updateProgress(String caseId, int progress) {
    final index = repairCases.indexWhere((repairCase) => repairCase.id == caseId);
    if (index == -1) {
      return;
    }

    repairCases[index] = repairCases[index].copyWith(progress: progress.clamp(0, 100));
    notifyListeners();
  }

  void addMessage({
    required String caseId,
    required String senderId,
    required String senderName,
    required String text,
  }) {
    if (text.trim().isEmpty) {
      return;
    }

    messages.add(
      Message(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        caseId: caseId,
        senderId: senderId,
        senderName: senderName,
        text: text.trim(),
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
