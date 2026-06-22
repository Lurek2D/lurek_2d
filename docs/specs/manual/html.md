# html manual spec overlay

## TL;DR

- Runs interactive HTML/CSS documents with input routing, selector queries, and element mutations.

## Summary

- The `html` module is the in-engine document-style UI surface for users who want markup, styles, and DOM-like interaction inside the runtime.
- Parsing, runtime document state, selectors, style resolution, layout, and event routing work together so a project can build menus, tool panels, and overlays with a web-like authoring model.
- Dynamic mutation matters because the module is not only for static documents: scripts can update attributes, styles, and content while still relying on the same layout and event system.
- Input handling, dirty or reflow behavior, and render-command generation make the feature practical as an interactive UI stack instead of a passive HTML parser.
- Style inheritance and selector resolution are especially valuable because document-driven interfaces stay manageable only when broad presentation rules can change without rewriting every element.
- That authoring model is especially appealing for tool panels and content-driven menus.
- It also keeps document structure visible at runtime.
- Read `html` as the module that turns markup and CSS-like data into live engine UI. Rendering shows the result, but `html` owns how the document is parsed, laid out, mutated, and interacted with.

This module primarily collaborates with `color`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
