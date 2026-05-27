# Block Simulator w Lurek2D - anomalie i chaos

Ten dokument przepisuje mechanikę anomalii pod Lurek2D. Celem jest digital twin runtime, w którym Lua wybiera i konfiguruje scenariusze, a produkcyjny tick loop i anomaly engine mieszkają w `src/blocksim/`.

## Decyzja architektoniczna

Anomalie są warstwą nakładaną na normalną symulację. Nie zastępują logiki bloków. Aktywują się na podstawie warunków, modyfikują istniejące uchwyty systemu i wygasają według warunków.

Docelowy podział:

| Warstwa | Odpowiedzialność |
|---|---|
| `library/blocksim/anomaly.lua` | definicje anomalii, warunki aktywacji, expiry, interpretacja configu |
| `library/blocksim/world.lua` | Lua spike tick loop, kolejność faz, wywołanie anomalii i monitorów |
| `lurek.math.newRandomGenerator(seed)` | deterministyczny RNG, `random`, `randomInt`, `randomNormal`, zapis stanu RNG |
| `lurek.graph` | istniejący graf, node/edge capacity, active state, item type routing; dobry fundament, ale nie pełny block simulator |
| `src/blocksim/` + `lurek.sim` | szybkie kontenery, block state machine, event stream, monitor samples, anomaly hooks |
| `lurek.serial` + `lurek.filesystem` | zapis JSONL/JSON i TOML scenario packs |
| `lurek.debugbridge` | live anomaly events dla VS Code |

Nie używać YAML. Scenariusze jako Lua tables, a data-only packs jako TOML.

## Fazy ticka

Kolejność powinna być stała:

1. `pre_tick`: aktywuj nowe anomalie, zastosuj efekty aktywnych anomalii.
2. `step_graph`: przesuń itemy, przetwórz bloki według priorytetu.
3. `deliver_signals`: dostarcz sygnały i eventy.
4. `post_tick`: sprzątanie efektów jednorazowych, expiry anomalii.
5. `monitor_pass`: zbierz próbki monitorów.
6. `log_pass`: zapisz eventy i wyślij debug bridge.

W Lurek robi to Lua world:

```lua
function world:step()
  self.tick = self.tick + 1
  self.anomalies:preTick(self)
  self.blocks:step(self)
  self.signals:drain(self)
  self.anomalies:postTick(self)
  self.monitors:collect(self)
end
```

W Rustowym `src/blocksim` fazy są bardziej szczegółowe: clock, anomaly_eval, circuit_check, rate_limit, block_exec, resource_release, value_rollup, monitor_sample. Model Lua spike powinien pozostać zgodny z tą kolejnością.

## Zasada V1 dla inject

W V1 anomalie muszą być zadeklarowane w specyfikacji lub katalogu TOML i wybrane przez scenariusz Lua przed utworzeniem symulacji. `lurek.sim.inject_anomaly(sim, anomaly_id)` nie tworzy nowej anomalii ad-hoc. Ono tylko wymusza aktywację istniejącej zadeklarowanej anomalii.

To chroni determinism, walidację targetów i replay. Ad-hoc anomaly object może być V2, ale tylko z pełną walidacją i eventem w logu.

## Konfiguracja Lua

```lua
anomalies = {
  {
    id = "heat_assembly",
    type = "heat_buildup",
    target = "assembly_line",
    trigger = {
      logic = "and",
      conditions = {
        { type = "block_state", state = "processing" },
        { type = "time_elapsed_in_state", ticks = 5 },
      },
    },
    effect = { system = "script", mutation = "progressive_slowdown" },
    expiry = { type = "block_state", state = "idle" },
    config = {
      heat_per_processing_tick = 0.02,
      cooldown_per_idle_tick = 0.01,
      slowdown_per_heat = 0.5,
      thermal_shutdown_at = 1.0,
      shutdown_duration = 10,
    },
  },
}
```

## Warunki aktywacji

Warunki najlepiej utrzymać jako mały interpreter Lua. To daje elastyczność bez dopisywania wielu bindingów.

| Condition | Źródło danych w Lurek |
|---|---|
| `probability` | `LRandomGenerator:random()` |
| `tick_range` | `world.tick` |
| `time_window` | `world.clock` w Lua; później Rustowy calendar helper |
| `queue_overflow`, `queue_empty` | `block.container:size()` albo Rust snapshot |
| `block_state` | `block.state` |
| `signal_received` | `world.signals:count(target, name)` |
| `value_threshold` | value ledger w `world.metrics` |
| `data_threshold` | container query w Lua, Rust helper dla dużych kolejek |
| `time_elapsed_in_state` | `block.state_since_tick` |

## Efekty anomalii

Każdy efekt musi modyfikować istniejący system: block state, script params, data, signal, value, filter, container albo port. To pasuje do Lurek, bo gra w Lua może mieć tabelę stanu, a Rust może dostać małe metody mutujące.

| System | Lua-first | Rust API, jeżeli trzeba |
|---|---|---|
| block_state | `world:setBlockState(id, state, reason)` | `LWorld:setBlockState` |
| script | `block.params.processing_ticks = ...` | szybkie effective param snapshoty |
| data | mutacja `item.data`, tagi, typ itemu | `LItem:setField`, batch mutate |
| signal | drop, delay, inject przez `world.signals` | event queue w Rust |
| value | `world.value:emit(...)` | value ledger i aggregation |
| filter | gate open/close, threshold shift | `LBlock:setGate`, `LBlock:setFilterParam` |
| container | capacity, overflow, loss | Rust queue dla dużych symulacji |
| port/edge | throttle, disconnect, speed modifier | istniejące `LGraphEdge:setActive`, `setThroughput`, `setSpeedModifier`, `setCapacity` |

