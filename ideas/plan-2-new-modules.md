# Plan 2: Nowe Moduły — Propozycje (Revised)

> **Cel**: Opisać nowe moduły do dodania do lurek.* API surface. Każdy moduł ma pełną specyfikację: namespace, API, testy, examples, tier, zależności.
> **Status**: REVISED po audycie codebase (2026-05-28). Propozycje z korektami właściwości. NIE wdrażać bez osobnej decyzji.
> **Priorytet AI-first**: Moduły oznaczone 🤖 są krytyczne dla AI-first vision projektu.

---

## Wyniki audytu — co już istnieje

Przed rewizją przeanalizowano wszystkie istniejące moduły. Poniżej kluczowe odkrycia:

| Propozycja | Stan | Decyzja |
|---|---|---|
| `lurek.ai.llm` | `lurek.agent` istnieje z OllamaManager, LuaAgent, LuaAgentManager, LuaAISystem | Dodać brakujące metody do `lurek.agent` — **bez nowego namespace** |
| `lurek.ai.memory` | Brak memory system w agent | Dodać do `lurek.agent` — **bez nowego namespace** |
| `lurek.easing` | `lurek.math.easing` **JUŻ ISTNIEJE** — 27 funkcji (quad/cubic/quart/sine/expo/elastic/bounce/back/smooth_step + apply/resolve) | **ANULOWANY** — brak potrzeby nowego modułu |
| `lurek.input.actions` | `lurek.input` ma już: `bind`, `unbind`, `clearBindings`, `getBindings`, `isActionDown`, `wasActionPressed`, `wasActionReleased`, `wasActionPressedWithin`, `newMapping`, `newCombo` | Dodać brakujące metody (define z metadata, getAxis, getVector, reset, getConflicts, serialize, onRebind) — **do lurek.input** |
| `lurek.asset` | `lurek.mods` zarządza metadanymi modów, nie mediami (image/audio/font cache) | **NOWY MODUŁ** — Platform Services; mods to inna domena |
| `lurek.replay` | `lurek.automation` ma scripted replay (TOML); `lurek.input` ma `LuaInputRecording` | **BRAK NOWEGO MODUŁU** — rozszerzyć automation o rich export dla ML |
| `lurek.learning.onnx` | `lurek.learning` istnieje (QLearner, NeuralNet, GeneticAlg, Bandit, Neuroevolution) | Dodać do `lurek.learning` — **bez nowego namespace** |
| `lurek.learning.env` | `lurek.learning` istnieje | Dodać do `lurek.learning` — **bez nowego namespace** |
| `lurek.proc.wfc` | WFC **JUŻ ISTNIEJE** w `lurek.procgen` | Dodać LLM-guided constraint generation do istniejącego WFC |
| `lurek.network.sse` | `lurek.network` istnieje (HTTP GET/POST, raw binary) | Dodać SSE client do `lurek.network` — **bez nowego namespace** |
| `lurek.pathfind.navmesh` | `LuaNavMesh` **JUŻ ISTNIEJE** w `lurek.pathfind` | **GOTOWE — nic do robienia** |
| `lurek.pathfind.flowfield` | `LuaFlowField` i `LuaAiFlowField` **JUŻ ISTNIEJA** w `lurek.pathfind` | **GOTOWE — nic do robienia** |
| `lurek.pool` | `LuaObjectPool` **JUŻ ISTNIEJE** w `lurek.patterns` | **ANULOWANY** — używać `lurek.patterns.newObjectPool()` |

---

## Metodologia

Każdy moduł opisany jest przez:
- **Namespace** — pełny `lurek.*` namespace
- **Tier** — miejsce w architekturze 5-tier
- **Priorytet** — Critical / High / Medium / Low
- **Właściwość** — dodatkowe metody do istniejącego modułu LUB nowy moduł
- **Uzasadnienie** — dlaczego brakuje / co dodajemy
- **Zakres API** — nowe funkcje i typy (tylko delta, nie powtarzanie tego co istnieje)
- **Testy** — co testować, naming conventions
- **Examples** — content/examples/ i content/games/ powiązania
- **Zależności** — inne moduły wymagane

---

## NM-01 — Rozszerzenie `lurek.agent`: direct LLM API 🤖

**Namespace**: `lurek.agent` (rozszerzenie istniejącego)
**Tier**: Edge/Integration (już tam jest)
**Priorytet**: Critical
**Właściwość**: Dodatkowe metody/obiekty do istniejącego `lurek.agent`
**Uzasadnienie**: `lurek.agent` ma już LuaAgent (skills, options, Ollama backend), ale brakuje: bezpośredniego `complete()` bez agenta, chat sessions z historią, prompt templates, structured JSON output, embeddings, oraz provider-level helpers.

