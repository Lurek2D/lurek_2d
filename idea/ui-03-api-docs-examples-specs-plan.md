# UI Plan 3 of 4: Lua API, Documentation, Examples, Specs, and Docstrings

## Purpose

Turn the corrected UI design into a coherent, teachable public contract. This phase removes misleading compatibility surfaces, makes examples behaviorally useful, repairs generated/source documentation drift, and ensures the module specification describes the implementation rather than aspirational behavior.

## Evidence that coverage percentages are not sufficient

- Unit and spec tools report 507 UI APIs with 100% marker ownership.
- Example tooling also reports 507 full examples and no gaps.
- `audit_module.py ui` reports only 112 bound functions, showing that audit tools do not share one canonical inventory for namespace functions, userdata methods, generated variants, and aliases.
- Several public methods are callable but inert (`attachToEntity`, `setSectionWidget`, toolbar separator/spacer operations), so marker coverage can conceal missing behavior.
- The module audit reports structured documentation gaps for more than 80 UI types even though broad doc coverage reports pass.
- The strict file-doc audit fails 5 of 19 UI files: `controls.rs`, `render.rs`, `context/input.rs`, `layout_loader.rs`, and `context/builders.rs`.
- Many existing file doc blocks are generic ownership boilerplate rather than concrete navigation and boundary documentation.

## P0 — Define one canonical UI API inventory

- Make the generator/registry that produces the public Lua API model the sole inventory source for:
  - `lurek.ui` namespace functions;
  - widget userdata/table methods;
  - properties/constants/events;
  - compatibility aliases and their canonical target;
  - generated overload or variant names.
- Give every entry a stable machine ID, public Lua name, owner module, kind, source registration location, lifecycle state (`stable`, `experimental`, `deprecated`, `removed`), and canonical/alias relationship.
- Change API, test, example, spec, and doc audits to consume that inventory. A count mismatch must fail the gate before reporting a coverage percentage.
- Add self-tests with fixtures containing namespace functions, userdata methods, overloads, duplicate names on different types, aliases, and removed entries.
- Treat any manual `tbl.set` count as a diagnostic only, not the coverage denominator.

## P0 — Redesign the widget-handle public contract

Document and expose the generational handle work from UI Plan 1 consistently:

- Public widget objects are opaque typed values, not arbitrary tables authenticated by `_idx`.
- Every method documents stale, released, foreign-context, and wrong-type errors.
- `destroy`, recursive cleanup, `isValid`, `clear`, callback removal, and destruction-during-callback semantics are explicit.
- Child/focus/modal/tooltip/docking APIs accept widget objects, not public numeric indexes.
- Diagnostic tree snapshots may include stable printable IDs, but those IDs are not accepted as mutation authority.
- Compatibility forms have exact deprecation wording, migration examples, and a removal milestone.

Update examples and tests in the same change; do not document new behavior before it exists.

## P0 — Normalize naming, signatures, and error semantics

- Inventory functions that accept the same concept in different shapes: widget object versus numeric index, `(width, height, path)` versus `(path, width, height)`, `loadLayoutFile` versus `loadLayoutGameFile`, and one-based versus zero-based collection indexes.
- Select one canonical form per concept. Recommended conventions:
  - widget references are typed objects;
  - Lua collection positions are one-based;
  - dimensions precede optional configuration, while output destinations use an explicit options table;
  - GameFS-backed load names omit redundant `Game` wording after migration.
- Add explicit options tables when optional positional arguments are already ambiguous; reject unknown keys to catch typos.
- Standardize error categories and messages for invalid argument type/range, limit exceeded, stale handle, wrong widget kind, path-policy rejection, callback failure, and unsupported feature.
- Return diagnostics/results only where recovery is meaningful; avoid silently ignoring invalid section indexes or widget types.
- Never document clamping if the implementation rejects, or rejection if it clamps.

## P0 — Repair the UI module spec

Update the source spec under `docs/specs` and regenerate its derived sections. Required content:

- Replace the inaccurate “arena/stable identity” claim until the generational store is implemented; after implementation, name the actual identity and invalidation rules.
- State the root lifetime and `clear` semantics.
- Specify tree invariants, ownership/reparenting, cycle rejection, destruction, callbacks, event ordering, and reentrancy.
- Include `UiLimits`, rejection behavior, cumulative accounting, and trusted configuration boundary.
- Specify GameFS reads and authorized output writes.
- Document layout transactions and rollback.
- Define widget layout versus top-level generic `layout` module ownership.
- Define UI-to-render lowering, software capture delegation, input event consumption, font/image handles, entity anchor snapshots, and data virtualization adapters.
- Add architecture links to the render pipeline, input routing, scripting boundary, file/security policy, and relevant lifecycle documents.
- Describe feature status honestly; no “future” or inert field should look implemented.

Run the spec generator/checker and edit source regions only. Do not hand-edit generated markers.

## P1 — Rewrite qualitative Rust and Lua documentation

### File-level `//!` documentation

