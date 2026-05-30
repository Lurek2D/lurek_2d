# App

## Summary

The `app` module is where the whole runtime is assembled and driven from launch to shutdown. It does not own gameplay rules. Instead, it owns execution order: start services, process events, run frame stages, and present output in a predictable cycle.

Its main job is keeping one stable frame pipeline. Input, script callbacks, simulation updates, and rendering are coordinated in a fixed order so modules do not drift into inconsistent timing. Functionally, this gives the engine one trusted place that defines what happens each frame and when.

The module is also the bridge between platform events and engine behavior. Window, keyboard, mouse, touch, and gamepad signals are routed into runtime callbacks in a consistent form. This keeps script-side logic simpler, because gameplay code receives normalized events instead of platform-specific differences.

Operational UX is managed here too. Startup splash flow, debug overlay output, frame profile text, and fatal error presentation are coordinated at the app layer. In practical terms, this means both normal and failure paths stay readable for users and maintainers during real sessions.

Reliability policy lives at this boundary. Guarded callback calls, timeout-aware execution, and explicit recovery paths help prevent one failing script call from collapsing the whole loop silently. This makes runtime behavior easier to debug and safer to evolve as more subsystems are added.

Overall, the `app` module is the integration backbone of Lurek2D. It keeps subsystem boundaries clear, controls execution rhythm, and provides a single lifecycle contract that other modules can rely on for deterministic behavior.

*No public API documented yet.*