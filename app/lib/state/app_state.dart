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

  static const String _specialAccessPassword = 'demo123';

  bool isSpecialAccessCode(String code) {
    final normalizedCode = code.trim().toUpperCase();

    return normalizedCode == 'SINERGIA-2026' ||
        normalizedCode == 'TALLER-NORTE-2026' ||
        normalizedCode == 'TALLER-CENTRAL-2026';
  }

  User? loginWithClaimCode(String code) {
    final normalizedCode = code.trim().toUpperCase();

    for (final repairCase in repairCases) {
      if (repairCase.claimNumber.toUpperCase() == normalizedCode) {
        final user = getUserById(repairCase.insuredUserId);

        if (user != null && user.role == UserRole.insured) {
          loginAs(user);
          return user;
        }
      }
    }

    return null;
  }

  User? loginWithSpecialAccess(String code, String password) {
    if (password != _specialAccessPassword) {
      return null;
    }

    final normalizedCode = code.trim().toUpperCase();
    String? userId;

    if (normalizedCode == 'SINERGIA-2026') {
      userId = 'user-consultant';
    } else if (normalizedCode == 'TALLER-NORTE-2026') {
      userId = 'workshop-1-user';
    } else if (normalizedCode == 'TALLER-CENTRAL-2026') {
      userId = 'workshop-2-user';
    } else {
      return null;
    }

    final user = getUserById(userId);

    if (user == null) {
      return null;
    }

    loginAs(user);
    return user;
  }

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
            .where(
              (repairCase) => repairCase.workshopId == _currentUser!.workshopId,
            )
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
    final sorted =
        messages.where((message) => message.caseId == caseId).toList()
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
      status: workshopId == null
          ? RepairCaseStatus.newCase
          : RepairCaseStatus.workshopAssigned,
      entryDate: DateTime.now(),
      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 12)),
      progress: 0,
      workshopId: workshopId,
    );

    repairCases.add(repairCase);
    notifyListeners();
  }

  void assignWorkshop(String caseId, String workshopId) {
    final index = repairCases.indexWhere(
      (repairCase) => repairCase.id == caseId,
    );

    if (index == -1) {
      return;
    }

    repairCases[index] = repairCases[index].copyWith(
      workshopId: workshopId,
      status: RepairCaseStatus.workshopAssigned,
    );

    notifyListeners();
  }

  void updateCaseStatus(String caseId, RepairCaseStatus status) {
    final index = repairCases.indexWhere(
      (repairCase) => repairCase.id == caseId,
    );

    if (index == -1) {
      return;
    }

    repairCases[index] = repairCases[index].copyWith(status: status);

    notifyListeners();
  }

  void updateProgress(String caseId, int progress) {
    final index = repairCases.indexWhere(
      (repairCase) => repairCase.id == caseId,
    );

    if (index == -1) {
      return;
    }

    repairCases[index] = repairCases[index].copyWith(
      progress: progress.clamp(0, 100),
    );

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
