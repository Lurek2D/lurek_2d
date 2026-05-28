# Block Simulator w Lurek2D - analityka before/after

Ten dokument przepisuje pierwotny pomysĹ‚ analityki pod Lurek2D. Analityka jest warstwÄ… po runie: Rustowy `src/blocksim` emituje monitor samples i event log, a Lua oraz `lurek.dataframe` liczÄ… KPI i raporty.

## Decyzja architektoniczna

Analityka jest procesem po symulacji. Nie modyfikuje tick loop, nie zmienia stanu blokĂłw i nie jest czÄ™Ĺ›ciÄ… renderowania. Czyta prĂłbki monitorĂłw, liczy KPI, porĂłwnuje baseline z wariantem anomalii i zapisuje raport.

Docelowy podziaĹ‚:

| Warstwa | OdpowiedzialnoĹ›Ä‡ |
|---|---|
| Lua `library/blocksim/analytics.lua` | definicje KPI, reguĹ‚y porĂłwnaĹ„, interpretacja wynikĂłw, skĹ‚adanie raportu |
| Lua `content/games/block_sim/` | scenariusze, ekrany dashboardu, komendy uĹĽytkownika |
| Rust `lurek.dataframe` | statystyki, rolling windows, percent change, z-score, korelacje |
| Rust `lurek.serial` | JSON/TOML import-export raportĂłw i konfiguracji |
| Rust `lurek.filesystem` | zapis `save/sim_runs/*_monitors.jsonl` i `*_analytics.json` |
| Rust `lurek.thread` | opcjonalne liczenie raportu poza gĹ‚ĂłwnÄ… klatkÄ… |
| Rust `lurek.debugbridge` | wysyĹ‚ka raportĂłw i prĂłbek do rozszerzenia VS Code |
| `extension/vscode` | panel porĂłwnania runĂłw, wykresy, szybkie uruchamianie baseline/comparison |

Nie uĹĽywaÄ‡ YAML. Konfiguracje czysto danych powinny byÄ‡ TOML. Scenariusze, ktĂłre zawierajÄ… funkcje, callbacki albo niestandardowe formuĹ‚y, powinny byÄ‡ Lua modules zwracajÄ…cymi tabele.

## Pipeline w Lurek

1. `lurek.init()` Ĺ‚aduje scenariusz i tworzy dwa runy: baseline i comparison.
2. `lurek.process(dt)` krokuje symulacjÄ™. Dla szybkiego trybu uĹĽywa akumulatora logicznych tickĂłw, nie czasu klatki.
3. Monitor engine zapisuje prĂłbki w strukturze Lua i opcjonalnie do pliku przez `lurek.filesystem.write` albo append przez `lurek.filesystem.append`.
4. Po zakoĹ„czeniu obu runĂłw `SimAnalytics.comparePair(baseline, comparison, config)` liczy KPI.
5. Wynik idzie do `lurek.serial.toJson(report, true)` i `lurek.filesystem.writeJson(path, json)`.
6. `lurek.draw_ui()` pokazuje raport w UI, a `lurek.debugbridge.broadcast("sim.analytics", json)` wysyĹ‚a go do VS Code.

PrzykĹ‚ad Lua-first:

```lua
local Sim = require("library.blocksim")
local Analytics = require("library.blocksim.analytics")

local scenario = require("scenarios.manufacturing_resilience")
local baseline, comparison, report

function lurek.init()
  baseline = Sim.newRun(scenario, { id = "baseline", anomalies_enabled = false, seed = 1001 })
  comparison = Sim.newRun(scenario, { id = "heat_test", anomalies_enabled = true, seed = 1001 })
end

function lurek.process(dt)
  if not baseline:isFinished() then baseline:stepTicks(10) return end
  if not comparison:isFinished() then comparison:stepTicks(10) return end
  if not report then
    report = Analytics.comparePair(baseline, comparison, scenario.analytics)
    lurek.filesystem.createDirectory("sim_runs")
    lurek.filesystem.writeJson("sim_runs/heat_test_analytics.json", lurek.serial.toJson(report, true))
    lurek.debugbridge.broadcast("sim.analytics", lurek.serial.toJson(report, false))
  end
end
```

