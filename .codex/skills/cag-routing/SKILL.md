---
name: cag-routing
description: "Load this skill when routing work between CAG agents, choosing ownership, or shaping Manager handoffs. Skip it for single-agent mode or direct work inside one already-chosen owner."
---
# cag-routing

## Use when
- Manager handles any multi-agent, unclear-ownership, or phase-splitting task.
- Ownership between two or more agents is unclear.
- A handoff packet or acceptance gate needs shaping.
- CAG edits change the agent graph, ownership map, or routing heuristics.

## Avoid when
- Single-agent mode.
- Direct implementation inside one already-chosen agent.
- Pure code, content, docs, or test work when ownership is already explicit.

## Repo rules
- Routing authority: only Manager routes between agents. Specialists return one of three signals: DONE, BLOCKED, SCOPE-MISMATCH.
- Read-only consultation: if a specialist only needs a convention check or signature clarification, Manager may broker a short question-only consultation without changing ownership. No files move, no phase handoff is created, and the consulted agent returns guidance only.
- Single-specialist mode: when a request clearly maps to one agent with no handoff needed, Manager assigns and waits for DONE. No routing overhead is needed for single-owner tasks.
- Planner first: route to Planner when work spans 3+ agents, 5+ files, or the phase order is genuinely unclear. Planner returns a phase plan with each phase having one owner and one Done-When gate.
- Artifact ownership matrix for routing decisions:
- Product Rust code Ă˘â€ â€™ Developer or Build-Engineer or Extension-Engineer
- Lua API design Ă˘â€ â€™ Lua-Designer
- Runnable Lua content Ă˘â€ â€™ Content-Maker
- Markdown docs, specs, generated refs Ă˘â€ â€™ Doc-Writer
- Test cases and coverage Ă˘â€ â€™ Tester
- Diff review and performance gating Ă˘â€ â€™ Verifier
- CAG layer (.github/) Ă˘â€ â€™ CAG-Architect
- Architecture decisions Ă˘â€ â€™ Architect
- Roadmap, backlog, feature scope Ă˘â€ â€™ Planner
- Handoff packet format: Context, Goal, Inputs, Done When, Return To.
- Acceptance gate rule: one phase, one owner, one binary test. "Tests pass and no new Clippy warnings" is a valid gate.
- Ambiguous ownership resolution: when two agents could own a task, choose by narrowest artifact class. A Lua test file Ă˘â€ â€™ Tester, not Developer.
- Never assign the same work to two agents simultaneously. If parallel work is needed, they must operate on non-overlapping files with explicit merge instructions from Manager.
- Scope-mismatch escalation: when a specialist returns SCOPE-MISMATCH, Manager re-evaluates routing, does not re-send the same task to the same specialist.

## Checks
- `Run the narrowest relevant validation for the touched files or workflow.`

## References
- `.github/copilot-instructions.md`
- `docs/architecture/cag-system.md`
- `.github/agents/manager.agent.md`

