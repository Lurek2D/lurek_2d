# Lurek2D - Modularity and Plugins Architecture

## TL;DR

- Consolidated governance for advanced feature surfaces and plugin extraction planning.
- Status: Proposed for plugin rollout phases; classification and gates are active governance rules.

Companion documents: [philosophy.md](philosophy.md) · [engine-core.md](engine-core.md)

---

## Purpose

The API gap review raised a valid product-shape concern: Lurek2D exposes unusually broad systems for a compact 2D runtime, including AI, numerical compute, tabular data and SQL-style queries, globe/province strategy maps, and raycasting.

This document turns that concern into an architecture decision framework:

- These modules are **intentional advanced feature surfaces** in the current repository.
- They are not removed, renamed, or extracted by this note.
- They must remain consistent with the binding constraints in [philosophy.md](philosophy.md), especially runtime-only scope (A-01), 2D-only graphics (A-03), 60 FPS target (B-03), `lurek.*` namespace discipline (C-01), no cycles (T-03), and thin Lua bindings (TST-03).
- Any future optional-module or plugin decision must be based on measured pressure, not on the mere presence of advanced APIs.

---

## Classification Model

| Classification | Meaning | Default handling |
|---|---|---|
| **Core surface** | Required for most games and beginner examples. | Keep in the main learning path and default docs. |
| **Advanced feature surface** | Broad capability useful to simulations, tools, data-rich games, or advanced scripts, but not required for a first game. | Keep supported; contain docs and examples so beginners can ignore it. |
| **Genre-specialized feature surface** | Built for a specific game family while still obeying Lurek2D constraints. | Keep supported; present as optional learning path, not as core identity. |
| **Optionalization candidate** | A surface with measured size, dependency, performance, maintenance, or product-fit pressure. | Do not optionalize until the future gates in this note pass. |
| **De-emphasis candidate** | A surface that remains supported but should move out of quick-start and beginner-first docs. | Keep API stable; change docs/navigation only after a product decision. |

---

## Current Classification Table

| Surface | Current module group | Classification now | Why it is intentional now | Containment rule | Future decision pressure |
|---|---|---|---|---|---|
| `lurek.compute` / `src/compute/` | Foundations | Advanced feature surface | Provides CPU-only numerical arrays, signal processing, linear algebra, and spatial helpers for simulations, image/data processing, and advanced scripts. | Must remain GPU-free, engine-state-free, and lower-tier. It must not become the normal way to represent lightweight `Vec2` or `Vec3` gameplay values. | Binary size, compile cost, API-doc footprint, or confusion with simple math vectors. |
| `lurek.dataframe` / `src/dataframe/` | Foundations | Advanced feature surface | Provides in-memory tabular data, analytics, serialization, async tasks, and data-rich workflow support. Useful for strategy games, dashboards, procedural content, and tooling-like screens. | Must stay storage-agnostic at the domain layer. GameFS and Lua concerns stay at the boundary. Long-running work must use Rust workers rather than blocking the main Lua VM. | Binary size, dependency weight, beginner-doc noise, or a product decision that tabular analytics should be delivered as an add-on. |
| `LDatabase` and SQL-style queries inside `lurek.dataframe` | Foundations, under `dataframe` | Advanced feature surface | The SQL surface is an in-memory query catalog for local `DataFrame` tables, not an external database platform. It supports data-heavy game logic without adding a server or platform SDK. | Must not become a platform database integration. It must not introduce external DB processes, blocking Lua I/O, or non-GameFS storage assumptions. | Query-engine maintenance cost, API complexity, or a measured need to split query support from basic dataframes. |
| `lurek.ai` / `src/ai/` | Feature Systems | Advanced feature surface | Game AI is a valid 2D engine feature for NPCs, simulations, agents, and modder-authored behavior. The current contract is CPU-oriented and headless-testable. | Must stay game-behavior focused. Domain code must not import `lua_api`; debug rendering must remain a projection/output path, not the core owner of AI logic. | Learning-surface size, maintenance burden of ML/planning subareas, or product choice to expose only a smaller AI starter kit by default. |
| `lurek.globe` / `src/globe/` | Feature Systems | Genre-specialized feature surface | Supports geoscape and grand-strategy style maps while preserving the A-03 rule: output is 2D draw commands projected from spherical data, not a 3D scene graph. | Must not add a 3D renderer, perspective scene pipeline, or platform SDK dependency. Projection remains data-to-2D-render-command transformation. | Product decision that grand-strategy support should be a plugin or advanced package, or measured size/performance pressure. |
| `lurek.province` / `src/province/` | Edge/Integration, per current spec | Genre-specialized feature surface | Provides province-map runtime, topology, import, rendering commands, visibility state, and strategy-map economy helpers for map-painting games. | Must keep imports one-way and acyclic. PNG/CSV/TOML import is acceptable; editor or platform integration does not move into the core binary. | Product decision to move grand-strategy map tooling outside the default runtime, or measured binary/API maintenance pressure. |
| `lurek.raycaster` / `src/raycaster/` | Feature Systems | Genre-specialized feature surface | Provides pseudo-3D 2.5D raycasting for retro first-person games while staying within A-03: grid raycasts emit 2D/textured quads and software debug images. | Must not become a general 3D engine, 3D scene graph, or alternate renderer backend. It remains a 2D grid/ray projection system. | Product concern that raycasting weakens the 2D identity, or measured rendering/API maintenance pressure. |
| `lurek.ui` / `src/ui/` | Feature Systems | Advanced but core-adjacent UI surface | Native retained widgets, themes, focus, layouts, charts, tables, and TOML-authored screens are the single supported in-engine UI path for menus, HUDs, tools, and data-rich games. | Keep widget, theme, input, retained state, and TOML-layout concerns here. Do not reintroduce a parallel DOM/CSS UI stack. | Only docs de-emphasis is plausible now; extraction would need strong product and compatibility evidence. |

