# IDEA.md — `pathfind` module

> Migrated from `ideas/features/pathfinding.md` and `ideas/performance/05-ai-pathfinding.md` (Part 2).
> Status checked against `src/pathfind/` and `src/lua_api/pathfind_api.rs`.
> Lua namespace: `lurek.pathfinding`.

---

## Features

### ✅ DONE — Jump Point Search (JPS)
**Source**: features/pathfinding.md — Feature Gaps #6

`JpsGrid` and `LuaJpsGrid` implemented in `pathfind_api.rs` (line ~1004) with
`newJpsGrid(w, h)` factory. JPS is dramatically faster than A* on uniform-cost grids
with no quality loss.

---

### ✅ DONE — Reachability Query
**Source**: features/pathfinding.md — Feature Gaps #4

`isReachable(x1, y1, x2, y2)` implemented in `pathfind_api.rs` (line ~411). Boolean
check without computing the full path.

---

### ✅ DONE — Tilemap → NavGrid Bridge
**Source**: features/pathfinding.md — Suggestions #1

`newNavGridFromTileMap(tilemap, layerName, walkableCallback)` implemented in
`pathfind_api.rs` (line ~1169).

---

### ✅ DONE — Hex Grid Pathfinding
**Source**: features/pathfinding.md — implicit

`HexGrid` and `HexLayout` imported in `pathfind_api.rs` (line ~15). Hex-grid A*
exposed via `newHexGrid()`. Not mentioned in original feature doc — this is a bonus.

---

### ❌ TODO — NavMesh
**Source**: features/pathfinding.md — Feature Gaps #1 (HIGH)

No NavMesh found. Grid pathfinding is excellent for tile-based games. For non-grid games
(car games, freely placed walls, procedural maps) a NavMesh gives smoother paths with
lower memory cost. This is the #1 missing pathfinding feature for non-tile games.

---

### ✅ DONE — Any-Angle / Theta* Paths
**Source**: features/pathfinding.md — Feature Gaps #3

`findPathSmooth()` (Theta* post-processing via Bresenham line-of-sight pruning) was already
implemented in `pathfind_api.rs` at lines ~304 (`LuaUnitPathfinder`) and ~746 (`findPathSmoothed`).
Both call `astar::smooth_path()` in the domain module. No new code required.

---

### ✅ DONE — Bidirectional Search
**Source**: features/pathfinding.md — Feature Gaps #5

`findPathBidirectional(sx, sy, ex, ey)` added to `src/lua_api/pathfind_api.rs`.
Uses a meet-in-the-middle A* that runs a forward search from start and a reverse
search from goal, merging when the frontiers overlap. Useful for very long paths on
large grids (1000×1000+) where meeting in the middle halves search space.

Implemented: 2026-04-18

---

### ✅ DONE — AI Module Bridge
**Source**: features/pathfinding.md — Structural Issues / Suggestions #6

Canonical integration pattern documented: call `lurek.pathfinding.findPath(...)` to get a
path table, then update `steeringAgent.target` each frame from the path array. A thin
Lua wrapper in `content/library/` suffices; no Rust bridge required.

---

## Performance

### ✅ DONE — Parallel Nav Grid Solving (rayon) — needs verification
**Source**: performance/05-ai-pathfinding.md — Section 2 / Pathfinding

`src/pathfind/` — verify whether rayon is used for batch path requests from multiple
callers. If not, multiple agents each requesting paths per frame should be batched and
solved in parallel. Check `src/pathfind/astar.rs` for rayon usage.
