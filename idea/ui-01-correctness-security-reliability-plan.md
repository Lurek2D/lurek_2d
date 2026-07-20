# UI Plan 1 of 4: Correctness, Security, and Reliability

## Purpose

Make `ui` safe under stale Lua references, hostile or accidental oversized input, callback failure, malformed layouts, and long-running widget churn. This plan is the first UI implementation phase because the later API, performance, and feature work must build on a reliable identity and lifecycle model.

## Confirmed baseline

- The focused Rust baseline passes: `cargo test --test ui_tests` (2 tests).
- `cargo clippy -- -D warnings` passes.
- Lua marker tooling reports 507/507 API owners, but many tests only prove callability and do not establish lifecycle or output semantics.
- `GuiContext` stores widgets in `Vec<WidgetKind>` and exposes raw `usize` indexes through mutable Lua tables containing `_idx`.
- `lurek.ui.clear()` resets the widget vector, so an old `_idx` may name a different widget created later.
- `GuiCallbacks` is keyed by the same raw indexes, while `clear()` does not clear every callback registry. Old callbacks can therefore leak or become associated with a reused index.
- `loadLayoutFile` and `renderToImage` perform direct host filesystem operations. Their policies differ from GameFS-backed APIs.
- Layout loading recursively mutates the live context; a late error can leave partial widgets behind.
- Layout, descendant, tree-view, and rendering walks include recursive paths without a shared depth/work ceiling.

## Required invariants

1. A widget handle identifies exactly one live widget generation and can never silently alias a replacement.
2. Lua cannot forge an authoritative widget identity by constructing a table with an `_idx` field.
3. Destroying or clearing a widget invalidates handles and removes callbacks, events, focus, capture, parent/child links, modal state, and cached render/layout state that refers to it.
4. Any invalid, released, foreign-context, or stale handle returns a stable Lua error and never panics.
5. Public file access uses the repository's canonical GameFS/path-policy boundary; render and UI code do not invent independent path checks.
6. Every Lua-controlled collection, recursion, allocation, string, image dimension, and per-update work queue has a documented ceiling and checked arithmetic.
7. Failed layout construction is atomic: the prior UI remains unchanged.
8. Callback failure follows documented delivery semantics and cannot silently discard unrelated already-queued events.

## P0 — Replace raw widget indexes with generational handles

### Design

- Introduce an opaque `WidgetId` containing a slot and generation, backed by a generational arena/slot map or an equivalent checked store.
- Preserve the distinguished root through an explicit `root_id`; do not rely on numeric slot zero outside the arena implementation.
- Make `WidgetId` the key used by:
  - widget storage and parent/child relationships;
  - focus, hover, pointer capture, modal, drag/drop, tooltip, docking, dialog, menu, and tree references;
  - `GuiEvent` and `GuiCallbacks`;
  - dirty/layout/render caches and diagnostics.
- Bind a typed Lua userdata such as `LUiWidgetHandle` with private context identity and generation. Widget-specific Lua objects may wrap this handle, but a user-created table must not become authoritative.
- Reject a handle from another `GuiContext`, a stale generation, a destroyed widget, or the wrong widget type with stable error wording.
- If table-shaped widget objects must remain compatible, keep `_idx` as read-only diagnostic metadata only. Add a time-bounded compatibility shim that resolves an internal userdata token, emits a deprecation diagnostic, and cannot accept a bare forged table.
- Audit every Lua API parameter currently accepting `usize`, `Option<usize>`, or a table `_idx`; convert it to checked handle resolution before mutation.

### Migration tasks

- Add core operations `get`, `get_mut`, `contains`, `insert`, `remove`, and `clear` around the new store; prohibit direct vector indexing in feature code.
- Convert child lists and widget-owned references in `src/ui/widget.rs`, `src/ui/extras.rs`, `src/ui/controls.rs`, `src/ui/context.rs`, and context submodules.
- Convert the broad raw-index surface in `src/lua_api/ui_api.rs`, including split panes, dock panels, menu bars/items, dialogs, status bars, accordions, tooltips, focus, tree diagnostics, and event callbacks.
- Add one shared Lua extraction helper and remove ad hoc `_idx` reads.
- Assign a migration removal release or date to the compatibility table form. Document it in the spec and public docs.

