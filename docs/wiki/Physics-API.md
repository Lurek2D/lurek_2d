<!-- Manual wiki stub kept for audit_module W-05. Prefer docs/specs/physics.md and docs/api/lurek.md for canonical generated reference. -->

# Physics API

`lurek.physics` exposes worlds, bodies, joints, fixtures, terrain sync, spatial queries, trigger zones, debug rendering, and physics diagnostics for Lua games.

Canonical references:

- [`docs/specs/physics.md`](/c:/Users/tombl/Documents/lurek_2D/docs/specs/physics.md)
- [`docs/api/lurek.md`](/c:/Users/tombl/Documents/lurek_2D/docs/api/lurek.md)
- [`src/lua_api/physics_api.rs`](/c:/Users/tombl/Documents/lurek_2D/src/lua_api/physics_api.rs)

Current maintenance notes:

- Public Lua names and signatures are intentionally stable.
- Lua boundary errors should use the `lurek.physics.<method>` prefix.
- Thin-wrapper policy for this module is enforced by `tools/audit/thin_wrapper_audit.py`.
