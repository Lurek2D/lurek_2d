# IDEA.md — `animation` module

> Migrated from `ideas/features/animation.md`.
> Status checked against `src/animation/` and `src/lua_api/animation_api.rs`.

---

## Features

### ❌ TODO — Spine Bridge
**Source**: features/animation.md — Feature Gaps #4 / Suggestions #5

`src/spine/` and `src/animation/` are independent. There is no API for animation clips to drive
bone transforms in the Spine module. Requires design alignment between both modules.

---

### 🤔 CONSIDER — Tween/Property Animation Ownership
**Source**: features/animation.md — Structural Issues

Property tweening (`move X from 0 to 100 over 2 seconds`) falls in a gap between `animation`
and `math` modules. The dedicated `tween` module (`src/tween/`) exists — ensure it is clearly
documented as the canonical owner and cross-link from `lurek.animation` docs.
