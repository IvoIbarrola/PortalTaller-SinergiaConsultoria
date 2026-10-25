-- Reemplazo único del conjunto anterior por ocho casos ficticios de gestión de siniestros.
-- Los nombres de adjuntos son marcadores de ejemplo; no se guardan binarios.
-- Mantiene RLS activo y no crea políticas públicas.

-- Sustituir los datos demo anteriores por ocho fichas ficticias.
insert into public.workshops(id,name,city,phone,rating) values
('workshop-demo-1','Taller Norte','Córdoba','351 555 0101',4.8),
('workshop-demo-2','Taller Central','Rosario','341 555 0102',4.6),
('workshop-demo-3','Taller del Sur','Lomas de Zamora','11 5555 0103',4.7)
on conflict(id) do update set name=excluded.name,city=excluded.city,phone=excluded.phone,rating=excluded.rating;

insert into public.profiles(id,auth_user_id,name,role,workshop_id) values
('insured-demo-1',null,'Lucía Benítez','insured',null),
('insured-demo-2',null,'Tomás Ferreyra','insured',null),
('insured-demo-3',null,'Carolina Méndez','insured',null),
('insured-demo-4',null,'Diego Acosta','insured',null),
('insured-demo-5',null,'Valentina Sosa','insured',null),
('insured-demo-6',null,'Martín Quiroga','insured',null),
('insured-demo-7',null,'Sofía Cabrera','insured',null),
('insured-demo-8',null,'Julián Pereyra','insured',null),
('consultant-demo-1',null,'Nicolás Patella','consultant',null),
('workshop-demo-user-1',null,'Taller Norte','workshop','workshop-demo-1'),
('workshop-demo-user-2',null,'Taller Central','workshop','workshop-demo-2'),
('workshop-demo-user-3',null,'Taller del Sur','workshop','workshop-demo-3')
on conflict(id) do update set name=excluded.name,role=excluded.role,workshop_id=excluded.workshop_id;

insert into public.vehicles(id,brand,model,year,plate,color,image_url) values
('vehicle-demo-1','Toyota','Hilux',2022,'AE505YU','Blanco',''),
('vehicle-demo-2','Volkswagen','Polo',2021,'AD214KF','Gris',''),
('vehicle-demo-3','Ford','Ranger',2023,'AF318QZ','Negro',''),
('vehicle-demo-4','Chevrolet','Tracker',2020,'AC762LM','Azul',''),
('vehicle-demo-5','Fiat','Cronos',2022,'AE904TR','Blanco',''),
('vehicle-demo-6','Renault','Duster',2019,'AB557NP','Gris',''),
('vehicle-demo-7','Peugeot','208',2024,'AG128WD','Rojo',''),
('vehicle-demo-8','Nissan','Frontier',2021,'AD883VX','Plata','')
on conflict(id) do update set brand=excluded.brand,model=excluded.model,year=excluded.year,plate=excluded.plate,color=excluded.color,image_url=excluded.image_url;

insert into public.repair_cases
(id,vehicle_id,insured_user_id,claim_number,description,status,entry_date,estimated_delivery_date,progress,workshop_id,
 insurer_company,claim_branch,claim_type,fast_track,company_claim_number,insured_dni,insured_phone,insured_email,driver,broker,pas_name,
 incident_date,incident_location,origin,jotform_id,attachment_filename,responsible,has_third_parties,registered_at)
