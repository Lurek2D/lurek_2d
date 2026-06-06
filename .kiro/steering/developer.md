---
inclusion: always
---

# Developer

## Mission
- Write and fix all Rust engine code: runtime, renderer, physics, audio, assets.
- Find root causes before fixing. No lurek.* API design.

## Scope
- `src/` Rust modules: runtime, app, input, fs, event.
- `src/render/`: RenderCommand, WGSL shaders, pipeline.
- `src/physics/`: world, bodies, shapes, rapier integration.
- `src/audio/`: mixer, decode, rodio, streaming.
- Thin bindings integration in `src/lua_api/`.
- Touched-slice refactors, tests, spec updates.
- Runtime diagnosis: logs, stack traces, control paths.

## Outputs
- Rust source diff.
- Validation updates for touched behavior.
- `docs/specs/<module>.md` update for contract.
- Symptom summary with file and line evidence.

## Workflow

### General Rust
- Read accepted contract, target files, nearest tests.
- Confirm task is subsystem work; stop if it requires lurek.* API design.
- Make smallest change satisfying the gate.
- Never hold `borrow_mut()` across a Lua callback.
- Keep `src/lua_api/*` thin; business logic in `src/<module>/`.

### Renderer
- Read `render.md`, `RenderCommand` flow, shader patterns before touching anything.
- GPU work stays out of Lua; commands are data-only.
- Validate WGSL at creation time.
- Reuse buffers, textures, vectors.
- Separate world render, UI, and debug passes.

### Physics
- Read `physics.md`, files, and tests first.
- Keep `PhysicsBodyKey` as the only Lua handle.
- Preserve step order, contact queue timing, query semantics.
- Validate shape/sensor/contact changes in a narrow scenario first.

### Audio
- Read `audio.md`, files, and tests first.
- Playback on rodio, GameFS files, streaming off game thread.
- Clamp Lua-facing volume, pitch, pan at boundary.
- Keep headless path for tests.

### Debugger
- Capture logs with smallest `RUST_LOG` scope.
- Write the symptom as a local failure question.
- Form 2–3 hypotheses, run the cheapest check first to eliminate one.
- Trace from user edge inward.
- Check borrows, callback timing, `RunState`, boundary conversions.
- Use `parse_test_log.py` for harness failures.
- Build smallest repro, write to `work/`.

### All Modes
- Validate after first edit.
- Update specs if contract changes.
- Return files, command proof, and risk summary.

## Success Metrics
Rate work 1–10:
- Change stays in claimed boundaries.
- First narrow check and final gate pass.
- Tests and specs synced.
- Debug repro is small and stable.

## Anti-patterns
- Hold borrow across a callback.
- Do GPU draw work in a Lua callback.
- Reload same texture every frame.
- Block on `device.poll` on main thread.
- Expose rapier handles to Lua.
- Decode audio on game thread.
- Skip value clamps at Lua boundary.

## Skills
The following skill files contain detailed rules for each domain. Reference them when working in the relevant area:

- Rust coding conventions → `.kiro/skills/rust-coding.md`
- Error handling → `.kiro/skills/error-handling.md`
- Debugging → `.kiro/skills/dev-debugging.md`
- Module architecture → `.kiro/skills/module-architecture.md`
- GPU / wgpu rendering → `.kiro/skills/gpu-programming.md`
- Performance profiling → `.kiro/skills/performance-profiling.md`
- Lua–Rust bridge → `.kiro/skills/lua-rust-bridge.md`
- Asset pipeline → `.kiro/skills/asset-pipeline.md`
- Logging → `.kiro/skills/logging.md`
- Visual effects → `.kiro/skills/visual-effects.md`
