# Tilefield

## Purpose

Coordinates exposed to Lua are one-based x, y, z; Rust storage is zero-based.

## When To Use

- LTileField is a single field with width, height, and one or more levels. This is the default one-level map model.
- LTileFieldMap is a 2D or layered map of shared LTileField handles. Use it when a world is chunked into fields or stacked as layers of fields.
- Supported topologies are square, square4, square8, iso_square, and hex. square/square8 use eight neighbors, but radial range budgets use Euclidean square distance so a diagonal is sqrt(2); square4 uses Manhattan distance, and iso_square uses square gameplay math because projection belongs to tilemap/rendering.

## Minimal Example

Example block: `lurek.tilefield.new`

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 8, height = 8, levels = 2, topology = "square" })
    local w, h, levels = field:getSize()
    local topology = field:getTopology()
    local inside = field:inBounds(8, 8, 2)
    tilefield_log("new field " .. w .. "x" .. h .. "x" .. levels .. " " .. topology .. " inside=" .. tostring(inside))
end
```

## Common Patterns

- Start with `lurek.tilefield.createLightsFromTileset` when exploring this module.
- Start with `lurek.tilefield.createPhysicsFromTileset` when exploring this module.
- Start with `lurek.tilefield.fromProvider` when exploring this module.
- Start with `lurek.tilefield.fromTileMap` when exploring this module.
- Start with `lurek.tilefield.new` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- Coordinates exposed to Lua are one-based `x, y, z`; Rust storage is zero-based.
- `LTileField` is a single field with width, height, and one or more levels. This is the default one-level map model.
- `LTileFieldMap` is a 2D or layered map of shared `LTileField` handles. Use it when a world is chunked into fields or stacked as layers of fields.
- Supported topologies are `square`, `square4`, `square8`, `iso_square`, and `hex`. `square`/`square8` use eight neighbors, but radial range budgets use Euclidean square distance so a diagonal is `sqrt(2)`; `square4` uses Manhattan distance, and `iso_square` uses square gameplay math because projection belongs to tilemap/rendering.
- Channels are intentionally independent: seeing through a cell does not imply acting, moving, or lighting through it.
- Built-in profiles include `empty`, `wall`, `window`, `door_closed`, `door_open`, and `half_wall`.
- The `light` channel and `sunOcclusion` are environment inputs consumed by `lurek.tilelight`; `tilefield` does not store point lights or computed light values.
- Cell refs such as `floor`, `wall_left`, `roof`, or `object` are author-defined slots. They are useful for mapping tile ids, object ids, or block slots onto the same gameplay field without forcing every system to own separate data.

This module is mostly self-contained inside the Feature Systems group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.tilefield.createLightsFromTileset`

Creates normal render lights and occluders from tilefield refs whose tileset objects define `renderLight` or `occluder`.

