# FREKANS Database

PostgreSQL is the source of truth for application data. Supabase Auth owns user identity; `public.profiles.id` references `auth.users.id`.

## Migration

`migrations/001_initial_schema.sql` creates the first application schema for:

- profiles and authentication bootstrap
- provider-independent music catalog records
- favorite artists and songs
- community posts/topics, comments and likes
- follows
- direct conversations and messages
- reports and moderation audit actions
- notifications

## Music provider rule

Internal UUIDs are the primary keys. Provider IDs are external identifiers and are unique only together with their provider. This keeps FREKANS independent from Spotify or any future music provider.

For the MVP, music data is catalog metadata and outbound links. Listening-history analysis and derived compatibility/listenership metrics are intentionally outside the schema.

## Content model

`posts.type` currently supports:

- `thought` — normal music/community post
- `song_share` — post linked to a catalog song
- `topic` — discussion topic with a required title

Comments attach to posts, which keeps the initial API and moderation model simple.

## Security direction

Row Level Security policies will be added when the Supabase project is connected. Business rules should remain behind the API/application layer; the Android client must not contain privileged database credentials.
