-- FREKANS initial PostgreSQL schema
-- Identity is owned by Supabase Auth; application profile data lives here.

create extension if not exists pgcrypto;

create type public.music_provider as enum ('spotify', 'apple_music');
create type public.post_type as enum ('thought', 'song_share', 'topic');
create type public.content_status as enum ('active', 'hidden', 'deleted');
create type public.report_target_type as enum ('post', 'comment', 'user', 'message');
create type public.report_status as enum ('open', 'reviewing', 'resolved', 'dismissed');
create type public.notification_type as enum ('like', 'comment', 'follow', 'message', 'system');

create table public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    username text not null,
    display_name text not null,
    bio text,
    avatar_url text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint profiles_username_length check (char_length(username) between 3 and 30),
    constraint profiles_username_format check (username ~ '^[a-zA-Z0-9_]+$'),
    constraint profiles_display_name_length check (char_length(display_name) between 1 and 60)
);

create unique index profiles_username_lower_unique on public.profiles (lower(username));

create table public.artists (
    id uuid primary key default gen_random_uuid(),
    provider public.music_provider not null,
    provider_id text not null,
    name text not null,
    image_url text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (provider, provider_id)
);

create table public.albums (
    id uuid primary key default gen_random_uuid(),
    provider public.music_provider not null,
    provider_id text not null,
    artist_id uuid references public.artists(id) on delete set null,
    name text not null,
    image_url text,
    release_date date,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (provider, provider_id)
);

create table public.songs (
    id uuid primary key default gen_random_uuid(),
    provider public.music_provider not null,
    provider_id text not null,
    artist_id uuid references public.artists(id) on delete set null,
    album_id uuid references public.albums(id) on delete set null,
    title text not null,
    artist_name text not null,
    album_name text,
    artwork_url text,
    external_url text not null,
    duration_ms integer,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (provider, provider_id),
    constraint songs_duration_positive check (duration_ms is null or duration_ms > 0)
);

create table public.favorite_artists (
    user_id uuid not null references public.profiles(id) on delete cascade,
    artist_id uuid not null references public.artists(id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (user_id, artist_id)
);

create table public.favorite_songs (
    user_id uuid not null references public.profiles(id) on delete cascade,
    song_id uuid not null references public.songs(id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (user_id, song_id)
);

create table public.posts (
    id uuid primary key default gen_random_uuid(),
    author_id uuid not null references public.profiles(id) on delete cascade,
    type public.post_type not null default 'thought',
    title text,
    body text not null,
    song_id uuid references public.songs(id) on delete set null,
    status public.content_status not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    constraint posts_body_length check (char_length(body) between 1 and 5000),
    constraint posts_title_length check (title is null or char_length(title) between 1 and 180),
    constraint posts_topic_title check (type <> 'topic' or title is not null),
    constraint posts_song_share_song check (type <> 'song_share' or song_id is not null)
);

create index posts_feed_idx on public.posts (created_at desc) where status = 'active';
create index posts_author_idx on public.posts (author_id, created_at desc);
create index posts_song_idx on public.posts (song_id) where song_id is not null;

create table public.comments (
    id uuid primary key default gen_random_uuid(),
    post_id uuid not null references public.posts(id) on delete cascade,
    author_id uuid not null references public.profiles(id) on delete cascade,
    body text not null,
    status public.content_status not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    constraint comments_body_length check (char_length(body) between 1 and 2000)
);

create index comments_post_idx on public.comments (post_id, created_at asc) where status = 'active';

create table public.post_likes (
    post_id uuid not null references public.posts(id) on delete cascade,
    user_id uuid not null references public.profiles(id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (post_id, user_id)
);

create table public.comment_likes (
    comment_id uuid not null references public.comments(id) on delete cascade,
    user_id uuid not null references public.profiles(id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (comment_id, user_id)
);

create table public.follows (
    follower_id uuid not null references public.profiles(id) on delete cascade,
    following_id uuid not null references public.profiles(id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (follower_id, following_id),
    constraint follows_no_self check (follower_id <> following_id)
);

create index follows_following_idx on public.follows (following_id, created_at desc);

create table public.conversations (
    id uuid primary key default gen_random_uuid(),
    direct_key text unique,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.conversation_members (
    conversation_id uuid not null references public.conversations(id) on delete cascade,
    user_id uuid not null references public.profiles(id) on delete cascade,
    joined_at timestamptz not null default now(),
    primary key (conversation_id, user_id)
);

create index conversation_members_user_idx on public.conversation_members (user_id, joined_at desc);

create table public.messages (
    id uuid primary key default gen_random_uuid(),
    conversation_id uuid not null references public.conversations(id) on delete cascade,
    sender_id uuid not null references public.profiles(id) on delete cascade,
    body text not null,
    status public.content_status not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    constraint messages_body_length check (char_length(body) between 1 and 5000)
);

create index messages_conversation_idx on public.messages (conversation_id, created_at desc);

create table public.reports (
    id uuid primary key default gen_random_uuid(),
    reporter_id uuid not null references public.profiles(id) on delete cascade,
    target_type public.report_target_type not null,
    target_id uuid not null,
    reason text not null,
    status public.report_status not null default 'open',
    reviewed_by uuid references public.profiles(id) on delete set null,
    reviewed_at timestamptz,
    created_at timestamptz not null default now(),
    constraint reports_reason_length check (char_length(reason) between 3 and 1000)
);

create index reports_status_idx on public.reports (status, created_at desc);
create index reports_target_idx on public.reports (target_type, target_id);

create table public.moderation_actions (
    id uuid primary key default gen_random_uuid(),
    moderator_id uuid not null references public.profiles(id) on delete cascade,
    report_id uuid references public.reports(id) on delete set null,
    target_type public.report_target_type not null,
    target_id uuid not null,
    action text not null,
    note text,
    created_at timestamptz not null default now()
);

create index moderation_actions_target_idx on public.moderation_actions (target_type, target_id, created_at desc);

create table public.notifications (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    actor_id uuid references public.profiles(id) on delete set null,
    type public.notification_type not null,
    post_id uuid references public.posts(id) on delete cascade,
    comment_id uuid references public.comments(id) on delete cascade,
    conversation_id uuid references public.conversations(id) on delete cascade,
    message_id uuid references public.messages(id) on delete cascade,
    read_at timestamptz,
    created_at timestamptz not null default now()
);

create index notifications_user_idx on public.notifications (user_id, created_at desc);
create index notifications_unread_idx on public.notifications (user_id, created_at desc) where read_at is null;

-- Keep updated_at consistent without relying on application code.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

do $$
declare
    table_name text;
begin
    foreach table_name in array array[
        'profiles', 'artists', 'albums', 'songs', 'posts', 'comments',
        'conversations', 'messages'
    ] loop
        execute format(
            'create trigger %I before update on public.%I for each row execute function public.set_updated_at()',
            table_name || '_updated_at', table_name
        );
    end loop;
end;
$$;

-- Supabase Auth -> application profile bootstrap.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
    insert into public.profiles (id, username, display_name)
    values (
        new.id,
        coalesce(nullif(new.raw_user_meta_data ->> 'username', ''), 'user_' || substr(replace(new.id::text, '-', ''), 1, 10)),
        coalesce(nullif(new.raw_user_meta_data ->> 'display_name', ''), 'Yeni Kullanıcı')
    );
    return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();
