# Particle

## Purpose

Simulates pooled particles with rich shapes, gravity forces, and collider bounces.

## When To Use

- Emitters, particle state, force application, lifetimes, presets, trails, and render bridges all live together here, so effects can be authored as configurations instead of one-off update loops.
- Pooling is central to the design because short-lived effects appear in large numbers and need predictable reuse instead of constant allocation churn.
- Emission rules, spawn shapes, attractors, turbulence, and per-particle lifetime state give the module enough range to cover both ambient effects and gameplay feedback.

## Minimal Example

Example block: `lurek.particle.newSystem`

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        seed = 42,
        maxParticles = 128,
        emissionRate = 24,
        lifetimeMin = 0.25,
        lifetimeMax = 0.75,
    })

    example_print_log("type = " .. ps:type())
    example_print_log("buffer = " .. ps:getBufferSize())
end
```

## Common Patterns

- Start with `lurek.particle.drawLifecycleToImage` when exploring this module.
- Start with `lurek.particle.fromTOML` when exploring this module.
- Start with `lurek.particle.newPreset` when exploring this module.
- Start with `lurek.particle.newSystem` when exploring this module.
- Start with `lurek.particle.newTrail` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `particle` module is the pooled visual-effects system for users who want smoke, sparks, rain, trails, bursts, and other transient visuals to behave like one reusable runtime feature.
- Emitters, particle state, force application, lifetimes, presets, trails, and render bridges all live together here, so effects can be authored as configurations instead of one-off update loops.
- Pooling is central to the design because short-lived effects appear in large numbers and need predictable reuse instead of constant allocation churn.
- Emission rules, spawn shapes, attractors, turbulence, and per-particle lifetime state give the module enough range to cover both ambient effects and gameplay feedback.
- Per-particle state is not only position and color. Lifetime, velocity, size evolution, rotation, and other update-time values determine how an effect feels over time and are part of the same runtime model.
- Sub-emitters, trails, and simple collision hooks matter because many practical effects need layered motion and lightweight grounding in world space.
- Force handling is especially important because many effects are really motion systems: wind, gravity-like influence, turbulence, and attractors all shape how a burst reads to the player.
- Spawn-shape variety matters too, since emitters often need circles, lines, cones, boxes, or directional releases rather than a single point source.
- Presets and visualization support make the system useful for iteration, docs, tests, and content authoring as well as for final shipped visuals.
- The same pooled model also keeps high-volume effects legible for debugging, because emitters, lifetimes, and force rules remain inspectable instead of dissolving into ad hoc update code.
- The module is useful for combat hits, weather, ambience, UI flourishes, projectiles, and other procedural or semi-procedural effect workflows.
- `render` draws the result and `physics` may inform light collision behavior, but `particle` owns effect spawning, pooled update logic, and transient visual behavior over time.
- Read `particle` as the subsystem that decides how short-lived procedural effects are described, updated, reused, and inspected.

This module primarily collaborates with `color`, `image`, `math`, `physics`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.particle.drawLifecycleToImage`

Draws a lifecycle chart image from `(step, count)` snapshot tables.

```lua
lurek.particle.drawLifecycleToImage(snapshots, max_particles, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshots` | table | Array of snapshot tables or `{step, count}` arrays. |
| `max_particles` | number | Maximum particle count for chart scaling. |
| `w` | number | Image width. |
| `h` | number | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Image data containing the lifecycle chart. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local snapshots = {
        { 0, 0 },
        { 5, 12 },
        { 10, 4 },
    }
    local image = lurek.particle.drawLifecycleToImage(snapshots, 16, 128, 64)
    example_print_log("lifecycle type = " .. image:type())
    example_print_log("lifecycle width = " .. image:getWidth())
