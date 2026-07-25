# Module Scope Boundaries

## Purpose

These contracts resolve module pairs that can otherwise duplicate state or policy. Each pair has one primary owner; the neighbor consumes data or calls a narrow API.

## General Rules

- One mutable state model has one owner.
- Lower-level modules expose neutral data or algorithms; higher-level modules apply runtime or presentation policy.
- A cache, snapshot, serialized payload, or renderer command is derived state.
- Cross-module orchestration belongs in the higher-level owner or an explicit adapter, not in duplicated schedulers.
- Public registration remains in `src/lua_api/`.

## Module Layers And Dependency Direction

This is the canonical layer model for Rust modules under `src/`. It classifies
responsibility; it is not a requirement that every module in one row be
isolated from every other module in that row. The hard rule is an acyclic
dependency graph and a single authority for mutable state.

```text
                 Composition root
               app + runtime lifecycle
                        |
                        v
             Edge / Integration layer
       lua_api, devtools, debugbridge, docs, automation
                        |
                        v
                Feature systems
   scene, ui, physics, tilemap, sprite, animation, ...
                        |
                        v
                Platform services
 render, window, input, audio, filesystem, network, thread
                        |
                        v
             Core runtime contracts
       errors, IDs, configuration, commands, shared runtime seams
                        |
                        v
                  Foundations
 math, binary, serialize, compute, dataframe, graph, procgen, patterns
```

The diagram shows the normal direction of dependency: a row can depend on a
lower row through its public contract. A module may also depend on a stable
peer when that does not create a cycle or duplicate state ownership. `app` is
the composition root, not a reusable feature module: it may assemble the
layers but lower layers never import it.

| Layer | Module type and responsibility | Allowed relationships | Prohibited relationships |
|---|---|---|---|
| Foundations | Stateless or self-contained algorithms, value types, encoding, and data transforms. | May depend on the standard library and other stable foundation modules. | No dependency on windowing, GPU/rendering, audio, input, physics, Lua registration, or application lifecycle. |
| Core runtime | Shared lifecycle contracts, errors, configuration, identity, commands, and neutral runtime services. | May depend on foundations; platform and feature modules consume its contracts. | Does not own a game feature, UI, renderer backend, host event loop, or Lua public API. |
| Platform services | OS, device, transport, storage, rendering, audio, and worker-thread boundaries. | May depend on foundations and runtime contracts; features call their public seams. | Does not own scene, widget, gameplay, map, or other feature-system state. |
| Feature systems | Domain state and rules such as scene, UI, physics, tiles, sprites, effects, maps, AI, progression, and gameplay services. | May depend on foundations, runtime contracts, and platform facades; stable feature-to-feature dependency is allowed when acyclic. | Does not reach into platform backends, own the application loop, or register Lua names. |
| Edge / integration | Translation and optional developer-facing adapters: `src/lua_api/`, diagnostics, docs, automation, and debug bridges. | May translate calls to lower-layer public owners and may observe their state through explicit APIs. | Is never imported by a foundation, runtime, platform, or feature module; it does not become a second state owner. |
| Composition root | `app` and lifecycle assembly. | Creates and wires services, Lua, callbacks, and frame order; may know every layer. | Is not imported by any lower layer and does not absorb domain algorithms. |

### Required Dependency Edges

- `app` creates the runtime state and wires platform services, feature stores,
  and `src/lua_api/` registration.
- `src/lua_api/` converts Lua values, validates handles, calls the Rust owner,
  and translates errors back to Lua. It does not contain feature algorithms.
- Feature systems submit resolved draw or audio work through `render` and
  `audio` contracts; they do not own GPU/device resources or mixer state.
- Tools use explicit registries, generated metadata, or public APIs. They do
  not become dependencies of runtime features.

### Choosing A Layer

Choose the lowest layer that can enforce the module's invariant. Move a module
up only when it must own a domain policy or translate across a boundary. If two
modules need each other's private state, redesign the shared contract or merge
the responsibility; do not introduce a cycle.

## Pair Contracts

### Image And Render

`image` owns CPU pixel buffers, import/export, diffs, and CPU transformations. `render` owns uploaded textures, GPU targets, and submission.

### Sprite And Animation

`sprite` owns drawable sprite state and batching inputs. `animation` owns time-based sequence and pose progression. Animation updates sprite-facing data; it does not own GPU resources.

### Scene And App/Runtime

`scene` owns scene registration, stack state, scene-local callback policy, and traversal. `app`/`runtime` owns the application loop and decides when scene processing is invoked.

### UI And Render/Input

`ui` owns widget identity, layout, focus, interaction, and resolved UI draw data. `input` owns device state. `render` draws resolved output; neither input nor render owns widget state.

### Tilemap And Tilefield

`tilemap` owns authored/imported map structure and tileset interpretation. `tilefield` owns scalable runtime tile storage and field-oriented operations. Conversion creates data for the target owner rather than shared mutable authority.

### Effect, Overlay, Particle, Image, And Render

The durable split is defined in [Effects, Particles, Image, And Overlay Boundaries](effects-particles-overlay-plan.md).

### Filesystem, Mods, And Asset

`filesystem` resolves approved paths and file operations. `mods` applies sandbox/mod policy. `asset` catalogs validated loaded resources. Raw path access never becomes asset ownership.

### Docs, Validator, Grep, Log, And Devtools

The durable split is defined in [Runtime Tooling Boundaries](runtime-tooling-boundaries.md).

### Save And Serialize

`serialize` owns value encoding/decoding. `save` owns slots, metadata, versions, and persistence workflow. Serialized bytes are not primary live state.

### Network And Domain Modules

`network` owns transport, connection, and protocol delivery. Domain modules own the meaning and validation of payloads after decoding.

## Enforcement

- New dependencies identify the concrete call, message, shared registry, generated data, or filesystem edge.
- Changes that introduce a second mutable owner are architecture defects.
- Public APIs use a documented fallback when an optional neighbor is absent.
- Specs may link here for durable scope, but per-function catalogs remain generated.
