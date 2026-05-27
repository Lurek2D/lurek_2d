# Block Simulator w Lurek2D - monitoring

Monitoring w Lurek jest warstwą obserwacji nad `src/blocksim` i `library/blocksim`. Monitory nie zmieniają symulacji. Próbkują stan po zakończeniu ticka, zapisują próbki i karmią dashboard oraz analytics.

## Decyzja

Monitory są deklarowane w scenariuszu Lua/TOML i aktywne od startu runu. Dane operatora pochodzą z monitorów, nie z surowego event logu. Event log nadal istnieje, ale jest dla diagnostyki i analityki po runie.

Warstwy:

| Warstwa | Rola |
|---|---|
| `library/blocksim/monitor.lua` | Monitor definitions, alert parser, sample history |
| `library/blocksim/world.lua` | Lua spike wywołuje monitor pass po ticku |
| `src/blocksim/monitor.rs` | produkcyjny ring buffer, typed samples, alert evaluation |
| `lurek.filesystem` | zapis `*_monitors.jsonl` |
| `lurek.serial` | JSON encoding samples |
| `lurek.dataframe` | agregacje po runie |
| `lurek.ui` | live dashboard w grze |
| `lurek.debugbridge` | event stream do VS Code |

## Pętla ticka

```lua
function World:step()
  self.tick = self.tick + 1
  self.anomalies:preTick(self)
  self.blocks:step(self)
  self.signals:drain(self)
  self.anomalies:postTick(self)
  self.monitors:collectDue(self)
end
```

Monitor pass jest ostatni. Dzięki temu próbka widzi stan po przetworzeniu ticka. W Rust kernelu monitor buffer musi być ring bufferem z konfigurowalnym limitem, domyślnie 10_000 próbek. Event log i monitor samples to dwa oddzielne strumienie.

## Konfiguracja Lua

```lua
monitors = {
  {
    id = "watch_assembly_queue",
    type = "queue_depth_monitor",
    target = "assembly_station",
    interval = 1,
    alert = {
      { condition = "> 8", severity = "warning", message = "Assembly queue backing up" },
      { condition = "> 15", severity = "critical", message = "Queue near overflow" },
    },
  },
  {
    id = "watch_throughput",
    type = "throughput_monitor",
    target = "assembly_station",
    window = 10,
    interval = 1,
  },
}
```

TOML może opisać te same pola, jeżeli nie ma callbacków.

## MonitorSample

Próbka jako Lua table:

```lua
{
  monitor_id = "watch_assembly_queue",
  type = "queue_depth_monitor",
  tick = 42,
  sim_time = 42,
  target = "assembly_station",
  metric = "queue_depth",
  value = 7,
  details = { capacity = 20, fill_ratio = 0.35 },
  window_values = nil,
  alert = nil,
}
```

Zapis:

```lua
local json = lurek.serial.toJson(sample, false)
lurek.filesystem.append("sim_runs/run_001_monitors.jsonl", json .. "\n")
lurek.debugbridge.broadcast("sim.monitor", json)
```

## 21 monitorów

| ID | Monitor | Lurek implementation |
|---|---|---|
| s15.1 | queue_depth | `block.container:size()`, fill ratio |
| s15.2 | state | `block.state`, transition, duration |
| s15.3 | throughput | delta `block.processed` over window |
| s15.4 | latency | completion tick - queued tick |
| s15.5 | health | `block.health` |
| s15.6 | concurrency | active jobs / max concurrency |
| s15.7 | error_rate | failed+rejected / total over window |
| s15.8 | edge_flow | item count sent across edge per tick |
| s15.9 | particle | in-flight item count by type |
| s15.10 | backpressure | downstream fill + gate state |
| s15.11 | bottleneck | queue growth ranking |
| s15.12 | cost | `value_cost_total` delta/total |
| s15.13 | revenue | `value_out_total` delta/total |
| s15.14 | efficiency | value_out / max(value_cost, 1) |
| s15.15 | signal | emitted/received signal counts |
| s15.16 | circuit_breaker | CB state and failures |
| s15.17 | resource_pool | used/capacity |
| s15.18 | resource_contention | blocks waiting for a pool |
| s15.19 | dlq | DLQ size, delta, by reason |
| s15.20 | approval_queue | pending approvals and wait time |
| s15.21 | anomaly | active anomalies, effects this tick |

