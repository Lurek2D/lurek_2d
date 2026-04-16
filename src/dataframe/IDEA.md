# IDEA.md — `dataframe` module

> Migrated from `ideas/features/dataframe.md`.
> Status checked against `src/dataframe/` and `src/lua_api/dataframe_api.rs`.

---

## Features

### ✅ DONE — Pivot Tables
**Source**: features/dataframe.md — Feature Gaps #1

`DataFrame::pivot_table(row_key, col_key, value_key, agg_fn)` added to `src/dataframe/frame.rs`.
`LuaDataFrame:pivotTable(row_key, col_key, value_key, agg?)` added to `src/lua_api/dataframe_api.rs`.
Reshapes long-format data to wide; supported aggregations: `"sum"`, `"mean"`, `"count"`, `"min"`, `"max"`.

```lua
local wide = df:pivotTable("player", "round", "score", "sum")
```

Implemented: 2026-04-18

---

### ✅ DONE — Window Functions (Rolling Average, Running Total, Rank)
**Source**: features/dataframe.md — Feature Gaps #2 / Suggestions #2

Three window-function methods added to `src/dataframe/frame.rs` and `src/lua_api/dataframe_api.rs`:

- `df:rollingMean(col, window, result_col?)` — sliding-window mean
- `df:rollingSum(col, window, result_col?)` — sliding-window running total
- `df:rank(col, order?, result_col?)` — rank column (order: `"asc"` | `"desc"`)

```lua
df:rollingMean("damage", 5)   -- 5-frame rolling average
df:rank("score", "desc")      -- leaderboard rank column
```

Implemented: 2026-04-18

---

### ✅ DONE — Expression-Based Column Creation
**Source**: features/dataframe.md — Feature Gaps #3

`DataFrame::with_eval(col_name, expr)` added to `src/dataframe/frame.rs`.
`LuaDataFrame:withEval(col_name, expr)` added to `src/lua_api/dataframe_api.rs`.
Returns a new `DataFrame` with the computed column appended.
Supports column-name references and numeric literals with `+`, `-`, `*`, `/`.

```lua
local df2 = df:withEval("total", "attack + bonus * 1.5")
```

Implemented: 2026-04-15

---

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
