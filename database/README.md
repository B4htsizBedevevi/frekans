# Database

The database is PostgreSQL-based.

Schema design priorities:

- UUID primary keys
- Explicit foreign keys
- Unique constraints for relationships such as follows and likes
- Indexes on feed, search, relationship, and timestamp access paths
- `created_at` / `updated_at` timestamps where applicable
- Soft deletion where audit/history matters
- Provider-independent music IDs
- Row-level authorization where Supabase RLS is used

Planned domains:

```text
identity
profiles
music
community
social
chat
moderation
notifications
```

Migrations will be added in `database/migrations/` and applied in order.
