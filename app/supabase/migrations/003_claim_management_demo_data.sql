-- Portal Taller: modelo ampliado y set nuevo de ejemplos de gestión de siniestros.
-- Los registros son ficticios. Las referencias a adjuntos son nombres de ejemplo; no se incluyen binarios.
-- Mantiene RLS habilitado y no crea políticas públicas.

alter table public.repair_cases
  add column if not exists insurer_company text not null default '',
  add column if not exists claim_branch text not null default '',
  add column if not exists claim_type text not null default '',
  add column if not exists fast_track boolean not null default false,
  add column if not exists company_claim_number text not null default '',
  add column if not exists insured_dni text not null default '',
  add column if not exists insured_phone text not null default '',
  add column if not exists insured_email text not null default '',
  add column if not exists driver text not null default '',
  add column if not exists broker text not null default '',
  add column if not exists pas_name text not null default '',
  add column if not exists incident_date date,
  add column if not exists incident_location text not null default '',
  add column if not exists origin text not null default 'Portal Taller',
  add column if not exists jotform_id text not null default '',
  add column if not exists attachment_filename text not null default '',
  add column if not exists responsible text not null default '',
  add column if not exists has_third_parties boolean not null default false,
  add column if not exists registered_at timestamptz;

create table if not exists public.case_checklist_items (
 id text primary key default gen_random_uuid()::text,
 case_id text not null references public.repair_cases(id) on delete cascade,
 title text not null, completed boolean not null default false,
 sort_order integer not null default 0, completed_at timestamptz,
 completed_by text references public.profiles(id) on delete set null,
 created_at timestamptz not null default now(), unique(case_id,title)
);
create table if not exists public.case_documents (
 id text primary key default gen_random_uuid()::text,
 case_id text not null references public.repair_cases(id) on delete cascade,
 title text not null, received boolean not null default false, storage_path text,
 received_at timestamptz, received_by text references public.profiles(id) on delete set null,
 sort_order integer not null default 0, created_at timestamptz not null default now(),
 unique(case_id,title)
);
create table if not exists public.case_activity (
 id text primary key default gen_random_uuid()::text,
 case_id text not null references public.repair_cases(id) on delete cascade,
 entry_text text not null, author text not null default 'Sistema',
 origin text not null default '', created_at timestamptz not null default now()
);
create table if not exists public.case_attachments (
 id text primary key default gen_random_uuid()::text,
 case_id text not null references public.repair_cases(id) on delete cascade,
 filename text not null, description text not null default '',
 storage_path text not null default '', source text not null default 'JotForm',
 created_at timestamptz not null default now()
);
create index if not exists case_checklist_case_order_idx on public.case_checklist_items(case_id,sort_order);
create index if not exists case_documents_case_order_idx on public.case_documents(case_id,sort_order);
create index if not exists case_activity_case_created_idx on public.case_activity(case_id,created_at desc);
create index if not exists case_attachments_case_created_idx on public.case_attachments(case_id,created_at);
alter table public.case_checklist_items enable row level security;
alter table public.case_documents enable row level security;
alter table public.case_activity enable row level security;
alter table public.case_attachments enable row level security;
