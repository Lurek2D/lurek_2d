# IDEA — `src/bin/`

> **This file is forward-looking.** It records ideas, not commitments. Nothing here is
> implemented in the same session that produces it. Implementation is gated by a separate
> roadmap decision.
>
> See [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md) for filling instructions.

---

## 1. Header

- **Module**: `bin`
- **Owner module path**: `src/bin/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy**: `CORE-KEEP`
- **LOC (rust only)**: ~30 · **Public Lua surface**: none — 0 fn / 0 userdata
- **Inbound non-`lua_api` callers**: none (binary targets only)
- **Heavy dependencies**: none (delegates to `lurek2d::lurek_run()`)

## 2. Mission Summary

The `bin` module provides alternative binary entry points for the Lurek2D engine. Currently it contains only `lurekc.rs`, the console-less Windows launcher that suppresses the terminal window via `#![windows_subsystem = "windows"]`. Both `lurekc.exe` and the primary `lurek2d.exe` call `lurek2d::lurek_run()`. It serves **Player** (polished distribution) and **GameDev** (packaging). It is NOT a library, NOT a Lua surface, and MUST remain minimal.

## 3. Existing Strengths

- **Minimal surface**: `lurekc.rs` is 30 lines — intentionally tiny, zero risk of bugs.
- **Clear purpose**: Single responsibility — hide the console on Windows distribution.
- **Platform-safe**: `cfg_attr(windows, ...)` means the attribute is ignored on Linux/macOS.

## 4. Gap List

1. **[P3][GAP]** `No dedicated CLI binary` — The primary binary's CLI parsing lives in `src/main.rs`; there is no `lurek-cli.rs` for headless tooling (config validation, asset packing, screenshot batch).
   - Why: Tooling currently requires the full GPU-capable binary even for non-graphical tasks.

## 5. Feature Ideas

1. **[P3][FEAT]** `lurek-cli headless binary` — A third binary target that skips GPU/window init for CLI-only tasks: `lurek-cli validate conf.toml`, `lurek-cli pack game/`, `lurek-cli screenshot game/ --frames 5`.
   - Rationale: CI pipelines and tooling should not require a display server.
   - Effort: M · Risk: low.
   - Competitor inspiration: `[Godot: godot --headless for CI/CD]`, `[Bevy: can run with MinimalPlugins for headless mode]`.

## 6. Performance / Reliability / Quality Ideas

- No items — module is 30 lines of delegation code.

## 7. Test Coverage Gaps

- **[P3][TEST-RUST]** No unit tests possible — `lurekc.rs` is a binary entry point that calls `lurek_run()`. Integration testing would require launching the binary, which needs a GPU.

## 8. TODO(dedup): Cross-Module Overlap

```text
TODO(dedup): main.rs vs bin/lurekc.rs — both call lurek_run(). If CLI parsing grows, ensure it stays in one place (lib.rs or a shared cli module).
```

## 9. TODO(helper): Engine-Level Helper Candidates

- None — no Lua surface.

## 10. TODO(plugin): Plugin Candidacy Proposal

```text
TODO(plugin): CORE-KEEP — binary entry point, not a library module. Cannot be extracted.
```

- **Extraction blockers**: Cargo binary target, not a library.
- **Heavy dep impact if extracted**: n/a.
- **Lua surface stability**: n/a.
- **Migration step**: n/a.

## 11. References

- Module spec: [docs/specs/bin.md](../../docs/specs/bin.md)
- Lua API reference: n/a
- Philosophy constraints touched: `A-01` (runtime only — single binary distribution)
- Plugin doc tier table: [plugins.md §5](../../docs/architecture/plugins.md#5-candidate-modules)
- Authoring guide: [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md)
- Session plan: [PLAN.md](../../work/src-module-review-20260418/reports/PLAN.md)
