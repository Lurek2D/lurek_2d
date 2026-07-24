---
name: create-layout
description: "Load this skill when creating or modifying TOML UI layouts under content/layouts and producing visual/evidence validation. Skip it for HTML UI, engine renderer internals, or non-layout Lua examples."
---

# create-layout

## Mission
- Create or modify layout assets that follow current content rules and visual evidence expectations.

## Domain Knowledge
- TOML layouts live under `content/layouts/apps/` and `content/layouts/games/`.
- The engine UI deserializer defines supported keys and hierarchy.
- Valid TOML may still contain unsupported UI fields.
- Component IDs are unique per file.
- Component IDs use `snake_case`.
- Lua code uses component IDs as an interaction contract.
- Renaming an ID is a behavior change.
- Geometry uses `w` and `h`.
- `width` and `height` are not valid layout geometry keys.
- Coordinates snap to an 8-pixel grid.
- TOML layout text accepts bitmap font sizes 8, 10, 12, 16, 20, 24, and 30.
- Flex direction, wrapping, and alignment are preferred over fixed offsets.
- Modal layouts block input to covered content.
- Hidden components must not keep active hit bounds.
- Visual evidence covers focus, disabled, clipping, overlap, and z-order states.
- Long text and dense values are required content-pressure cases.
- `snap_to_grid.py` changes only `x`, `y`, `w`, and `h`; it leaves gameplay values such as `min`, `max`, and `depth` unchanged.
- Grid snapping keeps `w` and `h` at least one grid unit, so a widget cannot collapse to zero size.
- `fix_layouts.py` rejects widget types outside its engine-backed allowlist.
- The fixer removes `widget_type = "separator"` blocks because separators are not supported layout widgets.
- Overlap checks compare siblings at the same parent level; full containment is treated as intentional layering.
- Scroll bounds come from content size minus the computed viewport and clamp to non-negative values.

## Workflow
1. Read the layout contract.
2. Find the owning app or game screen.
3. Find every Lua consumer of changed component IDs.
4. List required states and target dimensions.
5. Build the parent and child hierarchy first.
6. Use only deserializer-supported fields.
7. Preserve existing consumed IDs unless behavior changes.
8. Add representative long text and dense values.
9. Run `fix_layouts.py`.
10. Run `snap_to_grid.py` with grid 8.
11. Inspect both tool diffs.
12. Render minimum, target, and expanded dimensions.
13. Test pointer and keyboard or controller focus order.
14. Test disabled, hidden, modal, and overlay states.
15. Check clipping, overlap, z-order, and readability.
16. Save visual evidence for the changed screen.

## References
- `contracts: content/AGENTS.md, content/layouts/AGENTS.md, content/examples/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content layouts TOML UI primitives" --profile game --limit 10, tools/python.cmd tools/ui/snap_to_grid.py content/layouts/ --grid 8 --recursive, tools/python.cmd tools/ui/fix_layouts.py content/layouts/ --recursive --fix, tests/lua/evidence/test_ui_evidence.lua`
- `agent: content`
- RAG: `content layouts TOML UI primitives <screen>`; inspect the owning layout, Lua ID consumers, deserializer fields, and relevant UI evidence.
