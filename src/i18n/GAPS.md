# Gap Analysis: `src/i18n`

## 1. Architecture & Compliance
- **Dependency Direction**: Review required.
- **Thin Wrapper Rule**: Ensure no `mlua` imports exist in this domain module. All Lua bindings must be in `src/lua_api`.

## 2. AGENT.md Structure (BLOCKER / ERROR)
The `AGENT.md` file in this module does **not** adhere to the canonical short format required by the CAG rules (A-02).

## Remediation Steps
1. **Rewrite `AGENT.md`**: Convert to the exact short template format.