---

## Plugin Architecture (Proposed)

### Goals

- **Core binary â‰¤ 10 MB stripped** on Windows / Linux / macOS x86_64 + ARM â€” constraint **A-05 (Proposed)**.
- **Optional features ship as plugins**, not compile-time `cfg` thickets. A user who needs only sprites + audio + input must not pay binary size for AI, raycasting, dataframes, or the in-game terminal.
- **Documented third-party extension surface.** Community authors building Steam SDK wrappers or custom physics adapters plug in via a stable Rust crate API rather than forking the engine.
- **Zero-config user path.** Running `lurek2d main.lua` gets a working renderer, audio, input, filesystem, window, camera, timer, event, ECS, scene, sprite, and tilemap out of the box.

### Non-Goals

- Hot-reload of native plugins at runtime (reserved for pure-Lua content in `library/`)
- Arbitrary FFI sandboxing â€” plugins run with the same trust as the core engine
- Mobile / WASM plugins â€” constraint A-02 keeps the project desktop-only
- A package manager or marketplace
- Replacing pure-Lua extensibility â€” Lureksome libraries in `library/` remain the recommended path for game-side reuse

---

## Why Plugins

The current `src/` tree is dominated by large, optional-by-nature modules. Evidence from `work/docs-api-arch-specs-review-20260418/reports/P1_EVIDENCE.md`:

| Module | LOC | Used by typical 2D game? |
|--------|----:|--------------------------|
| `ai` | 7 860 | No â€” most games ship a custom FSM |
| `tilemap` | 7 776 | Yes â€” fundamental primitive |
| `ui` | 6 882 | Sometimes â€” many games use custom Lua UI |
| `pathfind` | 5 880 | Only with `ai` or strategy games |
| `physics` | 4 921 | Often â€” but heavy `rapier2d` tree |
| `dataframe` | 4 411 | No â€” power-user only |
| `raycaster` | 3 670 | No â€” Wolfenstein-style only |
| `compute` | 3 652 | No â€” specialist GPU workloads |

Extracting optional-by-nature modules and their heavy crate trees (`rapier2d`, `rusty_enet`, `tungstenite`, `csv`) saves conservatively **3â€“6 MB** on a stripped Linux release plus reduced compile times. Smaller binaries also clear Windows Defender and macOS Gatekeeper faster on first launch.

Constraint **A-05** formalises this argument so it cannot be eroded by single-PR feature creep.

---

## Plugin Model

A Lurek2D plugin is a Rust crate that:

