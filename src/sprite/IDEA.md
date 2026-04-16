# IDEA.md — `sprite` module

> Migrated from `ideas/features/graphics.md` (sprite / atlas sections).
> Status checked against `src/sprite/` and `src/lua_api/sprite_api.rs`.
> Lua namespace: `lurek.sprite`.

---

## Features

### ❌ TODO — Runtime Atlas Packing (Batch Textures → Single GPU Page)
**Source**: features/graphics.md — Feature Gaps #1 / performance/02-gpu-rendering.md — Opportunity 2

No runtime atlas packer that takes multiple loaded textures and packs them into shared
GPU pages to reduce texture switching. This is the highest-ROI batching improvement —
reduces 200+ draw calls to 3–5 for a typical sprite-heavy game.

Suggested API:
```lua
local atlas = lurek.sprite.newAtlasPacker(2048, 2048)
atlas:add("player", player_img)
atlas:add("enemy", enemy_img)
local packed = atlas:pack()  -- returns SpriteAtlas + backing texture
```

---

### ❌ TODO — Normal Map / Lit Sprite Support
**Source**: general engine completeness

No normal map channel binding for lit 2D sprites (useful with `lurek.light` module).
Currently lighting and sprites are decoupled — a lit-sprite path would link them.

---

### ❌ TODO — Sprite Flip (flipX / flipY) as First-Class Atlas Feature
This item was moved above and marked DONE — see above.

---

### 🔇 LOW — Binary Atlas Format (Faster Load)
**Source**: general performance

JSON parsing at startup for large atlases adds measurable load time. A compiled binary
format (e.g. flat binary UV table) would load faster. Low priority unless atlas files
exceed ~5000 regions.
