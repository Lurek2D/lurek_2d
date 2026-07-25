# Engine Core Architecture

## Purpose

This document owns runtime composition, lifecycle order, primary state, and cross-subsystem dependencies. Detailed renderer and Lua-boundary rules live in [Render Pipeline](render-pipeline.md) and [Scripting Bridge](scripting-bridge.md).

## Composition

```text
binary entry
  -> application/bootstrap
      -> window and event loop
      -> renderer and GPU resources
      -> audio and platform services
      -> SharedState and module stores
      -> Lua VM and public API registration
      -> script load and callback discovery
  -> event/frame loop
  -> ordered shutdown
```

- `src/app/` owns desktop application composition and event-loop integration.
- `src/runtime/` owns shared runtime services, Lua execution, callback scheduling, and runtime-wide state access.
- `src/lua_api/` owns the public Lua registration boundary.
- Modules under `src/` own their domain state and algorithms.
- `src/render/` owns GPU objects, render commands, execution, and presentation.

The dependency direction is toward narrower owners. Runtime composition may depend on modules; modules do not own the application loop.

## Startup Lifecycle

1. The binary resolves the requested script or project input.
2. Application bootstrap creates platform state, window/event-loop integration, renderer, and shared services.
3. Runtime construction creates primary module stores and the Lua VM.
4. `src/lua_api/` registers callbacks and `lurek.*` namespaces against shared owners.
5. Game filesystem policy resolves and loads the entry script.
6. The runtime discovers optional lifecycle callbacks and enters the event loop.

Creation is transactional at subsystem boundaries: a failed window, device, audio, script, or registration step returns an error and prevents the normal loop from starting. No document should promise a fallback that the owning code does not implement.

## Frame Lifecycle

The event loop collects platform events and advances runtime work in a stable order:

1. refresh input and window/event state;
2. invoke update/process callbacks that exist and are enabled;
3. advance owned simulations or scheduled systems;
4. collect render-ready commands or snapshots;
5. execute render passes and UI work;
6. submit and present;
7. clear frame-local state.

Callbacks are optional. Missing callbacks are a normal fallback, while callback errors are reported through runtime error handling and must not silently mutate later stages.

## Shutdown And Restore

- Window close, an accepted quit request, or unrecoverable runtime failure leaves the frame loop.
- Owners release callbacks and Lua references before their backing VM is dropped.
- GPU, audio, worker, and platform resources are released by their Rust owners.
- Save/serialization output is a copy. Loading validates external data before replacing or reconstructing owned state.
- A renderer surface loss may recreate surface-dependent resources; it does not transfer ownership to a game module.

## State Authority

| State | Primary owner | Consumer form |
|---|---|---|
| Window and platform events | application/window | events and queries |
| Lua VM and callback registry | runtime/Lua boundary | guarded Lua calls |
| GPU resources and surfaces | renderer | handles and render commands |
| Audio playback | audio | handles and commands |
| Physics world | physics | handles, queries, snapshots |
| Scene stack | scene | scene operations and render/update traversal |
| Game files | filesystem/mods policy | validated virtual paths and bytes |
| Module metadata | `docs/meta/modules.toml` | generated documentation/tool data |

Derived caches, renderer snapshots, and serialized payloads never become co-equal mutable owners.

## Lua Dependency Boundary

`src/lua_api/` is the sole owner of public registration and namespace shape. Some runtime and module files legitimately use `mlua` because they store Lua callbacks or values, including application, runtime, scene, networking, ECS, and AI seams. Those uses must remain internal, document VM lifetime assumptions, and must not create independent public registration.

## Failure Rules

- Invalid external paths fail before file contents reach domain owners.
- Invalid public handles return a Lua-visible error or documented absence; they do not index unchecked state.
- A callback failure is attributed to its callback and surfaced through runtime diagnostics.
- Device/surface recovery rebuilds derived GPU state from renderer-owned sources.
- Worker failures cross to the caller as results or events; worker-owned state is not exposed through unsynchronized references.

## Repository Boundaries

- `lurek_2d_content/`: finished games, design references, and pure-Lua libraries.
- `lurek_2d_extension/`: VS Code extension.
- `lurek_2d_workbench/`: native Workbench.
- `lurek_2d_pages/`: generated site output.
- `content/`: engine-owned examples, layouts, and snippet sources.
- `docs/`: durable documentation sources and generated API/spec artifacts.
