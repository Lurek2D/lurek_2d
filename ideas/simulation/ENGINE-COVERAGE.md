# Block Simulator w Lurek2D - mapa pokrycia engine/API

Ten dokument zastępuje mapę `docs -> src/engine.py`. W Lurek nie ma Pythonowego `src/engine.py`, więc mapa pokrycia musi odpowiadać na inne pytanie: które części pomysłu można zrobić obecnym API Lurek, które powinny zostać biblioteką Lua, a które wymagają nowego Rust API.

## Status skrócony

| Obszar | Status w Lurek | Decyzja |
|---|---|---|
| Tick loop symulacji bloków | brak dedykowanego `lurek.sim` | produkcyjnie `src/blocksim/`; Lua tylko jako spike/prototyp |
| Graf | częściowo jest `lurek.graph` | użyć tylko z Lua jako prototyp/reference; nie importować `src/graph` w Rust kernelu |
| Kolejki/kontenery | brak dedykowanej semantyki block simulator | Rust kernel docelowo, Lua tylko do weryfikacji DSL |
| Item z payload/audit/cost | brak pełnego typu | Lua table na start |
| RNG deterministyczny | jest `lurek.math.newRandomGenerator` | używać od początku |
| Serializacja | jest `lurek.serial` | używać JSON/TOML, bez YAML |
| Logi i pliki | jest `lurek.filesystem`, `lurek.log` | używać do JSONL/structured logs |
| DataFrame/statystyka | jest `lurek.dataframe` | używać do monitorów i analytics |
| UI dashboard | jest `lurek.render`, `lurek.ui`, `lurek.html` | zrobić w grze, plus VS Code view opcjonalnie |
| Debug bridge | jest `lurek.debugbridge` | użyć do live tools |
| Worker threads | jest `lurek.thread` | użyć dla ciężkiej analityki, nie dla współdzielonego Lua state |

## Pokrycie mechanik s4-s13

| Mechanika | Pokrycie obecnym Lurek | Uwagi |
|---|---|---|
| s4 typed items | częściowe | `lurek.graph:createItem` ma type/priority/decay, ale payload/audit/cost lepiej w Lua table |
| s4.3 container | częściowe | `LGraphNode` ma queue capacity i overflow policy; pełne pool_rules/aging w Lua |
| s5 script triggers | brak dedykowanego | Lua world obsługuje `fires_on` |
| s6 signals | częściowe | jest `lurek.event` i debugbridge, ale symulacyjne signals zrobić w `world.signals` |
| s7 value system | brak dedykowanego | Lua ledger; Rust później dla aggregation |
| s8 filters/gates | częściowe | `LGraphEdge:setActive`, node active/filter fields mogą pomóc; domenowo Lua |
| s9 block states | brak dedykowanego | Lua state strings |
| s10 concurrency | brak dedykowanego | Lua jobs per block; Rust później |
| s11 batch | brak dedykowanego | Lua container logic |
| s12 composite | brak dedykowanego | Lua subgraph/composition |
| s13.1 skills | brak dedykowanego | item.data attributes + Lua requirements |
| s13.2 health | brak dedykowanego | Lua block.health |
| s13.3 schedule | częściowe | `lurek.process(dt)` + world logical ticks; timers nie zastępują sim clock |
| s13.4 conditional routing | częściowe | Lua router handler |
| s13.5 value formula | częściowe | Lua eval whitelist; unikać niebezpiecznego `load` dla TOML data |
| s13.6 conversion | częściowe | `LGraphNode:setConversion`, ale payload conversion w Lua |
| s13.7 router | częściowe | `lurek.graph` path/filter pomaga; reguły domenowe w Lua |
| s13.8 counter | brak dedykowanego | Lua block handler |
| s13.9 priority queue | częściowe | `LGraphItem:setPriority`, `LGraphNode` queue; pełna priority map w Lua |
| s13.10 join | brak dedykowanego | Lua keyed join |
| s13.11 aging | częściowe | `GraphItem` decay time, ale SLA aging w Lua |
| s13.12 resource pool | brak dedykowanego | Lua resource manager |
| s13.13 backpressure | częściowe | `LGraphEdge:setThroughput`/`setActive`; policy w Lua |
| s13.14 circuit breaker | brak dedykowanego | Lua circuit breaker |
| s13.15 saga | brak dedykowanego | Lua coordinator |
| s13.16 fork/join | częściowe | wiele edges + Lua join |
| s13.17 time windows | brak dedykowanego | Lua sim clock/calendar |
| s13.18 cost ledger | brak dedykowanego | Lua item audit/cost |
| s13.19 adaptive concurrency | brak dedykowanego | Lua policy |
| s13.20 token bucket | brak dedykowanego | Lua helper; Rust później |
| s13.21 probabilistic outcomes | dobre | `lurek.math.newRandomGenerator`, `lurek.patterns.newWeightedRandom` |
| s13.22 audit trail | brak dedykowanego | Lua table + JSONL |
| s13.23 context/scenarios | dobre | Lua tables + `lurek.serial` |
| s13.24 DLQ/replay | brak dedykowanego | Lua list/table |
| s13.25 tap | częściowe | clone item in Lua; `lurek.graph` item clone nie ma pełnego payloadu |
| s13.26 schema version | Lua | field na itemie |
| s13.27 human approval | UI/game logic | `lurek.ui`/`lurek.html` formularze, `debugbridge` dla VS Code |
| s13.28 clock/fast-forward | Lua | logical ticks w `world:stepTicks(n)` |
| s13.29 warmup | Lua | state counter |
| s13.30 yield rate | Lua | RNG per item |
| s13.31 maintenance | Lua | state counter + signals |
| s13.32 priority | Lua | sort blocks by `priority` |
| s13.33 energy cost | Lua | per-tick ledger |

