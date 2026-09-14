# Android client

The Android app is the user-facing FREKANS client.

Initial direction:

- Kotlin
- Jetpack Compose
- Feature-oriented package boundaries
- Unidirectional UI state where practical
- Repository/data layer separated from UI
- API calls isolated behind interfaces
- No direct production database access from UI code

Planned feature modules:

```text
core/
auth/
home/
discover/
post/
music/
profile/
chat/
notifications/
settings/
```

The buildable Gradle project will be added after the repository foundation and database contract are established.
