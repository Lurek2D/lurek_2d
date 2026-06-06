# dialog

## General Info

- Module group: `Edge/Integration`
- Source path: `src/dialog/`
- Binding: `src/lua_api/dialog_api.rs`
- Namespace: `lurek.dialog`
- Lua API surface: `3` functions, `3` types, `30` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

This module provides the narrative scripting and conversation logic system, allowing gameplay scripts to choreograph complex dialogues. It handles multi-character conversation graphs, player choices, and conditional narrative gates. Conversations are built as dialogue trees where branches are evaluated and ranked dynamically using utility scoring, ensuring the engine can select contextually appropriate dialogue paths.

To keep dialogue flows organized, the system separates narrative structure from presentation. It features a dedicated speaker registry that maps character IDs to display names, portraits, and audio properties. Additionally, a persistent state tracker maintains the history of visited nodes, active conversation nodes, and custom variable stores. This decouples visual layouts from script logic while ensuring progression stays coherent.

## Files

### [condition.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dialog/condition.rs)

- Provides reusable gate rules that decide whether dialog options are eligible under the current runtime context.
- Encodes state and threshold checks as portable data so narrative gating stays configurable and data-first.
- Supports composable all-or-any logic for layered progression constraints across branching conversations.
- Delivers a deterministic condition engine that keeps availability checks consistent between systems and scripts.

### [events.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dialog/events.rs)

- Defines the dialogue event vocabulary used to publish lifecycle milestones and selection outcomes.
- Carries typed payloads so UI, scripting, and telemetry can react without digging into internal state.
- Delivers a clean event contract that keeps conversation flow observable across integration points.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dialog/mod.rs)

- Provides the high-level dialog module surface that unifies authored conversation flow with runtime progression state.
- Connects speaker identity, gating logic, selection models, and lifecycle events into one coherent interaction layer.
- Delivers a stable module boundary that scripts and systems consume as the canonical dialogue orchestration entry point.

### [speaker.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dialog/speaker.rs)

- Provides canonical speaker identity records used by dialogue flow to resolve who is talking at each step.
- Centralizes speaker lookup in a stable registry keyed by durable identifiers shared across a session.
- Keeps narrative content decoupled from presentation metadata like portraits, voices, and character tags.
- Delivers a single reference layer that makes speaker data consistent for tree logic and runtime state.

### [state.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dialog/state.rs)

- Provides mutable dialogue runtime state that tracks active position, visit history, and per-run variables.
- Supports conversation lifecycle transitions for start, advance, end, and subsequent re-entry handling.
- Preserves continuity data in a compact snapshot that dependent systems can query every frame.
- Delivers the authoritative progression record used to keep branching dialogue behavior coherent over time.

### [tree.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dialog/tree.rs)

- Provides the core dialogue graph model for authored topics, branches, nodes, and selectable progression paths.
- Applies runtime gate filtering so only context-compatible narrative candidates remain available.
- Combines base weights with utility-driven influence to rank candidates and pick strong conversation outcomes.
- Keeps decision flow transparent by storing gating and scoring inputs directly with authored records.
- Serves as the planning backbone executed by dialogue state, scripting hooks, and event publication.
- Delivers data-first branching behavior that stays testable, tunable, and stable across gameplay sessions.
