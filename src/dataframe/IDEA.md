# IDEA.md — `dataframe` module

> Migrated from `ideas/features/dataframe.md`.
> Status checked against `src/dataframe/` and `src/lua_api/dataframe_api.rs`.

---

## Features

### ❌ TODO — SQLite Import
**Source**: features/dataframe.md — Feature Gaps #5 / Suggestions #3

No `fromSQLite(path, query)` found. SQLite is a common format for game balance data and
modder-supplied databases.

---

### ❌ TODO — Visualization / Chart Output
**Source**: features/dataframe.md — Feature Gaps #4 / Suggestions #5

No `df:plot()` or chart rendering. A minimal bar/line chart for debug overlays would make
the module far more practical for game developers.

---

### 🤔 CONSIDER — Move to Tier 3 Pure-Lua Library
**Source**: features/dataframe.md — Structural Issues / Suggestions #1

The DataFrame use case (leaderboard analysis, balance tuning, event logs) is valid but niche
for a 2D game engine. A pure-Lua implementation in `content/library/` with `lurek.codec`
for CSV and `lurek.compute` for numerics could serve the same audience without engine-level
Rust overhead. Requires Architect decision.