### Acceptance tests

- A handle retained across `clear()` fails and cannot mutate the first newly-created widget.
- Creating/destroying/recreating the same arena slot does not revive an old handle.
- A Lua table containing a guessed `_idx` is rejected.
- Handles from two UI contexts cannot cross contexts.
- Wrong-type method calls fail without changing the target.
- A randomized create/attach/detach/destroy/clear sequence preserves all tree and handle invariants.

## P0 — Implement complete widget destruction and cleanup

- Add an explicit `destroy(widget[, recursive])` or widget `:destroy()` API. Choose recursive subtree removal as the default only if the spec makes that unambiguous; otherwise require an explicit policy.
- Centralize cleanup in one core transaction. It must:
  - remove parent and child links;
  - invalidate the handle generation;
  - unregister all callback registry keys and Lua registry values;
  - remove pending events targeting removed widgets;
  - release focus, hover, pointer capture, drag/drop, modal, popup, tooltip, and docking references;
  - invalidate layout/render/text/hit-test caches;
  - remove entity attachments and data/view adapter state.
- Make `clear()` call the same cleanup path for all non-root widgets and rebuild a fresh root generation.
- Define behavior for destroying a widget during its own callback. Prefer queuing destruction until callback dispatch reaches a safe boundary, while immediately marking the handle unavailable to subsequent API calls.
- Expose `isValid()` only as a convenience; correctness must never require callers to preflight instead of handling a fallible operation.

## P0 — Establish shared UI input and work limits

Create a single `UiLimits` policy owned by `src/ui`, with defaults documented in the UI spec and overridable only through a trusted engine configuration path. At minimum cover:

- total live widgets and children per widget;
- maximum tree/layout depth;
- maximum layout file bytes, TOML nesting depth, table entries, bindings, diagnostics, list/table/tree rows, and text bytes;
- maximum pending events and callbacks dispatched per update;
- maximum render commands generated per UI frame;
- maximum screenshot width, height, pixel count, encoded bytes, and output path length;
- maximum animation count and normalized `dt`;
- maximum item counts accepted by Lua table conversion helpers.

Implementation rules:

- Validate cumulative totals, not only each individual item.
- Use checked addition/multiplication and `try_reserve`; report which limit was exceeded.
- Reject NaN/infinity and invalid negative geometry, opacity, scale, duration, resolution, and coordinates at the public boundary. Define clamping only for values whose API contract explicitly promises it.
- Apply the same policy to Lua construction and TOML layout loading so one path cannot bypass another.
- Bound event production as well as dispatch. When full, coalesce safe high-frequency events such as pointer movement; never silently discard click/change/close events.

## P0 — Unify filesystem and output security

- Remove direct public-path reads from `lurek.ui.loadLayoutFile`; make GameFS the canonical game-content source. If host-file loading is needed for editor tooling, put it behind a clearly named trusted/tool-only API outside the normal game sandbox.
- Make `loadLayoutGameFile` the canonical behavior and deprecate the duplicate name only after compatibility analysis.
- Split `renderToImage` into in-memory capture and file output:
  - UI lowers widgets to render commands;
  - render software capture replays commands into bounded RGBA bytes;
  - image owns image data and PNG encoding;
  - GameFS or the filesystem owner validates and atomically writes the output.
- Replace `std::fs::write` in `src/ui/layout_loader.rs` with the canonical output service. Prevent traversal, absolute paths, links/reparse-point escapes, device paths, reserved names, and overwrite surprises according to the engine-wide policy.
- Write to a temporary sibling and atomically rename where supported. On failure, leave no truncated destination.
- Add image dimension and encoded-size checks before allocation and before writing.

