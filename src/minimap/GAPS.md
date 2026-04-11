# Gap Analysis: `src/minimap`

## 1. Architecture & Compliance
- **Dependency Direction**: Review required to ensure no upward imports.
- **Thin Wrapper Rule**: Ensure no `mlua` imports exist in this domain module.

## 2. AGENT.md Structure (BLOCKER / ERROR)
The `AGENT.md` file in this module does **not** adhere to the canonical short format required by the CAG rules (A-02).
- **Missing / Incorrect Metadata Table**: Needs the required markdown table format.
- **Forbidden Sections**: Contains a `## Key Types` section which belongs *only* in `docs/specs/minimap.md`.
- **Missing Required Link**: Lacks the `## Full Specification` section linking to `docs/specs/minimap.md`.

## Remediation Steps
1. **Rewrite `AGENT.md`**: Convert to the exact short format.