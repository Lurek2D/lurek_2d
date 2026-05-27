# Lurek2D API Audit Report

> **Scope**: Pełna analiza `docs/specs/` (71 modułów). Skupiam się na:
> 1. Duplikaty / overlaping odpowiedzialności
> 2. Zła grupa (moduł w złym tierze)
> 3. Luki w stosunku do popularnych engine'ów i AI-first frameworków
> 4. Niespójne nazewnictwo (konwencja, branżowe terminy)
> 5. Sugestia scalenia lub podziału

---

## Legenda severity

| Symbol | Znaczenie |
|---|---|
| 🔴 | Krytyczny (mylący, blokuje integrację AI) |
| 🟠 | Wysoki (duplikat lub znaczący gap) |
| 🟡 | Średni (niespójność nazewnicza lub design smell) |
| 🟢 | Niski (kosmetyczna sugestia) |

---

## TIER: Foundations

### `math` — `lurek.math`

| # | Severity | Sugestia |
|---|---|---|
| M1 | 🟡 | `AabbTree` jest strukturą przyspieszającą kolizje — powinna być w `physics` lub `spatial` (osobny moduł). W `math` mieszamy czystą matematykę ze strukturami danych przestrzennych. |
| M2 | 🟡 | Brak `lurek.math.noise` z kontrolowanym ziarniem (Perlin/Simplex/Value). `procgen` ma generację, ale nie eksponuje surowego sampla szumowego jako narzędzia matematycznego. |
| M3 | 🟢 | `Vec3` w module 2D — ok dla kolorów i 2.5D depth, ale warto dodać komentarz w spec że `z` to depth, nie 3D coordinate. |
| M4 | 🟢 | Brak `lurek.math.lerp`, `lurek.math.clamp`, `lurek.math.smoothstep` jako module-level helpers (mogą być w table, nie tylko w Vec). Godot, Love2D i Bevy mają je jako top-level. |

### `color` — `lurek.color`

| # | Severity | Sugestia |
|---|---|---|
| C1 | 🟡 | Osobny moduł dla kolorów jest ok, ale spec nie wspomina o **color spaces** (sRGB vs linear). Przy HDR i post-processingu (bloom) brak konwersji `srgb_to_linear` może dawać błędne wyniki. |
| C2 | 🟠 | `lurek.effect` (post-process) operuje na kolorach, `lurek.render` używa kolorów, `lurek.ui` — ale każdy robi własne color handling. Brak centralnego `Color` typu eksponowanego przez `lurek.color` jako userdata (Unity-style `Color32` vs `Color`). |
| C3 | 🟢 | Popularny w engine'ach: `color.fromHex("#ff6600")`, `color.toHex()`. Sprawdzić czy jest. |

### `log` — `lurek.log`

| # | Severity | Sugestia |
|---|---|---|
| L1 | 🟢 | Brak **structured logging** (log z polami klucz-wartość). Ważne dla AI-first: agent logi powinny być maszynowo parsowalne (JSON lines), nie tylko human-readable tekst. |
| L2 | 🟡 | Brak `lurek.log.span` / `lurek.log.trace` dla distributed tracing w stylu OpenTelemetry. Pipeline, flownet i thread mogą generować rozproszony trace — bez span ID nie da się ich powiązać. |

### `patterns` — `lurek.patterns`

| # | Severity | Sugestia |
|---|---|---|
| P1 | 🔴 | **Ryzyko scope creep** — moduł `patterns` w Foundations to anti-pattern. Design patterns (Observer, Pool, FSM, State Machine) są abstrakcjami nad innymi modułami. Proponuję **podzielić**: `lurek.patterns.pool` → `lurek.pool` (Foundations); `lurek.patterns.fsm` → `lurek.fsm` (Feature Systems, blisko `lurek.ai`); `lurek.patterns.observer` → zduplikowany z `lurek.event` Signal. |
| P2 | 🟠 | `lurek.patterns` zawiera FSM i BehaviorTree — ale `lurek.ai` też ma AI state machines i BT executor. To **duplikat konceptualny**. `ai.behavior_tree` re-uses `patterns.behavior_tree` strukturalnie (ok), ale FSM istnieje w obu. |
| P3 | 🟡 | Nazwa `patterns` jest generyczna i niedziałająca jako namespace w IDE — `lurek.patterns.ObjectPool` jest niejasne. |

