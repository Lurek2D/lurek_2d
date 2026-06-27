# effect manual spec overlay

## TL;DR

- Manages visual post-processing stacks, shader parameters, and presets.
- Coordinates capture boundaries, image effect chains, and diagnostics.

## Summary

- The `effect` module is the post-processing surface for users who want final-frame styling to be configurable at runtime instead of buried in renderer internals.
- Effect stacks, presets, and parameter control let projects combine blur, bloom, grading, distortion, and custom passes as a reusable look pipeline rather than as isolated toggles.
- The same module supports both full-frame and image-scoped workflows, which makes it useful for global scene mood, local asset treatment, and diagnostic capture flows.
- Runtime enabling, disabling, and reordering matter because visual iteration often depends on trying combinations quickly while the game is running.
- Preset-oriented workflow is a major user-facing advantage because art direction usually depends on named looks that can be switched, blended, or tuned per scene instead of rebuilt from scratch each time.
- That makes the module valuable for shipped presentation, look development, and visual comparison.
- It is especially useful when several passes need to be staged and tuned together as one style decision.
- It also keeps composition policy above the renderer, so projects can adjust how global and local treatments are assembled without rewriting low-level pass code.
- Read `effect` as the owner of effect composition and art-direction control. The renderer executes passes, but `effect` defines how those passes are organized and tuned from the user side.

This module primarily collaborates with `image`, `overlay`, `render`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Notes

- Ownership boundary:
  `effect` owns post-processing effect kinds, parameter schemas, stack ordering, presets, capture/apply orchestration, custom shader pass descriptors, and image-scoped post-fx chains. It must not own weather, flash, fade, shake, ambient, or other scene-wide presentation policy; those belong to `overlay`.
- Built-in post-fx parameters are schema-validated before they are accepted or emitted to render commands. Unknown built-in parameter names are rejected, non-finite values are rejected, and integer-like params such as `motionblur.samples`, `pixelate.block_size`, and `dither.palette_size` must stay whole-numbered and in range.
- `PostFxStack` dimensions are part of the module contract. Rust callers can use `try_new` and `try_resize` for strict validation, while legacy constructors sanitize dimensions into the configured safe range instead of forwarding zero-sized targets.
- Stack planning now resolves explicit renderer `PostFxPass` descriptors from enabled effects. Stale stack indices, invalid custom shader ids, empty resolved pass lists, and duplicate indices are surfaced through `PostFxDiagnostics` instead of silently producing an empty `ApplyPostFx`.
- Duplicate stack entries are allowed by default but reported as warnings through the stack duplicate policy. Callers that want stricter behavior can switch the policy to disallow duplicates before validation or render planning.
- Custom post-fx auto uniforms use the documented contract snapshot `time`, `resolution`, `texel_size`, `frame_index`, and `stack_index`. The `auto_uniforms` flag only opts a pass into that fixed set; it does not imply arbitrary shader reflection.
- Debug image helpers now have explicit `try_draw_*` variants guarded by `PostFxDebugImageLimits` so tooling can reject oversized diagnostic images deterministically.
- Legacy overlay exports under `effect` are compatibility edges only. New Lua/API examples should use `lurek.overlay` for overlay state and `lurek.effect` for post-fx stacks or shader passes.

## Architecture Links

- `docs/architecture/module-scope-boundaries.md`
- `docs/architecture/effects-particles-overlay-plan.md`
