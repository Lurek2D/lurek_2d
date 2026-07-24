---
name: create-design
description: "Load this skill when authoring or revising technical game-design references under lurek_2d_content/design. Skip it for engine architecture, playable games, examples, or implementation code."
---

# create-design

## Mission
- Produce a distinct, implementable game-design reference grounded in shipped Lurek2D capabilities.

## Domain Knowledge
- Design files live under `lurek_2d_content/design/<category>/`.
- `lurek_2d_content/design/README.md` is the category index.
- The design contract defines the required section order.
- Design files use English prose and tables.
- Design files do not contain Lua, pseudocode, or fenced code.
- A design cites three to five reference games.
- Each reference needs one useful lesson and one deliberate difference.
- The API map contains 12-25 verified public APIs.
- Each API is Required, Optional, or Feature-gated.
- A missing API is an `Engine gap` with a fallback.
- The design defines at least five saved or authored records.
- The vertical slice defines at least ten observable checks.
- The risk table contains at least four rows.
- The document names the closest design that it does not replace.
- Supported scope is desktop 2D, isometric, or raycast pseudo-3D.
- Runtime state, saved state, authored data, and derived render state have separate owners.
- Lua owns game rules and orchestration; `lurek.*` modules supply runtime services.
- The API map is an ownership boundary, not a checklist of unrelated namespaces.
- `lurek.scene` is the catalog convention for game-mode authority.
- `lurek.ecs` is used only when identity must cross several systems.
- `lurek.event` carries resolved domain facts, not undecided gameplay commands.
- Saves keep stable IDs, schema versions, authored seeds, and player progress; paths, render handles, and caches are rebuilt after load.
- Render, animation, particles, and audio consume committed state and do not decide gameplay truth.

## Workflow
1. Read the design contract and category index.
2. Read the two closest design files.
3. Write one sentence that defines the new boundary.
4. Define the player promise and core loop.
5. Define runtime, saved, authored, and derived state owners.
6. Define scenes and data flow.
7. Define at least five concrete records.
8. Verify every API in generated Lua API docs.
9. Mark each API as Required, Optional, or Feature-gated.
10. Record each missing capability as an Engine gap with a fallback.
11. Write ten or more observable vertical-slice checks.
12. Write four or more concrete risks and mitigations.
13. Keep all required sections in contract order.
14. Update the category index when needed.
15. Run strict workspace link checking.
16. Compare the result with both nearby designs.

## References
- `contracts: lurek_2d_content/AGENTS.md, lurek_2d_content/design/AGENTS.md, docs/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "game design API map state ownership vertical slice" --profile game --limit 10, tools/python.cmd tools/audit/cag_link_check.py --strict --require-workspace`
- `agent: content`
- RAG: `technical game design reference API map state ownership`; inspect `lurek_2d_content/design/`, generated Lua API docs, and specs for named modules.