### `serialize` — `lurek.serial`

| # | Severity | Sugestia |
|---|---|---|
| S1 | 🟠 | **Konflikt nazwy modułu vs namespace**: spec file = `serialize.md`, src = `src/serialize/`, ale namespace = `lurek.serial`. Niespójność — albo `lurek.serialize`, albo `src/serial/`. |
| S2 | 🟡 | `save` moduł ma własny `SaveValue` serializer (LZ4 + Lua literals) równolegle do `lurek.serial` (JSON/TOML/MsgPack). To częściowy duplikat. |
| S3 | 🟢 | Brak `lurek.serial.fromYaml` — B-05 zakazuje YAML dla configów, ale YAML jest popularne w ML/AI toolchain. Warto mieć read-only import. |
| S4 | 🟢 | Brak `flatbuffers` / `protobuf` support — ważne dla high-performance AI inference pipeline. |

### `binary` — `lurek.data`

| # | Severity | Sugestia |
|---|---|---|
| B1 | 🔴 | **Zła nazwa namespace**: spec = `binary.md`, src = `src/binary/`, ale namespace = `lurek.data`. `lurek.data` sugeruje data management/analytics — a to jest binarny I/O (bitwise ops, buffers). Lepsza nazwa: `lurek.binary` lub `lurek.buf`. |
| B2 | 🟠 | `lurek.data` i `lurek.dataframe` — dwie różne rzeczy, ale zbyt podobne nazwy powodują confusion w IDE autocomplete. |
| B3 | 🟡 | Uwaga: `lurek.data.pack`/`unpack` już istnieje (Python struct-style) — audit był tu nieprecyzyjny. OK. |

### `procgen` — `lurek.procgen`

| # | Severity | Sugestia |
|---|---|---|
| PR1 | 🟠 | `procgen` jest w Foundations, ale korzysta z `math`, `tilemap` (generacja map), `render` (debug draw). To sugeruje że powinno być w **Feature Systems**, nie Foundations. |
| PR2 | 🟡 | Brak generatorów dungeonów — BSP, Voronoi rooms. Popularne w rogue-like. |
| PR3 | 🟡 | Brak `wave function collapse` (WFC) — bardzo modny algorytm dla AI-assisted level design. |

---

## TIER: Core Runtime

### `runtime` — `lurek.runtime`

| # | Severity | Sugestia |
|---|---|---|
| RT1 | 🟡 | `lua_api.md` i `runtime.md` oba mają `lurek.runtime` namespace. **To jest duplikat** — dwa spec pliki mapują na ten sam namespace. Należy scalić lub zdeduplikować. |
| RT2 | 🟡 | Brak `lurek.runtime.version` / `lurek.runtime.buildInfo` — ważne dla plugin/mod compat checks. |
| RT3 | 🟢 | Brak hook `lurek.runtime.onCrash(fn)` — callback przed crash dump. |

### `event` — `lurek.event`

| # | Severity | Sugestia |
|---|---|---|
| EV1 | 🟠 | `lurek.event.Signal` (pub-sub z wildcard) duplikuje `EventBus` z `lurek.patterns`. Canonical: `LSignal` w `event`, `patterns.EventBus` jako Lua-level wrapper lub osobny obiekt. |
| EV2 | 🟡 | Brak `lurek.event.throttle(name, ms)` i `lurek.event.debounce(name, ms)`. Uwaga: `lurek.patterns` ma `Throttle` i `Debounce` — overlap. |
| EV3 | 🟡 | `lurek.event.exit` vs `lurek.event.quit` — oba istnieją, jeden z exit code, jeden hardcoded 0. Nieczyste API. |
| EV4 | 🟢 | Brak `lurek.event.middleware` / interceptors. |

### `thread` — `lurek.thread`

