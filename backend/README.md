# Backend

Application/API layer for FREKANS.

Responsibilities:

- Authentication/session integration
- Authorization
- Profile and social domain logic
- Community/feed logic
- Music provider abstraction
- Chat authorization and message workflows
- Notifications
- Moderation/report workflows

The backend owns business rules. Clients should not implement security-sensitive rules themselves.

The first implementation will stay modular and small; we will not prematurely split the system into microservices.
