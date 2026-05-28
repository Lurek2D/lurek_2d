# Lurek2D API Audit Report

> **Scope**: PeĹ‚na analiza `docs/specs/` (71 moduĹ‚Ăłw). Skupiam siÄ™ na:
> 1. Duplikaty / overlaping odpowiedzialnoĹ›ci
> 2. ZĹ‚a grupa (moduĹ‚ w zĹ‚ym tierze)
> 3. Luki w stosunku do popularnych engine'Ăłw i AI-first frameworkĂłw
> 4. NiespĂłjne nazewnictwo (konwencja, branĹĽowe terminy)
> 5. Sugestia scalenia lub podziaĹ‚u

---

## Legenda severity

| Symbol | Znaczenie |
|---|---|
| đź”´ | Krytyczny (mylÄ…cy, blokuje integracjÄ™ AI) |
| đźź  | Wysoki (duplikat lub znaczÄ…cy gap) |
| đźźˇ | Ĺšredni (niespĂłjnoĹ›Ä‡ nazewnicza lub design smell) |
| đźź˘ | Niski (kosmetyczna sugestia) |

---

## TIER: Foundations

### `math` â€” `lurek.math`

| # | Severity | Sugestia |
|---|---|---|
| M1 | đźźˇ | `AabbTree` jest strukturÄ… przyspieszajÄ…cÄ… kolizje â€” powinna byÄ‡ w `physics` lub `spatial` (osobny moduĹ‚). W `math` mieszamy czystÄ… matematykÄ™ ze strukturami danych przestrzennych. |
| M2 | đźźˇ | Brak `lurek.math.noise` z kontrolowanym ziarniem (Perlin/Simplex/Value). `procgen` ma generacjÄ™, ale nie eksponuje surowego sampla szumowego jako narzÄ™dzia matematycznego. |
| M3 | đźź˘ | `Vec3` w module 2D â€” ok dla kolorĂłw i 2.5D depth, ale warto dodaÄ‡ komentarz w spec ĹĽe `z` to depth, nie 3D coordinate. |
| M4 | đźź˘ | Brak `lurek.math.lerp`, `lurek.math.clamp`, `lurek.math.smoothstep` jako module-level helpers (mogÄ… byÄ‡ w table, nie tylko w Vec). Godot, Love2D i Bevy majÄ… je jako top-level. |

### `color` â€” `lurek.color`

| # | Severity | Sugestia |
|---|---|---|
| C1 | đźźˇ | Osobny moduĹ‚ dla kolorĂłw jest ok, ale spec nie wspomina o **color spaces** (sRGB vs linear). Przy HDR i post-processingu (bloom) brak konwersji `srgb_to_linear` moĹĽe dawaÄ‡ bĹ‚Ä™dne wyniki. |
| C2 | đźź  | `lurek.effect` (post-process) operuje na kolorach, `lurek.render` uĹĽywa kolorĂłw, `lurek.ui` â€” ale kaĹĽdy robi wĹ‚asne color handling. Brak centralnego `Color` typu eksponowanego przez `lurek.color` jako userdata (Unity-style `Color32` vs `Color`). |
| C3 | đźź˘ | Popularny w engine'ach: `color.fromHex("#ff6600")`, `color.toHex()`. SprawdziÄ‡ czy jest. |

### `log` â€” `lurek.log`

| # | Severity | Sugestia |
|---|---|---|
| L1 | đźź˘ | Brak **structured logging** (log z polami klucz-wartoĹ›Ä‡). WaĹĽne dla AI-first: agent logi powinny byÄ‡ maszynowo parsowalne (JSON lines), nie tylko human-readable tekst. |
| L2 | đźźˇ | Brak `lurek.log.span` / `lurek.log.trace` dla distributed tracing w stylu OpenTelemetry. Pipeline, flownet i thread mogÄ… generowaÄ‡ rozproszony trace â€” bez span ID nie da siÄ™ ich powiÄ…zaÄ‡. |

### `patterns` â€” `lurek.patterns`

