# FREKANS 🎧

> **Müzik burada konuşulur.**
>
> Aynı şarkıda buluşalım.

FREKANS is a music-focused social community. People discover songs and artists, share what they are listening to, discuss music, follow other listeners, and chat — without turning the product into a generic social-media feed.

## Product principles

- Music is the center of the product.
- Community discussions come before vanity metrics.
- User-created music preferences are first-class data.
- Spotify is initially an outbound listening destination, not the core of the product.
- No Spotify listening-history analysis is required for the MVP.
- Moderation and reporting are part of the foundation, not an afterthought.
- The architecture must allow additional music providers later without coupling the whole app to one provider.

## MVP

1. Authentication
2. Profile creation
3. Community home
4. Posts and topics
5. Comments and likes
6. Music/user/topic search
7. Song cards and Spotify deep links
8. Following
9. Direct messages
10. Notifications
11. Reporting and moderation foundations
12. Settings

## Repository layout

```text
frekans/
├── android/      # Android client
├── backend/      # API/application layer
├── database/     # Database schema and migrations
├── docs/         # Architecture and product decisions
└── .github/      # CI/CD configuration
```

## Architecture rule

The Android client does **not** talk directly to the production database for application business logic. Requests flow through the application/API layer, with authentication and authorization enforced server-side.

## Status

🚧 Foundation phase — repository created from scratch.
