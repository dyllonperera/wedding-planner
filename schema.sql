-- ============================================================
-- Wedding + Homecoming Planner — schema
-- Run this once in Supabase → SQL Editor → New query → Run
-- ============================================================

create extension if not exists "pgcrypto";

create table if not exists events (
  id text primary key,
  name text not null,
  event_date date
);

insert into events (id, name, event_date) values
  ('wedding', 'Wedding', null),
  ('homecoming', 'Homecoming', null)
on conflict (id) do nothing;

create table if not exists vendors (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references events(id),
  category text not null,
  name text not null,
  contact_name text,
  contact_phone text,
  contact_email text,
  status text not null default 'researching', -- researching | contacted | booked | paid_deposit | paid_full
  price numeric,
  deposit_amount numeric,
  deposit_paid boolean not null default false,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists budget_items (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references events(id),
  category text not null,
  item_name text not null,
  planned_amount numeric not null default 0,
  actual_amount numeric,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references events(id),
  title text not null,
  due_date date,
  category text,
  completed boolean not null default false,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists guests (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references events(id),
  name text not null,
  side text, -- his side | her side | family | friends
  rsvp_status text not null default 'pending', -- pending | yes | no
  plus_one boolean not null default false,
  dietary_notes text,
  notes text,
  created_at timestamptz not null default now()
);

-- ============================================================
-- Row Level Security
-- This app has no login — anyone with the URL + anon key can
-- read/write. That's fine for a private link only you and your
-- family/partner have, but don't post the URL publicly.
-- ============================================================
alter table events enable row level security;
alter table vendors enable row level security;
alter table budget_items enable row level security;
alter table tasks enable row level security;
alter table guests enable row level security;

create policy "anon full access" on events for all using (true) with check (true);
create policy "anon full access" on vendors for all using (true) with check (true);
create policy "anon full access" on budget_items for all using (true) with check (true);
create policy "anon full access" on tasks for all using (true) with check (true);
create policy "anon full access" on guests for all using (true) with check (true);

-- ============================================================
-- Mood board photo storage
-- Run this too if you want the Mood Board tab to work.
-- ============================================================
insert into storage.buckets (id, name, public)
values ('moodboard', 'moodboard', true)
on conflict (id) do nothing;

create policy "moodboard anon read" on storage.objects for select using (bucket_id = 'moodboard');
create policy "moodboard anon upload" on storage.objects for insert with check (bucket_id = 'moodboard');
create policy "moodboard anon delete" on storage.objects for delete using (bucket_id = 'moodboard');