| # | Severity | Sugestia |
|---|---|---|
| P1 | đź”´ | **Ryzyko scope creep** â€” moduĹ‚ `patterns` w Foundations to anti-pattern. Design patterns (Observer, Pool, FSM, State Machine) sÄ… abstrakcjami nad innymi moduĹ‚ami. ProponujÄ™ **podzieliÄ‡**: `lurek.patterns.pool` â†’ `lurek.pool` (Foundations); `lurek.patterns.fsm` â†’ `lurek.fsm` (Feature Systems, blisko `lurek.ai`); `lurek.patterns.observer` â†’ zduplikowany z `lurek.event` Signal. |
| P2 | đźź  | `lurek.patterns` zawiera FSM i BehaviorTree â€” ale `lurek.ai` teĹĽ ma AI state machines i BT executor. To **duplikat konceptualny**. `ai.behavior_tree` re-uses `patterns.behavior_tree` strukturalnie (ok), ale FSM istnieje w obu. |
| P3 | đźźˇ | Nazwa `patterns` jest generyczna i niedziaĹ‚ajÄ…ca jako namespace w IDE â€” `lurek.patterns.ObjectPool` jest niejasne. |

### `serialize` â€” `lurek.serial`

| # | Severity | Sugestia |
|---|---|---|
| S1 | đźź  | **Konflikt nazwy moduĹ‚u vs namespace**: spec file = `serialize.md`, src = `src/serialize/`, ale namespace = `lurek.serial`. NiespĂłjnoĹ›Ä‡ â€” albo `lurek.serialize`, albo `src/serial/`. |
| S2 | đźźˇ | `save` moduĹ‚ ma wĹ‚asny `SaveValue` serializer (LZ4 + Lua literals) rĂłwnolegle do `lurek.serial` (JSON/TOML/MsgPack). To czÄ™Ĺ›ciowy duplikat. |
| S3 | đźź˘ | Brak `lurek.serial.fromYaml` â€” B-05 zakazuje YAML dla configĂłw, ale YAML jest popularne w ML/AI toolchain. Warto mieÄ‡ read-only import. |
| S4 | đźź˘ | Brak `flatbuffers` / `protobuf` support â€” waĹĽne dla high-performance AI inference pipeline. |

### `binary` â€” `lurek.data`

| # | Severity | Sugestia |
|---|---|---|
| B1 | đź”´ | **ZĹ‚a nazwa namespace**: spec = `binary.md`, src = `src/binary/`, ale namespace = `lurek.data`. `lurek.data` sugeruje data management/analytics â€” a to jest binarny I/O (bitwise ops, buffers). Lepsza nazwa: `lurek.binary` lub `lurek.buf`. |
| B2 | đźź  | `lurek.data` i `lurek.dataframe` â€” dwie rĂłĹĽne rzeczy, ale zbyt podobne nazwy powodujÄ… confusion w IDE autocomplete. |
| B3 | đźźˇ | Uwaga: `lurek.data.pack`/`unpack` juĹĽ istnieje (Python struct-style) â€” audit byĹ‚ tu nieprecyzyjny. OK. |

### `procgen` â€” `lurek.procgen`

| # | Severity | Sugestia |
|---|---|---|
| PR1 | đźź  | `procgen` jest w Foundations, ale korzysta z `math`, `tilemap` (generacja map), `render` (debug draw). To sugeruje ĹĽe powinno byÄ‡ w **Feature Systems**, nie Foundations. |
| PR2 | đźźˇ | Brak generatorĂłw dungeonĂłw â€” BSP, Voronoi rooms. Popularne w rogue-like. |
| PR3 | đźźˇ | Brak `wave function collapse` (WFC) â€” bardzo modny algorytm dla AI-assisted level design. |

---

## TIER: Core Runtime

### `runtime` â€” `lurek.runtime`

