-- Worksheet 9: Praktik 9 - Tabel Device Tokens (Push Notification)

create table if not exists public.device_tokens (
  token text primary key,
  user_id uuid not null default auth.uid()
           references auth.users(id) on delete cascade,
  platform text,
  updated_at timestamptz not null default now()
);

alter table public.device_tokens enable row level security;

drop policy if exists "tokens_select_own" on public.device_tokens;
create policy "tokens_select_own" on public.device_tokens
  for select to authenticated using (auth.uid() = user_id);

drop policy if exists "tokens_insert_own" on public.device_tokens;
create policy "tokens_insert_own" on public.device_tokens
  for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "tokens_update_own" on public.device_tokens;
create policy "tokens_update_own" on public.device_tokens
  for update to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "tokens_delete_own" on public.device_tokens;
create policy "tokens_delete_own" on public.device_tokens
  for delete to authenticated using (auth.uid() = user_id);
