-- Worksheet 9: Praktik 5 & 6 - Row Level Security (RLS) pada tabel Kos

create table if not exists public.kos (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid()
           references auth.users(id) on delete cascade,
  name text not null,
  address text,
  price integer,
  created_at timestamptz not null default now()
);

-- Aktifkan RLS
alter table public.kos enable row level security;

-- 1. SELECT: Semua user yang authenticated boleh membaca data
drop policy if exists "kos_select_authenticated" on public.kos;
create policy "kos_select_authenticated"
  on public.kos for select to authenticated
  using (true);

-- 2. INSERT: owner_id harus sama dengan user login & role harus owner/admin
drop policy if exists "kos_insert_owner" on public.kos;
create policy "kos_insert_owner"
  on public.kos for insert to authenticated
  with check (
    auth.uid() = owner_id
    and exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role in ('owner', 'admin')
    )
  );

-- 3. UPDATE: Hanya pemilik data (owner_id == auth.uid())
drop policy if exists "kos_update_own" on public.kos;
create policy "kos_update_own"
  on public.kos for update to authenticated
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

-- 4. DELETE: Hanya pemilik data (owner_id == auth.uid())
drop policy if exists "kos_delete_own" on public.kos;
create policy "kos_delete_own"
  on public.kos for delete to authenticated
  using (auth.uid() = owner_id);

-- Query cek status policy RLS:
select tablename, policyname, cmd
from pg_policies
where schemaname = 'public' and tablename = 'kos';
