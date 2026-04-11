# sprite — Module Overview

**Tier:** Platform Services  
**Spec:** `docs/specs/sprite.md`

## Purpose

Sprite handling for Lurek2D: individual sprites with position/scale/rotation/color,
batched sprite rendering, sprite sheets with named frame regions, and nine-slice
scalable sprites for UI panels.

Extracted from `src/render/` during the architecture migration to give sprite
types their own module boundary, separate from the GPU rendering pipeline.

## Source Files

| File | Responsibility |
|---|---|
| `mod.rs` | Module root — re-exports |
| `sprite.rs` | `Sprite` — individual sprite with transform and color |
| `sprite_batch.rs` | `SpriteBatch` — batched sprite renderer |
| `sprite_sheet.rs` | `SpriteSheet` — sprite sheet with named frame regions |
| `nine_slice.rs` | `NineSlice` — nine-slice scalable sprite |

## Full Specification

� [docs/specs/sprite.md](../../docs/specs/sprite.md) (planned)

## Full Specification

→ [docs/specs/sprite.md](../../docs/specs/sprite.md) (planned)

## Full Specification

→ [docs/specs/sprite.md](../../docs/specs/sprite.md) (planned)
