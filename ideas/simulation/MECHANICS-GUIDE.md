# Block Simulator w Lurek2D - mechanics guide

Ten dokument przepisuje mechaniki s4-s13 jako kontrakt biblioteki `library/blocksim` i przyszłego Rust kernelu `src/blocksim`. Publiczne `lurek.sim.*` powinno dostać tylko te elementy, które muszą działać deterministycznie i szybko w tick loop.

## Callbacki runtime

Gra używa aktualnych callbacków Lurek:

```lua
function lurek.init() end
function lurek.process(dt) end
function lurek.draw() end
function lurek.draw_ui() end
```

Nie projektować przykładów na `lurek.load` ani `lurek.update`.

## Core systems

| ID | Mechanika | Lurek implementation |
|---|---|---|
| s4 | typed items | Lua table z `id`, `type`, `data`, `quantity`, `priority`, `audit_trail`, `cost_ledger` |
| s4.3 | container | `Sim.Container` w Lua; FIFO/LIFO/priority/overflow/pool rules |
| s5 | script triggers | `fires_on = "data" | "trigger" | "both" | "any"` w Lua world |
| s6 | signals | `world.signals` jako kolejka end-of-tick; payload opcjonalny |
| s7 | value | `world.value_ledger`, per-item `cost_ledger`, composite aggregation |
| s8 | filter/gate | Lua filter handler; opcjonalnie `LGraphEdge:setActive` dla edge gate |
| s9 | block states | lowercase state strings |
| s10 | concurrency | licznik active jobs per block |
| s11 | batch | container czeka na `batch_size` albo `batch_timeout_ticks` |
| s12 | composite | nested world/subgraph z boundary ports |

## Extended mechanics

| ID | Mechanika | Lurek implementation |
|---|---|---|
| s13.1 | skill requirement | item.data attributes, `requires` z min/exact value |
| s13.2 | health degradation | `block.health`, repair signal/API w Lua |
| s13.3 | schedule | logical tick schedule w world, nie wall-clock timer |
| s13.4 | conditional event routing | `event_out.routes` w Lua |
| s13.5 | value formula | bezpieczny mały expression evaluator albo callback Lua |
| s13.6 | conversion | `item.type` mapping po success |
| s13.7 | router | rules top-to-bottom, fallback do DLQ |
| s13.8 | counter/accumulator | handler bloków `counter` i `merge` |
| s13.9 | priority queue | sort po `item.priority` albo mapped field |
| s13.10 | join | keyed join po `item.data[key]` |
| s13.11 | aging | per tick age, priority escalation, expiry to DLQ |
| s13.12 | resource pool | Lua `ResourcePool:tryAcquire(slots)` |
| s13.13 | backpressure | downstream fill ratio zamyka upstream gate |
| s13.14 | circuit breaker | Lua state machine closed/open/half_open |
| s13.15 | saga | coordinator wysyła compensation signals |
| s13.16 | fork/join | clone item do wielu lanes, join po key |
| s13.17 | time windows | `SimClock` i calendar helper |
| s13.18 | item cost | stamp cost into audit trail |
| s13.19 | adaptive concurrency | policy zwiększa/zmniejsza slots po queue depth |
| s13.20 | token bucket | Lua bucket per block |
| s13.21 | probabilistic outcomes | `lurek.math.newRandomGenerator` albo `lurek.patterns.newWeightedRandom` |
| s13.22 | audit trail | append immutable-ish stamp tables; JSONL export |
| s13.23 | context/scenarios | `world.context`, injected into new items |
| s13.24 | DLQ/replay | `world.dlq` z replay do target container |
| s13.25 | tap | clone item do monitor/analytics bus |
| s13.26 | versioned item types | `item.schema_version` |
| s13.27 | human approval | UI panel + pending approvals table |
| s13.28 | clock/fast-forward | `world:stepTicks(n)` |
| s13.29 | warmup | state counter przed pierwszym processing |
| s13.30 | yield rate | RNG discard po success |
| s13.31 | preventive maintenance | interval counter + maintenance state |
| s13.32 | block priority | sort blocks before each tick |
| s13.33 | energy cost | charge per non-idle tick |

## Minimalne API biblioteki Lua

```lua
local Sim = require("library.blocksim")

local world = Sim.newWorld(def, { seed = 42 })
world:step()
world:stepTicks(100)
world:getSnapshot()
world:getBlock("assembly")
world:sendSignal("assembly", "reset", { by = "operator" })
world:replayDlq(item_id, "manual_review")
```

