# Lurek2D Engine Core Architecture

## Purpose

Lurek2D runs a Lua project inside one desktop application process. The engine owns platform resources and runtime services; game code owns the rules and state of the experience through the public `lurek.*` surface.

This document describes cross-module composition and lifecycle. Module-level callable details belong in `docs/specs/` and generated API documentation.

## System composition

```text
main
  -> app: window/event-loop composition and callback lifecycle
      -> runtime: shared state, configuration, errors, paths, headless support
      -> lua_api: VM setup, public namespaces, conversion, callbacks
      -> domain modules: simulation, content, services, and render-command producers
      -> render: GPU resources, frame validation, command execution, presentation
```

`app` is the composition root. It may coordinate lower layers, but lower layers must not depend back on `app`. `lua_api` is the public edge: domain owners never import it to reach Lua or `mlua` types.

## Responsibilities by layer

| Layer | Owns | Must not own |
|---|---|---|
| `app` | Window lifecycle, event dispatch, frame orchestration, callback failure handling, startup/shutdown. | Domain algorithms or the public API implementation. |
| `runtime` | Shared runtime state, configuration, error model, resource keys, paths, headless helpers, cross-cutting messages. | A parallel renderer, Lua API, or gameplay authority. |
| `lua_api` | VM creation, sandboxing, `lurek.*` registration, Lua conversion, callbacks, boundary errors. | Domain behavior duplicated from `src/<module>/`. |
| Domain modules | Feature state, algorithms, validation, import/export rules, and typed outputs. | Window/event-loop ownership, direct GPU backend objects, or VM ownership. |
| `render` | GPU resources, render-frame validation, command execution, software capture/testing paths, present. | Gameplay/simulation state or UI layout policy. |

The five module groups recorded in metadata are navigation and dependency guidance, not a second public API taxonomy. The hard rule is an acyclic dependency graph with a visible owner for every mutable state.

## Startup lifecycle

1. `main` parses launch options and delegates to the application or headless runtime path.
2. Configuration and the project directory are resolved before a game script is loaded.
3. `app` creates platform/window state when the selected mode requires it, then creates renderer and shared runtime state.
4. `lua_api` creates the VM, installs the sandbox, registers enabled `lurek.*` namespaces, and configures package resolution.
5. The entry script loads. Once runtime services and the Lua environment are ready, the engine invokes startup callbacks such as `lurek.init`.
6. The first usable frame completes resource setup, then the ready lifecycle runs where applicable.

Startup errors remain attached to the owning phase. Configuration, project resolution, VM creation, script load, window/GPU initialization, and callback failures are reported as distinct paths so a user can act on the correct boundary.

## Frame lifecycle

`LurekApp` owns the desktop event loop and its frame orchestration. The exact callback catalog is generated from source; the durable sequence is:

```text
platform events
  -> input state + UI routing
  -> queued runtime work and hot-reload observation
  -> fixed-rate physics/process callbacks (zero or more steps)
  -> per-frame process callback
  -> late-process callback
  -> draw and draw-ui callbacks
  -> collect automatic subsystem output
  -> validate and execute render commands
  -> present, diagnostics, and deferred cleanup
```

Input is first interpreted by platform and configured UI routing before game callbacks receive unconsumed events. Time-based game code receives `dt`; fixed-rate callbacks may run more than once in a rendered frame. Rendering is a projection of current runtime/domain state, not the owner of that state.

Callback failures are classified by application policy. Frame-critical callbacks stop or surface a failure rather than letting a partially-updated frame continue; report-only callbacks keep diagnostics without silently changing the owner of recovery decisions.

## State ownership

`SharedState` is the runtime coordination object, not a global gameplay model. It holds data needed across the running application: timing, input aggregation, window/viewport state, resource registries, render-command state, and configured subsystem access.

Use this distinction when changing state:

| Kind | Owner and rule |
|---|---|
| Primary domain state | The module whose behavior defines it: physics world, scene stack, save model, tile data, UI state, and similar feature state. |
| Runtime coordination | `SharedState` when several runtime paths need a live service in one process. |
| GPU data | `render` and renderer-owned resource registries. Domain modules provide descriptors, handles, or commands. |
| Snapshot/cache | Derived from a primary owner; invalidation follows that owner. A cache is never a second authority. |
| Serialized data | Stable domain data only. Rebuild runtime/GPU/VM resources through lifecycle owners after load. |
| External input | Validate at the import/API boundary before it becomes owned state. |

Lua bindings borrow shared state only for the operation they perform. They release the borrow before re-entering Lua or calling a callback.

## Resource and filesystem lifecycle

Resources loaded for a running project are represented by typed owners and validated handles. A Lua-visible handle identifies a Rust-owned resource; it does not grant access to a raw pointer or transfer cleanup responsibility. The owning module detects stale/invalid use and performs release, eviction, or rebuild under its own policy.

Filesystem access passes through the project/runtime policy. Raw host paths, package resolution, imported content, and mod-provided files remain external input until their owning subsystem validates them. A script-side convenience API must not bypass the sandbox or turn a presentation path into a persistence authority.

## Threading and messages

Lua VMs and `SharedState` remain thread-local. Long-running or blocking work belongs in Rust workers or subsystem-specific asynchronous paths. Cross-thread communication uses owned data/messages; a worker must not capture Lua state, backend GPU objects, or mutable domain state without the owner's explicit synchronization contract.

## Headless and shutdown paths

Headless execution uses the same public registration and error model with a mode-specific runtime configuration. It is the primary path for tests that do not need a presentation surface, not an undocumented alternative API.

Shutdown is owned by the app lifecycle: stop callbacks/work, release runtime-owned services in an orderly way, and let renderer/platform objects close through their owners. Do not make a domain module close a global window, VM, or renderer in response to local state.

## Change checklist

When a change crosses two layers, answer these questions before implementation:

1. Which module owns the primary mutable state after the change?
2. What concrete call, command, registry, or message creates the dependency?
3. Does the normal lifecycle cover create, update, failure, teardown, and restore?
4. Is there a generated API/spec/example/test update required by a public contract change?
5. Can the same behavior run headlessly, and if not, is the unsupported path explicit?

## Related documents

- [Render Pipeline](render-pipeline.md)
- [Lua--Rust Boundary](scripting-bridge.md)
- [Module Scope Boundaries](module-scope-boundaries.md)
- [Runtime Tooling Boundaries](runtime-tooling-boundaries.md)
- [Philosophy and Constraints](philosophy.md)
