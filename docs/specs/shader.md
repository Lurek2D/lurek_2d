<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/shader.md or source docstrings instead. -->

# shader

## TL;DR

`shader` owns the user-facing WGSL shader constructor surface. It validates fragment shader source for an explicit target before other modules bind the handle into draw, post-fx, image, overlay, particle, or light workflows.

## General Info

- Module group: `Platform Services`
- Source path: `src/render`
- Binding: `src/lua_api/shader_api.rs`
- Namespace: `lurek.shader`
- Lua API surface: `1` functions, `0` types, `0` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- WGSL is the only supported user shader language.
- `lurek.shader.new(code, { target = ... })` is the canonical constructor for target-aware runtime shaders.
- `lurek.render.newShader(code)` remains a compatibility path for `target = "draw"`.
- Target validation is strict: post-fx, image, overlay, particle, and light APIs reject shaders created for another target.
- The current implementation establishes the shared API, validation, example WGSL assets, custom post-fx execution, and offline `ImageData` GPU processing through a render-owned headless readback path.
- Particle shader rendering and light contribution pipeline replacement are staged behind the same target contracts; their public bindings validate targets and preserve shader selections while renderer specialization continues.

This module is mostly self-contained inside the Platform Services group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Ownership

- Canonical source: `src/render`
- Owning tier: `Platform Services`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/shader_api.rs`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files





## Lua API Ref

### Functions

- `lurek.shader.new(code, opts?) -> LShader`: Compiles a target-aware WGSL fragment shader and returns a shader handle.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## Examples

- `content/examples/shader.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_shader_unit.lua` (present)
- Rust: none detected.

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_shader_evidence.lua` |
| Current artifact | `tests/artifacts/current/shader/shader_api_contract.txt` |

## Architecture Links

- docs/architecture/effects-particles-overlay-plan.md
- docs/architecture/render-pipeline.md

## Notes

- Fullscreen targets (`postfx`, `image`, `overlay`) share the same input contract: source color, uv, pixel position, resolution, and texel size.
- `image` shaders run as an off-screen fullscreen pass over RGBA8 `ImageData` and read the result back into a new `ImageData`.
- Particle and light targets add scalar/vector inputs for render-time visual data.
- Runtime custom shaders are fragment-only; arbitrary vertex and compute shader execution is outside this API.
