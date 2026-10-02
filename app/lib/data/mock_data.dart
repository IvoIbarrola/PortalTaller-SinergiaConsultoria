import '../models/message.dart';
import '../models/repair_case.dart';
import '../models/user.dart';
import '../models/vehicle.dart';
import '../models/workshop.dart';

const List<User> mockUsers = [
  User(
    id: 'user-insured',
    name: 'Juan Pérez',
    role: UserRole.insured,
  ),
  User(
    id: 'user-consultant',
    name: 'Sinergia Consultoría',
    role: UserRole.consultant,
  ),
  User(
    id: 'workshop-1-user',
    name: 'Taller Norte',
    role: UserRole.workshop,
    workshopId: 'workshop-1',
  ),
  User(
    id: 'workshop-2-user',
    name: 'Taller Central',
    role: UserRole.workshop,
    workshopId: 'workshop-2',
  ),
];

const List<Workshop> mockWorkshops = [
  Workshop(
    id: 'workshop-1',
    name: 'Taller Norte',
    city: 'Córdoba',
    phone: '+54 351 555 0101',
    rating: 4.8,
  ),
  Workshop(
    id: 'workshop-2',
    name: 'Taller Central',
    city: 'Rosario',
    phone: '+54 341 555 0102',
    rating: 4.6,
  ),
];

const List<Vehicle> mockVehicles = [
  Vehicle(
    id: 'vehicle-1',
    brand: 'Toyota',
    model: 'Corolla',
    year: 2022,
    plate: 'AA 123 BB',
    color: 'Blanco',
    imageUrl: '',
  ),
  Vehicle(
    id: 'vehicle-2',
    brand: 'Volkswagen',
    model: 'Golf',
    year: 2021,
    plate: 'AC 456 CD',
    color: 'Gris',
    imageUrl: '',
  ),
];

final List<RepairCase> mockRepairCases = [
  RepairCase(
    id: 'case-1',
    vehicleId: 'vehicle-1',
    insuredUserId: 'user-insured',
    claimNumber: 'SINI-2026-001',
    description: 'Daños en paragolpes y luces delanteras.',
    status: RepairCaseStatus.inRepair,
    entryDate: DateTime(2026, 9, 20),
    estimatedDeliveryDate: DateTime(2026, 10, 8),
    progress: 65,
    workshopId: 'workshop-1',
  ),
  RepairCase(
    id: 'case-2',
    vehicleId: 'vehicle-2',
    insuredUserId: 'user-insured',
    claimNumber: 'SINI-2026-002',
    description: 'Revisión de puerta lateral y ajuste de pintura.',
    status: RepairCaseStatus.awaitingParts,
    entryDate: DateTime(2026, 9, 25),
    estimatedDeliveryDate: DateTime(2026, 10, 15),
    progress: 35,
    workshopId: 'workshop-2',
  ),
];

final List<Message> mockMessages = [
  Message(
    id: 'msg-1',
    caseId: 'case-1',
    senderId: 'user-insured',
    senderName: 'Juan Pérez',
    text: 'Buenas tardes, ¿tuvieron novedades del Corolla?',
    createdAt: DateTime(2026, 9, 20, 9, 45),
  ),
  Message(
    id: 'msg-2',
    caseId: 'case-1',
    senderId: 'workshop-1-user',
    senderName: 'Taller Norte',
    text: 'Sí. Ya estamos en la etapa de reparación y estimamos entrega para el 8 de octubre.',
    createdAt: DateTime(2026, 9, 20, 10, 5),
  ),
  Message(
    id: 'msg-3',
    caseId: 'case-2',
    senderId: 'user-insured',
    senderName: 'Juan Pérez',
    text: 'Necesito saber cuándo llega el repuesto para el Golf.',
    createdAt: DateTime(2026, 9, 25, 12, 15),
  ),
  Message(
    id: 'msg-4',
    caseId: 'case-2',
    senderId: 'workshop-2-user',
    senderName: 'Taller Central',
    text: 'El repuesto está en tránsito y se confirma la entrega este jueves.',
    createdAt: DateTime(2026, 9, 25, 12, 30),
  ),
];