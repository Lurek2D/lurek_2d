---
trigger: model_decision
description: "Load this skill when routing work between CAG agents, choosing ownership, or shaping Manager handoffs. Skip it for single-agent mode or direct work inside one already-chosen owner."
---

# agent-routing

## Mission
- Own exact routing rules for Manager and the shared handoff contract.
- Keep ownership boundaries explicit across agents.
- Remove duplicated routing prose from agent files.

## When To Load
- Manager handles any multi-agent, unclear-ownership, or phase-splitting task.
- Ownership between two or more agents is unclear.
- A handoff packet or acceptance gate needs shaping.
- CAG edits change the agent graph, ownership map, or routing heuristics.

## When To Skip
- Single-agent mode.
- Direct implementation inside one already-chosen agent.
- Pure code, content, docs, or test work when ownership is already explicit.

## Domain Knowledge
- Routing authority: only Manager routes between agents. Specialists return one of three signals: DONE (work complete, artifacts ready), BLOCKED (need input or a missing resource), SCOPE-MISMATCH (task is outside this agent's owned surface). Manager interprets signals; specialists do not re-route to peers.
- Single-specialist mode: when a request clearly maps to one agent with no handoff needed, Manager assigns and waits for DONE. No routing overhead is needed for single-owner tasks.
- Planner first: route to Planner when work spans 3+ agents, 5+ files, or the phase order is genuinely unclear. Planner returns a phase plan with each phase having one owner and one Done-When gate. Architect gets involved only when the phase plan reveals an architectural decision (module boundary, dependency direction, API shape) that must be resolved before implementation can start.
- Artifact ownership matrix for routing decisions:
  - Product Rust code â†’ Developer (cross-surface) or Build-Engineer (build/packaging) or Extension-Engineer (extension/vscode/)
  - Lua API design â†’ Lua-Designer
  - Runnable Lua content â†’ Content-Maker
  - Markdown docs, specs, generated refs â†’ Doc-Writer
  - Test cases and coverage â†’ Tester
  - Diff review and performance gating â†’ Verifier
  - CAG layer (.github/) â†’ CAG-Architect
  - Architecture decisions â†’ Architect
  - Roadmap, backlog, feature scope â†’ Planner
- Handoff packet format (5 fields, always all 5): Context (what led here), Goal (one sentence), Inputs (file list or artifact refs), Done When (binary acceptance gate), Return To (Manager or upstream agent).
- Acceptance gate rule: one phase, one owner, one binary test. "Tests pass and no new Clippy warnings" is a valid gate. "Code looks good" is not.
- Ambiguous ownership resolution: when two agents could own a task, choose by narrowest artifact class. A Lua test file â†’ Tester, not Developer. A module spec change â†’ Doc-Writer, not Architect. A generated doc â†’ Doc-Writer, not whoever wrote the source docstring.
- Never assign the same work to two agents simultaneously. If parallel work is needed (e.g., Tester writing tests while Developer fixes a bug), they must operate on non-overlapping files with explicit merge instructions from Manager.
- Scope-mismatch escalation: when a specialist returns SCOPE-MISMATCH, Manager re-evaluates routing, does not re-send the same task to the same specialist.

## Companion File Index
- .github/agents/README.md
- docs/architecture/cag-system.md


## Gemini Tips (Antigravity Optimization)
- **Token Efficiency**: Load this skill selectively. Do not copy long code snippets when reference paths or outline will suffice.
- **Tool Usage**: Prefer specific IDE tools (`view_file`, `grep_search`, `multi_replace_file_content`) over bash commands where possible for faster, structured execution.
- **Context Limit**: Focus strictly on the required modules specified in constraints. Do not read unrelated codebase parts.

## References
- .github/copilot-instructions.md
- .github/agents/README.md
- docs/architecture/cag-system.md
- .github/agents/manager.agent.md

