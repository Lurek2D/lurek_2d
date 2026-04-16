# IDEA.md — `ai` module

> Migrated from `ideas/features/ai.md` and `ideas/performance/05-ai-pathfinding.md` (Part 1).
> Status checked against `src/ai/` file list and `src/lua_api/ai_api.rs`.

---

## Features

### ❌ TODO — NavMesh Integration for Steering
**Source**: features/ai.md — Feature Gaps #2 / Suggestions #2

Steering behaviors and pathfinding are separate systems. Agents should be able to query the
NavMesh (or nav-grid) for walkable areas during steering.

Suggested API:
```lua
steeringAgent:setPath(navGrid:findPath(start, end))
```

No implementation found in `ai_api.rs` or `src/ai/`.

---

### ❌ TODO — Dialogue AI Integration
**Source**: features/ai.md — Feature Gaps #8

AI module has no bridge to the dialogue system. NPC conversation decisions (which topic to
raise, which branch to choose) should be driveable from FSM/BT/Utility AI.

No implementation found. Requires design alignment with `dialog` library module.

---

### 🤔 CONSIDER — Sub-Namespace the Lua API
**Source**: features/ai.md — Suggestions #4

The `lurek.ai` table currently contains 50+ functions in a flat namespace. Consider grouping:
- `lurek.ai.fsm.*`
- `lurek.ai.bt.*`
- `lurek.ai.goap.*`
- `lurek.ai.steering.*`
- `lurek.ai.utility.*`

This is a **breaking API change** — needs sign-off from Lua-Designer and MAJOR version bump.

---

### 🤔 CONSIDER — Config-gate Q-Learning as Optional
**Source**: features/ai.md — Structural Issues

Q-Learning is the most niche AI paradigm. Consider toggling it via `ModulesConfig` or moving
the RL subsystem (`qlearner.rs`, `bandit.rs`, `neural_net.rs`, `neuroevolution.rs`, `genetic.rs`)
into an optional feature group.

---

## Performance

### ❌ DEFERRED — GOAP Parallel Planning (rayon / Lua thread workers)
**Source**: performance/05-ai-pathfinding.md — Section 1 / GOAP

Rayon parallel planning is out-of-scope for Foundation tier. Option B (Lua thread workers
via `lurek.thread.new()`) is the documented pattern — no Rust change required.

---

### ❌ DEFERRED — Parallel Steering Force Computation (rayon)
**Source**: performance/05-ai-pathfinding.md — Section 3 / Steering

After the spatial-hash landing (✅ now done), per-agent steering calculations are independent.
rayon parallel iteration would reduce to O(n / cores). Deferred until profiling confirms need.

---

### 🔇 LOW — Utility AI Parallel Scoring
**Source**: performance/05-ai-pathfinding.md — Section 4 / Utility AI

Each agent evaluates 10–100 action/consideration pairs. Too little work per agent to benefit
from rayon overhead <100 agents. Defer until profiling shows it as a hot path.
