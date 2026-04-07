-- Auto-publish stories on insert (dev/testing — bypasses moderation)
-- Remove this trigger when OpenAI moderation is configured

create or replace function public.auto_publish_story()
returns trigger as $$
begin
    new.is_published := true;
    new.mod_status := 'approved';
    return new;
end;
$$ language plpgsql;

create trigger on_story_auto_publish
    before insert on public.stories
    for each row execute function public.auto_publish_story();

-- Also allow users to read other users' profiles (needed for author display)
create policy "Anyone can read user profiles" on public.users
    for select using (true);
