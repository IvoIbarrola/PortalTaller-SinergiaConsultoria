import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../data/demo_data.dart';
import '../data/supabase_config.dart';
import '../models/message.dart';
import '../models/repair_case.dart';
import '../models/user.dart';
import '../models/vehicle.dart';
import '../models/workshop.dart';

class AppState extends ChangeNotifier {
  static const String _demoStorageKey = 'portal_taller_demo_v1';
  static const String _themeModeKey = 'portal_taller_theme_mode';
  static const String _profilePreferencesKey =
      'portal_taller_profile_preferences_v1';

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
  Future<void>? _initialization;
  ThemeMode _themeMode = ThemeMode.light;
  final Map<String, List<String>> _photosByCase = {};
  final Map<String, Set<String>> _checklistByCase = {};
  final Map<String, Set<String>> _documentsByCase = {};
  final Map<String, List<String>> _activityByCase = {};

  User? get currentUser => _currentUser;
  ThemeMode get themeMode => _themeMode;
  bool get isLoggedIn => _currentUser != null;
  bool get isSupabaseConfigured => SupabaseConfig.client != null;
  bool get isDemoMode => !isSupabaseConfigured;

  SupabaseClient get _client {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw StateError(
        'Supabase no está configurado. Revisá SUPABASE_URL y SUPABASE_ANON_KEY.',
      );
    }
    return client;
  }

  Future<void> initialize() => _initialization ??= _initializeLocalData();

  Future<void> _initializeLocalData() async {
    final preferences = await SharedPreferences.getInstance();
    final themeModeName = preferences.getString(_themeModeKey);
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == themeModeName,
      orElse: () => ThemeMode.light,
    );
    if (!isDemoMode) return;

    final savedState = preferences.getString(_demoStorageKey);
    if (savedState == null) {
      _loadDemoSeed();
      await _persistDemoData();
      return;
    }

    final state = jsonDecode(savedState) as Map<String, dynamic>;
    final version = state['version'];
    if (version != 1 && version != 2) {
      throw StateError(
        'Los datos locales de demostración tienen una versión no compatible.',
      );
    }

    users
      ..clear()
      ..addAll(_decodeRows(state, 'users', _userFromRow));
    vehicles
      ..clear()
      ..addAll(_decodeRows(state, 'vehicles', _vehicleFromRow));
    workshops
      ..clear()
      ..addAll(_decodeRows(state, 'workshops', _workshopFromRow));
    repairCases
      ..clear()
      ..addAll(_decodeRows(state, 'cases', _caseFromRow));
    messages
      ..clear()
      ..addAll(_decodeRows(state, 'messages', _messageFromRow));
    _photosByCase.addAll(_decodeStringLists(state['photos']));
    _checklistByCase.addAll(_decodeStringSets(state['checklist']));
    _documentsByCase.addAll(_decodeStringSets(state['documents']));
    _activityByCase.addAll(_decodeStringLists(state['activity']));
    if (version == 1) {
      for (var index = 0; index < vehicles.length; index++) {
        final vehicle = vehicles[index];
        if (vehicle.insuredUserId.isEmpty &&
            getUserById('user-insured')?.role == UserRole.insured) {
          vehicles[index] = vehicle.copyWith(insuredUserId: 'user-insured');
        }
      }
      await _persistDemoData();
    }
  }

  List<T> _decodeRows<T>(
    Map<String, dynamic> state,
    String key,
    T Function(Map<String, dynamic>) decode,
  ) {
    final rows = state[key] as List<dynamic>;
    return rows
        .map((row) => decode(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Map<String, List<String>> _decodeStringLists(Object? value) {
    final rows = Map<String, dynamic>.from(value as Map);
    return rows.map(
      (key, value) => MapEntry(key, List<String>.from(value as List)),
    );
  }

  Map<String, Set<String>> _decodeStringSets(Object? value) {
    final rows = Map<String, dynamic>.from(value as Map);
    return rows.map(
      (key, value) => MapEntry(key, Set<String>.from(value as List)),
    );
  }

  void _loadDemoSeed() {
    users
      ..clear()
      ..addAll(DemoData.users);
    vehicles
      ..clear()
      ..addAll(DemoData.vehicles);
    workshops
      ..clear()
      ..addAll(DemoData.workshops);
    repairCases
      ..clear()
      ..addAll(DemoData.repairCases);
    messages
      ..clear()
      ..addAll(DemoData.messages);
  }

  Future<void> _persistDemoData() async {
    if (!isDemoMode) return;

    final state = <String, Object>{
      'version': 2,
      'users': users.map(_userToRow).toList(),
      'vehicles': vehicles.map(_vehicleToRow).toList(),
      'workshops': workshops.map(_workshopToRow).toList(),
      'cases': repairCases.map(_caseToRow).toList(),
      'messages': messages.map(_messageToRow).toList(),
      'photos': _photosByCase,
      'checklist': _checklistByCase.map(
        (key, value) => MapEntry(key, value.toList()),
      ),
      'documents': _documentsByCase.map(
        (key, value) => MapEntry(key, value.toList()),
      ),
      'activity': _activityByCase,
    };
    final saved = await (await SharedPreferences.getInstance()).setString(
      _demoStorageKey,
      jsonEncode(state),
    );
    if (!saved) {
      throw StateError(
        'No se pudieron guardar los cambios locales de la demo.',
      );
    }
  }

  Map<String, dynamic> _userToRow(User user) => {
    'id': user.id,
    'name': user.name,
    'role': user.role.name,
    'workshop_id': user.workshopId,
    'email': user.email,
    'phone': user.phone,
  };

  Map<String, dynamic> _vehicleToRow(Vehicle vehicle) => {
    'id': vehicle.id,
    'brand': vehicle.brand,
    'model': vehicle.model,
    'year': vehicle.year,
    'plate': vehicle.plate,
    'color': vehicle.color,
    'image_url': vehicle.imageUrl,
    'insured_user_id': vehicle.insuredUserId,
    'vehicle_type': vehicle.vehicleType,
    'trim': vehicle.trim,
    'vin': vehicle.vin,
    'mileage': vehicle.mileage,
    'notes': vehicle.notes,
  };

  Map<String, dynamic> _workshopToRow(Workshop workshop) => {
    'id': workshop.id,
    'name': workshop.name,
    'city': workshop.city,
    'phone': workshop.phone,
    'rating': workshop.rating,
    'address': workshop.address,
    'contact_name': workshop.contactName,
    'specialties': workshop.specialties,
    'is_active': workshop.isActive,
  };

  Map<String, dynamic> _caseToRow(RepairCase item) => {
    'id': item.id,
    'vehicle_id': item.vehicleId,
    'insured_user_id': item.insuredUserId,
    'claim_number': item.claimNumber,
    'description': item.description,
    'status': item.status.name,
    'entry_date': item.entryDate.toIso8601String(),
    'estimated_delivery_date': item.estimatedDeliveryDate?.toIso8601String(),
    'progress': item.progress,
    'workshop_id': item.workshopId,
    'insurer_company': item.insurerCompany,
    'claim_branch': item.claimBranch,
    'claim_type': item.claimType,
    'fast_track': item.fastTrack,
    'company_claim_number': item.companyClaimNumber,
    'insured_dni': item.insuredDni,
    'insured_phone': item.insuredPhone,
    'insured_email': item.insuredEmail,
    'driver': item.driver,
    'broker': item.broker,
    'pas_name': item.pasName,
    'incident_date': item.incidentDate?.toIso8601String(),
    'incident_location': item.incidentLocation,
    'origin': item.origin,
    'jotform_id': item.jotformId,
    'attachment_filename': item.attachmentFilename,
    'responsible': item.responsible,
    'has_third_parties': item.hasThirdParties,
    'registered_at': item.registeredAt?.toIso8601String(),
  };

  Map<String, dynamic> _messageToRow(Message message) => {
    'id': message.id,
    'case_id': message.caseId,
    'sender_id': message.senderId,
    'sender_name': message.senderName,
    'message_text': message.text,
    'created_at': message.createdAt.toIso8601String(),
  };

  Future<User?> signInDemo(UserRole role, {String? userId}) async {
    await initialize();
    final matches = users.where(
      (item) => item.role == role && (userId == null || item.id == userId),
    );
    if (matches.isEmpty) {
      throw StateError('No hay un usuario de demostración para ${role.label}.');
    }
    final user = await _withProfilePreferences(matches.first);
    final userIndex = users.indexWhere((item) => item.id == user.id);
    if (userIndex >= 0) users[userIndex] = user;
    _currentUser = user;
    notifyListeners();
    return user;
  }

  Future<void> resetDemoData() async {
    if (!isDemoMode) {
      throw StateError(
        'El reinicio de datos solo está disponible en modo demo local.',
      );
    }
    await initialize();
    for (final path in _photosByCase.values.expand((paths) => paths)) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    _loadDemoSeed();
    _photosByCase.clear();
    _checklistByCase.clear();
    _documentsByCase.clear();
    _activityByCase.clear();
    await _persistDemoData();
    notifyListeners();
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
      if (authUser == null) {
        throw const AuthException('No se pudo iniciar sesión.');
      }

      final profile = await _client
          .from('profiles')
          .select()
          .eq('auth_user_id', authUser.id)
          .maybeSingle();
      if (profile == null) {
        await _client.auth.signOut();
        throw const AuthException(
          'La cuenta no está vinculada a un perfil de Portal Taller.',
        );
      }

      final user = _userFromRow(profile);
      final personalizedUser = await _withProfilePreferences(user);
      _currentUser = personalizedUser;
      users
        ..clear()
        ..add(personalizedUser);
      await refreshData();
      return personalizedUser;
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
    if (isDemoMode) {
      await initialize();
      notifyListeners();
      return;
    }
    lastError = null;
    try {
      final caseRows = await _client
          .from('repair_cases')
          .select()
          .order('entry_date', ascending: false);
      final vehicleRows = await _client.from('vehicles').select();
      final workshopRows = await _client.from('workshops').select();
      final profileRows = await _client.from('profiles').select();
      final messageRows = await _client
          .from('case_messages')
          .select()
          .order('created_at');

      repairCases
        ..clear()
        ..addAll(
          (caseRows as List).map(
            (row) => _caseFromRow(Map<String, dynamic>.from(row)),
          ),
        );
      vehicles
        ..clear()
        ..addAll(
          (vehicleRows as List).map(
            (row) => _vehicleFromRow(Map<String, dynamic>.from(row)),
          ),
        );
      workshops
        ..clear()
        ..addAll(
          (workshopRows as List).map(
            (row) => _workshopFromRow(Map<String, dynamic>.from(row)),
          ),
        );
      users
        ..clear()
        ..addAll(
          (profileRows as List).map(
            (row) => _userFromRow(Map<String, dynamic>.from(row)),
          ),
        );
      messages
        ..clear()
        ..addAll(
          (messageRows as List).map(
            (row) => _messageFromRow(Map<String, dynamic>.from(row)),
          ),
        );
      if (_currentUser != null) {
        final currentIndex = users.indexWhere(
          (user) => user.id == _currentUser!.id,
        );
        if (currentIndex >= 0) {
          final personalizedUser = await _withProfilePreferences(
            users[currentIndex],
          );
          users[currentIndex] = personalizedUser;
          _currentUser = personalizedUser;
        }
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
    email: (row['email'] ?? '').toString(),
    phone: (row['phone'] ?? '').toString(),
  );

  Future<User> _withProfilePreferences(User user) async {
    final preferences = await SharedPreferences.getInstance();
    final savedProfiles = preferences.getString(_profilePreferencesKey);
    if (savedProfiles == null) return user;
    final profiles = Map<String, dynamic>.from(
      jsonDecode(savedProfiles) as Map,
    );
    final profile = profiles[user.id];
    if (profile is! Map) return user;
    final values = Map<String, dynamic>.from(profile);
    return user.copyWith(
      name: (values['name'] ?? user.name).toString(),
      email: (values['email'] ?? user.email).toString(),
      phone: (values['phone'] ?? user.phone).toString(),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final saved = await (await SharedPreferences.getInstance()).setString(
      _themeModeKey,
      mode.name,
    );
    if (!saved) {
      throw StateError('No se pudo guardar la preferencia de apariencia.');
    }
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> updateCurrentUserProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Iniciá sesión para editar tu perfil.');
    }
    final updatedUser = user.copyWith(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
    );
    final preferences = await SharedPreferences.getInstance();
    final savedProfiles = preferences.getString(_profilePreferencesKey);
    final profiles = savedProfiles == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(savedProfiles) as Map);
    profiles[user.id] = {
      'name': updatedUser.name,
      'email': updatedUser.email,
      'phone': updatedUser.phone,
    };
    final saved = await preferences.setString(
      _profilePreferencesKey,
      jsonEncode(profiles),
    );
    if (!saved) {
      throw StateError('No se pudo guardar la personalización del perfil.');
    }
    final userIndex = users.indexWhere((item) => item.id == user.id);
    if (userIndex >= 0) users[userIndex] = updatedUser;
    _currentUser = updatedUser;
    if (isDemoMode) await _persistDemoData();
    notifyListeners();
  }

  Vehicle _vehicleFromRow(Map<String, dynamic> row) => Vehicle(
    id: row['id'].toString(),
    brand: (row['brand'] ?? '').toString(),
    model: (row['model'] ?? '').toString(),
    year: (row['year'] as num?)?.toInt() ?? 0,
    plate: (row['plate'] ?? '').toString(),
    color: (row['color'] ?? '').toString(),
    imageUrl: (row['image_url'] ?? '').toString(),
    insuredUserId: (row['insured_user_id'] ?? '').toString(),
    vehicleType: (row['vehicle_type'] ?? '').toString(),
    trim: (row['trim'] ?? '').toString(),
    vin: (row['vin'] ?? '').toString(),
    mileage: (row['mileage'] as num?)?.toInt(),
    notes: (row['notes'] ?? '').toString(),
  );

  Workshop _workshopFromRow(Map<String, dynamic> row) => Workshop(
    id: row['id'].toString(),
    name: (row['name'] ?? '').toString(),
    city: (row['city'] ?? '').toString(),
    phone: (row['phone'] ?? '').toString(),
    rating: (row['rating'] as num?)?.toDouble() ?? 0,
    address: (row['address'] ?? '').toString(),
    contactName: (row['contact_name'] ?? '').toString(),
    specialties: List<String>.from(row['specialties'] as List? ?? const []),
    isActive: row['is_active'] != false,
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
      incidentDate: row['incident_date'] == null
          ? null
          : DateTime.parse(row['incident_date'].toString()),
      incidentLocation: (row['incident_location'] ?? '').toString(),
      origin: (row['origin'] ?? '').toString(),
      jotformId: (row['jotform_id'] ?? '').toString(),
      attachmentFilename: (row['attachment_filename'] ?? '').toString(),
      responsible: (row['responsible'] ?? '').toString(),
      hasThirdParties: row['has_third_parties'] == true,
      registeredAt: row['registered_at'] == null
          ? null
          : DateTime.parse(row['registered_at'].toString()).toLocal(),
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
        return repairCases
            .where((item) => item.insuredUserId == user.id)
            .toList();
      case UserRole.workshop:
        return repairCases
            .where((item) => item.workshopId == user.workshopId)
            .toList();
      case UserRole.consultant:
        return List.unmodifiable(repairCases);
    }
  }

  User? getUserById(String id) {
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }

  Vehicle? getVehicleById(String id) {
    for (final vehicle in vehicles) {
      if (vehicle.id == id) return vehicle;
    }
    return null;
  }

  Workshop? getWorkshopById(String id) {
    for (final workshop in workshops) {
      if (workshop.id == id) return workshop;
    }
    return null;
  }

  List<Workshop> get activeWorkshops =>
      workshops.where((workshop) => workshop.isActive).toList();

  RepairCase? getCaseById(String id) {
    for (final item in repairCases) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> createVehicle({
    required String brand,
    required String model,
    required int year,
    required String plate,
    required String insuredUserId,
    String color = '',
    String vehicleType = '',
    String trim = '',
    String vin = '',
    int? mileage,
    String notes = '',
  }) async {
    _requireLocalAdministration();
    await initialize();
    final normalizedPlate = _validateVehicle(
      brand: brand,
      model: model,
      year: year,
      plate: plate,
      insuredUserId: insuredUserId,
      mileage: mileage,
    );
    if (vehicles.any(
      (item) => _normalizePlate(item.plate) == normalizedPlate,
    )) {
      throw StateError('Ya existe un vehículo registrado con esa patente.');
    }

    vehicles.add(
      Vehicle(
        id: _newId('vehicle', vehicles.map((item) => item.id)),
        brand: brand.trim(),
        model: model.trim(),
        year: year,
        plate: plate.trim().toUpperCase(),
        color: color.trim(),
        imageUrl: '',
        insuredUserId: insuredUserId,
        vehicleType: vehicleType.trim(),
        trim: trim.trim(),
        vin: vin.trim().toUpperCase(),
        mileage: mileage,
        notes: notes.trim(),
      ),
    );
    await _persistDemoData();
    notifyListeners();
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    _requireLocalAdministration();
    await initialize();
    final index = vehicles.indexWhere((item) => item.id == vehicle.id);
    if (index < 0) throw StateError('No se encontró el vehículo.');
    if (vehicles[index].insuredUserId != vehicle.insuredUserId &&
        repairCases.any((item) => item.vehicleId == vehicle.id)) {
      throw StateError(
        'No se puede cambiar el asegurado porque el vehículo ya tiene casos asociados.',
      );
    }

    final normalizedPlate = _validateVehicle(
      brand: vehicle.brand,
      model: vehicle.model,
      year: vehicle.year,
      plate: vehicle.plate,
      insuredUserId: vehicle.insuredUserId,
      mileage: vehicle.mileage,
    );
    if (vehicles.any(
      (item) =>
          item.id != vehicle.id &&
          _normalizePlate(item.plate) == normalizedPlate,
    )) {
      throw StateError('Ya existe un vehículo registrado con esa patente.');
    }

    vehicles[index] = vehicle.copyWith(
      brand: vehicle.brand.trim(),
      model: vehicle.model.trim(),
      plate: vehicle.plate.trim().toUpperCase(),
      color: vehicle.color.trim(),
      vehicleType: vehicle.vehicleType.trim(),
      trim: vehicle.trim.trim(),
      vin: vehicle.vin.trim().toUpperCase(),
      notes: vehicle.notes.trim(),
    );
    await _persistDemoData();
    notifyListeners();
  }

  Future<void> createWorkshop({
    required String name,
    required String city,
    required String phone,
    required double rating,
    String address = '',
    String contactName = '',
    List<String> specialties = const [],
  }) async {
    _requireLocalAdministration();
    await initialize();
    _validateWorkshop(name: name, city: city, rating: rating);
    final id = _newId('workshop', workshops.map((item) => item.id));
    final workshop = Workshop(
      id: id,
      name: name.trim(),
      city: city.trim(),
      phone: phone.trim(),
      rating: rating,
      address: address.trim(),
      contactName: contactName.trim(),
      specialties: _cleanSpecialties(specialties),
    );
    workshops.add(workshop);
    users.add(
      User(
        id: '$id-user',
        name: workshop.name,
        role: UserRole.workshop,
        workshopId: id,
      ),
    );
    await _persistDemoData();
    notifyListeners();
  }

  Future<void> updateWorkshop(Workshop workshop) async {
    _requireLocalAdministration();
    await initialize();
    final index = workshops.indexWhere((item) => item.id == workshop.id);
    if (index < 0) throw StateError('No se encontró el taller.');
    _validateWorkshop(
      name: workshop.name,
      city: workshop.city,
      rating: workshop.rating,
    );
    final updated = workshop.copyWith(
      name: workshop.name.trim(),
      city: workshop.city.trim(),
      phone: workshop.phone.trim(),
      address: workshop.address.trim(),
      contactName: workshop.contactName.trim(),
      specialties: _cleanSpecialties(workshop.specialties),
    );
    workshops[index] = updated;
    final userIndex = users.indexWhere(
      (user) =>
          user.role == UserRole.workshop && user.workshopId == workshop.id,
    );
    if (userIndex >= 0) {
      users[userIndex] = User(
        id: users[userIndex].id,
        name: updated.name,
        role: UserRole.workshop,
        workshopId: updated.id,
      );
    }
    await _persistDemoData();
    notifyListeners();
  }

  Future<void> setWorkshopActive(String workshopId, bool isActive) async {
    _requireLocalAdministration();
    await initialize();
    final index = workshops.indexWhere((item) => item.id == workshopId);
    if (index < 0) throw StateError('No se encontró el taller.');
    workshops[index] = workshops[index].copyWith(isActive: isActive);
    await _persistDemoData();
    notifyListeners();
  }

  void _requireLocalAdministration() {
    if (!isDemoMode) {
      throw UnsupportedError(
        'La administración local está disponible solo en modo demo.',
      );
    }
  }

  String _validateVehicle({
    required String brand,
    required String model,
    required int year,
    required String plate,
    required String insuredUserId,
    required int? mileage,
  }) {
    if (brand.trim().isEmpty || model.trim().isEmpty || plate.trim().isEmpty) {
      throw StateError('Completá marca, modelo y patente.');
    }
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 1) {
      throw StateError('Ingresá un año entre 1900 y ${currentYear + 1}.');
    }
    if (mileage != null && mileage < 0) {
      throw StateError('El kilometraje no puede ser negativo.');
    }
    if (getUserById(insuredUserId)?.role != UserRole.insured) {
      throw StateError('Seleccioná un asegurado válido para el vehículo.');
    }
    final normalizedPlate = _normalizePlate(plate);
    if (normalizedPlate.isEmpty) {
      throw StateError('Ingresá una patente válida.');
    }
    return normalizedPlate;
  }

  String _normalizePlate(String plate) =>
      plate.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  void _validateWorkshop({
    required String name,
    required String city,
    required double rating,
  }) {
    if (name.trim().isEmpty || city.trim().isEmpty) {
      throw StateError('Completá el nombre y la ciudad del taller.');
    }
    if (!rating.isFinite || rating < 0 || rating > 5) {
      throw StateError('La calificación debe estar entre 0 y 5.');
    }
  }

  List<String> _cleanSpecialties(Iterable<String> values) => values
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList();

  String _newId(String prefix, Iterable<String> existingIds) {
    final ids = existingIds.toSet();
    var suffix = DateTime.now().microsecondsSinceEpoch;
    var id = '$prefix-$suffix';
    while (ids.contains(id)) {
      id = '$prefix-${++suffix}';
    }
    return id;
  }

  List<Message> messagesForCase(String caseId) =>
      messages.where((message) => message.caseId == caseId).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  bool isChecklistCompleted(String caseId, String task) =>
      _checklistByCase[caseId]?.contains(task) ?? false;

  Future<void> setChecklistCompleted(
    String caseId,
    String task,
    bool completed,
  ) async {
    final items = _checklistByCase.putIfAbsent(caseId, () => <String>{});
    if (completed) {
      items.add(task);
    } else {
      items.remove(task);
    }
    await _persistDemoData();
    notifyListeners();
  }

  bool isDocumentReceived(String caseId, String document) =>
      _documentsByCase[caseId]?.contains(document) ?? false;

  Future<void> setDocumentReceived(
    String caseId,
    String document,
    bool received,
  ) async {
    final items = _documentsByCase.putIfAbsent(caseId, () => <String>{});
    if (received) {
      items.add(document);
    } else {
      items.remove(document);
    }
    await _persistDemoData();
    notifyListeners();
  }

  List<String> activityForCase(String caseId) =>
      List.unmodifiable(_activityByCase[caseId] ?? const <String>[]);

  Future<void> addCaseActivity(String caseId, String note) async {
    final value = note.trim();
    if (value.isEmpty) return;
    _activityByCase.putIfAbsent(caseId, () => <String>[]).insert(0, value);
    await _persistDemoData();
    notifyListeners();
  }

  Future<void> logout() async {
    await SupabaseConfig.client?.auth.signOut();
    _currentUser = null;
    if (!isDemoMode) {
      users.clear();
      vehicles.clear();
      workshops.clear();
      repairCases.clear();
      messages.clear();
    }
    notifyListeners();
  }

  Future<void> createCase({
    required String insuredUserId,
    required String vehicleId,
    required String claimNumber,
    required String description,
    String? workshopId,
  }) async {
    if (isDemoMode) {
      await initialize();
      if (getUserById(insuredUserId)?.role != UserRole.insured) {
        throw StateError('Seleccioná un asegurado válido para el nuevo caso.');
      }
      if (getVehicleById(vehicleId) == null) {
        throw StateError('Seleccioná un vehículo válido para el nuevo caso.');
      }
      final vehicle = getVehicleById(vehicleId)!;
      if (vehicle.insuredUserId.isNotEmpty &&
          vehicle.insuredUserId != insuredUserId) {
        throw StateError('El vehículo no pertenece al asegurado seleccionado.');
      }
      if (workshopId != null && getWorkshopById(workshopId)?.isActive != true) {
        throw StateError('El taller seleccionado no existe.');
      }
      final now = DateTime.now();
      repairCases.insert(
        0,
        RepairCase(
          id: 'case-${now.microsecondsSinceEpoch}',
          vehicleId: vehicleId,
          insuredUserId: insuredUserId,
          claimNumber: claimNumber,
          description: description,
          status: workshopId == null
              ? RepairCaseStatus.newCase
              : RepairCaseStatus.workshopAssigned,
          entryDate: now,
          estimatedDeliveryDate: now.add(const Duration(days: 12)),
          progress: 0,
          workshopId: workshopId,
          origin: 'Demo local',
          registeredAt: now,
        ),
      );
      await _persistDemoData();
      notifyListeners();
      return;
    }

    await _client.from('repair_cases').insert({
      'vehicle_id': vehicleId,
      'insured_user_id': insuredUserId,
      'claim_number': claimNumber,
      'description': description,
      'status': workshopId == null
          ? RepairCaseStatus.newCase.name
          : RepairCaseStatus.workshopAssigned.name,
      'entry_date': DateTime.now().toUtc().toIso8601String(),
      'estimated_delivery_date': DateTime.now()
          .add(const Duration(days: 12))
          .toUtc()
          .toIso8601String(),
      'progress': 0,
      'workshop_id': workshopId,
    });
    await refreshData();
  }

  Future<void> assignWorkshop(String caseId, String workshopId) async {
    if (isDemoMode) {
      await initialize();
      final caseIndex = repairCases.indexWhere((item) => item.id == caseId);
      if (caseIndex < 0 || getWorkshopById(workshopId)?.isActive != true) {
        throw StateError('No se pudo asignar el taller al caso.');
      }
      repairCases[caseIndex] = repairCases[caseIndex].copyWith(
        workshopId: workshopId,
        status: RepairCaseStatus.workshopAssigned,
      );
      await _persistDemoData();
      notifyListeners();
      return;
    }

    await _client
        .from('repair_cases')
        .update({
          'workshop_id': workshopId,
          'status': RepairCaseStatus.workshopAssigned.name,
        })
        .eq('id', caseId);
    await refreshData();
  }

  Future<void> updateProgress(String caseId, int progress) async {
    if (isDemoMode) {
      await initialize();
      final caseIndex = repairCases.indexWhere((item) => item.id == caseId);
      if (caseIndex < 0) {
        throw StateError('No se encontró el caso seleccionado.');
      }
      repairCases[caseIndex] = repairCases[caseIndex].copyWith(
        progress: progress.clamp(0, 100).toInt(),
      );
      await _persistDemoData();
      notifyListeners();
      return;
    }

    await _client
        .from('repair_cases')
        .update({'progress': progress.clamp(0, 100)})
        .eq('id', caseId);
    await refreshData();
  }

  List<String> photosForCase(String caseId) =>
      List.unmodifiable(_photosByCase[caseId] ?? const <String>[]);

  Future<void> addPhotoToCase(String caseId, String photoPath) async {
    if (!isDemoMode) {
      throw UnsupportedError(
        'La carga de fotos en Supabase requiere integrar Storage y sus políticas de acceso.',
      );
    }
    await initialize();
    final source = File(photoPath);
    if (!await source.exists()) {
      throw FileSystemException(
        'No se encontró la fotografía seleccionada.',
        photoPath,
      );
    }
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final photosDirectory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}case_photos',
    );
    await photosDirectory.create(recursive: true);
    final extension = photoPath.contains('.')
        ? photoPath.substring(photoPath.lastIndexOf('.'))
        : '.jpg';
    final persistedPath =
        '${photosDirectory.path}${Platform.pathSeparator}$caseId-${DateTime.now().microsecondsSinceEpoch}$extension';
    await source.copy(persistedPath);
    _photosByCase.putIfAbsent(caseId, () => <String>[]).add(persistedPath);
    await _persistDemoData();
    notifyListeners();
  }

  Future<void> removePhotoFromCase(String caseId, String photoPath) async {
    if (!isDemoMode) {
      throw UnsupportedError(
        'La eliminación de fotos en Supabase requiere integrar Storage y sus políticas de acceso.',
      );
    }
    final photos = _photosByCase[caseId];
    if (photos == null || !photos.contains(photoPath)) return;
    final photo = File(photoPath);
    if (await photo.exists()) await photo.delete();
    photos.remove(photoPath);
    await _persistDemoData();
    notifyListeners();
  }

  Future<void> updateCaseStatus(String caseId, RepairCaseStatus status) async {
    if (isDemoMode) {
      await initialize();
      final caseIndex = repairCases.indexWhere((item) => item.id == caseId);
      if (caseIndex < 0) {
        throw StateError('No se encontró el caso seleccionado.');
      }
      repairCases[caseIndex] = repairCases[caseIndex].copyWith(status: status);
      await _persistDemoData();
      notifyListeners();
      return;
    }

    await _client
        .from('repair_cases')
        .update({'status': status.name})
        .eq('id', caseId);
    await refreshData();
  }

  Future<void> addMessage({
    required String caseId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    if (isDemoMode) {
      await initialize();
      if (getCaseById(caseId) == null) {
        throw StateError('No se encontró el caso para enviar el mensaje.');
      }
      messages.add(
        Message(
          id: 'msg-${DateTime.now().microsecondsSinceEpoch}',
          caseId: caseId,
          senderId: senderId,
          senderName: senderName,
          text: text.trim(),
          createdAt: DateTime.now(),
        ),
      );
      await _persistDemoData();
      notifyListeners();
      return;
    }

    await _client.from('case_messages').insert({
      'case_id': caseId,
      'sender_id': senderId,
      'sender_name': senderName,
      'message_text': text.trim(),
    });
    await refreshData();
  }
}