**Co już istnieje** (nie implementować ponownie):
- `lurek.agent.new(config)` → `LAgent`
- `LAgent:addSkill()`, `setOption()`, `setFormat()`, `setMaxRetries()`, `setContextSize()`, `setTemperature()`
- `lurek.agent.newManager()` → `LAgentManager` z batch execution
- `lurek.agent.newAISystem()` → `LAISystem` z pull-based queries

**Nowe API (delta)**:
```lua
-- Konfiguracja provider globalnie (raz przy starcie)
lurek.agent.configure({
  provider = "ollama",       -- "ollama" | "openai" | "custom"
  base_url = "http://localhost:11434",
  model = "llama3:8b",
  timeout_ms = 30000,
  api_key = nil,
})

-- Synchroniczne i asynchroniczne wywołania bez agenta
local resp = lurek.agent.complete("What should the guard do next?")
-- resp.text: string, resp.tokens_used: number, resp.model: string, resp.error: string?

lurek.agent.completeAsync("Describe the room.", function(resp, err)
  if not err then print(resp.text) end
end)

-- Chat sessions z historią
local chat = lurek.agent.newChat()
chat:setSystemPrompt("You are a helpful NPC in a fantasy game.")
chat:addMessage("user", "What quests do you have?")
local reply = chat:complete()
chat:addMessage("assistant", reply.text)
chat:clear()
chat:getHistory()  -- returns table of {role, content} pairs

-- Prompt templates z {placeholder} substitution
local tmpl = lurek.agent.newTemplate("The player has {health}HP in {location}.")
local prompt = tmpl:render({ health = 45, location = "forest" })

-- Structured JSON output (schema enforcement)
local items = lurek.agent.completeJson(
  "Generate 3 shop items.",
  { type = "array", items = { type = "object",
      properties = { name={type="string"}, price={type="number"}, rarity={type="string"} }
  }}
)
-- returns Lua table auto-parsed from JSON

-- Embeddings
local vec = lurek.agent.embed("A glowing magical sword")
-- vec: array of floats

-- Provider health checks
local ok = lurek.agent.isAvailable()
local models = lurek.agent.listModels()  -- array of strings
```

**Rust Implementation Notes**:
- `src/agent/` — nowe pliki: `chat.rs`, `template.rs`, `embeddings.rs`
- `src/lua_api/agent_api.rs` — dodać nowe funkcje do istniejącego `register()`
- Async path używa istniejącego background client pattern z `LuaAgentRuntime`
- JSON schema validate używa `src/serialize/`

**Testy**:
```lua
-- tests/lua/unit/test_agent_core_unit.lua (nowe cases)
-- @covers lurek.agent.newTemplate
local t = lurek.agent.newTemplate("Hello {name}, {count} items.")
local out = t:render({name="Alice", count=5})
assert_equal(out, "Hello Alice, 5 items.")

-- @covers lurek.agent.newTemplate
local ok, err = pcall(function() t:render({name="Alice"}) end)
assert_true(not ok, "should error on missing key")

-- @covers lurek.agent.newChat
local chat = lurek.agent.newChat()
chat:setSystemPrompt("You are a warrior.")
chat:addMessage("user", "Hi")
local history = chat:getHistory()
assert_equal(#history, 1)
chat:clear()
assert_equal(#chat:getHistory(), 0)
```

**Examples**:
```
content/examples/agent/llm_npc_dialog.lua   -- NPC dialogue via LLM
content/examples/agent/llm_quest_gen.lua    -- Procedural quest generation
content/examples/agent/llm_json_output.lua  -- Structured JSON output
content/games/llm_dungeon/                  -- Demo game
```

**Zależności**: `lurek.network` (HTTP), `lurek.thread` (async), `lurek.serial` (JSON)

---

## NM-02 — Rozszerzenie `lurek.agent`: memory system 🤖

**Namespace**: `lurek.agent` (rozszerzenie istniejącego)
**Tier**: Edge/Integration (już tam jest)
**Priorytet**: Critical
**Właściwość**: Nowe obiekty w `lurek.agent` — nie wymaga osobnego namespace
**Uzasadnienie**: Blackboard (istniejący w `lurek.patterns`) to volatile per-tick state. Memory to trwała, zorganizowana wiedza agenta: episodic (co się stało), semantic (co agent wie), working (aktywny kontekst). Żaden istniejący moduł tego nie ma.

**Co już istnieje** (nie implementować):
- `lurek.patterns.newBlackboard()` — volatile key/value, brak persistence i brak query

