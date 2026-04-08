-- Streak recovery: allows a user to "freeze" their streak for one missed day.
-- Returns true if recovery was successfully used, false if already used.

create or replace function public.use_streak_recovery()
returns boolean as $$
begin
    update public.users
    set streak_recovery_used = true,
        updated_at = now()
    where id = auth.uid()
      and streak_recovery_used = false
      and streak_days > 0;

    return found;
end;
$$ language plpgsql security definer;

-- Reset streak_recovery_used when streak increments (new story written)
create or replace function public.reset_streak_recovery_on_increment()
returns trigger as $$
begin
    if new.streak_days > old.streak_days then
        new.streak_recovery_used := false;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger on_streak_increment
    before update of streak_days on public.users
    for each row execute function public.reset_streak_recovery_on_increment();
