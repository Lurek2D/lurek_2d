# Digital Twin Block Simulator - architektura dla Lurek2D

Ten dokument zbiera tylko wysokowartosciowe decyzje z rootowych plikow `ideas/simulation/*.md`. Celem jest wersja zgodna z Lurek2D: runtime desktop, Lua jako warstwa scenariuszy, TOML jako dane, Rust jako deterministyczny rdzen symulacji.

## Decyzja glowna

Produkcyjna wersja nie powinna byc czystym portem Lua ani rozszerzeniem `src/graph`. Docelowy ksztalt to nowy modul `src/blocksim/` z cienkim bindingiem `lurek.sim.*` i biblioteka pomocnicza `library/blocksim/`.

```text
External tools / dashboards
  consume JSON, CSV, JSONL, debugbridge events

library/blocksim/
  pure Lua DSL, blueprints, scenario orchestration, reports
  uses public lurek.* only

src/lua_api/blocksim_api.rs
  thin Lua bridge for lurek.sim.*
  converts Lua tables to Rust types and back

src/blocksim/
  headless Rust simulation kernel
  owns tick loop, queues, ports, monitors, anomalies, approvals, DLQ, replay
```

Use name `blocksim` for files and module internals. The public Lua table can still be `lurek.sim`, because that is the ergonomic scripting surface.

## Why not pure Lua only

Lua is good for authoring scenarios, prototypes, reports, and dashboards. It is not the right place for the hot tick loop once the graph is large.

A pure Lua prototype is useful only as a spike. The production kernel should move these parts to Rust:

- item queues and capacity checks,
- deterministic tick loop,
- typed port and edge validation,
- monitor sampling,
- event log,
- anomaly lifecycle,
- approval queue,
- DLQ and replay,
- checkpoint and deterministic restore.

Lua must not be called for every item movement in the production path. If Lua customization is needed, it should happen between `lurek.sim.step(...)` calls or as batched post-processing.

## Why not extend `src/graph`

`src/graph` can remain a conceptual reference and a prototype helper, but `src/blocksim` must not depend on it.

Reasons:

- `src/graph` is already Tier 2, and another Tier 2 module must not import it.
- `src/graph` is a general directed graph utility, not a digital twin kernel.
- Block simulation needs typed port schemas, composite flattening, anomaly targeting, approval queues, DLQ, monitor streams, checkpointing, and deterministic replay.
- Adding those concerns to `src/graph` would make both modules unclear.

If topological sort or cycle detection is needed, either implement it locally in `src/blocksim/compiler.rs` or promote a small generic algorithm to a lower tier such as `src/math/` after architecture review.

## Tier placement

| Component | Location | Tier | Rule |
|---|---|---|---|
| Rust simulation kernel | `src/blocksim/` | Tier 2 | imports Baseline + Tier 1 only |
| Lua bridge | `src/lua_api/blocksim_api.rs` | Bridge | imports `src/blocksim/`; no business logic |
| Lua helper library | `library/blocksim/` | Tier 3 | public `lurek.*` APIs only |
| Demo/tool app | `content/games/block_sim/` | Content | uses `library/blocksim` + `lurek.sim` |
| Tests, Rust | `tests/rust/unit/blocksim_tests.rs` | Test | kernel behavior |
| Tests, Lua API | `tests/lua/unit/test_blocksim.lua` | Test | public `lurek.sim.*` behavior |
| Tests, Lua library | `tests/lua/library/test_blocksim_lib.lua` | Test | DSL and helpers |

`src/blocksim/*` may use `math`, `data`, and `compute` if they are available as lower-tier modules. It must not import graphics, audio, UI, terminal, dataframe, graph, scene, physics, input, or `lua_api`.

## Responsibility split

### Rust kernel owns

- Parse and validate `SimSpec` from Lua table or TOML-derived table.
- Compile `SimSpec` into an `ExecutionPlan` with flattened composites and resolved port refs.
- Run all per-tick phases.
- Own all live state in `SimRuntime`.
- Keep monitor buffers and event logs separate.
- Apply anomaly effects through constrained typed mutations.
- Manage resource ledger, approvals, DLQ, replay, checkpoints, clock, and deterministic RNG state.

### Lua bridge owns

- Register `lurek.sim.*` only when `[modules].blocksim = true`.
- Convert Lua values to Rust specs and Rust snapshots back to Lua tables.
- Store `SimRuntime` as `mlua::UserData`.
- Convert `SimError` to Lua errors or `nil, err` returns.
- Stay thin. No domain logic in `src/lua_api/blocksim_api.rs`.

