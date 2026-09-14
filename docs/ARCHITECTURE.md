# FREKANS Architecture

## Goals

FREKANS is designed to start small without creating a dead-end architecture. The MVP should be deployable as a small system, while keeping clear boundaries for future scale.

## Layers

```text
Android client
      │
      ▼
Application/API layer
      │
 ┌────┼───────────────┐
 ▼    ▼               ▼
Auth  Domain logic    Music providers
 │    │               │
 └────┴───────┬───────┘
               ▼
          PostgreSQL
               │
               ▼
          Object storage
```

## Rules

1. The Android app does not contain database business rules.
2. Authorization is enforced server-side for every protected resource.
3. Database IDs are provider-independent UUIDs.
4. Music providers are accessed through an internal provider abstraction.
5. Spotify IDs are external identifiers, never primary keys.
6. User-created preferences and social activity are separate from provider playback history.
7. Moderation/reporting data is auditable.
8. API contracts are versionable.
9. Secrets never enter source control.
10. Features are isolated by domain so the app can evolve without a monolithic feature package.

## Initial technology direction

- Android: Kotlin + Jetpack Compose
- Backend: API/application layer with PostgreSQL
- Database/auth/storage: Supabase services where appropriate
- Realtime: introduced for chat after the core social flows are stable
- CI: GitHub Actions

The exact dependency versions will be pinned when the buildable Android/backend projects are added.