end
```

---

### `lurek.particle.fromTOML`

Creates a particle system from a TOML config file.

```lua
lurek.particle.fromTOML(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | TOML file path. The TOML config may include `seed` for deterministic emission. |

**Returns**

| Type | Description |
|------|-------------|
| [LParticleSystem](#lparticlesystem) | New particle system handle. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local path = "save/particle_example.toml"
    lurek.filesystem.write(path, "seed = 42\nmax_particles = 96\nemission_rate = 18.0\nlifetime_min = 0.2\nlifetime_max = 0.8\n")

    local ps = lurek.particle.fromTOML(path)
    example_print_log("type = " .. ps:type())
    example_print_log("buffer = " .. ps:getBufferSize())
end
```

---

### `lurek.particle.newPreset`

Creates a particle system from a named preset.

```lua
lurek.particle.newPreset(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Preset name: `fire`, `smoke`, `rain`, `snow`, or `sparks`. |

**Returns**

| Type | Description |
|------|-------------|
| [LParticleSystem](#lparticlesystem) | New particle system handle. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fire = lurek.particle.newPreset("fire")
    fire:setPosition(160, 220)
    fire:setEmissionRate(48)
    local x, y = fire:getPosition()
    local rate = fire:getEmissionRate()
    particle_log("campfire preset at " .. x .. "," .. y .. " emits " .. rate)
end
```

---

### `lurek.particle.newSystem`

Creates a particle system from an optional config table.

```lua
lurek.particle.newSystem(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Particle config table. Supports `seed` for deterministic emission and reset behavior. |

**Returns**

| Type | Description |
|------|-------------|
| [LParticleSystem](#lparticlesystem) | New particle system handle. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        seed = 42,
        maxParticles = 128,
        emissionRate = 24,
        lifetimeMin = 0.25,
        lifetimeMax = 0.75,
    })

    example_print_log("type = " .. ps:type())
    example_print_log("buffer = " .. ps:getBufferSize())
end
```

---

### `lurek.particle.newTrail`

Creates a trail effect. This function is exposed to Lua scripts.

```lua
lurek.particle.newTrail(lifetime, start_width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lifetime` | number | Trail point lifetime. |
| `start_width` | number | Trail start width. |

**Returns**

| Type | Description |
|------|-------------|
| [LTrail](#ltrail) | New trail handle. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(2.0, 8)
    trail:pushPoint(0, 0)
    trail:pushPoint(24, 12)
    local type_name = trail:type()
    local lifetime = trail:getLifetime()
    particle_log(type_name .. " lifetime " .. lifetime .. " with " .. trail:getPointCount() .. " points")
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LImageData](#limagedata)
- [LParticleSystem](#lparticlesystem)
- [LTrail](#ltrail)

## LImageData

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LImageData:alphaMask`

Multiplies this image alpha channel by a factor in place.

```lua
LImageData:alphaMask(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Alpha multiplier. |

---

#### `LImageData:applyEffect`

Applies a named image effect in place, or returns a new image when the effect changes size.

```lua
LImageData:applyEffect(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Effect name. |
| `opts?` | table | Effect options such as `factor`, `amount`, `radius`, `levels`, `region`, or `color`. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | New image for size-changing effects, otherwise nil. |

---

#### `LImageData:applyEffects`

Applies a sequence of named effects in order.

```lua
LImageData:applyEffects(effects, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `effects` | table | Array of effect names or `{name=..., opts=...}` tables. |
| `opts?` | table | Default options used by string entries. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | Last new image returned by a size-changing effect, otherwise nil. |

---

#### `LImageData:applyMask`

Multiplies this image alpha by another image's alpha channel.

```lua
LImageData:applyMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | [LImageData](#limagedata) | Same-sized alpha mask image. |

---

#### `LImageData:applyPaletteLut`

Applies a palette lookup table to this image in place.

```lua
LImageData:applyPaletteLut(lut_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lut_ud` | [LPaletteLUT](image.md#lpalettelut) | Palette lookup table handle. |

---

#### `LImageData:blit`

Copies a source image into this image at a destination coordinate.

```lua
LImageData:blit(src_ud, dst_x, dst_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata) | Source image data handle. |
| `dst_x` | number | Destination x coordinate. |
| `dst_y` | number | Destination y coordinate. |

---

#### `LImageData:blur`

Returns a blurred copy of this image.

```lua
LImageData:blur(radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius` | number | Blur radius. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Blurred image data handle. |

---

#### `LImageData:brightness`

Applies a brightness factor to this image in place.

```lua
LImageData:brightness(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Brightness multiplier or adjustment factor. |

---

#### `LImageData:clone`

Returns a deep copy of this image data.

```lua
LImageData:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Copied image data. |

---

#### `LImageData:contrast`

Applies a contrast factor to this image in place.

```lua
LImageData:contrast(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Contrast factor. |

---

#### `LImageData:convolve`

Applies a convolution kernel and returns the filtered image.

```lua
LImageData:convolve(kernel_t, ksize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kernel_t` | table | Array table of numeric kernel weights. |
| `ksize` | number | Kernel width and height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Convolved image data handle. |

---

#### `LImageData:copyRegion`

Copies a rectangular region into a new image.

```lua
LImageData:copyRegion(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Source x coordinate. |
| `y` | number | Source y coordinate. |
| `w` | number | Region width. |
| `h` | number | Region height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Copied region. |

---

#### `LImageData:crop`

Returns a cropped image region. This method is available to Lua scripts.

```lua
LImageData:crop(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Source x coordinate. |
| `y` | number | Source y coordinate. |
| `w` | number | Crop width. |
| `h` | number | Crop height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Cropped image data handle. |

---

#### `LImageData:diff`

Computes a difference metric against another image.

```lua
LImageData:diff(other_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other_ud` | [LImageData](#limagedata) | Image data handle to compare with this image. |

**Returns**

| Type | Description |
|------|-------------|
| number | Difference score. |

---

#### `LImageData:drawCircle`

Draws a filled circle into this image.

```lua
LImageData:drawCircle(cx, cy, radius, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Circle center x coordinate. |
| `cy` | number | Circle center y coordinate. |
| `radius` | number | Circle radius. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:drawLine`

Draws a line into this image. This method is available to Lua scripts.

```lua
LImageData:drawLine(x0, y0, x1, y1, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x0` | number | Start x coordinate. |
| `y0` | number | Start y coordinate. |
| `x1` | number | End x coordinate. |
| `y1` | number | End y coordinate. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:drawRect`

Draws a filled rectangle into this image.

```lua
LImageData:drawRect(x, y, w, h, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Rectangle x coordinate. |
| `y` | number | Rectangle y coordinate. |
| `w` | number | Rectangle width. |
| `h` | number | Rectangle height. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:encode`

Encodes image data in a supported format.

```lua
LImageData:encode(format)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format` | string | Format name; currently `png`. |

**Returns**

| Type | Description |
|------|-------------|
| string | Encoded image bytes. |

---

#### `LImageData:fill`

Fills the whole image with one RGBA color.

```lua
LImageData:fill(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:flipHorizontal`

Flips this image horizontally in place.

```lua
LImageData:flipHorizontal()
```

---

#### `LImageData:flipVertical`

Flips this image vertically in place.

```lua
LImageData:flipVertical()
```

---

#### `LImageData:gamma`

Applies gamma correction to this image in place.

```lua
LImageData:gamma(gamma)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gamma` | number | Gamma value. |

---

#### `LImageData:getDimensions`

Returns image dimensions. This method is available to Lua scripts.

```lua
LImageData:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |
| number | Height in pixels. |

---

#### `LImageData:getHeight`

Returns image height. This method is available to Lua scripts.

```lua
LImageData:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

---

#### `LImageData:getPixel`

Returns RGBA channels at a pixel coordinate.

```lua
LImageData:getPixel(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

---

#### `LImageData:getRawBytes`

Returns raw image bytes as a Lua string.

```lua
LImageData:getRawBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Raw image byte string. |

---

#### `LImageData:getRegion`

Returns an image region when the requested rectangle is inside bounds.

```lua
LImageData:getRegion(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Region x coordinate. |
| `y` | number | Region y coordinate. |
| `w` | number | Region width. |
| `h` | number | Region height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | `[LImageData](#limagedata)` handle, or nil when the region is out of bounds. |

---

#### `LImageData:getString`

Returns raw image bytes as a Lua string.

```lua
LImageData:getString()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Raw image byte string. |

---

#### `LImageData:getWidth`

Returns image width. This method is available to Lua scripts.

```lua
LImageData:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

---

#### `LImageData:grayscale`

Converts this image to grayscale in place.

```lua
LImageData:grayscale()
```

---

#### `LImageData:invert`

Inverts image color channels in place.

```lua
LImageData:invert()
```

---

#### `LImageData:mapPixel`

Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.

```lua
LImageData:mapPixel(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels. |

---

#### `LImageData:mapPixels`

Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.

```lua
LImageData:mapPixels(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels. |

---

#### `LImageData:noise`

Adds noise to this image in place. This method is available to Lua scripts.

```lua
LImageData:noise(amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amount` | number | Noise amount. |

---

#### `LImageData:paste`

Pastes a source image into this image at unsigned destination coordinates.

```lua
LImageData:paste(src_ud, dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata) | Source image data handle. |
| `dx` | number | Destination x coordinate. |
| `dy` | number | Destination y coordinate. |

---

#### `LImageData:posterize`

Reduces image colors to a fixed number of levels in place.

```lua
LImageData:posterize(levels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `levels` | number | Number of posterization levels. |

---

#### `LImageData:resize`

Returns a resized image using an optional named filter.

```lua
LImageData:resize(width, height, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Output width. |
| `height` | number | Output height. |
| `filter` | string | Optional filter name, defaulting to `bilinear`. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | Resized `[LImageData](#limagedata)` handle, or nil when resizing fails. |

---

#### `LImageData:resizeNearest`

Returns a resized image using nearest-neighbor sampling.

```lua
LImageData:resizeNearest(new_w, new_h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `new_w` | number | Output width. |
| `new_h` | number | Output height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Resized image data handle. |

---

#### `LImageData:rotate90cw`

Returns a new image rotated ninety degrees clockwise.

```lua
LImageData:rotate90cw()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Rotated image data handle. |

---

#### `LImageData:saturation`

Applies a saturation factor to this image in place.

```lua
LImageData:saturation(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Saturation factor. |

---

#### `LImageData:sepia`

Applies a sepia filter to this image in place.

```lua
LImageData:sepia()
```

---

#### `LImageData:setPixel`

Sets RGBA channels at a pixel coordinate.

```lua
LImageData:setPixel(x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

---

#### `LImageData:setRawData`

Replaces the image byte buffer with raw bytes.

```lua
LImageData:setRawData(bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bytes` | string | Raw byte string matching the image storage size. |

---

#### `LImageData:sharpen`

Returns a sharpened copy of this image.

```lua
LImageData:sharpen()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Sharpened image data handle. |

---

#### `LImageData:threshold`

Applies a threshold filter to this image in place.

```lua
LImageData:threshold(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | Threshold channel value. |

---

#### `LImageData:tint`

Blends this image toward a tint color in place.

```lua
LImageData:tint(tr, tg, tb, factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tr` | number | Tint red channel. |
| `tg` | number | Tint green channel. |
| `tb` | number | Tint blue channel. |
| `factor` | number | Tint blend factor. |

---

#### `LImageData:transform`

Returns a transformed image, currently supporting high-quality resize through `width`, `height`, and `filter`.

```lua
LImageData:transform(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Transform options. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Transformed image. |

---

#### `LImageData:type`

Returns the Lua-visible type name for this image data handle.

```lua
LImageData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LImageData](#limagedata)`. |

---

#### `LImageData:typeOf`

Returns whether this image data handle matches the `[LImageData](#limagedata)` type name.

```lua
LImageData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LImageData](#limagedata)` or `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches. |

---

## LParticleSystem

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LParticleSystem:addAttractor`

Adds an attractor to the particle system.

```lua
LParticleSystem:addAttractor(x, y, strength, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Attractor x position. |
| `y` | number | Attractor y position. |
| `strength` | number | Attraction strength. |
| `radius` | number | Attraction radius. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:setPosition(400, 300)
    ps:setSpeed(50, 150)
    ps:setSpread(math.pi * 2)
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    example_print_log("attractors = " .. ps:getAttractorCount())
end
```

---

#### `LParticleSystem:addSubEmitter`

Configures a death sub-emitter from a config table.

```lua
LParticleSystem:addSubEmitter(config_tbl, burst_count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config_tbl` | table | Particle config table. Supports `seed` for deterministic sub-emission. |
| `burst_count?` | number | Burst count per death. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 256,
    })
    ps:addSubEmitter({
        emissionRate = 20,
        speedMin = 10,
        speedMax = 30,
        lifetimeMin = 0.2,
        lifetimeMax = 0.5,
    }, 5)

    example_print_log("sub-systems = " .. ps:subSystemCount())
end
```

---

#### `LParticleSystem:addSubSystem`

Adds a particle sub-system from a config table.

```lua
LParticleSystem:addSubSystem(config_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config_tbl` | table | Particle config table. Supports `seed` for deterministic sub-systems. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based sub-system index. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 256,
    })
    local idx = ps:addSubSystem({
        emissionRate = 10,
        speedMin = 5,
        speedMax = 15,
        lifetimeMin = 0.3,
        lifetimeMax = 0.6,
    })

    example_print_log("sub-system index = " .. idx)
    example_print_log("sub-system count = " .. ps:subSystemCount())
end
```

---

#### `LParticleSystem:clearAttractors`

Clears all attractors on this object.

```lua
LParticleSystem:clearAttractors()
```

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    example_print_log("before clear = " .. ps:getAttractorCount())
    ps:clearAttractors()
    example_print_log("after clear = " .. ps:getAttractorCount())
end
```

---

#### `LParticleSystem:clearBounds`

Clears collision bounds on this object.

```lua
LParticleSystem:clearBounds()
```

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setBounds(0, 800, 0, 600, 0.5)

    example_print_log("bounds set")
    ps:clearBounds()
    example_print_log("bounds cleared")
end
```

---

#### `LParticleSystem:clearCollidesWithPhysics`

Disables particle collision against a physics world.

```lua
LParticleSystem:clearCollidesWithPhysics()
```

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    example_print_log("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
    ps:clearCollidesWithPhysics()
    example_print_log("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end
```

---

#### `LParticleSystem:clone`

Clones this particle system configuration into a new system handle.

```lua
LParticleSystem:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LParticleSystem](#lparticlesystem) | New particle system handle. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 256,
        emissionRate = 75,
    })
    ps:setSpeed(80, 160)
    ps:setGravity(0, 100)

    local copy = ps:clone()
    example_print_log("clone buffer = " .. copy:getBufferSize())
    example_print_log("clone rate = " .. copy:getEmissionRate())
end
```

---

#### `LParticleSystem:count`

Returns the current particle count.

```lua
LParticleSystem:count()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Particle count. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(6)

    example_print_log("count = " .. ps:count())
end
```

---

#### `LParticleSystem:drawExplosionToImage`

Draws particles as an explosion preview image.

```lua
LParticleSystem:drawExplosionToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Image width. |
| `h` | number | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Image data containing the explosion preview. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("fire")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawExplosionToImage(128, 128)
    example_print_log("explosion type = " .. image:type())
    example_print_log("explosion width = " .. image:getWidth())
end
```

---

#### `LParticleSystem:drawOverImage`

Draws particles over an existing image and returns a composited copy.

```lua
LParticleSystem:drawOverImage(image)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | [LImageData](#limagedata) | Background image data handle. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Image data containing the composited result. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)
    local image = lurek.image.newImageData(128, 128)
    image:fill(16, 16, 16, 255)

    local over = ps:drawOverImage(image)
    example_print_log("overlay type = " .. over:type())
    example_print_log("overlay width = " .. over:getWidth())
end
```

---

#### `LParticleSystem:drawRainToImage`

Draws particles as a rain preview image.

```lua
LParticleSystem:drawRainToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Image width. |
| `h` | number | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Image data containing the rain preview. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("rain")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawRainToImage(128, 128)
    example_print_log("rain type = " .. image:type())
    example_print_log("rain height = " .. image:getHeight())
end
```

---

#### `LParticleSystem:drawSparkTrailToImage`

Draws particles as a spark-trail preview image.

```lua
LParticleSystem:drawSparkTrailToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Image width. |
| `h` | number | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Image data containing the spark preview. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawSparkTrailToImage(128, 128)
    example_print_log("spark type = " .. image:type())
    example_print_log("spark width = " .. image:getWidth())
end
```

---

#### `LParticleSystem:drawToImage`

Draws particles to image data. This method is available to Lua scripts.

```lua
LParticleSystem:drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Image width. |
| `h` | number | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Image data containing the rendered particles. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawToImage(128, 128)
    example_print_log("drawToImage type = " .. image:type())
end
```

---

#### `LParticleSystem:emit`

Emits particles immediately. This method is available to Lua scripts.

```lua
LParticleSystem:emit(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Number of particles to emit. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 512,
    })
    ps:setPosition(400, 300)
    ps:setSpeed(50, 150)
    ps:setSpread(math.pi * 2)
    ps:emit(100)

    example_print_log("after emit = " .. ps:count())
end
```

---

#### `LParticleSystem:getAttractorCount`

Returns attractor count. This method is available to Lua scripts.

```lua
LParticleSystem:getAttractorCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Attractor count. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    example_print_log("attractors = " .. ps:getAttractorCount())
end
```

---

#### `LParticleSystem:getBufferSize`

Returns maximum particle buffer size.

```lua
LParticleSystem:getBufferSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum particle count. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(90)
    ps:setBufferSize(1024)
    local buffer = ps:getBufferSize()
    local rate = ps:getEmissionRate()
    particle_log("buffer " .. buffer .. " supports rate " .. rate)
end
```

---

#### `LParticleSystem:getColors`

Returns particle color keyframes.

```lua
LParticleSystem:getColors()
```

**Returns**

| Type | Description |
|------|-------------|
| LParticleSystemGetColorsResult | Array table of RGBA color tables. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setColors({1, 0.5, 0, 1}, {1, 0, 0, 0})

    local colors = ps:getColors()
    example_print_log("color keyframes = " .. #colors)
    example_print_log("last alpha = " .. colors[#colors][4])
end
```

---

#### `LParticleSystem:getCount`

Returns particle count and errors if the handle was released.

```lua
LParticleSystem:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Particle count. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(6)

    example_print_log("getCount = " .. ps:getCount())
end
```

---

#### `LParticleSystem:getDirection`

Returns emission direction. This method is available to Lua scripts.

```lua
LParticleSystem:getDirection()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Direction angle. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpeed(40, 60)
    ps:setDirection(math.pi / 2)
    local dir = ps:getDirection()
    local min_speed = select(1, ps:getSpeed())
    particle_log("leaf burst direction " .. dir .. " from speed floor " .. min_speed)
end
```

---

#### `LParticleSystem:getEmissionArea`

Returns emission area distribution and size.

```lua
LParticleSystem:getEmissionArea()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Distribution name. |
| number | Area width. |
| number | Area height. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 3)
    ps:setEmissionArea("uniform", 100, 50)
    local dist, width, height = ps:getEmissionArea()
    local dir = ps:getDirection()
    particle_log("spawn area " .. dist .. " " .. width .. "x" .. height .. " dir " .. dir)
end
```

---

#### `LParticleSystem:getEmissionRate`

Returns emission rate. This method is available to Lua scripts.

```lua
LParticleSystem:getEmissionRate()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Particles per second. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.2, 0.8)
    ps:setEmissionRate(100)
    local rate = ps:getEmissionRate()
    local min_life = select(1, ps:getParticleLifetime())
    particle_log("muzzle flash emits " .. rate .. " with min lifetime " .. min_life)
end
```

---

#### `LParticleSystem:getEmitterLifetime`

Returns emitter lifetime. This method is available to Lua scripts.

```lua
LParticleSystem:getEmitterLifetime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Emitter lifetime. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setPosition(320, 180)
    ps:setEmitterLifetime(5.0)
    local emitter_life = ps:getEmitterLifetime()
    local x = select(1, ps:getPosition())
    particle_log("storm cloud at x=" .. x .. " lives " .. emitter_life .. "s")
end
```

---

#### `LParticleSystem:getFlipbook`

Returns flipbook grid and frame rate when configured.

```lua
LParticleSystem:getFlipbook()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Column count; or nil when unconfigured. |
| number | Row count; or nil when unconfigured. |
| number | Frame rate; or nil when unconfigured. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(30)
    ps:setFlipbook(4, 4, 12)
    local cols, rows, fps = ps:getFlipbook()
    local rate = ps:getEmissionRate()
    particle_log("flipbook " .. cols .. "x" .. rows .. " @" .. fps .. "fps at rate " .. rate)
end
```

---

#### `LParticleSystem:getGravity`

Returns particle gravity. This method is available to Lua scripts.

```lua
LParticleSystem:getGravity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Gravity x. |
| number | Gravity y. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.5, 1.5)
    ps:setGravity(0, 200)
    local gx, gy = ps:getGravity()
    local max_life = select(2, ps:getParticleLifetime())
    particle_log("dust gravity " .. gx .. "," .. gy .. " over lifetime " .. max_life)
end
```

---

#### `LParticleSystem:getInsertMode`

Returns particle insert mode. This method is available to Lua scripts.

```lua
LParticleSystem:getInsertMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Insert mode name. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setBufferSize(32)
    ps:setInsertMode("bottom")
    local mode = ps:getInsertMode()
    local buffer = ps:getBufferSize()
    particle_log("insert mode " .. mode .. " within pool " .. buffer)
end
```

---

#### `LParticleSystem:getLinearAcceleration`

Returns linear acceleration range.

```lua
LParticleSystem:getLinearAcceleration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum x acceleration. |
| number | Minimum y acceleration. |
| number | Maximum x acceleration. |
| number | Maximum y acceleration. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(-math.pi / 2)
    ps:setLinearAcceleration(-10, 50, 10, 100)
    local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
    local dir = ps:getDirection()
    particle_log("read accel " .. xmin .. "," .. ymin .. ".." .. xmax .. "," .. ymax .. " dir " .. dir)
end
```

---

#### `LParticleSystem:getLinearDamping`

Returns linear damping range. This method is available to Lua scripts.

```lua
LParticleSystem:getLinearDamping()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum damping. |
| number | Maximum damping. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.6, 1.2)
    ps:setLinearDamping(0.1, 0.5)
    local min_damping, max_damping = ps:getLinearDamping()
    local max_life = select(2, ps:getParticleLifetime())
    particle_log("damping " .. min_damping .. ".." .. max_damping .. " over " .. max_life .. "s")
end
```

---

#### `LParticleSystem:getOffset`

Returns particle spawn offset. This method is available to Lua scripts.

```lua
LParticleSystem:getOffset()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Offset x. |
| number | Offset y. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 2)
    ps:setOffset(16, 16)
    local ox, oy = ps:getOffset()
    local dir = ps:getDirection()
    particle_log("offset " .. ox .. "," .. oy .. " for direction " .. dir)
end
```

---

#### `LParticleSystem:getParticleLifetime`

Returns particle lifetime range. This method is available to Lua scripts.

```lua
LParticleSystem:getParticleLifetime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum lifetime. |
| number | Maximum lifetime. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpeed(20, 80)
    ps:setParticleLifetime(0.5, 3.0)
    local min_life, max_life = ps:getParticleLifetime()
    local max_speed = select(2, ps:getSpeed())
    particle_log("spark lifetime " .. min_life .. ".." .. max_life .. " with speed ceiling " .. max_speed)
end
```

---

#### `LParticleSystem:getPosition`

Returns emitter position. This method is available to Lua scripts.

```lua
LParticleSystem:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Emitter x coordinate. |
| number | Emitter y coordinate. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setOffset(12, -4)
    ps:setPosition(100, 200)
    local x, y = ps:getPosition()
    local ox, oy = ps:getOffset()
    particle_log("projectile trail anchor " .. x .. "," .. y .. " offset " .. ox .. "," .. oy)
end
```

---

#### `LParticleSystem:getRadialAcceleration`

Returns radial acceleration range.

```lua
LParticleSystem:getRadialAcceleration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum acceleration. |
| number | Maximum acceleration. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi * 2)
    ps:setRadialAcceleration(-50, 50)
    local min_radial, max_radial = ps:getRadialAcceleration()
    local spread = ps:getSpread()
    particle_log("radial accel " .. min_radial .. ".." .. max_radial .. " with spread " .. spread)
end
```

---

#### `LParticleSystem:getRotation`

Returns particle rotation range. This method is available to Lua scripts.

```lua
LParticleSystem:getRotation()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum rotation. |
| number | Maximum rotation. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpin(-1, 1)
    ps:setRotation(0, math.pi * 2)
    local min_rotation, max_rotation = ps:getRotation()
    local min_spin = select(1, ps:getSpin())
    particle_log("rotation " .. min_rotation .. ".." .. max_rotation .. " with min spin " .. min_spin)
end
```

---

#### `LParticleSystem:getShape`

Returns particle shape. This method is available to Lua scripts.

```lua
LParticleSystem:getShape()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Shape name. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpinVariation(0.25)
    ps:setShape("circle")
    local shape = ps:getShape()
    local variation = ps:getSpinVariation()
    particle_log("shape readback " .. shape .. " with spin variation " .. variation)
end
```

---

#### `LParticleSystem:getSizeVariation`

Returns size variation. This method is available to Lua scripts.

```lua
LParticleSystem:getSizeVariation()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Size variation. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)
    ps:setSizeVariation(0.3)
    local variation = ps:getSizeVariation()
    local first_size = ps:getSizes()[1]
    particle_log("size variation " .. variation .. " with first size " .. first_size)
end
```

---

#### `LParticleSystem:getSizes`

Returns particle size keyframes. This method is available to Lua scripts.

```lua
LParticleSystem:getSizes()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of size values. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)

    local sizes = ps:getSizes()
    example_print_log("size count = " .. #sizes)
    example_print_log("last size = " .. sizes[#sizes])
end
```

---

#### `LParticleSystem:getSpeed`

Returns particle speed range. This method is available to Lua scripts.

```lua
LParticleSystem:getSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum speed. |
| number | Maximum speed. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi / 12)
    ps:setSpeed(50, 200)
    local min_speed, max_speed = ps:getSpeed()
    local spread = ps:getSpread()
    particle_log("fountain speed " .. min_speed .. ".." .. max_speed .. " with spread " .. spread)
end
```

---

#### `LParticleSystem:getSpin`

Returns particle spin range. This method is available to Lua scripts.

```lua
LParticleSystem:getSpin()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum spin. |
| number | Maximum spin. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setShape("ring")
    ps:setSpin(-3, 3)
    local min_spin, max_spin = ps:getSpin()
    local shape = ps:getShape()
    particle_log("spin " .. min_spin .. ".." .. max_spin .. " for shape " .. shape)
end
```

---

#### `LParticleSystem:getSpinVariation`

Returns spin variation. This method is available to Lua scripts.

```lua
LParticleSystem:getSpinVariation()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Spin variation. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setRotation(0, 0.5)
    ps:setSpinVariation(0.5)
    local variation = ps:getSpinVariation()
    local max_rotation = select(2, ps:getRotation())
    particle_log("spin variation " .. variation .. " with max rotation " .. max_rotation)
end
```

---

#### `LParticleSystem:getSpread`

Returns emission spread. This method is available to Lua scripts.

```lua
LParticleSystem:getSpread()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Spread angle. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(24)
    ps:setSpread(math.pi / 6)
    local spread = ps:getSpread()
    local rate = ps:getEmissionRate()
    particle_log("ember spread " .. spread .. " with rate " .. rate)
end
```

---

#### `LParticleSystem:getStats`

Returns a telemetry snapshot for dashboard and debug workflows.

```lua
LParticleSystem:getStats()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Particle-system telemetry fields. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({ emissionRate = 40, maxParticles = 32, lifetimeMin = 2.0, lifetimeMax = 2.0 })
    ps:addAttractor(32, 32, 80, 64)
    ps:setBounds(64, -64, 48, -48, 0.5)
    ps:emit(6)
    ps:update(0.1)
    local stats = ps:getStats()

    example_print_log("live_particles = " .. tostring(stats.live_particles))
    example_print_log("state = " .. tostring(stats.state))
end
```

---

#### `LParticleSystem:getTangentialAcceleration`

Returns tangential acceleration range.

```lua
LParticleSystem:getTangentialAcceleration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum acceleration. |
| number | Maximum acceleration. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setPosition(128, 96)
    ps:setTangentialAcceleration(-20, 20)
    local min_tangent, max_tangent = ps:getTangentialAcceleration()
    local y = select(2, ps:getPosition())
    particle_log("tangential accel " .. min_tangent .. ".." .. max_tangent .. " near y=" .. y)
end
```

---

#### `LParticleSystem:hasCollidesWithPhysics`

Returns whether particle physics collision is enabled.

```lua
LParticleSystem:hasCollidesWithPhysics()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when collision is enabled. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    example_print_log("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end
```

---

#### `LParticleSystem:hasRelativeRotation`

Returns whether relative rotation is enabled.

```lua
LParticleSystem:hasRelativeRotation()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when relative rotation is enabled. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 4)
    ps:setRelativeRotation(true)
    local relative = ps:hasRelativeRotation()
    local dir = ps:getDirection()
    particle_log("relative rotation " .. tostring(relative) .. " at dir " .. dir)
end
```

---

#### `LParticleSystem:isActive`

Returns whether the particle system is active.

```lua
LParticleSystem:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when active. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(80)
    ps:start()
    ps:update(0.05)
    local active = ps:isActive()
    local count = ps:count()
    particle_log("bonfire active = " .. tostring(active) .. " with " .. count .. " live particles")
end
```

---

#### `LParticleSystem:isEmpty`

Returns whether the particle system has no particles or is missing.

```lua
LParticleSystem:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when empty. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:setEmissionRate(0)
    ps:emit(0)
    local empty = ps:isEmpty()
    local count = ps:count()
    particle_log("fresh system empty=" .. tostring(empty) .. " count=" .. count)
end
```

---

#### `LParticleSystem:isFull`

Returns whether the particle system has reached capacity.

```lua
LParticleSystem:isFull()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when full. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(10)

    example_print_log("full = " .. tostring(ps:isFull()))
end
```

---

#### `LParticleSystem:isPaused`

Returns whether the particle system is paused.

```lua
LParticleSystem:isPaused()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when paused. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()

    example_print_log("paused = " .. tostring(ps:isPaused()))
end
```

---

#### `LParticleSystem:isStopped`

Returns whether the particle system is stopped or missing.

```lua
LParticleSystem:isStopped()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when stopped. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(80)
    ps:start()
    ps:stop()

    example_print_log("stopped = " .. tostring(ps:isStopped()))
end
```

---

#### `LParticleSystem:moveTo`

Moves the particle emitter. This method is available to Lua scripts.

```lua
LParticleSystem:moveTo(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Emitter x coordinate. |
| `y` | number | Emitter y coordinate. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setPosition(40, 60)
    ps:moveTo(300, 400)

    local x, y = ps:getPosition()
    example_print_log("moved = " .. x .. "," .. y)
end
```

---

#### `LParticleSystem:paintOnto`

Paints live particles directly onto an existing image in place.

```lua
LParticleSystem:paintOnto(image)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | [LImageData](#limagedata) | Target image data handle. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("fire")
    ps:setPosition(32, 32)
    ps:emit(12)
    ps:update(0.1)
    local image = lurek.image.newImageData(64, 64)

    ps:paintOnto(image)
    example_print_log("paint target type = " .. image:type())
    example_print_log("paint target height = " .. image:getHeight())
end
```

---

#### `LParticleSystem:pause`

Pauses particle emission and updates.

```lua
LParticleSystem:pause()
```

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()

    example_print_log("paused = " .. tostring(ps:isPaused()))
end
```

---

#### `LParticleSystem:release`

Releases the particle system from shared storage.

```lua
LParticleSystem:release()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True after release. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(12)
    ps:emit(5)
    local ok = ps:release()
    local type_name = ps:type()
    particle_log("release returned " .. tostring(ok) .. " for " .. type_name)
end
```

---

#### `LParticleSystem:render`

Enqueues particle render commands with an optional offset.

```lua
LParticleSystem:render(ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox?` | number | X offset. |
| `oy?` | number | Y offset. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        emissionRate = 200,
        maxParticles = 1024,
    })
    ps:setPosition(320, 240)
    ps:setSpeed(100, 300)
    ps:setDirection(-math.pi / 2)
    ps:setSpread(math.pi / 8)
    ps:setGravity(0, 400)
    ps:start()

    for _ = 1, 10 do
        ps:update(0.016)
    end

    ps:render()
    ps:render(10, 5)
    example_print_log("count before render = " .. ps:count())
end
```

---

#### `LParticleSystem:reset`

Resets particles and emitter state.

```lua
LParticleSystem:reset()
```

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)
    ps:start()
    ps:update(1.0)

    example_print_log("before reset = " .. ps:count())
    ps:reset()
    example_print_log("after reset = " .. ps:count())
end
```

---

#### `LParticleSystem:resume`

Resumes a paused particle system if it was previously paused.

```lua
LParticleSystem:resume()
```

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()
    ps:resume()

    example_print_log("paused = " .. tostring(ps:isPaused()))
    example_print_log("active = " .. tostring(ps:isActive()))
end
```

---

#### `LParticleSystem:setBounds`

Sets collision bounds for particles.

```lua
LParticleSystem:setBounds(xmin, xmax, ymin, ymax, restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `xmin` | number | Minimum x bound. |
| `xmax` | number | Maximum x bound. |
| `ymin` | number | Minimum y bound. |
| `ymax` | number | Maximum y bound. |
| `restitution` | number | Bounce restitution factor. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setBounds(0, 800, 0, 600, 0.5)

    example_print_log("bounds set")
    ps:clearBounds()
    example_print_log("bounds cleared")
end
```

---

#### `LParticleSystem:setBufferSize`

Sets maximum particle buffer size.

```lua
LParticleSystem:setBufferSize(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Maximum particle count. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(60)
    ps:setBufferSize(1024)
    local buffer = ps:getBufferSize()
    particle_log("boss explosion pool resized to " .. buffer)
end
```

---

#### `LParticleSystem:setCollidesWithPhysics`

Enables particle collision against a physics world.

```lua
LParticleSystem:setCollidesWithPhysics(world_ud, probe_radius, restitution)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world_ud` | [LWorld](physics.md#lworld) | Physics world handle. |
| `probe_radius?` | number | Collision probe radius. |
| `restitution?` | number | Bounce restitution. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    example_print_log("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
end
```

---

#### `LParticleSystem:setColors`

Sets particle color keyframes from one or more RGBA tables.

```lua
LParticleSystem:setColors(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... table One or more `{r, g, b, a}` color tables. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setColors({1, 0.5, 0, 1}, {1, 0, 0, 0})

    local colors = ps:getColors()
    example_print_log("color keyframes = " .. #colors)
    example_print_log("first alpha = " .. colors[1][4])
end
```

---

#### `LParticleSystem:setCustomEmissionShape`

Sets a Lua callback for custom emission positions.

```lua
LParticleSystem:setCustomEmissionShape(cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cb` | function | Callback returning an x/y position. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    local step = 0

    ps:setCustomEmissionShape(function()
        step = step + 1
        local angle = step * (math.pi / 4)
        local radius = 50
        return 400 + math.cos(angle) * radius, 300 + math.sin(angle) * radius
    end)

    ps:emit(10)
    ps:update(0.016)
    example_print_log("custom shape emitted = " .. ps:count())
end
```

---

#### `LParticleSystem:setDirection`

Sets emission direction. This method is available to Lua scripts.

```lua
LParticleSystem:setDirection(dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dir` | number | Direction angle. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi / 10)
    ps:setDirection(math.pi / 2)
    local dir = ps:getDirection()
    local spread = ps:getSpread()
    particle_log("steam vent faces " .. dir .. " with spread " .. spread)
end
```

---

#### `LParticleSystem:setEmissionArea`

Sets emission area distribution and size.

```lua
LParticleSystem:setEmissionArea(dist, w, h, angle, dir_rel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dist` | string | Distribution name. |
| `w` | number | Area width. |
| `h` | number | Area height. |
| `angle?` | number | Area angle. |
| `dir_rel?` | boolean | Direction-relative flag. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionArea("uniform", 100, 50)

    local dist, width, height = ps:getEmissionArea()
    example_print_log("area = " .. dist .. " " .. width .. "x" .. height)

    ps:setEmissionArea("normal", 80, 80, math.pi / 4, true)
    local next_dist, next_width, next_height = ps:getEmissionArea()
    example_print_log("area = " .. next_dist .. " " .. next_width .. "x" .. next_height)
end
```

---

#### `LParticleSystem:setEmissionRate`

Sets emission rate. This method is available to Lua scripts.

```lua
LParticleSystem:setEmissionRate(rate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rate` | number | Particles per second. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setBufferSize(256)
    ps:setEmissionRate(100)
    local rate = ps:getEmissionRate()
    local buffer = ps:getBufferSize()
    particle_log("rain emitter rate " .. rate .. " within pool " .. buffer)
end
```

---

#### `LParticleSystem:setEmitterLifetime`

Sets emitter lifetime. This method is available to Lua scripts.

```lua
LParticleSystem:setEmitterLifetime(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Emitter lifetime. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(18)
    ps:setEmitterLifetime(5.0)
    local emitter_life = ps:getEmitterLifetime()
    local rate = ps:getEmissionRate()
    particle_log("one-shot vent runs for " .. emitter_life .. "s at rate " .. rate)
end
```

---

#### `LParticleSystem:setFlipbook`

Sets flipbook grid and frame rate. This method is available to Lua scripts.

```lua
LParticleSystem:setFlipbook(cols, rows, fps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cols` | number | Grid column count. |
| `rows` | number | Grid row count. |
| `fps` | number | Playback frame rate. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setShape("square")
    ps:setFlipbook(4, 4, 12)
    local cols, rows, fps = ps:getFlipbook()
    local shape = ps:getShape()
    particle_log("flipbook " .. cols .. "x" .. rows .. " @" .. fps .. "fps on " .. shape)
end
```

---

#### `LParticleSystem:setGravity`

Sets particle gravity. This method is available to Lua scripts.

```lua
LParticleSystem:setGravity(gx, gy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | number | Gravity x. |
| `gy` | number | Gravity y. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpeed(60, 90)
    ps:setGravity(0, 200)
    local gx, gy = ps:getGravity()
    local max_speed = select(2, ps:getSpeed())
    particle_log("snowfall gravity " .. gx .. "," .. gy .. " against speed " .. max_speed)
end
```

---

#### `LParticleSystem:setInsertMode`

Sets particle insert mode. This method is available to Lua scripts.

```lua
LParticleSystem:setInsertMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | Insert mode: `top`, `bottom`, or `random`. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setInsertMode("top")

    example_print_log("mode = " .. ps:getInsertMode())
    ps:setInsertMode("random")
    example_print_log("mode = " .. ps:getInsertMode())
end
```

---

#### `LParticleSystem:setLinearAcceleration`

Sets linear acceleration range. This method is available to Lua scripts.

```lua
LParticleSystem:setLinearAcceleration(xmin, ymin, xmax, ymax)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `xmin` | number | Minimum x acceleration. |
| `ymin` | number | Minimum y acceleration. |
| `xmax` | number | Maximum x acceleration. |
| `ymax` | number | Maximum y acceleration. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpeed(30, 60)
    ps:setLinearAcceleration(-10, 50, 10, 100)
    local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
    local speed = select(2, ps:getSpeed())
    particle_log("wind accel " .. xmin .. "," .. ymin .. ".." .. xmax .. "," .. ymax .. " speed " .. speed)
end
```

---

#### `LParticleSystem:setLinearDamping`

Sets linear damping range. This method is available to Lua scripts.

```lua
LParticleSystem:setLinearDamping(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum damping. |
| `max` | number | Maximum damping. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpeed(120, 180)
    ps:setLinearDamping(0.1, 0.5)
    local min_damping, max_damping = ps:getLinearDamping()
    local speed = select(2, ps:getSpeed())
    particle_log("air drag " .. min_damping .. ".." .. max_damping .. " with max speed " .. speed)
end
```

---

#### `LParticleSystem:setOffset`

Sets particle spawn offset. This method is available to Lua scripts.

```lua
LParticleSystem:setOffset(ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox` | number | Spawn offset x. |
| `oy` | number | Spawn offset y. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setPosition(200, 120)
    ps:setOffset(16, 16)
    local ox, oy = ps:getOffset()
    local x, y = ps:getPosition()
    particle_log("spawn offset " .. ox .. "," .. oy .. " from " .. x .. "," .. y)
end
```

---

#### `LParticleSystem:setOnDeathBatch`

Sets a Lua callback invoked with batched particle death records.

```lua
LParticleSystem:setOnDeathBatch(cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cb` | function | Death batch callback. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 64,
        emissionRate = 0,
        lifetimeMin = 0.1,
        lifetimeMax = 0.2,
    })
    local death_count = 0

    ps:setOnDeathBatch(function(batch)
        death_count = death_count + #batch
    end)

    ps:emit(8)
    ps:update(0.5)
    example_print_log("deaths = " .. death_count)
end
```

---

#### `LParticleSystem:setParticleLifetime`

Sets particle lifetime range. This method is available to Lua scripts.

```lua
LParticleSystem:setParticleLifetime(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum lifetime. |
| `max` | number | Maximum lifetime. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(32)
    ps:setParticleLifetime(0.5, 3.0)
    local min_life, max_life = ps:getParticleLifetime()
    local rate = ps:getEmissionRate()
    particle_log("smoke lifetime " .. min_life .. ".." .. max_life .. " at rate " .. rate)
end
```

---

#### `LParticleSystem:setPosition`

Sets emitter position. This method is available to Lua scripts.

```lua
LParticleSystem:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Emitter x coordinate. |
| `y` | number | Emitter y coordinate. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(20)
    ps:setPosition(100, 200)
    local x, y = ps:getPosition()
    local rate = ps:getEmissionRate()
    particle_log("torch ember emitter moved to " .. x .. "," .. y .. " at rate " .. rate)
end
```

---

#### `LParticleSystem:setRadialAcceleration`

Sets radial acceleration range. This method is available to Lua scripts.

```lua
LParticleSystem:setRadialAcceleration(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum radial acceleration. |
| `max` | number | Maximum radial acceleration. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setPosition(320, 240)
    ps:setRadialAcceleration(-50, 50)
    local min_radial, max_radial = ps:getRadialAcceleration()
    local x = select(1, ps:getPosition())
    particle_log("shockwave radial accel " .. min_radial .. ".." .. max_radial .. " from x=" .. x)
end
```

---

#### `LParticleSystem:setRelativeRotation`

Sets whether particle rotation is relative to movement.

```lua
LParticleSystem:setRelativeRotation(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | boolean | Relative rotation flag. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setShape("spark")
    ps:setRelativeRotation(true)
    local relative = ps:hasRelativeRotation()
    local shape = ps:getShape()
    particle_log("relative rotation " .. tostring(relative) .. " for " .. shape)
end
```

---

#### `LParticleSystem:setRotation`

Sets particle rotation range. This method is available to Lua scripts.

```lua
LParticleSystem:setRotation(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum rotation. |
| `max` | number | Maximum rotation. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setShape("spark")
    ps:setRotation(0, math.pi * 2)
    local min_rotation, max_rotation = ps:getRotation()
    local shape = ps:getShape()
    particle_log("shrapnel rotation " .. min_rotation .. ".." .. max_rotation .. " shape " .. shape)
end
```

---

#### `LParticleSystem:setShape`

Sets particle shape. This method is available to Lua scripts.

```lua
LParticleSystem:setShape(shape)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | string | Shape name. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSizes(6, 2)
    ps:setShape("circle")
    local shape = ps:getShape()
    local size_count = #ps:getSizes()
    particle_log("shape " .. shape .. " with " .. size_count .. " size keys")
end
```

---

#### `LParticleSystem:setSizeVariation`

Sets size variation. This method is available to Lua scripts.

```lua
LParticleSystem:setSizeVariation(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Size variation. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)
    ps:setSizeVariation(0.3)
    local variation = ps:getSizeVariation()
    local sizes = ps:getSizes()
    particle_log("spark size variation " .. variation .. " across " .. #sizes .. " keyframes")
end
```

---

#### `LParticleSystem:setSizes`

Sets the particle size keyframes used during a particle's lifetime. Pass two or more values to interpolate between them.

```lua
LParticleSystem:setSizes(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... number Two or more size values that the particle lerps through over its lifetime (e.g. `4, 1` shrinks from 4 to 1). |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)

    local sizes = ps:getSizes()
    example_print_log("size count = " .. #sizes)
    example_print_log("first size = " .. sizes[1])
end
```

---

#### `LParticleSystem:setSpeed`

Sets particle speed range. This method is available to Lua scripts.

```lua
LParticleSystem:setSpeed(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum speed. |
| `max` | number | Maximum speed. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(-math.pi / 2)
    ps:setSpeed(50, 200)
    local min_speed, max_speed = ps:getSpeed()
    local dir = ps:getDirection()
    particle_log("debris speed " .. min_speed .. ".." .. max_speed .. " toward " .. dir)
end
```

---

#### `LParticleSystem:setSpin`

Sets particle spin range. This method is available to Lua scripts.

```lua
LParticleSystem:setSpin(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum spin. |
| `max` | number | Maximum spin. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setRotation(0, math.pi)
    ps:setSpin(-3, 3)
    local min_spin, max_spin = ps:getSpin()
    local max_rotation = select(2, ps:getRotation())
    particle_log("spin " .. min_spin .. ".." .. max_spin .. " across rotation " .. max_rotation)
end
```

---

#### `LParticleSystem:setSpinVariation`

Sets spin variation. This method is available to Lua scripts.

```lua
LParticleSystem:setSpinVariation(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Spin variation factor. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setSpin(-2, 2)
    ps:setSpinVariation(0.5)
    local variation = ps:getSpinVariation()
    local max_spin = select(2, ps:getSpin())
    particle_log("spin variation " .. variation .. " with max spin " .. max_spin)
end
```

---

#### `LParticleSystem:setSpread`

Sets emission spread. This method is available to Lua scripts.

```lua
LParticleSystem:setSpread(spread)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `spread` | number | Spread angle. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(0.0)
    ps:setSpread(math.pi / 6)
    local spread = ps:getSpread()
    local dir = ps:getDirection()
    particle_log("shotgun spark cone " .. spread .. " around " .. dir)
end
```

---

#### `LParticleSystem:setTangentialAcceleration`

Sets tangential acceleration range for emitted particles.

```lua
LParticleSystem:setTangentialAcceleration(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum tangential acceleration. |
| `max` | number | Maximum tangential acceleration. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setDirection(0.0)
    ps:setTangentialAcceleration(-20, 20)
    local min_tangent, max_tangent = ps:getTangentialAcceleration()
    local dir = ps:getDirection()
    particle_log("swirl tangential accel " .. min_tangent .. ".." .. max_tangent .. " around " .. dir)
end
```

---

#### `LParticleSystem:start`

Starts particle emission on this object.

```lua
LParticleSystem:start()
```

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        emissionRate = 100,
        lifetimeMin = 1.0,
        lifetimeMax = 2.0,
    })
    ps:start()

    example_print_log("active = " .. tostring(ps:isActive()))
    example_print_log("stopped = " .. tostring(ps:isStopped()))
end
```

---

#### `LParticleSystem:stop`

Stops particle emission on this object.

```lua
LParticleSystem:stop()
```

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        emissionRate = 100,
        lifetimeMin = 1.0,
        lifetimeMax = 2.0,
    })
    ps:start()

    ps:stop()
    example_print_log("active = " .. tostring(ps:isActive()))
    example_print_log("stopped = " .. tostring(ps:isStopped()))
end
```

---

#### `LParticleSystem:subSystemCount`

Returns particle sub-system count.

```lua
LParticleSystem:subSystemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Sub-system count. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        maxParticles = 256,
    })
    ps:addSubSystem({
        emissionRate = 10,
        speedMin = 5,
        speedMax = 15,
        lifetimeMin = 0.3,
        lifetimeMax = 0.6,
    })

    example_print_log("sub-system count = " .. ps:subSystemCount())
end
```

---

#### `LParticleSystem:toImage`

Draws particles to image data. This method is available to Lua scripts.

```lua
LParticleSystem:toImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Image width. |
| `h` | number | Image height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Image data containing the rendered particles. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:toImage(128, 128)
    example_print_log("toImage type = " .. image:type())
end
```

---

#### `LParticleSystem:type`

Returns the Lua-visible type name for this particle system handle.

```lua
LParticleSystem:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LParticleSystem](#lparticlesystem)`. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(16)
    local type_name = ps:type()
    local is_particle = ps:typeOf("LParticleSystem")
    local is_drawable = ps:typeOf("LDrawable")
    particle_log(type_name .. " particle=" .. tostring(is_particle) .. " drawable=" .. tostring(is_drawable))
end
```

---

#### `LParticleSystem:typeOf`

Returns whether this particle system handle matches a supported type name.

```lua
LParticleSystem:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LParticleSystem](#lparticlesystem)`, `ParticleSystem`, `Drawable`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(8)
    local particle = ps:typeOf("LParticleSystem")
    local drawable = ps:typeOf("LDrawable")
    local object = ps:typeOf("LObject")
    particle_log("typeOf particle=" .. tostring(particle) .. " drawable=" .. tostring(drawable) .. " object=" .. tostring(object))
end
```

---

#### `LParticleSystem:update`

Updates the particle system, applies optional physics collision, and invokes pending callbacks.

```lua
LParticleSystem:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newSystem({
        emissionRate = 200,
        maxParticles = 1024,
    })
    ps:setPosition(320, 240)
    ps:setSpeed(100, 300)
    ps:setDirection(-math.pi / 2)
    ps:setSpread(math.pi / 8)
    ps:setGravity(0, 400)
    ps:start()

    for _ = 1, 10 do
        ps:update(0.016)
    end

    example_print_log("count after update = " .. ps:count())
end
```

---

#### `LParticleSystem:warmUp`

Advances the system by a warm-up duration.

```lua
LParticleSystem:warmUp(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | number | Warm-up duration in seconds. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ps = lurek.particle.newPreset("rain")
    ps:start()
    ps:warmUp(2.0)
    local count = ps:count()
    local active = ps:isActive()
    particle_log("rain warmed to " .. count .. " drops active=" .. tostring(active))
end
```

---

## LTrail

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTrail:clear`

Clears all trail points on this object.

```lua
LTrail:clear()
```

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)

    example_print_log("before clear = " .. trail:getPointCount())
    trail:clear()
    example_print_log("after clear = " .. trail:getPointCount())
end
```

---

#### `LTrail:drawToImage`

Draws the trail to image data. This method is available to Lua scripts.

```lua
LTrail:drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Width of output image. |
| `h` | number | Height of output image. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Image data containing the rendered trail. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:pushPoint(50, 25)

    local image = trail:drawToImage(64, 64)
    example_print_log("trail image type = " .. image:type())
end
```

---

#### `LTrail:getLifetime`

Returns trail point lifetime. This method is available to Lua scripts.

```lua
LTrail:getLifetime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Lifetime in seconds. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(4, 2)
    trail:setLifetime(5.0)
    local lifetime = trail:getLifetime()
    local type_name = trail:type()
    particle_log(type_name .. " lifetime readback " .. lifetime)
end
```

---

#### `LTrail:getPointCount`

Returns trail point count. This method is available to Lua scripts.

```lua
LTrail:getPointCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Point count. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:pushPoint(30, 8)

    example_print_log("points = " .. trail:getPointCount())
end
```

---

#### `LTrail:getWidth`

Returns trail width settings from this object.

```lua
LTrail:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Start width. |
| number | End width. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:setWidth(10, 2)
    local start_width, end_width = trail:getWidth()
    local lifetime = trail:getLifetime()
    particle_log("trail width " .. start_width .. " -> " .. end_width .. " lifetime " .. lifetime)
end
```

---

#### `LTrail:pushPoint`

Adds a point to the trail. This method is available to Lua scripts.

```lua
LTrail:pushPoint(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Point x coordinate. |
| `y` | number | Point y coordinate. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:pushPoint(30, 8)

    example_print_log("points = " .. trail:getPointCount())
end
```

---

#### `LTrail:setHeadColor`

Sets the color of the leading edge of the trail.

```lua
LTrail:setHeadColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setHeadColor(1, 1, 0, 1)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)

    example_print_log("points = " .. trail:getPointCount())
end
```

---

#### `LTrail:setLifetime`

Sets trail point lifetime. This method is available to Lua scripts.

```lua
LTrail:setLifetime(lifetime)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lifetime` | number | Point lifetime in seconds. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:setLifetime(5.0)
    local lifetime = trail:getLifetime()
    local points = trail:getPointCount()
    particle_log("trail lifetime set to " .. lifetime .. " with " .. points .. " point(s)")
end
```

---

#### `LTrail:setMinDistance`

Sets minimum distance between trail points.

```lua
LTrail:setMinDistance(distance)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `distance` | number | Minimum distance between points. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setMinDistance(3)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)
    trail:pushPoint(10, 0)

    example_print_log("points = " .. trail:getPointCount())
end
```

---

#### `LTrail:setTailColor`

Sets the color of the trailing edge of the trail.

```lua
LTrail:setTailColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setTailColor(1, 0, 0, 0)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)

    example_print_log("points = " .. trail:getPointCount())
end
```

---

#### `LTrail:setWidth`

Sets trail start and optional end width.

```lua
LTrail:setWidth(start, end_)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | number | Start width. |
| `end_?` | number | End width. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:setWidth(10, 2)
    local start_width, end_width = trail:getWidth()
    local points = trail:getPointCount()
    particle_log("trail width " .. start_width .. " -> " .. end_width .. " across " .. points .. " point(s)")
end
```

---

#### `LTrail:type`

Returns the Lua-visible type name for this trail handle.

```lua
LTrail:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTrail](#ltrail)`. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.5, 8.0)
    trail:pushPoint(0, 0)
    trail:setWidth(8.0, 2.0)
    local type_name = trail:type()
    local points = trail:getPointCount()
    particle_log("trail handle " .. type_name .. " stores " .. points .. " point(s)")
end
```

---

#### `LTrail:typeOf`

Returns whether this trail handle matches a supported type name.

```lua
LTrail:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LTrail](#ltrail)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    local is_trail = trail:typeOf("LTrail")
    local is_object = trail:typeOf("LObject")
    local points = trail:getPointCount()
    particle_log("trail typeOf trail=" .. tostring(is_trail) .. " object=" .. tostring(is_object) .. " points=" .. points)
end
```

---

#### `LTrail:update`

Updates trail point lifetimes. This method is available to Lua scripts.

```lua
LTrail:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do
    local function particle_log(message)
        lurek.log.info("[particle.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:update(0.5)

    example_print_log("after update = " .. trail:getPointCount())
end
```

---
