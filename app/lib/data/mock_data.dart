import '../models/repair_case.dart';
import '../models/vehicles.dart';

const List<Vehicle> mockVehicles = [
  Vehicle(
    id: '1',
    brand: 'Toyota',
    model: 'Corolla',
    year: 2022,
    plate: 'AA 123 BB',
    color: 'Blanco',
    imageUrl: '',
  ),
  Vehicle(
    id: '2',
    brand: 'Volkswagen',
    model: 'Golf',
    year: 2021,
    plate: 'AC 456 CD',
    color: 'Gris',
    imageUrl: '',
  ),
  Vehicle(
    id: '3',
    brand: 'Ford',
    model: 'Focus',
    year: 2020,
    plate: 'AE 789 EF',
    color: 'Negro',
    imageUrl: '',
  ),
];

final List<RepairCase> mockRepairCases = [
  RepairCase(
    id: '1',
    vehicleId: '1',
    claimNumber: 'SINI-2026-001',
    description: 'Reparación de daños frontales',
    status: 'En reparación',
    entryDate: DateTime(2026, 9, 20),
    estimatedDeliveryDate: DateTime(2026, 10, 8),
    progress: 65,
  ),
  RepairCase(
    id: '2',
    vehicleId: '2',
    claimNumber: 'SINI-2026-002',
    description: 'Reparación de puerta lateral',
    status: 'En espera de repuestos',
    entryDate: DateTime(2026, 9, 25),
    estimatedDeliveryDate: DateTime(2026, 10, 15),
    progress: 35,
  ),
];