- Fix the five currently failing files to the exact repository length/line rules.
- Review all other UI files even if the mechanical audit passes. Replace generic boilerplate with concrete statements covering:
  - delivered behavior and algorithms;
  - owned state/caches and key invariants;
  - public/crate-local entry points;
  - neighboring modules and data direction;
  - what the file intentionally does not own;
  - a useful navigation hint for large files.
- When files are split by UI Plan 2, write the final docs after the split and rerun the exact audit.

### Rust item docs

- Add `# Errors`, `# Panics`, `# Safety`, and `# Performance` sections where behavior warrants them.
- Document fields/variants for the 80+ types flagged by the module audit, prioritizing handles, events, widget enums, layout definitions, callbacks, dirty generations, limits, and diagnostics.
- Explain units and coordinate spaces for geometry, resolution, DPI, time, color, opacity, scroll, and animation.
- Replace claims such as “owns subsystem” with observable contracts.

### Lua docstrings

- Keep the marker grammar intact while adding lifecycle, units, defaults, limits, side effects, return/error behavior, callback timing, and deprecation details.
- Cross-link canonical alternatives for aliases.
- Make every widget-reference parameter typed as the public handle rather than `integer` or generic `table` once migration lands.
- Add examples of error recovery only where the API actually returns recoverable status.

## P1 — Replace checkbox examples with semantic examples

Retain one exact example marker per canonical API entry, but improve the body quality:

- Constructors create the smallest valid context and visibly use the result.
- Setters are paired with a getter, layout result, event, render command, or screenshot assertion that demonstrates the effect.
- Lifecycle examples show `destroy`, invalid handles, callback removal, and `clear` safely.
- Layout-loading examples use GameFS and show diagnostics/rollback for invalid input.
- Input examples demonstrate propagation/consumption, focus, capture, modal behavior, and deterministic callbacks.
- Complex widgets show actual selection, expansion, editing, scrolling, and section content rather than `tostring` or callability only.
- Virtualized views and entity anchors, if implemented, show the owner-boundary adapter rather than reaching into data/ECS internals.
- Deprecated aliases contain a short migration example and no independent feature story.

Keep examples deterministic, headless where possible, and free of top-level side effects. Group related behavior in the prose around marker blocks without violating the exact-ownership parser.

## P1 — Create narrative documentation journeys

Add or revise public docs so users do not have to infer architecture from 507 reference entries:

1. Build a small retained UI and add it to the root.
2. Understand sizing, layout, coordinates, DPI, clipping, and theme inheritance.
3. Route input, focus, text/IME, modal dialogs, and callbacks.
4. Load and validate declarative layouts with bindings.
5. Manage lifetime, destruction, stale handles, and dynamic rebuilds.
6. Render normally and capture headlessly through the render/image pipeline.
7. Scale lists/tables/trees with virtualization and inspect diagnostics.

Each journey must state module boundaries and link to the canonical font, image, input, render, scene, and data documentation rather than duplicating those APIs.

## P1 — Clarify API deprecations and feature decisions

Prepare an explicit compatibility table for:

- raw `_idx` and numeric child/widget arguments;
- `loadLayoutFile`/`loadLayoutGameFile` naming;
- the two `renderToImage` positional signatures;
- inert features that are implemented or removed;
- any constructors/methods consolidated during the API file split.

For each entry give canonical replacement, warning release, removal release, automated migration if practical, and tests that keep the alias behavior identical until removal.

## P2 — Add docs-as-contract validation

- Verify every documented default and limit against a source constant or generated value.
- Verify every example compiles/runs in the Lua harness, not merely parses.
- Add link checks for UI docs and architecture references.
- Add a stale-symbol audit that rejects removed file names and API names in UI-owned docs.
- Add a qualitative lint for boilerplate file docs and empty/near-empty examples; keep human review for semantic quality.

## Required verification

```text
tools/python.cmd tools/audit/unit_test_api_coverage.py --module ui --json
tools/python.cmd tools/audit/example_coverage.py ui
tools/python.cmd tools/audit/example_lint.py content/examples/ui.lua
tools/python.cmd tools/audit/spec_api_coverage.py --module ui
tools/python.cmd tools/audit/docstring_audit.py src/lua_api/ui_api.rs
tools/python.cmd tools/audit/module_docstring_audit.py --src src/ui --check
tools/python.cmd tools/audit/cag_link_check.py --strict
```

Use the actual CLI syntax supported after the tooling repair. A global link-check failure from unrelated modules must be recorded separately, while UI-owned broken links block this phase.

## Exit criteria

- Every audit reads the same canonical inventory and reports the same UI total.
- All stable APIs have accurate docstrings, behavioral examples, and semantic tests.
- All source files pass mechanical file-doc rules and human qualitative review.
- The UI spec matches implemented lifecycle, limits, filesystem, event, performance, and module-boundary behavior.
- Deprecated and inert surfaces have explicit implementation or removal paths.
- Generated docs are reproducible from source and contain no stale file/API claims.