| # | Severity | Sugestia |
|---|---|---|
| TH1 | 🟠 | `thread` ma Channel (MPMC) dla cross-VM komunikacji. `pipeline` też ma DAG z async nodes. Overlap w konceptach worker pool i async task queue. |
| TH2 | 🟡 | Brak `lurek.thread.pool(n)` — managed thread pool z reuse. Tworzenie nowego VM per zadanie jest kosztowne. |
| TH3 | 🟡 | Brak `lurek.thread.atomic` — atomic counter / flag między wątkami. |
| TH4 | 🟢 | Brak `lurek.thread.timeout(vm, ms)` — anulowanie zawieszonego worker VM. Krytyczne dla AI agents. |

### `timer` — `lurek.timer`

| # | Severity | Sugestia |
|---|---|---|
| TM1 | 🟡 | `lurek.timer` i `lurek.tween` oba zarządzają czasem. Potrzebna dokumentacja czy `tween` używa `timer` wewnętrznie. |
| TM2 | 🟢 | Brak `lurek.timer.cron(expr, fn)` — cron-style scheduling dla AI agents. |

### `filesystem` — `lurek.filesystem`

| # | Severity | Sugestia |
|---|---|---|
| FS1 | 🟡 | Brak `lurek.filesystem.watch(path, fn)` — file system watcher dla hot-reload i AI agents. |
| FS2 | 🟡 | Brak `lurek.filesystem.glob(pattern)`. `lurek.grep` (Edge tier) jest osobnym modułem od FS — dziwne. |
| FS3 | 🟢 | `lurek.data.hash` już istnieje (MD5/SHA/CRC32) — brak tylko `lurek.filesystem.hash(path)` jako shortcut. |

### `network` — `lurek.network`

| # | Severity | Sugestia |
|---|---|---|
| NW1 | 🟡 | HTTP i WebSocket **już istnieją** w `LNetworkRuntime` (`httpGet`, `httpPost`, `wsConnect`) — audit był częściowo nieprecyzyjny. Ale są ukryte za obowiązkowym `newRuntime()`. Warto dodać `lurek.network.http` jako convenience shortcut bez ręcznego runtime zarządzania. |
| NW2 | 🟡 | Brak AI-specific convenience API: `lurek.network.httpJson(url, body)` — POST z auto-serialize JSON body i auto-parse response. Najczęstszy pattern dla OpenAI/Ollama API. |
| NW3 | 🟠 | Brak `lurek.network.mqtt` lub `lurek.network.pubsub` — popularne w IoT i distributed AI. |
| NW4 | 🟡 | Brak `lurek.network.rpc` — remote procedure call abstraction dla multi-agent orchestration. |
| NW5 | 🟢 | Brak SSE (Server-Sent Events) client — potrzebne do streaming LLM token output. |

### `repl` — `lurek.repl`

| # | Severity | Sugestia |
|---|---|---|
| RP1 | 🟢 | Brak integracji z `lurek.terminal`. Jeśli `terminal` to in-game console, a `repl` to Lua interactive shell, powinny być powiązane lub scalenie. |

---

## TIER: Platform Services

### `input` — `lurek.input.keyboard`

| # | Severity | Sugestia |
|---|---|---|
| IN1 | 🔴 | **Namespace niespójność**: Primary namespace to `lurek.input.keyboard`. Root namespace powinien być `lurek.input`, nie `lurek.input.keyboard`. Mouse i gamepad prawdopodobnie są w tym samym module ale spec tego nie dokumentuje. |
| IN2 | 🟠 | Brak input action mapping system (`lurek.input.actions`) — Godot `InputMap` style. Hardkodowane klawisze są złą praktyką. |
| IN3 | 🟡 | Brak `lurek.input.replay` / `lurek.input.record` — deterministic input recording. Kluczowe dla AI training data. |

### `camera` — `lurek.camera`

| # | Severity | Sugestia |
|---|---|---|
| CA1 | 🟡 | Brak `lurek.camera.shake(intensity, duration)` — standardowe w action games. |
| CA2 | 🟡 | Brak `lurek.camera.follow(entity, lerp)` — smooth follow camera built-in. |
| CA3 | 🟢 | Brak `lurek.camera.worldToScreen(pos)` / `screenToWorld(pos)` — coordinate conversion dla mouse picking. |

