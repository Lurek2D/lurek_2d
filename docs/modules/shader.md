# Shader

## Purpose

WGSL is the only supported user shader language.

## When To Use

- lurek.shader.new(code, { target = ... }) is the canonical constructor for target-aware runtime shaders.
- lurek.render.newShader(code) remains a compatibility path for target = "draw".
- Target validation is strict: post-fx, image, overlay, particle, and light APIs reject shaders created for another target.

## Minimal Example

Example block: `lurek.shader.new`

```lua
do
    local code = [[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(uv, 1.0), color.a);
}
]]
    local shader = lurek.shader.new(code, { target = "draw" })
    local shader_id = shader:getId()
    local target = shader:getTarget()
    local diagnostics = shader:getDiagnostics()
    shader:send("tint_amount", 0.5)
    local has_uniform = shader:hasUniform("tint_amount")
    local still_live = shader_id > 0 and target == "draw" and diagnostics[1] ~= nil and has_uniform
end
```

## Common Patterns

- Start with `lurek.shader.new` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- WGSL is the only supported user shader language.
- `lurek.shader.new(code, { target = ... })` is the canonical constructor for target-aware runtime shaders.
- `lurek.render.newShader(code)` remains a compatibility path for `target = "draw"`.
- Target validation is strict: post-fx, image, overlay, particle, and light APIs reject shaders created for another target.
- The current implementation establishes the shared API, validation, example WGSL assets, custom post-fx execution, offline `ImageData` GPU processing through a render-owned headless readback path, render-time particle shader specialization, and custom light contribution pipeline replacement.

This module is mostly self-contained inside the Platform Services group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.shader.new`

Compiles a target-aware WGSL fragment shader and returns a shader handle.

```lua
lurek.shader.new(code, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | string | WGSL fragment shader source code. |
| `opts?` | table | Options table with optional `target` string. |

**Returns**

| Type | Description |
|------|-------------|
| [LShader](#lshader) | Compiled shader handle. |

**Example**

```lua
do
    local code = [[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(uv, 1.0), color.a);
}
]]
    local shader = lurek.shader.new(code, { target = "draw" })
    local shader_id = shader:getId()
    local target = shader:getTarget()
    local diagnostics = shader:getDiagnostics()
    shader:send("tint_amount", 0.5)
    local has_uniform = shader:hasUniform("tint_amount")
    local still_live = shader_id > 0 and target == "draw" and diagnostics[1] ~= nil and has_uniform
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LShader](#lshader)

## LShader

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LShader:getDiagnostics`

Returns shader validation diagnostics.

```lua
LShader:getDiagnostics()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of diagnostic strings. |

---

#### `LShader:getId`

Returns the internal numeric handle ID for this shader.

```lua
LShader:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Opaque shader handle identifier. |

---

#### `LShader:getTarget`

Returns the target this shader was validated for.

```lua
LShader:getTarget()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Shader target name. |

---

#### `LShader:hasUniform`

Checks whether this shader declares a uniform with the given name.

```lua
LShader:hasUniform(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Uniform name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the uniform exists. |

---

#### `LShader:release`

Releases the shader resource. If active, the default shader is restored.

```lua
LShader:release()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the shader was valid and was released. |

---

#### `LShader:send`

Sends a uniform value to this shader by name. Supported types: number, boolean, or table (vec2/vec3/vec4).

```lua
LShader:send(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Uniform variable name declared in the shader. |
| `value` | number|boolean|table | The value to send. |

---

#### `LShader:type`

Returns the type name string for this shader object.

```lua
LShader:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LShader](#lshader)". |

---

#### `LShader:typeOf`

Checks whether this object matches the given type name.

```lua
LShader:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check ("Shader" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

---
