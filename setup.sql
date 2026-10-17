-- KantoBay website: Supabase schema and access policies
-- Run in Supabase Dashboard > SQL Editor.
-- Before going live, review these policies and enable email confirmation / anti-abuse controls.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  role text not null default 'reader' check (role in ('reader','editor','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  category text not null default 'Community' check (category in ('Kanto','Community','Politik','Sender')),
  title jsonb not null,
  body jsonb not null,
  published boolean not null default false,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists posts_publication_created_idx on public.posts (published, created_at desc);
create index if not exists profiles_email_idx on public.profiles (lower(email));

alter table public.profiles enable row level security;
alter table public.posts enable row level security;

create or replace function public.current_kantobay_role()
returns text language sql stable security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid()
$$;

-- New accounts are readers by default. Never let clients choose their own role.
create or replace function public.handle_new_kantobay_user()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, role)
  values (new.id, new.email, 'reader')
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_kantobay on auth.users;
create trigger on_auth_user_created_kantobay
after insert on auth.users
for each row execute procedure public.handle_new_kantobay_user();

-- Public can read only published posts.
drop policy if exists "Public read published posts" on public.posts;
create policy "Public read published posts" on public.posts
for select to anon, authenticated using (published = true or public.current_kantobay_role() in ('editor','admin'));

-- Editors and admins can create/update/delete posts.
drop policy if exists "Editors create posts" on public.posts;
create policy "Editors create posts" on public.posts
for insert to authenticated
with check (public.current_kantobay_role() in ('editor','admin') and created_by = auth.uid());

drop policy if exists "Editors update posts" on public.posts;
create policy "Editors update posts" on public.posts
for update to authenticated
using (public.current_kantobay_role() in ('editor','admin'))
with check (public.current_kantobay_role() in ('editor','admin'));

drop policy if exists "Editors delete posts" on public.posts;
create policy "Editors delete posts" on public.posts
for delete to authenticated
using (public.current_kantobay_role() in ('editor','admin'));

-- A user can read their own profile. Admins can list profiles for administration.
drop policy if exists "Read own profile or admin profiles" on public.profiles;
create policy "Read own profile or admin profiles" on public.profiles
for select to authenticated
using (id = auth.uid() or public.current_kantobay_role() = 'admin');

-- No client-side direct role updates. Role assignment is only through this admin-only function.
create or replace function public.admin_set_role_by_email(target_email text, new_role text)
returns boolean language plpgsql security definer
set search_path = public
as $$
declare target_id uuid;
begin
  if public.current_kantobay_role() <> 'admin' then
    raise exception 'Only administrators may change roles';
  end if;
  if new_role not in ('reader','editor','admin') then
    raise exception 'Invalid role';
  end if;
  select id into target_id from auth.users where lower(email) = lower(target_email) limit 1;
  if target_id is null then
    raise exception 'No user found with that email';
  end if;
  insert into public.profiles (id,email,role)
  select id,email,new_role from auth.users where id = target_id
  on conflict (id) do update set email = excluded.email, role = excluded.role;
  return true;
end;
$$;

revoke all on function public.admin_set_role_by_email(text,text) from public, anon;
grant execute on function public.admin_set_role_by_email(text,text) to authenticated;

-- Ensure the default role is never client-editable. RLS policies above do not grant
-- INSERT/UPDATE/DELETE on profiles to clients, so role escalation is blocked.
grant select on public.profiles to authenticated;
grant select, insert, update, delete on public.posts to authenticated;
grant select on public.posts to anon;

-- Bootstrap the first administrator:
-- 1) Sign up the first account through the website.
-- 2) In Supabase SQL Editor, find its UUID in Authentication > Users.
-- 3) Replace the UUID below and run this one-time statement:
-- update public.profiles set role = 'admin' where id = 'REPLACE-WITH-FIRST-ADMIN-UUID';
-- Do not publish this UUID statement in your public repository after use.
