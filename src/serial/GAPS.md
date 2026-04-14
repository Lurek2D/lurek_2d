# Gap Status: `src/serial`

- Reviewed: 2026-04-14
- Baseline: current workspace state on branch `refactor/src-migration-v2`      
- Current status: partially implemented
- Canonical module reference: `docs/specs/serial.md`

This refresh treats the current workspace state as the source of truth; older gap-analysis text is historical only.

## Open items
- `src/serial/lua_table.rs` still raises Lua-boundary ownership concerns for a pure domain module.
- The stale YAML/TOML split remains visible in the current tree and keeps the module short of a clean final state.

## Resolved or stale legacy items
- Stale: AGENT-era rewrite asks are obsolete because canonical module guidance now lives in `docs/specs/serial.md`.
- Resolved: the legacy file's broad blocker framing is too strong for the current workspace baseline.
- Superseded: the live concerns are narrower than the pre-refresh audit text suggested.

## Evidence
- `docs/specs/serial.md`
- `src/serial/lua_table.rs`
- `src/serial/toml.rs`
- `src/lua_api/serial_api.rs`
