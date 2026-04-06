# `spine` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Unassigned |
| **Status** | Implemented — Full |
| **Lua API** | `luna.spine` |
| **Source** | `src/spine/` |
| **Rust Tests** | `tests/unit/spine_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_spine.lua` |
| **Architecture** | — |

## Summary

The `spine` module implements skeletal 2D animation through bone hierarchies, slots, and
world-transform propagation. It is a Tier 2 Engine Extension with no GPU dependencies.

`Skeleton` owns a named bone tree and a list of attachment `Slot` values. `Bone` stores
local transform data (position, rotation, scale, shear) relative to its parent bone.
`Skeleton::update_world_transforms()` propagates local transforms down the hierarchy via
depth-first traversal, computing the final world-space positions needed by the renderer.

Slots associate sprite/region attachments with bones for the `lua_api` rendering pass.
The design is influenced by the Spine runtime data model but does not require the Spine SDK;
all types are custom Rust implementations with no licence restrictions.

Scripts create skeletons via `luna.spine.*`, update bone transforms each frame, call
`update_world_transforms()`, and then issue draw calls through `lua_api`.

**Scope boundary**: GPU rendering of bone-attached sprites is handled by `lua_api`. This
module holds only the bone graph data and transform propagation logic.
## Architecture

```
spine (module root)
  ├── bone.rs — TODO: describe
  ├── skeleton.rs — TODO: describe
  ├── slot.rs — TODO: describe
```

## Source Files

| File | Purpose |
|------|---------|
| `bone.rs` | TODO: describe |
| `skeleton.rs` | TODO: describe |
| `slot.rs` | TODO: describe |

## Submodules

### `spine::bone`

TODO: describe submodule purpose

- **`Bone`** (struct): TODO: one-line description.

### `spine::skeleton`

TODO: describe submodule purpose

- **`BoneParams`** (struct): TODO: one-line description.
- **`Skeleton`** (struct): TODO: one-line description.

### `spine::slot`

TODO: describe submodule purpose

- **`Slot`** (struct): TODO: one-line description.

## Key Types

### Structs

#### `spine::bone::Bone`

TODO: description from `///` doc comment.

#### `spine::skeleton::BoneParams`

TODO: description from `///` doc comment.

#### `spine::skeleton::Skeleton`

TODO: description from `///` doc comment.

#### `spine::slot::Slot`

TODO: description from `///` doc comment.

### Enums

No public enums.

## Lua API

Exposed under `luna.spine.*` by `src\lua_api\spine_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `spine`.

## Lua Examples

```lua
-- Example: Basic spine usage
function luna.load()
    -- TODO: replace with real spine setup
    local obj = luna.spine.spine()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 4 |
| `enum`   | 0 |
| `fn`     | 0 |
| **Total** | **4** |

## References

| Module | Relationship | Notes |
|--------|--------------|-------|
| `engine` | Imports from | Uses SharedState, EngineError |
| `math` | Imports from | Vec2, Color, Rect |
| `lua_api` | Imported by | Binds public API to Lua |

TODO: Add entries for similar modules and explain the separation of duties.

## Notes

TODO: Document unique facts an agent must know before editing this module:
- External crate constraints (version, thread-safety, API limitations)
- Hardware or OS-specific behaviour (e.g., headless fallback on CI)
- Known limitations or intentional omissions
- Best practices and anti-patterns for this module
- What Lua scripts will break if the API changes