Komponenty:

```lua
Sim.Container.new(opts)
Sim.ResourcePool.new(opts)
Sim.Block.new(def)
Sim.World.new(def, opts)
Sim.Schema.validate(def)
Sim.Patterns.forkJoin(...)
Sim.Analytics.comparePair(...)
```

## Mechaniki, które warto zrobić najpierw

Kolejność implementacji dla Lua prototype:

1. `Item`, `Container`, `World`, `source`, `process`, `sink`, data edge.
2. `schedule`, `processing_ticks`, `batch_size`, `fail_chance`, RNG seed.
3. `value_cost`, `value_out`, audit trail.
4. `router`, `filter`, `join`, `fork`.
5. `resource_pool`, `backpressure`, `circuit_breaker`.
6. `monitor` + `analytics` minimalne.
7. `anomaly` wybrane: turbulence, leakage, heat_buildup, byzantine_failure.
8. composite i drill-in.

Ta kolejność daje szybki działający vertical slice.

## Expression rules

W configach nie używać dowolnego `load` na stringach z TOML. Dopuszczalne opcje:

- mały parser operatorów: `eq`, `neq`, `gt`, `lt`, `contains`,
- callback Lua tylko w scenariuszach `.lua`,
- whitelisted formula evaluator dla prostych działań arytmetycznych.

Przykład bezpiecznych router rules:

```lua
routes = {
  { field = "quality", op = "gte", value = 0.85, to = "good_line" },
  { field = "rework_count", op = "gte", value = 2, to = "scrap" },
  { default = "rework" },
}
```

## Event log taxonomy

Zdarzenia zostają, ale nazwy jako strings:

| Kategoria | Eventy |
|---|---|
| lifecycle | `SIMULATION_STARTED`, `SIMULATION_ENDED`, `TICK_SUMMARY` |
| items | `ITEM_CREATED`, `ITEM_QUEUED`, `ITEM_PROCESSING_STARTED`, `ITEM_PROCESSED`, `ITEM_FAILED`, `ITEM_DLQ` |
| signals | `SIGNAL_EMITTED`, `SIGNAL_RECEIVED` |
| value | `VALUE_EMITTED`, `ENERGY_CONSUMED` |
| reliability | `HEALTH_DEGRADED`, `CIRCUIT_BREAKER_OPENED`, `CIRCUIT_BREAKER_CLOSED` |
| approval | `APPROVAL_REQUESTED`, `APPROVAL_GRANTED`, `APPROVAL_REJECTED` |
| anomaly | `ANOMALY_ACTIVATED`, `ANOMALY_EFFECT`, `ANOMALY_EXPIRED`, `ANOMALY_CASCADE` |

Do pliku JSONL:

```lua
function EventLog:write(event)
  local line = lurek.serial.toJson(event, false) .. "\n"
  lurek.filesystem.append(self.path, line)
end
```

## Użycie Lurek APIs

- `lurek.math.newRandomGenerator(seed)` zamiast `math.random`, żeby run był powtarzalny.
- `lurek.serial.toJson/fromJson/toToml/fromToml` zamiast YAML.
- `lurek.filesystem.lines(path)` do czytania JSONL po runie.
- `lurek.dataframe.fromTable(rows)` do raportów.
- `lurek.debugbridge.broadcast(event, json)` dla live tools.
- `lurek.ui.newTable`, `newLineChart`, `newBarChart` dla dashboardu.

## Braki API

Nie dodawać wszystkiego od razu. Najpierw zmierzyć Lua. Najbardziej prawdopodobne Rust braki:

1. Queue i item store z indeksami.
2. Event log ring buffer z filtrowaniem po tick/event.
3. Monitor sample buffer jako typed rows.
4. Percentile/t-test/stat helpers.
5. Snapshot diff dla VS Code live view.

## Testy

Testy Lua powinny być mechanika po mechanice:

- `test_sim_container_unit.lua`,
- `test_sim_world_unit.lua`,
- `test_sim_router_unit.lua`,
- `test_sim_resource_unit.lua`,
- `test_sim_reliability_unit.lua`,
- `test_sim_anomaly_unit.lua`,
- `test_sim_monitor_analytics_unit.lua`.

Jeżeli mechanika trafi do publicznego `lurek.sim.*`, wtedy dodać tests/lua dla API i Rust unit tests w `tests/rust/unit/blocksim_tests.rs`, nie w `src/`.