**Nowe API (delta)**:
```lua
-- Short-term working memory (in-RAM, FIFO eviction po capacity)
local wm = lurek.agent.newWorkingMemory(20)  -- capacity=20 slots
wm:push("target", "orc_guard_01")
wm:push("last_action", "patrol")
local target = wm:get("target")
wm:forget("last_action")
local recent = wm:getRecent(5)   -- table of {key, value} pairs

-- Episodic memory (zdarzenia z timestampem)
local em = lurek.agent.newEpisodicMemory()
em:record({ event="combat", enemy="dragon", outcome="fled", tick=lurek.app.getTick() })
local fights = em:query({ event="combat", limit=10 })
local dragon = em:query({ enemy="dragon" })
em:forgetBefore(tick - 10000)

-- Semantic memory (fakty/wiedza)
local sm = lurek.agent.newSemanticMemory()
sm:learn("dragon", { weakness="ice", is_hostile=true })
sm:learn("fire_sword", { damage=50, element="fire" })
local facts = sm:recall("dragon")
local fire_items = sm:query({ element="fire" })

-- Agent memory bundle (wszystkie trzy + persistence)
local mem = lurek.agent.newAgentMemory({
  working_capacity = 20,
  episodic_limit   = 1000,
  persist_path     = "save/npc_memory.json",
})
mem:working()   -- returns the working memory
mem:episodic()  -- returns the episodic memory
mem:semantic()  -- returns the semantic memory
mem:save()
mem:load()
```

**Rust Implementation Notes**:
- `src/agent/memory.rs` — nowy plik (working, episodic, semantic structs)
- `src/lua_api/agent_api.rs` — dodać factory funkcje i LuaUserData impls
- Persistence używa `src/save/` przez `lurek::save`
- Query używa simple linear scan dla episodic, HashMap dla semantic

**Testy**:
```lua
-- tests/lua/unit/test_agent_core_unit.lua (nowe cases)
-- @covers lurek.agent.newWorkingMemory
local wm = lurek.agent.newWorkingMemory(3)
wm:push("a", 1); wm:push("b", 2); wm:push("c", 3); wm:push("d", 4)
assert_true(wm:get("a") == nil, "a evicted after overflow")
assert_equal(wm:get("d"), 4)

-- @covers lurek.agent.newEpisodicMemory
local em = lurek.agent.newEpisodicMemory()
em:record({event="fight", enemy="goblin"})
em:record({event="fight", enemy="troll"})
em:record({event="rest"})
local fights = em:query({event="fight"})
assert_equal(#fights, 2)

-- @covers lurek.agent.newSemanticMemory
local sm = lurek.agent.newSemanticMemory()
sm:learn("sword", {damage=50, element="fire"})
local item = sm:recall("sword")
assert_equal(item.damage, 50)
assert_equal(item.element, "fire")
```

**Examples**:
```
content/examples/agent/memory_npc.lua      -- NPC z persistent memory
content/examples/agent/memory_episodic.lua -- Agent pamiętający przeszłe walki
```

**Zależności**: `lurek.save` (persist), `lurek.serial` (JSON)

---

---

## NM-03 — `lurek.easing` ~~ANULOWANY~~ — używaj `lurek.math`

**Decyzja**: `lurek.math.easing` **JUŻ ISTNIEJE** z 27 funkcjami easing:
- linear, ease_in/out_quad/cubic/quart, ease_in/out_sine, ease_in/out_expo
- ease_in/out_elastic, ease_in/out_bounce, ease_in/out_back, smooth_step
- `lurek.math.easing.apply(name, t)` — named dispatch
- `lurek.math.newTweenState(duration, easing_name?)` — tween z easing

`lurek.tween` używa tych funkcji jako backend. Brakuje jedynie `cubicBezier()` i `getNames()` — jeśli potrzebne, dodać jako 2 funkcje do `lurek.math`, nie jako nowy moduł.

**Do zrobienia (mały gap)**:
```lua
-- Dodać do lurek.math (2 funkcje):
lurek.math.easingNames()                      -- array of all easing names
lurek.math.cubicBezier(x1, y1, x2, y2, t)    -- custom cubic bezier easing
```

**Implementacja**: 2 linie w `src/lua_api/math_api.rs`, bez nowego pliku Rust.

---

## NM-04 — Rozszerzenie `lurek.input`: action definitions z metadata 🎮