### Lua helper library owns

- Scenario DSL: chains, branches, composites, catalog instantiation.
- Blueprint patterns: saga, canary, bulkhead, watchdog, approval flow, DLQ recovery.
- Multi-run orchestration: baseline vs variant, seeded runs, batches.
- TOML loading and table normalization via existing `lurek.*` APIs.
- Monitor export and post-run report generation.
- Optional dashboard glue for `lurek.ui`, `lurek.render`, `lurek.terminal`, and `lurek.debugbridge`.

### Analytics owns

Analytics stays outside the kernel. The kernel emits samples and events. Lua loads them into `lurek.dataframe` or exports them for external tools.

## Authoring model

The old source used YAML as one large configuration surface. In Lurek this should be split.

| Concern | Format | Location |
|---|---|---|
| lifecycle config | TOML | `scenarios/<name>/config.toml` |
| block catalogs | TOML | `catalogs/blocks/<domain>.toml` |
| resource pools | TOML | `catalogs/resources.toml` |
| monitor declarations | TOML | `scenarios/<name>/monitors.toml` |
| anomaly profiles | TOML | `catalogs/anomalies/<domain>.toml` |
| KPI thresholds | TOML | `standards/kpis.toml` |
| topology and edge wiring | Lua | scenario script |
| composite assembly | Lua | `library/blocksim` helpers |
| scenario variants | Lua | scenario script |
| KPI logic and reports | Lua | `library/blocksim/analytics.lua` |
| hard fallback defaults | Rust | `SimConfig::default()` and spec defaults |

Topology should remain Lua-first because it is scenario-specific. Static reusable data belongs in TOML catalogs. YAML is not used.

## Catalog pattern

Reusable domain blocks should live in TOML catalogs. Lua instantiates them and applies per-scenario overrides.

```lua
local blocksim = require("library.blocksim")
local catalog = blocksim.catalog.load("catalogs/blocks/factory.toml")

local blocks = {
  catalog:instantiate("press_template", { id = "press_A" }),
  catalog:instantiate("press_template", { id = "press_B", container = { capacity = 10 } }),
}

local edges = blocksim.graph.chain({ "source.out", "press_A.in", "press_B.in", "sink.in" })
```

This replaces YAML anchors and merge keys with explicit Lua reuse.

## Kernel module layout

```text
src/blocksim/
  mod.rs
  error.rs
  spec.rs
  model.rs
  compiler.rs
  runtime.rs
  tick.rs
  queue.rs
  resource.rs
  value.rs
  filter.rs
  script.rs
  composite.rs
  anomaly.rs
  monitor.rs
  approval.rs
  dlq.rs
  replay.rs
  clock.rs
  circuit_breaker.rs
  event_log.rs
```

`mod.rs` should only contain module declarations, re-exports, attributes, and docs. Definitions belong in sibling files.

## Tick pipeline

Production tick order should be fixed:

| Phase | Name | Responsibility |
|---|---|---|
| 1 | `clock_advance` | tick counter, calendar, fast-forward state |
| 2 | `anomaly_eval` | activate, apply, expire, cascade |
| 3 | `circuit_check` | closed/open/half-open transitions |
| 4 | `rate_limit` | refill tokens and throughput governors |
| 5 | `block_exec` | dequeue, filter, run block type, enqueue, log |
| 6 | `resource_release` | release locks completed in this tick |
| 7 | `value_rollup` | aggregate value edges through composite hierarchy |
| 8 | `monitor_sample` | sample monitors and evaluate alerts |

Monitor sampling is last, so samples represent committed end-of-tick state.

## Public Lua API target

V1 should be small and synchronous:

```lua
lurek.sim.create(spec) -> sim, err
lurek.sim.destroy(sim)
lurek.sim.step(sim, n) -> stats, err
lurek.sim.run(sim) -> stats, err
lurek.sim.reset(sim) -> ok, err
lurek.sim.snapshot(sim) -> table
lurek.sim.block_state(sim, block_id) -> table, err
lurek.sim.tick(sim) -> integer
lurek.sim.validate_spec(spec) -> ok, err_table
lurek.sim.load_toml(toml_string) -> sim, err
lurek.sim.drain_monitors(sim) -> samples
lurek.sim.peek_monitors(sim) -> samples
lurek.sim.drain_events(sim) -> events
lurek.sim.inject_anomaly(sim, anomaly_id) -> ok, err
lurek.sim.expire_anomaly(sim, anomaly_id) -> ok, err
lurek.sim.anomaly_status(sim) -> table
lurek.sim.pending_approvals(sim) -> requests
lurek.sim.approve(sim, approval_id) -> ok, err
lurek.sim.reject(sim, approval_id, reason) -> ok, err
lurek.sim.dlq_entries(sim) -> entries
lurek.sim.replay_dlq(sim, entry_id) -> ok, err
lurek.sim.clear_dlq(sim) -> count
lurek.sim.save_checkpoint(sim) -> checkpoint_string, err
lurek.sim.restore_checkpoint(sim, checkpoint_string) -> ok, err
lurek.sim.version() -> string
```

