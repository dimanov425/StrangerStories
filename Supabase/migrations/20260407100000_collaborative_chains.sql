-- Collaborative Story Chains
-- Transforms standalone stories into collaborative chains with chapters

---------------------------------------
-- 0. CLEANUP partial state from failed run
---------------------------------------

drop function if exists public.on_chapter_inserted() cascade;
drop function if exists public.fetch_swipeable_stories(uuid, int);
drop table if exists public.story_swipes;
drop table if exists public.chapters;
alter table public.stories drop column if exists chain_status;
alter table public.stories drop column if exists chapter_count;
alter table public.stories drop column if exists max_chapters;
alter table public.stories drop column if exists completed_at;

---------------------------------------
-- 1. EXTEND stories TABLE
---------------------------------------

alter table public.stories
    add column chain_status text not null default 'open'
        check (chain_status in ('open', 'completed'));

alter table public.stories
    add column chapter_count int not null default 1;

alter table public.stories
    add column max_chapters int not null default 7;

alter table public.stories
    add column completed_at timestamptz;

create index idx_stories_open_chains
    on public.stories (chain_status, wilson_score desc)
    where is_published = true and chain_status = 'open';

---------------------------------------
-- 2. CHAPTERS TABLE
---------------------------------------

create table public.chapters (
    id uuid primary key default gen_random_uuid(),
    story_id uuid not null references public.stories(id) on delete cascade,
    user_id uuid not null references public.users(id) on delete cascade,
    chapter_number int not null,
    content text not null,
    word_count int not null default 0,
    keywords text[] not null default '{}',
    is_ending boolean not null default false,
    started_at timestamptz not null,
    submitted_at timestamptz not null,
    created_at timestamptz not null default now(),
    unique (story_id, user_id),
    unique (story_id, chapter_number)
);

create index idx_chapters_by_story on public.chapters (story_id, chapter_number);
create index idx_chapters_by_user on public.chapters (user_id, created_at desc);

---------------------------------------
-- 3. STORY_SWIPES TABLE
---------------------------------------

create table public.story_swipes (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    story_id uuid not null references public.stories(id) on delete cascade,
    liked boolean not null,
    created_at timestamptz not null default now(),
    unique (user_id, story_id)
);

create index idx_swipes_by_user on public.story_swipes (user_id);

---------------------------------------
-- 4. RLS POLICIES
---------------------------------------

alter table public.chapters enable row level security;
alter table public.story_swipes enable row level security;

-- Chapters: anyone can read published story chapters
create policy "Anyone can read chapters of published stories" on public.chapters
    for select using (
        exists (
            select 1 from public.stories
            where stories.id = chapters.story_id
              and stories.is_published = true
        )
    );

-- Chapters: authenticated users can insert if chain is open and they haven't contributed
create policy "Authenticated users can add chapters to open chains" on public.chapters
    for insert with check (
        auth.uid() = user_id
        and exists (
            select 1 from public.stories
            where stories.id = chapters.story_id
              and stories.chain_status = 'open'
              and stories.is_published = true
        )
    );

-- Swipes: users can read and insert their own swipes
create policy "Users can read own swipes" on public.story_swipes
    for select using (auth.uid() = user_id);

create policy "Users can insert own swipes" on public.story_swipes
    for insert with check (auth.uid() = user_id);

---------------------------------------
-- 5. TRIGGER: on chapter insert
---------------------------------------

create or replace function public.on_chapter_inserted()
returns trigger as $$
declare
    v_chapter_count int;
    v_max_chapters int;
begin
    -- Update chapter count
    update public.stories
    set chapter_count = chapter_count + 1
    where id = new.story_id
    returning chapter_count, max_chapters
    into v_chapter_count, v_max_chapters;

    -- Auto-close if cap reached or author marked ending (with min 2 chapters)
    if v_chapter_count >= v_max_chapters
       or (new.is_ending = true and v_chapter_count >= 2) then
        update public.stories
        set chain_status = 'completed',
            completed_at = now()
        where id = new.story_id;
    end if;

    return new;
end;
$$ language plpgsql security definer;

create trigger on_chapter_insert
    after insert on public.chapters
    for each row execute function public.on_chapter_inserted();

---------------------------------------
-- 6. BACKFILL: create chapter 1 for existing stories
---------------------------------------

insert into public.chapters (story_id, user_id, chapter_number, content, word_count, started_at, submitted_at, created_at)
select
    s.id,
    s.user_id,
    1,
    s.content,
    s.word_count,
    s.started_at,
    s.submitted_at,
    s.created_at
from public.stories s
where not exists (
    select 1 from public.chapters c where c.story_id = s.id
);

---------------------------------------
-- 7. RPC: fetch swipeable stories
---------------------------------------

create or replace function public.fetch_swipeable_stories(p_user_id uuid, p_limit int default 7)
returns setof public.stories as $$
begin
    return query
    select s.*
    from public.stories s
    where s.is_published = true
      and s.chain_status = 'open'
      -- not authored any chapter in this chain
      and not exists (
          select 1 from public.chapters c
          where c.story_id = s.id and c.user_id = p_user_id
      )
      -- not already swiped
      and not exists (
          select 1 from public.story_swipes sw
          where sw.story_id = s.id and sw.user_id = p_user_id
      )
    order by s.wilson_score desc, s.created_at desc
    limit p_limit;
end;
$$ language plpgsql security definer;

