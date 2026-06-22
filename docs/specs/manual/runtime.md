# runtime manual spec overlay

## TL;DR

- Manages engine shared state, asset registries, and configurations.
- Supports headless or windowed modes and stable error codes.
- Reports frame profiling, memory budgets, and locale messages.

## Summary

- The `runtime` module is the shared engine-state surface that many other modules depend on before they expose their own user-facing features.
- Its role is to keep the rest of the engine coherent. Configuration, shared state, execution mode, error vocabulary, resource keys, logging support, and OS-aware helpers live here so the engine has one common operating language.
- This central vocabulary matters because large engines become fragile when every subsystem invents its own concepts for startup state, environment mode, resource identity, logging, or global context.
- Mode handling is especially important because the same engine may run in normal interactive play, headless automation, docs generation, tests, screenshots, or other specialized workflows that need different assumptions.
- Shared state, resource-key helpers, and runtime-wide error types give other modules a stable way to coordinate without dissolving into ad hoc registries and inconsistent failure reporting.
- Logging and environment-aware helpers belong here for the same reason: runtime-wide diagnostics and platform context should be centralized rather than redefined in each subsystem.
- That shared operating layer is what makes higher-level systems easier to compose around one startup and execution contract.
- Headless support is especially important because non-interactive execution should feel first-class for CI, docs, evidence capture, and automation instead of like a reduced afterthought.
- It also gives tool and gameplay code one place to agree on environment mode, startup assumptions, and shared process-level state.
- It gives the engine one durable answer to runtime context.
- That keeps “how the engine is running” separate from “what a feature is doing,” which is exactly the boundary `runtime` should own.
- `runtime` should stabilize common policy and state, but it should not absorb the domain logic of the modules that depend on it.
- Read `runtime` as the shared operating layer of the engine.

This module primarily collaborates with `audio`, `camera`, `event`, `filesystem`, `image`, `input`, `light`, `lua_api`, and adjacent engine modules. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
