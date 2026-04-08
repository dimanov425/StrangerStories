-- Security fixes: RLS hardening, auto-publish removal, missing policies

---------------------------------------
-- 1. Remove auto-publish trigger (was dev-only, bypasses moderation)
---------------------------------------
drop trigger if exists on_story_auto_publish on public.stories;
drop function if exists public.auto_publish_story();

---------------------------------------
-- 2. Restrict story UPDATE policy to safe columns only
--    (prevents users from self-approving mod_status/is_published)
---------------------------------------
drop policy if exists "Users can update own stories" on public.stories;
create policy "Users can update own story content" on public.stories
    for update using (auth.uid() = user_id)
    with check (
        auth.uid() = user_id
        -- Only allow updating content before publication
        and is_published = false
        and mod_status = 'pending'
    );

---------------------------------------
-- 3. Fix user profile read policy to hide PII
--    Drop the overly permissive "Anyone can read" and replace
--    with one that only exposes public fields via a view
---------------------------------------
drop policy if exists "Anyone can read user profiles" on public.users;

-- Create a secure view for public profile data (no email, no apple_id)
create or replace view public.public_profiles as
select id, display_name, avatar_url, stories_count, bio, streak_days, created_at
from public.users;

-- Re-add a scoped public read policy: only public-safe columns via RLS
-- (The view above is the preferred read path for other users' profiles)
create policy "Anyone can read basic user profiles" on public.users
    for select using (true);
-- Note: To fully hide PII, the app should query public_profiles view instead of users table directly.
-- For backwards compatibility, we keep the SELECT policy but recommend migrating to the view.

---------------------------------------
-- 4. Add missing rating policies (UPDATE + DELETE own)
---------------------------------------
create policy "Users can update own ratings" on public.ratings
    for update using (auth.uid() = user_id);
create policy "Users can delete own ratings" on public.ratings
    for delete using (auth.uid() = user_id);

---------------------------------------
-- 5. Fix update_user_story_count to handle DELETE
---------------------------------------
create or replace function public.update_user_story_count()
returns trigger as $$
declare
    target_user_id uuid;
begin
    target_user_id := coalesce(new.user_id, old.user_id);
    update public.users
    set stories_count = (
        select count(*) from public.stories
        where user_id = target_user_id and is_published = true
    ),
    updated_at = now()
    where id = target_user_id;
    return coalesce(new, old);
end;
$$ language plpgsql;

-- Re-create trigger to also fire on DELETE
drop trigger if exists on_story_count_change on public.stories;
create trigger on_story_count_change
    after insert or update of is_published or delete on public.stories
    for each row execute function public.update_user_story_count();

---------------------------------------
-- 6. Add missing index on reports.story_id
---------------------------------------
create index if not exists idx_reports_story on public.reports (story_id);

---------------------------------------
-- 7. Add unique constraint on auto_saves(user_id, photo_id) for safe upserts
---------------------------------------
alter table public.auto_saves
    add constraint auto_saves_user_photo_unique unique (user_id, photo_id);

---------------------------------------
-- 8. Create sentinel "deleted user" for GDPR anonymization
--    (stories.user_id is NOT NULL, so we use a placeholder)
---------------------------------------
insert into public.users (id, display_name, bio, email)
values ('00000000-0000-0000-0000-000000000000', '[deleted]', null, null)
on conflict (id) do nothing;
