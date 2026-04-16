# IDEA.md — `spine` module

> Migrated from `ideas/features/spine.md`.
> Status checked against `src/spine/` and `src/lua_api/spine_api.rs`.
> Lua namespace: `lurek.spine`.

---

## Features

### ❌ TODO — Spine JSON / DragonBones File Import
**Source**: features/spine.md — Feature Gaps #8 / Suggestions #3+4

No file format import. Artists use Spine and DragonBones export pipelines. Without
import support, must build skeletons programmatically (very tedious).

---

### ❌ TODO — Mesh Deformation (Vertex Skinning)
**Source**: features/spine.md — Feature Gaps #3

Slots bind sprites only — no mesh deformation by bone weights. Limits animation to
rigid piece (paper-doll) style.

---

### 🤔 CONSIDER — Rename to `skeleton` Module
**Source**: features/spine.md — Structural Issues

`lurek.spine` implies compatibility with the Spine animation tool. Since there's
no Spine file import and this is a custom implementation, `lurek.skeleton` is more
accurate and avoids confusion.

---

### 🤔 CONSIDER — Bridge with `animation` Module
**Source**: features/spine.md — Structural Issues

`animation` handles frame-based clips. `spine` handles bone hierarchies. Merging
into a unified animation system with sub-systems would improve ergonomics:
- `lurek.animation.newClip()` — existing frame-based
- `lurek.animation.newSkeleton()` — current spine
- `lurek.animation.newTimeline()` — new keyframe-over-bone
