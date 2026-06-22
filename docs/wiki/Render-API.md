<!-- Manual wiki stub kept for audit_module W-05. This is not a full API reference. Prefer GitHub Pages and docs/api/lurek.md for canonical generated API docs. -->

# Render API

`lurek.render` exposes image loading, canvases, text, mesh drawing, shader setup, batching, and draw queue helpers for Lua games, simulations, visual tools, and interactive apps.

This Wiki page is a pointer only. Full signatures, parameters, returns, and examples live in the generated API docs.

Canonical references:

- [`docs/specs/render.md`](../blob/main/docs/specs/render.md)
- [`docs/api/lurek.md`](../blob/main/docs/api/lurek.md)
- [`src/lua_api/render_api.rs`](../blob/main/src/lua_api/render_api.rs)

Current maintenance notes:

- Public Lua names and signatures are intentionally stable.
- Lua boundary errors should use the `lurek.render.<method>` prefix.
- Thin-wrapper policy for this module is enforced by `tools/audit/thin_wrapper_audit.py`.