1. **Registers Rust types** into `runtime::shared_state` pools or as standalone subsystems
2. **Registers a `lurek.<namespace>` Lua surface** using the same thin-binding pattern as `src/lua_api/` (Zen Rule 12, C-02)
3. **Provides explicit init / teardown hooks** for deterministic lifecycle
4. **Owns its own tests, docs, and Lua API reference**

Plugins are **NOT** pure-Lua libraries (`library/`), game scripts (`content/games/`), asset bundles, or sandboxed mods (`mods` module).

**Registration shape (C-02 compliant):**

```rust
pub fn register(
    lua: &Lua,
    lurek: &LuaTable,
    state: Rc<RefCell<SharedState>>,
) -> LuaResult<()>;
```

**Lifecycle:**

```
App::new(config)
   â†’ PluginRegistry::discover()
   â†’ for each plugin in load order:
       plugin.on_load(state)
       plugin.register_lua(lua, ...)
   â†’ lurek.init()   â† game fires; plugin tables are visible
   ... game runs ...
App::shutdown()
   â†’ for each plugin in reverse load order:
       plugin.on_unload(state)
```

Load order: CORE-KEEP (Foundations â†’ Core Runtime â†’ â€¦) then TIER-1 (alphabetical) then TIER-2 (declaration order in `conf.lua`).

---

## Plugin Tiers

| Tier | Distribution | Loaded | Disable strategy |
|------|-------------|--------|----------------|
| **CORE-KEEP** | Compiled into binary | Always | Cannot be disabled |
| **TIER-1-PLUGIN** | Separate `.dll`/`.so`/`.dylib` next to binary | At startup if file is present | Delete file or `[plugins] disabled = ["ai"]` in `conf.toml` |
| **TIER-2-PLUGIN** | Built and shipped, not loaded unless game opts in | When `conf.lua` declares `plugins = { "physics" }` | Game omits the entry |
| **THIRD-PARTY-PLUGIN** | Built by community author | Like TIER-1 or TIER-2 | User does not install it |

**CORE-KEEP modules** (always compiled in): `math`, `log`, `data`, `serial`, `runtime`, `event`, `timer`, `thread`, `filesystem`, `render`, `audio`, `input`, `image`, `window`, `camera`, `light`, `effect`, `ecs`, `scene`, `animation`, `tween`, `particle`, `tilemap`, `sprite`, `i18n`, `graph`, `automation`, `app`, `lua_api`, `bin`, plus docs-general and tooling Edge modules.

---

## Candidate Modules

Sorted by tier then LOC descending. Per user decision **D-1**, `physics` is TIER-2-PLUGIN.

| Module | LOC | Heavy deps | Tier | Rationale |
|--------|----:|-----------|------|-----------|
| `ai` | 7 860 | none | TIER-1 | Largest optional surface. Most games don't need engine-level FSM/BT/GOAP/HTN/MCTS. |
| `ui` | 6 882 | none | TIER-1 | Opinionated widget set; many games author UI in Lua directly. |
| `pathfind` | 5 880 | none | TIER-1 | Paired with `ai`; co-extracted. |
| `raycaster` | 3 670 | none | TIER-1 | Wolf3D-style 2.5D only. Self-contained. |
| `dataframe` | 4 411 | `csv` | TIER-1 | Power-user analytics; orthogonal to gameplay. |
| `network` | 2 295 | `rusty_enet`, `ureq`, `tungstenite`, `rmp-serde` | TIER-1 | Heavy HTTP+WS+ENet+TLS tree. Most games are offline. |
| `terminal` | 2 606 | none | TIER-1 | In-game dev REPL. Dev-only for shipping games. |
| `spine` | 1 328 | custom Spine runtime | TIER-1 | Proprietary format; niche. |
| `physics` | 4 921 | `rapier2d`, `rayon` | TIER-2 | Heavy tree but most 2D games eventually need a solver. Default ON in templates. |
| `compute` | 3 652 | none | TIER-2 | GPU compute is specialist. |
| `procgen` | 3 021 | none | TIER-2 | Keep noise/Perlin in core; move L-systems/WFC/dungeon generators. |
| `mods` | 672 | none | TIER-2 | Sandboxed mod loader; opt-in per game. |
| `minimap` | 1 574 | none | TIER-2 | Candidate for pure-Lua reimplementation in Lureksome. |
| `parallax` | 708 | none | TIER-2 | Tiny; strongest Lureksome reimplementation candidate. |
| `save` | 803 | `serde` | TIER-2 | Thin wrapper over `filesystem` + `serial`; could become Lureksome. |
| `debugbridge` | â€” | TCP/WS server | TIER-2 | Dev-only. Already optional by intent. |