## Pokrycie anomalii s14

Wszystkie 24 anomalie można prototypować w Lua, ale produkcyjny tick loop powinien być w Rust. Anomalie w V1 muszą być zadeklarowane w specyfikacji; `lurek.sim.inject_anomaly(sim, id)` tylko wymusza aktywację istniejącej anomalii.

Największe braki API:

- szybkie batch remove/move itemów między kontenerami,
- edge reliability/loss jako wbudowany parametr,
- snapshoty block/edge state bez deep copy,
- typowany event stream,
- built-in monitor samples.

## Pokrycie monitorów s15

| Monitor | Możliwe obecnie | Lepsze z `lurek.sim` |
|---|---|---|
| queue/state/throughput/latency | Lua world state | Rust snapshot i sample structs |
| health/concurrency/error rate | Lua counters | Rust counters per block |
| edge/particle/backpressure | częściowo `lurek.graph` | Rust edge stats |
| bottleneck | Lua rolling queue history | Rust indexed queues |
| cost/revenue/efficiency | Lua value ledger + dataframe | Rust value stream |
| signal/circuit breaker | Lua event queues | Rust event stream |
| resource/DLQ/approval/anomaly | Lua managers | Rust typed managers |

## Pokrycie analytics s16

`lurek.dataframe` daje bardzo dobre podstawy. Obecnie wystarczy dla:

- mean, median, stddev, variance,
- rolling mean/sum/min/max,
- percent change,
- z-score,
- correlation,
- SQL-like queries na in-memory database.

Braki:

- percentile helper jako first-class API, chyba że policzymy w Lua,
- Welch t-test i p-value,
- wygodne JSONL -> DataFrame streaming load,
- cross-run report registry.

## Proponowany `lurek.sim` API

Publiczne API powinno być funkcyjne i synchroniczne. `SimRuntime` mieszka w Rust jako userdata, a Lua wywołuje operacje na uchwycie.

Minimalne API v1:

```lua
lurek.sim.create(spec : table) -> sim, err
lurek.sim.destroy(sim) -> nil
lurek.sim.step(sim, ticks : integer?) -> stats, err
lurek.sim.run(sim) -> stats, err
lurek.sim.reset(sim) -> ok, err
lurek.sim.tick(sim) -> integer
lurek.sim.snapshot(sim) -> table
lurek.sim.block_state(sim, block_id : string) -> table, err
lurek.sim.drain_monitors(sim) -> table
lurek.sim.peek_monitors(sim) -> table
lurek.sim.drain_events(sim) -> table
lurek.sim.inject_anomaly(sim, anomaly_id : string) -> ok, err
lurek.sim.pending_approvals(sim) -> table
lurek.sim.approve(sim, approval_id : string) -> ok, err
lurek.sim.reject(sim, approval_id : string, reason : string?) -> ok, err
lurek.sim.save_checkpoint(sim) -> string, err
lurek.sim.restore_checkpoint(sim, checkpoint : string) -> ok, err
lurek.sim.validate_spec(spec : table) -> ok, err_table
```

`library/blocksim` może dawać obiektowy DSL nad tym API, ale bridge Rust-Lua powinien pozostać płaski i cienki.

## Granice modułów Rust

Docelowy moduł to `src/blocksim/`. To Tier 2 headless kernel. Może używać niższych warstw takich jak `math`, `data` i `compute`, ale nie może importować `src/graph`, `src/dataframe`, `src/gui`, `src/terminal`, `src/render`, `src/audio`, `src/physics`, ani `src/lua_api`.

Wariant zależności:

```text
math/data/compute -> blocksim -> lua_api/blocksim_api.rs
runtime/app -> lua_api composition root
library/blocksim -> public lurek.* only
```

`src/graph` zostaje conceptual reference i Lua prototype helperem. Jeżeli kernel potrzebuje topological sort albo cycle detection, dodać lokalny algorytm w `compiler.rs` albo mały lower-tier utility, nie import z Tier 2.

## VS Code extension coverage

Obecne rozszerzenie ma wygenerowane API data i webviewy. Dla symulacji brakuje:

- symulacyjnego schema registry,
- diagnostics dla scenario files,
- graph preview,
- run pair command,
- live monitor stream przez debug bridge,
- custom editor dla analytics JSON,
- snippets dla block/edge/monitor/anomaly.

Uwaga: dane callbacków w generatorze extension zawierają starsze nazwy typu `lurek.load`/`lurek.update`, a runtime faktycznie używa `lurek.init`, `lurek.process(dt)`, `lurek.draw`, `lurek.draw_ui`. Przy pracach extension trzeba zsynchronizować generator z runtime.

## Acceptance gate

Projekt można uznać za gotowy do implementacji, gdy:

1. `library/blocksim` ma jeden mały scenariusz, który uruchamia 100 ticków deterministycznie.
2. Ten scenariusz generuje monitor samples i analytics report.
3. Dashboard w Lurek pokazuje queue depth, throughput, state i anomaly timeline.
4. VS Code extension nie jest wymagane do działania, ale może podglądać dane przez debug bridge.
