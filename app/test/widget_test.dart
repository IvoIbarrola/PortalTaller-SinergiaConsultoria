import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:workspace/data/demo_data.dart';
import 'package:workspace/main.dart';
import 'package:workspace/models/repair_case.dart';
import 'package:workspace/models/user.dart';
import 'package:workspace/models/vehicle.dart';
import 'package:workspace/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({
    'portal_taller_demo_v1': jsonEncode(_legacyDemoState()),
  });

  testWidgets('local demo supports role access and persists case changes', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = AppState();
    await appState.initialize();
    final preferences = await SharedPreferences.getInstance();
    final migratedState = jsonDecode(
      preferences.getString('portal_taller_demo_v1')!,
    ) as Map<String, dynamic>;
    expect(migratedState['version'], 2);
    expect(
      (migratedState['vehicles'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .first['insured_user_id'],
      'user-insured',
    );
    expect(
      (migratedState['workshops'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .first['is_active'],
      isTrue,
    );
    await tester.pumpWidget(const MyApp());

    expect(find.text('Portal Taller'), findsOneWidget);
    expect(find.text('DEMO LOCAL · DATOS FICTICIOS'), findsOneWidget);
    expect(find.text('Entrar como asegurado'), findsOneWidget);
    expect(find.text('Entrar como Taller Norte'), findsOneWidget);
    expect(find.text('Entrar como Taller Central'), findsOneWidget);
    expect(find.text('Entrar como consultoría'), findsOneWidget);

    final consultantEntry = find.text('Entrar como consultoría');
    await tester.ensureVisible(consultantEntry);
    await tester.tap(consultantEntry);
    await tester.pumpAndSettle();
    expect(find.text('Seguimiento de siniestros'), findsOneWidget);
    expect(find.text('3 casos en la red'), findsOneWidget);

    await tester.tap(find.byTooltip('Configuración'));
    await tester.pumpAndSettle();
    expect(find.text('Mi perfil'), findsOneWidget);
    await tester.tap(find.text('Tema oscuro'));
    await tester.pumpAndSettle();
    expect(appState.themeMode, ThemeMode.dark);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre visible *'),
      'Consultoría Demo',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email de contacto'),
      'consultoria@example.com',
    );
    await tester.dragUntilVisible(
      find.text('Guardar perfil'),
      find.byType(ListView),
      const Offset(0, -250),
    );
    await tester.tap(find.text('Guardar perfil'));
    await tester.pumpAndSettle();
    expect(appState.currentUser?.name, 'Consultoría Demo');
    expect(appState.currentUser?.email, 'consultoria@example.com');
    final settings = await SharedPreferences.getInstance();
    expect(settings.getString('portal_taller_theme_mode'), 'dark');
    expect(
      settings.getString('portal_taller_profile_preferences_v1'),
      contains('Consultoría Demo'),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Configuración'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reportar un error'));
    await tester.pumpAndSettle();
    expect(find.text('Preparar reporte por email'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    final statisticsButton = find.text('Estadísticas');
    await tester.ensureVisible(statisticsButton);
    await tester.tap(statisticsButton);
    await tester.pumpAndSettle();
    expect(find.text('Casos por estado'), findsOneWidget);
    expect(find.text('Buscar siniestro, patente o asegurado'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await appState.createVehicle(
      brand: 'Chevrolet',
      model: 'Onix',
      year: 2024,
      plate: 'AE 010 AA',
      insuredUserId: 'user-insured',
      color: 'Negro',
      vehicleType: 'Hatchback',
      trim: 'LTZ',
      vin: '9BGKS48V0RG123456',
      mileage: 12000,
      notes: 'Vehículo de presentación',
    );
    final createdVehicle = appState.vehicles.last;
    expect(createdVehicle.vehicleType, 'Hatchback');
    expect(createdVehicle.mileage, 12000);
    await expectLater(
      appState.createVehicle(
        brand: 'Otra',
        model: 'Unidad',
        year: 2024,
        plate: 'AE010AA',
        insuredUserId: 'user-insured',
      ),
      throwsA(isA<StateError>()),
    );
    await appState.updateVehicle(
      Vehicle(
        id: createdVehicle.id,
        brand: createdVehicle.brand,
        model: createdVehicle.model,
        year: createdVehicle.year,
        plate: createdVehicle.plate,
        color: createdVehicle.color,
        imageUrl: createdVehicle.imageUrl,
        insuredUserId: createdVehicle.insuredUserId,
        vehicleType: createdVehicle.vehicleType,
        trim: createdVehicle.trim,
        vin: createdVehicle.vin,
        mileage: null,
        notes: 'Datos actualizados',
      ),
    );
    expect(appState.getVehicleById(createdVehicle.id)?.mileage, isNull);

    await appState.createWorkshop(
      name: 'Taller Demo Sur',
      city: 'Mendoza',
      phone: '+54 261 555 0103',
      address: 'San Martín 1200',
      contactName: 'Ana Demo',
      rating: 4.4,
      specialties: ['Chapa y pintura', ' Mecánica '],
    );
    final createdWorkshop = appState.workshops.last;
    final createdWorkshopUser = appState.getUserById(
      '${createdWorkshop.id}-user',
    );
    expect(createdWorkshopUser?.workshopId, createdWorkshop.id);
    expect(createdWorkshop.specialties, ['Chapa y pintura', 'Mecánica']);
    await appState.setWorkshopActive(createdWorkshop.id, false);
    expect(
      appState.activeWorkshops.any((item) => item.id == createdWorkshop.id),
      isFalse,
    );
    await appState.setWorkshopActive(createdWorkshop.id, true);

    await appState.createCase(
      insuredUserId: 'user-insured',
      vehicleId: createdVehicle.id,
      claimNumber: 'DEMO-LOCAL-001',
      description: 'Caso agregado durante la presentación.',
      workshopId: createdWorkshop.id,
    );
    await appState.updateProgress('case-1', 72);
    await appState.updateCaseStatus('case-1', RepairCaseStatus.qualityControl);
    await appState.addMessage(
      caseId: 'case-1',
      senderId: 'user-consultant',
      senderName: 'Sinergia Consultoría',
      text: 'Actualización de demostración.',
    );
    await appState.setChecklistCompleted(
      'case-1',
      'Contactar al asegurado',
      true,
    );
    await appState.addCaseActivity('case-1', 'Seguimiento de llamada de demo');

    final savedState = jsonDecode(
      preferences.getString('portal_taller_demo_v1')!,
    ) as Map<String, dynamic>;
    expect(savedState['version'], 2);
    final savedCase = (savedState['cases'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .firstWhere((item) => item['id'] == 'case-1');

    expect(savedCase['progress'], 72);
    expect(savedCase['status'], RepairCaseStatus.qualityControl.name);
    final savedVehicle = (savedState['vehicles'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .firstWhere((item) => item['id'] == createdVehicle.id);
    expect(savedVehicle['vin'], '9BGKS48V0RG123456');
    expect(savedVehicle['mileage'], isNull);
    expect(
      (savedState['workshops'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .any(
            (item) =>
                item['id'] == createdWorkshop.id &&
                item['address'] == 'San Martín 1200' &&
                item['is_active'] == true,
          ),
      isTrue,
    );
    expect(
      (savedState['cases'] as List<dynamic>).cast<Map<String, dynamic>>().any(
        (item) => item['claim_number'] == 'DEMO-LOCAL-001',
      ),
      isTrue,
    );
    expect(
      (savedState['messages'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .any(
            (item) => item['message_text'] == 'Actualización de demostración.',
          ),
      isTrue,
    );
    expect(
      (savedState['checklist'] as Map<String, dynamic>)['case-1'],
      contains('Contactar al asegurado'),
    );
    expect(
      (savedState['activity'] as Map<String, dynamic>)['case-1'],
      contains('Seguimiento de llamada de demo'),
    );

    await appState.logout();
    final workshop = await appState.signInDemo(UserRole.workshop);
    expect(workshop?.id, 'workshop-1-user');
    expect(appState.casesForCurrentUser, hasLength(1));

    await appState.logout();
    final secondWorkshop = await appState.signInDemo(
      UserRole.workshop,
      userId: 'workshop-2-user',
    );
    expect(secondWorkshop?.id, 'workshop-2-user');
    expect(appState.casesForCurrentUser, hasLength(1));

    await appState.logout();
    final newWorkshopUser = await appState.signInDemo(
      UserRole.workshop,
      userId: '${createdWorkshop.id}-user',
    );
    expect(newWorkshopUser?.name, 'Taller Demo Sur');
    expect(appState.casesForCurrentUser, hasLength(1));

    await appState.logout();
    final insured = await appState.signInDemo(UserRole.insured);
    expect(insured?.id, 'user-insured');
    expect(appState.casesForCurrentUser, hasLength(4));

    await appState.resetDemoData();
    await appState.logout();
    final consultant = await appState.signInDemo(UserRole.consultant);
    expect(consultant?.name, 'Consultoría Demo');
    expect(appState.themeMode, ThemeMode.dark);
  });
}

Map<String, Object?> _legacyDemoState() => {
  'version': 1,
  'users': DemoData.users
      .map(
        (user) => {
          'id': user.id,
          'name': user.name,
          'role': user.role.name,
          'workshop_id': user.workshopId,
        },
      )
      .toList(),
  'vehicles': DemoData.vehicles
      .map(
        (vehicle) => {
          'id': vehicle.id,
          'brand': vehicle.brand,
          'model': vehicle.model,
          'year': vehicle.year,
          'plate': vehicle.plate,
          'color': vehicle.color,
          'image_url': vehicle.imageUrl,
        },
      )
      .toList(),
  'workshops': DemoData.workshops
      .map(
        (workshop) => {
          'id': workshop.id,
          'name': workshop.name,
          'city': workshop.city,
          'phone': workshop.phone,
          'rating': workshop.rating,
        },
      )
      .toList(),
  'cases': DemoData.repairCases
      .map(
        (item) => {
          'id': item.id,
          'vehicle_id': item.vehicleId,
          'insured_user_id': item.insuredUserId,
          'claim_number': item.claimNumber,
          'description': item.description,
          'status': item.status.name,
          'entry_date': item.entryDate.toIso8601String(),
          'estimated_delivery_date': item.estimatedDeliveryDate
              ?.toIso8601String(),
          'progress': item.progress,
          'workshop_id': item.workshopId,
        },
      )
      .toList(),
  'messages': DemoData.messages
      .map(
        (message) => {
          'id': message.id,
          'case_id': message.caseId,
          'sender_id': message.senderId,
          'sender_name': message.senderName,
          'message_text': message.text,
          'created_at': message.createdAt.toIso8601String(),
        },
      )
      .toList(),
  'photos': <String, Object>{},
  'checklist': <String, Object>{},
  'documents': <String, Object>{},
  'activity': <String, Object>{},
};
