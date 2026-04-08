-- Device tokens for push notifications

create table public.device_tokens (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    token text not null,
    platform text not null default 'ios',
    created_at timestamptz not null default now(),
    unique (user_id, token)
);

create index idx_device_tokens_user on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;

create policy "Users can read own tokens" on public.device_tokens
    for select using (auth.uid() = user_id);

create policy "Users can insert own tokens" on public.device_tokens
    for insert with check (auth.uid() = user_id);

create policy "Users can delete own tokens" on public.device_tokens
    for delete using (auth.uid() = user_id);
