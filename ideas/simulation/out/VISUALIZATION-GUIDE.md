# Block Simulator w Lurek2D - wizualizacja

Ten dokument przepisuje wizualizację pod Lurek2D. Widok symulacji może być normalnym ekranem gry: canvas grafu w `lurek.draw()` i dashboard w `lurek.draw_ui()`. Rozszerzenie VS Code może mieć dodatkowy podgląd, ale runtime nie zależy od extension.

## Decyzja UI

| Element | Lurek API |
|---|---|
| canvas bloków i krawędzi | `lurek.render.rectangle`, `line`, `circle`, `print`, `setColor` |
| wykresy i panele | `lurek.ui.newLineChart`, `newBarChart`, `newTable`, `newTreeView`, `newProgressBar`, `newWindow` |
| HTML/HUD | `lurek.html` dla prostszych paneli, jeśli wygodniejsze niż retained UI |
| kamera/zoom/pan | `lurek.camera` albo własna transformacja w Lua |
| input | `lurek.input` i callbacki mouse/key |
| live tooling | `lurek.debugbridge.broadcast` |
| zapis screenshotów | `lurek.render.saveScreenshot`, `captureScreenshot` |

Nie używać web-only rozwiązań jako wymagania runtime. React/Next.js może być inspiracją, ale Lurek UI jest natywne dla gry.

## Layout bloków

Blok jest prostokątem z portami po bokach. Lewa strona to wejścia, prawa to wyjścia. Flow zawsze lewo -> prawo.

Proponowany model renderowania:

```lua
local Canvas = {}

function Canvas.drawBlock(block, x, y)
  local w, h = 180, 92
  local color = Canvas.stateColor(block.state)
  lurek.render.setColor(color.r, color.g, color.b, 1)
  lurek.render.rectangle("line", x, y, w, h, 4, 4)
  lurek.render.print(block.label or block.id, x + 10, y + 8)
  Canvas.drawPorts(block, x, y, w, h)
  Canvas.drawQueueBar(block, x + 10, y + h - 18, w - 20, 8)
end
```

Port symbols w UI mogą zostać tekstem albo małymi shape'ami:

| Port | Strona | Render |
|---|---|---|
| trigger_in | left top | triangle icon |
| filter_in | left mid | diamond icon |
| data_in | left lower | square icon |
| value_in | left bottom | plus-circle or small circle with plus |
| event_out | right top | inverted triangle |
| value_cost | right mid | minus-circle |
| value_out | right mid | circle |
| data_out | right lower | square icon |

Jeżeli brakuje icon API, użyć prostych kształtów z `lurek.render.polygon`, `rectangle`, `circle`.

## Edge styles

| Edge type | Styl |
|---|---|
| data | solid line, kolor per item type |
| signal | dashed amber |
| filter | dashed purple |
| value | dashed green |
| backpressure | dashed red, mocne highlight gdy active |
| resource | dotted gray |
| compensation | dashed orange |
| tap | dotted teal, niższa opacity |

`lurek.render.line` nie musi mieć dashed line built-in. W Lua można narysować dashed polyline ręcznie segmentami. Dla wielu krawędzi warto później dodać Rust/helper `lurek.render.dashedLine` albo `library/blocksim/render.drawDashedLine`.

## State indicators

| State | Wygląd |
|---|---|
| idle | szary border |
| waiting | żółty border, lekki pulse |
| processing | niebieski border, animacja lub progress |
| failed | czerwony border |
| maintenance | fioletowy albo pomarańczowy border |
| cb_open | czerwony/ciemny border z label CB |
| waiting_approval | żółty border + approval badge |

Queue bar:

| Fill ratio | Kolor |
|---|---|
| 0-50% | zielony |
| 50-80% | żółty |
| 80-95% | pomarańczowy |
| 95-100% | czerwony |

## Composite drill-in

Composite drill-in jest stanem UI:

```lua
ui.path = { "root", "software_dept", "dev_team" }
```

Widok renderuje aktualny subgraph. Boundary ports są pinned do lewej/prawej ściany canvasu.