## P0 — Make layout loading transactional

- Parse and validate TOML into an intermediate `LayoutDef` graph without mutating `GuiContext`.
- Validate unique IDs, supported widget kinds/properties, child references, cycles, maximum depth/counts, binding names/types, numeric finiteness, string sizes, and source-path policy.
- Construct widgets in a temporary arena/context or a transaction journal. Commit only after the complete graph and all bindings are valid.
- If commit fails, return the original context byte-for-byte equivalent in observable state, including focus, callbacks, caches, and pending events.
- Attach diagnostics to source path and TOML key/index. Never expose a partial root as success.
- Add duplicate-ID, cycle, deep-tree, oversized-table, malformed-binding, allocation-limit, and rollback tests.

## P1 — Define reliable callback and event semantics

- Stop draining all pending events before invoking fallible Lua callbacks. Use a bounded queue with a cursor or pop-one dispatch so undelivered events remain accounted for.
- Specify one of these behaviors and test it:
  - fail-fast while retaining the failing and later events for retry; or
  - isolate the failing callback, record a diagnostic, and continue delivery.
- Prevent a permanently failing callback from causing an infinite retry loop; provide failure counts, automatic disable policy, or explicit user removal.
- Define reentrancy: callbacks may enqueue events, create widgets, and request destruction, but may not invalidate the dispatcher’s iteration.
- Ensure callback replacement/removal releases the old Lua registry key.
- Give on-draw callbacks a temporary command transaction. A callback error must not leave an accidental partial command list unless partial submission is explicitly documented.
- Add deterministic ordering guarantees for multiple events and callbacks within one update.

## P1 — Replace unbounded recursion with guarded traversal

- Convert layout, descendant checks, cycle validation, tree-node flattening, and render traversal to iterative stacks where practical.
- Where recursion remains clearer, pass a shared depth budget and return a typed error when exhausted.
- Detect cycles even if internal corruption or future loaders bypass normal `add_child` validation.
- Add adversarial tests at the exact limit and one beyond it. Include a deep tree large enough to demonstrate no stack overflow in release builds.

## P1 — Repair error and invariant handling

- Replace the `unwrap` reported in `src/ui/focus.rs` with a fallible branch or a documented invariant represented by the type system.
- Audit `expect`, unchecked indexing, lossy integer casts, and arithmetic in UI core and Lua conversion paths.
- Add typed internal errors that map consistently to Lua errors and diagnostics; avoid module-specific prose assembled at dozens of call sites.
- Treat invalid state as a recoverable UI error where continued execution is safe. Reserve panic for process-internal impossible states proven by construction.

## P2 — Fuzz and property-test the trust boundaries

- Add Rust fuzz/property targets for TOML layout parsing, Lua table conversion, handle sequences, tree mutations, text/geometry numeric inputs, and software capture dimensions.
- Seed the corpus with stale handles, cross-context handles, duplicate IDs, cycles, NaN/infinity, very large integers, mixed Lua key types, invalid UTF-8 path bytes where supported, and event reentrancy.
- Assert bounded execution, no panic, no partial commit, no leaked callbacks, and preserved tree invariants.

## Files expected to change

- `src/ui/context.rs` and `src/ui/context/*`
- `src/ui/widget.rs`, `src/ui/controls.rs`, `src/ui/extras.rs`, `src/ui/layout_loader.rs`
- `src/lua_api/ui_api.rs`
- the canonical filesystem/GameFS and image/render capture seams, without moving their ownership into UI
- UI Rust/Lua/security/integration tests and the UI module spec

## Exit criteria

- All required invariants above have direct tests.
- No public UI operation trusts a raw `_idx` or unchecked `usize` as identity.
- `clear()` and destruction release every related registry entry and state reference.
- Layout load and image output are bounded, sandboxed, and atomic.
- Callback errors have deterministic, documented delivery behavior.
- Focused Rust, Lua unit, integration, security, and stress suites pass under debug and release profiles.

