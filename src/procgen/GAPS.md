# Gap Analysis: `src/procgen`

## 1. Architecture & Compliance (BLOCKER)
- **Dependency Violation**: The `procgen` module is assigned to the `Foundations` tier. Per the architecture rules (`docs/architecture/engine-architecture.md`), `Foundations` modules are leaf modules and must not import from higher groups (Zen Rule 9).
  - `src/procgen/cellular.rs` and `src/procgen/voronoi.rs` import `crate::runtime::log_messages` (`Core Runtime`).
  - **Severe Violation**: `src/procgen/render.rs` imports `crate::render::renderer::{DrawMode, RenderCommand}` and `crate::image::ImageData` (`Platform Services`). Pure math/generation systems must not depend on graphics endpoints.

## 2. AGENT.md Structure (BLOCKER / ERROR)
The `AGENT.md` file in `src/procgen/` does **not** adhere to the canonical short format required by the CAG rules (A-02).
- **Missing / Incorrect Metadata Table**: Uses a bulleted `## Module Info` list instead of the required markdown table format (with `**Tier**`, `**Status**`, etc.).
- **Wrong Headings**: Uses `## Module Purpose` instead of `## Purpose`, and `## Files` instead of `## Source Files`.
- **Forbidden Sections**: Contains a `## Key Types` section. According to the `module-audit` skill, this belongs *only* in `docs/specs/procgen.md` and strictly does not belong in `AGENT.md`.
- **Missing Required Link**: Lacks the `## Full Specification` section linking to `docs/specs/procgen.md`.

## 3. Code Documentation (PASS)
- Public items are documented.
- No placeholder stub text like `"Consult the module-level documentation..."` was detected.

## 4. Thin Wrapper Rule (PASS)
- No `mlua` imports were found in the domain module.

## Remediation Steps
1. **Fix Architectural Violations**:
   - Remove the dependency on `crate::runtime::log_messages`.
   - Remove `src/procgen/render.rs` from `procgen` or invert control by providing an abstract map output that is converted to commands inside `Platform Services` (`render`).
2. **Rewrite `src/procgen/AGENT.md`**: Convert to the exact short template format required by `.github/skills/module-audit/SKILL.md`. Move the detailed `Key Types` list to `docs/specs/procgen.md`.
