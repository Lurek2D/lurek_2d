# Render Plan 3 of 4: Lua API, Documentation, Examples, Specs, and Docstrings

## Purpose

Make the render contract accurate, consistently owned, and usable without reading engine internals. This phase aligns the Lua API, examples, specs, architecture, Rust docs, and file docs with the hardened renderer from Plans 1–2.

## Evidence and documentation drift

- Lua unit/spec tools report 217 render APIs with exact ownership.
- Example tooling reports 208 render APIs and no gaps against its own denominator.
- `audit_module.py render` reports 124 bound functions. These three denominators are incompatible and must not be presented as simultaneous 100% coverage.
- The module audit reports structured documentation gaps for more than 90 render types.
- The strict file-doc audit fails `src/render/province_map_pipeline.rs` and `src/render/postfx_pipeline.rs`; several mechanically passing files still use generic boilerplate.
- `docs/architecture/render-pipeline.md` contains obsolete `lurek.graphics.*` examples, stale app-flow/file claims, a fixed command-variant count, and an invariant that no module outside render imports `wgpu`, while app/province source currently does.
- The render spec omits the direct province collaboration and does not fully specify cumulative budgets, shader trust, recovery, readback, or resource-accounting behavior.

## P0 — Establish one canonical render API inventory

- Use the generated public API registry/model as the only denominator for namespace functions, userdata methods, constants/enums, overloads, and compatibility aliases.
- Assign a stable ID, owner module, kind, source registration location, lifecycle status, and canonical alias target to each entry.
- Require unit/example/spec/doc/module/quality audits to consume it and fail immediately if totals differ.
- Determine and close the current 217 versus 208 versus 124 disagreement before adding APIs. Report the exact missing/ignored entries and parser cause.
- Add fixtures for resources with methods, namespace constructors, overloaded signatures, deprecated aliases, and same method names on different types.

## P0 — Normalize resource identity and lifecycle APIs

- Every GPU-backed resource uses an opaque generational handle tied to one renderer/device identity.
- Document create/upload/use/release/recreate semantics for textures, canvases, meshes, shapes, shaders, fonts/glyph residency, batches, static geometry, and readback requests.
- Define errors for released, stale, foreign-renderer, device-lost, pending, and wrong-resource-kind handles.
- Make release idempotence a deliberate contract or reject double release consistently; do not vary by resource type.
- Document whether CPU descriptors are retained for device recovery and the memory cost.
- Ensure Lua cannot forge handles from integers/tables and never exposes raw slot IDs as mutation authority.

## P0 — Repair constructor ownership and naming

Create a migration table and implement it with aliases only where compatibility requires:

| Current surface | Canonical direction | Required documentation |
|---|---|---|
| `lurek.render.newFont` | font-owned load/constructor | Render consumes font handles; alias uses identical GameFS/default/error behavior. |
| `lurek.render.newImage` / `LImage` | `newTexture`/`LTexture` for GPU resource | Image owns `ImageData` and codecs; explain upload/color space. |
| `lurek.render.newSpriteBatch` | one sprite-owned semantic batch + render backend | No second batch type; alias target and removal schedule. |
| scene/render depth sorter aliases | one owner based on domain-neutral vs scene-aware semantics | Stable ordering, NaN behavior, complexity, canonical namespace. |
| path-based OBJ loading | asset/GameFS resolver + render mesh upload | Parser limits, material resolution, returned resource lifecycle. |

Each deprecated entry needs `@deprecated`, replacement, first-warning release, removal release, and an executable migration example. Aliases must share implementation rather than fork behavior.

## P0 — Make limits, errors, and asynchronous work public contracts

- Add a read-only capability/effective-limits snapshot with stable engine concepts, not raw `wgpu` enums.
- Document per-command `RenderInputLimits` and cumulative `RenderBudget`, including units, default source, device clamping, reset boundary, and reject/skip/defer policy.
- Use consistent typed options tables for complex constructors. Reject unknown keys.
- Document shader trust mode, accepted stages/features, source/binding/uniform limits, compilation behavior, and security limitations.
- Specify asynchronous resource/prewarm/readback request states, poll/cancel/result/timeout behavior, queue limits, and device-loss outcome.
- Define surface/recovery state visible to Lua, if any, as a small stable abstraction. App/process-specific details remain outside render.
- Standardize errors for invalid input, budget exceeded, unsupported capability, missing/released resource, compilation failure, recovery, timeout, and OOM.

## P0 — Correct the render module spec

Update source spec content, then regenerate managed sections:

- Enumerate the actual command families programmatically instead of embedding a stale fixed count.
- Specify validation order: Lua conversion, per-object validation, cumulative accounting, resource-generation checks, frame-state validation, encoding.
- Specify resource lifecycle/accounting, cache limits/eviction, and recovery descriptors.
- Specify GameFS/asset resolver boundaries for textures/fonts/OBJ/MTL and image ownership for codecs/readback.
- Specify shader trust and limits.
- Specify surface/device recovery and OOM behavior.
- Separate fault diagnostics from normal activity telemetry.
- Include province through the neutral snapshot boundary, UI through commands, sprite/font/image/scene through their owner handles/snapshots, and app through the narrow surface facade.
- Document software replay parity and unsupported-command diagnostics.
- Add architecture links for pipeline, resource lifecycle, security/file policy, Lua scripting boundary, and owner modules.

Never update generated regions manually.

## P0 — Rewrite stale render architecture documentation

Repair `docs/architecture/render-pipeline.md` from source evidence:

- Replace `lurek.graphics.*` with current canonical names after the API ownership decision.
- Describe the actual split app main-loop/screen flow rather than a stale monolithic file.
- Replace the false blanket `wgpu` invariant with the intended post-refactor dependency rule, or explicitly document a narrowly enforced app bootstrap exception.
- Remove claims that renderer never knows province only after source has been refactored to make them true; until then, mark current debt honestly.
- Generate or link the command inventory instead of hard-coding variant totals.
- Diagram CPU owner snapshots → validated frame packet → GPU/software backend → diagnostics/readback.
- State where color space, clipping, transforms, ordering, canvas feedback, and recovery are defined.
- Add source-link checks so renamed files/functions cannot silently stale.

## P1 — Improve Rust file and item documentation

### File docs

- Fix the exact mechanical failures in `province_map_pipeline.rs` and `postfx_pipeline.rs`.
- Qualitatively review all 37 render files. Each leading `//!` block must name concrete responsibility, owned GPU/CPU state, invariants, public/crate-local entry points, data direction, neighboring owner, and a navigation hint for large files.
- Remove repeated filler such as “owns subsystem” or “keeps helpers focused” when it conveys no file-specific fact.
- Re-run the audit after the file refactors in Render Plan 2, because final line-count rules depend on final LOC.

### Item docs

- Close the 90+ structured documentation findings, prioritizing public resource handles, command variants/fields, budgets, validation categories, pipeline/cache keys, descriptors, diagnostics, recovery states, and readback requests.
- Add `# Errors`, `# Panics`, `# Performance`, and recovery/resource-lifetime sections where relevant.
- Document coordinate spaces, units, color spaces, premultiplication, matrix conventions, angle units, depth/order, texture origin, row padding, and alignment.
- State complexity and allocation behavior for tessellation, sorting, uploads, shader compilation, and capture.

## P1 — Upgrade Lua docstrings and examples to semantic coverage

### Docstrings

- Document exact defaults/ranges/limits and cumulative budget impact.
- State whether a call records a command, performs an immediate upload, schedules work, or blocks. No API intended for the frame loop may hide synchronous `Maintain::Wait`.
- State resource ownership/lifetime and device-recovery outcome.
- Use canonical resource names and link aliases to their owner namespace.
- Document feature/capability requirements and fallback/rejection behavior.

### Examples

- Keep one exact marker per API entry, but demonstrate observable output/state rather than only construction or `tostring`.
- Pair state setters with draw commands/diagnostics and show balanced transform/scissor/stencil/canvas/shader scopes.
- Show budget/capability queries and graceful unsupported-feature handling.
- Show texture upload from `ImageData`, font-owner handles, sprite-owner batch snapshots, and province snapshots through the correct boundaries.
- Show release/stale-handle behavior and device-recovery expectations.
- Show asynchronous capture/prewarm poll/cancel/result flows.
- Add meaningful mesh/OBJ, shader uniform, postfx, canvas feedback rejection, lighting/shadow, and software replay examples.
- Deprecated aliases receive migration examples only; do not create separate competing concepts.

Examples must be deterministic, harness-runnable, and free of top-level side effects.

## P1 — Add narrative render guides

1. **Frame model:** record validated commands, submit, inspect diagnostics.
2. **Coordinates and state:** transforms, viewport, scissor, stencil, canvas, blend, color space, ordering.
3. **Resources:** ImageData → texture, mesh/shape/static geometry, font/glyph, sprite batch, release/recovery.
4. **Shaders and postfx:** trust, limits, capabilities, prewarm, errors, cache behavior.
5. **Performance:** batching, upload budgets, cache metrics, cold/warm frames, avoiding readback stalls.
6. **Capture/headless:** async GPU readback versus deterministic software replay and image encoding.
7. **Troubleshooting:** faults versus activity, budget rejection, unsupported capability, surface/device recovery.

Link to image/font/sprite/scene/province/UI/file docs for owner details instead of copying their API references.

## P2 — Add docs-as-contract gates

- Generate effective default limits/capability field lists into docs from source constants/schema.
- Verify every Lua example through the harness and a backend-appropriate smoke run.
- Reject stale `lurek.graphics`, renamed file paths, fixed command counts, and false dependency statements.
- Require API totals to match across every audit before coverage percentages are printed.
- Add qualitative checks for empty examples and generic file-doc boilerplate, with human review retained for correctness.

## Required verification

```text
tools/python.cmd tools/audit/unit_test_api_coverage.py --module render --json
tools/python.cmd tools/audit/example_coverage.py render
tools/python.cmd tools/audit/example_lint.py content/examples/render.lua
tools/python.cmd tools/audit/spec_api_coverage.py --module render
tools/python.cmd tools/audit/docstring_audit.py src/lua_api/render_api.rs
tools/python.cmd tools/audit/module_docstring_audit.py --src src/render --check
tools/python.cmd tools/audit/cag_link_check.py --strict
```

Use repaired CLI syntax. Record unrelated pre-existing link failures separately, but block on any new render-owned failure.

## Exit criteria

- All render audits consume one canonical inventory and agree on the count.
- Canonical resource names/namespaces match module ownership; aliases have deadlines and parity tests.
- Spec and architecture describe actual validation, budgets, lifecycle, recovery, shader trust, capture, and dependencies.
- File/item/Lua documentation is mechanically complete and qualitatively specific.
- Examples execute and demonstrate semantics, errors, limits, and lifecycle.
- No stale `lurek.graphics`, fixed command count, obsolete file path, or false dependency claim remains.