**Namespace**: `lurek.input` (rozszerzenie istniejącego)
**Tier**: Platform Services (już tam jest)
**Priorytet**: High
**Właściwość**: Dodatkowe metody do istniejącego `lurek.input` — bez nowego namespace
**Uzasadnienie**: `lurek.input` ma już: `bind`, `unbind`, `clearBindings`, `getBindings`, `isActionDown`, `wasActionPressed`, `wasActionReleased`, `wasActionPressedWithin`, `newMapping`, `newCombo`. Brakuje: `define()` z metadata (description, category, gamepad default), `getAxis`, `getVector`, conflict detection, serialize/deserialize z TOML, `onRebind` callback.

**Co już istnieje** (nie implementować):
- `lurek.input.bind(action, key)` — assign key to action
- `lurek.input.unbind(action)` — remove all bindings
- `lurek.input.isActionDown(action)` / `wasActionPressed(action)` / `wasActionReleased(action)`
- `lurek.input.newMapping(name, keys)` — returns mapping object with isDown/wasPressed/wasReleased

**Nowe API (delta)**:
```lua
-- Define action z pełnymi metadanymi (buduje na istniejącym bind)
lurek.input.define("jump", {
  default     = "Space",
  gamepad     = "Gamepad:A",
  description = "Make player jump",
  category    = "movement"
})
lurek.input.define("attack", {
  default  = "MouseButton:Left",
  gamepad  = "Gamepad:RightTrigger",
  category = "combat"
})

-- Axis i vector helpers (new)
lurek.input.getAxis("move_left", "move_right")          -- -1.0..1.0
lurek.input.getVector("left", "right", "up", "down")    -- {x, y} normalized

-- Rebind z override i reset do default
lurek.input.reset("jump")   -- przywróć default binding
lurek.input.resetAll()

-- Conflict detection
local conflicts = lurek.input.getConflicts()
-- returns array of {action1, action2, shared_key}

-- Persistence (TOML per binding-spec B-05)
local toml_str = lurek.input.serializeBindings()
lurek.input.deserializeBindings(toml_str)

-- Category query (dla UI key-binding screen)
local movement = lurek.input.getByCategory("movement")
-- returns array of action definition tables

-- Rebind callback
lurek.input.onRebind(function(action, old_key, new_key) end)
```

**Rust Implementation Notes**:
- `src/input/action_def.rs` — nowy plik: `ActionDef { default, gamepad, description, category }` struct
- `src/lua_api/input_api.rs` — rozszerzyć `action_map` Rc o `action_defs` HashMap, dodać nowe funkcje

**Testy**:
```lua
-- tests/lua/unit/test_input_core_unit.lua (nowe cases)
-- @covers lurek.input.define
lurek.input.define("test_jump", {default="F1", category="movement"})
local cats = lurek.input.getByCategory("movement")
local found = false
for _, a in ipairs(cats) do if a.name == "test_jump" then found = true end end
assert_true(found)

-- @covers lurek.input.getAxis
lurek.input.define("left", {default="A"})
lurek.input.define("right", {default="D"})
local axis = lurek.input.getAxis("left", "right")
assert_true(axis >= -1.0 and axis <= 1.0)

-- @covers lurek.input.getConflicts
lurek.input.define("c1", {default="Space"})
lurek.input.define("c2", {default="Space"})
local conflicts = lurek.input.getConflicts()
assert_true(#conflicts > 0)

-- @covers lurek.input.serializeBindings
lurek.input.define("ser_test", {default="X"})
lurek.input.bind("ser_test", "Y")
local saved = lurek.input.serializeBindings()
lurek.input.bind("ser_test", "Z")
lurek.input.deserializeBindings(saved)
local bindings = lurek.input.getBindings()
assert_equal(bindings["ser_test"][1], "Y")
```

**Examples**:
```
content/examples/input/action_mapping.lua     -- Basic action setup
content/examples/input/keybinding_ui.lua      -- Key binding UI screen
content/examples/input/controller_support.lua -- Gamepad action mapping
```

---

## NM-05 — `lurek.asset` (Asset Manager) — NOWY MODUŁ 🎮

**Namespace**: `lurek.asset`
**Tier**: Platform Services
**Priorytet**: High
**Właściwość**: Nowy moduł (nie do mods — inna domena)
**Uzasadnienie**: `lurek.mods` zarządza metadanymi modów (TOML, API version, dependencies, sandbox). `lurek.asset` to cache mediów (image/audio/font) z ref-counting, async loading i hot-reload — zupełnie inna odpowiedzialność. Aktualnie każdy moduł ładuje assety niezależnie bez cache.

