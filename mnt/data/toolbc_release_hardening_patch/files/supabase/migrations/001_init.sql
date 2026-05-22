-- ToolBC baseline schema hardening.
-- Review against existing production schema before applying to a non-empty database.

create extension if not exists pgcrypto;

begin;

do $$
begin
  create type public.user_role as enum ('patient', 'doctor', 'admin');
exception
  when duplicate_object then null;
end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  email text not null default '',
  role public.user_role not null default 'patient',
  specialty text,
  assigned_doctor_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_doctor_assignment_check check (
    assigned_doctor_id is null or assigned_doctor_id <> id
  )
);

create index if not exists profiles_email_idx on public.profiles(lower(email));
create index if not exists profiles_role_idx on public.profiles(role);
create index if not exists profiles_assigned_doctor_idx on public.profiles(assigned_doctor_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row
execute function public.set_updated_at();

create or replace function public.current_user_role()
returns public.user_role
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid();
$$;

revoke all on function public.current_user_role() from public;
grant execute on function public.current_user_role() to authenticated;

alter table public.profiles enable row level security;

drop policy if exists profiles_select_own_care_team_or_admin on public.profiles;
create policy profiles_select_own_care_team_or_admin
on public.profiles
for select
to authenticated
using (
  id = auth.uid()
  or public.current_user_role() = 'admin'::public.user_role
  or (
    public.current_user_role() = 'doctor'::public.user_role
    and (id = auth.uid() or assigned_doctor_id = auth.uid())
  )
);

drop policy if exists profiles_insert_admin_only on public.profiles;
create policy profiles_insert_admin_only
on public.profiles
for insert
to authenticated
with check (public.current_user_role() = 'admin'::public.user_role);

drop policy if exists profiles_update_admin_only on public.profiles;
create policy profiles_update_admin_only
on public.profiles
for update
to authenticated
using (public.current_user_role() = 'admin'::public.user_role)
with check (public.current_user_role() = 'admin'::public.user_role);

drop policy if exists profiles_delete_admin_only on public.profiles;
create policy profiles_delete_admin_only
on public.profiles
for delete
to authenticated
using (public.current_user_role() = 'admin'::public.user_role);

commit;