**Coupling refactor required before extraction.** `src/runtime/shared_state.rs` currently holds `parallax`, `particle`, `raycaster`, `tilemap`, and `ui` via direct `use crate::<m>` imports. Plugin extraction requires first introducing a `SharedState` extension trait or per-plugin registration table â€” migration step M1.

---

## Loading Mechanism Options

### Option A â€” Cargo features (recommended for v1)

Each plugin candidate becomes a Cargo feature on the root crate. Single binary; `--no-default-features --features minimal` build excludes unrequested modules.

**Pros:** Zero ABI risk, no `unsafe`, no dynamic loader code, all-Rust toolchain.  
**Cons:** Not third-party-extensible; produces multiple binary SKUs; `conf.lua` `plugins = {...}` is advisory only.  
**Recommendation:** Ship this for v1.

### Option B â€” `libloading` dynamic libraries (post-v1)

Each plugin builds as a `cdylib`. Engine scans `plugins/` next to binary at startup and `dlopen`/`LoadLibrary`s each one.

**Pros:** True third-party plugins; Steam SDK wrapper drops in cleanly.  
**Cons:** Rust has no stable ABI on stable channel; plugin + engine must agree on exact rustc + `mlua` versions.  
**Recommendation:** Defer to post-v1 (migration step M4). Use only for Steam SDK and similar.

### Option C â€” Pure Lua (already available)

Many candidates can be reimplemented in pure Lua against existing `lurek.*` APIs. Lureksome (`library/`) is the right home.

**Recommendation:** Use for `parallax`, `minimap`, `save`, and any candidate whose Rust footprint is mostly bookkeeping.

**Recommended hybrid for v1:** Option A for engine modules + Option C for thin Lua wrappers, with Option B reserved for post-v1 third-party/platform SDK plugins.

---

## Stability and ABI Contract

The plugin Rust API is a single trait plus a registration helper in the planned `lurek_plugin_api` crate (only `mlua` + `runtime` types as public dependencies):

```rust
pub trait LurekPlugin: Send {
    fn name(&self) -> &'static str;
    fn register_lua(&self, lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()>;
    fn on_load(&self, state: Rc<RefCell<SharedState>>) -> Result<(), EngineError> { Ok(()) }
    fn on_unload(&self, state: Rc<RefCell<SharedState>>) -> Result<(), EngineError> { Ok(()) }
    fn abi_version(&self) -> u32 { CURRENT_ABI_VERSION }
}
```

**For Option B (dynamic) only**, plugins additionally export a C entry point inside a panic boundary:

```rust
#[no_mangle]
pub extern "C" fn lurek_plugin_init() -> *mut dyn LurekPlugin { ... }
```

Engine wraps the call in `std::panic::catch_unwind`, refuses to load panicking plugins, never re-enters a panicked plugin.

**Versioning policy:** `LurekPlugin` is semver-locked on `lurek_plugin_api`. Major bump = ABI break = all plugins must be rebuilt. Compatibility: binary-compatible within a MAJOR.MINOR series (0.20.x â†’ 0.20.y). PATCH bumps never break ABI; MINOR bumps may add methods with default impls; MAJOR bumps are free to break.

**Plugin manifest** (`plugin.toml`): `name`, `version`, `min_engine_version`, `max_engine_version` are required. Engine refuses to load plugins outside the supported engine version range.

---

## Discovery and Configuration

Plugins declared in `conf.lua` (or `conf.toml`):

```lua
function lurek.conf(t)
    t.window.width  = 1280
    t.plugins = { "physics", "ai", "raycaster" }
end
```

```toml
[plugins]
enabled  = ["physics", "ai", "raycaster"]
disabled = ["terminal"]

[plugins.physics]
gravity_y = -9.81
allow_sleep = true
```

`enabled` is the authoritative list. `disabled` is consulted only for auto-discovered TIER-1 plugins â€” lets a user keep a `.dll` on disk while turning it off. Conflicts (`enabled` and `disabled` listing the same plugin) raise a boot error.

