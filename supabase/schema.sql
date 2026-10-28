-- 2415051086 - Gabriel Pranata Sembiring
-- Schema tabel courses

create table public.courses (
  id bigint generated always as identity primary key,
  code text not null unique,
  title text not null,
  credits int not null check (credits > 0),
  status text not null default 'planned'
    check (status in ('planned', 'active', 'done')),
  created_at timestamptz not null default now()
);

insert into public.courses (code, title, credits, status) values
  ('MOB01', 'Git & GitHub', 2, 'done'),
  ('MOB02', 'Dart Fundamentals', 2, 'done'),
  ('MOB03', 'Flutter UI Fundamentals', 3, 'active'),
  ('MOB04', 'Navigation', 2, 'planned'),
  ('MOB05', 'State Management', 3, 'planned');

alter table public.courses enable row level security;

create policy "lab_select_courses" on public.courses
  for select to anon, authenticated using (true);

create policy "lab_insert_courses" on public.courses
  for insert to anon, authenticated with check (true);

create policy "lab_update_courses" on public.courses
  for update to anon, authenticated using (true) with check (true);

create policy "lab_delete_courses" on public.courses
  for delete to anon, authenticated using (true);