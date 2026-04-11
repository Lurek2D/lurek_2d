# Gap Analysis: `src/log`

## 1. Architecture & Compliance (BLOCKER)
- **Dependency Violation**: The `log` module is assigned to the `Foundations` tier. Per the architecture rules (`docs/architecture/engine-architecture.md`), `Foundations` modules are leaf modules and must import **Nothing** from higher groups. However, `src/log/mod.rs` imports `crate::runtime::log_messages;`. `runtime` is in the `Core Runtime` group.
- **Cycle Risk**: This reverse dependency breaks the DAG strict layering (Foundations -> Core Runtime -> ...) and risks an actual import cycle since `runtime` likely depends on `log`.

## 2. AGENT.md Structure (BLOCKER / ERROR)
The `AGENT.md` file in `src/log/` does **not** adhere to the canonical short format required by the CAG rules (A-02).
- **Missing / Incorrect Metadata Table**: Uses a bulleted `## Module Info` list instead of the required markdown table format (with `**Tier**`, `**Status**`, etc.).
- **Wrong Headings**: Uses `## Module Purpose` instead of `## Purpose`, and `## Files` instead of `## Source Files`.
- **Forbidden Sections**: Contains a `## Key Types` section. According to the `module-audit` skill, this belongs *only* in `docs/specs/log.md` and strictly does not belong in `AGENT.md`.
- **Missing Required Link**: Lacks the `## Full Specification` section linking to `docs/specs/log.md`.

## 3. Code Documentation (PASS)
- All public items have docstrings (passes D-01/D-02).
- No stub template text like `"Consult the module-level documentation..."` was found (passes D-04).

## 4. Anomalies & Potential Improvements (WARNING)
- **`SinkLevel` implementation**: In `SinkLevel::from_str` and `enabled_for`, the strings `"off"` and `"none"` are handled inconsistently or absent in `SinkLevel` vs `enabled_for`. `SinkLevel` defaults unsupported strings to `Debug`.
- **File Flushing in `sinks.rs`**: In `Sink::flush()`, the file is locked and immediately dropped (`drop(guard as MutexGuard<File>);`) with a comment saying the OS buffer is flushed by the drop of the guard. Dropping a `File` or `MutexGuard` does *not* call `File::sync_all()` or `File::sync_data()`. It only flushes Rust's `BufWriter` if one is used, but a raw `File` has no buffer. To actually flush a file to disk, `file.sync_all()` must be called.

## Remediation Steps
1. **Fix Architectural Violation**: Remove the dependency on `crate::runtime::log_messages` from `src/log/mod.rs`. `log` should not depend on `runtime`. If `log_messages` state is needed, it either belongs in `Foundations` (e.g., in `log` itself) or the Lua API logic should query `runtime` directly without passing through `src/log/`.
2. **Rewrite `src/log/AGENT.md`**: Convert to the exact short template format required by `.github/skills/module-audit/SKILL.md`. Move the detailed `Key Types` list to `docs/specs/log.md`.
3. **Fix `Sink::flush` implementation**: Call `guard.sync_all()` to properly flush the `File` to disk.
