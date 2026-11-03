-- Authenticated CRUD for the Portal Taller workflows, scoped by profile role.
-- Apply after migrations 001 through 005. Never grant access to anon.

alter table public.profiles
  add column if not exists email text not null default '',
  add column if not exists phone text not null default '';

alter table public.workshops
  add column if not exists address text not null default '',
  add column if not exists contact_name text not null default '',
  add column if not exists specialties text[] not null default '{}',
  add column if not exists is_active boolean not null default true;

alter table public.vehicles
  add column if not exists insured_user_id text references public.profiles(id) on delete set null,
  add column if not exists vehicle_type text not null default '',
  add column if not exists trim text not null default '',
  add column if not exists vin text not null default '',
  add column if not exists mileage integer check (mileage is null or mileage >= 0),
  add column if not exists notes text not null default '';

create unique index if not exists vehicles_normalized_plate_uidx
  on public.vehicles (upper(regexp_replace(plate, '[^A-Za-z0-9]', '', 'g')))
  where btrim(plate) <> '';

create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated;

create or replace function private.current_profile_id()
returns text
language sql stable security definer set search_path = ''
as $$
  select p.id from public.profiles p
  where p.auth_user_id = (select auth.uid()) limit 1
$$;

create or replace function private.current_workshop_id()
returns text
language sql stable security definer set search_path = ''
as $$
  select p.workshop_id from public.profiles p
  where p.auth_user_id = (select auth.uid()) limit 1
$$;

create or replace function private.current_profile_name()
returns text
language sql stable security definer set search_path = ''
as $$
  select p.name from public.profiles p
  where p.auth_user_id = (select auth.uid()) limit 1
$$;

revoke all on function private.current_profile_id() from public, anon;
revoke all on function private.current_workshop_id() from public, anon;
revoke all on function private.current_profile_name() from public, anon;
grant execute on function private.current_profile_id() to authenticated;
grant execute on function private.current_workshop_id() to authenticated;
grant execute on function private.current_profile_name() to authenticated;

drop policy if exists workshops_insert_consultant on public.workshops;
create policy workshops_insert_consultant on public.workshops
for insert to authenticated
with check (private.current_profile_role() = 'consultant');

drop policy if exists workshops_update_consultant on public.workshops;
create policy workshops_update_consultant on public.workshops
for update to authenticated
using (private.current_profile_role() = 'consultant')
with check (private.current_profile_role() = 'consultant');

drop policy if exists vehicles_select_by_role on public.vehicles;
create policy vehicles_select_by_role on public.vehicles
for select to authenticated
using (
  private.current_profile_role() = 'consultant'
  or insured_user_id = private.current_profile_id()
  or exists (
    select 1 from public.repair_cases rc
    where rc.vehicle_id = vehicles.id
  )
);

drop policy if exists vehicles_insert_consultant on public.vehicles;
create policy vehicles_insert_consultant on public.vehicles
for insert to authenticated
with check (private.current_profile_role() = 'consultant');

drop policy if exists vehicles_update_consultant on public.vehicles;
create policy vehicles_update_consultant on public.vehicles
for update to authenticated
using (private.current_profile_role() = 'consultant')
with check (private.current_profile_role() = 'consultant');

drop policy if exists repair_cases_insert_consultant on public.repair_cases;
create policy repair_cases_insert_consultant on public.repair_cases
for insert to authenticated
with check (private.current_profile_role() = 'consultant');

drop policy if exists repair_cases_update_by_role on public.repair_cases;
create policy repair_cases_update_by_role on public.repair_cases
for update to authenticated
using (
  private.current_profile_role() = 'consultant'
  or (
    private.current_profile_role() = 'workshop'
    and workshop_id = private.current_workshop_id()
  )
)
with check (
  private.current_profile_role() = 'consultant'
  or (
    private.current_profile_role() = 'workshop'
    and workshop_id = private.current_workshop_id()
  )
);

drop policy if exists case_messages_insert_as_self on public.case_messages;
create policy case_messages_insert_as_self on public.case_messages
for insert to authenticated
with check (
  sender_id = private.current_profile_id()
  and sender_name = private.current_profile_name()
  and exists (
    select 1 from public.repair_cases rc
    where rc.id = case_messages.case_id
  )
);

drop policy if exists case_checklist_write_by_role on public.case_checklist_items;
create policy case_checklist_write_by_role on public.case_checklist_items
for all to authenticated
using (
  private.current_profile_role() = 'consultant'
  or (
    private.current_profile_role() = 'workshop'
    and exists (
      select 1 from public.repair_cases rc
      where rc.id = case_checklist_items.case_id
        and rc.workshop_id = private.current_workshop_id()
    )
  )
)
with check (
  private.current_profile_role() = 'consultant'
  or (
    private.current_profile_role() = 'workshop'
    and exists (
      select 1 from public.repair_cases rc
      where rc.id = case_checklist_items.case_id
        and rc.workshop_id = private.current_workshop_id()
    )
  )
);

