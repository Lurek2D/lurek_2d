# Render Plan 1 of 4: Correctness, Security, and Reliability

## Purpose

Harden `render` against hostile or accidental command streams, oversized GPU work, invalid resources, shader abuse, device/surface failure, blocking readback, and misleading diagnostics. This phase is a prerequisite for render API expansion or optimization.

## Confirmed baseline

- `cargo test --test render_tests` passes 132/132 and `cargo clippy -- -D warnings` passes.
- `RenderInputLimits` centrally validates individual commands with limits such as vertices per command, segments, and post-processing passes.
- There is no unified aggregate ceiling for commands, total vertices/indices/glyphs/text bytes/particles/lights/shadows/uploads/canvases/shader resources per frame.
- Geometry buffers can grow geometrically from Lua-driven workloads; several byte-size calculations and integer casts are not guarded by one device-aware checked policy.
- Public font, image, and OBJ paths ultimately use direct `std::fs` operations or `game_dir.join`, not one canonical GameFS/path-policy seam.
- Shader source/uniform counts and pipeline/cache churn lack complete user-input budgets.
- Screenshot and offline shader paths call `device.poll(wgpu::Maintain::Wait)`, which can block indefinitely from the caller’s perspective.
- Surface Lost/Outdated cases are reconfigured by app code, but Timeout, OutOfMemory, device loss, and uncaptured validation errors do not form one tested recovery state machine.
- `RenderDiagnostics::finding_total()` double-counts dropped-command categories and includes normal shadow activity as “findings,” so a healthy shadow frame can report a fault.

## Required invariants

1. Lua-controlled rendering can consume only a bounded amount of CPU memory, GPU memory, commands, compilation work, and per-frame processing.
2. All sizes and offsets are validated with checked arithmetic against both engine policy and `wgpu::Limits` before allocation or encoding.
3. Invalid commands/resources are rejected deterministically without panic, partial resource publication, or cross-frame state corruption.
4. Game asset reads and authorized output writes obey canonical filesystem policy.
5. User shaders have an explicit trust model and bounded source, bindings, compilation/cache, and submission behavior.
6. Surface/device failures transition through a documented state machine; OutOfMemory produces a controlled shutdown path.
7. Readback is bounded, cancellable or timeout-aware, and does not synchronously stall the main loop.
8. Fault diagnostics, normal activity telemetry, and cumulative totals are separate and numerically correct.

## P0 — Introduce cumulative `RenderBudget` accounting

Keep `RenderInputLimits` for per-object validation and add a device-aware cumulative budget checked while accepting a frame and while creating persistent resources. Include at least:

- commands per frame and per command family;
- total color/texture/particle vertices and indices;
- instances and sprite-batch items;
- glyphs, rich-text spans, and UTF-8 bytes;
- lights, shadow-casting lights, caster edges, shadow atlas work, and light quads;
- canvases touched, render passes, postfx passes, pipeline switches, and bind-group changes;
- dynamic texture/font/mesh/shader uploads and total bytes per frame;
- total live bytes/counts for textures, canvases, meshes, geometry buffers, shaders, uniform buffers, cached pipelines, and pending readbacks;
- tessellation segments and generated geometry across the entire frame;
- command nesting/stack depth for transforms, scissor, stencil, canvases, and shader/effect scopes.

Implementation requirements:

- Derive hard upper bounds from the minimum of engine configuration and adapter/device limits.
- Use checked additions/multiplications/conversions and `try_reserve`; no `usize as u32/u64` until a checked conversion establishes the range.
- Validate and account before expensive tessellation, allocation, shader compilation, upload, or command recording.
- Decide per category whether exceeding the budget rejects the entire frame, skips a command, or defers an upload. Document the decision and emit one precise diagnostic without double-counting.
- Reset frame counters at the frame boundary and keep separate persistent-resource accounting.
- Provide trusted configuration only at engine startup. Lua can query effective limits but cannot raise them.

## P0 — Make GPU allocations and resource publication fallible

- Replace unchecked capacity growth in `src/render/gpu_resources.rs` with checked next-capacity calculation constrained by policy and `max_buffer_size`.
- Validate alignment, row pitch, texture dimensions/layers/mips/sample count, vertex stride, index range, instance range, and upload byte equality before calling `wgpu`.
- Allocate into temporary state; publish the new buffer/texture/canvas/mesh/shader handle only after every validation/upload step succeeds.
- Cap retained capacity and define shrink/reclaim behavior after exceptional peaks or resource release.
- Audit every `create_buffer`, `create_texture`, `create_bind_group`, and `create_render_pipeline` call for a prevalidated descriptor and resource-count limit.
- Replace the transient bind-group `unwrap` in `gpu_renderer.rs`, the “just pushed” `expect` in `frame_mid.rs`, and parser `expect` paths with explicit invariant branches or types that make the state unrepresentable.
- Register `wgpu` uncaptured-error callbacks and map validation/OOM/internal errors to the recovery/diagnostic layer without exposing sensitive driver strings directly to game scripts.

## P0 — Harden shader and uniform input

- Define trust modes: built-in engine shaders, trusted local project shaders, and untrusted/runtime-provided shader text. State which modes are supported.
- Add limits for WGSL source bytes/lines/tokens, entry points, vertex attributes, bind groups, bindings, textures/samplers, uniform names, uniform count, and total uniform bytes.
- Validate each proposed layout against `wgpu::Limits` before module/pipeline creation. Avoid one 16-byte buffer and binding per arbitrary uniform if a bounded packed uniform layout can be used.
- Reject duplicate/reserved names, nonfinite uniform values, type mismatches, excessive array dimensions, and unsupported stages/features.
- Cache by normalized source/options/device capabilities, but cap entries and bytes; record compile time, hit/miss, eviction, and failure counts.
- Prevent repeated invalid source from compiling every frame with a bounded negative-result cache.
- Document that general WGSL cannot be proven termination-safe. For untrusted games, either restrict runtime shader creation to a validated subset or disable it; otherwise make the trust requirement explicit.
- Add hostile shader tests for source bombs, binding overflow, pipeline-key churn, repeated failures, device-limit mismatch, and release/recreate cycles.