V1 anomaly injection should only force-activate anomalies declared in the spec. Fully ad-hoc undeclared anomaly injection is a V2 feature at most.

## Hard design rules

- No Lua callbacks inside the hot tick loop.
- No heap allocation in the hot tick loop where it can be preallocated from `SimSpec`.
- No UI, GPU, audio, input, or window dependency in `src/blocksim`.
- Deterministic by construction: same spec, same seed, same external inputs means same event log and monitor samples.
- Monitor buffer is a configurable ring buffer. Default target: 10,000 samples.
- Event log and monitor samples are separate streams.
- DLQ replay is a manual operator action. It can change future ordering, but a checkpoint taken after replay must replay deterministically.
- Approval uses a poll-step model: a blocked approval does not pause the whole engine forever; `step` returns stats with `approvals_pending > 0`.
- Recoverable Lua API errors use `nil, err` or `nil, err_table` where the surrounding Lurek API style allows it.

## Existing Lurek APIs to use

| Need | Use |
|---|---|
| TOML and JSON data | `lurek.serial` / existing data helpers exposed to Lua |
| Files and JSONL | `lurek.filesystem` |
| deterministic RNG in Lua helpers | `lurek.math.newRandomGenerator` |
| post-run tables | `lurek.dataframe` |
| background batch orchestration | `lurek.thread` with channels |
| in-engine dashboard | `lurek.ui`, `lurek.render`, `lurek.terminal` |
| external live tooling | `lurek.debugbridge` |
| prototype graph reference | `lurek.graph` from Lua only, not as Rust dependency |

## Useful missing APIs and tools

High-value additions that fit this architecture:

- `lurek.sim.export_monitors(sim, path)` to flush monitor samples to JSONL.
- `lurek.dataframe.fromJsonLines(path)` or a Lua helper with streaming behavior.
- Percentile helpers such as p95 latency in `lurek.dataframe` or `library/blocksim/analytics.lua`.
- VS Code diagnostics for scenario TOML/Lua: missing targets, invalid port refs, cycles, no sink, unknown monitor target, invalid alert rule.
- VS Code graph preview and live monitor panel through `lurek.debugbridge`.
- Snippets for block, edge, monitor, anomaly, approval, DLQ, and blueprint patterns.
- Schema export from `library/blocksim/schema.lua` or Rust spec metadata for editor validation.

## Roadmap gates

Use these gates instead of copying a large implementation plan:

| Phase | Gate |
|---|---|
| 0 | YAML-to-TOML/Lua migration spike confirms no blocking source construct |
| 1 | Flat Rust graph Source -> Transform -> Sink runs in Rust tests |
| 2 | `lurek.sim.create/step/run/snapshot/destroy` works in Lua tests |
| 3 | monitor ring buffer and event log drain APIs work |
| 4 | anomaly activate/effect/expire/cascade works with event log |
| 5 | approval, DLQ, circuit breaker, replay, checkpoint determinism pass tests |
| 6 | three-level composite flattening has stable golden traces |
| 7 | advanced mechanics have one isolation test each |
| 8 | `library/blocksim` runs at least three domain blueprints |
| 9 | integration test runs sim -> drain monitors -> dataframe -> report |
| 10 | benchmark target passes: 50-block flat graph, 5 monitors, at least 10k ticks/s |

## Tests

Minimum test placement:

- Rust kernel: `tests/rust/unit/blocksim_tests.rs`.
- Lua API: `tests/lua/unit/test_blocksim.lua`.
- Lua helper library: `tests/lua/library/test_blocksim_lib.lua`.
- Demo smoke: `tests/demo_smoke_tests.rs` with `#[ignore]` only if a visual demo is added.
- Avoid `#[cfg(test)]` in `src/`.

## Non-goals for V1

Do not include these in the engine core:

- built-in web server or REST adapter,
- DuckDB or external SQL dependency,
- YAML parser,
- browser/WASM runtime,
- Python interop,
- embedded editor in the engine binary,
- graph layout engine inside `src/blocksim`,
- arbitrary Lua functions executed per item movement.
