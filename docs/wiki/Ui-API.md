# UI API

This page is a module-level pointer for the retained-mode UI API.

Primary references:
- docs/specs/ui.md
- docs/api/lurek.md (search for `lurek.ui`)
- content/examples/ui.lua

## Scope

The UI module provides a retained widget tree with layout, input routing, focus control, theming, and image-render fallback.

## Key Areas

- Widget creation: buttons, labels, inputs, containers, advanced widgets.
- Layout and hierarchy: parent-child composition, z-order, computed_rect rendering.
- Interaction: mouse filters, focus traversal, directional focus neighbors.
- Styling: state-driven theme styles and semantic style tokens.
- Rendering: command emission and headless `renderToImage` path.