## P0 — Route all assets and outputs through owner policies

### Fonts and textures

- Remove direct `std::fs::read` and unchecked `game_dir.join` from render Lua helpers.
- File/GameFS owns path resolution and bounded byte reads.
- Font owns font/bitmap font decoding and font resource semantics.
- Image owns image decoding and `ImageData`; render accepts validated pixel/upload descriptors and creates GPU textures.

### OBJ/MTL

- Refactor `obj_loader` so the parser accepts bounded bytes/text plus a resolver interface; it must not choose host filesystem policy.
- Validate OBJ/MTL byte size, line length, line count, vertices, normals, UVs, faces, triangulated indices, materials, object/group/name lengths, referenced files, and numeric finiteness.
- Keep traversal/absolute/link checks in the canonical resolver and require material references to remain within the same authorized asset root.
- Use checked index normalization/triangulation and reject outputs exceeding mesh/device budgets.

### Screenshots/readback

- Let render return bounded `ImageData`/readback results; image owns encoding and filesystem owner handles atomic output.
- Apply path, overwrite, byte, dimension, and concurrency policies consistently with UI capture.

## P0 — Implement a surface/device recovery state machine

Define explicit states such as `Ready`, `SurfaceReconfigurePending`, `DeviceRecoveryPending`, `OutOfMemory`, and `ShuttingDown` (exact names may differ). Required transitions:

- `Lost`/`Outdated`: stop submissions, refresh capabilities/configuration, recreate surface-dependent resources, then resume.
- `Timeout`: skip or retry under a capped policy and report rate-limited diagnostics.
- `OutOfMemory`: stop new allocations/submissions, surface a controlled fatal error, flush minimal diagnostics, and shut down rather than continuing.
- Device lost/internal validation: recreate device-owned pipelines/buffers/textures from retained CPU descriptors where supported, or fail in a documented controlled way.
- Zero-sized/suspended windows: avoid configuring/encoding until a valid extent returns.
- Pending screenshots/readbacks: cancel or requeue exactly once according to request policy; never hang.

Move duplicated surface-error handling from app paths behind one render-facing policy while allowing app to decide process/window lifecycle. Add deterministic state-machine unit tests using injected events and integration tests on the available backend.

## P0 — Replace blocking readback with bounded requests

- Add a readback request handle with states `pending`, `ready`, `failed`, `cancelled`, and `timed_out`.
- Validate dimensions and padded row-byte arithmetic before buffer creation.
- Limit concurrent requests and total staging bytes; reject or queue according to documented policy.
- Progress mapping through normal device polling/event-loop work. Do not call `Maintain::Wait` on the interactive main-loop path.
- Provide poll/status/cancel/result APIs; result consumption releases staging resources.
- Keep a synchronous helper only for trusted offline tools/tests with an explicit timeout and clear prohibition on frame-loop use.
- Cover device loss, cancellation, timeout, dropped Lua handle, repeated result reads, and row-padding correctness.

## P1 — Correct diagnostics and observability semantics

- Split `RenderFaults` from `RenderActivity`/`RenderStats`.
- Fault totals count each rejected/dropped operation once. Category counters may partition or annotate the total but must not be added on top of the already-counted total.
- Shadow lights rendered/edges collected/culled, buffer growth, draw calls, and cache activity are normal metrics, not faults.
- Track last-frame and saturating cumulative values independently.
- Bound diagnostic message storage and rate-limit repeated identical GPU/resource errors.
- Add invariants/tests such as:
  - healthy shadow rendering yields `has_faults() == false`;
  - one missing texture yields one dropped operation and one missing-texture category;
  - reset affects last-frame state but not cumulative totals;
  - saturation cannot wrap.
- Deprecate misleading `finding_total`/`has_findings` names after adding accurate replacements.

## P1 — Harden command/state-stack validation

- Validate balanced canvas, scissor, stencil, transform, shader, blend, and postfx scope transitions before encoding.
- Define end-of-frame behavior for unbalanced stacks: reject frame or unwind with a diagnostic; never leak state into the next frame.
- Validate resource generations and ownership for every command; released or foreign renderer handles fail deterministically.
- Reject nonfinite coordinates, matrices, colors, depths, widths, radii, particle parameters, and shader uniforms at the boundary.
- Validate mesh topology, index bounds, texture region bounds, canvas feedback hazards, sample/format compatibility, and pass attachment compatibility.
- Add randomized command-sequence property tests against a backend-independent validator.

## P2 — Fuzz parsers and validators

- Fuzz OBJ/MTL, WGSL prevalidation, command sequences, mesh data, rich text, texture upload descriptors, and state stacks.
- Assert bounded time/memory, no panic, no invalid resource publication, no cross-frame state leakage, and deterministic error categorization.
- Seed with integer overflows, NaN/infinity, malformed UTF-8 where relevant, deeply nested scopes, enormous declared counts with short buffers, and stale resource handles.

## Exit criteria

- Per-command and cumulative budgets cover every Lua-driven render workload and persistent GPU resource class.
- All allocation arithmetic is checked against engine and device limits.
- No normal game asset path bypasses GameFS/owner decoders.
- Shader trust and limits are explicit and tested.
- Surface/device errors and readback cannot panic or hang the main loop.
- Diagnostics distinguish one fault from normal activity and do not double-count.
- Security tests execute the real validation/resource paths and demonstrate bounded rejection.