| # | Severity | Sugestia |
|---|---|---|
| RT1 | đźźˇ | `lua_api.md` i `runtime.md` oba majÄ… `lurek.runtime` namespace. **To jest duplikat** â€” dwa spec pliki mapujÄ… na ten sam namespace. NaleĹĽy scaliÄ‡ lub zdeduplikowaÄ‡. |
| RT2 | đźźˇ | Brak `lurek.runtime.version` / `lurek.runtime.buildInfo` â€” waĹĽne dla plugin/mod compat checks. |
| RT3 | đźź˘ | Brak hook `lurek.runtime.onCrash(fn)` â€” callback przed crash dump. |

### `event` â€” `lurek.event`

| # | Severity | Sugestia |
|---|---|---|
| EV1 | đźź  | `lurek.event.Signal` (pub-sub z wildcard) duplikuje `EventBus` z `lurek.patterns`. Canonical: `LSignal` w `event`, `patterns.EventBus` jako Lua-level wrapper lub osobny obiekt. |
| EV2 | đźźˇ | Brak `lurek.event.throttle(name, ms)` i `lurek.event.debounce(name, ms)`. Uwaga: `lurek.patterns` ma `Throttle` i `Debounce` â€” overlap. |
| EV3 | đźźˇ | `lurek.event.exit` vs `lurek.event.quit` â€” oba istniejÄ…, jeden z exit code, jeden hardcoded 0. Nieczyste API. |
| EV4 | đźź˘ | Brak `lurek.event.middleware` / interceptors. |

### `thread` â€” `lurek.thread`

| # | Severity | Sugestia |
|---|---|---|
| TH1 | đźź  | `thread` ma Channel (MPMC) dla cross-VM komunikacji. `pipeline` teĹĽ ma DAG z async nodes. Overlap w konceptach worker pool i async task queue. |
| TH2 | đźźˇ | Brak `lurek.thread.pool(n)` â€” managed thread pool z reuse. Tworzenie nowego VM per zadanie jest kosztowne. |
| TH3 | đźźˇ | Brak `lurek.thread.atomic` â€” atomic counter / flag miÄ™dzy wÄ…tkami. |
| TH4 | đźź˘ | Brak `lurek.thread.timeout(vm, ms)` â€” anulowanie zawieszonego worker VM. Krytyczne dla AI agents. |

### `timer` â€” `lurek.timer`

| # | Severity | Sugestia |
|---|---|---|
| TM1 | đźźˇ | `lurek.timer` i `lurek.tween` oba zarzÄ…dzajÄ… czasem. Potrzebna dokumentacja czy `tween` uĹĽywa `timer` wewnÄ™trznie. |
| TM2 | đźź˘ | Brak `lurek.timer.cron(expr, fn)` â€” cron-style scheduling dla AI agents. |

### `filesystem` â€” `lurek.filesystem`

| # | Severity | Sugestia |
|---|---|---|
| FS1 | đźźˇ | Brak `lurek.filesystem.watch(path, fn)` â€” file system watcher dla hot-reload i AI agents. |
| FS2 | đźźˇ | Brak `lurek.filesystem.glob(pattern)`. `lurek.grep` (Edge tier) jest osobnym moduĹ‚em od FS â€” dziwne. |
| FS3 | đźź˘ | `lurek.data.hash` juĹĽ istnieje (MD5/SHA/CRC32) â€” brak tylko `lurek.filesystem.hash(path)` jako shortcut. |

### `network` â€” `lurek.network`

| # | Severity | Sugestia |
|---|---|---|
| NW1 | đźźˇ | HTTP i WebSocket **juĹĽ istniejÄ…** w `LNetworkRuntime` (`httpGet`, `httpPost`, `wsConnect`) â€” audit byĹ‚ czÄ™Ĺ›ciowo nieprecyzyjny. Ale sÄ… ukryte za obowiÄ…zkowym `newRuntime()`. Warto dodaÄ‡ `lurek.network.http` jako convenience shortcut bez rÄ™cznego runtime zarzÄ…dzania. |
| NW2 | đźźˇ | Brak AI-specific convenience API: `lurek.network.httpJson(url, body)` â€” POST z auto-serialize JSON body i auto-parse response. NajczÄ™stszy pattern dla OpenAI/Ollama API. |
| NW3 | đźź  | Brak `lurek.network.mqtt` lub `lurek.network.pubsub` â€” popularne w IoT i distributed AI. |
| NW4 | đźźˇ | Brak `lurek.network.rpc` â€” remote procedure call abstraction dla multi-agent orchestration. |
| NW5 | đźź˘ | Brak SSE (Server-Sent Events) client â€” potrzebne do streaming LLM token output. |

