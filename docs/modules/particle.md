# Particle

## Summary

Designed for high-performance visual effects, it utilizes bounded, fixed-capacity memory pools and CPU-based Euler integration. At the core of the module is the `ParticleSystem`, an emitter that spawns `Particle` instances according to highly configurable emission shapes, such as point, circle, ring, rectangle, cone, line, and custom callbacks. Once spawned, each particle evolves independently based on a robust physics model that includes linear velocity, gravity, radial/tangential acceleration, linear damping, drag, orbit mechanics, and turbulence, before eventually expiring after a predefined lifetime.

The visual representation of particles is extremely flexible. The system supports both procedural geometric shapes (like squares, circles, sparks, and shrapnel) and fully textured sprites. Throughout their lifetime, particles dynamically interpolate key properties—such as color, size, rotation, and opacity—using customizable multi-stop keyframe curves. To create complex, layered effects, `ParticleSystem`s support sub-emitters, allowing particles to spawn entirely new child particle bursts upon specific events, such as birth, death, or collision. The module also features a robust physics collision integration, allowing particles to bounce realistically off defined bounding boxes or dynamic Rapier2D world geometry with configurable restitution.

Beyond standalone particles, the module implements a sophisticated `Trail` system. This generates connected ribbon segments behind moving particles or standalone points, featuring width tapering, age-based point retirement, and head-to-tail color interpolation. Additional advanced features include point attractors (gravity wells) that dynamically pull or repel live particles, and texture animation that can cycle through sprite atlas frames over a particle's lifetime. For ease of use, the module provides a suite of ready-made `presets` for common effects like fire, smoke, rain, snow, and sparks. The entire module is heavily optimized for deterministic simulation (given the same initial seed) and provides extensive debug visualization tools. It is fully exposed to the Lua scripting environment via the `lurek.particle.*` API, making it an essential tool for bringing dynamic, visually rich effects to Lurek2D games.

## Spec File Descriptions

_Poniższe opisy plików pochodzą bezpośrednio ze specyfikacji modułu (`docs/specs/<module>.md`)._

### config.rs

- Runtime configuration for particle emitters and their tunable behavior.
- Carries spawn distribution, insertion order, state, and coordinate mode settings.
- Describes emission shapes from point and circle to cone, star, spiral, and custom callbacks.
- Includes attractor and bounce helper types for motion control.
- Covers world-space versus emitter-attached spawning rules.
- Packs every serializable knob into one config object for scripts and data files.
- Serves as the authored contract for building particle systems.

### emission.rs

- Spawn-offset sampling for particle emission shapes and area distributions.
- Supports uniform, normal, ellipse, border, rectangle, ring, cone, star, and spiral modes.
- Handles area-angle rotation so emitted particles respect the configured shape.
- Keeps emission math separate from the particle runtime.
- Supplies the offset generator used by emitters and presets.

### emitter.rs

- Live particle emitter that owns the active particle pool, physics stepping, and sub-system list.
- Integrates gravity, drag, orbit, turbulence, and other per-frame forces.
- Spawns particles continuously or in bursts using fractional accumulation and ordered insertion modes.
- Applies attractors and axis-aligned bounce boundaries to active particles.
- Runs child emitters on particle death when sub-systems are configured.
- Tracks active, paused, and stopped states with lifetime-based auto-stop.
- Builds render commands from current particle state, shape mapping, and interpolation curves.
- Supports warm-up simulation so systems can start in a settled state.
- Exposes custom emission-shape callbacks through the Lua bridge without coupling spawn math to rendering.
- Provides the runtime core for all particle effects.

### math.rs

- Keyframe interpolation for particle size, colour, and alpha over normalized lifetime.
- Offers uniform and normal random helpers for emission variance.
- Clamps interpolation inputs and falls back cleanly on empty keyframe sets.
- Supports the numeric shaping layer used by emitter animation.

### mod.rs

- Particle emitter lifecycle for spawn, simulation, and pooled recycling.
- Collects emission, physics, trail, rendering, and preset helpers under one namespace.
- Keeps particle effects modular while exposing a single runtime surface.

### particle.rs

- Per-particle runtime state for position, velocity, lifetime, rotation, and acceleration.
- Stores spawn origin and shape seed for force calculations and deterministic geometry.
- Keeps the minimum state needed by the emitter loop.

### physics_collision.rs