## Konfiguracja analityki

Dla gry najwygodniejszy jest Lua module:

```lua
return {
  baseline = { run_id = "base", anomalies_enabled = false },
  comparison = { run_id = "heat", anomalies_enabled = true },
  kpis = {
    { id = "kpi_throughput", type = "throughput_rate", source_monitor = "watch_throughput", config = { window = 50 } },
    { id = "kpi_latency", type = "average_latency", source_monitor = "watch_latency" },
    { id = "kpi_cost_per_item", type = "cost_per_item", source_monitors = { "watch_cost", "watch_throughput" } },
  },
  comparisons = {
    { kpi = "kpi_throughput", method = "percent_change", significance_threshold = 5.0, direction = "decrease" },
    { kpi = "kpi_latency", method = "percent_change", significance_threshold = 10.0, direction = "increase" },
  },
  detection = {
    { rule = "threshold", monitor = "watch_queue", condition = "> 12", label = "queue_overflow" },
    { rule = "trend", monitor = "watch_throughput", condition = "declining 10", label = "throughput_decay" },
  },
  report = { format = "json", include = { "summary", "comparison_table", "timeline", "detections" } },
}
```

JeĹĽeli scenariusz ma byÄ‡ edytowany jako plik danych, uĹĽyÄ‡ TOML i `lurek.serial.fromToml`. JSON zostaje formatem raportĂłw i integracji z narzÄ™dziami.

## KPI w Lurek

| KPI | Implementacja |
|---|---|
| throughput, latency, error rate, utilization | Lua liczy z prĂłbek monitorĂłw; `lurek.dataframe` liczy `mean`, `median`, `stddev`, `p95` |
| cost per item, revenue per tick, cost of quality | Lua skĹ‚ada wartoĹ›ci z monitorĂłw value; `LDataFrame:sum`, `:groupAgg`, `:withPctChange` pomagajÄ… w raportach |
| bottleneck score, flow efficiency, cascade depth | Lua uĹĽywa stanu grafu i historii queue depth; Rust powinien daÄ‡ szybkie snapshoty grafu |
| recovery time, anomaly impact, resilience score | Lua jako reguĹ‚y domenowe, bo wagi i tolerancje sÄ… czÄ™Ĺ›ciÄ… gry/scenariusza |
| signal propagation delay | Wymaga prĂłbek sygnaĹ‚Ăłw; najlepiej w Rustowym monitorze, jeĹĽeli symulacja uroĹ›nie |

`lurek.dataframe` juĹĽ ma dobre minimum: `fromTable`, `describe`, `mean`, `median`, `stddev`, `variance`, `corr`, `withRollingMean`, `withPctChange`, `zscoreCol`, `query`, `toJSON`. To wystarcza do pierwszej wersji analityki bez DuckDB.

## PorĂłwnanie baseline/comparison

Walidacja pary musi byÄ‡ binarna:

- ten sam graf logiczny: te same bloki, krawÄ™dzie, typy itemĂłw i monitory,
- ten sam seed RNG,
- ten sam tick count,
- baseline ma wyĹ‚Ä…czone anomalie,
- comparison ma wĹ‚Ä…czony wybrany zestaw anomalii.

Brakuje wygodnego silnikowego API do hashowania definicji scenariusza. W Lua moĹĽna zaczÄ…Ä‡ od `lurek.serial.toJson(def, false)` i `lurek.data.hash` jeĹ›li funkcja hash jest dostÄ™pna, ale docelowo warto dodaÄ‡:

```lua
lurek.sim.hashScenario(def) -> string
lurek.sim.validateRunPair(base_snapshot, comparison_snapshot) -> boolean, string
```

