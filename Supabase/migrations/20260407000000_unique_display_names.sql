-- Enforce unique display names (case-insensitive)

-- Step 1: Fix existing duplicates — append a short random suffix
-- (all current users with 'Stranger' get renamed to 'Stranger_xxxx')
do $$
declare
    r record;
    idx int := 0;
begin
    for r in
        select id from public.users
        where lower(display_name) = 'stranger'
        order by created_at
    loop
        idx := idx + 1;
        update public.users
        set display_name = 'Stranger_' || substr(md5(random()::text), 1, 4)
        where id = r.id;
    end loop;
end$$;

-- Step 2: Add unique index (case-insensitive)
create unique index users_display_name_lower_idx
    on public.users (lower(display_name));

-- Step 3: Helper RPC — check whether a name is available
create or replace function public.is_display_name_available(desired_name text)
returns boolean as $$
begin
    return not exists (
        select 1 from public.users
        where lower(display_name) = lower(desired_name)
    );
end;
$$ language plpgsql security definer;

-- Step 4: Helper RPC — claim a display name (only if it's available)
create or replace function public.claim_display_name(desired_name text)
returns boolean as $$
begin
    update public.users
    set display_name = desired_name,
        updated_at = now()
    where id = auth.uid();
    return true;
exception
    when unique_violation then
        return false;
end;
$$ language plpgsql security definer;
