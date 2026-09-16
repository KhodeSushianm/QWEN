-- SUSHIAN creator backend
-- Run this in Supabase SQL Editor after creating a project.
-- 1) Create one Auth user with the email you will use as ADMIN_EMAIL.
-- 2) Replace YOUR_ADMIN_EMAIL below with that exact email.
-- 3) Create a Storage bucket named beat-previews and keep it PUBLIC for preview playback.

create table if not exists public.beats (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  genre text not null,
  bpm integer not null check (bpm between 40 and 240),
  key text not null,
  price numeric(10,2) not null default 0 check (price >= 0),
  type text not null,
  audio_path text not null,
  preview_url text not null,
  created_at timestamptz not null default now()
);

alter table public.beats enable row level security;

drop policy if exists "Public can read beats" on public.beats;
create policy "Public can read beats"
on public.beats for select
to anon, authenticated
using (true);

drop policy if exists "Admin can insert beats" on public.beats;
create policy "Admin can insert beats"
on public.beats for insert
to authenticated
with check ((select auth.jwt()->>'email') = 'YOUR_ADMIN_EMAIL');

drop policy if exists "Admin can update beats" on public.beats;
create policy "Admin can update beats"
on public.beats for update
to authenticated
using ((select auth.jwt()->>'email') = 'YOUR_ADMIN_EMAIL')
with check ((select auth.jwt()->>'email') = 'YOUR_ADMIN_EMAIL');

drop policy if exists "Admin can delete beats" on public.beats;
create policy "Admin can delete beats"
on public.beats for delete
to authenticated
using ((select auth.jwt()->>'email') = 'YOUR_ADMIN_EMAIL');

-- Storage policies. Bucket must be named beat-previews.
drop policy if exists "Public can read beat previews" on storage.objects;
create policy "Public can read beat previews"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'beat-previews');

drop policy if exists "Admin can upload beat previews" on storage.objects;
create policy "Admin can upload beat previews"
on storage.objects for insert
to authenticated
with check (bucket_id = 'beat-previews' and (select auth.jwt()->>'email') = 'YOUR_ADMIN_EMAIL');

drop policy if exists "Admin can update beat previews" on storage.objects;
create policy "Admin can update beat previews"
on storage.objects for update
to authenticated
using (bucket_id = 'beat-previews' and (select auth.jwt()->>'email') = 'YOUR_ADMIN_EMAIL')
with check (bucket_id = 'beat-previews' and (select auth.jwt()->>'email') = 'YOUR_ADMIN_EMAIL');

drop policy if exists "Admin can delete beat previews" on storage.objects;
create policy "Admin can delete beat previews"
on storage.objects for delete
to authenticated
using (bucket_id = 'beat-previews' and (select auth.jwt()->>'email') = 'YOUR_ADMIN_EMAIL');