### `render` — `lurek.render`

| # | Severity | Sugestia |
|---|---|---|
| R1 | 🟡 | 5 modułów w rendering pipeline bez jasnego "render graph" concept organizującego kolejność. |
| R2 | 🟡 | `DepthSorter` jest w `lurek.scene` ale to rendering concern — powinien być w `lurek.render` lub `lurek.sprite`. |
| R3 | 🟢 | Brak `lurek.render.screenshot(path)` jako top-level convenience function. |

### `image` — `lurek.image`

| # | Severity | Sugestia |
|---|---|---|
| IM1 | 🟡 | Brak `lurek.image.resize()`, `crop()`, `composite()` — dla dynamic texture generation (AI content). |
| IM2 | 🟢 | Brak `lurek.image.fromBase64()` — ważne dla AI które zwraca obraz jako base64 (DALL-E API). |

### `font` — `lurek.font`

| # | Severity | Sugestia |
|---|---|---|
| FO1 | 🟢 | Brak `lurek.font.measure(text, size)` — text layout measurement dla dynamicznego UI. |
| FO2 | 🟢 | Brak emoji/Unicode extended glyph support dla AI-generowanego tekstu. |

### `light` — `lurek.light`

| # | Severity | Sugestia |
|---|---|---|
| LI1 | 🟡 | Brak integracji ze `visibility` (raycast shadows). `visibility.md` jest w Edge tier — powinna być zależność. |

### `dsp` — `lurek.dsp`

| # | Severity | Sugestia |
|---|---|---|
| DS1 | 🟡 | Niejednoznaczna nazwa — audio DSP czy generalny DSP (ML feature extraction)? |
| DS2 | 🟠 | Jeśli audio effects — overlap z `lurek.audio.bus` effects chain. |
| DS3 | 🟢 | Jeśli generalny signal processing dla ML — powinien być w Feature Systems obok `compute`. |

### `effect` — `lurek.effect`

| # | Severity | Sugestia |
|---|---|---|
| EF1 | 🟡 | Nazwa "effect" jest zbyt szeroka. Lepsza branżowa nazwa: `lurek.postprocess` lub `lurek.vfx.post`. |
| EF2 | 🟢 | Brak `lurek.effect.customShader(wgsl)` — custom user shader inject. |

### `window` — `lurek.window`

| # | Severity | Sugestia |
|---|---|---|
| W1 | 🟢 | Brak `lurek.window.setIcon(image)`. |
| W2 | 🟢 | Brak multi-monitor support. |

### `midi` — `lurek.midi`

| # | Severity | Sugestia |
|---|---|---|
| MI1 | 🟡 | MIDI jest niszowe dla game engine. Czy to część AI-first (music generation)? Jeśli tak — Feature Systems lub `lurek.audio` submodule. |

---

## TIER: Feature Systems

### `ecs` — `lurek.ecs`

| # | Severity | Sugestia |
|---|---|---|
| EC1 | 🟠 | `lurek.ecs` i `lurek.scene.setData`/`getData` nakładają się jako data storage. Potrzebna dokumentacja granicy. |
| EC2 | 🟡 | Brak `lurek.ecs.query().with(A).without(B).stream()` — lazy query streaming dla ogromnych światów. |
| EC3 | 🟡 | Brak `lurek.ecs.snapshot()` / `lurek.ecs.restore()` — world state serialization dla AI rollback i MCTS. |
| EC4 | 🟢 | Brak `lurek.ecs.prefab` — prefab/blueprint system. |

### `ai` — `lurek.ai`

| # | Severity | Sugestia |
|---|---|---|
| AI1 | 🟠 | `lurek.ai` jest już bardzo bogaty (FSM, BT, GOAP, HTN, MCTS, steering, UtilityAI, squad, director, sensors, emotions, needs). Gap: brak warstwy **LLM/inference bridge** do `lurek.learning` i `lurek.network`. |
| AI2 | 🟡 | Brak `lurek.ai.memory` — agent memory store (episodic, working). `Blackboard` istnieje ale to volatile state, nie persistent memory. |
| AI3 | 🟢 | Brak Boids flocking jako osobnego behavior — steering ma `flock` ale Boids to osobna implementacja. |