## Alert parser

Pierwsza wersja wspiera:

| Typ | Przykład |
|---|---|
| threshold | `> 8`, `<= 0.2`, `== failed` |
| delta | `delta > 20% in 5` |
| absence | `absent 10` |
| consecutive | `consecutive 3 failed`, `consecutive 20 bp_active` |

Alert jest edge-triggered. Warunek musi wrócić do false, zanim wyemituje ponownie.

```lua
local alert = {
  severity = "warning",
  condition = "> 8",
  message = "Queue depth high",
  triggered_value = 9,
  monitor_id = "watch_assembly_queue",
}
```

## Dashboard w Lurek

Live dashboard powinien być zwykłym ekranem gry:

- `lurek.ui.newLineChart` dla queue depth, latency, health,
- `lurek.ui.newBarChart` dla throughput windows i bottleneck ranking,
- `lurek.ui.newTable` dla DLQ, approvals, active anomalies,
- `lurek.ui.newProgressBar` dla resource utilization i queue fill,
- `lurek.ui.newTreeView` dla composite drill tree,
- `lurek.render` dla canvasu grafu i animowanych edge particles.

`lurek.draw_ui()` rysuje UI. `lurek.draw()` rysuje canvas grafu.

## DataFrame po runie

Po zakończeniu runu:

```lua
local rows = MonitorLog.loadRows("sim_runs/run_001_monitors.jsonl")
local df = lurek.dataframe.fromTable(rows)
local queue = df:filter("type", "eq", "queue_depth_monitor")
local desc = queue:describe()
```

Dla multi-table raportów użyć `lurek.dataframe.newDatabase()` i `LDatabase:query`.

## Mapowanie anomalii na monitory

| Anomalia | Detektory |
|---|---|
| flow_resistance | latency, throughput |
| pressure_buildup | queue_depth, backpressure |
| turbulence | latency variance |
| leakage | edge_flow, particle |
| cavitation | state, latency |
| thermal_noise | latency, throughput variance |
| heat_buildup | health, latency |
| entropy_increase | error_rate |
| phase_transition | state, throughput step change |
| impedance_mismatch | bottleneck, queue_depth |
| signal_attenuation | signal delivery rate |
| crosstalk | edge_flow unexpected edge |
| short_circuit | particle path audit |
| brownout | resource_pool capacity |
| quantum_tunneling | particle path audit |
| superposition | throughput/item count distribution |
| entanglement | correlated state monitor |
| observer_effect | throughput/latency vs tap count |
| catalyst | neighbor throughput increase |
| corrosion | edge_flow, error_rate over time |
| chain_reaction | state, circuit_breaker sequence |
| saturation | throughput plateau + queue growth |
| byzantine_failure | wrong item types downstream |
| clock_drift | state timing and latency |

## Braki w Lurek API

Dla Lua spike wystarczy tabela próbek. Dla produkcyjnych dużych runów potrzebne są:

1. `lurek.sim.peek_monitors(sim, id, since_tick)` albo helper `library/blocksim` bez ręcznego filtrowania tabel Lua.
2. JSONL reader do DataFrame: `lurek.dataframe.fromJsonLines(path)` albo helper w Lua.
3. Percentile/stat helper dla p95 latency.
4. Debug bridge event subscriptions, żeby VS Code nie musiał filtrować wszystkiego.
5. `lurek.sim.drain_monitors(sim)`, `peek_monitors(sim)` i opcjonalne `export_monitors(sim, path)`.

## VS Code extension

Potrzebne funkcje:

- panel `Simulation Monitors` z live próbkami z debug bridge,
- custom viewer dla `*_monitors.jsonl`,
- diagnostics: monitor target nie istnieje, interval <= 0, alert condition nie parsuje się,
- chart preview dla zaznaczonego monitora,
- komenda `Export Monitor DataFrame`, która konwertuje JSONL do JSON/CSV.

## Testy

- Unit: alert parser, alert dedupe, window history.
- Unit: każdy monitor na małym fake world.
- Integration: scenario generuje `*_monitors.jsonl`, można go wczytać i przeliczyć DataFrame.
- UI smoke: dashboard renderuje przynajmniej queue chart i active anomaly table.
