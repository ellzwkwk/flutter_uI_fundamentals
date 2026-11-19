-- Worksheet 9: Praktik 3 & 4 - Tabel Profiles & Role Pengguna

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  name text,
  role text not null default 'seeker'
        check (role in ('seeker', 'owner', 'admin'))
);

alter table public.profiles enable row level security;

-- user hanya boleh membaca profile miliknya sendiri.
create policy "profiles_select_own"
  on public.profiles for select to authenticated
  using (auth.uid() = id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', ''),
    case
      when new.raw_user_meta_data->>'role' in ('seeker', 'owner')
        then new.raw_user_meta_data->>'role'
      else 'seeker'
    end
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- profile untuk user yang sudah ada sebelumnya
insert into public.profiles (id, email, name, role)
select id, email, '', 'seeker' from auth.users
on conflict (id) do nothing;
