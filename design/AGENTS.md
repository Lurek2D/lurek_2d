# Design Contract

## Mission & Scope
- Applies to every file under `design/`.
- These files are technical game design references for building Lurek2D games.
- They are not tutorials, examples, snippets, or playable content.

## Files
- `README.md`: category index, shared assumptions, and cross-cutting architecture conventions.
- `<category>/<design>.md`: one technical game design document for one marketable 2D game type.
- `AGENTS.md`: local contract for this folder.

## Content Rules
- Do not include Lua code or pseudocode blocks.
- Write technical architecture: systems, state ownership, data flow, project structure, vertical slice, risks, and validation.
- Reference exact Lurek2D API namespaces such as `lurek.render`, `lurek.input`, `lurek.physics`, `lurek.ui`, `lurek.audio`, `lurek.scene`, `lurek.ecs`, `lurek.tilemap`, `lurek.tilefield`, `lurek.pathfind`, `lurek.ai`, `lurek.save`, `lurek.serialize`, `lurek.filesystem`, `lurek.dataframe`, `lurek.province`, and `lurek.minimap`.
- Explain why each API or module belongs in the design.
- Keep designs realistic for the 2D runtime. Do not target 3D-first, MMO-scale, cloud-service, or engine-editor products here.
- Use market references from Steam and itch.io as design anchors, not clone targets.

## File Shape
- Each design document should include:
  - `Design target`
  - `Market positioning`
  - `Lurek2D API map`
  - `Runtime architecture`
  - `Suggested project structure`
  - `Data and content model`
  - `Technical design notes`
  - `Vertical slice acceptance`
  - `Risks`
- Category folders should group game types that share architecture needs.
- New categories should be added to `design/README.md`.

## Workflow
- Read this file before editing design documents.
- Use RAG or existing docs to verify exact Lurek2D API namespaces before naming them.
- When adding a category, add one useful design document and update `README.md`.
- For contract changes, run `tools/python.cmd tools/validate/cag_validate.py` and `tools/python.cmd tools/audit/cag_link_check.py --strict`.

## Style
- Use short English prose and tables.
- Prefer concrete module responsibilities over generic genre advice.
- Keep file paths forward-slashed in examples.
- Keep scope useful for developers targeting itch.io prototypes and Steam-ready small commercial games.
