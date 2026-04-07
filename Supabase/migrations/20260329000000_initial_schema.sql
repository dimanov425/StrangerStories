-- Stranger Stories — Initial Database Schema
-- Run against a Supabase Postgres instance

-- No extensions needed — using built-in gen_random_uuid()

---------------------------------------
-- TABLES
---------------------------------------

create table public.users (
    id uuid primary key references auth.users(id) on delete cascade,
    apple_id text unique,
    email text,
    display_name text not null default 'Stranger',
    bio text,
    avatar_url text,
    stories_count integer not null default 0,
    avg_rating numeric(3,2),
    streak_days integer not null default 0,
    streak_recovery_used boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.photos (
    id uuid primary key default gen_random_uuid(),
    storage_path text not null,
    alt_text text not null,
    photographer text not null default 'Unknown',
    license text not null default 'CC0',
    mood_tags text[] not null default '{}',
    location text,
    story_count integer not null default 0,
    is_active boolean not null default true,
    created_at timestamptz not null default now()
);

create table public.stories (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    photo_id uuid not null references public.photos(id) on delete cascade,
    content text not null,
    word_count integer not null default 0,
    started_at timestamptz not null,
    submitted_at timestamptz not null,
    is_published boolean not null default false,
    is_flagged boolean not null default false,
    mod_status text not null default 'pending' check (mod_status in ('pending', 'approved', 'flagged', 'rejected')),
    avg_rating numeric(3,2),
    rating_count integer not null default 0,
    wilson_score numeric(10,8) not null default 0,
    created_at timestamptz not null default now()
);

create table public.ratings (
    id uuid primary key default gen_random_uuid(),
    story_id uuid not null references public.stories(id) on delete cascade,
    user_id uuid not null references public.users(id) on delete cascade,
    score integer not null check (score >= 1 and score <= 5),
    created_at timestamptz not null default now(),
    unique (story_id, user_id)
);

create table public.reports (
    id uuid primary key default gen_random_uuid(),
    story_id uuid not null references public.stories(id) on delete cascade,
    reporter_id uuid not null references public.users(id) on delete cascade,
    reason text not null,
    created_at timestamptz not null default now(),
    unique (story_id, reporter_id)
);

create table public.bookmarks (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    story_id uuid not null references public.stories(id) on delete cascade,
    created_at timestamptz not null default now(),
    unique (user_id, story_id)
);

create table public.achievements (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    type text not null,
    earned_at timestamptz not null default now(),
    unique (user_id, type)
);

create table public.auto_saves (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    photo_id uuid not null references public.photos(id) on delete cascade,
    content text not null default '',
    saved_at timestamptz not null default now()
);

create table public.daily_challenges (
    id uuid primary key default gen_random_uuid(),
    photo_id uuid not null references public.photos(id) on delete cascade,
    date date not null unique,
    created_at timestamptz not null default now()
);

create table public.admin_actions (
    id uuid primary key default gen_random_uuid(),
    admin_id uuid not null references public.users(id),
    action text not null,
    target_type text not null,
    target_id uuid not null,
    details jsonb,
    created_at timestamptz not null default now()
);

---------------------------------------
-- INDEXES
---------------------------------------

create index idx_stories_feed_recent on public.stories (created_at desc) where is_published = true;
create index idx_stories_feed_top on public.stories (wilson_score desc) where is_published = true;
create index idx_stories_by_photo on public.stories (photo_id, wilson_score desc);
create index idx_stories_by_user on public.stories (user_id, created_at desc);
create index idx_stories_moderation on public.stories (is_flagged, mod_status);
create index idx_ratings_story on public.ratings (story_id);
create index idx_bookmarks_user on public.bookmarks (user_id);
create index idx_achievements_user on public.achievements (user_id);
create index idx_auto_saves_user on public.auto_saves (user_id);

---------------------------------------
-- FUNCTIONS
---------------------------------------

-- Wilson score lower bound calculation (95% confidence)
create or replace function public.calculate_wilson_score(
    p_avg_rating numeric,
    p_rating_count integer
) returns numeric as $$
declare
    p numeric;
    n numeric;
    z numeric := 1.96;
begin
    if p_rating_count = 0 then
        return 0;
    end if;
    -- Normalize 1-5 star rating to 0-1 range
    p := (p_avg_rating - 1.0) / 4.0;
    n := p_rating_count;
    return (p + z*z/(2*n) - z * sqrt((p*(1-p) + z*z/(4*n)) / n)) / (1 + z*z/n);
end;
$$ language plpgsql immutable;

-- Recalculate story ratings and Wilson score
create or replace function public.update_story_rating()
returns trigger as $$
declare
    new_avg numeric;
    new_count integer;
begin
    select avg(score)::numeric(3,2), count(*)
    into new_avg, new_count
    from public.ratings
    where story_id = coalesce(new.story_id, old.story_id);

    update public.stories
    set avg_rating = new_avg,
        rating_count = new_count,
        wilson_score = public.calculate_wilson_score(new_avg, new_count)
    where id = coalesce(new.story_id, old.story_id);

    return coalesce(new, old);
end;
$$ language plpgsql;

-- Increment photo story count on published story
create or replace function public.increment_photo_story_count()
returns trigger as $$
begin
    if new.is_published = true and (old is null or old.is_published = false) then
        update public.photos
        set story_count = story_count + 1
        where id = new.photo_id;
    elsif new.is_published = false and old.is_published = true then
        update public.photos
        set story_count = greatest(story_count - 1, 0)
        where id = new.photo_id;
    end if;
    return new;
end;
$$ language plpgsql;

-- Increment user story count
create or replace function public.update_user_story_count()
returns trigger as $$
begin
    update public.users
    set stories_count = (
        select count(*) from public.stories
        where user_id = new.user_id and is_published = true
    ),
    updated_at = now()
    where id = new.user_id;
    return new;
end;
$$ language plpgsql;

-- Auto-create user row on auth signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.users (id, email, display_name)
    values (
        new.id,
        new.email,
        coalesce(new.raw_user_meta_data->>'full_name', 'Stranger')
    )
    on conflict (id) do nothing;
    return new;
end;
$$ language plpgsql security definer;

-- Auto-hide story when it reaches 3+ reports
create or replace function public.check_report_threshold()
returns trigger as $$
declare
    report_count integer;
begin
    select count(*) into report_count
    from public.reports
    where story_id = new.story_id;

    if report_count >= 3 then
        update public.stories
        set is_published = false, is_flagged = true
        where id = new.story_id and is_published = true;
    end if;
    return new;
end;
$$ language plpgsql;

---------------------------------------
-- TRIGGERS
---------------------------------------

create trigger on_rating_change
    after insert or update or delete on public.ratings
    for each row execute function public.update_story_rating();

create trigger on_story_publish_change
    after insert or update of is_published on public.stories
    for each row execute function public.increment_photo_story_count();

create trigger on_story_count_change
    after insert or update of is_published on public.stories
    for each row execute function public.update_user_story_count();

create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

create trigger on_report_created
    after insert on public.reports
    for each row execute function public.check_report_threshold();

---------------------------------------
-- ROW LEVEL SECURITY
---------------------------------------

alter table public.users enable row level security;
alter table public.photos enable row level security;
alter table public.stories enable row level security;
alter table public.ratings enable row level security;
alter table public.reports enable row level security;
alter table public.bookmarks enable row level security;
alter table public.achievements enable row level security;
alter table public.auto_saves enable row level security;
alter table public.daily_challenges enable row level security;
alter table public.admin_actions enable row level security;

-- Users: read own, update own
create policy "Users can read own profile" on public.users for select using (auth.uid() = id);
create policy "Users can update own profile" on public.users for update using (auth.uid() = id);

-- Photos: everyone can read active photos
create policy "Anyone can read active photos" on public.photos for select using (is_active = true);

-- Stories: read published + own; insert if authenticated; update own
create policy "Anyone can read published stories" on public.stories
    for select using (is_published = true);
create policy "Users can read own unpublished stories" on public.stories
    for select using (auth.uid() = user_id);
create policy "Authenticated users can insert stories" on public.stories
    for insert with check (auth.uid() = user_id);
create policy "Users can update own stories" on public.stories
    for update using (auth.uid() = user_id);

-- Ratings: read own; insert if authenticated (not own story)
create policy "Users can read own ratings" on public.ratings
    for select using (auth.uid() = user_id);
create policy "Authenticated users can insert ratings" on public.ratings
    for insert with check (
        auth.uid() = user_id
        and story_id not in (select id from public.stories where user_id = auth.uid())
    );

-- Reports: insert if authenticated
create policy "Authenticated users can insert reports" on public.reports
    for insert with check (auth.uid() = reporter_id);

-- Bookmarks: read/insert/delete own
create policy "Users can read own bookmarks" on public.bookmarks
    for select using (auth.uid() = user_id);
create policy "Users can insert bookmarks" on public.bookmarks
    for insert with check (auth.uid() = user_id);
create policy "Users can delete own bookmarks" on public.bookmarks
    for delete using (auth.uid() = user_id);

-- Achievements: read own
create policy "Users can read own achievements" on public.achievements
    for select using (auth.uid() = user_id);

-- Auto-saves: full CRUD on own
create policy "Users can manage own auto-saves" on public.auto_saves
    for all using (auth.uid() = user_id);

-- Daily challenges: everyone can read
create policy "Anyone can read daily challenges" on public.daily_challenges
    for select using (true);

-- Admin actions: no public access
create policy "No public access to admin actions" on public.admin_actions
    for select using (false);
