# Block Simulator w Lurek2D - skills coverage

Ten dokument przepisuje dawną macierz skills pod Lurek2D. W starym projekcie skills były plikami `.github/skills` dla agentów i authoringu YAML/Next.js. W Lurek trzeba rozdzielić trzy rzeczy:

1. mechaniczne umiejętności symulacji, czyli funkcje `library/blocksim`,
2. domenowe template'y, czyli gotowe blueprinty procesów,
3. skills dla CAG/VS Code, które pomagają autorowi tworzyć scenariusze, ale nie są częścią runtime.

## Decyzja

Nie przenosić starych skills jeden do jednego. Lurek ma własne CAG skills i własne repo rules. Stary zestaw Next.js, Tailwind, Flask, DuckDB, YAML nie pasuje bezpośrednio.

Docelowo:

| Typ | Gdzie mieszka | Użycie |
|---|---|---|
| Runtime mechanics | `library/blocksim/*.lua` | gra/symulacja używa w runtime |
| Domain blueprints | `content/games/block_sim/scenarios/*.lua` albo `library/blocksim/blueprints.lua` | szybki start dla domen |
| Authoring guidance | `.github/skills/simulation-*` lub VS Code snippets | pomoc przy pisaniu scenariuszy |
| API data | generated `extensions/vscode/data/lurek-api.json` | autocomplete i hover dla `lurek.*` |

## Mechanic coverage w `library/blocksim`

| Grupa | Plik Lua | Mechaniki |
|---|---|---|
| node/block core | `block.lua`, `world.lua` | s4-s12 |
| containers | `container.lua` | s4.3, s13.9, s13.11 |
| resources | `resource.lua` | s13.1, s13.12, s13.14, s13.19 |
| flow control | `flow.lua` | s13.7, s13.8, s13.13, s13.16, s13.20 |
| reliability | `reliability.lua` | s13.2, s13.14, s13.21, s13.24, s13.31 |
| value/economics | `value.lua` | s7, s13.5, s13.18, s13.33 |
| approval/dlq | `approval.lua`, `dlq.lua` | s13.15, s13.24, s13.27 |
| observation | `monitor.lua`, `analytics.lua` | s13.22, s13.25, s15, s16 |
| clock/context | `clock.lua`, `scenario.lua` | s13.17, s13.23, s13.28, s13.29, s13.32 |
| anomalies | `anomaly.lua` | s14.1-s14.24 |

## Domain coverage

Blueprint coverage should be tracked as tests, not only docs.

| Domena | Blueprint | Minimalny smoke test |
|---|---|---|
| Manufacturing | `manufacturingAssembly` | queue, resource, rework, QC, anomaly heat |
| Healthcare | `emergencyDepartment` | triage priority, doctor pool, admission bottleneck |
| Finance/trading | `tradeLifecycle` | compliance split/join, settlement window, saga |
| ITSM | `incidentFlow` | P1 fast lane, escalation, SLA aging |
| Logistics | `fulfillment` | inventory, pack/ship, carrier time window |
| CI/CD | `ciCdPipeline` | fork tests, build agent pool, rollback |
| HR | `recruitment` | panel join, background check, onboarding fan-out |
| Banking | `loanOrigination` | credit API CB, valuation approval, committee window |
| Energy | `powerGridFault` | alarms, crew resource, permit approval |
| Legal | `contractLifecycle` | review, negotiation aging, e-sign CB |
| Construction | `constructionProject` | planning window, weather gate |
| Retail | `merchPlanning` | supplier outcomes, QC, allocation |
| Pharma | `drugDevelopment` | long clock, trial gates, safety monitor |
| Public sector | `planningAuthority` | consultation fan-out, committee cycle |
| Insurance | `claimsProcessing` | catastrophe context, inspector resource, settlement approval |

## Authoring skills dla CAG

Jeżeli dodawać nowe CAG skills, proponowany minimalny zestaw:

| Skill | Kiedy ładować | Zakres |
|---|---|---|
| `simulation-scripting` | pisanie `library/blocksim` albo scenariuszy Lua | callbacki Lurek, Lua DSL, testy Lua |
| `simulation-blueprints` | tworzenie domenowego scenariusza | dobór bloków, itemów, resources, monitors |
| `simulation-monitoring` | monitory i analytics | monitor config, KPI, alert rules |
| `simulation-vscode-tools` | rozszerzenie VS Code dla symulacji | debug bridge, snippets, diagnostics |

Nie mieszać ich z runtime skills. CAG skills pomagają agentom; `library/blocksim` jest kodem gry.

## VS Code authoring features

Zamiast przenosić stare skill docs, rozszerzenie powinno mieć:

- snippets: `sim.block.process`, `sim.monitor.queue`, `sim.anomaly.heat`, `sim.analytics.kpi`,
- diagnostics dla scenario Lua/TOML,
- quick fix: dodaj monitor wymagany przez KPI,
- hover: mechanika s13/s14/s15, wyjaśnienie pól,
- command palette: `Create Simulation Blueprint`, `Run Simulation Smoke`, `Open Simulation Report`,
- generated schema z `library/blocksim/schema.lua` albo JSON schema eksportowanego przez narzędzie.

## Jak mierzyć coverage

Każda mechanika ma trzy poziomy pokrycia:

| Poziom | Wymaganie |
|---|---|
| documented | opisana w `ideas/simulation/out` albo docelowo `docs/specs/blocksim.md` |
| implemented | istnieje handler/helper w `library/blocksim` albo `src/blocksim` |
| tested | jest Lua/Rust test oraz przynajmniej jeden blueprint smoke, jeżeli mechanika jest domenowa |

Prosty raport może być Lua table:

```lua
return {
  mechanics = {
    ["s13.14"] = { documented = true, implemented = true, tested = true },
    ["s14.23"] = { documented = true, implemented = false, tested = false },
  },
  domains = {
    manufacturing = { blueprint = true, smoke = true },
    pharma = { blueprint = true, smoke = false },
  },
}
```

VS Code może renderować to jako coverage matrix.

## Braki do uzupełnienia

Największe luki, które warto zamknąć pierwsze:

1. Approval-heavy domains: HR, banking, insurance, public sector potrzebują więcej gotowych patterns.
2. Hybrid domains: pharma, healthcare, retail potrzebują długiego clocka i multi-layer composite examples.
3. Schema evolution, simulation clock i block priority powinny mieć przykłady, bo są łatwe do pominięcia.
4. Analytics examples powinny pokazywać end-to-end: run -> monitors -> analytics -> dashboard.
5. VS Code diagnostics powinny rozumieć, że Lurek używa Lua/TOML, nie YAML.

## Testy coverage

- Test `library/blocksim/coverage.lua` sprawdza, że każdy mechanic ID ma handler albo celowo `deferred`.
- Test blueprintów sprawdza, że każdy domain blueprint buduje poprawny scenariusz.
- Test snippets w extension sprawdza, że generowane snippet labels są zgodne z `library/blocksim/schema.lua`.

## Migration note

Stare skills o DuckDB i React mogą być inspiracją dla raportów, ale nie są dependency. Lurek ma własny UI i DataFrame API. Jeżeli kiedyś będzie eksport zewnętrzny, JSON raportów wystarczy dla narzędzi poza silnikiem.