drop policy if exists case_documents_write_by_role on public.case_documents;
create policy case_documents_write_by_role on public.case_documents
for all to authenticated
using (
  private.current_profile_role() = 'consultant'
  or (
    private.current_profile_role() = 'workshop'
    and exists (
      select 1 from public.repair_cases rc
      where rc.id = case_documents.case_id
        and rc.workshop_id = private.current_workshop_id()
    )
  )
)
with check (
  private.current_profile_role() = 'consultant'
  or (
    private.current_profile_role() = 'workshop'
    and exists (
      select 1 from public.repair_cases rc
      where rc.id = case_documents.case_id
        and rc.workshop_id = private.current_workshop_id()
    )
  )
);

drop policy if exists case_activity_insert_by_role on public.case_activity;
create policy case_activity_insert_by_role on public.case_activity
for insert to authenticated
with check (
  private.current_profile_role() in ('consultant', 'workshop')
  and author = private.current_profile_name()
  and exists (
    select 1 from public.repair_cases rc
    where rc.id = case_activity.case_id
  )
);

drop policy if exists case_photos_insert_by_role on public.case_photos;
create policy case_photos_insert_by_role on public.case_photos
for insert to authenticated
with check (
  uploaded_by = private.current_profile_id()
  and (
    private.current_profile_role() = 'consultant'
    or (
      private.current_profile_role() = 'workshop'
      and exists (
        select 1 from public.repair_cases rc
        where rc.id = case_photos.case_id
          and rc.workshop_id = private.current_workshop_id()
      )
    )
  )
);

drop policy if exists case_photos_delete_by_role on public.case_photos;
create policy case_photos_delete_by_role on public.case_photos
for delete to authenticated
using (
  private.current_profile_role() = 'consultant'
  or (
    private.current_profile_role() = 'workshop'
    and exists (
      select 1 from public.repair_cases rc
      where rc.id = case_photos.case_id
        and rc.workshop_id = private.current_workshop_id()
    )
  )
);

drop policy if exists case_photos_storage_select_by_case on storage.objects;
create policy case_photos_storage_select_by_case on storage.objects
for select to authenticated
using (
  bucket_id = 'case-photos'
  and exists (
    select 1 from public.case_photos cp
    where cp.storage_path = storage.objects.name
  )
);

drop policy if exists case_photos_storage_insert_by_role on storage.objects;
create policy case_photos_storage_insert_by_role on storage.objects
for insert to authenticated
with check (
  bucket_id = 'case-photos'
  and (
    private.current_profile_role() = 'consultant'
    or (
      private.current_profile_role() = 'workshop'
      and exists (
        select 1 from public.repair_cases rc
        where rc.id = split_part(storage.objects.name, '/', 1)
          and rc.workshop_id = private.current_workshop_id()
      )
    )
  )
);

drop policy if exists case_photos_storage_delete_by_role on storage.objects;
create policy case_photos_storage_delete_by_role on storage.objects
for delete to authenticated
using (
  bucket_id = 'case-photos'
  and exists (
    select 1 from public.case_photos cp
    where cp.storage_path = storage.objects.name
      and (
        private.current_profile_role() = 'consultant'
        or (
          private.current_profile_role() = 'workshop'
          and exists (
            select 1 from public.repair_cases rc
            where rc.id = cp.case_id
              and rc.workshop_id = private.current_workshop_id()
          )
        )
      )
  )
);

update storage.buckets
set public = false,
    file_size_limit = 10485760,
    allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp']
where id = 'case-photos';

revoke all on public.profiles, public.workshops, public.vehicles,
  public.repair_cases, public.case_messages, public.case_photos,
  public.case_checklist_items, public.case_documents, public.case_activity,
  public.case_attachments from anon, authenticated;

grant select on public.profiles, public.workshops, public.vehicles,
  public.repair_cases, public.case_messages, public.case_photos,
  public.case_checklist_items, public.case_documents, public.case_activity,
  public.case_attachments to authenticated;

grant update (name, email, phone) on public.profiles to authenticated;
grant insert, update on public.workshops, public.vehicles to authenticated;
grant insert on public.repair_cases to authenticated;
grant update (workshop_id, status, progress) on public.repair_cases to authenticated;
grant insert on public.case_messages, public.case_activity,
  public.case_photos to authenticated;
grant delete on public.case_photos to authenticated;
grant insert, update, delete on public.case_checklist_items,
  public.case_documents to authenticated;

do $$
declare
  table_name text;
begin
  if not exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) then
    raise exception 'La publicación supabase_realtime no existe.';
  end if;

  foreach table_name in array array[
    'profiles', 'workshops', 'vehicles', 'repair_cases', 'case_messages',
    'case_checklist_items', 'case_documents', 'case_activity', 'case_photos'
  ] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = table_name
    ) then
      execute format(
        'alter publication supabase_realtime add table public.%I',
        table_name
      );
    end if;
  end loop;
end;
$$;
