<!-- Manual wiki stub kept for audit_module W-05. This is not a full API reference. Prefer GitHub Pages and docs/api/lurek.md for canonical generated API docs. -->

# Physics API

`lurek.physics` exposes worlds, bodies, joints, fixtures, terrain sync, spatial queries, trigger zones, debug rendering, and physics diagnostics for Lua games and simulations.

This Wiki page is a pointer only. Full signatures, parameters, returns, and examples live in the generated API docs.

Canonical references:

- [`docs/specs/physics.md`](../blob/main/docs/specs/physics.md)
- [`docs/api/lurek.md`](../blob/main/docs/api/lurek.md)
- [`src/lua_api/physics_api.rs`](../blob/main/src/lua_api/physics_api.rs)

Current maintenance notes:

- Public Lua names and signatures are intentionally stable.
- Lua boundary errors should use the `lurek.physics.<method>` prefix.
- Thin-wrapper policy for this module is enforced by `tools/audit/thin_wrapper_audit.py`.
