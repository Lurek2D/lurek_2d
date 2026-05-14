# Block Graph Simulator w Lurek2D - core design

Ten dokument przepisuje model bloków pod Lurek2D. Najważniejsza zmiana: to nie jest osobny Python/Flask simulator. To jest reusable digital twin runtime w Lurek: Lua składa scenariusze, a produkcyjny tick loop docelowo działa w `src/blocksim/` i jest wystawiony jako `lurek.sim.*`.

## Kierunek

Bloki modelują procesy biznesowe. Dane płyną z lewej do prawej. Każdy blok ma porty wejściowe, kolejkę, skrypt przetwarzania, stan i porty wyjściowe.

W Lurek są trzy poziomy implementacji:

1. Pure Lua spike w `library/blocksim`, tylko do weryfikacji DSL i authoringu.
2. Gra demonstracyjna w `content/games/block_sim`.
3. Rust core `src/blocksim` dla rzeczy, których Lua nie powinna liczyć przy dużych grafach: kolejki, tick loop, snapshoty, zdarzenia, indeksy grafu, monitory, anomalie, approvals, DLQ i replay.

Nie tworzyć edytora w binarce silnika. Jeżeli powstanie edycja wizualna, to jest ekran gry albo widok w rozszerzeniu VS Code. Silnik pozostaje runtime.

## Proponowana struktura plików

```text
library/blocksim/
  init.lua
  world.lua
  block.lua
  container.lua
  graph_builder.lua
  anomaly.lua
  monitor.lua
  analytics.lua
  render.lua
  schema.lua

content/games/block_sim/
  conf.lua
  main.lua
  scenarios/
    manufacturing_resilience.lua
    software_sprint.lua
  ui/
    dashboard.lua
    canvas.lua
```

Jeżeli powstaje Rust core:

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
  monitor.rs
  anomaly.rs
  approval.rs
  dlq.rs
  replay.rs
  clock.rs
  circuit_breaker.rs
  event_log.rs