### `repl` â€” `lurek.repl`

| # | Severity | Sugestia |
|---|---|---|
| RP1 | đźź˘ | Brak integracji z `lurek.terminal`. JeĹ›li `terminal` to in-game console, a `repl` to Lua interactive shell, powinny byÄ‡ powiÄ…zane lub scalenie. |

---

## TIER: Platform Services

### `input` â€” `lurek.input.keyboard`

| # | Severity | Sugestia |
|---|---|---|
| IN1 | đź”´ | **Namespace niespĂłjnoĹ›Ä‡**: Primary namespace to `lurek.input.keyboard`. Root namespace powinien byÄ‡ `lurek.input`, nie `lurek.input.keyboard`. Mouse i gamepad prawdopodobnie sÄ… w tym samym module ale spec tego nie dokumentuje. |
| IN2 | đźź  | Brak input action mapping system (`lurek.input.actions`) â€” Godot `InputMap` style. Hardkodowane klawisze sÄ… zĹ‚Ä… praktykÄ…. |
| IN3 | đźźˇ | Brak `lurek.input.replay` / `lurek.input.record` â€” deterministic input recording. Kluczowe dla AI training data. |

### `camera` â€” `lurek.camera`

| # | Severity | Sugestia |
|---|---|---|
| CA1 | đźźˇ | Brak `lurek.camera.shake(intensity, duration)` â€” standardowe w action games. |
| CA2 | đźźˇ | Brak `lurek.camera.follow(entity, lerp)` â€” smooth follow camera built-in. |
| CA3 | đźź˘ | Brak `lurek.camera.worldToScreen(pos)` / `screenToWorld(pos)` â€” coordinate conversion dla mouse picking. |

### `render` â€” `lurek.render`

| # | Severity | Sugestia |
|---|---|---|
| R1 | đźźˇ | 5 moduĹ‚Ăłw w rendering pipeline bez jasnego "render graph" concept organizujÄ…cego kolejnoĹ›Ä‡. |
| R2 | đźźˇ | `DepthSorter` jest w `lurek.scene` ale to rendering concern â€” powinien byÄ‡ w `lurek.render` lub `lurek.sprite`. |
| R3 | đźź˘ | Brak `lurek.render.screenshot(path)` jako top-level convenience function. |

### `image` â€” `lurek.image`

| # | Severity | Sugestia |
|---|---|---|
| IM1 | đźźˇ | Brak `lurek.image.resize()`, `crop()`, `composite()` â€” dla dynamic texture generation (AI content). |
| IM2 | đźź˘ | Brak `lurek.image.fromBase64()` â€” waĹĽne dla AI ktĂłre zwraca obraz jako base64 (DALL-E API). |

### `font` â€” `lurek.font`

| # | Severity | Sugestia |
|---|---|---|
| FO1 | đźź˘ | Brak `lurek.font.measure(text, size)` â€” text layout measurement dla dynamicznego UI. |
| FO2 | đźź˘ | Brak emoji/Unicode extended glyph support dla AI-generowanego tekstu. |

### `light` â€” `lurek.light`

| # | Severity | Sugestia |
|---|---|---|
| LI1 | đźźˇ | Brak integracji ze `visibility` (raycast shadows). `visibility.md` jest w Edge tier â€” powinna byÄ‡ zaleĹĽnoĹ›Ä‡. |

### `dsp` â€” `lurek.dsp`

| # | Severity | Sugestia |
|---|---|---|
| DS1 | đźźˇ | Niejednoznaczna nazwa â€” audio DSP czy generalny DSP (ML feature extraction)? |
| DS2 | đźź  | JeĹ›li audio effects â€” overlap z `lurek.audio.bus` effects chain. |
| DS3 | đźź˘ | JeĹ›li generalny signal processing dla ML â€” powinien byÄ‡ w Feature Systems obok `compute`. |