**Zakres API**:
```lua
-- Load z cache (drugie wywołanie zwraca cached)
local tex   = lurek.asset.load("sprites/player.png")   -- LImage
local sound = lurek.asset.load("audio/footstep.ogg")   -- LSoundData
local font  = lurek.asset.load("fonts/ui.ttf")         -- LFont
local data  = lurek.asset.load("data/config.toml")     -- Lua table
local fn    = lurek.asset.load("scripts/enemy_ai.lua") -- function

-- Async load (non-blocking, callback)
lurek.asset.loadAsync("levels/level2.tmx", function(asset, err) end)

-- Preload group (dla loading screens)
local loader = lurek.asset.newLoader()
loader:add("sprites/enemy.png")
loader:add("audio/bgm.ogg")
local progress = loader:update()  -- 0.0..1.0
if loader:isDone() then
  local all = loader:getAll()
end

-- Cache management
lurek.asset.unload("sprites/player.png")   -- decrement ref count
lurek.asset.unloadAll()
lurek.asset.getCacheSize()                 -- bytes
lurek.asset.getCachedPaths()               -- string[]

-- Hot reload (dev only)
lurek.asset.watch("data/balance.toml", function(new_data) end)
lurek.asset.enableHotReload(true)

-- Asset info
local info = lurek.asset.getInfo("sprites/player.png")
-- info.path, info.size_bytes, info.ref_count, info.last_loaded
```

**Rust Implementation Notes**:
- `src/asset/` — nowy folder: `mod.rs` (manifest), `cache.rs` (HashMap + ref counts), `loader.rs` (async batch)
- `src/lua_api/asset_api.rs` — nowy plik
- Używa `src/filesystem/` dla I/O, `src/image/`, `src/audio/`, `src/font/` dla decode
- Hot-reload używa `src/filesystem/` watcher (jeśli istnieje)
- Tier: Platform Services — zależy od filesystem, image, audio, font

**Testy**:
```lua
-- tests/lua/unit/test_asset_core_unit.lua
-- @covers lurek.asset.load
local a1 = lurek.asset.load("tests/fixtures/dummy.png")
local a2 = lurek.asset.load("tests/fixtures/dummy.png")
assert_true(a1 == a2, "same cached object on double load")

-- @covers lurek.asset.unload
lurek.asset.unload("tests/fixtures/dummy.png")
local info = lurek.asset.getInfo("tests/fixtures/dummy.png")
assert_true(info == nil or info.ref_count == 0)

-- @covers lurek.asset.newLoader
local loader = lurek.asset.newLoader()
loader:add("tests/fixtures/dummy.png")
while not loader:isDone() do loader:update() end
assert_true(loader:isDone())
```

**Zależności**: `lurek.filesystem`, `lurek.image`, `lurek.audio`, `lurek.font`, `lurek.serial`

---

## NM-06 — `lurek.replay` ~~ANULOWANY~~ — używaj automation + input

**Decyzja**: Nowy moduł **niepotrzebny**. Istniejące narzędzia pokrywają wszystkie przypadki:

| Potrzeba | Istniejący moduł |
|---|---|
| Scripted input replay dla testów | `lurek.automation` — TOML-based scripts z timed steps, condition eval, visual regression |
| Nagrywanie/odtwarzanie input events | `lurek.input.LuaInputRecording` — record/replay, serialize/deserialize |
| DAG task pipeline | `lurek.pipeline` — dependency ordering, retry, context passing |
| ML training data collection | `lurek.automation` + `lurek.input.LuaInputRecording` razem |

**Gap (mały)**: `lurek.input.LuaInputRecording` nie ma `setSpeed()` ani `seekToFrame()`. Jeśli potrzebne, dodać jako 2 metody do `LInputRecording` w `src/lua_api/input_api.rs` — nie jako nowy moduł.

**Do zrobienia** (opcjonalne, niska priorytet):
```lua
-- Dodać do LInputRecording jeśli potrzebne:
recording:setSpeed(2.0)        -- playback speed multiplier
recording:seekToFrame(500)     -- jump to frame
recording:getTotalFrames()     -- query length
```

---

## NM-07 — Rozszerzenie `lurek.learning`: ONNX inference 🤖

**Namespace**: `lurek.learning` (rozszerzenie istniejącego)
**Tier**: Feature Systems (już tam jest)
**Priorytet**: Medium
**Właściwość**: Dodatkowe obiekty w `lurek.learning` — bez nowego namespace
**Uzasadnienie**: `lurek.learning` ma QLearner, NeuralNet, GeneticAlg, Bandit, Neuroevolution — ale wszystko to trening w engine. Brakuje importu pretrenowanych modeli z PyTorch/TF/sklearn przez ONNX. Game changer: trenuj w Python, uruchom w grze.

**Co już istnieje** (nie implementować):
- `lurek.learning.newNeuralNet(layers)` — trenowanie w engine (forward/backward)
- `lurek.learning.newQLearner()`, `newGeneticAlgorithm()`, `newBandit()`

