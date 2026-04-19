# P7 — Plugin Candidates (TODO(plugin) Synthesis)

> Generated: 2026-04-18 | Session: src-module-review-20260418

## Summary

69 TODO(plugin) entries found across all 49 modules. Each module was assessed for plugin candidacy per the tiering system in `docs/architecture/plugins.md`.

## Tier Classification

### CORE-KEEP (cannot be extracted — 33 modules)

These modules are fundamental to the engine and cannot be meaningfully extracted as optional plugins.

| Module | Rationale |
|--------|-----------|
| **math** | Foundational to every subsystem (render, physics, input, camera, tilemap, ai, particle) |
| **log** | Required by every module; no binary savings |
| **data** | Used by save, network, asset, serial modules |
| **serial** | Used by save, data, config loading, Lua bridge; all format drivers share SerialValue |
| **event** | Central dispatch hub; every input/window/automation event flows through it |
| **timer** | Every game loop needs clock + scheduler |
| **thread** | Asset loaders, AI workers, compute shaders depend on Channel/ThreadPool |
| **runtime** | Dependency root; every module imports from it |
| **app** | Engine entry point and event loop owner |
| **bin** | Binary entry point |
| **ecs** | Entity lifecycle is tightly integrated |
| **scene** | Scene management is core to game flow |
| **patterns** | Cross-cutting patterns used by multiple modules |
| **window** | Fundamental to every game |
| **input** | Fundamental to every interactive game |
| **filesystem** | Sandbox contract; required by every game |
| **render** | Core rendering pipeline |
| **camera** | SharedState holds Camera; render pipeline consumes camera-generated RenderCommands |
| **sprite** | Fundamental 2D rendering primitive |
| **animation** | Sprite animation used by every game with moving sprites |
| **tween** | Property tweening fundamental to UI, gameplay, camera |
| **image** | ImageData foundational to rendering, testing, effects, animation |
| **physics** | Fundamental to 2D games; rapier2d is sole dynamics backend |
| **tilemap** | Central to 2D games; used by majority of demos |
| **save** | Fundamental game feature; lightweight (~450 lines) |
| **effect** | Core visual effects pipeline |
| **light** | Core lighting system |
| **devtools** | Debug tooling needed during development |
| **debugbridge** | Remote debugging infrastructure |
| **mods** | Mod management |
| **docs** | Runtime documentation catalog |
| **graph** | Data structure module |
| **compute** | Numeric computation foundation |

### TIER-1-PLUGIN (extractable with significant binary savings — 4 modules)

These modules have heavy external dependencies and no reverse engine dependencies beyond lua_api.

| Module | Est. savings | Key deps | Rationale |
|--------|-------------|----------|-----------|
| **network** | ~2–5 MB | rusty_enet, ureq, tungstenite, rmp-serde, rustls | Single-player games don't need networking; no reverse deps except lua_api/network_api.rs |
| **audio** | ~1–3 MB | rodio | Headless/server games can skip sound; heaviest non-GPU dependency |
| **particle** | ~50 KB | fastrand | Self-contained; no inbound non-lua_api callers; ~1800 LOC removable |
| **automation** | ~20 KB | none | Self-contained test/macro automation; games without recording don't need it |

### TIER-2-PLUGIN (extractable as optional feature or pure-Lua library — 6 modules)

| Module | Extraction form | Rationale |
|--------|----------------|-----------|
| **pipeline** | Cargo feature or pure-Lua library | Pure algorithm module; no Rust-specific deps beyond log; could migrate to content/library/pipeline/ |
| **parallax** | Cargo feature | Self-contained; no inbound non-lua_api callers; minimal deps |
| **i18n** | Cargo feature | Zero deps on render/audio/physics; opt-in for games needing localization; ~400 lines |
| **procgen** | Cargo feature | Level generation is game-specific; many games use hand-crafted levels |
| **raycaster** | Cargo feature | 2.5D raycasting is niche; most 2D games don't use it |
| **dataframe** | Cargo feature | Data analysis is optional; games without analytics don't need it |

### Sub-Module Plugin Candidates (within CORE-KEEP modules)

| Module | Candidate | Tier | Description |
|--------|-----------|------|-------------|
| **light** | normal-map lighting | TIER-2 | Candidate for a `light-normalmap` plugin |
| **effect** | per-sprite effects | TIER-2 | Candidate for a `sprite-fx` plugin |
| **effect** | advanced weather | TIER-2 | Candidate for a `weather-advanced` plugin |

## Binary Impact Estimate

| Extraction | Modules | Est. binary reduction |
|------------|---------|----------------------|
| TIER-1 all | network + audio + particle + automation | ~3–8 MB |
| TIER-2 all | pipeline + parallax + i18n + procgen + raycaster + dataframe | ~500 KB – 1 MB |
| **Total potential** | 10 modules | **~4–9 MB** |

## Recommended Extraction Order

1. **network** (highest impact, no reverse deps)
2. **audio** (high impact, clean boundary)
3. **raycaster** (niche feature, clean boundary)
4. **procgen** (game-specific, clean boundary)
5. **dataframe** (optional analytics)
6. **parallax** (minor savings, clean boundary)
7. **pipeline** (consider pure-Lua migration first)
8. **i18n** (low priority, small module)
9. **particle** (moderate savings)
10. **automation** (minimal savings)
