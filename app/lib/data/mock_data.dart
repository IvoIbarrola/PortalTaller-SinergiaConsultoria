import '../models/message.dart';
import '../models/repair_case.dart';
import '../models/user.dart';
import '../models/vehicle.dart';
import '../models/workshop.dart';

const List<User> mockUsers = [
  User(id: 'insured-demo-1', name: 'Lucía Benítez', role: UserRole.insured),
  User(id: 'insured-demo-2', name: 'Tomás Ferreyra', role: UserRole.insured),
  User(id: 'insured-demo-3', name: 'Carolina Méndez', role: UserRole.insured),
  User(id: 'insured-demo-4', name: 'Diego Acosta', role: UserRole.insured),
  User(id: 'insured-demo-5', name: 'Valentina Sosa', role: UserRole.insured),
  User(id: 'insured-demo-6', name: 'Martín Quiroga', role: UserRole.insured),
  User(id: 'insured-demo-7', name: 'Sofía Cabrera', role: UserRole.insured),
  User(id: 'insured-demo-8', name: 'Julián Pereyra', role: UserRole.insured),
  User(id: 'consultant-demo-1', name: 'Nicolás Patella', role: UserRole.consultant),
  User(id: 'workshop-demo-user-1', name: 'Taller Norte', role: UserRole.workshop, workshopId: 'workshop-demo-1'),
  User(id: 'workshop-demo-user-2', name: 'Taller Central', role: UserRole.workshop, workshopId: 'workshop-demo-2'),
  User(id: 'workshop-demo-user-3', name: 'Taller del Sur', role: UserRole.workshop, workshopId: 'workshop-demo-3'),
];

const List<Workshop> mockWorkshops = [
  Workshop(id: 'workshop-demo-1', name: 'Taller Norte', city: 'Córdoba', phone: '351 555 0101', rating: 4.8),
  Workshop(id: 'workshop-demo-2', name: 'Taller Central', city: 'Rosario', phone: '341 555 0102', rating: 4.6),
  Workshop(id: 'workshop-demo-3', name: 'Taller del Sur', city: 'Lomas de Zamora', phone: '11 5555 0103', rating: 4.7),
];

const List<Vehicle> mockVehicles = [
  Vehicle(id: 'vehicle-demo-1', brand: 'Toyota', model: 'Hilux', year: 2022, plate: 'AE505YU', color: 'Blanco', imageUrl: ''),
  Vehicle(id: 'vehicle-demo-2', brand: 'Volkswagen', model: 'Polo', year: 2021, plate: 'AD214KF', color: 'Gris', imageUrl: ''),
  Vehicle(id: 'vehicle-demo-3', brand: 'Ford', model: 'Ranger', year: 2023, plate: 'AF318QZ', color: 'Negro', imageUrl: ''),
  Vehicle(id: 'vehicle-demo-4', brand: 'Chevrolet', model: 'Tracker', year: 2020, plate: 'AC762LM', color: 'Azul', imageUrl: ''),
  Vehicle(id: 'vehicle-demo-5', brand: 'Fiat', model: 'Cronos', year: 2022, plate: 'AE904TR', color: 'Blanco', imageUrl: ''),
  Vehicle(id: 'vehicle-demo-6', brand: 'Renault', model: 'Duster', year: 2019, plate: 'AB557NP', color: 'Gris', imageUrl: ''),
  Vehicle(id: 'vehicle-demo-7', brand: 'Peugeot', model: '208', year: 2024, plate: 'AG128WD', color: 'Rojo', imageUrl: ''),
  Vehicle(id: 'vehicle-demo-8', brand: 'Nissan', model: 'Frontier', year: 2021, plate: 'AD883VX', color: 'Plata', imageUrl: ''),
];