**Nowe API (delta)**:
```lua
-- Load pretrained ONNX model
local model = lurek.learning.loadOnnx("models/classifier.onnx")
local info = model:getInfo()
-- info.inputs: [{name, shape, dtype}], info.outputs: [{name, shape, dtype}]

-- Tensor operations
local t = lurek.learning.newTensor({1, 3, 224, 224})   -- shape
t:fill(pixel_data)                                      -- flat array of numbers
t:set(batch, channel, row, col, value)
t:get(batch, channel, row, col)
t:getShape()                                            -- array
t:toTable()                                             -- flat array of numbers

-- Inference
local outputs = model:run({t})    -- array of output tensors
local probs = outputs[1]:toTable()

-- Post-processing helpers
local result = outputs[1]:softmax(1)  -- dim=1
local idx = outputs[1]:argmax()        -- index of max value
```

**Rust Implementation Notes**:
- Nowy crate dependency: `ort = "2"` (ONNX Runtime bindings) lub `tract-onnx`
- `src/learning/onnx.rs` — nowy plik
- `src/lua_api/learning_api.rs` — dodać `loadOnnx` i `newTensor` do istniejącego register()

**Testy**:
```lua
-- tests/lua/unit/test_learning_core_unit.lua (nowe cases)
-- @covers lurek.learning.newTensor
local t = lurek.learning.newTensor({2, 3})
assert_equal(t:getShape()[1], 2)
assert_equal(t:getShape()[2], 3)

-- @covers lurek.learning.loadOnnx
-- (requires tests/fixtures/simple_add.onnx)
local model = lurek.learning.loadOnnx("tests/fixtures/simple_add.onnx")
assert_true(model ~= nil)
local info = model:getInfo()
assert_true(#info.inputs > 0)
```

**Zależności**: `lurek.filesystem`; zewnętrzna crate: `ort` lub `tract-onnx`

---

## NM-08 — Rozszerzenie `lurek.learning`: RL Environment interface 🤖

**Namespace**: `lurek.learning` (rozszerzenie istniejącego)
**Tier**: Feature Systems (już tam jest)
**Priorytet**: Medium
**Właściwość**: Dodatkowe obiekty w `lurek.learning` — bez nowego namespace
**Uzasadnienie**: OpenAI Gym-compatible environment wrapper pozwala używać gry jako środowiska dla RL agentów. Trenuj boty bezpośrednio w engine, eksportuj przez `lurek.learning.loadOnnx`.

**Nowe API (delta)**:
```lua
-- Define environment (Gym-compatible interface)
local env = lurek.learning.defineEnv({
  observation_space = { type="box", shape={8}, low=-1.0, high=1.0 },
  action_space      = { type="discrete", n=4 },

  reset = function(seed)
    return { x=0, y=0, health=1.0 }  -- initial observation
  end,

  step = function(action)
    -- Returns: observation, reward, done, truncated, info
    return get_obs(), calc_reward(), player_died, false, { level=1 }
  end,
})

-- Use environment
local obs = env:reset()
local obs2, reward, done, _, info = env:step(1)
local n_actions = env:actionCount()
local obs_shape = env:observationShape()

-- Wrappers (composable)
local stacked = lurek.learning.frameStack(env, 4)   -- stack 4 frames
local normed  = lurek.learning.normalizeEnv(env)    -- normalize observations
local limited = lurek.learning.timeLimit(env, 1000) -- max 1000 steps
```

**Rust Implementation Notes**:
- `src/learning/env.rs` — nowy plik: `EnvDefinition`, `EnvWrapper` trait
- `src/lua_api/learning_api.rs` — dodać `defineEnv` i wrapper factories

**Testy**:
```lua
-- tests/lua/unit/test_learning_core_unit.lua (nowe cases)
-- @covers lurek.learning.defineEnv
local env = lurek.learning.defineEnv({
  observation_space = {type="box", shape={2}, low=0, high=1},
  action_space = {type="discrete", n=2},
  reset = function() return {0.5, 0.3} end,
  step = function(a) return {0.4, 0.2}, 1.0, false, false, {} end
})
local obs = env:reset()
assert_equal(#obs, 2)
local obs2, r, done = env:step(0)
assert_true(type(r) == "number")
assert_true(type(done) == "boolean")
```

---

## NM-09 — Rozszerzenie `lurek.procgen`: WFC z LLM constraints 🤖🎮

