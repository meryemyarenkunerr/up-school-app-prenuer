create type public.user_role as enum ('free', 'premium');

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  device_hash varchar not null,
  display_name text not null default '',
  avatar_url text not null default '',
  nationality varchar(2),
  role public.user_role not null default 'free',
  total_score int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "users_can_read_own_profile"
on public.profiles
for select
to authenticated
using (auth.uid() = id);

create policy "users_can_update_own_profile"
on public.profiles
for update
to authenticated
using (auth.uid() = id);

create or replace function public.touch_profiles_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_touch_profiles_updated_at on public.profiles;

create trigger trg_touch_profiles_updated_at
before update on public.profiles
for each row execute function public.touch_profiles_updated_at();

create or replace function public.upsert_profile_on_social_login(
  p_user_id uuid,
  p_device_hash varchar,
  p_display_name text,
  p_avatar_url text
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile public.profiles;
begin
  insert into public.profiles (
    id,
    device_hash,
    display_name,
    avatar_url
  )
  values (
    p_user_id,
    p_device_hash,
    coalesce(p_display_name, ''),
    coalesce(p_avatar_url, '')
  )
  on conflict (id)
  do update
  set
    device_hash = excluded.device_hash,
    display_name = coalesce(nullif(excluded.display_name, ''), public.profiles.display_name),
    avatar_url = coalesce(nullif(excluded.avatar_url, ''), public.profiles.avatar_url)
  returning * into v_profile;

  return v_profile;
end;
$$;
