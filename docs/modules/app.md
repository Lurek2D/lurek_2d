# App

## Summary

The app module serves as the desktop execution heartbeat for Lurek2D. It unifies winit windowing, wgpu graphics, user inputs, and the LuaJIT virtual machine into a deterministic main loop. From process launch to final shutdown, it governs bootstrapping, manages graphic surface reconfigurations, and controls viewport scaling so visuals remain stable.

For scripting, the module coordinates the delivery of platform updates into Lua event handlers. It serves as the safety boundary, executing key lifecycle callbacks—such as fixed physics ticks, variable updates, rendering passes, and input event handlers—inside guarded boundaries. This protects against script anomalies, timeout lockups, and supports hot-reloading during live development.

To guide early startup and handle system faults, the module implements specialized visual screens. It renders a pre-game splash screen with branding elements and drag-and-drop feedback. If an unrecoverable failure occurs, it transitions to a formatted, clipboard-ready fatal crash screen that isolates traceback details and shows immediate troubleshooting guidance.

For diagnostics, the module incorporates lightweight performance tracking utilities. It aggregates frame timing profiles—update, rendering, and callback durations—into compact text traces for logs. It also supplies a togglable debug HUD showing real-time frame rates and draw workloads, offering low-cost visibility into live engine budgets.

*No public API documented yet.*