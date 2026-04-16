# IDEA.md — `ui` module

> Migrated from `ideas/features/gui.md` + `ideas/performance/21-gui-scene-events.md`.
> Status checked against `src/ui/` and `src/lua_api/ui_api.rs`.
> Lua namespace: `lurek.ui`.

---

## Features

> **NOTE**: The feature analysis file listed tooltips, tab bar, flexbox layout, draggable
> windows, modal dialogs, and themes as missing. All five are already implemented.
> Only data binding and world-space anchoring remain genuinely missing.

---

### ❌ TODO — Drag-and-Drop Between Containers
**Source**: features/gui.md — Feature Gaps #4 / Suggestions #2

Window-level dragging is supported but not drag-and-drop between arbitrary containers.
Required for inventory, card games, crafting interfaces.

```lua
itemSlot:setDraggable(true)
equipSlot:setDropTarget(true, function(item) equip(item) end)
```

---

## Performance

### 🔇 LOW — Retained Widget Tree Diff
**Source**: performance/21-gui-scene-events.md

Widget re-render on every frame even when no widget state changes. A dirty-flag system
that skips retess of unchanged subtrees would reduce CPU time for complex UIs. Low priority
unless profiling shows UI in the hot path.