final List<RepairCase> mockRepairCases = [
  RepairCase(id: 'cf2e0d17-0fc4-4a25-800a-0e03100d88bf', vehicleId: 'vehicle-demo-1', insuredUserId: 'insured-demo-1', claimNumber: 'SIN-2026-001', description: 'Robo parcial de rueda de auxilio. La asegurada advirtió el faltante y daños en la cadena de sujeción.', status: RepairCaseStatus.newCase, entryDate: DateTime(2026, 10, 7, 10, 34), progress: 0),
  RepairCase(id: 'demo-claim-002', vehicleId: 'vehicle-demo-2', insuredUserId: 'insured-demo-2', claimNumber: 'SIN-2026-002', description: 'Daños en paragolpes trasero y portón luego de un impacto a baja velocidad.', status: RepairCaseStatus.inReview, entryDate: DateTime(2026, 10, 10, 9, 20), estimatedDeliveryDate: DateTime(2026, 10, 30), progress: 10),
  RepairCase(id: 'demo-claim-003', vehicleId: 'vehicle-demo-3', insuredUserId: 'insured-demo-3', claimNumber: 'SIN-2026-003', description: 'Rotura de luneta y daños en caja de carga; se solicita inspección y presupuesto.', status: RepairCaseStatus.workshopAssigned, entryDate: DateTime(2026, 10, 11, 11, 5), estimatedDeliveryDate: DateTime(2026, 10, 28), progress: 20, workshopId: 'workshop-demo-1'),
  RepairCase(id: 'demo-claim-004', vehicleId: 'vehicle-demo-4', insuredUserId: 'insured-demo-4', claimNumber: 'SIN-2026-004', description: 'Choque lateral en intersección; hay daños en ambas puertas del lado del conductor.', status: RepairCaseStatus.inspection, entryDate: DateTime(2026, 10, 12, 14, 40), estimatedDeliveryDate: DateTime(2026, 11, 5), progress: 30, workshopId: 'workshop-demo-2'),
  RepairCase(id: 'demo-claim-005', vehicleId: 'vehicle-demo-5', insuredUserId: 'insured-demo-5', claimNumber: 'SIN-2026-005', description: 'Hurto de rueda delantera y daños en cerradura del vehículo. Gestión Fast Track.', status: RepairCaseStatus.awaitingParts, entryDate: DateTime(2026, 10, 13, 8, 15), estimatedDeliveryDate: DateTime(2026, 10, 29), progress: 45, workshopId: 'workshop-demo-3'),
  RepairCase(id: 'demo-claim-006', vehicleId: 'vehicle-demo-6', insuredUserId: 'insured-demo-6', claimNumber: 'SIN-2026-006', description: 'Daños en capot y óptica delantera por colisión con otro vehículo.', status: RepairCaseStatus.inRepair, entryDate: DateTime(2026, 10, 14, 16), estimatedDeliveryDate: DateTime(2026, 10, 27), progress: 65, workshopId: 'workshop-demo-1'),
  RepairCase(id: 'demo-claim-007', vehicleId: 'vehicle-demo-7', insuredUserId: 'insured-demo-7', claimNumber: 'SIN-2026-007', description: 'Granizo con múltiples marcas en techo y capot; pendiente de validación del presupuesto.', status: RepairCaseStatus.estimate, entryDate: DateTime(2026, 10, 16, 10, 10), estimatedDeliveryDate: DateTime(2026, 11, 10), progress: 35, workshopId: 'workshop-demo-2'),
  RepairCase(id: 'demo-claim-008', vehicleId: 'vehicle-demo-8', insuredUserId: 'insured-demo-8', claimNumber: 'SIN-2026-008', description: 'Robo de espejo retrovisor y daños en moldura de puerta.', status: RepairCaseStatus.readyForDelivery, entryDate: DateTime(2026, 10, 18, 12, 30), estimatedDeliveryDate: DateTime(2026, 10, 24, 17), progress: 90, workshopId: 'workshop-demo-3'),
];

// Los chats empiezan vacíos en este conjunto de demostración.
final List<Message> mockMessages = [];
