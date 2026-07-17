# event manual spec overlay

## TL;DR

- Runs a dual-priority event queue, wildcard signal registry, and neutral ChangeSet envelope.

## Summary

- The `event` module is the central message-routing layer for users who want runtime systems to communicate without hardwiring direct dependencies.
- Queues, priorities, listeners, signals, and deferred dispatch work together so gameplay, input, and tooling events can move through one predictable channel.
- Wildcard-style subscriptions and explicit listener lifecycle management make the bus practical for both large subsystems and small script integrations.
- History and Rust-Lua payload transfer matter because the module is not only about dispatch, but also about making that dispatch inspectable and usable across the engine boundary.
- `newChangeSet()` provides a bounded, versioned collection of object/component mutations. It owns ordering, validation, deterministic hashing, and snapshot/restore only; it does not apply changes to ECS, physics, save, or network state.
- Lua code explicitly forwards a ChangeSet table to whichever existing module should consume it, keeping cross-system composition outside Rust.
- Read it as the shared traffic system for runtime messages.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
