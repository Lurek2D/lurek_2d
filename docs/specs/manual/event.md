# event manual spec overlay

## TL;DR

- Runs a dual-priority event queue and wildcard signal registry.

## Summary

- The `event` module is the central message-routing layer for users who want runtime systems to communicate without hardwiring direct dependencies.
- Queues, priorities, listeners, signals, and deferred dispatch work together so gameplay, input, and tooling events can move through one predictable channel.
- Wildcard-style subscriptions and explicit listener lifecycle management make the bus practical for both large subsystems and small script integrations.
- History and Rust-Lua payload transfer matter because the module is not only about dispatch, but also about making that dispatch inspectable and usable across the engine boundary.
- Read it as the shared traffic system for runtime messages.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