Controls:

- double click block composite -> push path,
- breadcrumb click -> pop path,
- mouse wheel -> zoom,
- middle/drag -> pan,
- click block -> side panel with state, queue, monitors, anomalies.

## Dashboard panels

Użyć `lurek.ui`:

| Panel | Widget |
|---|---|
| Queue depth over time | `newLineChart` |
| Throughput per window | `newBarChart` |
| Bottleneck ranking | `newBarChart` albo `newTable` |
| Resource utilization | `newProgressBar` |
| DLQ entries | `newTable` |
| Approvals | `newTable` |
| Active anomalies | `newTable` + timeline |
| Composite tree | `newTreeView` |
| KPI comparison | `newTable` + `newLineChart` |

Przykład UI setup:

```lua
local dashboard = {}

function dashboard.init(world)
  dashboard.queue_chart = lurek.ui.newLineChart({ title = "Queue depth" })
  dashboard.kpi_table = lurek.ui.newTable()
  dashboard.anomaly_table = lurek.ui.newTable()
end

function dashboard.update(world)
  local sample = world.monitors:latest("watch_assembly_queue")
  if sample then dashboard.queue_chart:addPoint(sample.tick, sample.value) end
end
```

Nazwy metod chartów trzeba potwierdzić w aktualnym `lurek.ui` przed implementacją. Konstruktor `newLineChart` istnieje.

## Heat map overlays

Canvas powinien mieć tryb overlay:

- throughput,
- utilization,
- queue depth,
- cost,
- error rate,
- anomaly severity.

Overlay liczy kolor z monitor samples. Nie dotyka symulacji.

## Item flow particles

Dla czytelności można rysować lightweight particles po krawędziach. To nie musi być `lurek.particle`; proste punkty w Lua wystarczą:

```lua
for _, transit in ipairs(world.transit_items) do
  local x, y = Canvas.edgePoint(transit.edge, transit.progress)
  lurek.render.circle("fill", x, y, 3)
end
```

Jeżeli itemów jest bardzo dużo, renderować tylko zagregowane strumienie: grubość krawędzi i licznik.

## VS Code preview

Rozszerzenie powinno dawać podgląd authoringowy, nie zastępować runtime UI:

- static graph preview z scenario file,
- live graph inspector z debug bridge,
- analytics report viewer,
- monitor timeline,
- quick navigation: block id -> definition in Lua/TOML.

Debug bridge eventy:

```lua
lurek.debugbridge.broadcast("sim.snapshot", lurek.serial.toJson(world:getSnapshot({ compact = true }), false))
lurek.debugbridge.broadcast("sim.monitor", lurek.serial.toJson(sample, false))
lurek.debugbridge.broadcast("sim.analytics", lurek.serial.toJson(report, false))
```

## Braki w Lurek/API/UI

Możliwe braki do dodania po prototypie:

1. `lurek.render.dashedLine` albo helper w Lua.
2. API chart data methods w `lurek.ui` musi być udokumentowane przykładami.
3. Canvas hit-testing helper dla bloków/krawędzi.
4. Layout DAG helper. Można zacząć od prostego layered layout w Lua.
5. Minimap widget dla dużych grafów.
6. Debug bridge subscriptions, żeby extension pobierało tylko `sim.*`.

## Layout algorithm v1

Nie dodawać ELK/dagre dependency. Wystarczy prosty layout:

1. topological sort grafu,
2. layer = longest distance from source,
3. y = index within layer,
4. edges as cubic polylines between layers,
5. manual drag zapisany w save JSON.

Jeżeli graf ma cycle, użyć fallback: keep manual positions albo simple grid.

## Testy

- Lua unit: layout assigns positions, hit-test works, queue color thresholds.
- Demo smoke: uruchom mały scenario i screenshot dashboardu.
- Playwright nie jest potrzebny dla Lurek native UI; można użyć screenshot save i sprawdzić plik.
- VS Code extension tests osobno, jeżeli powstanie webview.