### `learning` — `lurek.learning`

| # | Severity | Sugestia |
|---|---|---|
| LE1 | 🟠 | NeuralNet ma forward inference (`forward(input)`) ale brak unified `lurek.learning.infer(model, input)` API na module level. Każdy model ma swoje metody ale brak common interface. |
| LE2 | 🟠 | `lurek.learning` + `lurek.compute` oba dotykają numerical computation. Brak dokumentacji zależności. |
| LE3 | 🟡 | Brak ONNX runtime integration — import pretrained models. Game changer dla AI-first. |
| LE4 | 🟡 | Brak `lurek.learning.env` — RL environment interface (OpenAI Gym compatible). |
| LE5 | 🟢 | Brak `lurek.learning.embed(text)` — text embedding via small model. |

### `pipeline` — `lurek.pipeline`

| # | Severity | Sugestia |
|---|---|---|
| PI1 | 🟠 | `lurek.pipeline` (DAG workflow) vs `lurek.flownet` (directed flow simulation) — bardzo podobna architektura. Potrzebna shared foundation lub jasna dokumentacja rozdzielności. |
| PI2 | 🟡 | Brak `lurek.pipeline.retry(n, backoff)` i `lurek.pipeline.timeout(ms)` — ważne dla AI pipelines. |
| PI3 | 🟡 | Brak `lurek.pipeline.cache(key, fn)` — memoizacja w node. |
| PI4 | 🟢 | Brak `lurek.pipeline.visualize()` — DAG diagram (Mermaid/DOT). |

### `flownet` — `lurek.flownet`

| # | Severity | Sugestia |
|---|---|---|
| FL1 | 🟠 | Overlap z `pipeline`. |
| FL2 | 🟡 | Nazwa `flownet` niestandardowa. Branżowe: `flow network`, `petri net`, `resource graph`. |
| FL3 | 🟢 | Brak `lurek.flownet.bottleneck()` — detekcja wąskiego gardła. |

### `pathfind` — `lurek.pathfind`

| # | Severity | Sugestia |
|---|---|---|
| PF1 | 🟡 | Brak jasnej dokumentacji granicy: `pathfind` = global path (A*), `ai.steering` = local avoidance. |
| PF2 | 🟡 | Brak `lurek.pathfind.navmesh` — dla nieregularnych kształtów. |
| PF3 | 🟢 | Brak `lurek.pathfind.flowfield` — flow field pathfinding (StarCraft II style). |

### `physics` — `lurek.physics`

| # | Severity | Sugestia |
|---|---|---|
| PH1 | 🟠 | `physics.md` zawiera `CellularWorld` (cellular automata). Cellular automata != physics — powinno być w `procgen` lub osobnym module. |
| PH2 | 🟡 | Brak `lurek.physics.joint` — spring, distance, revolute joints. Rapier2D to wspiera. |
| PH3 | 🟡 | Brak `lurek.physics.debug.draw()` — debug visualization. |
| PH4 | 🟢 | Brak `lurek.physics.sleep` — body sleeping dla dużych światów. |

### `tilemap` — `lurek.tilemap`

| # | Severity | Sugestia |
|---|---|---|
| TL1 | 🟡 | Chunk management w `LargeMapRenderer` — generalny concept bez shared abstraction. |
| TL2 | 🟢 | Brak `lurek.tilemap.pathfind(from, to)` convenience method. |

### `animation` — `lurek.animation`

| # | Severity | Sugestia |
|---|---|---|
| AN1 | 🟡 | Trzy animation systems bez unified timeline. |
| AN2 | 🟡 | Brak `lurek.animation.blendTree` — blend trees (Unity Animator style). |

### `scene` — `lurek.scene`