Conf-file precedence: `conf.toml` preferred, `conf.lua` legacy fallback. Plugins inherit that rule.

---

## Migration Plan

All steps keep `cargo test` green throughout.

| Step | Goal | Gate |
|------|------|------|
| **M1** â€” Untangle `shared_state` | Introduce extension trait / typed registry so the five candidate pools (`parallax`, `particle`, `raycaster`, `tilemap`, `ui`) are no longer direct `use crate::<m>` imports in `runtime`. | Removing one module no longer breaks compile in `runtime`. |
| **M2** â€” Cargo features | Introduce features `plugin-ai`, `plugin-ui`, `plugin-raycaster`, `plugin-physics`, etc. Default is everything-on. CI gains a build matrix. | Every matrix cell builds; `cargo test --features <name>` passes. |
| **M3** â€” Size enforcement, A-05 promotion | Flip default features off for `minimal`. Measure stripped binary on all three platforms. If â‰¤ 10 MB, promote A-05 to Active, add CI size budget gate. | A-05 Active; CI size budget green on Windows / Linux / macOS. |
| **M4** â€” Dynamic plugins (optional) | Add `libloading` path behind `dynamic-plugins` feature. Port `raycaster` as proof. Document third-party plugin workflow. | `raycaster.dll/.so/.dylib` loads on all platforms; in-tree `raycaster` disappears from static binary. |

---

## Comparison to Other Engines

| Engine | Plugin model | Core size |
|--------|-------------|---------|
| LĂ–VE | None â€” plain Lua libs or LuaJIT FFI | ~6 MB |
| Solar2D | Lua frontend + native plugin server | ~6â€“10 MB |
| Godot | GDExtension (stable C ABI since 4.1) | ~60â€“100 MB |
| Lurek2D (proposed) | Cargo features (M2/M3), Lureksome Lua libs, optional `libloading` (M4) | **â‰¤ 10 MB stripped (A-05)** |

Position: simpler than Godot's GDExtension (no full ABI surface to maintain in v1), more native than RPG Maker's JS, smaller core than LĂ–VE-with-everything-bundled.

---

## Risks and Open Questions

1. **Rust ABI stability.** Option B dynamic plugins on Rust stable require pinning rustc + `mlua` versions exactly. Mitigation: `lurek_plugin_api` crate with a published version table; refuse mismatched plugins.
2. **`shared_state` refactor scope.** M1 touches a hub used by every subsystem. Mitigation: introduce trait first as a no-op refactor, then remove direct imports module-by-module.
3. **Plugin Lua VM access from worker threads.** B-04: LuaJIT VMs cannot share state. Plugin `on_load` must declare whether it spawns workers. Workers cannot register `lurek.*` functions on the main VM after boot.
4. **`dlopen` paths on Linux.** `LD_LIBRARY_PATH`, `RPATH`, and AppImage layouts surface plugins differently. Needs a documented install layout before M4.
5. **Steam SDK licensing.** Steamworks SDK is closed and per-publisher licensed. Wrapper plugin must live in a separate repo; Lurek2D core can never link it.
6. **Lua-candidate evaluation.** `parallax`, `minimap`, `save` could become Lureksome libraries instead of Rust plugins. Decision deferred.
7. **Plugin testing harness.** Each plugin needs its own `tests/lua/` slice. Open: shared harness or per-plugin?
8. **Spec location.** When a module becomes a plugin, its spec stays in `docs/specs/<name>.md` with a "Plugin: TIER-1" header. Tier is also recorded in `docs/specs/README.md`.
9. **VS Code extension integration.** The extension needs to know which plugins are present for IntelliSense and run-with-profile commands. Open: emit `plugins.json` at boot, or parse `Cargo.toml` features?

## Migration Gate Mapping

Transition into migration steps M2 (Cargo features) and M3 (size-budget enforcement and A-05 promotion) requires formal pass of these governance gates before implementation proceeds:

- Product decision gate
- Measurement gate
- Dependency gate

For parallax, minimap, and save, this document keeps them in the candidate matrix as plugin-or-Lua migration candidates. They are not removed from the native matrix at this stage; preferred path is soft deprecation planning in Rust only after pure-Lua parity is validated.
