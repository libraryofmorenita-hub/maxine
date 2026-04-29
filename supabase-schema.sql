-- ─────────────────────────────────────────────────────────────────────────────
-- MAXINE Research Dashboard — Supabase schema
-- Run this in your Supabase project: SQL Editor → New query → paste → Run
-- ─────────────────────────────────────────────────────────────────────────────

-- Notes
create table public.maxine_notes (
  id         uuid primary key default gen_random_uuid(),
  tag        text not null default 'finding'
               check (tag in ('finding','issue','idea')),
  title      text not null,
  body       text not null default '',
  note_date  date not null default current_date,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Hardware BOM
create table public.maxine_hardware (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  part_no    text,
  qty        integer not null default 1,
  unit_cost  numeric(8,2),
  status     text not null default 'ordered'
               check (status in ('ordered','received','testing','integrated','issue')),
  notes      text,
  sort_order integer not null default 0,
  created_at timestamptz default now()
);

-- Changelog entries
create table public.maxine_changelog (
  id         uuid primary key default gen_random_uuid(),
  version    text not null,
  title      text not null,
  entry_date date not null default current_date,
  type       text not null default 'feat'
               check (type in ('feat','fix','arch','doc')),
  changes    jsonb not null default '[]',
  sort_order integer not null default 0,
  created_at timestamptz default now()
);

-- ── ROW LEVEL SECURITY ──
alter table public.maxine_notes     enable row level security;
alter table public.maxine_hardware  enable row level security;
alter table public.maxine_changelog enable row level security;

-- Anyone can read
create policy "public_read" on public.maxine_notes     for select using (true);
create policy "public_read" on public.maxine_hardware  for select using (true);
create policy "public_read" on public.maxine_changelog for select using (true);

-- Allowed editors table — add a row for each person who should have write access
create table public.maxine_editors (
  user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.maxine_editors enable row level security;
create policy "public_read" on public.maxine_editors for select using (true);

-- Only editors listed in maxine_editors can write
create policy "auth_write" on public.maxine_notes
  for all using (exists (select 1 from public.maxine_editors where user_id = auth.uid()))
  with check (exists (select 1 from public.maxine_editors where user_id = auth.uid()));

create policy "auth_write" on public.maxine_hardware
  for all using (exists (select 1 from public.maxine_editors where user_id = auth.uid()))
  with check (exists (select 1 from public.maxine_editors where user_id = auth.uid()));

create policy "auth_write" on public.maxine_changelog
  for all using (exists (select 1 from public.maxine_editors where user_id = auth.uid()))
  with check (exists (select 1 from public.maxine_editors where user_id = auth.uid()));

-- ── SETUP NOTES ──
-- After running this schema:
-- 1. Run supabase-seed.sql to load existing data
-- 2. Go to Authentication → Settings in your Supabase dashboard:
--      Site URL: your GitHub Pages URL (e.g. https://username.github.io/MAXINE)
--      Redirect URLs: same URL
--      Disable "Enable email confirmations" if you want instant access
-- 3. Go to Authentication → Users → Add user to create your own account
-- 4. To invite Mika: Authentication → Users → Invite user → enter her email
-- 5. Copy your project URL and anon key from Settings → API into dashboard.html
