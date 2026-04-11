# Gap Analysis: `src/dataframe`

## 1. Architecture & Compliance (BLOCKER)
- **Dependency Violation**: The `dataframe` module is assigned to the `Foundations` tier. Per the architecture rules (`docs/architecture/engine-architecture.md`), `Foundations` modules are leaf modules and must not import from higher groups. However, `src/dataframe/frame.rs` and `src/dataframe/query.rs` import `crate::runtime::log_messages` (`Core Runtime`). This creates a reverse dependency and risks cycle issues.

## 2. AGENT.md Structure (BLOCKER / ERROR)
The `AGENT.md` file in `src/dataframe/` does **not** adhere to the canonical short format required by the CAG rules (A-02).
- **Missing / Incorrect Metadata Table**: Uses a bulleted `## Module Info` list instead of the required markdown table format (with `**Tier**`, `**Status**`, etc.).
- **Wrong Headings**: Uses `## Module Purpose` instead of `## Purpose`, and `## Files` instead of `## Source Files`.
- **Forbidden Sections**: Contains a `## Key Types` section. According to the `module-audit` skill, this belongs *only* in `docs/specs/dataframe.md` and strictly does not belong in `AGENT.md`.
- **Missing Required Link**: Lacks the `## Full Specification` section linking to `docs/specs/dataframe.md`.

## 3. Code Documentation (PASS)
- Public items are documented.
- No placeholder stub text like `"Consult the module-level documentation..."` was detected.

## 4. Thin Wrapper Rule (PASS)
- No `mlua` imports were found in the domain module.

## Remediation Steps
1. **Fix Architectural Violation**: Remove the dependency on `crate::runtime::log_messages` from `src/dataframe/`. `Foundations` modules should either return `Result`s for higher tiers to log, or use the injected/global `log` crate facade.
2. **Rewrite `src/dataframe/AGENT.md`**: Convert to the exact short template format required by `.github/skills/module-audit/SKILL.md`. Move the detailed `Key Types` list to `docs/specs/dataframe.md`.
