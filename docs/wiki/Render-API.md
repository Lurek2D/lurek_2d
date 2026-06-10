<!-- Manual wiki stub kept for audit_module W-05. Prefer docs/specs/render.md and docs/api/lurek.md for canonical generated reference. -->

# Render API

`lurek.render` exposes image loading, canvases, text, mesh drawing, shader setup, batching, and low-level draw queue helpers for Lua games.

Canonical references:

- [`docs/specs/render.md`](/c:/Users/tombl/Documents/lurek_2D/docs/specs/render.md)
- [`docs/api/lurek.md`](/c:/Users/tombl/Documents/lurek_2D/docs/api/lurek.md)
- [`src/lua_api/render_api.rs`](/c:/Users/tombl/Documents/lurek_2D/src/lua_api/render_api.rs)

Current maintenance notes:

- Public Lua names and signatures are intentionally stable.
- Lua boundary errors should use the `lurek.render.<method>` prefix.
- Thin-wrapper policy for this module is enforced by `tools/audit/thin_wrapper_audit.py`.
