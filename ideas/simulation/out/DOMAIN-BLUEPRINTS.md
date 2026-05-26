# Block Simulator w Lurek2D - blueprinty domen

Ten dokument przepisuje domenowe przykłady pod Lurek2D. Oryginalne YAML playbooki stają się Lua blueprintami, które zwracają zwykłe tabele. Dzięki temu scenario może zawierać callbacki, helpers i generatory, a nadal może być serializowane do JSON/TOML dla narzędzi.

## Zasada

Blueprint nie jest osobnym formatem silnika. Blueprint to funkcja Lua, która buduje definicję świata:

```lua
local Blueprint = {}

function Blueprint.softwareSprint(opts)
  opts = opts or {}
  return {
    simulation = { ticks = opts.ticks or 500, seed = opts.seed or 1001 },
    item_types = { { id = "feature_request" }, { id = "deployed_feature" } },
    resources = { { id = "engineers", capacity = opts.engineers or 4 } },
    blocks = {},
    edges = {},
    monitors = {},
    analytics = {},
  }
end

return Blueprint
```

W grze:

```lua
local Sim = require("library.blocksim")
local Blueprints = require("scenarios.blueprints")
local world

function lurek.init()
  world = Sim.newWorld(Blueprints.softwareSprint({ engineers = 5 }))
end

function lurek.process(dt)
  world:stepTicks(1)
end
```

## Biblioteki Lua

Proponowany podział:

| Plik | Rola |
|---|---|
| `library/blocksim/blueprints.lua` | fabryki domenowych scenariuszy |
| `library/blocksim/patterns.lua` | reusable patterns: saga, watchdog, heartbeat, canary, fan-out/fan-in |
| `library/blocksim/templates.lua` | parametryzowane bloki i composite |
| `library/blocksim/domain.lua` | mapowanie domen na block_class i item_types |
| `library/blocksim/schema.lua` | walidacja tabel przed uruchomieniem |

To pasuje do istniejącego stylu `library/*`: moduł expose jeden table, a gra ładuje go przez `require` albo `lurek.require`, zależnie od aktualnego sposobu w projekcie.

## Catalog pattern

Blueprinty domenowe nie powinny kopiować dużych definicji bloków. Stałe katalogi bloków, resource pools, monitorów i anomalii trzymać w TOML, a Lua używa ich jako template'ów.

```lua
local Sim = require("library.blocksim")
local machines = Sim.catalog.load("catalogs/blocks/machines.toml")

local blocks = {
  machines:instantiate("press_template", { id = "press_A" }),
  machines:instantiate("press_template", { id = "press_B", container = { capacity = 10 } }),
}
```

Edge topology i composite wiring zostają w Lua. To zastępuje YAML anchors i merge keys czytelnym kodem scenariusza.

## Blueprinty domenowe

| Domena | Blueprint Lua | Główne mechaniki |
|---|---|---|
| Manufacturing | `Blueprints.manufacturingAssembly(opts)` | resource pool, health, rework loop, QC router, backpressure |
| Healthcare ED | `Blueprints.emergencyDepartment(opts)` | priority queue, resource pools, aging escalation, admission join |
| Financial trades | `Blueprints.tradeLifecycle(opts)` | rate limiter, compliance split/join, circuit breaker, saga |
| ITSM incidents | `Blueprints.incidentFlow(opts)` | severity router, SLA aging, escalation, human approval |
| Logistics fulfillment | `Blueprints.fulfillment(opts)` | inventory resource, carrier windows, returns saga |
| CI/CD | `Blueprints.ciCdPipeline(opts)` | fork test suites, build agents, canary, rollback |
| HR recruitment | `Blueprints.recruitment(opts)` | approval gates, panel join, expiry, onboarding fan-out |
| Banking loans | `Blueprints.loanOrigination(opts)` | external API CB, valuation approval, committee time window |
| Energy fault | `Blueprints.powerGridFault(opts)` | alarm batch, crew dispatch, permit approval, restoration saga |
| Legal contracts | `Blueprints.contractLifecycle(opts)` | template bypass, legal review, negotiation aging, renewal |
| Construction | `Blueprints.constructionProject(opts)` | planning time window, procurement fan-out, weather gate |
| Retail buying | `Blueprints.merchPlanning(opts)` | supplier outcomes, QC route, allocation fan-out |
| Pharma pipeline | `Blueprints.drugDevelopment(opts)` | long tick scale, ethics resource, safety monitor, attrition |
| Public sector | `Blueprints.planningAuthority(opts)` | consultation fan-out, committee cycles, appeal path |
| Insurance claims | `Blueprints.claimsProcessing(opts)` | catastrophe context, inspector resource, settlement approval |

## Przykład: software feature pipeline