## Detekcja anomalii

ReguĹ‚y detekcji sÄ… post-processingiem nad monitorami:

| ReguĹ‚a | Lurek implementacja |
|---|---|
| threshold | parser prostych warunkĂłw w Lua |
| trend | `LDataFrame:withRollingMean`, regresja liniowa w Lua albo Rust helper |
| correlation | `LDataFrame:corr` dla dwĂłch kolumn |
| overlap with injected anomalies | Lua porĂłwnuje zakresy tickĂłw i taguje `correlated_anomalies` |

Pierwsza wersja nie potrzebuje osobnego endpointu HTTP. Lurek runtime zapisuje raport i wysyĹ‚a event przez debug bridge. Rozszerzenie VS Code moĹĽe to odebraÄ‡.

## Format raportu

Raport powinien pozostaÄ‡ JSON, bo to jest zewnÄ™trzna integracja i Ĺ‚atwy format dla VS Code:

```json
{
  "report_id": "analytics_heat_test",
  "baseline": { "run_id": "base", "ticks": 500 },
  "comparison": { "run_id": "heat", "ticks": 500, "anomalies_active": ["heat_assembly"] },
  "summary": {},
  "kpi_results": [],
  "comparison_table": [],
  "timeline": [],
  "detections": []
}
```

Do zapisu uĹĽyÄ‡:

- `lurek.serial.toJson(report, true)`,
- `lurek.filesystem.writeJson("sim_runs/<id>_analytics.json", json)`,
- `lurek.debugbridge.broadcast("sim.analytics", json)` dla narzÄ™dzi.

## Braki w Lurek API

Priorytetowe braki, jeĹĽeli projekt ma byÄ‡ produkcyjny:

1. `lurek.sim` jako publiczny bridge do Rustowego `src/blocksim`: sim handle, block state, item queues, monitor sample, event log.
2. Stabilny `RunSnapshot` z `scenario_hash`, `monitor_hash`, `seed`, `tick_count`.
3. Helpery statystyczne dla percentyli i Welch t-test. CzÄ™Ĺ›Ä‡ da siÄ™ zrobiÄ‡ przez `lurek.dataframe`, ale t-test i p-value powinny byÄ‡ Rustowe.
4. API append JSONL: dzisiaj moĹĽna uĹĽyÄ‡ `lurek.filesystem.append`, ale wygodne byĹ‚oby `lurek.serial.writeJsonLine(path, table)`.
5. `lurek.debugbridge.broadcast` ma surowy JSON string; dla symulacji warto dodaÄ‡ konwencjÄ™ eventĂłw `sim.monitor`, `sim.analytics`, `sim.state`.

## VS Code extension

Dodatki do rozszerzenia:

- komenda `Lurek2D: Run Simulation Pair`, ktĂłra uruchamia baseline i comparison,
- webview `Simulation Analytics` z tabelÄ… KPI, timeline i wykresami,
- podglÄ…d `*_analytics.json` jako raport zamiast zwykĹ‚ego JSON,
- walidator scenariuszy Lua/TOML: brak monitora dla KPI, zĹ‚y target, mismatch baseline/comparison,
- snippets dla KPI i detection rules,
- debug bridge client dla eventĂłw `sim.analytics` i `sim.monitor`.

WaĹĽne: rozszerzenie jest warstwÄ… developerskÄ…. Silnik i gra muszÄ… dziaĹ‚aÄ‡ bez niego.

## Testy

- Lua tests dla `library/blocksim/analytics.lua`: percent change, absolute change, ratio, z-score, effect size, recovery time.
- Rust tests dotyczÄ… kernelowych monitor samples i event logu w `src/blocksim`; KPI pozostaje poza tick loop.
- Demo smoke test moĹĽe byÄ‡ ignorowany i robiÄ‡ screenshot dashboardu.
- Generated docs aktualizowaÄ‡ tylko wtedy, gdy dodamy publiczne `lurek.sim.*` API.

