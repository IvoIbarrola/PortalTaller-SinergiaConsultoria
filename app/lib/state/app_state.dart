import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../data/supabase_config.dart';
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
  final List<User> users = [];
  final List<Vehicle> vehicles = [];
  final List<Workshop> workshops = [];
  final List<RepairCase> repairCases = [];
  final List<Message> messages = [];
  bool isLoading = false;
  String? lastError;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isSupabaseConfigured => SupabaseConfig.client != null;

  SupabaseClient get _client {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw StateError('Supabase no está configurado. Revisá SUPABASE_URL y SUPABASE_ANON_KEY.');
    }
    return client;
  }

  Future<User?> signIn(String email, String password) async {
    lastError = null;
    isLoading = true;
    notifyListeners();
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final authUser = response.user;
      if (authUser == null) throw const AuthException('No se pudo iniciar sesión.');

      final profile = await _client
          .from('profiles')
          .select()
          .eq('auth_user_id', authUser.id)
          .maybeSingle();
      if (profile == null) {
        await _client.auth.signOut();
        throw const AuthException('La cuenta no está vinculada a un perfil de Portal Taller.');
      }

      final user = _userFromRow(profile);
      _currentUser = user;
      users
        ..clear()
        ..add(user);
      await refreshData();
      return user;
    } catch (error) {
      lastError = _friendlyError(error);
      _currentUser = null;
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    lastError = null;
    try {
      final caseRows = await _client.from('repair_cases').select().order('entry_date', ascending: false);
      final vehicleRows = await _client.from('vehicles').select();
      final workshopRows = await _client.from('workshops').select();
      final profileRows = await _client.from('profiles').select();
      final messageRows = await _client.from('case_messages').select().order('created_at');

      repairCases
        ..clear()
        ..addAll((caseRows as List).map((row) => _caseFromRow(Map<String, dynamic>.from(row))));
      vehicles
        ..clear()
        ..addAll((vehicleRows as List).map((row) => _vehicleFromRow(Map<String, dynamic>.from(row))));
      workshops
        ..clear()
        ..addAll((workshopRows as List).map((row) => _workshopFromRow(Map<String, dynamic>.from(row))));
      users
        ..clear()
        ..addAll((profileRows as List).map((row) => _userFromRow(Map<String, dynamic>.from(row))));
      messages
        ..clear()
        ..addAll((messageRows as List).map((row) => _messageFromRow(Map<String, dynamic>.from(row))));
      if (_currentUser != null) {
        final current = users.where((user) => user.id == _currentUser!.id);
        if (current.isNotEmpty) _currentUser = current.first;
      }
    } catch (error) {
      lastError = _friendlyError(error);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  String _friendlyError(Object error) {
    if (error is PostgrestException) {
      if (error.code == '42501' || error.code == 'PGRST301') {
        return 'Supabase respondió, pero el acceso fue rechazado por permisos/RLS. Verificá las políticas y que el usuario esté autenticado.';
      }
      return 'Error de Supabase: ${error.message}';
    }
    if (error is AuthException) return error.message;
    if (error is StateError) return error.message;
    return 'No se pudo cargar la información desde Supabase: $error';
  }

  User _userFromRow(Map<String, dynamic> row) => User(
    id: row['id'].toString(),
    name: (row['name'] ?? '').toString(),
    role: UserRole.values.firstWhere(
      (role) => role.name == row['role'],
      orElse: () => UserRole.insured,
    ),
    workshopId: row['workshop_id']?.toString(),
  );

  Vehicle _vehicleFromRow(Map<String, dynamic> row) => Vehicle(
    id: row['id'].toString(),
    brand: (row['brand'] ?? '').toString(),
    model: (row['model'] ?? '').toString(),
    year: (row['year'] as num?)?.toInt() ?? 0,
    plate: (row['plate'] ?? '').toString(),
    color: (row['color'] ?? '').toString(),
    imageUrl: (row['image_url'] ?? '').toString(),
  );

  Workshop _workshopFromRow(Map<String, dynamic> row) => Workshop(
    id: row['id'].toString(),
    name: (row['name'] ?? '').toString(),
    city: (row['city'] ?? '').toString(),
    phone: (row['phone'] ?? '').toString(),
    rating: (row['rating'] as num?)?.toDouble() ?? 0,
  );

  RepairCase _caseFromRow(Map<String, dynamic> row) {
    final statusName = (row['status'] ?? 'newCase').toString();
    return RepairCase(
      id: row['id'].toString(),
      vehicleId: row['vehicle_id'].toString(),
      insuredUserId: row['insured_user_id'].toString(),
      claimNumber: (row['claim_number'] ?? '').toString(),
      description: (row['description'] ?? '').toString(),
      status: RepairCaseStatus.values.firstWhere(
        (status) => status.name == statusName,
        orElse: () => RepairCaseStatus.newCase,
      ),
      entryDate: DateTime.parse(row['entry_date'].toString()).toLocal(),
      estimatedDeliveryDate: row['estimated_delivery_date'] == null
          ? null
          : DateTime.parse(row['estimated_delivery_date'].toString()).toLocal(),
      progress: (row['progress'] as num?)?.toInt() ?? 0,
      workshopId: row['workshop_id']?.toString(),
      insurerCompany: (row['insurer_company'] ?? '').toString(),
      claimBranch: (row['claim_branch'] ?? '').toString(),
      claimType: (row['claim_type'] ?? '').toString(),
      fastTrack: row['fast_track'] == true,
      companyClaimNumber: (row['company_claim_number'] ?? '').toString(),
      insuredDni: (row['insured_dni'] ?? '').toString(),
      insuredPhone: (row['insured_phone'] ?? '').toString(),
      insuredEmail: (row['insured_email'] ?? '').toString(),
      driver: (row['driver'] ?? '').toString(),
      broker: (row['broker'] ?? '').toString(),
      pasName: (row['pas_name'] ?? '').toString(),
      incidentDate: row['incident_date'] == null ? null : DateTime.parse(row['incident_date'].toString()),
      incidentLocation: (row['incident_location'] ?? '').toString(),
      origin: (row['origin'] ?? '').toString(),
      jotformId: (row['jotform_id'] ?? '').toString(),
      attachmentFilename: (row['attachment_filename'] ?? '').toString(),
      responsible: (row['responsible'] ?? '').toString(),
      hasThirdParties: row['has_third_parties'] == true,
      registeredAt: row['registered_at'] == null ? null : DateTime.parse(row['registered_at'].toString()).toLocal(),
    );
  }

  Message _messageFromRow(Map<String, dynamic> row) => Message(
    id: row['id'].toString(),
    caseId: row['case_id'].toString(),
    senderId: row['sender_id'].toString(),
    senderName: (row['sender_name'] ?? '').toString(),
    text: (row['message_text'] ?? '').toString(),
    createdAt: DateTime.parse(row['created_at'].toString()).toLocal(),
  );

  List<RepairCase> get allCases => List.unmodifiable(repairCases);

  List<RepairCase> get casesForCurrentUser {
    final user = _currentUser;
    if (user == null) return const [];
    switch (user.role) {
      case UserRole.insured:
        return repairCases.where((item) => item.insuredUserId == user.id).toList();
      case UserRole.workshop:
        return repairCases.where((item) => item.workshopId == user.workshopId).toList();
      case UserRole.consultant:
        return List.unmodifiable(repairCases);
    }
  }

  User? getUserById(String id) {
    for (final user in users) { if (user.id == id) return user; }
    return null;
  }

  Vehicle? getVehicleById(String id) {
    for (final vehicle in vehicles) { if (vehicle.id == id) return vehicle; }
    return null;
  }

  Workshop? getWorkshopById(String id) {
    for (final workshop in workshops) { if (workshop.id == id) return workshop; }
    return null;
  }

  RepairCase? getCaseById(String id) {
    for (final item in repairCases) { if (item.id == id) return item; }
    return null;
  }

  List<Message> messagesForCase(String caseId) => messages
      .where((message) => message.caseId == caseId)
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  Future<void> logout() async {
    await SupabaseConfig.client?.auth.signOut();
    _currentUser = null;
    users.clear();
    vehicles.clear();
    workshops.clear();
    repairCases.clear();
    messages.clear();
    notifyListeners();
  }

  Future<void> createCase({
    required String insuredUserId,
    required String vehicleId,
    required String claimNumber,
    required String description,
    String? workshopId,
  }) async {
    await _client.from('repair_cases').insert({
      'vehicle_id': vehicleId,
      'insured_user_id': insuredUserId,
      'claim_number': claimNumber,
      'description': description,
      'status': workshopId == null ? RepairCaseStatus.newCase.name : RepairCaseStatus.workshopAssigned.name,
      'entry_date': DateTime.now().toUtc().toIso8601String(),
      'estimated_delivery_date': DateTime.now().add(const Duration(days: 12)).toUtc().toIso8601String(),
      'progress': 0,
      'workshop_id': workshopId,
    });
    await refreshData();
  }

  Future<void> assignWorkshop(String caseId, String workshopId) async {
    await _client.from('repair_cases').update({
      'workshop_id': workshopId,
      'status': RepairCaseStatus.workshopAssigned.name,
    }).eq('id', caseId);
    await refreshData();
  }

  Future<void> updateProgress(String caseId, int progress) async {
    await _client.from('repair_cases').update({
      'progress': progress.clamp(0, 100),
    }).eq('id', caseId);
    await refreshData();
  }

  final Map<String, List<String>> _photosByCase = {};

  List<String> photosForCase(String caseId) =>
      List.unmodifiable(_photosByCase[caseId] ?? const <String>[]);

  Future<void> addPhotoToCase(String caseId, String photoPath) async {
    throw UnsupportedError(
      'La carga de fotos requiere integrar Storage y las políticas de acceso antes de habilitarla.',
    );
  }

  Future<void> removePhotoFromCase(String caseId, String photoPath) async {
    throw UnsupportedError(
      'La eliminación de fotos requiere integrar Storage y las políticas de acceso antes de habilitarla.',
    );
  }

  // Las mutaciones se habilitarán junto con sus políticas RLS específicas.
  Future<void> updateCaseStatus(String caseId, RepairCaseStatus status) async {
    await _client.from('repair_cases').update({'status': status.name}).eq('id', caseId);
    await refreshData();
  }

  Future<void> addMessage({
    required String caseId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    await _client.from('case_messages').insert({
      'case_id': caseId,
      'sender_id': senderId,
      'sender_name': senderName,
      'message_text': text.trim(),
    });
    await refreshData();
  }
}
