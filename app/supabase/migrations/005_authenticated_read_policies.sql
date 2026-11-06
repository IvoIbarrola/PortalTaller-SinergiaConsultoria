-- Read access for authenticated Portal Taller users, scoped by profile role and case ownership.
-- RLS remains enabled. No anon/public access is granted.
create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

create or replace function private.current_profile_role()
returns text language sql stable security definer set search_path = ''
as $$
  select p.role from public.profiles p
  where p.auth_user_id = (select auth.uid()) limit 1
$$;

revoke all on function private.current_profile_role() from public, anon;
grant execute on function private.current_profile_role() to authenticated;

drop policy if exists profiles_select_self on public.profiles;
drop policy if exists profiles_select_self_or_consultant on public.profiles;
create policy profiles_select_self_or_consultant on public.profiles
for select to authenticated
using (auth_user_id = (select auth.uid()) or private.current_profile_role() = 'consultant');

drop policy if exists repair_cases_select_by_role on public.repair_cases;
create policy repair_cases_select_by_role on public.repair_cases
for select to authenticated
using (
  private.current_profile_role() = 'consultant'
  or insured_user_id = (select id from public.profiles where auth_user_id = (select auth.uid()) limit 1)
  or (private.current_profile_role() = 'workshop'
      and workshop_id = (select workshop_id from public.profiles where auth_user_id = (select auth.uid()) limit 1))
);

drop policy if exists vehicles_select_for_authenticated_cases on public.vehicles;
create policy vehicles_select_for_authenticated_cases on public.vehicles
for select to authenticated
using (exists (select 1 from public.repair_cases rc where rc.vehicle_id = vehicles.id));

drop policy if exists workshops_select_for_authenticated_cases on public.workshops;
create policy workshops_select_for_authenticated_cases on public.workshops
for select to authenticated
using (
  private.current_profile_role() = 'consultant'
  or id = (select workshop_id from public.profiles where auth_user_id = (select auth.uid()) limit 1)
  or exists (select 1 from public.repair_cases rc where rc.workshop_id = workshops.id)
);

drop policy if exists case_messages_select_visible_case on public.case_messages;
create policy case_messages_select_visible_case on public.case_messages
for select to authenticated using (
  exists (select 1 from public.repair_cases rc where rc.id = case_messages.case_id)
);

drop policy if exists case_photos_select_visible_case on public.case_photos;
create policy case_photos_select_visible_case on public.case_photos
for select to authenticated using (
  exists (select 1 from public.repair_cases rc where rc.id = case_photos.case_id)
);

drop policy if exists case_checklist_select_visible_case on public.case_checklist_items;
create policy case_checklist_select_visible_case on public.case_checklist_items
for select to authenticated using (
  exists (select 1 from public.repair_cases rc where rc.id = case_checklist_items.case_id)
);

drop policy if exists case_documents_select_visible_case on public.case_documents;
create policy case_documents_select_visible_case on public.case_documents
for select to authenticated using (
  exists (select 1 from public.repair_cases rc where rc.id = case_documents.case_id)
);

drop policy if exists case_activity_select_visible_case on public.case_activity;
create policy case_activity_select_visible_case on public.case_activity
for select to authenticated using (
  exists (select 1 from public.repair_cases rc where rc.id = case_activity.case_id)
);

drop policy if exists case_attachments_select_visible_case on public.case_attachments;
create policy case_attachments_select_visible_case on public.case_attachments
for select to authenticated using (
  exists (select 1 from public.repair_cases rc where rc.id = case_attachments.case_id)
);

-- Keep the pre-existing SECURITY DEFINER event-trigger function unavailable to API roles.
revoke all on function public.rls_auto_enable() from public, anon, authenticated;