| # | Severity | Sugestia |
|---|---|---|
| SC1 | 🟠 | `lurek.scene.setData`/`getData` mini shared state bus — nakłada się na `lurek.event.Signal` i ECS. |
| SC2 | 🟡 | `DepthSorter` jest w `lurek.scene` — powinien być w `lurek.render`. |
| SC3 | 🟡 | `serializeScene` / `deserializeScene` — integracja z `lurek.save` niejasna. |

### `ui` + `html` + `layout` — UI Trio

| # | Severity | Sugestia |
|---|---|---|
| UI1 | 🟠 | **Trzy moduły UI** bez jasnej hierarchii. `lurek.html` renderuje HTML/CSS, `lurek.ui` to 2D UI, `lurek.layout` to TOML layouts. Potrzebna dokumentacja która jest primary, która secondary. |
| UI2 | 🟡 | Jeśli `lurek.html` jest primary (AI generates HTML) to `lurek.ui` = game-specific widgets only, `lurek.layout` = TOML backend dla `lurek.html` lub `lurek.ui`. |

### `particle` — `lurek.particle`

| # | Severity | Sugestia |
|---|---|---|
| PA1 | 🟡 | `lurek.particle` vs `lurek.effect` (post-process) — oba "visual effects". Nazewnictwo niespójne: `lurek.vfx.particle` + `lurek.vfx.post`? |

### `tween` — `lurek.tween`

| # | Severity | Sugestia |
|---|---|---|
| TW1 | 🟡 | Trzy implementacje easing functions (`tween`, `animation`, `scene.transitions`). Centralny `lurek.easing`. |

### `save` — `lurek.save`

| # | Severity | Sugestia |
|---|---|---|
| SV1 | 🟠 | Custom serialization (Lua literals + LZ4 + Base64) zamiast `lurek.serial`. Duplikacja. |
| SV2 | 🟡 | Brak cloud save abstraction. |

### `spine` — `lurek.spine`

| # | Severity | Sugestia |
|---|---|---|
| SP1 | 🟡 | Proprietary licencja. Powinno być za optional feature flag. |

### `mods` — `lurek.mods`

| # | Severity | Sugestia |
|---|---|---|
| MO1 | 🟠 | `lurek.mods` + `lurek.terminal` + `lurek.repl` tworzą extensibility stack bez unified plugin API. |
| MO2 | 🟡 | Brak sandboxing dla modów — security concern. |

### `dataframe` — `lurek.dataframe`

| # | Severity | Sugestia |
|---|---|---|
| DF1 | 🟠 | Overlap z `lurek.compute`. Potrzebna dokumentacja: `dataframe` = high-level tabular, `compute` = low-level numerics. |
| DF2 | 🟡 | Brak bridge do `lurek.serial.fromCsv` — duplikacja CSV parsing. |
| DF3 | 🟢 | Brak `lurek.dataframe.toArrow()` — Apache Arrow format dla ML pipelines. |

### `charts` — `lurek.charts`

| # | Severity | Sugestia |
|---|---|---|
| CH1 | 🟡 | Brak dokumentacji dependency na `lurek.render` / `lurek.ui`. |
| CH2 | 🟢 | Brak `lurek.charts.export(path, format)` — PNG/SVG eksport dla AI metrics. |

### Inne Feature Systems

| Moduł | Severity | Sugestia |
|---|---|---|
| `i18n` | 🟡 | Brak integracji z AI translation (LLM backend). Brak `plural(n, key)`. |
| `terminal` | 🟡 | Overlap z `repl` i `devtools`. Brak `registerCommand(name, fn, help)`. |
| `automation` | 🟠 | Niejasna odpowiedzialność. Overlap z `pipeline` i `event` jeśli to "event-driven scripting". |
| `raycaster` | 🟡 | Overlap z `light` (shadow rays) i `visibility` (line of sight). Potrzebna dokumentacja. |
| `globe` | 🟡 | Brak jasnego use case w AI-first context. Rozważyć `lurek.gis`. |
| `visibility` | 🟡 | W Edge tier ale to game feature — powinno być Feature Systems obok `pathfind` i `ai`. |
| `minimap` | 🟢 | Rozważyć przeniesienie do `content/library/` jako Lua-level library. |
| `parallax` | 🟢 | Analogicznie do minimap — można zrealizować przez `lurek.camera`. |
| `province` | 🟡 | Geopolitical/territory system — lepiej jako `content/library/`. |

