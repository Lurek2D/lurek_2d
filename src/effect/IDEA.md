# IDEA.md — `effect` module

> Migrated from `ideas/features/fx.md` and `ideas/performance/15-postfx-shader-pipeline.md`.
> Status checked against `src/effect/` and `src/lua_api/effect_api.rs`.
> Lua namespace: `lurek.fx`.

---

## Features

### ❌ TODO — Effect on Individual Layers / Sprites
**Source**: features/fx.md — Feature Gaps #6

PostFx stacks apply to the full screen. No per-layer or per-sprite effect found. A sprite
could pass through its own mini-canvas for local bloom or palette swap without affecting
the entire scene.

---

### ❌ TODO — Shader Compile Error Display in Dev Mode
**Source**: features/fx.md — Feature Gaps #7

Shader compilation errors in custom PostFx pass silently break the effect. A dev-mode
fallback (render a magenta/error quad with the WGSL error text) would speed up shader
authoring significantly.

> **Partial**: `lurek.postfx.setShaderErrorDisplay(true/false)` and `getShaderErrorDisplay()`
> are implemented (2026-04-16). The Lua-side toggle exists; GPU-side render path hookup is
> tracked in `docs/specs/effect.md`.

---

### 🤔 CONSIDER — Consolidate Screen Shake (see also `camera`)
**Source**: features/fx.md — Structural Issues

Screen shake appears in both `effect`/overlay system and `camera`. Pick one canonical
location (prefer camera) and remove the other. See `src/camera/IDEA.md`.

---

## Performance