```lua
function Blueprint.softwareFeaturePipeline(opts)
  opts = opts or {}
  return {
    simulation = { ticks = opts.ticks or 300, seed = opts.seed or 42 },
    item_types = {
      { id = "feature_spec", unit = "tickets" },
      { id = "draft_code", unit = "changes" },
      { id = "approved_code", unit = "prs" },
      { id = "deployment", unit = "releases" },
    },
    resources = {
      { id = "engineers", capacity = opts.engineers or 4 },
      { id = "ci_runners", capacity = opts.ci_runners or 2 },
    },
    blocks = {
      Sim.block.source("requirements", { output = "feature_spec", interval_ticks = 2 }),
      Sim.block.process("developer", {
        block_class = "person",
        input = "feature_spec",
        output = "draft_code",
        processing_ticks = 4,
        resource = { pool = "engineers", slots = 1 },
        fail_chance = 0.05,
        value_cost = { amount = 150, type = "labor" },
      }),
      Sim.block.process("code_review", {
        input = "draft_code",
        output = "approved_code",
        processing_ticks = 2,
        outcome_distribution = {
          { outcome = "approved", probability = 0.75, output_type = "approved_code" },
          { outcome = "rejected", probability = 0.25, output_type = "draft_code" },
        },
      }),
      Sim.block.process("deploy", {
        input = "approved_code",
        output = "deployment",
        processing_ticks = 1,
        resource = { pool = "ci_runners", slots = 1 },
        value_out = { amount = opts.value_per_feature or 1000, type = "business_value" },
      }),
      Sim.block.sink("production", { input = "deployment" }),
    },
    edges = {
      { from = "requirements", to = "developer", type = "data", item_type = "feature_spec" },
      { from = "developer", to = "code_review", type = "data", item_type = "draft_code" },
      { from = "code_review", to = "developer", type = "data", item_type = "draft_code", when = "rejected" },
      { from = "code_review", to = "deploy", type = "data", item_type = "approved_code" },
      { from = "deploy", to = "production", type = "data", item_type = "deployment" },
    },
  }
end
```

`Sim.block.*` to helpery Lua, nie nowe engine API. One tworzą tabele zgodne z `library/blocksim/schema.lua`.

## Cross-cutting patterns w Lurek

| Pattern | Lua helper |
|---|---|
| heartbeat | `Patterns.heartbeat(source_id, sink_id, opts)` |
| watchdog | `Patterns.watchdog(target_id, monitor_id, opts)` |
| catch-up replay | `Patterns.dlqReplay(dlq_id, target_id, opts)` |
| blue/green routing | `Patterns.blueGreen(router_id, blue_id, green_id, opts)` |
| shadow mode | `Patterns.shadow(primary_id, shadow_id, comparator_id, opts)` |
| canary release | `Patterns.canary(router_id, stages, opts)` |
| saga | `Patterns.saga(id, blocks, compensation_edges)` |
| fan-out/fan-in | `Patterns.forkJoin(split_id, join_id, lanes, opts)` |
| priority lane | `Patterns.priorityLane(router_id, high_id, normal_id, opts)` |
| health degradation | `Patterns.equipmentLifecycle(block_id, maintenance_id, opts)` |

Te helpers powinny zwracać fragmenty: `{ blocks = {}, edges = {}, monitors = {} }`, a `Sim.compose(...)` składa je w jeden scenariusz.

## Skille domenowe w projekcie

Stare `SKILLS-COVERAGE.md` opisywało agent skills dla innego stacku. W Lurek lepiej potraktować to jako dwa rodzaje wiedzy:

1. Gameplay/domain skills: zestawy gotowych template'ów i patternów w `library/blocksim`.
2. Authoring skills: instrukcje dla CAG/VS Code, które pomagają generować scenariusze.

Nie przenosić starych Next.js/Tailwind/DuckDB skills. Lurek runtime nie potrzebuje tego. Dla VS Code można dodać snippets i prompt/skill tylko wtedy, gdy faktycznie wspiera authoring scenario packs.

## Dane i import/export

- Lua blueprint jest źródłem prawdy dla uruchamianych scenariuszy.
- TOML pack jest dobry dla użytkownika, który chce zmieniać parametry bez kodu.
- JSON jest dobry dla eksportu do VS Code i raportów.
- `lurek.serial.validate` i `applyDefaults` powinny walidować blueprint przed `Sim.newWorld`.

## VS Code extension

Potrzebne widoki:

- `Simulation Blueprints`: lista dostępnych `Blueprints.*`, parametry i szybkie uruchomienie.
- `Scenario Outline`: blocks/resources/item_types/monitors/anomalies.
- `Graph Preview`: statyczny podgląd bez uruchamiania gry.
- `Template Insert`: wstaw manufacturing line, approval flow, saga, fork/join.
- Diagnostyka domenowa: np. approval-heavy bez monitorów approval queue, manufacturing bez health/resource monitorów.

## Testy

Każdy blueprint powinien mieć mały smoke test Lua:

- buduje definicję,
- przechodzi `Sim.schema.validate(def)`,
- uruchamia 10-50 ticków,
- sprawdza, że są itemy, eventy i monitor samples.