- Bounce particles off rapier colliders using AABB overlap probes.
- Reflects velocity with configurable restitution per collision pass.
- Operates on all live particles in a system each frame.

### presets.rs

- Ready-made ParticleConfig constructors for common visual effects.
- Covers fire, smoke, rain, snow, sparks, and other standard patterns.
- Returns self-contained configs with tuned lifetime, speed, color ramp, and shape.
- Lets callers start from a stable preset and override fields afterward.
- Makes quick particle authoring simple without hiding the underlying config.

### render.rs

- Render-command generation for particle systems and trails.
- Expands textured particle batches into individual draw calls when needed.
- Keeps untextured particles batched for efficiency.
- Bridges live particle state to renderer submission.

### shapes.rs

- Geometric shape primitives that control how individual particles are rendered.
- Covers fills, directional shapes, and composite outlines with inline parameters.
- Gives emitters a compact vocabulary for particle silhouette design.

### trail.rs

- Ribbon trail built from a deque of aged world-space points.
- Retires points automatically when they exceed the configured lifetime.
- Tapers width and interpolates color from head to tail.
- Can render as triangle-strip commands or as a CPU-rasterized image.
- Provides a lightweight motion trail for fast effects and debug views.

### visualization.rs

- Particle visualization helpers that render live ParticleSystem state to ImageData bitmaps.
- Includes a generic renderer plus themed presets for explosions, rain, and spark trails.
- Supports compositing particles over an existing background or painting in place.
- Adds a chart-style lifetime view for inspecting particle counts over time.
- Keeps render inspection separate from the particle simulation core.
- Helps debug effect tuning without touching the live emitter loop.

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
| [LImageData](#limagedata-handle) | Image data containing the lifecycle chart. |

**Example**

```lua
do
    local snapshots = {
        { step = 0, count = 0 },
        { step = 5, count = 12 },
        { step = 10, count = 4 },
    }
    local image = lurek.particle.drawLifecycleToImage(snapshots, 16, 128, 64)
    print("lifecycle type = " .. image:type())
    print("lifecycle width = " .. image:getWidth())
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
| `path` | string | TOML file path. |

**Returns**

| Type | Description |
|------|-------------|
| [LParticleSystem](#lparticlesystem-handle) | New particle system handle. |

**Example**

```lua
do
    local path = "logs/particle_example.toml"
    lurek.filesystem.write(path, "max_particles = 96\nemission_rate = 18.0\nlifetime_min = 0.2\nlifetime_max = 0.8\n")

    local ps = lurek.particle.fromTOML(path)
    print("type = " .. ps:type())
    print("buffer = " .. ps:getBufferSize())
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
| [LParticleSystem](#lparticlesystem-handle) | New particle system handle. |

**Example**

```lua
do
    local fire = lurek.particle.newPreset("fire")
    fire:setPosition(160, 220)

    print("type = " .. fire:type())
    print("fire rate = " .. fire:getEmissionRate())
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
| `config?` | table | Particle config table. |

**Returns**

| Type | Description |
|------|-------------|
| [LParticleSystem](#lparticlesystem-handle) | New particle system handle. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 128,
        emissionRate = 24,
        lifetimeMin = 0.25,
        lifetimeMax = 0.75,
    })

    print("type = " .. ps:type())
    print("buffer = " .. ps:getBufferSize())
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
| [LTrail](#ltrail-handle) | New trail handle. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(2.0, 8)

    print("type = " .. trail:type())
    print("lifetime = " .. trail:getLifetime())
end
```

---

## Module Fields

*No module-level fields documented.*

## Types

- [LImageData Handle](#limagedata-handle)
- [LParticleSystem Handle](#lparticlesystem-handle)
- [LTrail Handle](#ltrail-handle)

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## LImageData Handle

### Fields

*No documented fields for this handle.*

### Methods

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

#### `LImageData:applyPaletteLut`

Applies a palette lookup table to this image in place.

```lua
LImageData:applyPaletteLut(lut_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lut_ud` | LPaletteLUT | Palette lookup table handle. |

---

#### `LImageData:blit`

Copies a source image into this image at a destination coordinate.

```lua
LImageData:blit(src_ud, dst_x, dst_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata-handle) | Source image data handle. |
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
| [LImageData](#limagedata-handle) | Blurred image data handle. |

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
| [LImageData](#limagedata-handle) | Convolved image data handle. |

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
| [LImageData](#limagedata-handle) | Cropped image data handle. |

---

#### `LImageData:diff`

Computes a difference metric against another image.

```lua
LImageData:diff(other_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other_ud` | [LImageData](#limagedata-handle) | Image data handle to compare with this image. |

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

#### `LImageData:drawNineSlice`

Draws a nine-slice region from a source image into this image.

```lua
LImageData:drawNineSlice(src_ud, src_x, src_y, src_w, src_h, dst_x, dst_y, dst_w, dst_h, inset_left, inset_right, inset_top, inset_bottom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata-handle) | Source image data handle. |
| `src_x` | number | Source region x coordinate. |
| `src_y` | number | Source region y coordinate. |
| `src_w` | number | Source region width. |
| `src_h` | number | Source region height. |
| `dst_x` | number | Destination x coordinate. |
| `dst_y` | number | Destination y coordinate. |
| `dst_w` | number | Destination width. |
| `dst_h` | number | Destination height. |
| `inset_left` | number | Left inset width. |
| `inset_right` | number | Right inset width. |
| `inset_top` | number | Top inset height. |
| `inset_bottom` | number | Bottom inset height. |

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
| [LImageData](#limagedata-handle) | nil | `[LImageData](#limagedata-handle)` handle, or nil when the region is out of bounds. |

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
| `src_ud` | [LImageData](#limagedata-handle) | Source image data handle. |
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
| [LImageData](#limagedata-handle) | nil | Resized `[LImageData](#limagedata-handle)` handle, or nil when resizing fails. |

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
| [LImageData](#limagedata-handle) | Resized image data handle. |

---

#### `LImageData:rotate90cw`

Returns a new image rotated ninety degrees clockwise.

```lua
LImageData:rotate90cw()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | Rotated image data handle. |

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
| [LImageData](#limagedata-handle) | Sharpened image data handle. |

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

#### `LImageData:type`

Returns the Lua-visible type name for this image data handle.

```lua
LImageData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LImageData](#limagedata-handle)`. |

---

#### `LImageData:typeOf`

Returns whether this image data handle matches the `[LImageData](#limagedata-handle)` type name.

```lua
LImageData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LImageData](#limagedata-handle)` or `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches. |

---

## LParticleSystem Handle

### Fields

*No documented fields for this handle.*

### Methods

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
    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:setPosition(400, 300)
    ps:setSpeed(50, 150)
    ps:setSpread(math.pi * 2)
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    print("attractors = " .. ps:getAttractorCount())
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
| `config_tbl` | table | Particle config table. |
| `burst_count?` | number | Burst count per death. |

**Example**

```lua
do
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

    print("sub-systems = " .. ps:subSystemCount())
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
| `config_tbl` | table | Particle config table. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based sub-system index. |

**Example**

```lua
do
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

    print("sub-system index = " .. idx)
    print("sub-system count = " .. ps:subSystemCount())
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
    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    print("before clear = " .. ps:getAttractorCount())
    ps:clearAttractors()
    print("after clear = " .. ps:getAttractorCount())
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
    local ps = lurek.particle.newSystem()
    ps:setBounds(0, 800, 0, 600, 0.5)

    print("bounds set")
    ps:clearBounds()
    print("bounds cleared")
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
    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    print("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
    ps:clearCollidesWithPhysics()
    print("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
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
| [LParticleSystem](#lparticlesystem-handle) | New particle system handle. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 256,
        emissionRate = 75,
    })
    ps:setSpeed(80, 160)
    ps:setGravity(0, 100)

    local copy = ps:clone()
    print("clone buffer = " .. copy:getBufferSize())
    print("clone rate = " .. copy:getEmissionRate())
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
    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(6)

    print("count = " .. ps:count())
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
| [LImageData](#limagedata-handle) | Image data containing the explosion preview. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("fire")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawExplosionToImage(128, 128)
    print("explosion type = " .. image:type())
    print("explosion width = " .. image:getWidth())
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
| `image` | [LImageData](#limagedata-handle) | Background image data handle. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | Image data containing the composited result. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)
    local image = lurek.image.newImageData(128, 128)
    image:fill(16, 16, 16, 255)

    local over = ps:drawOverImage(image)
    print("overlay type = " .. over:type())
    print("overlay width = " .. over:getWidth())
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
| [LImageData](#limagedata-handle) | Image data containing the rain preview. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("rain")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawRainToImage(128, 128)
    print("rain type = " .. image:type())
    print("rain height = " .. image:getHeight())
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
| [LImageData](#limagedata-handle) | Image data containing the spark preview. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawSparkTrailToImage(128, 128)
    print("spark type = " .. image:type())
    print("spark width = " .. image:getWidth())
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
| [LImageData](#limagedata-handle) | Image data containing the rendered particles. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:drawToImage(128, 128)
    print("drawToImage type = " .. image:type())
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
    local ps = lurek.particle.newSystem({
        maxParticles = 512,
    })
    ps:setPosition(400, 300)
    ps:setSpeed(50, 150)
    ps:setSpread(math.pi * 2)
    ps:emit(100)

    print("after emit = " .. ps:count())
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
    local ps = lurek.particle.newSystem({
        maxParticles = 512,
        emissionRate = 100,
    })
    ps:addAttractor(400, 300, 200, 100)
    ps:addAttractor(200, 200, -50, 60)

    print("attractors = " .. ps:getAttractorCount())
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
    local ps = lurek.particle.newSystem()
    ps:setBufferSize(1024)

    print("buffer = " .. ps:getBufferSize())
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
    local ps = lurek.particle.newSystem()
    ps:setColors({1, 0.5, 0, 1}, {1, 0, 0, 0})

    local colors = ps:getColors()
    print("color keyframes = " .. #colors)
    print("last alpha = " .. colors[#colors][4])
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
    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(6)

    print("getCount = " .. ps:getCount())
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
    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 2)

    print("dir = " .. ps:getDirection())
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
    local ps = lurek.particle.newSystem()
    ps:setEmissionArea("uniform", 100, 50)

    local dist, width, height = ps:getEmissionArea()
    print("area = " .. dist .. " " .. width .. "x" .. height)
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
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)

    print("rate = " .. ps:getEmissionRate())
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
    local ps = lurek.particle.newSystem()
    ps:setEmitterLifetime(5.0)

    print("emitter lifetime = " .. ps:getEmitterLifetime())
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
    local ps = lurek.particle.newSystem()
    ps:setFlipbook(4, 4, 12)

    local cols, rows, fps = ps:getFlipbook()
    print("flipbook = " .. cols .. "x" .. rows .. " @" .. fps .. "fps")
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
    local ps = lurek.particle.newSystem()
    ps:setGravity(0, 200)

    local gx, gy = ps:getGravity()
    print("gravity = " .. gx .. "," .. gy)
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
    local ps = lurek.particle.newSystem()
    ps:setInsertMode("bottom")

    print("mode = " .. ps:getInsertMode())
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
    local ps = lurek.particle.newSystem()
    ps:setLinearAcceleration(-10, 50, 10, 100)

    local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
    print("accel = " .. xmin .. "," .. ymin .. ".." .. xmax .. "," .. ymax)
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
    local ps = lurek.particle.newSystem()
    ps:setLinearDamping(0.1, 0.5)

    local min_damping, max_damping = ps:getLinearDamping()
    print("damping = " .. min_damping .. ".." .. max_damping)
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
    local ps = lurek.particle.newSystem()
    ps:setOffset(16, 16)

    local ox, oy = ps:getOffset()
    print("offset = " .. ox .. "," .. oy)
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
    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.5, 3.0)

    local min_life, max_life = ps:getParticleLifetime()
    print("lifetime = " .. min_life .. ".." .. max_life)
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
    local ps = lurek.particle.newSystem()
    ps:setPosition(100, 200)

    local x, y = ps:getPosition()
    print("pos = " .. x .. "," .. y)
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
    local ps = lurek.particle.newSystem()
    ps:setRadialAcceleration(-50, 50)

    local min_radial, max_radial = ps:getRadialAcceleration()
    print("radial = " .. min_radial .. ".." .. max_radial)
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
    local ps = lurek.particle.newSystem()
    ps:setRotation(0, math.pi * 2)

    local min_rotation, max_rotation = ps:getRotation()
    print("rotation = " .. min_rotation .. ".." .. max_rotation)
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
    local ps = lurek.particle.newSystem()
    ps:setShape("circle")

    print("shape = " .. ps:getShape())
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
    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)
    ps:setSizeVariation(0.3)

    print("size variation = " .. ps:getSizeVariation())
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
    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)

    local sizes = ps:getSizes()
    print("size count = " .. #sizes)
    print("last size = " .. sizes[#sizes])
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
    local ps = lurek.particle.newSystem()
    ps:setSpeed(50, 200)

    local min_speed, max_speed = ps:getSpeed()
    print("speed = " .. min_speed .. ".." .. max_speed)
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
    local ps = lurek.particle.newSystem()
    ps:setSpin(-3, 3)

    local min_spin, max_spin = ps:getSpin()
    print("spin = " .. min_spin .. ".." .. max_spin)
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
    local ps = lurek.particle.newSystem()
    ps:setSpinVariation(0.5)

    print("spin variation = " .. ps:getSpinVariation())
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
    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi / 6)

    print("spread = " .. ps:getSpread())
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
    local ps = lurek.particle.newSystem()
    ps:setTangentialAcceleration(-20, 20)

    local min_tangent, max_tangent = ps:getTangentialAcceleration()
    print("tangential = " .. min_tangent .. ".." .. max_tangent)
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
    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    print("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
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
    local ps = lurek.particle.newSystem()
    ps:setRelativeRotation(true)

    print("relative rotation = " .. tostring(ps:hasRelativeRotation()))
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
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(80)
    ps:start()

    print("active = " .. tostring(ps:isActive()))
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
    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })

    print("empty = " .. tostring(ps:isEmpty()))
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
    local ps = lurek.particle.newSystem({
        maxParticles = 10,
    })
    ps:emit(10)

    print("full = " .. tostring(ps:isFull()))
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
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()

    print("paused = " .. tostring(ps:isPaused()))
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
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(80)
    ps:start()
    ps:stop()

    print("stopped = " .. tostring(ps:isStopped()))
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
    local ps = lurek.particle.newSystem()
    ps:setPosition(40, 60)
    ps:moveTo(300, 400)

    local x, y = ps:getPosition()
    print("moved = " .. x .. "," .. y)
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
| `image` | [LImageData](#limagedata-handle) | Target image data handle. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("fire")
    ps:setPosition(32, 32)
    ps:emit(12)
    ps:update(0.1)
    local image = lurek.image.newImageData(64, 64)

    ps:paintOnto(image)
    print("paint target type = " .. image:type())
    print("paint target height = " .. image:getHeight())
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
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()

    print("paused = " .. tostring(ps:isPaused()))
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
    local ps = lurek.particle.newSystem()
    ps:emit(5)

    local ok = ps:release()
    print("released = " .. tostring(ok))
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
    print("count before render = " .. ps:count())
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
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)
    ps:start()
    ps:update(1.0)

    print("before reset = " .. ps:count())
    ps:reset()
    print("after reset = " .. ps:count())
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
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(50)
    ps:start()
    ps:pause()
    ps:resume()

    print("paused = " .. tostring(ps:isPaused()))
    print("active = " .. tostring(ps:isActive()))
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
    local ps = lurek.particle.newSystem()
    ps:setBounds(0, 800, 0, 600, 0.5)

    print("bounds set")
    ps:clearBounds()
    print("bounds cleared")
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
    local ps = lurek.particle.newSystem()
    ps:setBufferSize(1024)

    print("buffer = " .. ps:getBufferSize())
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
| `world_ud` | LWorld | Physics world handle. |
| `probe_radius?` | number | Collision probe radius. |
| `restitution?` | number | Bounce restitution. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem({
        maxParticles = 200,
    })
    local world = lurek.physics.newWorld(0, 0)

    ps:setCollidesWithPhysics(world, 4.0, 0.3)

    print("has collisions = " .. tostring(ps:hasCollidesWithPhysics()))
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
    local ps = lurek.particle.newSystem()
    ps:setColors({1, 0.5, 0, 1}, {1, 0, 0, 0})

    local colors = ps:getColors()
    print("color keyframes = " .. #colors)
    print("first alpha = " .. colors[1][4])
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
    print("custom shape emitted = " .. ps:count())
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
    local ps = lurek.particle.newSystem()
    ps:setDirection(math.pi / 2)

    print("dir = " .. ps:getDirection())
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
    local ps = lurek.particle.newSystem()
    ps:setEmissionArea("uniform", 100, 50)

    local dist, width, height = ps:getEmissionArea()
    print("area = " .. dist .. " " .. width .. "x" .. height)

    ps:setEmissionArea("normal", 80, 80, math.pi / 4, true)
    local next_dist, next_width, next_height = ps:getEmissionArea()
    print("area = " .. next_dist .. " " .. next_width .. "x" .. next_height)
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
    local ps = lurek.particle.newSystem()
    ps:setEmissionRate(100)

    print("rate = " .. ps:getEmissionRate())
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
    local ps = lurek.particle.newSystem()
    ps:setEmitterLifetime(5.0)

    print("emitter lifetime = " .. ps:getEmitterLifetime())
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
    local ps = lurek.particle.newSystem()
    ps:setFlipbook(4, 4, 12)

    local cols, rows, fps = ps:getFlipbook()
    print("flipbook = " .. cols .. "x" .. rows .. " @" .. fps .. "fps")
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
    local ps = lurek.particle.newSystem()
    ps:setGravity(0, 200)

    local gx, gy = ps:getGravity()
    print("gravity = " .. gx .. "," .. gy)
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
    local ps = lurek.particle.newSystem()
    ps:setInsertMode("top")

    print("mode = " .. ps:getInsertMode())
    ps:setInsertMode("random")
    print("mode = " .. ps:getInsertMode())
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
    local ps = lurek.particle.newSystem()
    ps:setLinearAcceleration(-10, 50, 10, 100)

    local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
    print("accel = " .. xmin .. "," .. ymin .. ".." .. xmax .. "," .. ymax)
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
    local ps = lurek.particle.newSystem()
    ps:setLinearDamping(0.1, 0.5)

    local min_damping, max_damping = ps:getLinearDamping()
    print("damping = " .. min_damping .. ".." .. max_damping)
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
    local ps = lurek.particle.newSystem()
    ps:setOffset(16, 16)

    local ox, oy = ps:getOffset()
    print("offset = " .. ox .. "," .. oy)
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
    print("deaths = " .. death_count)
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
    local ps = lurek.particle.newSystem()
    ps:setParticleLifetime(0.5, 3.0)

    local min_life, max_life = ps:getParticleLifetime()
    print("lifetime = " .. min_life .. ".." .. max_life)
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
    local ps = lurek.particle.newSystem()
    ps:setPosition(100, 200)

    local x, y = ps:getPosition()
    print("pos = " .. x .. "," .. y)
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
    local ps = lurek.particle.newSystem()
    ps:setRadialAcceleration(-50, 50)

    local min_radial, max_radial = ps:getRadialAcceleration()
    print("radial = " .. min_radial .. ".." .. max_radial)
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
    local ps = lurek.particle.newSystem()
    ps:setRelativeRotation(true)

    print("relative rotation = " .. tostring(ps:hasRelativeRotation()))
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
    local ps = lurek.particle.newSystem()
    ps:setRotation(0, math.pi * 2)

    local min_rotation, max_rotation = ps:getRotation()
    print("rotation = " .. min_rotation .. ".." .. max_rotation)
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
    local ps = lurek.particle.newSystem()
    ps:setShape("circle")

    print("shape = " .. ps:getShape())
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
    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)
    ps:setSizeVariation(0.3)

    print("size variation = " .. ps:getSizeVariation())
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
    local ps = lurek.particle.newSystem()
    ps:setSizes(4, 2, 1)

    local sizes = ps:getSizes()
    print("size count = " .. #sizes)
    print("first size = " .. sizes[1])
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
    local ps = lurek.particle.newSystem()
    ps:setSpeed(50, 200)

    local min_speed, max_speed = ps:getSpeed()
    print("speed = " .. min_speed .. ".." .. max_speed)
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
    local ps = lurek.particle.newSystem()
    ps:setSpin(-3, 3)

    local min_spin, max_spin = ps:getSpin()
    print("spin = " .. min_spin .. ".." .. max_spin)
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
    local ps = lurek.particle.newSystem()
    ps:setSpinVariation(0.5)

    print("spin variation = " .. ps:getSpinVariation())
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
    local ps = lurek.particle.newSystem()
    ps:setSpread(math.pi / 6)

    print("spread = " .. ps:getSpread())
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
    local ps = lurek.particle.newSystem()
    ps:setTangentialAcceleration(-20, 20)

    local min_tangent, max_tangent = ps:getTangentialAcceleration()
    print("tangential = " .. min_tangent .. ".." .. max_tangent)
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
    local ps = lurek.particle.newSystem({
        emissionRate = 100,
        lifetimeMin = 1.0,
        lifetimeMax = 2.0,
    })
    ps:start()

    print("active = " .. tostring(ps:isActive()))
    print("stopped = " .. tostring(ps:isStopped()))
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
    local ps = lurek.particle.newSystem({
        emissionRate = 100,
        lifetimeMin = 1.0,
        lifetimeMax = 2.0,
    })
    ps:start()

    ps:stop()
    print("active = " .. tostring(ps:isActive()))
    print("stopped = " .. tostring(ps:isStopped()))
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

    print("sub-system count = " .. ps:subSystemCount())
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
| [LImageData](#limagedata-handle) | Image data containing the rendered particles. |

**Example**

```lua
do
    local ps = lurek.particle.newPreset("sparks")
    ps:setPosition(64, 64)
    ps:emit(20)
    ps:update(0.1)

    local image = ps:toImage(128, 128)
    print("toImage type = " .. image:type())
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
| string | The string `[LParticleSystem](#lparticlesystem-handle)`. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()

    print("type = " .. ps:type())
    print("is particle = " .. tostring(ps:typeOf("LParticleSystem")))
    print("is drawable = " .. tostring(ps:typeOf("LDrawable")))
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
| `name` | string | Type name to compare against `[LParticleSystem](#lparticlesystem-handle)`, `ParticleSystem`, `Drawable`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local ps = lurek.particle.newSystem()

    print("particle = " .. tostring(ps:typeOf("LParticleSystem")))
    print("drawable = " .. tostring(ps:typeOf("LDrawable")))
    print("object = " .. tostring(ps:typeOf("LObject")))
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

    print("count after update = " .. ps:count())
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
    local ps = lurek.particle.newPreset("rain")
    ps:start()
    ps:warmUp(2.0)

    print("warmed count = " .. ps:count())
end
```

---

## LTrail Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LTrail:clear`

Clears all trail points on this object.

```lua
LTrail:clear()
```

**Example**

```lua
do
    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)

    print("before clear = " .. trail:getPointCount())
    trail:clear()
    print("after clear = " .. trail:getPointCount())
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
| [LImageData](#limagedata-handle) | Image data containing the rendered trail. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:pushPoint(0, 0)
    trail:pushPoint(50, 25)

    local image = trail:drawToImage(64, 64)
    print("trail image type = " .. image:type())
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
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:setLifetime(5.0)

    print("lifetime = " .. trail:getLifetime())
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
    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:pushPoint(30, 8)

    print("points = " .. trail:getPointCount())
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
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:setWidth(10, 2)

    local start_width, end_width = trail:getWidth()
    print("width = " .. start_width .. " -> " .. end_width)
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
    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:pushPoint(30, 8)

    print("points = " .. trail:getPointCount())
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
    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setHeadColor(1, 1, 0, 1)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)

    print("points = " .. trail:getPointCount())
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
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:setLifetime(5.0)

    print("lifetime = " .. trail:getLifetime())
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
    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setMinDistance(3)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)
    trail:pushPoint(10, 0)

    print("points = " .. trail:getPointCount())
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
    local trail = lurek.particle.newTrail(2.0, 6)
    trail:setTailColor(1, 0, 0, 0)
    trail:pushPoint(0, 0)
    trail:pushPoint(5, 0)

    print("points = " .. trail:getPointCount())
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
    local trail = lurek.particle.newTrail(1.0, 4)
    trail:setWidth(10, 2)

    local start_width, end_width = trail:getWidth()
    print("width = " .. start_width .. " -> " .. end_width)
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
| string | The string `[LTrail](#ltrail-handle)`. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(1.5, 8.0)

    print("type = " .. trail:type())
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
| `name` | string | Type name to compare against `[LTrail](#ltrail-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local trail = lurek.particle.newTrail(1.0, 4)

    print("is trail = " .. tostring(trail:typeOf("LTrail")))
    print("is object = " .. tostring(trail:typeOf("LObject")))
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
    local trail = lurek.particle.newTrail(3.0, 5)
    trail:pushPoint(0, 0)
    trail:pushPoint(10, 5)
    trail:pushPoint(20, 10)
    trail:update(0.5)

    print("after update = " .. trail:getPointCount())
end
```

---