values
('cf2e0d17-0fc4-4a25-800a-0e03100d88bf','vehicle-demo-1','insured-demo-1','SIN-2026-001','Al estacionar, la asegurada advirtió el faltante de la rueda de auxilio y daños en la cadena de sujeción.','newCase','2026-10-07T10:34:06-03:00',null,0,null,'Sancor Seguros','Automotor','Robo parcial / Ruedas',true,'','27000001','11 4000 1001','lucia.benitez@example.invalid','Yo asegurado/a','RYS','Mariano','2026-10-07','Lomas de Zamora, Buenos Aires','JotForm','6672045302572456436','adjunto_demo_001.jpg','',false,'2026-10-07T10:34:06-03:00'),
('demo-claim-002','vehicle-demo-2','insured-demo-2','SIN-2026-002','Daños en paragolpes trasero y portón luego de un impacto a baja velocidad.','inReview','2026-10-10T09:20:00-03:00','2026-10-30T12:00:00-03:00',10,null,'La Caja','Automotor','Daños parciales',false,'LC-2026-8821','27000002','11 4000 1002','tomas.ferreyra@example.invalid','Asegurado','Broker Delta','Andrea','2026-10-09','Caballito, Ciudad Autónoma de Buenos Aires','JotForm','6672045302572456437','adjunto_demo_002.jpg','Equipo de Siniestros',false,'2026-10-10T09:20:00-03:00'),
('demo-claim-003','vehicle-demo-3','insured-demo-3','SIN-2026-003','Rotura de luneta y daños en caja de carga; se solicita inspección y presupuesto.','workshopAssigned','2026-10-11T11:05:00-03:00','2026-10-28T12:00:00-03:00',20,'workshop-demo-1','Federación Patronal','Automotor','Cristales y carrocería',false,'FP-009182','27000003','351 555 1003','carolina.mendez@example.invalid','Cónyuge autorizado','RYS','Mariano','2026-10-10','Córdoba Capital, Córdoba','JotForm','6672045302572456438','adjunto_demo_003.jpg','Mesa Automotor',false,'2026-10-11T11:05:00-03:00'),
('demo-claim-004','vehicle-demo-4','insured-demo-4','SIN-2026-004','Choque lateral en intersección; hay daños en ambas puertas del lado del conductor.','inspection','2026-10-12T14:40:00-03:00','2026-11-05T12:00:00-03:00',30,'workshop-demo-2','San Cristóbal','Automotor','Colisión',false,'SC-220184','27000004','341 555 1004','diego.acosta@example.invalid','Yo asegurado/a','Productores Unidos','Paula','2026-10-12','Rosario, Santa Fe','JotForm','6672045302572456439','adjunto_demo_004.jpg','Nicolás Patella',true,'2026-10-12T14:40:00-03:00'),
('demo-claim-005','vehicle-demo-5','insured-demo-5','SIN-2026-005','Hurto de rueda delantera y daños en cerradura del vehículo.','awaitingParts','2026-10-13T08:15:00-03:00','2026-10-29T12:00:00-03:00',45,'workshop-demo-3','Sancor Seguros','Automotor','Robo parcial / Ruedas',true,'SA-2026-1044','27000005','11 4000 1005','valentina.sosa@example.invalid','Yo asegurado/a','RYS','Mariano','2026-10-12','Banfield, Buenos Aires','JotForm','6672045302572456440','adjunto_demo_005.jpg','Equipo Fast Track',false,'2026-10-13T08:15:00-03:00'),
('demo-claim-006','vehicle-demo-6','insured-demo-6','SIN-2026-006','Daños en capot y óptica delantera por colisión con otro vehículo.','inRepair','2026-10-14T16:00:00-03:00','2026-10-27T12:00:00-03:00',65,'workshop-demo-1','Río Uruguay Seguros','Automotor','Colisión',false,'RUS-71002','27000006','351 555 1006','martin.quiroga@example.invalid','Pareja autorizada','Aseguradora Centro','Luciano','2026-10-14','Villa Allende, Córdoba','JotForm','6672045302572456441','adjunto_demo_006.jpg','Taller Norte',true,'2026-10-14T16:00:00-03:00'),
('demo-claim-007','vehicle-demo-7','insured-demo-7','SIN-2026-007','Granizo con múltiples marcas en techo y capot; pendiente de validación del presupuesto.','estimate','2026-10-16T10:10:00-03:00','2026-11-10T12:00:00-03:00',35,'workshop-demo-2','Provincia Seguros','Automotor','Granizo',false,'PS-61028','27000007','341 555 1007','sofia.cabrera@example.invalid','Yo asegurado/a','Broker Delta','Andrea','2026-10-15','Funes, Santa Fe','JotForm','6672045302572456442','adjunto_demo_007.jpg','Equipo de Siniestros',false,'2026-10-16T10:10:00-03:00'),
('demo-claim-008','vehicle-demo-8','insured-demo-8','SIN-2026-008','Robo de espejo retrovisor y daños en moldura de puerta.','readyForDelivery','2026-10-18T12:30:00-03:00','2026-10-24T17:00:00-03:00',90,'workshop-demo-3','La Segunda','Automotor','Robo parcial / Accesorios',true,'LS-882901','27000008','11 4000 1008','julian.pereyra@example.invalid','Yo asegurado/a','Productores Unidos','Paula','2026-10-17','Temperley, Buenos Aires','JotForm','6672045302572456443','adjunto_demo_008.jpg','Taller del Sur',false,'2026-10-18T12:30:00-03:00')
on conflict(id) do update set
 vehicle_id=excluded.vehicle_id,insured_user_id=excluded.insured_user_id,claim_number=excluded.claim_number,description=excluded.description,status=excluded.status,
 entry_date=excluded.entry_date,estimated_delivery_date=excluded.estimated_delivery_date,progress=excluded.progress,workshop_id=excluded.workshop_id,
 insurer_company=excluded.insurer_company,claim_branch=excluded.claim_branch,claim_type=excluded.claim_type,fast_track=excluded.fast_track,
 company_claim_number=excluded.company_claim_number,insured_dni=excluded.insured_dni,insured_phone=excluded.insured_phone,insured_email=excluded.insured_email,
 driver=excluded.driver,broker=excluded.broker,pas_name=excluded.pas_name,incident_date=excluded.incident_date,incident_location=excluded.incident_location,
 origin=excluded.origin,jotform_id=excluded.jotform_id,attachment_filename=excluded.attachment_filename,responsible=excluded.responsible,
 has_third_parties=excluded.has_third_parties,registered_at=excluded.registered_at;

