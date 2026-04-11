# Gap Analysis: `src/ai`

## 1. Architecture & Compliance
- **Dependency Direction**: Review required to ensure no upward imports (e.g., into higher tiers) occur.
- **Thin Wrapper Rule**: Ensure no `mlua` imports exist in this domain module. All Lua bindings must be in `src/lua_api`.

## 2. AGENT.md Structure (BLOCKER / ERROR)
The `AGENT.md` file in this module does **not** adhere to the canonical short format required by the CAG rules (A-02).
- **Missing / Incorrect Metadata Table**: Needs the required markdown table format (with `**Tier**`, `**Status**`, etc.).
- **Wrong Headings**: Uses `## Module Purpose` instead of `## Purpose`, and `## Files` instead of `## Source Files`.
- **Forbidden Sections**: Contains a `## Key Types` section which belongs *only* in `docs/specs/ai.md`.
- **Missing Required Link**: Lacks the `## Full Specification` section linking to `docs/specs/ai.md`.

## 3. Code Documentation
- **Stubs**: Check for placeholder stub text like `"Consult the module-level documentation..."` and replace with meaningful descriptions.

## Remediation Steps
1. **Rewrite `AGENT.md`**: Convert to the exact short template format.
2. **Audit Imports**: Remove any `mlua` or upward architecture tier imports.