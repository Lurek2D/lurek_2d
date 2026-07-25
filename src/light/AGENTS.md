# Light Module Contract

## Mission & Scope
- Own 2D lights, occluders, groups, flicker, transitions, and render-ready snapshots.
- Do not own GPU pipelines, tile-grid light propagation, or gameplay visibility.

## Files

- `light2d.rs`, `light_world.rs`: Light state, groups, and snapshots.
- `occluder.rs`, `shadow.rs`: Geometry and shadow data.
- `flicker.rs`, `transition.rs`, `attenuation.rs`, `falloff.rs`: Light behavior.
- `limits.rs`, `debug_image.rs`: Limits and bounded CPU previews.

## Rules
- Reject non-finite Lua numbers before mutation.
- Apply `LightLimits` before storing lights, geometry, exports, previews, or work.
- `max_lights` limits render selection, not stored lights. Selection order is stable.
- Failed constructors and bulk imports leave counts and handles unchanged.
- Checked occluder input must return errors, never panic.
- Keep cookies and transitions on `Light2D` or `LightWorld`, not handle wrappers.

## Workflow
- Run `cargo test --test light_tests` and the light Lua unit/security tests.
