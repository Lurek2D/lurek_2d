# Block Simulator w Lurek2D - analityka before/after

Ten dokument przepisuje pierwotny pomysł analityki pod Lurek2D. Analityka jest warstwą po runie: Rustowy `src/blocksim` emituje monitor samples i event log, a Lua oraz `lurek.dataframe` liczą KPI i raporty.

## Decyzja architektoniczna

Analityka jest procesem po symulacji. Nie modyfikuje tick loop, nie zmienia stanu bloków i nie jest częścią renderowania. Czyta próbki monitorów, liczy KPI, porównuje baseline z wariantem anomalii i zapisuje raport.

Docelowy podział:

| Warstwa | Odpowiedzialność |
|---|---|
| Lua `library/blocksim/analytics.lua` | definicje KPI, reguły porównań, interpretacja wyników, składanie raportu |
| Lua `content/games/block_sim/` | scenariusze, ekrany dashboardu, komendy użytkownika |
| Rust `lurek.dataframe` | statystyki, rolling windows, percent change, z-score, korelacje |
| Rust `lurek.serial` | JSON/TOML import-export raportów i konfiguracji |
| Rust `lurek.filesystem` | zapis `save/sim_runs/*_monitors.jsonl` i `*_analytics.json` |
| Rust `lurek.thread` | opcjonalne liczenie raportu poza główną klatką |
| Rust `lurek.debugbridge` | wysyłka raportów i próbek do rozszerzenia VS Code |
| `extensions/vscode` | panel porównania runów, wykresy, szybkie uruchamianie baseline/comparison |

Nie używać YAML. Konfiguracje czysto danych powinny być TOML. Scenariusze, które zawierają funkcje, callbacki albo niestandardowe formuły, powinny być Lua modules zwracającymi tabele.

## Pipeline w Lurek

1. `lurek.init()` ładuje scenariusz i tworzy dwa runy: baseline i comparison.
2. `lurek.process(dt)` krokuje symulację. Dla szybkiego trybu używa akumulatora logicznych ticków, nie czasu klatki.
3. Monitor engine zapisuje próbki w strukturze Lua i opcjonalnie do pliku przez `lurek.filesystem.write` albo append przez `lurek.filesystem.append`.
4. Po zakończeniu obu runów `SimAnalytics.comparePair(baseline, comparison, config)` liczy KPI.
5. Wynik idzie do `lurek.serial.toJson(report, true)` i `lurek.filesystem.writeJson(path, json)`.
6. `lurek.draw_ui()` pokazuje raport w UI, a `lurek.debugbridge.broadcast("sim.analytics", json)` wysyła go do VS Code.

Przykład Lua-first:

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

Jeżeli scenariusz ma być edytowany jako plik danych, użyć TOML i `lurek.serial.fromToml`. JSON zostaje formatem raportów i integracji z narzędziami.

## KPI w Lurek

| KPI | Implementacja |
|---|---|
| throughput, latency, error rate, utilization | Lua liczy z próbek monitorów; `lurek.dataframe` liczy `mean`, `median`, `stddev`, `p95` |
| cost per item, revenue per tick, cost of quality | Lua składa wartości z monitorów value; `LDataFrame:sum`, `:groupAgg`, `:withPctChange` pomagają w raportach |
| bottleneck score, flow efficiency, cascade depth | Lua używa stanu grafu i historii queue depth; Rust powinien dać szybkie snapshoty grafu |
| recovery time, anomaly impact, resilience score | Lua jako reguły domenowe, bo wagi i tolerancje są częścią gry/scenariusza |
| signal propagation delay | Wymaga próbek sygnałów; najlepiej w Rustowym monitorze, jeżeli symulacja urośnie |

`lurek.dataframe` już ma dobre minimum: `fromTable`, `describe`, `mean`, `median`, `stddev`, `variance`, `corr`, `withRollingMean`, `withPctChange`, `zscoreCol`, `query`, `toJSON`. To wystarcza do pierwszej wersji analityki bez DuckDB.

