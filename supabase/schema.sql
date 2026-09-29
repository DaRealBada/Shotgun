-- Shotgun: run once in Supabase → SQL Editor.
-- 1) Replace the three emails at the bottom with the real Google emails first.

create table if not exists public.members (
  email     text primary key,
  person_id text unique not null check (person_id in ('dhiya', 'george', 'tolu'))
);

create table if not exists public.events (
  id         text primary key,
  week       date not null,                                  -- Monday of the week
  d          smallint not null check (d between 0 and 6),    -- 0 = Monday
  start_hour smallint not null check (start_hour between 0 and 23),
  dur        smallint not null check (dur between 1 and 24),
  type       text not null,
  title      text not null default '',
  owner      text not null references public.members (person_id),
  people     jsonb not null default '{}'::jsonb,              -- { personId: going|invited|declined }
  updated_at timestamptz not null default now()
);
create index if not exists events_week_idx on public.events (week);

create table if not exists public.types (
  id     text primary key,
  label  text not null,
  icon   text,
  fill   text,
  campus boolean not null default false
);

-- Who is the signed-in user? (NULL = not in the house)
create or replace function public.my_person_id() returns text
language sql stable security definer set search_path = public as $$
  select person_id from public.members where email = lower(auth.jwt() ->> 'email')
$$;
create or replace function public.is_member() returns boolean
language sql stable security definer set search_path = public as $$
  select public.my_person_id() is not null
$$;

-- Row-level security: only house members can see or change anything.
alter table public.members enable row level security;
alter table public.events  enable row level security;
alter table public.types   enable row level security;

drop policy if exists members_read on public.members;
create policy members_read on public.members for select to authenticated
  using (email = lower(auth.jwt() ->> 'email') or public.is_member());

drop policy if exists events_read   on public.events;
drop policy if exists events_insert on public.events;
drop policy if exists events_update on public.events;
drop policy if exists events_delete on public.events;
create policy events_read   on public.events for select to authenticated using (public.is_member());
create policy events_insert on public.events for insert to authenticated with check (owner = public.my_person_id());
create policy events_update on public.events for update to authenticated using (public.is_member()) with check (public.is_member());
create policy events_delete on public.events for delete to authenticated using (owner = public.my_person_id());

drop policy if exists types_all on public.types;
create policy types_all on public.types for all to authenticated using (public.is_member()) with check (public.is_member());

-- Non-organisers may only change "people" (accept / decline / join / leave).
create or replace function public.guard_event_update() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if old.owner is distinct from public.my_person_id()
     and (new.week, new.d, new.start_hour, new.dur, new.type, new.title, new.owner)
         is distinct from (old.week, old.d, old.start_hour, old.dur, old.type, old.title, old.owner) then
    raise exception 'Only the organiser can edit this event';
  end if;
  new.updated_at := now();
  return new;
end $$;
drop trigger if exists events_guard on public.events;
create trigger events_guard before update on public.events
  for each row execute function public.guard_event_update();

-- Live updates between phones.
alter table public.events replica identity full;
alter table public.types  replica identity full;
do $$ begin
  begin alter publication supabase_realtime add table public.events; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.types;  exception when duplicate_object then null; end;
end $$;

-- 2) The house. Lowercase Google emails.
insert into public.members (email, person_id) values
  ('tolu@example.com',      'tolu'),
  ('george@example.com',    'george'),
  ('dhiyanick@example.com', 'dhiya')
on conflict (email) do update set person_id = excluded.person_id;