src/lua_api/blocksim_api.rs
```

`src/blocksim/mod.rs` ma być tylko manifestem. Bindingi w `src/lua_api/blocksim_api.rs` mają zostać cienkie.

## Istniejące API Lurek, którego użyć

| Potrzeba | Obecne API |
|---|---|
| graf i krawędzie | `lurek.graph.newGraph`, `LGraph:addNode`, `:addEdge`, `:step`, `:update`, `:topologicalSort`, `LGraphEdge:setCapacity`, `:setThroughput`, `:setActive` |
| deterministyczny RNG | `lurek.math.newRandomGenerator(seed)`, `LRandomGenerator:random`, `:randomInt`, `:randomNormal`, `:getState`, `:setState` |
| serializacja | `lurek.serial.toJson`, `fromJson`, `toToml`, `fromToml`, `validate`, `applyDefaults` |
| zapis logów | `lurek.filesystem.write`, `append`, `writeJson`, `read`, `lines`, `createDirectory` |
| analityka | `lurek.dataframe.fromTable`, `LDataFrame:mean`, `:stddev`, `:corr`, `:withRollingMean`, `:withPctChange`, `:query` |
| UI | `lurek.render.*`, `lurek.ui.newLineChart`, `newBarChart`, `newTable`, `newTreeView`, `newProgressBar`, `newWindow` |
| narzędzia | `lurek.debugbridge.start`, `broadcast`, `poll`, `getClientCount` |
| praca w tle | `lurek.thread.async`, `newChannel`, `newBoundedChannel`, `newPool` |

## DSL scenariusza

Wariant Lua:

```lua
return {
  simulation = { ticks = 500, tick_seconds = 1, seed = 1234 },
  item_types = {
    { id = "feature_request", unit = "tickets" },
    { id = "deployed_feature", unit = "releases" },
  },
  resources = {
    { id = "engineers", capacity = 4 },
  },
  blocks = {
    {
      id = "developer",
      label = "Developer",
      type = "process",
      block_class = "person",
      ports = {
        data_in = { "feature_request" },
        data_out = { "draft_code" },
        trigger_in = { "start" },
        event_out = { on_complete = "code_written", on_fail = "blocked" },
        value_cost = { amount = 150.0, type = "labor" },
      },
      container = { capacity = 5, strategy = "priority", priority_field = "business_value" },
      script = {
        fires_on = "any",
        requires_resource = { pool = "engineers", slots = 1, on_unavailable = "queue" },
        steps = {
          { id = "analyze", duration_ticks = 1 },
          { id = "write", duration_ticks = 3, fail_chance = 0.05, output = "draft_code" },
        },
      },
    },
  },
  edges = {
    { from = "developer", to = "review", type = "data", item_type = "draft_code" },
  },
}
```

Wariant TOML jest dla statycznych katalogów i data-only scenariuszy. Topologia i warianty scenariusza zostają w Lua, bo tam najczytelniej składa się composite, baseline vs variant i per-run overrides.

## Porty

Porty zostają jako model domenowy i wizualny:

| Port | Strona | Znaczenie |
|---|---|---|
| `trigger_in` | lewa | sygnały start/reset/override |
| `filter_in` | lewa | gate, parametry, transformacje |
| `data_in` | lewa | typowane itemy |
| `value_in` | lewa | agregacja wartości z dzieci composite |
| `event_out` | prawa | sygnały done/failed/sla_breach |
| `value_cost` | prawa | koszt przetwarzania |
| `value_out` | prawa | przychód, oszczędność, wartość |
| `data_out` | prawa | typowane itemy po przetworzeniu |

W Lua porty są metadanymi. Silnik symulacji używa ich do walidacji i routingu. Render używa ich do layoutu.

## Item

Minimalny item:

```lua
{
  id = "item_001",
  type = "feature_request",
  data = { priority = "high", business_value = 100 },
  quantity = 1,
  priority = 0,
  born_tick = 0,
  schema_version = 1,
  tags = {},
  audit_trail = {},
  cost_ledger = 0,
}
```

Lua może obsłużyć to jako tabela. Rust API ma sens, gdy liczba itemów jest duża i trzeba ograniczyć alokacje.

## Kontener

Pierwsza wersja w Lua:

- `capacity = 0` oznacza brak limitu,
- `strategy = "fifo" | "lifo" | "priority"`,
- `overflow = "drop_oldest" | "drop_newest" | "block" | "error"`,
- `pool_rules` do `min_to_start` i `max_stockpile`,
- aging i expiry jako opcjonalny moduł.

Rust przenieść dopiero, gdy profiling pokaże koszt. Najpierw zrobić Lua i testy.

## Skrypt bloku

Skrypt bloku to deklaracja kroków, nie dowolny kod w środku każdego bloku. W prototypie Lua można dodać callback Lua:

```lua
script = {
  fires_on = "all",
  batch_size = 5,
  steps = {
    { id = "consume", type = "consume", requires = { wood = 5, metal = 3 } },
    { id = "assemble", type = "process", duration_ticks = 3, fail_chance = 0.05 },
    { id = "emit", type = "emit", output = "product" },
  },
  on_process = function(ctx, items)
    return items
  end,
}
```

Jeżeli scenario pack ma być TOML, callbacki nie są dostępne. Wtedy używać tylko built-in `type` kroków. W produkcyjnym `src/blocksim` nie wolno wywoływać Lua callbacka dla każdego itemu ani każdego block exec. Custom logika musi być typowanym wariantem `ScriptSpec` albo batched hookiem między `lurek.sim.step(...)`.

## Stany

Stan bloku:

- `idle`,
- `waiting`,
- `processing`,
- `failed`,
- `warmup`,
- `maintenance`,
- `cb_open`,
- `waiting_approval`.

Nazwy jako lowercase strings w Lua. Jeżeli trafi do Rust API, eksportować enum jako strings, zgodnie z konwencją Lua API.

## Kompozyty

Composite jest blokiem, który zawiera subgraph. Ważna decyzja: composite boundary nie dodaje kolejki domyślnie. Item wchodzi bezpośrednio do entry child.

Tryby:

| Mode | Zachowanie |
|---|---|
| `passthrough` | granica organizacyjna, bez przetwarzania |
| `script_only` | composite działa jak atomowy blok |
| `internal_only` | dzieci wykonują całą pracę; domyślnie |
| `script_then_internal` | outer script jako pre-gate, potem dzieci |
| `internal_then_script` | dzieci, potem outer script jako walidacja |

W UI drill-in to funkcja gry albo VS Code, nie core engine.

## Typy bloków

Pierwsza wersja powinna mieć:

| Type | Lua handler |
|---|---|
| `source` | tworzy itemy według schedule i RNG |
| `sink` | zbiera itemy i value |
| `process` | uruchamia script steps |
| `router` | wybiera edge według reguł |
| `filter` | gate/transform/route |
| `transform` | modyfikuje fields/type |
| `fork` | klonuje item na N wyjść |
| `join` | czeka na wiele typów po key |
| `merge` | batch accumulator |
| `gate` | trzyma itemy do triggera |
| `delay` | trzyma item przez N ticków |
| `counter` | liczy throughput i emituje event |
| `tap` | niekonsumująca kopia do monitorów |
| `dead_letter` | DLQ i replay |
| `value_accumulator` | P&L aggregator |
| `composite` | subgraph |

## Braki w Lurek API

Istniejące `lurek.graph` ma dużo przydatnych prymitywów, ale block simulator potrzebuje więcej semantyki:

1. Per-node state machine i processing jobs.
2. Per-item `data` table, audit trail, cost ledger.
3. Queue strategy z priority map i aging.
4. Signal queue z payloadem i delivery phase.
5. Value aggregation przez composite hierarchy.
6. Monitor samples jako typowany stream.
7. API snapshots bez kopiowania całego świata w Lua co tick.

Proponowane publiczne API produkcyjne:

```lua
lurek.sim.create(spec) -> sim, err
lurek.sim.step(sim, ticks) -> stats, err
lurek.sim.run(sim) -> stats, err
lurek.sim.snapshot(sim) -> table
lurek.sim.block_state(sim, id) -> table, err
lurek.sim.drain_events(sim) -> table
lurek.sim.drain_monitors(sim) -> table
lurek.sim.replay_dlq(sim, entry_id) -> ok, err
```

`library/blocksim` może opakować to w wygodniejsze metody obiektowe dla scenariuszy, ale publiczny bridge pozostaje funkcjami pod `lurek.sim.*`.

## VS Code extension

Najbardziej wartościowe funkcje:

- schema validation dla Lua/TOML scenariuszy,
- outline: item types, resources, blocks, edges, monitors, anomalies,
- graph preview webview,
- diagnostics: edge do nieistniejącego blocka, KPI bez monitora, cycle warning, brak sink,
- snippets dla bloków, monitorów i anomalii,
- debug bridge live state inspector.

## Testy

- Lua unit tests dla `container`, `world`, `block`, `router`, `join`, `composite`.
- Lua integration test dla jednego małego scenariusza end-to-end.
- Rust tests tylko po dodaniu `src/blocksim`.
- Dla publicznego `lurek.sim.*`: testy Lua w `tests/lua/`, `docs/specs/blocksim.md` i generated docs.
