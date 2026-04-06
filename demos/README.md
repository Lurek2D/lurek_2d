# Luna2D Demos

27 fully playable demo games showcasing `luna.*` engine features. Every demo is self-contained: it runs as-is with `cargo run -- demos/<name>`.

For API reference code (not runnable games), see [`examples/`](../examples/).

---

## Running a Demo

```bash
cargo run -- demos/<name>          # debug build
cargo run --release -- demos/<name>  # release build
luna demos/<name>                  # installed binary
```

---

## Demo Index

| Demo | Description | Key APIs |
|------|-------------|----------|
| [hello_world](#hello_world) | Minimal game: shapes, text, keyboard | `graphics`, `timer`, `keypressed` |
| [sprites](#sprites) | Sprite movement, mouse input | `keyboard.isDown`, `mouse`, `graphics` |
| [physics_demo](#physics_demo) | Rigid bodies, sensors, collisions | `physics`, `world`, `body` |
| [platformer](#platformer) | Side-scrolling character controller | `physics`, `keyboard`, `math.lerp` |
| [particles_demo](#particles_demo) | Particle emitter systems | `particle`, `newEmitter`, effects |
| [scene_demo](#scene_demo) | Multi-screen state machine | `scene`, `graphics` |
| [tween_demo](#tween_demo) | All easing curves side-by-side | `math.newTween`, easing types |
| [dialog_demo](#dialog_demo) | Typewriter text and branching | `dialog`, `sequencer`, `node` |
| [signal_demo](#signal_demo) | Pub-sub event bus | `event.newSignal`, `connect`, `fire` |
| [patterns_demo](#patterns_demo) | 6 game design patterns in Lua | `patterns`, EventBus, ObjectPool |
| [minimap_demo](#minimap_demo) | Fog-of-war overhead minimap | `minimap`, terrain, fog, pings |
| [nine_slice_demo](#nine_slice_demo) | Scalable 9-patch UI panels | `graphics.newNineSlice` |
| [overlay_demo](#overlay_demo) | Z-ordered render layers | `graphics.newDrawLayer`, z-order |
| [postfx_demo](#postfx_demo) | Post-processing effects stack | `postfx`, vignette, blur, aberration |
| [localization_demo](#localization_demo) | Multi-language string system | `localization`, `t()`, `setLanguage` |
| [light_demo](#light_demo) | 2D dynamic lighting | `light`, normal maps, shadows |
| [light_showcase](#light_showcase) | Advanced lighting effects gallery | `light`, `luna.graphics` |
| [loot_rpg_demo](#loot_rpg_demo) | RPG loot and inventory | `inventory`, `item`, `stats` |
| [merchant_demo](#merchant_demo) | Shop and trading system | `economy`, `inventory`, merchant UI |
| [modding_demo](#modding_demo) | Mod discovery and loading | `modding`, mod hooks |
| [province_demo](#province_demo) | Province map strategy game | `province_map`, map rendering |
| [debugbridge_demo](#debugbridge_demo) | TCP debug server (JSON-RPC) | `debugbridge`, network protocol |
| [devtools_demo](#devtools_demo) | Runtime diagnostics overlay | `devtools`, profiler, watcher |
| [automation_demo](#automation_demo) | Automated input replay | `automation`, input recording |
| [docs_demo](#docs_demo) | In-game API browser | `docs.scan`, catalog, search |
| [terminal_demo](#terminal_demo) | In-game developer terminal | `terminal`, widgets, REPL |
| [demo_game](#demo_game) | Complete shooting gallery game | `physics`, `mouse`, scoring |

---

## hello_world

The minimum viable Luna2D game. Draws colored shapes and text, shows FPS, and demonstrates the `luna.load / update / draw / keypressed` callback structure.

**Key APIs**: `luna.graphics.rectangle`, `circle`, `line`, `print`, `setColor`, `luna.timer.getFPS`

| Key | Action |
|-----|--------|
| Space | Randomize background color |

```bash
cargo run -- demos/hello_world
```

---

## sprites

Moves a colored rectangle with keyboard input. Covers delta-time movement, boundary clamping, and mouse-click spawning.

**Key APIs**: `luna.keyboard.isDown`, `luna.mouse.getPosition`, `luna.graphics.rectangle`

| Key / Input | Action |
|-------------|--------|
| Arrow keys / WASD | Move rectangle |
| Left click | Spawn a dot |

```bash
cargo run -- demos/sprites
```

---

## physics_demo

rapier2d rigid bodies: dynamic circles and rects, static ground/walls, sensors, collision events, and layer filtering.

**Key APIs**: `luna.physics.newWorld`, `newCircleBody`, `newRectBody`, `newCircleSensor`, `setLayerFilter`, `getCollisionEvents`, `step`

| Key | Action |
|-----|--------|
| Space | Spawn ball |
| R | Reset |

```bash
cargo run -- demos/physics_demo
```

---

## platformer

Side-scrolling platformer with physics character controller, jump mechanics, and easing-based camera follow.

**Key APIs**: `luna.physics`, `luna.keyboard.isDown`, `luna.math.lerp`, `luna.scene`

| Key | Action |
|-----|--------|
| Arrow / WASD | Move |
| Space | Jump |
| R | Restart |

```bash
cargo run -- demos/platformer
```

---

## particles_demo

Particle emitter systems with configurable emission rates, spread, color gradients, and physics integration.

**Key APIs**: `luna.particle.newEmitter`, `setRate`, `setBurst`, `setLifetime`, `setSpread`, `setColors`

| Key | Action |
|-----|--------|
| Mouse move | Move emitter |
| Space | Burst emit |
| 1–5 | Preset effects |

```bash
cargo run -- demos/particles_demo
```

---

## scene_demo

A Lua-side scene state machine: Title Screen → Gameplay → Game Over with transitions.

**Key APIs**: `luna.scene`, `luna.math.lerp`, `luna.graphics.print`

| Key | Action |
|-----|--------|
| Enter | Advance |
| Esc | Back |

```bash
cargo run -- demos/scene_demo
```

---

## tween_demo

All `luna.math.newTween` easing curves shown side by side. Pause, reset, and compare `linear`, `ease_in`, `ease_out`, `bounce`, `elastic`, and more.

**Key APIs**: `luna.math.newTween`, `tween:update`, `tween:isFinished`

| Key | Action |
|-----|--------|
| R | Reset tweens |
| Space | Pause / resume |

```bash
cargo run -- demos/tween_demo
```

---

## dialog_demo

Typewriter text reveal, branching choice menus, event callbacks, and call nodes powered by `luna.dialog`.

**Key APIs**: `luna.dialog.newSequencer`, `newNode`, `onEvent`

| Key | Action |
|-----|--------|
| Space / Enter | Advance / confirm |
| Up / Down | Navigate choices |

```bash
cargo run -- demos/dialog_demo
```

---

## signal_demo

Pub-sub event bus with connection IDs, combo chain tracking, and scrolling event history.

**Key APIs**: `luna.event.newSignal`, `signal:connect`, `signal:fire`, `signal:disconnect`

| Key | Action |
|-----|--------|
| Space | Fire event |
| C | Clear log |

```bash
cargo run -- demos/signal_demo
```

---

## patterns_demo

Six classic Lua game design patterns: EventBus, ObjectPool, CommandStack, ServiceLocator, Factory, SimpleState FSM.

**Key APIs**: `luna.patterns.newEventBus`, `newObjectPool`, `newCommandStack`, `newServiceLocator`, `newFactory`, `newSimpleState`

```bash
cargo run -- demos/patterns_demo
```

---

## minimap_demo

Scrollable terrain minimap with fog of war, dynamic object markers, pings, and a viewport overlay.

**Key APIs**: `luna.minimap.new`, `setTerrain`, `setFog`, `addObject`, `addPing`, `setViewport`, `draw`

| Key | Action |
|-----|--------|
| Arrow / WASD | Move player |
| P | Add ping |

```bash
cargo run -- demos/minimap_demo
```

---

## nine_slice_demo

Scalable 9-patch UI panels and buttons that preserve corners while stretching edges and center.

**Key APIs**: `luna.graphics.newNineSlice`, `drawNineSlice`

| Key | Action |
|-----|--------|
| Arrow keys | Resize panel |
| Tab | Cycle examples |

```bash
cargo run -- demos/nine_slice_demo
```

---

## overlay_demo

Z-ordered render layers with runtime reordering — ideal for HUD-over-world depth control.

**Key APIs**: `luna.graphics.newDrawLayer`, layer z-order, `flushLayers`

| Key | Action |
|-----|--------|
| 1 / 2 / 3 | Select rectangle |
| Up / Down | Change z-order |
| R | Reset |

```bash
cargo run -- demos/overlay_demo
```

---

## postfx_demo

Post-processing effects stack with vignette, chromatic aberration, blur, scanlines, and color grading.

**Key APIs**: `luna.postfx.newEffect`, `newStack`, `stack:addEffect`, `setEnabled`, `setParam`, `apply`

| Key | Action |
|-----|--------|
| 1–5 | Toggle effects |
| Up / Down | Adjust parameter |

```bash
cargo run -- demos/postfx_demo
```

---

## localization_demo

Multi-language text with interpolation, pluralization, and on-the-fly language switching.

**Key APIs**: `luna.localization.load`, `t()`, `setLanguage`

| Key | Action |
|-----|--------|
| L | Cycle languages |
| + / - | Change item count |

```bash
cargo run -- demos/localization_demo
```

---

## light_demo

2D dynamic lighting with normal maps, point lights, and shadow casting.

**Key APIs**: `luna.light.newPointLight`, `setColor`, `setRadius`, `draw`

| Key | Action |
|-----|--------|
| Mouse move | Move light |
| +/- | Adjust radius |

```bash
cargo run -- demos/light_demo
```

---

## light_showcase

Advanced lighting effects gallery: area lights, spotlights, colored shadows, and emissive materials.

**Key APIs**: `luna.light`, multiple light types, blending modes

| Key | Action |
|-----|--------|
| Tab | Cycle showcases |
| Mouse | Interactive light |

```bash
cargo run -- demos/light_showcase
```

---

## loot_rpg_demo

RPG loot system: item drops, rarity tiers, stat modifiers, and inventory management.

**Key APIs**: `luna.item`, `luna.inventory`, `luna.stats`, item generation

| Key | Action |
|-----|--------|
| Space | Generate loot |
| Click | Pick up item |
| I | Open inventory |

```bash
cargo run -- demos/loot_rpg_demo
```

---

## merchant_demo

Shop and trading system with buy/sell mechanics, pricing, and transaction history.

**Key APIs**: `luna.economy`, `luna.inventory`, merchant UI

| Key | Action |
|-----|--------|
| Click | Buy / sell |
| E | Interact with merchant |

```bash
cargo run -- demos/merchant_demo
```

---

## modding_demo

Mod discovery, dependency resolution, and load ordering. Loads mods from a `mods/` directory.

**Key APIs**: `luna.modding.discover`, `resolve`, `load`, mod hooks

| Key | Action |
|-----|--------|
| R | Reload mods |
| M | Toggle mod list |

```bash
cargo run -- demos/modding_demo
```

---

## province_demo

Province-map strategy game: territory control, resource flow, and turn-based management.

**Key APIs**: `luna.province_map`, territory adjacency, resource simulation

| Key / Click | Action |
|-------------|--------|
| Click province | Select / expand |
| Space | End turn |

```bash
cargo run -- demos/province_demo
```

---

## debugbridge_demo

TCP debug server for connecting external tools to a running game over JSON-RPC.

**Key APIs**: `luna.debugbridge.start`, `stop`, `register`

**Connect**: `telnet 127.0.0.1 19740` or `nc 127.0.0.1 19740`

```bash
cargo run -- demos/debugbridge_demo
```

---

## devtools_demo

Runtime diagnostics overlay: profiler, memory tracker, variable watcher, and log viewer.

**Key APIs**: `luna.devtools.start`, `profile`, `watch`, `log`, `getFrameStats`

| Key | Action |
|-----|--------|
| F1 | Toggle overlay |
| F2 | Cycle panels |

```bash
cargo run -- demos/devtools_demo
```

---

## automation_demo

Automated input recording and replay system. Records a play session and plays it back deterministically.

**Key APIs**: `luna.automation.startRecording`, `stopRecording`, `play`, `setSpeed`

| Key | Action |
|-----|--------|
| R | Start/stop recording |
| P | Play back recording |
| 1–3 | Playback speed |

```bash
cargo run -- demos/automation_demo
```

---

## docs_demo

In-game API browser powered by `luna.docs.scan()`. Browse all `luna.*` modules, query signatures, and fuzzy-search function names.

**Key APIs**: `luna.docs.scan`, `catalog:getModules`, `catalog:getFunctions`, `catalog:search`

| Key | Action |
|-----|--------|
| Up / Down | Scroll list |
| Tab | Cycle modules |
| / | Search mode |

```bash
cargo run -- demos/docs_demo
```

---

## terminal_demo

In-game developer terminal with widget toolkit: text boxes, buttons, lists, borders, and a built-in Lua REPL.

**Key APIs**: `luna.terminal.new`, `newLabel`, `newButton`, `newTextBox`, `newList`, `newBorder`

| Key | Action |
|-----|--------|
| F12 | Toggle terminal |
| Enter | Execute command |
| Tab | Autocomplete |

```bash
cargo run -- demos/terminal_demo
```

---

## demo_game

A complete shooting gallery mini-game: aim with mouse, fire physics balls at targets, score points before time runs out.

**Key APIs**: `luna.physics`, `luna.mouse.getPosition`, `luna.physics.getCollisionEvents`, `luna.timer.getTime`

| Input | Action |
|-------|--------|
| Mouse move | Aim |
| Left click | Fire |
| R | Reset |

```bash
cargo run -- demos/demo_game
```

---

## See Also

- [`examples/`](../examples/) — API reference code (one `.lua` file per module)
- [`library/`](../library/) — Reusable pure-Lua gameplay libraries
- [Getting Started](../docs/getting_started.md) — Build your first game with Luna2D