## Porównanie baseline/comparison

Walidacja pary musi być binarna:

- ten sam graf logiczny: te same bloki, krawędzie, typy itemów i monitory,
- ten sam seed RNG,
- ten sam tick count,
- baseline ma wyłączone anomalie,
- comparison ma włączony wybrany zestaw anomalii.

Brakuje wygodnego silnikowego API do hashowania definicji scenariusza. W Lua można zacząć od `lurek.serial.toJson(def, false)` i `lurek.data.hash` jeśli funkcja hash jest dostępna, ale docelowo warto dodać:

```lua
lurek.sim.hashScenario(def) -> string
lurek.sim.validateRunPair(base_snapshot, comparison_snapshot) -> boolean, string
```

## Detekcja anomalii

Reguły detekcji są post-processingiem nad monitorami:

| Reguła | Lurek implementacja |
|---|---|
| threshold | parser prostych warunków w Lua |
| trend | `LDataFrame:withRollingMean`, regresja liniowa w Lua albo Rust helper |
| correlation | `LDataFrame:corr` dla dwóch kolumn |
| overlap with injected anomalies | Lua porównuje zakresy ticków i taguje `correlated_anomalies` |

Pierwsza wersja nie potrzebuje osobnego endpointu HTTP. Lurek runtime zapisuje raport i wysyła event przez debug bridge. Rozszerzenie VS Code może to odebrać.

## Format raportu

Raport powinien pozostać JSON, bo to jest zewnętrzna integracja i łatwy format dla VS Code:

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

Do zapisu użyć:

- `lurek.serial.toJson(report, true)`,
- `lurek.filesystem.writeJson("sim_runs/<id>_analytics.json", json)`,
- `lurek.debugbridge.broadcast("sim.analytics", json)` dla narzędzi.

## Braki w Lurek API

Priorytetowe braki, jeżeli projekt ma być produkcyjny:

1. `lurek.sim` jako publiczny bridge do Rustowego `src/blocksim`: sim handle, block state, item queues, monitor sample, event log.
2. Stabilny `RunSnapshot` z `scenario_hash`, `monitor_hash`, `seed`, `tick_count`.
3. Helpery statystyczne dla percentyli i Welch t-test. Część da się zrobić przez `lurek.dataframe`, ale t-test i p-value powinny być Rustowe.
4. API append JSONL: dzisiaj można użyć `lurek.filesystem.append`, ale wygodne byłoby `lurek.serial.writeJsonLine(path, table)`.
5. `lurek.debugbridge.broadcast` ma surowy JSON string; dla symulacji warto dodać konwencję eventów `sim.monitor`, `sim.analytics`, `sim.state`.

## VS Code extension

Dodatki do rozszerzenia:

- komenda `Lurek2D: Run Simulation Pair`, która uruchamia baseline i comparison,
- webview `Simulation Analytics` z tabelą KPI, timeline i wykresami,
- podgląd `*_analytics.json` jako raport zamiast zwykłego JSON,
- walidator scenariuszy Lua/TOML: brak monitora dla KPI, zły target, mismatch baseline/comparison,
- snippets dla KPI i detection rules,
- debug bridge client dla eventów `sim.analytics` i `sim.monitor`.

Ważne: rozszerzenie jest warstwą developerską. Silnik i gra muszą działać bez niego.

## Testy

- Lua tests dla `library/blocksim/analytics.lua`: percent change, absolute change, ratio, z-score, effect size, recovery time.
- Rust tests dotyczą kernelowych monitor samples i event logu w `src/blocksim`; KPI pozostaje poza tick loop.
- Demo smoke test może być ignorowany i robić screenshot dashboardu.
- Generated docs aktualizować tylko wtedy, gdy dodamy publiczne `lurek.sim.*` API.
