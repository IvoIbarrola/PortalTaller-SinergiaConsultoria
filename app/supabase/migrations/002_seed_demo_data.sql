-- Datos ficticios para la segunda demostración de Portal Taller.
-- Idempotente: permite volver a ejecutar sin duplicar registros.
-- No contiene datos reales ni modifica las políticas RLS.

insert into public.workshops (id, name, city, phone, rating)
values
  ('workshop-1', 'Taller Norte', 'Córdoba', '+54 351 555 0101', 4.8),
  ('workshop-2', 'Taller Central', 'Rosario', '+54 341 555 0102', 4.6)
on conflict (id) do update set
  name = excluded.name, city = excluded.city, phone = excluded.phone, rating = excluded.rating;

insert into public.profiles (id, auth_user_id, name, role, workshop_id)
values
  ('user-insured', null, 'Juan Pérez', 'insured', null),
  ('user-consultant', null, 'Sinergia Consultoría', 'consultant', null),
  ('workshop-1-user', null, 'Taller Norte', 'workshop', 'workshop-1'),
  ('workshop-2-user', null, 'Taller Central', 'workshop', 'workshop-2')
on conflict (id) do update set
  name = excluded.name, role = excluded.role, workshop_id = excluded.workshop_id;

insert into public.vehicles (id, brand, model, year, plate, color, image_url)
values
  ('vehicle-1', 'Toyota', 'Corolla', 2022, 'AA 123 BB', 'Blanco', ''),
  ('vehicle-2', 'Volkswagen', 'Golf', 2021, 'AC 456 CD', 'Gris', '')
on conflict (id) do update set
  brand = excluded.brand, model = excluded.model, year = excluded.year,
  plate = excluded.plate, color = excluded.color, image_url = excluded.image_url;

insert into public.repair_cases
  (id, vehicle_id, insured_user_id, claim_number, description, status, entry_date, estimated_delivery_date, progress, workshop_id)
values
  ('case-1', 'vehicle-1', 'user-insured', 'SINI-2026-001',
   'Daños en paragolpes y luces delanteras.', 'inRepair',
   '2026-09-20T00:00:00Z', '2026-10-08T00:00:00Z', 65, 'workshop-1'),
  ('case-2', 'vehicle-2', 'user-insured', 'SINI-2026-002',
   'Revisión de puerta lateral y ajuste de pintura.', 'awaitingParts',
   '2026-09-25T00:00:00Z', '2026-10-15T00:00:00Z', 35, 'workshop-2')
on conflict (id) do update set
  vehicle_id = excluded.vehicle_id, insured_user_id = excluded.insured_user_id,
  claim_number = excluded.claim_number, description = excluded.description,
  status = excluded.status, entry_date = excluded.entry_date,
  estimated_delivery_date = excluded.estimated_delivery_date,
  progress = excluded.progress, workshop_id = excluded.workshop_id;

insert into public.case_messages (id, case_id, sender_id, sender_name, message_text, created_at)
values
  ('msg-1', 'case-1', 'user-insured', 'Juan Pérez',
   'Buenas tardes, ¿tuvieron novedades del Corolla?', '2026-09-20T09:45:00Z'),
  ('msg-2', 'case-1', 'workshop-1-user', 'Taller Norte',
   'Sí. Ya estamos en la etapa de reparación y estimamos entrega para el 8 de octubre.', '2026-09-20T10:05:00Z'),
  ('msg-3', 'case-2', 'user-insured', 'Juan Pérez',
   'Necesito saber cuándo llega el repuesto para el Golf.', '2026-09-25T12:15:00Z'),
  ('msg-4', 'case-2', 'workshop-2-user', 'Taller Central',
   'El repuesto está en tránsito y se confirma la entrega este jueves.', '2026-09-25T12:30:00Z')
on conflict (id) do update set
  case_id = excluded.case_id, sender_id = excluded.sender_id,
  sender_name = excluded.sender_name, message_text = excluded.message_text,
  created_at = excluded.created_at;
