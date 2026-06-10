# App

## Summary

- The `app` module is the desktop runtime shell that drives launch-to-shutdown execution.
- It composes windowing, rendering, input routing, and Lua callbacks into one deterministic frame loop.
- This is the operational boundary that turns engine subsystems into a running application.
- It owns startup bootstrap, graphics surface bring-up, and steady frame progression.
- It handles resize, focus, visibility, and other host-level transitions during runtime.
- Callback dispatch goes through guarded execution paths instead of raw host invocations.
- Guarding contains script failures, timeout risks, and hot-reload edge cases.
- The module routes lifecycle, update, draw, input, and controller callbacks consistently.
- It also owns user-visible startup and failure presentation paths.
- Splash rendering is available before gameplay content is fully ready.
- Fatal errors switch to a readable error screen instead of silent termination.
- Development observability includes frame profile summaries and debug overlay metrics.
- Runtime health becomes inspectable through FPS and draw workload surfaces.
- Splash and error presentation are intentionally separated so startup, failure, and recovery states remain readable and testable.
- The module owns process lifecycle, frame orchestration, callback safety, and top-level diagnostics.
- Domain modules provide behavior, but `app` keeps the host responsive, ordered, and recoverable.

This module primarily collaborates with `event`, `filesystem`, `image`, `input`, `light`, `lua_api`, `math`, `parallax`, and adjacent engine modules. Its responsibility should stay inside the Edge/Integration group rather than absorb behavior owned by those neighbors.

*No public API documented yet.*