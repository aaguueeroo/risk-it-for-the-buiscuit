-- Leaderboard schema for Supabase
-- Fields requested: username, character_type, score

create extension if not exists pgcrypto;

create table if not exists public.leaderboard_scores (
  id uuid primary key default gen_random_uuid(),
  username text not null check (char_length(trim(username)) > 0),
  character_type text not null check (char_length(trim(character_type)) > 0),
  score integer not null check (score >= 0),
  created_at timestamptz not null default now()
);

-- Migration support for existing schema
alter table public.leaderboard_scores
  add column if not exists character_type text;

update public.leaderboard_scores
set character_type = upper(
  coalesce(character_type, character_name, character, 'UNKNOWN')
)
where character_type is null or character_type = '';

alter table public.leaderboard_scores
  alter column character_type set not null;

alter table public.leaderboard_scores
  drop column if exists character_name;

alter table public.leaderboard_scores
  drop column if exists character;

alter table public.leaderboard_scores
  drop column if exists year;

create index if not exists leaderboard_scores_score_idx
  on public.leaderboard_scores (score desc);

create index if not exists leaderboard_scores_created_at_idx
  on public.leaderboard_scores (created_at desc);

alter table public.leaderboard_scores enable row level security;

drop policy if exists "allow_public_read_scores" on public.leaderboard_scores;
create policy "allow_public_read_scores"
  on public.leaderboard_scores
  for select
  to anon, authenticated
  using (true);

drop policy if exists "allow_public_insert_scores" on public.leaderboard_scores;
create policy "allow_public_insert_scores"
  on public.leaderboard_scores
  for insert
  to anon, authenticated
  with check (true);
