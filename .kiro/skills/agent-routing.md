---
inclusion: manual
---

# agent-routing

## Mission
Own exact routing rules and the shared handoff contract. Keep ownership boundaries explicit.

## When To Use
- Routing work between multiple roles or phases.
- Ownership between two or more roles is unclear.
- A handoff packet or acceptance gate needs shaping.

## When To Skip
- Single-role direct implementation where ownership is already explicit.

## Rules

### Routing Authority
Only Manager routes between roles. Specialists return one of three signals:
- DONE — work complete, artifacts ready.
- BLOCKED — need input or a missing resource.
- SCOPE-MISMATCH — task is outside this role's owned surface.

Manager interprets signals; specialists do not re-route to peers.

### Planner First
Route to Planner when work spans 3+ roles, 5+ files, or the phase order is genuinely unclear. Architect gets involved only when the phase plan reveals an architectural decision that must be resolved before implementation can start.

### Artifact Ownership Matrix
- Product Rust code → Developer
- Build/packaging code → Build-Engineer
- `extension/vscode/` → Extension-Engineer
- Lua API design → Lua-Designer
- Runnable Lua content → Content-Maker
- Markdown docs, specs, generated refs → Doc-Writer
- Test cases and coverage → Tester
- Diff review and performance gating → Verifier
- CAG layer (`.github/`) → CAG-Architect
- Architecture decisions → Architect
- Roadmap, backlog, feature scope → Planner

### Handoff Packet Format (5 fields always)
Context, Goal, Inputs, Done When, Return To.

### Acceptance Gate Rule
One phase, one owner, one binary test. "Tests pass and no new Clippy warnings" is valid. "Code looks good" is not.

### Ambiguous Ownership
When two roles could own a task, choose by narrowest artifact class. A Lua test file → Tester, not Developer. A module spec change → Doc-Writer, not Architect.

### Never
- Assign the same work to two roles simultaneously.
- Re-send the same task to a role that returned SCOPE-MISMATCH.

## References
- `.kiro/steering/agent-manager.md`
- `docs/architecture/cag-system.md`