## Katalog 24 anomalii

| ID | Anomalia | Lurek implementation |
|---|---|---|
| s14.1 Flow Resistance | dodaje effective processing ticks według queue depth | Lua param override; Rust helper później |
| s14.2 Pressure Buildup | spowalnia upstream według downstream fill ratio | wymaga upstream traversal; użyć `lurek.graph:getNeighbors` albo world adjacency |
| s14.3 Turbulence | losuje processing time z rozkładu | `LRandomGenerator:randomNormal` |
| s14.4 Leakage | usuwa itemy z kontenera | Lua dla małych kolejek; Rust batch remove dla dużych |
| s14.5 Cavitation | stall po pustej kolejce, restart penalty | Lua state counters |
| s14.6 Thermal Noise | jitter timingów | `LRandomGenerator:randomInt` |
| s14.7 Heat Buildup | heat counter, slowdown, shutdown | Lua state + block state mutation |
| s14.8 Entropy Increase | psucie pól itemów | Lua item mutation; potrzebny helper copy/hash dla audit |
| s14.9 Phase Transition | skokowy switch configu po progu | Lua override stack |
| s14.10 Impedance Mismatch | odbicie itemów do poprzedniego bloku | potrzebne reverse edge lookup |
| s14.11 Signal Attenuation | drop signal per hop | world signal queue; hop count z grafu |
| s14.12 Crosstalk | item skacze między ścieżkami | Lua container move |
| s14.13 Short Circuit | bypass jednego bloku | `LGraphEdge`/world routing override |
| s14.14 Brownout | capacity resource pool spada | resource pool state; Rust pole capacity mile widziane |
| s14.15 Quantum Tunneling | bypass wielu bloków małym prawdopodobieństwem | path traversal + item teleport |
| s14.16 Superposition | probabilistyczny outcome | `lurek.patterns.newWeightedRandom` albo Lua cumulative roll |
| s14.17 Entanglement | korelacja wyników dwóch bloków | shared anomaly state per tick |
| s14.18 Observer Effect | monitor/tap dodaje koszt pomiaru | world count of monitors/taps per block |
| s14.19 Catalyst | boost sąsiadów | graph radius traversal |
| s14.20 Corrosion | edge reliability degraduje | `LGraphEdge:setSpeedModifier`, `setThroughput`, plus loss in routing |
| s14.21 Chain Reaction | awaria propaguje po grafie | delayed events queue |
| s14.22 Saturation | throughput cap przy dużej kolejce | Lua capacity formula |
| s14.23 Byzantine Failure | blok wygląda zdrowo, ale psuje output | output hook after success |
| s14.24 Clock Drift | lokalny tick bloku odpływa od globalnego | `block.local_tick = world.tick + drift` |

## Event schema

Każde zdarzenie anomalii zapisujemy jako zwykłą tabelę Lua i serializujemy do JSON:

```lua
local event = {
  tick = world.tick,
  event = "ANOMALY_EFFECT",
  anomaly_id = anomaly.id,
  anomaly_type = anomaly.type,
  target = target_id,
  details = { heat_level = 0.75, effective_ticks = 8 },
}
world.events:push(event)
lurek.debugbridge.broadcast("sim.anomaly", lurek.serial.toJson(event, false))
```

W pliku można pisać JSONL przez `lurek.filesystem.append(path, lurek.serial.toJson(event, false) .. "\n")`.

## Braki w Lurek API

Lua spike może działać tymczasowo. Produkcyjny API powinien być zgodny z `src/blocksim`:

```lua
lurek.sim.create(spec : table) -> sim, err
lurek.sim.step(sim, ticks : integer?) -> stats, err
lurek.sim.inject_anomaly(sim, anomaly_id : string) -> ok, err
lurek.sim.expire_anomaly(sim, anomaly_id : string) -> ok, err
lurek.sim.anomaly_status(sim) -> table
lurek.sim.drain_events(sim) -> table
lurek.sim.drain_monitors(sim) -> table
```

Rustowy moduł powinien mieszkać w `src/blocksim/` jako Tier 2 headless kernel. Bindingi tylko w `src/lua_api/blocksim_api.rs`. `src/lua_api` nie może zawierać logiki domenowej.

## VS Code extension

Potrzebne funkcje:

- walidacja anomalii: `target` istnieje, `effect.system` pasuje do targetu, `expiry` ma wymagane pola,
- hover i autocomplete dla `type = "heat_buildup"`, `mutation = "progressive_slowdown"`, itp.,
- panel timeline anomalii z eventów `sim.anomaly`,
- komenda `Insert Anomaly Template`,
- wizualne podświetlenie bloków i krawędzi dotkniętych aktywną anomalią,
- ostrzeżenie, gdy użyto YAML zamiast Lua/TOML.

## Testy

- Lua unit tests: trigger logic, expiry logic, każde 24 `type` przynajmniej raz.
- Lua integration tests: manufacturing stress scenario z deterministycznym seedem.
- Rust tests dla `src/blocksim/anomaly.rs` po przeniesieniu queue/event core.
- Golden JSON: eventy `ANOMALY_ACTIVATED`, `ANOMALY_EFFECT`, `ANOMALY_EXPIRED`, `ANOMALY_CASCADE`, `ANOMALY_BLOCKED`.
