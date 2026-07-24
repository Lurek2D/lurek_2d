---
name: create-workbench-feature
description: "Load this skill when creating or modifying native Lua Workbench shell, editor, or project-service behavior under lurek_2d_workbench. Skip it for VS Code extension features, engine internals, or playable games."
---

# create-workbench-feature

## Mission
- Deliver a focused Workbench feature that integrates with the shell without turning the app into a code editor.

## Domain Knowledge
- `lurek_2d_workbench/main.lua` is bootstrap and callback wiring only.
- Shared shell code lives under `lurek_2d_workbench/app/`.
- Visual editor modules live under `lurek_2d_workbench/editors/`.
- Every editor exposes `id`, `title`, `draw`, `update`, `inspect`, and `export`.
- The shell owns editor registration and active selection.
- Project services own project paths and project data.
- Editors do not read another editor's private state.
- Workbench uses public `lurek.*` APIs.
- Workbench does not define a shadow engine API.
- VS Code owns source editing and language features.
- Workbench owns visual editing, inspection, preview, and export.
- Project paths use forward slashes.
- Export output must have stable ordering and format.
- Project reload must not duplicate editor registration.
- Project switches must clear project-specific cached state.
- Editors use `matches_path` to claim supported document suffixes through the shared registry.
- Document editors provide `create_document`, `serialize_document`, and `validate_document` to the document service.
- `build_export` returns a project-relative output path and generated text payload.
- The document service owns save, reload, revert, undo, redo, dirty state, and external-change detection.
- Undo history is document-local and capped at 128 model snapshots.
- A user-selected project is exposed through an explicit writable workspace mount.
- Dirty documents cannot be closed or replaced without an explicit force path.
- Current editor formats include `.particle.toml`, `.tmx`, `.layout.toml`, `.sheet.toml`, `.png`, `.animation.toml`, `.tileset.toml`, and `.audio.toml`.

## Workflow
1. Read the Workbench contract.
2. Trace the action from shell command to editor or project service.
3. Classify each change as bootstrap, shell, editor, or project IO.
4. Keep `main.lua` limited to callback delegation.
5. Put editor state and behavior in the owning editor module.
6. Put shared project access in a project service.
7. Register the editor or command through the shell.
8. Normalize project paths before IO.
9. Define validation and failure behavior before mutation.
10. Keep the previous project usable after a failed load or export.
11. Test editor registration and selection.
12. Test empty and invalid project data.
13. Test project reload and project switch.
14. Run `cargo test --test workbench_smoke_tests`.
15. Run focused Lua integration tests for crossed engine boundaries.
16. Reload exported output with its real consumer.

## References
- `contracts: lurek_2d_workbench/AGENTS.md, tests/AGENTS.md, tests/lua/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lurek Workbench editor shell project service" --profile game --limit 10, cargo test --test workbench_smoke_tests, cargo test --test lua_tests`
- `agent: content`
- RAG: `Lurek Workbench editor shell project service`; inspect `lurek_2d_workbench/app/`, `editors/`, and the focused workbench smoke/integration owner.