**Namespace**: `lurek.procgen` (rozszerzenie istniejącego)
**Tier**: Feature Systems (już tam jest)
**Priorytet**: Medium
**Właściwość**: Dodatkowe metody do istniejącego WFC w `lurek.procgen` — bez nowego namespace
**Uzasadnienie**: WFC (`LBiomeClassifier`, dungeon generators, WFC) już istnieje w `lurek.procgen`. Brakuje LLM-guided constraint generation: opisujesz level słowami, LLM generuje tile constraints/rules.

**Co już istnieje** (nie implementować):
- WFC, BSP dungeon, rooms dungeon, L-systems, Voronoi, noise, cellular automata — wszystko w `lurek.procgen`

**Nowe API (delta)**:
```lua
-- LLM-guided WFC constraints (wymaga NM-01 lurek.agent)
local wfc = lurek.procgen.newWfc({ width=20, height=20 })
-- ... standardowe wfc:addTile() / wfc:constrain() ...

-- Generuj constraints z prompt naturalnego języka
wfc:setConstraintsFromLLM(
  "A coastal map: ocean in the south, mountains in the north, forest in between.",
  function(err)
    if not err then wfc:collapse(seed=42) end
  end
)

-- One-shot: prompt → tilemap (async)
lurek.procgen.wfcFromPrompt({
  prompt   = "A small village with a central square and surrounding farms.",
  width    = 20, height = 20,
  tileset  = { "grass","stone","water","tree","building" },
  callback = function(result, err)
    -- result: 2D array of tile names
  end
})
```

**Rust Implementation Notes**:
- `src/procgen/wfc_llm.rs` — nowy plik (LLM constraint parser)
- `src/lua_api/procgen_api.rs` — dodać metody do istniejącego WFC LuaUserData + wfcFromPrompt factory
- Używa `src/agent/` (NM-01) dla LLM calls; JSON schema enforcement dla tile rules output

**Testy**:
```lua
-- tests/lua/unit/test_procgen_core_unit.lua (nowe cases — bez sieci, mock LLM)
-- @covers lurek.procgen.newWfc
local wfc = lurek.procgen.newWfc({width=5, height=5})
assert_true(wfc ~= nil)
-- istniejące WFC testy już pokrywają collapse/getResult
```

---

## NM-10 — Rozszerzenie `lurek.network`: SSE client 🤖

**Namespace**: `lurek.network` (rozszerzenie istniejącego)
**Tier**: Core Runtime (już tam jest)
**Priorytet**: Medium
**Właściwość**: Dodatkowe funkcje w `lurek.network` — bez nowego namespace
**Uzasadnienie**: `lurek.network` ma HTTP GET/POST (raw binary). SSE (Server-Sent Events) to standard dla streaming LLM token output (OpenAI streaming API, Ollama streaming mode). Bez SSE trzeba polling.

**Co już istnieje** (nie implementować):
- `lurek.network.get(url, callback)`, `lurek.network.post(url, body, callback)` — raw HTTP

**Nowe API (delta)**:
```lua
-- SSE streaming client
local stream = lurek.network.sseConnect("http://localhost:11434/api/generate", {
  method  = "POST",
  body    = lurek.serial.toJson({ model="llama3", prompt="Hello", stream=true }),
  headers = { ["Content-Type"] = "application/json" },
})

-- Event callbacks
stream:onEvent(function(event_type, data)
  if event_type == "message" then
    local chunk = lurek.serial.fromJson(data)
    io.write(chunk.response)
    if chunk.done then stream:close() end
  end
end)
stream:onError(function(err) print("SSE error:", err) end)
stream:onClose(function() print("Stream closed") end)

-- Call once per frame to pump events
stream:poll()

-- Status
local ok = stream:isConnected()
stream:close()

-- Convenience: blocking collect (używaj z lurek.thread!)
local text = lurek.network.sseCollect("http://...", body, opts, timeout_ms)
```

**Rust Implementation Notes**:
- `src/network/sse.rs` — nowy plik: `SseStream` struct z background Tokio task
- `src/lua_api/network_api.rs` — dodać `sseConnect` i `sseCollect` do istniejącego register()
- Używa istniejącego `NetworkRuntime` Tokio background thread pattern

**Testy**:
```lua
-- tests/lua/unit/test_network_core_unit.lua (nowe cases)
-- @covers lurek.network.sseConnect
-- (bez sieci — test że obiekt powstaje i ma metody)
local stream = lurek.network.sseConnect("http://localhost:1", {})
assert_true(stream ~= nil)
stream:close()

-- tests/lua/integration/test_network_sse_streaming.lua
-- @integration lurek.network.sseConnect lurek.serial.fromJson
-- @requires ollama
```

**Zależności**: `lurek.serial` (JSON parse), `lurek.thread` (async use)

---

