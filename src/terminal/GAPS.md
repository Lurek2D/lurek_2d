# Gap Analysis: `src/terminal`

## 1. Architecture & Compliance
- **Dependency Direction**: Review required to ensure no upward imports (e.g., into higher tiers) occur.
- **Thin Wrapper Rule**: Ensure no `mlua` imports exist in this domain module. All Lua bindings must be in `src/lua_api`.

## 2. AGENT.md Structure (BLOCKER / ERROR)
The `AGENT.md` file in this module does **not** adhere to the canonical short format required by the CAG rules (A-02).
- **Missing / Incorrect Metadata Table**: Needs the required markdown table format.
- **Forbidden Sections**: Contains a `## Key Types` section which belongs *only* in `docs/specs/terminal.md`.
- **Missing Required Link**: Lacks the `## Full Specification` section linking to `docs/specs/terminal.md`.

## Remediation Steps
1. **Rewrite `AGENT.md`**: Convert to the exact short format.