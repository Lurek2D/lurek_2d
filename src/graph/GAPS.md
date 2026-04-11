# Gap Analysis: `src/graph`

## 1. Architecture & Compliance (BLOCKER)
- **Dependency Violation**: The `graph` module is assigned to the `Foundations` tier. Per the architecture rules (`docs/architecture/engine-architecture.md`), `Foundations` modules are leaf modules and must not import from higher groups.
  - `src/graph/core.rs` and `src/graph/simulation.rs` import `crate::runtime::log_messages` (`Core Runtime`).
  - **Severe Violation**: `src/graph/render.rs` imports `crate::render::renderer::{DrawMode, RenderCommand}` (`Platform Services`). The pure math structure must not depend on the GPU interface, especially `Platform Services`. Rendering routines belong either in `Platform Services` (`render`) or `Feature Systems`. Pure Logic stays pure (Zen Rule 9).

## 2. AGENT.md Structure (BLOCKER / ERROR)
The `AGENT.md` file in `src/graph/` does **not** adhere to the canonical short format required by the CAG rules (A-02).
- **Missing / Incorrect Metadata Table**: Uses a bulleted `## Module Info` list instead of the required markdown table format (with `**Tier**`, `**Status**`, etc.).
- **Wrong Headings**: Uses `## Module Purpose` instead of `## Purpose`, and `## Files` instead of `## Source Files`.
- **Forbidden Sections**: Contains a `## Key Types` section. According to the `module-audit` skill, this belongs *only* in `docs/specs/graph.md` and strictly does not belong in `AGENT.md`.
- **Missing Required Link**: Lacks the `## Full Specification` section linking to `docs/specs/graph.md`.

## 3. Code Documentation (PASS)
- Public items are documented.
- No placeholder stub text like `"Consult the module-level documentation..."` was detected.

## 4. Thin Wrapper Rule (PASS)
- No `mlua` imports were found in the domain module.

## Remediation Steps
1. **Fix Architectural Violations**:
   - Remove the dependency on `crate::runtime::log_messages`.
   - Re-evaluate `src/graph/render.rs`. Either abstract the render interface or move `render.rs` responsibilities into a visualization system located in `Feature Systems` or `Platform Services` (`render` / `lurek.debug`).
2. **Rewrite `src/graph/AGENT.md`**: Convert to the exact short template format required by `.github/skills/module-audit/SKILL.md`.