## NM-11 — `lurek.pathfind.navmesh` ~~GOTOWE~~

**Decyzja**: `LuaNavMesh` **JUŻ ISTNIEJE** w `lurek.pathfind` z 102 bridged methods. Nic do robienia.

---

## NM-12 — `lurek.pathfind.flowfield` ~~GOTOWE~~

**Decyzja**: `LuaFlowField` i `LuaAiFlowField` **JUŻ ISTNIEJĄ** w `lurek.pathfind`. Nic do robienia.

---

## NM-13 — `lurek.pool` ~~ANULOWANY~~ — używaj `lurek.patterns`

**Decyzja**: `LuaObjectPool` **JUŻ ISTNIEJE** w `lurek.patterns`:
```lua
local pool = lurek.patterns.newObjectPool(
  function() return {x=0, y=0, active=false} end,  -- create
  function(o) o.x=0; o.y=0; o.active=false end,    -- reset
  200  -- capacity
)
local b = pool:acquire()
pool:release(b)
pool:forEach(function(b) ... end)
pool:getActiveCount()
pool:getIdleCount()
```
Brak potrzeby oddzielnego modułu.

---

## Podsumowanie — mapa rewizji

### Status po audycie

| ID | Oryginalna propozycja | Decyzja | Target namespace |
|---|---|---|---|
| NM-01 | `lurek.ai.llm` | Rozszerzenie istniejącego | `lurek.agent` |
| NM-02 | `lurek.ai.memory` | Rozszerzenie istniejącego | `lurek.agent` |
| NM-03 | `lurek.easing` | **ANULOWANY** — `lurek.math.easing` ma 27 funkcji | `lurek.math` (+2 metody) |
| NM-04 | `lurek.input.actions` | Rozszerzenie istniejącego | `lurek.input` |
| NM-05 | `lurek.asset` | **NOWY MODUŁ** (inna domena niż mods) | `lurek.asset` |
| NM-06 | `lurek.replay` | **ANULOWANY** — automation + input recording pokrywa | `lurek.input` (+3 metody opcjonalne) |
| NM-07 | `lurek.learning.onnx` | Rozszerzenie istniejącego | `lurek.learning` |
| NM-08 | `lurek.learning.env` | Rozszerzenie istniejącego | `lurek.learning` |
| NM-09 | `lurek.proc.wfc` | WFC istnieje — dodać LLM integration | `lurek.procgen` |
| NM-10 | `lurek.network.sse` | Rozszerzenie istniejącego | `lurek.network` |
| NM-11 | `lurek.pathfind.navmesh` | **GOTOWE** — LuaNavMesh istnieje | — |
| NM-12 | `lurek.pathfind.flowfield` | **GOTOWE** — LuaFlowField istnieje | — |
| NM-13 | `lurek.pool` | **ANULOWANY** — LuaObjectPool w patterns | `lurek.patterns` (już) |

### Priorytety implementacji (revidowane)

```
Faza 1 — AI-first core (NM-01, NM-02):
  lurek.agent: configure, complete, completeAsync, newChat, newTemplate, completeJson, embed, isAvailable, listModels
  lurek.agent: newWorkingMemory, newEpisodicMemory, newSemanticMemory, newAgentMemory

Faza 2 — Engine completeness (NM-04, NM-10, NM-05):
  lurek.input: define, getAxis, getVector, reset, getConflicts, serializeBindings, deserializeBindings, getByCategory, onRebind
  lurek.network: sseConnect, sseCollect + LSseStream
  lurek.asset: nowy moduł Platform Services

Faza 3 — Advanced ML (NM-07, NM-08, NM-09):
  lurek.learning: loadOnnx, newTensor + LTensor, LOnnxModel
  lurek.learning: defineEnv, frameStack, normalizeEnv, timeLimit
  lurek.procgen: setConstraintsFromLLM, wfcFromPrompt (wymaga Fazy 1)

Faza 4 — Małe gapsy (NM-03 resztki):
  lurek.math: easingNames(), cubicBezier() — 2 małe funkcje
```

### Cross-cutting concerns dla każdej zmiany

1. `src/<module>/` — Rust implementation; `src/lua_api/<module>_api.rs` jako binding-only (TST-03)
2. `tests/lua/unit/test_<module>_core_unit.lua` — min. 5 nowych test cases
3. `docs/specs/<module>.md` — update, nie nowy plik (bo moduły istnieją)
4. Regeneracja `docs/api/lurek.lua` przez `python tools/gen_all_docs.py`
5. Wpis w `docs/CHANGELOG.md`
6. Dla NM-05 (nowy moduł): `docs/specs/asset.md` + wpis w `docs/specs/README.md`