insert into public.case_checklist_items(id,case_id,title,completed,sort_order)
select 'check-'||substr(md5(c.id||v.n::text),1,16),c.id,v.title,false,v.n from public.repair_cases c cross join (values
(1,'Denuncia recibida vía JotForm'),(2,'Ingresar en compañía'),(3,'Contactar al asegurado'),
(4,'Enviar orden fast track (24hs)'),(5,'Relevamiento'),(6,'CLEAS vinculación'),(7,'CLEAS dictamen')
) as v(n,title) on conflict(case_id,title) do update set sort_order=excluded.sort_order;
insert into public.case_documents(id,case_id,title,received,sort_order)
select 'doc-'||substr(md5(c.id||v.n::text),1,16),c.id,v.title,false,v.n from public.repair_cases c cross join (values
(1,'Licencia de conducir'),(2,'Cédula verde / azul'),(3,'Denuncia policial')
) as v(n,title) on conflict(case_id,title) do update set sort_order=excluded.sort_order;
insert into public.case_activity(id,case_id,entry_text,author,origin,created_at)
select 'activity-'||substr(md5(c.id),1,16),c.id,'Sincronizado desde JotForm automotor — '||coalesce(c.claim_branch,'Automotor')||' — '||coalesce(c.claim_type,'Ingreso demo'),
'Sistema JotForm','JotForm',coalesce(c.registered_at,c.entry_date,now()) from public.repair_cases c
on conflict(id) do update set entry_text=excluded.entry_text,created_at=excluded.created_at;
insert into public.case_attachments(id,case_id,filename,description,storage_path,source,created_at)
select 'attachment-'||substr(md5(c.id),1,16),c.id,coalesce(nullif(c.attachment_filename,''),'adjunto_demo.jpg'),
'Nombre ilustrativo; el archivo no está incluido.','','JotForm',coalesce(c.registered_at,c.entry_date,now()) from public.repair_cases c
on conflict(id) do update set filename=excluded.filename,description=excluded.description,created_at=excluded.created_at;

delete from public.repair_cases where id not in
('cf2e0d17-0fc4-4a25-800a-0e03100d88bf','demo-claim-002','demo-claim-003','demo-claim-004','demo-claim-005','demo-claim-006','demo-claim-007','demo-claim-008');
delete from public.case_messages where case_id not in
('cf2e0d17-0fc4-4a25-800a-0e03100d88bf','demo-claim-002','demo-claim-003','demo-claim-004','demo-claim-005','demo-claim-006','demo-claim-007','demo-claim-008');
delete from public.case_photos where case_id not in
('cf2e0d17-0fc4-4a25-800a-0e03100d88bf','demo-claim-002','demo-claim-003','demo-claim-004','demo-claim-005','demo-claim-006','demo-claim-007','demo-claim-008');
delete from public.vehicles where id not in
('vehicle-demo-1','vehicle-demo-2','vehicle-demo-3','vehicle-demo-4','vehicle-demo-5','vehicle-demo-6','vehicle-demo-7','vehicle-demo-8');
delete from public.profiles where id not in
('insured-demo-1','insured-demo-2','insured-demo-3','insured-demo-4','insured-demo-5','insured-demo-6','insured-demo-7','insured-demo-8','consultant-demo-1','workshop-demo-user-1','workshop-demo-user-2','workshop-demo-user-3');
delete from public.workshops where id not in ('workshop-demo-1','workshop-demo-2','workshop-demo-3');