### `effect` â€” `lurek.effect`

| # | Severity | Sugestia |
|---|---|---|
| EF1 | đźźˇ | Nazwa "effect" jest zbyt szeroka. Lepsza branĹĽowa nazwa: `lurek.postprocess` lub `lurek.vfx.post`. |
| EF2 | đźź˘ | Brak `lurek.effect.customShader(wgsl)` â€” custom user shader inject. |

### `window` â€” `lurek.window`

| # | Severity | Sugestia |
|---|---|---|
| W1 | đźź˘ | Brak `lurek.window.setIcon(image)`. |
| W2 | đźź˘ | Brak multi-monitor support. |

### `midi` â€” `lurek.midi`

| # | Severity | Sugestia |
|---|---|---|
| MI1 | đźźˇ | MIDI jest niszowe dla game engine. Czy to czÄ™Ĺ›Ä‡ AI-first (music generation)? JeĹ›li tak â€” Feature Systems lub `lurek.audio` submodule. |

---

## TIER: Feature Systems

### `ecs` â€” `lurek.ecs`

| # | Severity | Sugestia |
|---|---|---|
| EC1 | đźź  | `lurek.ecs` i `lurek.scene.setData`/`getData` nakĹ‚adajÄ… siÄ™ jako data storage. Potrzebna dokumentacja granicy. |
| EC2 | đźźˇ | Brak `lurek.ecs.query().with(A).without(B).stream()` â€” lazy query streaming dla ogromnych Ĺ›wiatĂłw. |
| EC3 | đźźˇ | Brak `lurek.ecs.snapshot()` / `lurek.ecs.restore()` â€” world state serialization dla AI rollback i MCTS. |
| EC4 | đźź˘ | Brak `lurek.ecs.prefab` â€” prefab/blueprint system. |

### `ai` â€” `lurek.ai`

| # | Severity | Sugestia |
|---|---|---|
| AI1 | đźź  | `lurek.ai` jest juĹĽ bardzo bogaty (FSM, BT, GOAP, HTN, MCTS, steering, UtilityAI, squad, director, sensors, emotions, needs). Gap: brak warstwy **LLM/inference bridge** do `lurek.learning` i `lurek.network`. |
| AI2 | đźźˇ | Brak `lurek.ai.memory` â€” agent memory store (episodic, working). `Blackboard` istnieje ale to volatile state, nie persistent memory. |
| AI3 | đźź˘ | Brak Boids flocking jako osobnego behavior â€” steering ma `flock` ale Boids to osobna implementacja. |

### `learning` â€” `lurek.learning`

| # | Severity | Sugestia |
|---|---|---|
| LE1 | đźź  | NeuralNet ma forward inference (`forward(input)`) ale brak unified `lurek.learning.infer(model, input)` API na module level. KaĹĽdy model ma swoje metody ale brak common interface. |
| LE2 | đźź  | `lurek.learning` + `lurek.compute` oba dotykajÄ… numerical computation. Brak dokumentacji zaleĹĽnoĹ›ci. |
| LE3 | đźźˇ | Brak ONNX runtime integration â€” import pretrained models. Game changer dla AI-first. |
| LE4 | đźźˇ | Brak `lurek.learning.env` â€” RL environment interface (OpenAI Gym compatible). |
| LE5 | đźź˘ | Brak `lurek.learning.embed(text)` â€” text embedding via small model. |

### `pipeline` â€” `lurek.pipeline`

| # | Severity | Sugestia |
|---|---|---|
| PI1 | đźź  | `lurek.pipeline` (DAG workflow) vs `lurek.flownet` (directed flow simulation) â€” bardzo podobna architektura. Potrzebna shared foundation lub jasna dokumentacja rozdzielnoĹ›ci. |
| PI2 | đźźˇ | Brak `lurek.pipeline.retry(n, backoff)` i `lurek.pipeline.timeout(ms)` â€” waĹĽne dla AI pipelines. |
| PI3 | đźźˇ | Brak `lurek.pipeline.cache(key, fn)` â€” memoizacja w node. |
| PI4 | đźź˘ | Brak `lurek.pipeline.visualize()` â€” DAG diagram (Mermaid/DOT). |