```lua
lurek.tilefield.createLightsFromTileset(field, slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](#ltilefield) | Source field containing refs. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](#ltileset) | Tileset with tile object metadata. |
| `opts?` | table | `{z?/level?, refIsGid?, originX?, originY?, tileWidth?, tileHeight?}`. |

**Returns**

| Type | Description |
|------|-------------|
| table | `{lights=Llight[], occluders=[LOccluder](#loccluder)[]}`. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    lurek.light.clear()
    local tileset = lurek.tileset.fromProvider({
        firstGid = 1,
        tileCount = 1,
        columns = 1,
        tileWidth = 16,
        tileHeight = 16,
        objects = { torch_wall = { renderLight = { radius = 64, intensity = 1.2, color = { 1, 0.8, 0.4, 1 } }, occluder = { shape = "diamond" } } },
        tileObjects = { [1] = "torch_wall" },
    })
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setRef(1, 1, 1, "tiles", 1)
    local spawned = lurek.tilefield.createLightsFromTileset(field, "tiles", tileset, { refIsGid = true })
    tilefield_log("tileset lights=" .. #spawned.lights .. " occluders=" .. #spawned.occluders)
end
```

---

### `lurek.tilefield.createPhysicsFromTileset`

Creates physics bodies from tilefield refs whose tileset objects define `physics`.

```lua
lurek.tilefield.createPhysicsFromTileset(field, slot, tileset, world, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](#ltilefield) | Source field containing refs. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](#ltileset) | Tileset with tile object metadata. |
| `world` | [LWorld](#lworld) | Physics world that receives the bodies. |
| `opts?` | table | `{z?/level?, refIsGid?, originX?, originY?, tileWidth?, tileHeight?}`. |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody)[] | Created physics body handles in row-major order. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local tileset = lurek.tileset.fromProvider({
        firstGid = 1,
        tileCount = 2,
        columns = 2,
        tileWidth = 16,
        tileHeight = 16,
        objects = { wall = { physics = { shape = "rect", bodyType = "static", restitution = 0.8 } } },
        tileObjects = { [1] = "wall" },
    })
    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:setRef(2, 2, 1, "tiles", 1)
    local world = lurek.physics.newWorld(0, 0)
    local bodies = lurek.tilefield.createPhysicsFromTileset(field, "tiles", tileset, world, { refIsGid = true })
    tilefield_log("tileset physics bodies=" .. #bodies .. " world=" .. world:getBodyCount())
end
```

---

### `lurek.tilefield.fromProvider`

Builds a native tilefield from a Lua provider table with width, height, optional levels/topology, slots, modifiers, regions, and optional getCell(x,y,z).

```lua
lurek.tilefield.fromProvider(provider)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `provider` | table | Lua-authored tilefield provider. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileField](#ltilefield) | New tilefield copied from the provider. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        local f = lurek.tilefield.fromProvider({ width = 3, height = 2, levels = 2, topology = "square4" })
        return f:getTopology()
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

### `lurek.tilefield.fromTileMap`

Copies a tilemap layer into a tilefield, optionally applying tileset object defaults and a ref slot.

```lua
lurek.tilefield.fromTileMap(tilemap, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tilemap` | [LTileMap](#ltilemap) | Source tilemap. |
| `opts?` | table | `{layer?, level?, levels?, topology?, solidGids?, refSlot?, applyTilesetObject?}`; `solidGids` and `applyTilesetObject` are explicit, no tileset solidity is inferred. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileField](#ltilefield) | New tilefield copied from the tilemap layer. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilemap.newTileMap(16, 16)
    map:addLayer("ground", 4, 4)
    map:setTile(1, 2, 2, 9)
    local field = lurek.tilefield.fromTileMap(map, { layer = 1, solidGids = { 9 } })
    tilefield_log("tilemap copied, blocked=" .. tostring(field:blocks(2, 2, 1, "move")))
end
```

---

### `lurek.tilefield.new`

Creates a multi-level tilefield with explicit dimensions and topology.

```lua
lurek.tilefield.new(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{width, height, levels?, topology?}`. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileField](#ltilefield) | New tilefield handle. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 8, height = 8, levels = 2, topology = "square" })
    local w, h, levels = field:getSize()
    local topology = field:getTopology()
    local inside = field:inBounds(8, 8, 2)
    tilefield_log("new field " .. w .. "x" .. h .. "x" .. levels .. " " .. topology .. " inside=" .. tostring(inside))
end
```

---

### `lurek.tilefield.newFieldMap`

Creates a 2D or layered map of shared tilefields.

```lua
lurek.tilefield.newFieldMap(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{width, height, layers?, fieldWidth, fieldHeight, fieldLevels?, topology?}`. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileFieldMap](#ltilefieldmap) | New tilefield map handle. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 4, fieldHeight = 4, topology = "square4" })
    local mw, mh, ml = map:getMapSize()
    local fw, fh = map:getFieldSize()
    local topology = map:getTopology()
    tilefield_log("fieldmap " .. mw .. "x" .. mh .. "x" .. ml .. " field=" .. fw .. "x" .. fh .. " topology=" .. topology)
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LBody](#lbody)
- [LOccluder](#loccluder)
- [LTileField](#ltilefield)
- [LTileFieldMap](#ltilefieldmap)
- [LTileMap](#ltilemap)
- [LTileSet](#ltileset)
- [LWorld](#lworld)

## LBody

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBody:applyAngularImpulse`

Applies an instantaneous angular impulse (spin) to the body.

```lua
LBody:applyAngularImpulse(impulse)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `impulse` | number | Angular impulse value. |

---

#### `LBody:applyForce`

Applies a continuous force to the body's center of mass (accumulates over the step).

```lua
LBody:applyForce(fx, fy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fx` | number | Force X component. |
| `fy` | number | Force Y component. |

---

#### `LBody:applyForceAtPoint`

Applies a force at a specific world point, generating both linear and angular acceleration.

```lua
LBody:applyForceAtPoint(fx, fy, px, py)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fx` | number | Force X component. |
| `fy` | number | Force Y component. |
| `px` | number | Application point X in world coordinates. |
| `py` | number | Application point Y in world coordinates. |

---

#### `LBody:applyImpulse`

Applies an instantaneous linear impulse to the body's center of mass.

```lua
LBody:applyImpulse(ix, iy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ix` | number | Impulse X component. |
| `iy` | number | Impulse Y component. |

---

#### `LBody:applyTorque`

Applies a rotational torque to the body.

```lua
LBody:applyTorque(torque)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `torque` | number | Torque value (positive = counter-clockwise). |

---

#### `LBody:destroy`

Destroys this body, removing it from the world along with all fixtures and joints.

```lua
LBody:destroy()
```

---

#### `LBody:getAngle`

Returns the body's rotation angle in radians.

```lua
LBody:getAngle()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Angle in radians. |

---

#### `LBody:getAngularDamping`

Returns the angular damping factor (rotational decay rate).

```lua
LBody:getAngularDamping()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Angular damping value. |

---

#### `LBody:getAngularVelocity`

Returns the body's angular (rotational) velocity.

```lua
LBody:getAngularVelocity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Angular velocity in radians per second. |

---

#### `LBody:getCollisionGroup`

Returns the single 0..15 collision group for this body, or nil for multi-group masks.

```lua
LBody:getCollisionGroup()
```

**Returns**

| Type | Description |
|------|-------------|
| number? | Collision group index, or nil. |

---

#### `LBody:getFriction`

Returns the body's friction coefficient.

```lua
LBody:getFriction()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Friction value. |

---

#### `LBody:getGravityScale`

Returns the gravity scale multiplier for this body (1.0 = normal gravity).

```lua
LBody:getGravityScale()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Gravity scale. |

---

#### `LBody:getHeight`

Returns the body's bounding height (from its primary shape).

```lua
LBody:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in world units. |

---

#### `LBody:getId`

Returns the unique numeric ID of this body within the world.

```lua
LBody:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Body ID. |

---

#### `LBody:getLayer`

Returns the body's collision layer bitmask.

```lua
LBody:getLayer()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer bitmask. |

---

#### `LBody:getLinearDamping`

Returns the linear damping factor (velocity decay rate, like air resistance).

```lua
LBody:getLinearDamping()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Damping value. |

---

#### `LBody:getMask`

Returns the body's collision mask (which layers this body can collide with).

```lua
LBody:getMask()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Mask bitmask. |

---

#### `LBody:getMass`

Returns the body's total mass (computed from density and fixture areas).

```lua
LBody:getMass()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Mass in kilograms. |

---

#### `LBody:getPosition`

Returns the current world-space position of this body.

```lua
LBody:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X coordinate. |
| number | Y coordinate. |

---

#### `LBody:getRestitution`

Returns the body's restitution (bounciness) value.

```lua
LBody:getRestitution()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Restitution (0 = no bounce, 1 = perfectly elastic). |

---

#### `LBody:getType`

Returns the body's type as a string.

```lua
LBody:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Body type: "static", "dynamic", "kinematic", or "sensor". |

---

#### `LBody:getVelocity`

Returns the body's current linear velocity.

```lua
LBody:getVelocity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Velocity X component. |
| number | Velocity Y component. |

---

#### `LBody:getWidth`

Returns the body's bounding width (from its primary shape).

```lua
LBody:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in world units. |

---

#### `LBody:getX`

Returns only the X component of the body's position.

```lua
LBody:getX()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X coordinate. |

---

#### `LBody:getY`

Returns only the Y component of the body's position.

```lua
LBody:getY()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Y coordinate. |

---

#### `LBody:isBullet`

Returns whether continuous collision detection (bullet mode) is enabled for this body.

```lua
LBody:isBullet()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if CCD is active. |

---

#### `LBody:isFixedRotation`

Returns whether the body's rotation is locked.

```lua
LBody:isFixedRotation()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if rotation is fixed. |

---

#### `LBody:isSleeping`

Returns whether this body is currently in the sleeping (inactive) state.

```lua
LBody:isSleeping()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if sleeping. |

---

#### `LBody:isSleepingAllowed`

Returns whether the body is allowed to enter sleep state when at rest.

```lua
LBody:isSleepingAllowed()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if sleeping is allowed. |

---

#### `LBody:isValid`

Returns whether this body handle still points to an active body.

```lua
LBody:isValid()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the body has not been destroyed. |

---

#### `LBody:setAngle`

Sets the body's rotation angle directly.

```lua
LBody:setAngle(angle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `angle` | number | New angle in radians. |

---

#### `LBody:setAngularDamping`

Sets the angular damping factor (higher = rotation decays faster).

```lua
LBody:setAngularDamping(damping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `damping` | number | Angular damping value. |

---

#### `LBody:setAngularVelocity`

Sets the body's angular velocity directly.

```lua
LBody:setAngularVelocity(omega)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `omega` | number | Angular velocity in radians per second. |

---

#### `LBody:setBullet`

Enables or disables continuous collision detection to prevent fast-moving tunneling.

```lua
LBody:setBullet(bullet)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bullet` | boolean | True to enable CCD. |

---

#### `LBody:setCollisionGroup`

Assigns the body to one collision group and opens its local mask to the 16 group bits.

```lua
LBody:setCollisionGroup(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | number | Collision group index, 0..15. |

---

#### `LBody:setFixedRotation`

Locks or unlocks the body's rotation. Useful for player characters.

```lua
LBody:setFixedRotation(fixed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fixed` | boolean | True to prevent rotation. |

---

#### `LBody:setFriction`

Sets the body's friction coefficient.

```lua
LBody:setFriction(friction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `friction` | number | New friction value (0 = ice, 1 = rubber). |

---

#### `LBody:setGravityScale`

Sets a per-body gravity scale multiplier (0 = no gravity, 2 = double gravity, -1 = inverted).

```lua
LBody:setGravityScale(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale` | number | Gravity scale factor. |

---

#### `LBody:setLayer`

Sets the body's collision layer bitmask (which layers this body belongs to).

```lua
LBody:setLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer bitmask. |

---

#### `LBody:setLinearDamping`

Sets the linear damping factor (higher = more velocity decay per step).

```lua
LBody:setLinearDamping(damping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `damping` | number | Damping value (0 = no damping). |

---

#### `LBody:setMask`

Sets the body's collision mask (which layers this body can collide with).

```lua
LBody:setMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | number | Collision mask bitmask. |

---

#### `LBody:setMass`

Overrides the body's mass directly.

```lua
LBody:setMass(mass)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mass` | number | New mass value. |

---

#### `LBody:setPosition`

Teleports the body to a new world-space position (does not apply physics forces).

```lua
LBody:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | New X position. |
| `y` | number | New Y position. |

---

#### `LBody:setRestitution`

Sets the body's restitution (bounciness) value.

```lua
LBody:setRestitution(restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `restitution` | number | New restitution (0Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬Ĺ›1). |

---

#### `LBody:setSleepingAllowed`

Controls whether the body can enter sleep state. Disable for bodies that must stay active.

```lua
LBody:setSleepingAllowed(allowed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `allowed` | boolean | True to allow sleeping. |

---

#### `LBody:setType`

Changes the body's type at runtime.

```lua
LBody:setType(bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyType` | string | New type: "static", "dynamic", "kinematic", or "sensor". |

---

#### `LBody:setVelocity`

Directly sets the body's linear velocity.

```lua
LBody:setVelocity(vx, vy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vx` | number | Velocity X component. |
| `vy` | number | Velocity Y component. |

---

#### `LBody:sleep`

Forces the body into sleep state, pausing its simulation until disturbed.

```lua
LBody:sleep()
```

---

#### `LBody:type`

Returns the type name of this object ("[LBody](#lbody)").

```lua
LBody:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | "[LBody](#lbody)". |

---

#### `LBody:typeOf`

Checks if this object is of a given type name.

```lua
LBody:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object matches. |

---

#### `LBody:wakeUp`

Wakes the body from sleep, making it active in the simulation again.

```lua
LBody:wakeUp()
```

---

## LOccluder

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LOccluder:getLightMask`

Returns this occluder's light mask.

```lua
LOccluder:getLightMask()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Light mask bits. |

---

#### `LOccluder:getOpacity`

Returns this occluder opacity. This method is available to Lua scripts.

```lua
LOccluder:getOpacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Opacity value. |

---

#### `LOccluder:getPosition`

Returns this occluder position offset.

```lua
LOccluder:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X coordinate. |
| number | Y coordinate. |

---

#### `LOccluder:getVertices`

Returns this occluder's flat vertex coordinate list.

```lua
LOccluder:getVertices()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flat numeric array `[x1, y1, x2, y2, ...]`. |

---

#### `LOccluder:isEnabled`

Returns whether this occluder is enabled.

```lua
LOccluder:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when enabled. |

---

#### `LOccluder:isValid`

Returns whether this occluder handle still points to a live occluder.

```lua
LOccluder:isValid()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the occluder still exists. |

---

#### `LOccluder:remove`

Removes this occluder from the shared light world.

```lua
LOccluder:remove()
```

---

#### `LOccluder:setEnabled`

Enables or disables this occluder.

```lua
LOccluder:setEnabled(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | boolean | New enabled flag. |

---

#### `LOccluder:setLightMask`

Sets this occluder's light mask. This method is available to Lua scripts.

```lua
LOccluder:setLightMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | number | Light mask bits. |

---

#### `LOccluder:setOpacity`

Sets this occluder opacity. This method is available to Lua scripts.

```lua
LOccluder:setOpacity(o)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `o` | number | Opacity value. |

---

#### `LOccluder:setPosition`

Sets this occluder position offset.

```lua
LOccluder:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

---

#### `LOccluder:setVertices`

Replaces this occluder's flat vertex coordinate list.

```lua
LOccluder:setVertices(tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tbl` | table | Flat numeric array `[x1, y1, x2, y2, ...]`. |

---

#### `LOccluder:type`

Returns the Lua-visible type name for this occluder handle.

```lua
LOccluder:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LOccluder](#loccluder)`. |

---

#### `LOccluder:typeOf`

Returns whether this occluder handle matches a supported type name.

```lua
LOccluder:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LOccluder](#loccluder)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

---

## LTileField

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileField:applyModifier`

Applies a named modifier to one cell.

```lua
LTileField:applyModifier(x, y, z, modifier)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `modifier` | string | Modifier name. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("wall", { blocks = { move = true } })
        field:applyModifier(2, 2, 1, "wall")
        return field:blocks(2, 2, 1, "move")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:applyProfile`

Applies a legacy profile to one cell.

```lua
LTileField:applyProfile(x, y, z, profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `profile` | string | Profile name. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local move = field:blocks(2, 2, 1, "move")
    local light = field:blocks(2, 2, 1, "light")
    tilefield_log("window move=" .. tostring(move) .. " light=" .. tostring(light))
end
```

---

#### `LTileField:applyTilesetObject`

Applies the object archetype defaults for a tileset tile referenced from one cell.

```lua
LTileField:applyTilesetObject(x, y, z, slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](#ltileset) | Tileset that stores object archetype metadata. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the tileset object was found and applied. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:applyTilesetObject(1, 1, 1, "object", tileset)
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:applyTilesetObjectLayer`

Applies tileset object defaults for every referenced cell on one tilefield level.

```lua
LTileField:applyTilesetObjectLayer(slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](#ltileset) | Tileset that stores object metadata. |
| `opts?` | table | Options: z, refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of cells that received object defaults. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        field:setRef(2, 1, 1, "object", 1)
        return field:applyTilesetObjectLayer("object", tileset, { z = 1 })
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:blocks`

Returns whether a cell blocks a channel.

```lua
LTileField:blocks(x, y, z, channel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Blocker channel name to query. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the addressed cell blocks the channel. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local move = field:blocks(2, 2, 1, "move")
    local vision = field:blocks(2, 2, 1, "vision")
    tilefield_log("blocks move=" .. tostring(move) .. " vision=" .. tostring(vision))
end
```

---

#### `LTileField:blocksCategory`

Returns whether one cell blocks a category.

```lua
LTileField:blocksCategory(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryBlock(2, 2, 1, "tank", true)
        return field:blocksCategory(2, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:clear`

Clears all cell gameplay state.

```lua
LTileField:clear()
```

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "move", true)
    local before = field:blocks(2, 2, 1, "move")
    field:clear()
    tilefield_log("clear before=" .. tostring(before) .. " after=" .. tostring(field:blocks(2, 2, 1, "move")))
end
```

---

#### `LTileField:clearCell`

Clears gameplay state for one addressed cell.

```lua
LTileField:clearCell(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "vision", true)
    field:setBlock(3, 2, 1, "vision", true)
    field:clearCell(2, 2, 1)
    tilefield_log("clearCell target=" .. tostring(field:blocks(2, 2, 1, "vision")) .. " neighbor=" .. tostring(field:blocks(3, 2, 1, "vision")))
end
```

---

#### `LTileField:clearLine`

Returns true when the line between two cell tables has no blocker for a channel.

```lua
LTileField:clearLine(from_tbl, to_tbl, channel, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_tbl` | table | Start cell table with one-based x, y, and optional z fields. |
| `to_tbl` | table | End cell table with one-based x, y, and optional z fields. |
| `channel` | string | Blocker channel name to test along the line. |
| `opts?` | table | Reserved optional line query options. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when no blocker exists between the two cells. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(3, 2, 1, "window")
    local sight = field:clearLine({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "vision")
    local action = field:clearLine({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "action")
    tilefield_log("clearLine sight=" .. tostring(sight) .. " action=" .. tostring(action))
end
```

---

#### `LTileField:clearModifier`

Removes one modifier from one cell.

```lua
LTileField:clearModifier(x, y, z, modifier)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `modifier` | string | Modifier name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the cell had the modifier. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("mud", { costs = { move = 4 } })
        field:applyModifier(2, 2, 1, "mud")
        field:clearModifier(2, 2, 1)
        return #field:getModifiers(2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:clearRef`

Clears a named object/tile reference from one cell.

```lua
LTileField:clearRef(x, y, z, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(2, 2, 1, "object", 1)
        field:clearRef(2, 2, 1, "object")
        return field:getRef(2, 2, 1, "object")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:defineCategory`

Defines or replaces a user category used by movement, awareness, light, sun, or custom systems.

```lua
LTileField:defineCategory(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Stable category name. |
| `opts?` | table?|Options | custom', active=true?. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineCategory("tank", { kind = "movement" })
        return field:getCategory("tank").kind
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:defineSlot`

Defines a named object slot that cells may reference.

```lua
LTileField:defineSlot(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name chosen by the Lua game. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineSlot("object")
        return field:hasSlot("object")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:exportBlockLayer`

Exports one blocker channel and level as a row-major boolean array.

```lua
LTileField:exportBlockLayer(channel, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Blocker channel name to export. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Row-major boolean array for the requested channel and level. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:applyProfile(2, 2, 1, "wall")
    local layer = field:exportBlockLayer("move", 1)
    local blocked = layer[5]
    tilefield_log("block layer center=" .. tostring(blocked))
end
```

---

#### `LTileField:exportCostLayer`

Exports one cost channel and level as a row-major number array.

```lua
LTileField:exportCostLayer(channel, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Cost channel name to export. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Row-major number array for the requested channel and level. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:setCost(2, 2, 1, "move", 7)
    local layer = field:exportCostLayer("move", 1)
    local center = layer[5]
    tilefield_log("cost layer center=" .. center)
end
```

---

#### `LTileField:exportRefLayer`

Exports one named object/tile reference slot and level as a row-major array.

```lua
LTileField:exportRefLayer(slot, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Reference slot name to export. |
| `z?` | number | One-based level, default 1. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4, levels = 2 })
    field:setRef(2, 2, 1, "floor", 101)
    field:setRef(2, 2, 1, "wall_left", 210)
    local layer = field:exportRefLayer("wall_left", 1)
    tilefield_log("floor=" .. field:getRef(2, 2, 1, "floor") .. " wall_left=" .. tostring(layer[6]))
end
```

---

#### `LTileField:firstBlocker`

Returns the first one-based blocking cell table between two cells, or nil.

```lua
LTileField:firstBlocker(from_tbl, to_tbl, channel, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_tbl` | table | Start cell table with one-based x, y, and optional z fields. |
| `to_tbl` | table | End cell table with one-based x, y, and optional z fields. |
| `channel` | string | Blocker channel name to test along the line. |
| `opts?` | table | Reserved optional line query options. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | First blocking cell table, or nil when the line is clear. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(4, 2, 1, "wall")
    local blocker = field:firstBlocker({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "vision")
    local x = blocker and blocker.x or 0
    tilefield_log("first blocker x=" .. x)
end
```

---

#### `LTileField:footprintPassable`

Returns whether a rectangular footprint can occupy a cell anchor for a category.

```lua
LTileField:footprintPassable(x, y, z, w, h, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `w` | any |  |
| `h` | any |  |
| `category` | any |  |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryBlock(3, 2, 1, "tank", true)
        return field:footprintPassable(2, 2, 1, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getCategories`

Returns known category names.

```lua
LTileField:getCategories()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Sorted category names. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineCategory("tank", { kind = "movement" })
        return field:getCategories()[1]
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getCategory`

Returns category metadata, or nil when the category is unknown.

```lua
LTileField:getCategory(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Category name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Category table with name, kind, and active. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineCategory("tank", { kind = "movement" })
        return field:getCategory("tank").kind
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getCategoryCost`

Returns one effective category cost.

```lua
LTileField:getCategoryCost(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryCost(2, 2, 1, "tank", 6)
        return field:getCategoryCost(2, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getCategoryFilter`

Returns one effective RGB category filter.

```lua
LTileField:getCategoryFilter(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryFilter(2, 2, 1, "light", { 0.25, 0.5, 1 })
        return field:getCategoryFilter(2, 2, 1, "light")[3]
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getCategoryTransmission`

Returns one effective category transmission multiplier.

```lua
LTileField:getCategoryTransmission(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryTransmission(2, 2, 1, "light", 0.25)
        return field:getCategoryTransmission(2, 2, 1, "light")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getCell`

Returns a table with blockers, costs, sun occlusion, refs, and modifiers.

```lua
LTileField:getCell(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Cell state table. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local cell = field:getCell(2, 2, 1)
    local move = cell.blocks.move
    local vision = cell.blocks.vision
    tilefield_log("cell move=" .. tostring(move) .. " vision=" .. tostring(vision))
end
```

---

#### `LTileField:getCost`

Returns the cost for one cell/channel.

```lua
LTileField:getCost(x, y, z, channel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Cost channel name to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Movement or traversal cost value. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local base = field:getCost(1, 1, 1, "move")
    field:setCost(1, 2, 1, "move", 5)
    local changed = field:getCost(1, 2, 1, "move")
    tilefield_log("cost base=" .. base .. " changed=" .. changed)
end
```

---

#### `LTileField:getModifier`

Returns a named tile modifier table, or nil.

```lua
LTileField:getModifier(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Modifier name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Modifier table. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("mud", { costs = { move = 4 } })
        return field:getModifier("mud").costs.move
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getModifiers`

Returns active modifier names on one cell.

```lua
LTileField:getModifiers(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Active modifier names. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("wall", { blocks = { move = true } })
        field:applyModifier(2, 2, 1, "wall")
        return field:getModifiers(2, 2, 1)[1]
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getNeighbors`

Returns topology-aware same-level neighbours for one cell.

```lua
LTileField:getNeighbors(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of one-based coordinate tables. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        return #field:getNeighbors(2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getProfile`

Returns a legacy profile table, or nil.

```lua
LTileField:getProfile(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Profile table. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local profile = field:getProfile("wall")
    local move = profile.blocks.move
    local vision = profile.blocks.vision
    tilefield_log("wall profile move=" .. tostring(move) .. " vision=" .. tostring(vision))
end
```

---

#### `LTileField:getRef`

Returns a named object/tile reference from one cell, or nil.

```lua
LTileField:getRef(x, y, z, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |

**Returns**

| Type | Description |
|------|-------------|
| number | table|nil | Stored legacy id, typed ref table, or nil when unset. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4, levels = 2 })
    field:setRef(2, 2, 1, "object", { tileset = "props", object = "crate" })
    local value = field:getRef(2, 2, 1, "object")
    tilefield_log("getRef object=" .. tostring(value.object))
end
```

---

#### `LTileField:getRefProperties`

Reads all tileset properties for a tile referenced from one cell.

```lua
LTileField:getRefProperties(x, y, z, slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](#ltileset) | Tileset that stores object metadata. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Property name/value table, or nil when the ref is missing/outside the tileset. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:getRefProperties(1, 1, 1, "object", tileset).terrain
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getRefProperty`

Reads a tileset property for a tile referenced from one cell.

```lua
LTileField:getRefProperty(x, y, z, slot, tileset, property, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](#ltileset) | Tileset that stores object metadata. |
| `property` | string | Property name to read. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | Property value, or nil when missing. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:getRefProperty(1, 1, 1, "object", tileset, "material")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getRefPropertyBool`

Reads a tileset property for a tile referenced from one cell and parses it as a boolean.

```lua
LTileField:getRefPropertyBool(x, y, z, slot, tileset, property, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](#ltileset) | Tileset that stores object metadata. |
| `property` | string | Property name to read. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | nil | Boolean property value, or nil when missing/not boolean. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:getRefPropertyBool(1, 1, 1, "object", tileset, "solid")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getRefPropertyNumber`

Reads a tileset property for a tile referenced from one cell and parses it as a number.

```lua
LTileField:getRefPropertyNumber(x, y, z, slot, tileset, property, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](#ltileset) | Tileset that stores object metadata. |
| `property` | string | Property name to read. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| number | nil | Numeric property value, or nil when missing/not numeric. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:getRefPropertyNumber(1, 1, 1, "object", tileset, "cost")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getRefSlots`

Returns every declared ref slot.

```lua
LTileField:getRefSlots()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Ref slot names. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineSlot("object")
        return field:getRefSlots()[1]
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getRegionCells`

Returns one-based cells for a named region, or nil when it does not exist.

```lua
LTileField:getRegionCells(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |

**Returns**

| Type | Description |
|------|-------------|
| table? | Array of `{ x, y, z }` cells. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionRect("room", 1, 1, 2, 2, 1)
        return #field:getRegionCells("room")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getRegionNames`

Returns all region names in stable order.

```lua
LTileField:getRegionNames()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of region names. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionCells("stairs", { { x = 1, y = 1, z = 1 } })
        return field:getRegionNames()[1]
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getSize`

Returns field width, height, and level count.

```lua
LTileField:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Field width in cells. |
| number | Field height in cells. |
| number | Level count. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 10, height = 6, levels = 3 })
    local width, height, levels = field:getSize()
    local cells = width * height * levels
    local valid = cells == 180
    tilefield_log("field cells=" .. cells .. " valid=" .. tostring(valid))
end
```

---

#### `LTileField:getSunOcclusion`

Returns top-light occlusion in the inclusive range 0..1.

```lua
LTileField:getSunOcclusion(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| number | Top-light occlusion value in the inclusive range 0..1. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setSunOcclusion(1, 1, 1, 0.3)
    local value = field:getSunOcclusion(1, 1, 1)
    local default = field:getSunOcclusion(2, 2, 1)
    tilefield_log("sun values=" .. value .. "," .. default)
end
```

---

#### `LTileField:getTopology`

Returns the field topology name used for coordinate interpretation.

```lua
LTileField:getTopology()
```

**Returns**

| Type | Description |
|------|-------------|
| string | `square`, `square4`, `square8`, `iso_square`, or `hex`. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 5, height = 5, topology = "iso_square" })
    local topology = field:getTopology()
    local same_logic = topology == "iso_square"
    local line = field:line({ from = { x = 1, y = 1, z = 1 }, to = { x = 3, y = 1, z = 1 } })
    tilefield_log("topology=" .. topology .. " line=" .. #line .. " same=" .. tostring(same_logic))
end
```

---

#### `LTileField:getVersion`

Returns the current tilefield data version.

```lua
LTileField:getVersion()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Monotonic field version incremented by data mutations. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        local before = field:getVersion()
        field:setBlock(1, 1, 1, "move", true)
        return field:getVersion() - before
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:hasSlot`

Returns true when a named object slot is declared.

```lua
LTileField:hasSlot(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when declared. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineSlot("object")
        return field:hasSlot("object")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:inBounds`

Returns whether one-based coordinates are inside the field.

```lua
LTileField:inBounds(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when coordinates are in bounds. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 3, height = 3, levels = 2 })
    local a = field:inBounds(1, 1, 1)
    local b = field:inBounds(4, 1, 1)
    local c = field:inBounds(3, 3, 2)
    tilefield_log("bounds " .. tostring(a) .. "," .. tostring(b) .. "," .. tostring(c))
end
```

---

#### `LTileField:line`

Returns topology-aware one-based cells between `from` and `to` tables.

```lua
LTileField:line(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{from={x,y,z?}, to={x,y,z?}, includeEndpoints?}`. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 6, height = 6 })
    local line = field:line({ from = { x = 1, y = 1, z = 1 }, to = { x = 5, y = 1, z = 1 } })
    local first = line[1].x
    local last = line[#line].x
    tilefield_log("line first=" .. first .. " last=" .. last .. " count=" .. #line)
end
```

---

#### `LTileField:regionContains`

Returns whether a named region contains a one-based tile cell.

```lua
LTileField:regionContains(name, x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the region contains the cell. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionCells("stairs", { { x = 2, y = 2, z = 1 } })
        return field:regionContains("stairs", 2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:removeModifier`

Removes a named modifier and clears it from all cells.

```lua
LTileField:removeModifier(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Modifier name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when removed. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("mud", { costs = { move = 4 } })
        return field:removeModifier("mud")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:removeProfile`

Removes a legacy profile and clears it from all cells.

```lua
LTileField:removeProfile(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when removed. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setProfile("temporary", { blocks = { move = true } })
    field:removeProfile("temporary")
    local missing = field:getProfile("temporary") == nil
    tilefield_log("profile removed=" .. tostring(missing))
end
```

---

#### `LTileField:removeRegion`

Removes a named region.

```lua
LTileField:removeRegion(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the region existed. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionRect("room", 1, 1, 2, 2, 1)
        return field:removeRegion("room")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:removeSlot`

Removes a named object slot and clears its references from the field.

```lua
LTileField:removeSlot(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the slot existed. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineSlot("object")
        return field:removeSlot("object")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:setBlock`

Sets whether a cell blocks a channel.

```lua
LTileField:setBlock(x, y, z, channel, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Blocker channel name to update. |
| `blocked` | boolean | True when the channel should be blocked. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "move", true)
    field:setBlock(2, 2, 1, "vision", false)
    local move = field:blocks(2, 2, 1, "move")
    tilefield_log("setBlock move=" .. tostring(move))
end
```

---

#### `LTileField:setCategoryBlock`

Sets one category blocker on one cell.

```lua
LTileField:setCategoryBlock(x, y, z, category, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `blocked` | any |  |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryBlock(2, 2, 1, "tank", true)
        return field:blocksCategory(2, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:setCategoryCost`

Sets one category cost on one cell.

```lua
LTileField:setCategoryCost(x, y, z, category, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `cost` | any |  |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryCost(2, 2, 1, "tank", 5)
        return field:getCategoryCost(2, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:setCategoryFilter`

Sets one RGB category filter on one cell.

```lua
LTileField:setCategoryFilter(x, y, z, category, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `filter` | any |  |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryFilter(2, 2, 1, "light", { 1, 0.5, 0.25 })
        return field:getCategoryFilter(2, 2, 1, "light")[2]
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:setCategoryTransmission`

Sets one category transmission multiplier on one cell.

```lua
LTileField:setCategoryTransmission(x, y, z, category, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryTransmission(2, 2, 1, "light", 0.5)
        return field:getCategoryTransmission(2, 2, 1, "light")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:setCell`

Sets cell state from a table with optional `blocks`, `costs`, `sunOcclusion`, `refs`, and `modifiers`.

```lua
LTileField:setCell(x, y, z, cell)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `cell` | table | Cell data. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setCell(2, 2, 1, { blocks = { action = true }, costs = { move = 3 }, sunOcclusion = 0.25 })
    local action = field:blocks(2, 2, 1, "action")
    local cost = field:getCost(2, 2, 1, "move")
    tilefield_log("setCell action=" .. tostring(action) .. " cost=" .. cost)
end
```

---

#### `LTileField:setCost`

Sets the cost for one cell/channel.

```lua
LTileField:setCost(x, y, z, channel, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Cost channel name to update. |
| `cost` | number | Movement or traversal cost value. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setCost(2, 2, 1, "move", 4)
    field:setCost(2, 3, 1, "move", 2)
    local a = field:getCost(2, 2, 1, "move")
    tilefield_log("setCost high=" .. a)
end
```

---

#### `LTileField:setModifier`

Registers or replaces a named tile modifier.

```lua
LTileField:setModifier(name, modifier)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Modifier name. |
| `modifier` | table | Modifier table with blocks, costAdd, costMul, sunOcclusionAdd, light, properties. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("mud", { costs = { move = 4 } })
        return field:getModifier("mud").name
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:setProfile`

Registers or replaces a legacy tilefield profile.

```lua
LTileField:setProfile(name, profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |
| `profile` | table | Profile table with blocks, costs, sunOcclusion, light, or properties. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setProfile("bars", { blocks = { move = true, vision = false, action = true }, sunOcclusion = 0.1 })
    field:applyProfile(2, 2, 1, "bars")
    local visible = not field:blocks(2, 2, 1, "vision")
    tilefield_log("custom bars visible=" .. tostring(visible))
end
```

---

#### `LTileField:setRef`

Sets a named object/tile reference on one cell.

```lua
LTileField:setRef(x, y, z, slot, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name defined by the Lua game. |
| `value` | number|table | Legacy id or typed `{ tileset, tile?/object? }` ref stored for the slot. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4, levels = 2 })
    field:setRef(2, 2, 1, "object", 101)
    local value = field:getRef(2, 2, 1, "object")
    tilefield_log("setRef object=" .. tostring(value))
end
```

---

#### `LTileField:setRegionCells`

Defines or replaces a named region from explicit one-based tile cells.

```lua
LTileField:setRegionCells(name, cells)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `cells` | table | Array of `{ x, y, z? }` cells. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local cells = { { x = 2, y = 2, z = 1 }, { x = 3, y = 2, z = 1 } }
    field:setRegionCells("stairs", cells)
    local ok = field:regionContains("stairs", 3, 2, 1)
    example_log("setRegionCells contains=" .. tostring(ok))
end
```

---

#### `LTileField:setRegionRect`

Defines or replaces a named region from an inclusive one-based tile rectangle.

```lua
LTileField:setRegionRect(name, x1, y1, x2, y2, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `x1` | number | First one-based column. |
| `y1` | number | First one-based row. |
| `x2` | number | Second one-based column. |
| `y2` | number | Second one-based row. |
| `z?` | number | One-based level, default 1. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionRect("room", 2, 2, 3, 2, 1)
        return field:regionContains("room", 2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:setSunOcclusion`

Sets top-light occlusion in the inclusive range 0..1.

```lua
LTileField:setSunOcclusion(x, y, z, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `value` | number | Top-light occlusion value in the inclusive range 0..1. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
    field:setSunOcclusion(1, 1, 2, 0.5)
    tilefield_log("sun occlusion=" .. field:getSunOcclusion(1, 1, 2))
end
```

---

#### `LTileField:type`

Returns the Lua-visible type name for this tilefield handle.

```lua
LTileField:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTileField](#ltilefield)`. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2 })
    local type_name = field:type()
    local expected = type_name == "LTileField"
    local object = field:typeOf("LObject")
    tilefield_log("type=" .. type_name .. " ok=" .. tostring(expected) .. " object=" .. tostring(object))
end
```

---

#### `LTileField:typeOf`

Returns whether this handle matches a supported type name.

```lua
LTileField:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LTileField](#ltilefield)` or `LObject`. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2 })
    local exact = field:typeOf("LTileField")
    local object = field:typeOf("LObject")
    local miss = field:typeOf("LNavGrid")
    tilefield_log("typeOf exact=" .. tostring(exact) .. " object=" .. tostring(object) .. " miss=" .. tostring(miss))
end
```

---

#### `LTileField:writeBlockLayer`

Writes one full blocker channel layer from a row-major boolean array.

```lua
LTileField:writeBlockLayer(channel, z, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Blocker channel name to write. |
| `z?` | number | One-based level, default 1. |
| `values` | table | Row-major boolean array with width*height entries. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:writeBlockLayer("move", 1, { true, false, false, true })
        return field:blocks(1, 1, 1, "move")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:writeCostLayer`

Writes one full cost channel layer from a row-major number array.

```lua
LTileField:writeCostLayer(channel, z, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Cost channel name to write. |
| `z?` | number | One-based level, default 1. |
| `values` | table | Row-major number array with width*height entries. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:writeCostLayer("move", 1, { 1, 2, 3, 4 })
        return field:getCost(2, 2, 1, "move")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileField:writeRefLayer`

Writes one full named ref layer from a row-major integer-or-nil array.

```lua
LTileField:writeRefLayer(slot, z, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Reference slot name to write. |
| `z?` | number | One-based level, default 1. |
| `values` | table | Row-major integer-or-nil array with width*height entries. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:writeRefLayer("object", 1, { 1, nil, 3, 4 })
        return field:getRef(1, 2, 1, "object")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

## LTileFieldMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileFieldMap:getField`

Returns the shared tilefield at one field-map coordinate.

```lua
LTileFieldMap:getField(mapX, mapY, mapZ)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mapX` | number | One-based field-map column. |
| `mapY` | number | One-based field-map row. |
| `mapZ?` | number | One-based field-map layer, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileField](#ltilefield) | Shared tilefield handle. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
    local field = map:getField(2, 2, 2)
    field:setRef(1, 1, 1, "floor", 12)
    local shared = map:getField(2, 2, 2):getRef(1, 1, 1, "floor")
    tilefield_log("shared field ref=" .. tostring(shared))
end
```

---

#### `LTileFieldMap:getFieldSize`

Returns contained field width, height, and level count.

```lua
LTileFieldMap:getFieldSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Contained field width in cells. |
| number | Contained field height in cells. |
| number | Contained field level count. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, fieldWidth = 8, fieldHeight = 6, fieldLevels = 2 })
    local width, height, levels = map:getFieldSize()
    local cells = width * height * levels
    local field = map:getField(1, 1, 1)
    tilefield_log("field cells=" .. cells .. " type=" .. field:type())
end
```

---

#### `LTileFieldMap:getMapSize`

Returns field-map width, height, and layer count.

```lua
LTileFieldMap:getMapSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Field-map width in field slots. |
| number | Field-map height in field slots. |
| number | Field-map layer count. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 3, height = 2, layers = 1, fieldWidth = 4, fieldHeight = 4 })
    local width, height, layers = map:getMapSize()
    local slots = width * height * layers
    local valid = slots == 6
    tilefield_log("map slots=" .. slots .. " valid=" .. tostring(valid))
end
```

---

#### `LTileFieldMap:getTopology`

Returns the topology shared by every contained field.

```lua
LTileFieldMap:getTopology()
```

**Returns**

| Type | Description |
|------|-------------|
| string | `square`, `square4`, `square8`, `iso_square`, or `hex`. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, fieldWidth = 4, fieldHeight = 4, topology = "hex" })
    local topology = map:getTopology()
    local field = map:getField(1, 1, 1)
    local same = field:getTopology() == topology
    tilefield_log("fieldmap topology=" .. topology .. " same=" .. tostring(same))
end
```

---

#### `LTileFieldMap:inBounds`

Returns whether one-based field-map coordinates are inside the field map.

```lua
LTileFieldMap:inBounds(mapX, mapY, mapZ)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mapX` | number | One-based field-map column. |
| `mapY` | number | One-based field-map row. |
| `mapZ?` | number | One-based field-map layer, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when coordinates are in bounds. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
    local inside = map:inBounds(2, 2, 2)
    local outside = map:inBounds(3, 1, 1)
    local default_layer = map:inBounds(1, 1)
    tilefield_log("fieldmap bounds=" .. tostring(inside) .. "," .. tostring(outside) .. "," .. tostring(default_layer))
end
```

---

#### `LTileFieldMap:setField`

Replaces one field-map slot with an existing compatible tilefield handle.

```lua
LTileFieldMap:setField(mapX, mapY, mapZ, field)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mapX` | number | One-based field-map column. |
| `mapY` | number | One-based field-map row. |
| `mapZ?` | number | One-based field-map layer, default 1. |
| `field` | [LTileField](#ltilefield) | Existing compatible tilefield handle. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, layers = 1, fieldWidth = 3, fieldHeight = 3, topology = "square8" })
    local field = lurek.tilefield.new({ width = 3, height = 3, topology = "square8" })
    field:setRef(2, 2, 1, "object", 90)
    map:setField(1, 1, 1, field)
    tilefield_log("stored object=" .. tostring(map:getField(1, 1, 1):getRef(2, 2, 1, "object")))
end
```

---

#### `LTileFieldMap:type`

Returns the Lua-visible type name for this tilefield map handle.

```lua
LTileFieldMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTileFieldMap](#ltilefieldmap)`. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        local map = lurek.tilefield.newFieldMap({ width = 2, height = 3, layers = 2, fieldWidth = 4, fieldHeight = 5, fieldLevels = 2 })
        return map:type()
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileFieldMap:typeOf`

Returns whether this handle matches a supported type name.

```lua
LTileFieldMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LTileFieldMap](#ltilefieldmap)` or `LObject`. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        local map = lurek.tilefield.newFieldMap({ width = 2, height = 3, layers = 2, fieldWidth = 4, fieldHeight = 5, fieldLevels = 2 })
        return map:typeOf("LTileFieldMap")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

## LTileMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileMap:addLayer`

Creates a new tile layer with the given name and dimensions.

```lua
LTileMap:addLayer(name, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |
| `w` | number | Width in tiles. |
| `h` | number | Height in tiles. |

**Returns**

| Type | Description |
|------|-------------|
| number | Index of the new layer (1-based). |

---

#### `LTileMap:addTileSet`

Attaches a tileset to this map for tile rendering.

```lua
LTileMap:addTileSet(tileSet)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileSet` | [LTileSet](#ltileset) | Tileset to add. |

---

#### `LTileMap:applyAutoTile`

Runs 4-bit auto-tiling on an entire layer, replacing tiles according to registered rules.

```lua
LTileMap:applyAutoTile(layer, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `typeName` | string | Tile type name whose rules to apply. |

---

#### `LTileMap:applyAutoTile8`

Runs 8-bit auto-tiling on an entire layer, considering diagonal neighbors.

```lua
LTileMap:applyAutoTile8(layer, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `typeName` | string | Tile type name whose rules to apply. |

---

#### `LTileMap:applyAutoTile8At`

Runs 8-bit auto-tiling at a single tile position and updates it and its neighbors.

```lua
LTileMap:applyAutoTile8At(layer, x, y, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `typeName` | string | Tile type name whose rules to apply. |

---

#### `LTileMap:applyAutoTileAt`

Runs 4-bit auto-tiling at a single tile position and updates it and its neighbors.

```lua
LTileMap:applyAutoTileAt(layer, x, y, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `typeName` | string | Tile type name whose rules to apply. |

---

#### `LTileMap:applyAutoTileMode`

Runs auto-tiling on an entire layer using the mode configured on the matching tileset.

```lua
LTileMap:applyAutoTileMode(layer, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `typeName` | string | Tile type name whose configured mode and rules to apply. |

---

#### `LTileMap:applyAutoTileModeAt`

Runs configured-mode auto-tiling at a single tile position and updates it and its neighbors.

```lua
LTileMap:applyAutoTileModeAt(layer, x, y, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `typeName` | string | Tile type name whose configured mode and rules to apply. |

---

#### `LTileMap:clearTile`

Removes the tile at a specific grid position, setting it to empty (GID 0).

```lua
LTileMap:clearTile(layer, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |

---

#### `LTileMap:fill`

Fills every cell of a layer with the given GID.

```lua
LTileMap:fill(layer, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `gid` | number | Global tile ID to fill with. |

---

#### `LTileMap:findTilesByGid`

Returns all positions on a layer that contain a specific GID.

```lua
LTileMap:findTilesByGid(layer, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `gid` | number | Global tile ID to search for. |

**Returns**

| Type | Description |
|------|-------------|
| LTileMapFindTilesByGidResult | Array of `{x=number, y=number}` positions. |

---

#### `LTileMap:getChunkSize`

Returns the chunk size used for internal tile storage.

```lua
LTileMap:getChunkSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Chunk size in tiles per side. |

---

#### `LTileMap:getDiagnostics`

Returns tilemap diagnostics counters for invalid calls, unknown gids, and lazy index rebuilds.

```lua
LTileMap:getDiagnostics()
```

---

#### `LTileMap:getLayerColor`

Returns the tint color of a layer as four RGBA components.

```lua
LTileMap:getLayerColor(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Red (0..1). |
| number | Green (0..1). |
| number | Blue (0..1). |
| number | Alpha (0..1). |

---

#### `LTileMap:getLayerCount`

Returns the total number of layers in this map.

```lua
LTileMap:getLayerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer count. |

---

#### `LTileMap:getLayerName`

Returns the name of a layer by index.

```lua
LTileMap:getLayerName(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| string | Layer name, or nil if index is out of range. |

---

#### `LTileMap:getLayerOffset`

Returns the pixel offset of a layer.

```lua
LTileMap:getLayerOffset(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Horizontal offset. |
| number | Vertical offset. |

---

#### `LTileMap:getLayerParallax`

Returns the parallax scroll factor of a layer.

```lua
LTileMap:getLayerParallax(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Horizontal parallax factor. |
| number | Vertical parallax factor. |

---

#### `LTileMap:getLayerVisible`

Returns whether a layer is currently visible.

```lua
LTileMap:getLayerVisible(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the layer is visible. |

---

#### `LTileMap:getOrientation`

Returns the current map orientation as a string.

```lua
LTileMap:getOrientation()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of `"topdown"`, `"sideview"`, `"isometric"`, `"hexagonal"`. |

---

#### `LTileMap:getTile`

Returns the tile GID at a specific grid position on a layer.

```lua
LTileMap:getTile(layer, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Global tile ID at that position. |

---

#### `LTileMap:getTileDimensions`

Returns both tile width and height in pixels.

```lua
LTileMap:getTileDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width. |
| number | Tile height. |

---

#### `LTileMap:getTileHeight`

Returns the height of a single tile in pixels for this map.

```lua
LTileMap:getTileHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile height in pixels. |

---

#### `LTileMap:getTileSet`

Returns the tileset at the given index.

```lua
LTileMap:getTileSet(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Tileset index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| [LTileSet](#ltileset) | The tileset, or nil if index is out of range. |

---

#### `LTileMap:getTileSetCount`

Returns how many tilesets are attached to this map.

```lua
LTileMap:getTileSetCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tileset count. |

---

#### `LTileMap:getTileWidth`

Returns the width of a single tile in pixels for this map.

```lua
LTileMap:getTileWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width in pixels. |

---

#### `LTileMap:getViewport`

Returns the current viewport rectangle, or nils if none is set.

```lua
LTileMap:getViewport()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Left edge. |
| number | Top edge. |
| number | Width. |
| number | Height. |

---

#### `LTileMap:render`

Submits render commands for all visible tiles, optionally offset by a scroll position.

```lua
LTileMap:render(ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox?` | number | Horizontal scroll offset (default 0). |
| `oy?` | number | Vertical scroll offset (default 0). |

---

#### `LTileMap:renderFieldCatalogSlot`

Renders typed refs from a tilefield slot through a tileset catalog.

```lua
LTileMap:renderFieldCatalogSlot(field, catalog, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](#ltilefield)|table | Source tilefield handle or provider table containing typed slot refs. |
| `catalog` | [LTileCatalog](tileset.md#ltilecatalog) | Catalog resolving `{tileset,tile/object}` refs to visuals. |
| `opts` | table | Options: slot, z, offsetX, offsetY. |

---

#### `LTileMap:renderFieldSlot`

Renders objects referenced from a tilefield slot using tileset object visuals.

```lua
LTileMap:renderFieldSlot(field, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](#ltilefield)|table | Source tilefield handle or provider table containing slot refs. |
| `tileset` | [LTileSet](#ltileset)|table | Tileset handle or provider table with object archetype visuals. |
| `opts` | table | Options: slot, z, offsetX, offsetY, refIsGid. |

---

#### `LTileMap:setLayerColor`

Sets the tint color for an entire layer.

```lua
LTileMap:setLayerColor(idx, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |
| `r` | number | Red channel (0..1). |
| `g` | number | Green channel (0..1). |
| `b` | number | Blue channel (0..1). |
| `a` | number | Alpha channel (0..1). |

---

#### `LTileMap:setLayerOffset`

Sets the pixel offset for a layer, shifting all tiles during rendering.

```lua
LTileMap:setLayerOffset(idx, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |
| `ox` | number | Horizontal offset in pixels. |
| `oy` | number | Vertical offset in pixels. |

---

#### `LTileMap:setLayerParallax`

Sets the parallax scroll factor for a layer. Values less than 1 scroll slower than the camera.

```lua
LTileMap:setLayerParallax(idx, px, py)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |
| `px` | number | Horizontal parallax factor. |
| `py` | number | Vertical parallax factor. |

---

#### `LTileMap:setLayerVisible`

Sets whether a layer is drawn during rendering.

```lua
LTileMap:setLayerVisible(idx, visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |
| `visible` | boolean | True to show, false to hide. |

---

#### `LTileMap:setOrientation`

Sets the map orientation, affecting coordinate transforms and rendering.

```lua
LTileMap:setOrientation(orientation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `orientation` | string | One of `"topdown"`, `"sideview"`, `"isometric"`, `"hexagonal"`. |

---

#### `LTileMap:setTile`

Sets the tile GID at a specific grid position on a layer.

```lua
LTileMap:setTile(layer, x, y, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `gid` | number | Global tile ID to place. |

---

#### `LTileMap:setTileTint`

Overrides the color tint for a single tile at a given position.

```lua
LTileMap:setTileTint(layer, x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `r` | number | Red channel (0..1). |
| `g` | number | Green channel (0..1). |
| `b` | number | Blue channel (0..1). |
| `a` | number | Alpha channel (0..1). |

---

#### `LTileMap:setViewport`

Sets the visible area of the map for culling during rendering.

```lua
LTileMap:setViewport(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Left edge in world pixels. |
| `y` | number | Top edge in world pixels. |
| `w` | number | Viewport width in pixels. |
| `h` | number | Viewport height in pixels. |

---

#### `LTileMap:tileToWorld`

Converts tile-grid coordinates to world-space pixel coordinates (top-left corner of the tile).

```lua
LTileMap:tileToWorld(tx, ty)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Tile column (1-based). |
| `ty` | number | Tile row (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | World X position in pixels. |
| number | World Y position in pixels. |

---

#### `LTileMap:tileTypeIndex`

Builds an index mapping each GID present on a layer to an array of `{x, y}` positions.

```lua
LTileMap:tileTypeIndex(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| LTileMapTileTypeIndexResult | Table keyed by GID, each value an array of `{x=number, y=number}`. |

---

#### `LTileMap:tryAddLayer`

Creates a new tile layer and returns `nil, error` instead of throwing on invalid dimensions or layer limits.

```lua
LTileMap:tryAddLayer(name, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |
| `w` | number | Width in tiles. |
| `h` | number | Height in tiles. |

**Returns**

| Type | Description |
|------|-------------|
| number | Index of the new layer (1-based). |
| string | Error message when validation fails. |

---

#### `LTileMap:tryGetTile`

Returns the tile GID at a specific grid position, or `nil, error` when the layer or coord is invalid.

```lua
LTileMap:tryGetTile(layer, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Global tile ID at that position. |
| string | Error message on failure. |

---

#### `LTileMap:trySetTile`

Sets a tile and returns `false, error` instead of throwing on invalid layer or coordinate input.

```lua
LTileMap:trySetTile(layer, x, y, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `gid` | number | Global tile ID to place. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True on success. |
| string | Error message on failure. |

---

#### `LTileMap:trySetTileTint`

Sets a per-cell tint override and returns `false, error` instead of throwing on invalid input.

```lua
LTileMap:trySetTileTint(layer, x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `r` | number | Red tint channel. |
| `g` | number | Green tint channel. |
| `b` | number | Blue tint channel. |
| `a` | number | Alpha tint channel. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True on success. |
| string | Error message on failure. |

---

#### `LTileMap:tryWorldToTile`

Converts world-space pixel coordinates to tile-grid coordinates, returning nils for negative or non-finite input.

```lua
LTileMap:tryWorldToTile(wx, wy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | World X position in pixels. |
| `wy` | number | World Y position in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tile column (1-based). |
| number | Tile row (1-based). |

---

#### `LTileMap:type`

Returns the type name of this userdata.

```lua
LTileMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LTileMap](#ltilemap)"`. |

---

#### `LTileMap:typeOf`

Checks whether this object matches the given type name.

```lua
LTileMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if `name` is `"[LTileMap](#ltilemap)"` or `"Object"`. |

---

#### `LTileMap:update`

Advances tile animations by the given delta time.

```lua
LTileMap:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Time elapsed in seconds since last update. |

---

#### `LTileMap:worldToTile`

Converts world-space pixel coordinates to tile-grid coordinates.

```lua
LTileMap:worldToTile(wx, wy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | World X position in pixels. |
| `wy` | number | World Y position in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tile column (1-based). |
| number | Tile row (1-based). |

---

## LTileSet

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileSet:getAnimation`

Returns the animation frames for one tile.

```lua
LTileSet:getAnimation(tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Array of frame tables, or nil when no animation exists. |

---

#### `LTileSet:getAutoTileId`

Resolves a four-neighbor autotile bitmask to a tile id.

```lua
LTileSet:getAutoTileId(type_name, bitmask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Logical tile type name. |
| `bitmask` | number | Four-neighbor bitmask. |

**Returns**

| Type | Description |
|------|-------------|
| number | nil | Tile id (1-based), or nil when no rule exists. |

---

#### `LTileSet:getAutoTileId8`

Resolves an eight-neighbor autotile bitmask to a tile id.

```lua
LTileSet:getAutoTileId8(type_name, bitmask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Logical tile type name. |
| `bitmask` | number | Eight-neighbor bitmask. |

**Returns**

| Type | Description |
|------|-------------|
| number | nil | Tile id (1-based), or nil when no rule exists. |

---

#### `LTileSet:getAutoTileMode`

Returns the autotile matching mode for a tile type.

```lua
LTileSet:getAutoTileMode(type_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Logical tile type name. |

**Returns**

| Type | Description |
|------|-------------|
| string | Autotile matching mode. |

---

#### `LTileSet:getColumns`

Returns the number of atlas columns.

```lua
LTileSet:getColumns()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Column count. |

---

#### `LTileSet:getFirstGid`

Returns the first global tile id assigned to this tileset.

```lua
LTileSet:getFirstGid()
```

**Returns**

| Type | Description |
|------|-------------|
| number | First global tile id. |

---

#### `LTileSet:getMargin`

Returns the atlas margin in pixels.

```lua
LTileSet:getMargin()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Atlas margin. |

---

#### `LTileSet:getObject`

Returns object archetype metadata by name.

```lua
LTileSet:getObject(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Object archetype name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Object metadata table, or nil when missing. |

---

#### `LTileSet:getObjectNames`

Returns all object archetype names in this tileset.

```lua
LTileSet:getObjectNames()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of object archetype names. |

---

#### `LTileSet:getPhysicsShape`

Returns the physics shape label for one tile.

```lua
LTileSet:getPhysicsShape(tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | Physics shape label, or nil when unset. |

---

#### `LTileSet:getProfile`

Returns the named gameplay profile for one tile.

```lua
LTileSet:getProfile(tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | Profile name, or nil when unset. |

---

#### `LTileSet:getProperties`

Returns all custom properties for one tile.

```lua
LTileSet:getProperties(tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| table | Property name/value table. |

---

#### `LTileSet:getProperty`

Returns a custom tile property as a string.

```lua
LTileSet:getProperty(tile_id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `name` | string | Property name. |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | Property value, or nil when unset. |

---

#### `LTileSet:getPropertyBool`

Returns a custom tile property parsed as a boolean.

```lua
LTileSet:getPropertyBool(tile_id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `name` | string | Property name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | nil | Boolean property value, or nil when unset or not boolean. |

---

#### `LTileSet:getPropertyNumber`

Returns a custom tile property parsed as a number.

```lua
LTileSet:getPropertyNumber(tile_id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `name` | string | Property name. |

**Returns**

| Type | Description |
|------|-------------|
| number | nil | Numeric property value, or nil when unset or not numeric. |

---

#### `LTileSet:getQuad`

Returns the atlas rectangle for one tile id.

```lua
LTileSet:getQuad(tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| table | Rectangle table with x, y, width, and height. |

---

#### `LTileSet:getSpacing`

Returns the spacing between atlas tiles in pixels.

```lua
LTileSet:getSpacing()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile spacing. |

---

#### `LTileSet:getTextureDimensions`

Returns the computed texture width and height in pixels.

```lua
LTileSet:getTextureDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Texture width. |
| number | Texture height. |

---

#### `LTileSet:getTileCount`

Returns the number of tile entries in this tileset.

```lua
LTileSet:getTileCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile count. |

---

#### `LTileSet:getTileDimensions`

Returns the tile width and height in pixels.

```lua
LTileSet:getTileDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width. |
| number | Tile height. |

---

#### `LTileSet:getTileHeight`

Returns the tile height in pixels.

```lua
LTileSet:getTileHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile height. |

---

#### `LTileSet:getTileObject`

Returns the object archetype name mapped to one tile.

```lua
LTileSet:getTileObject(tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | Object archetype name, or nil when unmapped. |

---

#### `LTileSet:getTileWidth`

Returns the tile width in pixels.

```lua
LTileSet:getTileWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width. |

---

#### `LTileSet:removeObject`

Removes an object archetype by name.

```lua
LTileSet:removeObject(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Object archetype name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an archetype was removed. |

---

#### `LTileSet:setAnimation`

Replaces the animation frames for one tile.

```lua
LTileSet:setAnimation(tile_id, frames)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `frames` | table | Array of frame tables with `tileid` and `duration`. |

---

#### `LTileSet:setAutoTileMode`

Sets the autotile matching mode for a tile type.

```lua
LTileSet:setAutoTileMode(type_name, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Logical tile type name. |
| `mode` | string | One of `matchSides`, `matchCorners`, or `matchCornersAndSides`. |

---

#### `LTileSet:setAutoTileRule`

Sets a four-neighbor autotile bitmask rule for a tile type.

```lua
LTileSet:setAutoTileRule(type_name, bitmask, tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Logical tile type name. |
| `bitmask` | number | Four-neighbor bitmask. |
| `tile_id` | number | Tile id (1-based) to emit for the bitmask. |

---

#### `LTileSet:setAutoTileRule8`

Sets an eight-neighbor autotile bitmask rule for a tile type.

```lua
LTileSet:setAutoTileRule8(type_name, bitmask, tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Logical tile type name. |
| `bitmask` | number | Eight-neighbor bitmask. |
| `tile_id` | number | Tile id (1-based) to emit for the bitmask. |

---

#### `LTileSet:setObject`

Stores an object archetype and its visual, pathing, lighting, and custom metadata.

```lua
LTileSet:setObject(name, object)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Object archetype name. |
| `object` | table | Object metadata table. |

---

#### `LTileSet:setPhysicsShape`

Sets or clears the physics shape label for one tile.

```lua
LTileSet:setPhysicsShape(tile_id, shape)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `shape?` | string | Physics shape label, or nil/empty to clear it. |

---

#### `LTileSet:setProfile`

Sets or clears the named gameplay profile for one tile.

```lua
LTileSet:setProfile(tile_id, profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `profile?` | string | Profile name, or nil/empty to clear it. |

---

#### `LTileSet:setProperty`

Sets or clears a custom string-convertible tile property.

```lua
LTileSet:setProperty(tile_id, name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `name` | string | Property name. |
| `value` | any | String, number, boolean, or nil to clear the property. |

---

#### `LTileSet:setTileObject`

Assigns or clears the object archetype mapped to one tile.

```lua
LTileSet:setTileObject(tile_id, object_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `object_name?` | string | Object archetype name, or nil to clear it. |

---

#### `LTileSet:type`

Returns the userdata type name.

```lua
LTileSet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `[LTileSet](#ltileset)`. |

---

#### `LTileSet:typeOf`

Checks whether this tileset matches a type name.

```lua
LTileSet:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LTileSet](#ltileset)` or `LObject`. |

---

## LWorld

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LWorld:addDistanceJoint`

Creates a distance joint that keeps two bodies at a fixed distance apart, like a rigid rod.

```lua
LWorld:addDistanceJoint(bodyA, bodyB, anchorAX, anchorAY, anchorBX, anchorBY, length)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorAX` | number | Local anchor X on body A. |
| `anchorAY` | number | Local anchor Y on body A. |
| `anchorBX` | number | Local anchor X on body B. |
| `anchorBY` | number | Local anchor Y on body B. |
| `length` | number | Target distance between anchors. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

---

#### `LWorld:addFixture`

Attaches a new collider shape to an existing body with material properties.

```lua
LWorld:addFixture(bodyId, shapeType, density, friction, restitution, sensor, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The target body ID. |
| `shapeType` | string | Shape kind: "circle", "rectangle", "polygon", "edge", or "chain". |
| `density` | number | Mass density (affects dynamic body mass calculation). |
| `friction` | number | Surface friction coefficient (0 = ice, 1 = rubber). |
| `restitution` | number | Bounciness (0 = no bounce, 1 = perfectly elastic). |
| `sensor` | boolean | If true, detects overlaps without generating collision response. |
| — | — | @param ... number Shape-specific size arguments (radius, width/height, or vertex list). |

**Returns**

| Type | Description |
|------|-------------|
| number | The fixture index on the body. |

---

#### `LWorld:addFrictionJoint`

Creates a friction joint that applies resistance to relative motion between two bodies.

```lua
LWorld:addFrictionJoint(bodyA, bodyB, anchorX, anchorY, maxForce, maxTorque)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorX` | number | Anchor X in world coordinates. |
| `anchorY` | number | Anchor Y in world coordinates. |
| `maxForce` | number | Maximum friction force. |
| `maxTorque` | number | Maximum friction torque. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

---

#### `LWorld:addGearJoint`

Creates a gear joint that synchronizes rotation between two bodies at an anchor.

```lua
LWorld:addGearJoint(bodyA, bodyB, anchorX, anchorY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorX` | number | Gear anchor X. |
| `anchorY` | number | Gear anchor Y. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

---

#### `LWorld:addGravityVector`

Adds an extra directional gravity vector that is summed with world gravity when no non-additive zone override is active.

```lua
LWorld:addGravityVector(gx, gy, layerMask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | number | Horizontal acceleration in world units per second squared. |
| `gy` | number | Vertical acceleration in world units per second squared. |
| `layerMask?` | number | Optional body layer mask, defaults to all layers. |

**Returns**

| Type | Description |
|------|-------------|
| number | Stable gravity vector ID. |

---

#### `LWorld:addMotorJoint`

Creates a motor joint that drives body B toward a target offset from body A using a correction factor.

```lua
LWorld:addMotorJoint(bodyA, bodyB, factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `factor` | number | Correction factor (0Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬Ĺ›1), higher = faster convergence. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

---

#### `LWorld:addMouseJoint`

Creates a mouse joint that pulls a body toward a world target point with spring-like force.

```lua
LWorld:addMouseJoint(bodyId, targetX, targetY, maxForce)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body to pull. |
| `targetX` | number | Initial target X in world coordinates. |
| `targetY` | number | Initial target Y in world coordinates. |
| `maxForce` | number | Maximum force applied to reach the target. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

---

#### `LWorld:addPrismaticJoint`

Creates a prismatic (slider) joint that constrains body B to move along an axis relative to body A.

```lua
LWorld:addPrismaticJoint(bodyA, bodyB, anchorX, anchorY, axisX, axisY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorX` | number | Anchor X in world coordinates. |
| `anchorY` | number | Anchor Y in world coordinates. |
| `axisX` | number | Slide axis X direction. |
| `axisY` | number | Slide axis Y direction. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

---

#### `LWorld:addPulleyJoint`

Creates a pulley joint connecting two bodies so that movement of one affects the other inversely.

```lua
LWorld:addPulleyJoint(bodyA, bodyB, anchorX, anchorY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorX` | number | Shared anchor X. |
| `anchorY` | number | Shared anchor Y. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

---

#### `LWorld:addRevoluteJoint`

Creates a revolute (hinge) joint connecting two bodies at an anchor point. Bodies can rotate freely around the anchor.

```lua
LWorld:addRevoluteJoint(bodyA, bodyB, anchorX, anchorY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorX` | number | Anchor X in world coordinates. |
| `anchorY` | number | Anchor Y in world coordinates. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

---

#### `LWorld:addRopeJoint`

Creates a rope joint limiting the maximum distance between two anchor points on two bodies.

```lua
LWorld:addRopeJoint(bodyA, bodyB, anchorAX, anchorAY, anchorBX, anchorBY, maxLength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorAX` | number | Local anchor X on body A. |
| `anchorAY` | number | Local anchor Y on body A. |
| `anchorBX` | number | Local anchor X on body B. |
| `anchorBY` | number | Local anchor Y on body B. |
| `maxLength` | number | Maximum allowed distance between anchors. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

---

#### `LWorld:addWeldJoint`

Creates a weld joint that rigidly connects two bodies at an anchor point (no relative movement).

```lua
LWorld:addWeldJoint(bodyA, bodyB, anchorX, anchorY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID. |
| `bodyB` | number | Second body ID. |
| `anchorX` | number | Anchor X in world coordinates. |
| `anchorY` | number | Anchor Y in world coordinates. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

---

#### `LWorld:addWheelJoint`

Creates a wheel joint simulating a suspension: allows rotation and linear movement along an axis.

```lua
LWorld:addWheelJoint(bodyA, bodyB, anchorX, anchorY, axisX, axisY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyA` | number | First body ID (chassis). |
| `bodyB` | number | Second body ID (wheel). |
| `anchorX` | number | Anchor X in world coordinates. |
| `anchorY` | number | Anchor Y in world coordinates. |
| `axisX` | number | Suspension axis X direction. |
| `axisY` | number | Suspension axis Y direction. |

**Returns**

| Type | Description |
|------|-------------|
| number | The joint ID. |

---

#### `LWorld:addZone`

Creates a rectangular physics zone for area-based effects (custom gravity, damping overrides).

```lua
LWorld:addZone(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Zone left X. |
| `y` | number | Zone top Y. |
| `w` | number | Zone width. |
| `h` | number | Zone height. |

**Returns**

| Type | Description |
|------|-------------|
| [LZone](physics.md#lzone) | The zone handle. |

---

#### `LWorld:clear`

Removes bodies, joints, terrain colliders, and zones while preserving world-level settings.

```lua
LWorld:clear()
```

---

#### `LWorld:clearBeginContact`

Removes the begin-contact callback so it is no longer called.

```lua
LWorld:clearBeginContact()
```

---

#### `LWorld:clearBodyData`

Removes and releases the Lua data attached to a body.

```lua
LWorld:clearBodyData(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

---

#### `LWorld:clearBodyOneWay`

Removes the one-way platform behavior from a body, making it block from all directions.

```lua
LWorld:clearBodyOneWay(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

---

#### `LWorld:clearEndContact`

Removes the end-contact callback so it is no longer called.

```lua
LWorld:clearEndContact()
```

---

#### `LWorld:clearGravityVectors`

Removes all additive gravity vectors from the world.

```lua
LWorld:clearGravityVectors()
```

---

#### `LWorld:destroyBody`

Removes a body from the world by its ID, along with all attached fixtures and joints.

```lua
LWorld:destroyBody(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID to destroy. |

---

#### `LWorld:destroyJoint`

Removes a joint from the world, disconnecting the two bodies it linked.

```lua
LWorld:destroyJoint(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID to destroy. |

---

#### `LWorld:drawDebug`

Renders a debug visualization of all physics bodies onto a software ImageData target.

```lua
LWorld:drawDebug(target, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | [LImageData](render.md#limagedata) | The image to draw debug shapes onto. |
| `r?` | number | Red channel (0-255, default 0). |
| `g?` | number | Green channel (0-255, default 255). |
| `b?` | number | Blue channel (0-255, default 0). |
| `a?` | number | Alpha channel (0-255, default 255). |

---

#### `LWorld:fixtureCount`

Returns how many fixtures (colliders) are attached to a body.

```lua
LWorld:fixtureCount(bodyId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of attached fixtures. |

---

#### `LWorld:getBeginContactEvents`

Returns contact-begin events from the last step (pairs of bodies that started touching).

```lua
LWorld:getBeginContactEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetBeginContactEventsResult | Array of {bodyA, bodyB} tables. |

---

#### `LWorld:getBodyAtPoint`

Returns the body ID at a specific world point, or nil if no body is there.

```lua
LWorld:getBodyAtPoint(x, y, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Query point X. |
| `y` | number | Query point Y. |
| `filter?` | table | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?}. |

**Returns**

| Type | Description |
|------|-------------|
| number | Body ID at the point, or nil. |

---

#### `LWorld:getBodyCCD`

Returns whether continuous collision detection is enabled on a body.

```lua
LWorld:getBodyCCD(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if CCD is enabled. |

---

#### `LWorld:getBodyContacts`

Returns all contacts involving a specific body.

```lua
LWorld:getBodyContacts(bodyId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body to query contacts for. |

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetBodyContactsResult | Array of {bodyA, bodyB, normalX, normalY, isTouching} tables. |

---

#### `LWorld:getBodyCount`

Returns the total number of active bodies in the world.

```lua
LWorld:getBodyCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Body count. |

---

#### `LWorld:getBodyData`

Retrieves the Lua data previously attached to a body, or nil if none was set.

```lua
LWorld:getBodyData(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| table | The stored value, or nil if none was set. |

---

#### `LWorld:getBodyIds`

Returns a sequential table of all body IDs currently in the world.

```lua
LWorld:getBodyIds()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Body ID numbers. |

---

#### `LWorld:getBodyOneWay`

Returns the one-way platform normal for a body, or nil,nil if not set.

```lua
LWorld:getBodyOneWay(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Normal X; or nil if not a one-way body. |
| number | Normal Y; or nil if not a one-way body. |

---

#### `LWorld:getBodyType`

Returns the type name of a body as a string.

```lua
LWorld:getBodyType(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| string | Body type: "static", "dynamic", "kinematic", or "sensor". |

---

#### `LWorld:getCollisionEvents`

Returns all collision events from the last step as a table of {bodyA, bodyB} pairs.

```lua
LWorld:getCollisionEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetCollisionEventsResult | Array of collision event tables. |

---

#### `LWorld:getCollisionGroupMask`

Returns one row of the 16-group collision matrix.

```lua
LWorld:getCollisionGroupMask(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | number | Source collision group index, 0..15. |

**Returns**

| Type | Description |
|------|-------------|
| number | Target group bitmask. |

---

#### `LWorld:getCollisionPair`

Returns whether collisions are enabled between two world-level collision groups.

```lua
LWorld:getCollisionPair(groupA, groupB)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `groupA` | number | First collision group index, 0..15. |
| `groupB` | number | Second collision group index, 0..15. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the pair is enabled in both matrix directions. |

---

#### `LWorld:getContacts`

Returns all currently active contact manifolds with normals and touching state.

```lua
LWorld:getContacts()
```

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetContactsResult | Array of {bodyA, bodyB, normalX, normalY, isTouching} tables. |

---

#### `LWorld:getEndContactEvents`

Returns contact-end events from the last step (pairs of bodies that stopped touching).

```lua
LWorld:getEndContactEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetEndContactEventsResult | Array of {bodyA, bodyB} tables. |

---

#### `LWorld:getGravity`

Returns the current world gravity vector.

```lua
LWorld:getGravity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Gravity X component in world units per second squared. |
| number | Gravity Y component in world units per second squared. |

---

#### `LWorld:getGravityVector`

Returns an additive gravity vector by ID, or nil when no active vector exists.

```lua
LWorld:getGravityVector(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Gravity vector ID returned by addGravityVector. |

**Returns**

| Type | Description |
|------|-------------|
| table? | Table with id, gx, gy, layerMask, and enabled fields. |

---

#### `LWorld:getJointBodies`

Returns the two body IDs connected by a joint.

```lua
LWorld:getJointBodies(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Body A ID. |
| number | Body B ID. |

---

#### `LWorld:getJointBreakForce`

Returns the break force threshold for a joint.

```lua
LWorld:getJointBreakForce(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Break force value. |

---

#### `LWorld:getJointIds`

Returns a sequential table of all joint IDs currently in the world.

```lua
LWorld:getJointIds()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Joint ID numbers. |

---

#### `LWorld:getJointLimits`

Returns the lower and upper limit values for a joint.

```lua
LWorld:getJointLimits(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Lower limit. |
| number | Upper limit. |

---

#### `LWorld:getJointMotorSpeed`

Returns the current motor speed setting of a joint.

```lua
LWorld:getJointMotorSpeed(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Motor speed value. |

---

#### `LWorld:getJointType`

Returns the type name of a joint (e.g. "revolute", "distance", "prismatic").

```lua
LWorld:getJointType(jointId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |

**Returns**

| Type | Description |
|------|-------------|
| string | The joint type name. |

---

#### `LWorld:getMeter`

Returns the current pixels-per-meter scale.

```lua
LWorld:getMeter()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Pixels per meter. |

---

#### `LWorld:getSolverIterations`

Returns the current number of velocity solver iterations.

```lua
LWorld:getSolverIterations()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Iteration count. |

---

#### `LWorld:getStats`

Returns active counts and slot diagnostics for the world.

```lua
LWorld:getStats()
```

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetStatsResult | Stats table with bodies, bodySlots, colliders, joints, jointSlots, zones, gravityVectors, sleepingBodies. |

---

#### `LWorld:getZoneEvents`

Returns all zone enter/leave events from the last step.

```lua
LWorld:getZoneEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| LWorldGetZoneEventsResult | Array of {zone_id, body_id, kind} tables where kind is "enter" or "leave". |

---

#### `LWorld:hasBody`

Returns true when a body ID still refers to a live body slot.

```lua
LWorld:hasBody(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Body ID to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the body is active. |

---

#### `LWorld:hasJoint`

Returns true when a joint ID still refers to a live joint slot.

```lua
LWorld:hasJoint(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Joint ID to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the joint is active. |

---

#### `LWorld:isBodySleeping`

Returns whether a body is currently in the sleeping (inactive) state.

```lua
LWorld:isBodySleeping(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the body is sleeping. |

---

#### `LWorld:jointCount`

Returns the total number of joints in the world.

```lua
LWorld:jointCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Joint count. |

---

#### `LWorld:newBodies`

Batch-creates multiple bodies at once for better performance. Each entry is {x, y, w, h, type} or {x, y, type}.

```lua
LWorld:newBodies(specs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `specs` | table | Array of tables: {{x, y, w, h, "dynamic"}, ...} or {{x, y, "dynamic"}, ...} (defaults to 16x16). |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Body ID numbers in creation order. |

---

#### `LWorld:newBody`

Creates a new physics body at the given position with the specified type and dimensions.

```lua
LWorld:newBody(x, y, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Initial X position in world coordinates. |
| `y` | number | Initial Y position in world coordinates. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

---

#### `LWorld:newChainBody`

Creates a new body with a chain (polyline) collider. Useful for terrain edges.

```lua
LWorld:newChainBody(x, y, vertices, closed, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Body X position in world coordinates. |
| `y` | number | Body Y position in world coordinates. |
| `vertices` | table | Flat array of vertex coordinates {x1,y1,x2,y2,...}. |
| `closed` | boolean | If true, connects the last vertex back to the first. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

---

#### `LWorld:newCircleBody`

Creates a new body with a circle collider already attached.

```lua
LWorld:newCircleBody(x, y, radius, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Initial X position in world coordinates. |
| `y` | number | Initial Y position in world coordinates. |
| `radius` | number | Circle radius in world units. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

---

#### `LWorld:newEdgeBody`

Creates a new body with an edge (line segment) collider between two local points.

```lua
LWorld:newEdgeBody(x, y, x1, y1, x2, y2, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Body X position in world coordinates. |
| `y` | number | Body Y position in world coordinates. |
| `x1` | number | Edge start X relative to body. |
| `y1` | number | Edge start Y relative to body. |
| `x2` | number | Edge end X relative to body. |
| `y2` | number | Edge end Y relative to body. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

---

#### `LWorld:newPolygonBody`

Creates a new body with a convex polygon collider defined by vertex pairs.

```lua
LWorld:newPolygonBody(x, y, vertices, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Initial X position in world coordinates. |
| `y` | number | Initial Y position in world coordinates. |
| `vertices` | table | Flat array of vertex coordinates {x1,y1,x2,y2,...}. |
| `bodyType` | string | One of "static", "dynamic", "kinematic", or "sensor". |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](#lbody) | The newly created body handle. |

---

#### `LWorld:queryAABB`

Returns all body IDs whose axis-aligned bounding boxes overlap the given rectangle.

```lua
LWorld:queryAABB(x, y, w, h, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Query rectangle left X. |
| `y` | number | Query rectangle top Y. |
| `w` | number | Query rectangle width. |
| `h` | number | Query rectangle height. |
| `filter?` | table | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?}. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Body ID numbers found in the region. |

---

#### `LWorld:raycast`

Casts a ray from point (x1,y1) to (x2,y2) and returns the first body hit, or nil.

```lua
LWorld:raycast(x1, y1, x2, y2, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | Ray origin X. |
| `y1` | number | Ray origin Y. |
| `x2` | number | Ray end X. |
| `y2` | number | Ray end Y. |
| `filter?` | table | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?}. |

**Returns**

| Type | Description |
|------|-------------|
| LWorldRaycastResult | Hit info {bodyId, x, y, normalX, normalY, toi} or nil if no hit. |

---

#### `LWorld:raycastAll`

Casts a directional ray and returns all bodies hit within max distance as a table of results.

```lua
LWorld:raycastAll(x, y, dx, dy, maxDist, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Ray origin X. |
| `y` | number | Ray origin Y. |
| `dx` | number | Ray direction X. |
| `dy` | number | Ray direction Y. |
| `maxDist` | number | Maximum ray travel distance. |
| `filter?` | table | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?}. |

**Returns**

| Type | Description |
|------|-------------|
| LWorldRaycastAllResult | Array of hit tables {bodyId, x, y, normalX, normalY, toi}. |

---

#### `LWorld:raycastClosest`

Casts a directional ray from a point and returns the closest hit within max distance.

```lua
LWorld:raycastClosest(x, y, dx, dy, maxDist, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Ray origin X. |
| `y` | number | Ray origin Y. |
| `dx` | number | Ray direction X (does not need to be normalized). |
| `dy` | number | Ray direction Y. |
| `maxDist` | number | Maximum ray travel distance. |
| `filter?` | table | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?}. |

**Returns**

| Type | Description |
|------|-------------|
| LWorldRaycastClosestResult | Hit info {bodyId, x, y, normalX, normalY, toi} or nil if no hit. |

---

#### `LWorld:removeGravityVector`

Removes one additive gravity vector so it no longer affects future steps.

```lua
LWorld:removeGravityVector(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Gravity vector ID returned by addGravityVector. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if an active vector was removed. |

---

#### `LWorld:resetCollisionGroups`

Restores all 16 collision groups so every group can collide with every other group.

```lua
LWorld:resetCollisionGroups()
```

---

#### `LWorld:resetWorld`

Fully resets the world to its post-construction state.

```lua
LWorld:resetWorld()
```

---

#### `LWorld:setBeginContact`

Registers a callback function invoked whenever two bodies begin touching.

```lua
LWorld:setBeginContact(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | Called with (bodyIdA, bodyIdB) on each new contact. |

---

#### `LWorld:setBodyCCD`

Enables or disables continuous collision detection (bullet mode) on a body to prevent tunneling.

```lua
LWorld:setBodyCCD(id, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |
| `enabled` | boolean | True to enable CCD. |

---

#### `LWorld:setBodyData`

Attaches arbitrary Lua data to a body ID for later retrieval (e.g. entity reference, tag).

```lua
LWorld:setBodyData(id, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |
| `value` | any | Lua value to associate with this body (table, number, string, etc.). |

---

#### `LWorld:setBodyOneWay`

Marks a body as a one-way platform: other bodies can pass through from the opposite side of the normal.

```lua
LWorld:setBodyOneWay(id, nx, ny)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |
| `nx` | number | One-way normal X (points toward the blocking side). |
| `ny` | number | One-way normal Y. |

---

#### `LWorld:setBodyType`

Changes the type of an existing body (e.g. from "dynamic" to "static").

```lua
LWorld:setBodyType(id, bodyType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |
| `bodyType` | string | New type: "static", "dynamic", "kinematic", or "sensor". |

---

#### `LWorld:setCollisionGroupMask`

Replaces one row of the 16-group collision matrix.

```lua
LWorld:setCollisionGroupMask(group, mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | number | Source collision group index, 0..15. |
| `mask` | number | Target group bitmask in 0..0xFFFF. |

---

#### `LWorld:setCollisionPair`

Enables or disables collisions between two world-level collision groups.

```lua
LWorld:setCollisionPair(groupA, groupB, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `groupA` | number | First collision group index, 0..15. |
| `groupB` | number | Second collision group index, 0..15. |
| `enabled` | boolean | True to allow collisions, false to block them. |

---

#### `LWorld:setEndContact`

Registers a callback function invoked whenever two bodies stop touching.

```lua
LWorld:setEndContact(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | Called with (bodyIdA, bodyIdB) on each ended contact. |

---

#### `LWorld:setFixtureFriction`

Updates the friction coefficient of a specific fixture on a body.

```lua
LWorld:setFixtureFriction(bodyId, fixtureIndex, friction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body ID. |
| `fixtureIndex` | number | Zero-based fixture index on the body. |
| `friction` | number | New friction value (0Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬Ĺ›1 typical range). |

---

#### `LWorld:setFixtureRestitution`

Updates the restitution (bounciness) of a specific fixture on a body.

```lua
LWorld:setFixtureRestitution(bodyId, fixtureIndex, restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body ID. |
| `fixtureIndex` | number | Zero-based fixture index on the body. |
| `restitution` | number | New restitution value (0 = no bounce, 1 = full bounce). |

---

#### `LWorld:setFixtureSensor`

Toggles whether a fixture acts as a sensor (overlap detection only, no physical response).

```lua
LWorld:setFixtureSensor(bodyId, fixtureIndex, sensor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bodyId` | number | The body ID. |
| `fixtureIndex` | number | Zero-based fixture index on the body. |
| `sensor` | boolean | True to make it a sensor, false for solid collision. |

---

#### `LWorld:setGravity`

Sets the world gravity vector. Affects all dynamic bodies.

```lua
LWorld:setGravity(gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | number | Horizontal gravity component. |
| `gy` | number | Vertical gravity component (positive = down in screen space). |

---

#### `LWorld:setGravityVector`

Replaces the direction, strength, and optional layer mask of an existing additive gravity vector.

```lua
LWorld:setGravityVector(id, gx, gy, layerMask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Gravity vector ID returned by addGravityVector. |
| `gx` | number | Horizontal acceleration in world units per second squared. |
| `gy` | number | Vertical acceleration in world units per second squared. |
| `layerMask?` | number | Optional body layer mask, defaults to all layers. |

---

#### `LWorld:setJointBreakForce`

Sets the maximum force a joint can withstand before it breaks and is automatically destroyed.

```lua
LWorld:setJointBreakForce(jointId, force)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |
| `force` | number | Break threshold force (use math.huge for unbreakable). |

---

#### `LWorld:setJointLimits`

Sets the lower and upper bounds for a joint's limited range of motion.

```lua
LWorld:setJointLimits(jointId, lower, upper)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |
| `lower` | number | Lower limit (radians or meters depending on joint type). |
| `upper` | number | Upper limit. |

---

#### `LWorld:setJointLimitsEnabled`

Enables or disables angular/linear limits on a joint.

```lua
LWorld:setJointLimitsEnabled(jointId, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |
| `enabled` | boolean | True to enforce limits, false to allow free movement. |

---

#### `LWorld:setJointMotorSpeed`

Sets the motor speed on a motorized joint (revolute or prismatic).

```lua
LWorld:setJointMotorSpeed(jointId, speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The joint ID. |
| `speed` | number | Desired motor speed (radians/sec for revolute, meters/sec for prismatic). |

---

#### `LWorld:setMeter`

Sets the pixels-per-meter scale used to convert between pixel coordinates and physics units.

```lua
LWorld:setMeter(ppm)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ppm` | number | Pixels per meter (e.g. 64 means 64 px = 1 meter in physics). |

---

#### `LWorld:setMouseJointTarget`

Moves the target position of a mouse joint, causing the attached body to follow.

```lua
LWorld:setMouseJointTarget(jointId, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jointId` | number | The mouse joint ID. |
| `x` | number | New target X in world coordinates. |
| `y` | number | New target Y in world coordinates. |

---

#### `LWorld:setSolverIterations`

Sets the number of velocity solver iterations. Higher values improve stability at the cost of performance.

```lua
LWorld:setSolverIterations(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of iterations (default is typically 4Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬Ĺ›8). |

---

#### `LWorld:sleepBody`

Forces a body into the sleeping state, pausing its simulation until disturbed.

```lua
LWorld:sleepBody(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

---

#### `LWorld:step`

Advances the physics simulation by a time delta and fires any registered contact callbacks.

```lua
LWorld:step(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Time step in seconds (e.g. 1/60 for 60 FPS). |

---

#### `LWorld:stepFixed`

Performs fixed-timestep physics stepping, consuming accumulated time. Returns the leftover time.

```lua
LWorld:stepFixed(accumulator, stepDt, maxSteps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `accumulator` | number | Accumulated time since last frame (seconds). |
| `stepDt` | number | Fixed step size (e.g. 1/60). |
| `maxSteps` | number | Maximum sub-steps per call to prevent spiral of death. |

**Returns**

| Type | Description |
|------|-------------|
| number | Remaining unstepped time to carry into next frame. |

---

#### `LWorld:toPhysics`

Converts a pixel measurement to physics-world meters using the current meter scale.

```lua
LWorld:toPhysics(px)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | number | Value in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Equivalent value in physics meters. |

---

#### `LWorld:toPixels`

Converts a physics-world meter measurement to pixels using the current meter scale.

```lua
LWorld:toPixels(m)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `m` | number | Value in physics meters. |

**Returns**

| Type | Description |
|------|-------------|
| number | Equivalent value in pixels. |

---

#### `LWorld:type`

Returns the type name of this object ("[LWorld](#lworld)").

```lua
LWorld:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | "[LWorld](#lworld)". |

---

#### `LWorld:typeOf`

Checks if this object is of a given type name. Supports inheritance (always matches "Object").

```lua
LWorld:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object matches. |

---

#### `LWorld:wakeUpBody`

Forces a sleeping body to wake up and participate in simulation again.

```lua
LWorld:wakeUpBody(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The body ID. |

---
