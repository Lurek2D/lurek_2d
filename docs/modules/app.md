# App

## Summary

- The `app` module is the top-level runtime shell that turns the engine from a set of subsystems into one running desktop application.
- It owns startup, frame progression, host-window lifecycle, and guarded callback dispatch, so update, draw, input, and lifecycle hooks reach game code in a stable order instead of through scattered platform calls.
- Splash screens, error screens, and debug overlays belong here because they are part of the user-facing execution shell rather than any one gameplay feature.
- This central shell also makes recovery possible when startup, callback, or shutdown errors occur.
- It turns platform hosting into one stable application loop.
- Read this module as the final integration boundary where rendering, input, windowing, and Lua execution are coordinated into one recoverable runtime loop.

*No public API documented yet.*