### `flownet` â€” `lurek.flownet`

| # | Severity | Sugestia |
|---|---|---|
| FL1 | đźź  | Overlap z `pipeline`. |
| FL2 | đźźˇ | Nazwa `flownet` niestandardowa. BranĹĽowe: `flow network`, `petri net`, `resource graph`. |
| FL3 | đźź˘ | Brak `lurek.flownet.bottleneck()` â€” detekcja wÄ…skiego gardĹ‚a. |

### `pathfind` â€” `lurek.pathfind`

| # | Severity | Sugestia |
|---|---|---|
| PF1 | đźźˇ | Brak jasnej dokumentacji granicy: `pathfind` = global path (A*), `ai.steering` = local avoidance. |
| PF2 | đźźˇ | Brak `lurek.pathfind.navmesh` â€” dla nieregularnych ksztaĹ‚tĂłw. |
| PF3 | đźź˘ | Brak `lurek.pathfind.flowfield` â€” flow field pathfinding (StarCraft II style). |

### `physics` â€” `lurek.physics`

| # | Severity | Sugestia |
|---|---|---|
| PH1 | đźź  | `physics.md` zawiera `CellularWorld` (cellular automata). Cellular automata != physics â€” powinno byÄ‡ w `procgen` lub osobnym module. |
| PH2 | đźźˇ | Brak `lurek.physics.joint` â€” spring, distance, revolute joints. Rapier2D to wspiera. |
| PH3 | đźźˇ | Brak `lurek.physics.debug.draw()` â€” debug visualization. |
| PH4 | đźź˘ | Brak `lurek.physics.sleep` â€” body sleeping dla duĹĽych Ĺ›wiatĂłw. |

### `tilemap` â€” `lurek.tilemap`

| # | Severity | Sugestia |
|---|---|---|
| TL1 | đźźˇ | Chunk management w `LargeMapRenderer` â€” generalny concept bez shared abstraction. |
| TL2 | đźź˘ | Brak `lurek.tilemap.pathfind(from, to)` convenience method. |

### `animation` â€” `lurek.animation`

| # | Severity | Sugestia |
|---|---|---|
| AN1 | đźźˇ | Trzy animation systems bez unified timeline. |
| AN2 | đźźˇ | Brak `lurek.animation.blendTree` â€” blend trees (Unity Animator style). |

### `scene` â€” `lurek.scene`

| # | Severity | Sugestia |
|---|---|---|
| SC1 | đźź  | `lurek.scene.setData`/`getData` mini shared state bus â€” nakĹ‚ada siÄ™ na `lurek.event.Signal` i ECS. |
| SC2 | đźźˇ | `DepthSorter` jest w `lurek.scene` â€” powinien byÄ‡ w `lurek.render`. |
| SC3 | đźźˇ | `serializeScene` / `deserializeScene` â€” integracja z `lurek.save` niejasna. |

### `ui` + `html` + `layout` â€” UI Trio

| # | Severity | Sugestia |
|---|---|---|
| UI1 | đźź  | **Trzy moduĹ‚y UI** bez jasnej hierarchii. `lurek.html` renderuje HTML/CSS, `lurek.ui` to 2D UI, `lurek.layout` to TOML layouts. Potrzebna dokumentacja ktĂłra jest primary, ktĂłra secondary. |
| UI2 | đźźˇ | JeĹ›li `lurek.html` jest primary (AI generates HTML) to `lurek.ui` = game-specific widgets only, `lurek.layout` = TOML backend dla `lurek.html` lub `lurek.ui`. |

### `particle` â€” `lurek.particle`

