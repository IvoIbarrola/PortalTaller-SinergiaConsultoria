-- Portal Taller - esquema inicial de Supabase
-- Aplicar desde Supabase Dashboard > SQL Editor.
-- La autenticacion real y las politicas RLS se agregaran en una migracion posterior.
-- IMPORTANTE: las tablas tienen RLS habilitado y no incluyen politicas permisivas.
-- No desactivar RLS ni agregar acceso anonimo amplio para probar.

create extension if not exists pgcrypto;

create table if not exists public.workshops (
  id text primary key default gen_random_uuid()::text,
  name text not null,
  city text not null default '',
  phone text not null default '',
  rating numeric(2,1) not null default 0 check (rating >= 0 and rating <= 5),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id text primary key default gen_random_uuid()::text,
  auth_user_id uuid unique references auth.users(id) on delete set null,
  name text not null,
  role text not null check (role in ('insured', 'consultant', 'workshop')),
  workshop_id text references public.workshops(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint workshop_role_requires_workshop
    check (role = 'workshop' or workshop_id is null)
);

create table if not exists public.vehicles (
  id text primary key default gen_random_uuid()::text,
  brand text not null,
  model text not null,
  year integer not null check (year between 1900 and 2200),
  plate text not null,
  color text not null default '',
  image_url text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.repair_cases (
  id text primary key default gen_random_uuid()::text,
  vehicle_id text not null references public.vehicles(id) on delete restrict,
  insured_user_id text not null references public.profiles(id) on delete restrict,
  claim_number text not null unique,
  description text not null default '',
  status text not null default 'newCase'
    check (status in (
      'newCase', 'inReview', 'workshopAssigned', 'received', 'inspection',
      'estimate', 'approval', 'awaitingParts', 'inRepair', 'qualityControl',
      'readyForDelivery', 'delivered'
    )),
  entry_date timestamptz not null default now(),
  estimated_delivery_date timestamptz,
  progress integer not null default 0 check (progress between 0 and 100),
  workshop_id text references public.workshops(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.case_messages (
  id text primary key default gen_random_uuid()::text,
  case_id text not null references public.repair_cases(id) on delete cascade,
  sender_id text not null references public.profiles(id) on delete restrict,
  sender_name text not null,
  message_text text not null check (length(trim(message_text)) > 0),
  created_at timestamptz not null default now()
);

create table if not exists public.case_photos (
  id text primary key default gen_random_uuid()::text,
  case_id text not null references public.repair_cases(id) on delete cascade,
  storage_path text not null unique,
  uploaded_by text references public.profiles(id) on delete set null,
  caption text not null default '',
  created_at timestamptz not null default now()
);

create index if not exists repair_cases_insured_user_idx
  on public.repair_cases(insured_user_id);
create index if not exists repair_cases_workshop_idx
  on public.repair_cases(workshop_id);
create index if not exists case_messages_case_created_idx
  on public.case_messages(case_id, created_at);
create index if not exists case_photos_case_created_idx
  on public.case_photos(case_id, created_at);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists workshops_set_updated_at on public.workshops;
create trigger workshops_set_updated_at before update on public.workshops
for each row execute function public.set_updated_at();

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists vehicles_set_updated_at on public.vehicles;
create trigger vehicles_set_updated_at before update on public.vehicles
for each row execute function public.set_updated_at();

drop trigger if exists repair_cases_set_updated_at on public.repair_cases;
create trigger repair_cases_set_updated_at before update on public.repair_cases
for each row execute function public.set_updated_at();

alter table public.workshops enable row level security;
alter table public.profiles enable row level security;
alter table public.vehicles enable row level security;
alter table public.repair_cases enable row level security;
alter table public.case_messages enable row level security;
alter table public.case_photos enable row level security;

-- Bucket privado para el registro fotografico.
insert into storage.buckets (id, name, public)
values ('case-photos', 'case-photos', false)
on conflict (id) do nothing;

-- Las politicas de tablas y storage se agregaran junto con la autenticacion.
-- Mientras tanto, el cliente anonimo no debe tener acceso a datos reales.
