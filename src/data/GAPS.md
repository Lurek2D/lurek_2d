# Gap Status: `src/data`

- Reviewed: 2026-04-14
- Baseline: current workspace state on branch `refactor/src-migration-v2`      
- Current status: partially implemented
- Canonical module reference: `docs/specs/data.md`

This refresh treats the current workspace state as the source of truth; older gap-analysis text is historical only.

## Open items
- `src/data/toml_convert.rs` still blurs the boundary between `data` and `serial`.
- The `LuaDataView` / data-view boundary remains a live layering concern and should be tracked from `docs/specs/data.md`, not from the superseded legacy audit text.

## Resolved or stale legacy items
- Stale: AGENT-era rewrite asks are obsolete because canonical module guidance now lives in `docs/specs/data.md`.
- Resolved: the legacy file overstated the module as broadly blocked; the current baseline shows a working module with a narrower cleanup list.
- Superseded: use this status snapshot, not the pre-refresh prose, as the repository truth baseline.

## Evidence
- `docs/specs/data.md`
- `src/data/toml_convert.rs`
- `src/data/dataview.rs`
- `src/lua_api/data_api.rs`