| # | Severity | Sugestia |
|---|---|---|
| PA1 | đźźˇ | `lurek.particle` vs `lurek.effect` (post-process) â€” oba "visual effects". Nazewnictwo niespĂłjne: `lurek.vfx.particle` + `lurek.vfx.post`? |

### `tween` â€” `lurek.tween`

| # | Severity | Sugestia |
|---|---|---|
| TW1 | đźźˇ | Trzy implementacje easing functions (`tween`, `animation`, `scene.transitions`). Centralny `lurek.easing`. |

### `save` â€” `lurek.save`

| # | Severity | Sugestia |
|---|---|---|
| SV1 | đźź  | Custom serialization (Lua literals + LZ4 + Base64) zamiast `lurek.serial`. Duplikacja. |
| SV2 | đźźˇ | Brak cloud save abstraction. |

### `spine` â€” `lurek.spine`

| # | Severity | Sugestia |
|---|---|---|
| SP1 | đźźˇ | Proprietary licencja. Powinno byÄ‡ za optional feature flag. |

### `mods` â€” `lurek.mods`

| # | Severity | Sugestia |
|---|---|---|
| MO1 | đźź  | `lurek.mods` + `lurek.terminal` + `lurek.repl` tworzÄ… extensibility stack bez unified plugin API. |
| MO2 | đźźˇ | Brak sandboxing dla modĂłw â€” security concern. |

### `dataframe` â€” `lurek.dataframe`

| # | Severity | Sugestia |
|---|---|---|
| DF1 | đźź  | Overlap z `lurek.compute`. Potrzebna dokumentacja: `dataframe` = high-level tabular, `compute` = low-level numerics. |
| DF2 | đźźˇ | Brak bridge do `lurek.serial.fromCsv` â€” duplikacja CSV parsing. |
| DF3 | đźź˘ | Brak `lurek.dataframe.toArrow()` â€” Apache Arrow format dla ML pipelines. |

### `charts` â€” `lurek.charts`

| # | Severity | Sugestia |
|---|---|---|
| CH1 | đźźˇ | Brak dokumentacji dependency na `lurek.render` / `lurek.ui`. |
| CH2 | đźź˘ | Brak `lurek.charts.export(path, format)` â€” PNG/SVG eksport dla AI metrics. |

### Inne Feature Systems

| ModuĹ‚ | Severity | Sugestia |
|---|---|---|
| `i18n` | đźźˇ | Brak integracji z AI translation (LLM backend). Brak `plural(n, key)`. |
| `terminal` | đźźˇ | Overlap z `repl` i `devtools`. Brak `registerCommand(name, fn, help)`. |
| `automation` | đźź  | Niejasna odpowiedzialnoĹ›Ä‡. Overlap z `pipeline` i `event` jeĹ›li to "event-driven scripting". |
| `raycaster` | đźźˇ | Overlap z `light` (shadow rays) i `visibility` (line of sight). Potrzebna dokumentacja. |
| `globe` | đźźˇ | Brak jasnego use case w AI-first context. RozwaĹĽyÄ‡ `lurek.gis`. |
| `visibility` | đźźˇ | W Edge tier ale to game feature â€” powinno byÄ‡ Feature Systems obok `pathfind` i `ai`. |
| `minimap` | đźź˘ | RozwaĹĽyÄ‡ przeniesienie do `content/library/` jako Lua-level library. |
| `parallax` | đźź˘ | Analogicznie do minimap â€” moĹĽna zrealizowaÄ‡ przez `lurek.camera`. |
| `province` | đźźˇ | Geopolitical/territory system â€” lepiej jako `content/library/`. |

---

## TIER: Edge/Integration