---

## TIER: Edge/Integration

| Moduł | Severity | Sugestia |
|---|---|---|
| `bin.md` | 🔴 | Brak Lua namespace — co to jest? Spec dla binary entry point nie powinien być w lurek.* surface. |
| `lua_api.md` | 🔴 | Duplikat `lurek.runtime` namespace z `runtime.md` — należy scalić. |
| `vscode-extension.md` | 🔴 | Nie należy do `docs/specs/` — przenieść do `extensions/vscode/docs/`. |
| `cursor.md` | 🟡 | Powinno być w `lurek.input` lub `lurek.window`, nie Edge. |
| `grep.md` | 🟠 | Powinno być `lurek.filesystem.grep()`, nie osobny moduł. |
| `validator.md` | 🟠 | Duplikuje `lurek.serial.validate` — jeden powinien używać drugiego jako backend. |
| `overlay.md` | 🟡 | Nakłada się z `lurek.scene.pushOverlay`. |
| `debugbridge.md` | 🟡 | Brak protokołu (DAP?). Potrzebna jasna granica z `devtools`. |
| `dialog.md` | 🟡 | Native OS dialog vs RPG dialog tree — musi być wyjaśnione. |
| `docs.md` | 🟡 | Runtime dostęp do API docs — ciekawy AI-first feature. Brak `docs.search(query)`. |
| `mapblock.md` | 🟠 | Podobna nazwa do `tilemap` — potrzebne wyjaśnienie czym się różni. |

---

## Podsumowanie: Top 10 najważniejszych zmian

| Priorytet | Problem | Akcja |
|---|---|---|
| 1 | 🔴 `binary.md` → `lurek.data` — zła nazwa namespace | Rename: `lurek.data` → `lurek.binary` |
| 2 | 🔴 `lua_api.md` i `runtime.md` — duplikat namespace | Scalić w jeden spec plik |
| 3 | 🔴 `vscode-extension.md` w `docs/specs/` | Przenieść do `extensions/vscode/docs/` |
| 4 | 🔴 `bin.md` — brak namespace, niejasna rola | Wyjaśnić lub usunąć z lurek.* surface |
| 5 | 🔴 `input.md` namespace = `lurek.input.keyboard` | Zmienić root na `lurek.input` |
| 6 | 🟠 UI trio bez hierarchii (`ui`, `html`, `layout`) | Zdefiniować primary/secondary role |
| 7 | 🟠 `patterns.FSM` duplikuje `ai.FSM` | Udokumentować że `ai` re-używa `patterns` structure-only |
| 8 | 🟠 `validator` duplikuje `serial.validate` | Jeden jako backend drugiego |
| 9 | 🟠 `learning` brak unified inference interface | Dodać `lurek.learning.model` common interface |
| 10 | 🟠 `network` HTTP/WS istnieje ale ukryte | Dodać convenience `lurek.network.httpJson()` |

---

## Brakujące popularne moduły (nie istnieją w żadnej formie)

| Moduł | Branżowy precedens | Priorytet |
|---|---|---|
| `lurek.ai.llm` bridge | LangChain, llama.cpp, Ollama via `lurek.network` | 🔴 |
| `lurek.ai.memory` | MemGPT, LangChain Memory | 🔴 |
| `lurek.input.actions` | Godot InputMap, Unity Input System | 🟠 |
| `lurek.asset` (manager) | Godot ResourceLoader, Unity AssetDatabase | 🟠 |
| `lurek.easing` (centralne) | Godot Tween.EaseType, LÖVE easing | 🟡 |
| `lurek.proc.wfc` | Wave Function Collapse | 🟡 |
| `lurek.replay` | Input replay / game recorder | 🟡 |
| `lurek.network.sse` | Server-Sent Events dla LLM streaming | 🟡 |
| `lurek.learning.onnx` | ONNX Runtime | 🟡 |
| `lurek.physics.navmesh` | Navmesh dla free-space pathfinding | 🟡 |
