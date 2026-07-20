---
name: create-layout
description: "Load this skill when creating or modifying TOML UI layouts under content/layouts and producing visual/evidence validation. Skip it for HTML UI, engine renderer internals, or non-layout Lua examples."
---

# create-layout

## Mission
- Create or modify layout assets that follow current content rules and visual evidence expectations.

## Domain Knowledge
- Layout TOML under `content/layouts/apps` and `content/layouts/games` is deserialized by the engine UI system; valid TOML can still fail when keys or hierarchies are unsupported.
- Responsive relationships belong in parent/child flow, alignment, wrapping, and anchors; fixed coordinates are appropriate for deliberate overlays, not as a substitute for container structure.
- Stable `snake_case` IDs are the Lua interaction contract used by `lurek.ui`; renaming an ID is behavior change even if the frame looks identical.
- Visual proof must include content pressure and states—long text, focus, disabled controls, clipping, overlap, z-order, and target dimensions—not only default geometry.
- Snap/fixer tools normalize layout but cannot judge intended grouping, so their diff requires visual review.
- Layout IDs and widget types form a binding surface with game/app Lua; a visual refactor that replaces a component or changes nesting can alter event routing, focus order, and lookup behavior even when IDs remain present.
- Text metrics use the engine's supported bitmap fonts, so line height, wrapping, and intrinsic dimensions must be tested with actual localized or maximum-length content rather than browser/system-font expectations.
- Overlay order and input capture should follow screen semantics: modal layers must block underlying actions, passive HUD layers must not steal focus, and hidden components should not remain interactive through stale bounds.

## Workflow
- Identify the runtime screen and Lua code consuming each widget ID, then sketch container hierarchy and state variants; extend the existing app/game layout when it owns that interaction surface.
- Implement hierarchy before pixel geometry with deserializer-supported fields, preserving consumed IDs and testing representative long labels and dense values instead of placeholders.
- Run the fixer and 8-pixel snap tool, inspect their diffs, then render the owning app/game at target dimensions and exercise focus, disabled, overlay, and resize states.
- Iterate from visual evidence until alignment, clipping, hierarchy, and readability stabilize; retain an artifact that demonstrates the changed screen rather than relying on parse success.
- Trace focus and action order with keyboard/controller-style navigation as well as pointer input, verifying that visual order, tab/focus order, default action, and cancel path agree for menus and dialogs.
- Compare the layout at minimum, target, and expanded dimensions; document any intentionally fixed viewport and ensure flexible containers absorb extra space without stretching icons, breaking aspect ratios, or obscuring world content.

## References
- `contracts: content/AGENTS.md, content/layouts/AGENTS.md, content/examples/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content layouts TOML UI primitives" --profile game --limit 10, tools/python.cmd tools/ui/snap_to_grid.py content/layouts/ --grid 8 --recursive, tools/python.cmd tools/ui/fix_layouts.py content/layouts/ --recursive --fix, tests/lua/evidence/test_ui_evidence.lua`
- `agent: content`
- RAG: `content layouts TOML UI primitives`; `content layouts button label stack`; `hud menu overlay layout`; `content/layouts/`; `content/games/`; `docs/` UI or layout notes; rendering support in `src/`