| ModuĹ‚ | Severity | Sugestia |
|---|---|---|
| `bin.md` | đź”´ | Brak Lua namespace â€” co to jest? Spec dla binary entry point nie powinien byÄ‡ w lurek.* surface. |
| `lua_api.md` | đź”´ | Duplikat `lurek.runtime` namespace z `runtime.md` â€” naleĹĽy scaliÄ‡. |
| `vscode-extension.md` | đź”´ | Nie naleĹĽy do `docs/specs/` â€” przenieĹ›Ä‡ do `extension/vscode/docs/`. |
| `cursor.md` | đźźˇ | Powinno byÄ‡ w `lurek.input` lub `lurek.window`, nie Edge. |
| `grep.md` | đźź  | Powinno byÄ‡ `lurek.filesystem.grep()`, nie osobny moduĹ‚. |
| `validator.md` | đźź  | Duplikuje `lurek.serial.validate` â€” jeden powinien uĹĽywaÄ‡ drugiego jako backend. |
| `overlay.md` | đźźˇ | NakĹ‚ada siÄ™ z `lurek.scene.pushOverlay`. |
| `debugbridge.md` | đźźˇ | Brak protokoĹ‚u (DAP?). Potrzebna jasna granica z `devtools`. |
| `dialog.md` | đźźˇ | Native OS dialog vs RPG dialog tree â€” musi byÄ‡ wyjaĹ›nione. |
| `docs.md` | đźźˇ | Runtime dostÄ™p do API docs â€” ciekawy AI-first feature. Brak `docs.search(query)`. |
| `mapblock.md` | đźź  | Podobna nazwa do `tilemap` â€” potrzebne wyjaĹ›nienie czym siÄ™ rĂłĹĽni. |

---

## Podsumowanie: Top 10 najwaĹĽniejszych zmian

| Priorytet | Problem | Akcja |
|---|---|---|
| 1 | đź”´ `binary.md` â†’ `lurek.data` â€” zĹ‚a nazwa namespace | Rename: `lurek.data` â†’ `lurek.binary` |
| 2 | đź”´ `lua_api.md` i `runtime.md` â€” duplikat namespace | ScaliÄ‡ w jeden spec plik |
| 3 | đź”´ `vscode-extension.md` w `docs/specs/` | PrzenieĹ›Ä‡ do `extension/vscode/docs/` |
| 4 | đź”´ `bin.md` â€” brak namespace, niejasna rola | WyjaĹ›niÄ‡ lub usunÄ…Ä‡ z lurek.* surface |
| 5 | đź”´ `input.md` namespace = `lurek.input.keyboard` | ZmieniÄ‡ root na `lurek.input` |
| 6 | đźź  UI trio bez hierarchii (`ui`, `html`, `layout`) | ZdefiniowaÄ‡ primary/secondary role |
| 7 | đźź  `patterns.FSM` duplikuje `ai.FSM` | UdokumentowaÄ‡ ĹĽe `ai` re-uĹĽywa `patterns` structure-only |
| 8 | đźź  `validator` duplikuje `serial.validate` | Jeden jako backend drugiego |
| 9 | đźź  `learning` brak unified inference interface | DodaÄ‡ `lurek.learning.model` common interface |
| 10 | đźź  `network` HTTP/WS istnieje ale ukryte | DodaÄ‡ convenience `lurek.network.httpJson()` |

---

## BrakujÄ…ce popularne moduĹ‚y (nie istniejÄ… w ĹĽadnej formie)

| ModuĹ‚ | BranĹĽowy precedens | Priorytet |
|---|---|---|
| `lurek.ai.llm` bridge | LangChain, llama.cpp, Ollama via `lurek.network` | đź”´ |
| `lurek.ai.memory` | MemGPT, LangChain Memory | đź”´ |
| `lurek.input.actions` | Godot InputMap, Unity Input System | đźź  |
| `lurek.asset` (manager) | Godot ResourceLoader, Unity AssetDatabase | đźź  |
| `lurek.easing` (centralne) | Godot Tween.EaseType, LĂ–VE easing | đźźˇ |
| `lurek.proc.wfc` | Wave Function Collapse | đźźˇ |
| `lurek.replay` | Input replay / game recorder | đźźˇ |
| `lurek.network.sse` | Server-Sent Events dla LLM streaming | đźźˇ |
| `lurek.learning.onnx` | ONNX Runtime | đźźˇ |
| `lurek.physics.navmesh` | Navmesh dla free-space pathfinding | đźźˇ |

