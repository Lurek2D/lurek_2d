# Plan 2: Nowe Moduły — Propozycje

> **Cel**: Opisać nowe moduły do dodania do lurek.* API surface. Każdy moduł ma pełną specyfikację: namespace, API, testy, examples, tier, zależności.
> **Status**: Propozycje — NIE wdrażać bez osobnej decyzji.
> **Priorytet AI-first**: Moduły oznaczone 🤖 są krytyczne dla AI-first vision projektu.

---

## Metodologia

Każdy nowy moduł opisany jest przez:
- **Namespace** — pełny `lurek.*` namespace
- **Tier** — miejsce w architekturze 5-tier
- **Priorytet** — Critical / High / Medium / Low
- **Uzasadnienie** — dlaczego brakuje, precedensy w innych engine'ach
- **Zakres API** — główne funkcje i typy
- **Testy** — co testować, naming conventions
- **Examples** — content/examples/ i content/games/ powiązania
- **Zależności** — inne moduły wymagane
- **Powiązane spec** — istniejące moduły dotknięte przez nowy

---

## NM-01 — `lurek.ai.llm` 🤖

**Namespace**: `lurek.ai.llm`
**Tier**: Feature Systems (sub-namespace of `lurek.ai`)
**Priorytet**: Critical
**Uzasadnienie**: Największy gap w AI-first engine. Bez HTTP bridge do LLM backend (Ollama, OpenAI, llama.cpp) nie można zbudować AI-driven game zachowań opartych o language models. `lurek.network.httpJson` (Plan 1, P1-J1) jest prerequisite.

**Precedensy**: LangChain Python, llama-cpp-python, Ollama API, OpenAI API

**API Design**:
```lua
-- Konfiguracja backend (raz przy starcie)
lurek.ai.llm.configure({
  provider = "ollama",       -- "ollama" | "openai" | "custom"
  base_url = "http://localhost:11434",
  model = "llama3:8b",
  timeout_ms = 30000,
  api_key = nil,             -- dla openai
})

-- Synchroniczne wołanie (blokuje VM — używaj z lurek.thread!)
local response = lurek.ai.llm.complete("What should the guard do next?")
-- response.text: string
-- response.tokens_used: number
-- response.model: string
-- response.error: string or nil

-- Asynchroniczne wołanie (non-blocking, callback)
lurek.ai.llm.completeAsync(
  "Describe the dungeon room in 2 sentences.",
  function(resp, err)
    if err then print("LLM error:", err) return end
    print("Room description:", resp.text)
  end
)

-- Chat format (multi-turn conversation)
local chat = lurek.ai.llm.newChat()
chat:setSystemPrompt("You are a helpful NPC in a fantasy game.")
chat:addMessage("user", "What quests do you have for me?")
local reply = chat:complete()
chat:addMessage("assistant", reply.text)
-- ... continue conversation

-- Prompt templates
local template = lurek.ai.llm.newTemplate(
  "The player has {health}HP and is in {location}. What does the NPC say?"
)
local prompt = template:render({ health = 45, location = "forest" })
local resp = lurek.ai.llm.complete(prompt)

-- Structured output (JSON schema enforcement)
local result = lurek.ai.llm.completeJson(
  "Generate 3 items for a shop.",
  {
    type = "array",
    items = {
      type = "object",
      properties = {
        name = { type = "string" },
        price = { type = "number", minimum = 1 },
        rarity = { type = "string", enum = {"common","rare","epic"} }
      }
    }
  }
)
-- result is a Lua table (auto-parsed from JSON)
for _, item in ipairs(result) do
  print(item.name, item.price, item.rarity)
end

-- Embeddings (for semantic search)
local embedding = lurek.ai.llm.embed("A magical sword that glows in the dark")
-- embedding: array of floats (dimension depends on model)

-- Provider helpers
lurek.ai.llm.isAvailable()  -- bool: check if configured backend responds
lurek.ai.llm.listModels()   -- array of model names (from Ollama or OpenAI)
```

**Rust Implementation Notes**:
- `src/ai/llm.rs` — nowy plik
- Używa `lurek::network::NetworkRuntime` jako HTTP backend (B-04: Rust threads)
- `LLMClient` struct z configurable provider
- Async path używa `lurek::thread` dla non-blocking Lua callback
- `LLMChat` struct z conversation history
- `LLMTemplate` struct z `{placeholder}` substitution
- Structured output przez `lurek::serialize` JSON schema validate

**Testy**:
```lua
-- tests/lua/unit/test_ai_llm.lua
-- (Unit tests nie wymagają sieci — mock provider)

-- test_template_render
local t = lurek.ai.llm.newTemplate("Hello {name}, you have {count} items.")
local out = t:render({name="Alice", count=5})
assert(out == "Hello Alice, you have 5 items.")

-- test_template_missing_key_error
local ok, err = pcall(function()
  t:render({name="Alice"})  -- missing 'count'
end)
assert(not ok, "should error on missing key")

-- tests/lua/integration/test_ai_llm_ollama.lua
-- @requires ollama  (skip in CI)
lurek.ai.llm.configure({provider="ollama", model="llama3"})
assert(lurek.ai.llm.isAvailable(), "Ollama must be running")
local resp = lurek.ai.llm.complete("Say 'hello' in exactly one word.")
assert(type(resp.text) == "string")
assert(#resp.text > 0)
```

**Examples**:
```
content/examples/ai/llm_npc_dialog.lua   -- NPC dialogue driven by LLM
content/examples/ai/llm_quest_gen.lua    -- Procedural quest generation
content/examples/ai/llm_json_output.lua  -- Structured JSON output
content/games/llm_dungeon/              -- Demo game: LLM-driven roguelike narration
```

**Zależności**: `lurek.network` (HTTP), `lurek.thread` (async), `lurek.serial` (JSON parse), `lurek.ai` (parent namespace)
**Powiązane spec**: `ai.md`, `network.md`, `thread.md`

---

## NM-02 — `lurek.ai.memory` 🤖

**Namespace**: `lurek.ai.memory`
**Tier**: Feature Systems (sub-namespace of `lurek.ai`)
**Priorytet**: Critical
**Uzasadnienie**: Persistent AI agent memory. Blackboard (istniejący) to volatile state per-tick. Memory to trwała, zorganizowana wiedza agenta: episodic (co się stało), semantic (co agent wie), working (aktywny kontekst).

**Precedensy**: MemGPT, LangChain Memory, Generative Agents (Stanford), Voyager (Minecraft AI)

**API Design**:
```lua
-- Short-term working memory (in-RAM, ograniczona pojemność)
local wm = lurek.ai.memory.newWorkingMemory(capacity = 20)
wm:push("target", "orc_guard_01")
wm:push("last_action", "patrol")
local target = wm:get("target")
wm:forget("last_action")
local recent = wm:getRecent(5)  -- last 5 items

-- Episodic memory (długoterminowe zdarzenia z timestampem)
local em = lurek.ai.memory.newEpisodicMemory()
em:record({
  event = "combat",
  enemy = "dragon",
  outcome = "fled",
  location = {x=100, y=200},
  tick = lurek.app.getTick()
})
local last_combats = em:query({event="combat", limit=10})
local dragon_encounters = em:query({enemy="dragon"})
em:forget_before(tick - 10000)  -- prune old memories

-- Semantic memory (fakty/wiedza)
local sm = lurek.ai.memory.newSemanticMemory()
sm:learn("dragon", {weakness="ice", is_hostile=true, habitat="mountain"})
sm:learn("sword_of_flames", {damage=50, element="fire"})
local dragon_facts = sm:recall("dragon")
local fire_items = sm:query({element="fire"})  -- find all fire items

-- Agent memory bundle (combines all three)
local agent_memory = lurek.ai.memory.newAgentMemory({
  working_capacity = 20,
  episodic_limit = 1000,
  persist_path = "save/agent_memory.json"  -- auto-save
})
agent_memory:save()
agent_memory:load()

-- Embedding-based retrieval (requires lurek.ai.llm.embed)
local relevant = agent_memory:semanticSearch("I need something to fight fire creatures", top_k=5)
```

**Rust Implementation Notes**:
- `src/ai/memory.rs` — nowy plik
- `WorkingMemory<V>` — fixed-capacity deque z named slots
- `EpisodicMemory` — `Vec<Episode>` z metadata, timestamp, full-text search
- `SemanticMemory` — `HashMap<String, SerialValue>` z query support
- `AgentMemory` — bundle z optionalnym persist path używając `lurek::save`
- Optional: embedding index używając float vectors z `lurek::learning`

**Testy**:
```lua
-- tests/lua/unit/test_ai_memory.lua

-- test_working_memory_capacity
local wm = lurek.ai.memory.newWorkingMemory(3)
wm:push("a", 1)
wm:push("b", 2)
wm:push("c", 3)
wm:push("d", 4)  -- evicts "a"
assert(wm:get("a") == nil, "a evicted")
assert(wm:get("d") == 4, "d present")

-- test_episodic_memory_query
local em = lurek.ai.memory.newEpisodicMemory()
em:record({event="fight", enemy="goblin"})
em:record({event="fight", enemy="troll"})
em:record({event="rest"})
local fights = em:query({event="fight"})
assert(#fights == 2)

-- test_semantic_memory_recall
local sm = lurek.ai.memory.newSemanticMemory()
sm:learn("fire_sword", {damage=50, element="fire"})
local item = sm:recall("fire_sword")
assert(item.damage == 50)
assert(item.element == "fire")

-- tests/lua/integration/test_ai_memory_save.lua
local am = lurek.ai.memory.newAgentMemory({persist_path="test_memory.json"})
am:semantic():learn("key", {value=42})
am:save()
am:semantic():learn("key", {value=99})  -- overwrite
am:load()
assert(am:semantic():recall("key").value == 42, "loaded from file")
```

**Examples**:
```
content/examples/ai/memory_npc.lua           -- NPC z persistent memory o playerze
content/examples/ai/memory_episodic.lua      -- Agent który pamięta przeszłe walki
```

**Zależności**: `lurek.ai` (parent), `lurek.save` (persist), `lurek.serial` (JSON), `lurek.learning` (optional embeddings)

---

## NM-03 — `lurek.easing` 🎮

**Namespace**: `lurek.easing`
**Tier**: Foundations
**Priorytet**: Medium
**Uzasadnienie**: Trzy osobne implementacje easing functions (`tween`, `animation`, `scene.transitions`). Centralny moduł eliminuje duplikację i umożliwia użycie easing w dowolnym kontekście.

**Precedensy**: Godot `Tween.EaseType`, LÖVE `flux`, Robert Penner easing functions

**API Design**:
```lua
-- Module-level easing (pure functions)
lurek.easing.linear(t)           -- t: 0.0 to 1.0
lurek.easing.easeIn(t, pow?)     -- default pow=2 (quadratic)
lurek.easing.easeOut(t, pow?)
lurek.easing.easeInOut(t, pow?)
lurek.easing.bounce(t)
lurek.easing.elastic(t, amplitude?, period?)
lurek.easing.back(t, overshoot?)
lurek.easing.sine(t)
lurek.easing.exponential(t)
lurek.easing.circular(t)

-- Named easing (string-based, for config/serialization)
lurek.easing.apply("ease_in_back", 0.75)  -- returns eased value

-- Easing list
lurek.easing.getNames()  -- array of all supported easing names

-- Custom easing via cubic bezier
local myEase = lurek.easing.cubicBezier(0.25, 0.1, 0.25, 1.0)
myEase(0.5)  -- returns eased value
```

**Testy**:
```lua
-- tests/lua/unit/test_easing.lua

-- test_linear_endpoints
assert(lurek.easing.linear(0) == 0)
assert(lurek.easing.linear(1) == 1)
assert(math.abs(lurek.easing.linear(0.5) - 0.5) < 0.001)

-- test_ease_in_boundary
assert(lurek.easing.easeIn(0) == 0)
assert(lurek.easing.easeIn(1) == 1)
assert(lurek.easing.easeIn(0.5) < 0.5, "easeIn slower at start")

-- test_all_names_applicable
for _, name in ipairs(lurek.easing.getNames()) do
  local v = lurek.easing.apply(name, 0.5)
  assert(type(v) == "number", "easing " .. name .. " returns number")
end
```

**Zależności**: `lurek.math` (trig functions)
**Powiązane spec**: `tween.md`, `animation.md`, `scene.md` — wszystkie powinny używać `lurek.easing` jako backend

---

## NM-04 — `lurek.input.actions` (Action Mapping) 🎮

> **Uwaga**: To zadanie jest częściowo pokryte przez Plan 1, P1-I1. Tutaj opisana jest pełniejsza wersja jako osobny sub-namespace.

**Namespace**: `lurek.input.actions`
**Tier**: Platform Services (sub-namespace of `lurek.input`)
**Priorytet**: High
**Uzasadnienie**: Input action mapping system — gracze mogą rebindować klawisze. Kluczowe dla moddability i accessibility.

**API Design** (rozszerzenie P1-I1):
```lua
-- Definiowanie actions (w game init)
lurek.input.actions.define("jump", {
  default = "Space",
  gamepad = "Gamepad:A",
  description = "Make player jump",
  category = "movement"
})
lurek.input.actions.define("attack", {
  default = "MouseButton:Left",
  gamepad = "Gamepad:RightTrigger",
  description = "Primary attack",
  category = "combat"
})

-- Runtimeowe zapytania (w game loop)
lurek.input.actions.isPressed("jump")
lurek.input.actions.isJustPressed("attack")
lurek.input.actions.getAxis("move_left", "move_right")
lurek.input.actions.getVector("left", "right", "up", "down")  -- Vec2

-- Rebinding (z UI)
lurek.input.actions.bind("jump", "W")        -- override
lurek.input.actions.reset("jump")            -- back to default
lurek.input.actions.resetAll()

-- Conflict detection
local conflicts = lurek.input.actions.getConflicts()
-- returns {action1, action2, shared_key} pairs

-- Persistence
local bindings_toml = lurek.input.actions.serialize()  -- TOML string
lurek.input.actions.deserialize(bindings_toml)

-- Categories (dla UI key-binding screen)
local movement_actions = lurek.input.actions.getByCategory("movement")
-- returns array of action definitions

-- Callbacks
lurek.input.actions.onRebind(function(action, old_key, new_key)
  print(action, "rebound from", old_key, "to", new_key)
end)
```

**Testy**:
```lua
-- tests/lua/unit/test_input_actions_full.lua

-- test_define_and_query
lurek.input.actions.define("test_action", {default="F1"})
assert(lurek.input.actions.isDefined("test_action"))

-- test_bind_override
lurek.input.actions.define("act", {default="A"})
lurek.input.actions.bind("act", "B")
local bindings = lurek.input.actions.getBindings("act")
assert(bindings[1] == "B", "overridden binding")

-- test_serialize_roundtrip
lurek.input.actions.define("ser_test", {default="X"})
lurek.input.actions.bind("ser_test", "Y")
local saved = lurek.input.actions.serialize()
lurek.input.actions.bind("ser_test", "Z")
lurek.input.actions.deserialize(saved)
local b = lurek.input.actions.getBindings("ser_test")
assert(b[1] == "Y", "deserialized binding")

-- test_conflict_detection
lurek.input.actions.define("a1", {default="Space"})
lurek.input.actions.define("a2", {default="Space"})
local conflicts = lurek.input.actions.getConflicts()
assert(#conflicts > 0, "conflict detected")
```

**Examples**:
```
content/examples/input/action_mapping.lua       -- Basic action setup
content/examples/input/keybinding_ui.lua        -- Key binding UI screen
content/examples/input/controller_support.lua   -- Gamepad action mapping
```

---

## NM-05 — `lurek.asset` (Asset Manager) 🎮

**Namespace**: `lurek.asset`
**Tier**: Platform Services
**Priorytet**: High
**Uzasadnienie**: Brak centralnego asset management. Każdy moduł ładuje assety niezależnie. Potrzebna: reference counting, hot-reload, async loading, cache invalidation.

**Precedensy**: Godot `ResourceLoader`, Unity `AssetDatabase`, Bevy `AssetServer`

**API Design**:
```lua
-- Load with caching (second call returns cached)
local texture = lurek.asset.load("sprites/player.png")     -- LTexture
local sound = lurek.asset.load("audio/footstep.ogg")       -- LSound
local font = lurek.asset.load("fonts/ui.ttf")              -- LFont
local data = lurek.asset.load("data/config.toml")          -- Lua table (parsed)
local script = lurek.asset.load("scripts/enemy_ai.lua")    -- LuaFunction

-- Async load (non-blocking)
lurek.asset.loadAsync("levels/level2.tmx", function(asset, err)
  if err then return end
  game.level = asset
end)

-- Preload group (for loading screens)
local loader = lurek.asset.newLoader()
loader:add("sprites/enemy.png")
loader:add("audio/bgm.ogg")
loader:add("fonts/game.ttf")
-- In loading screen loop:
local progress = loader:update()  -- 0.0 to 1.0
if loader:isDone() then
  local assets = loader:getAll()
end

-- Manual cache management
lurek.asset.unload("sprites/player.png")    -- decrement ref count, free if 0
lurek.asset.unloadAll()
lurek.asset.getCacheSize()      -- bytes
lurek.asset.getCachedPaths()    -- array of strings

-- Hot reload (development only)
lurek.asset.watch("data/balance.toml", function(new_data)
  game.balance = new_data
end)
lurek.asset.enableHotReload(true)

-- Asset info
local info = lurek.asset.getInfo("sprites/player.png")
-- info.path, info.size_bytes, info.ref_count, info.last_loaded
```

**Testy**:
```lua
-- tests/lua/unit/test_asset_manager.lua

-- test_load_returns_same_object
local a1 = lurek.asset.load("test_assets/dummy.png")
local a2 = lurek.asset.load("test_assets/dummy.png")
assert(a1 == a2, "same cached object")

-- test_unload_clears_cache
lurek.asset.load("test_assets/dummy.png")
lurek.asset.unload("test_assets/dummy.png")
local info = lurek.asset.getInfo("test_assets/dummy.png")
assert(info == nil or info.ref_count == 0)

-- test_loader_progress
local loader = lurek.asset.newLoader()
loader:add("test_assets/dummy.png")
while not loader:isDone() do
  local p = loader:update()
  assert(p >= 0 and p <= 1)
end
assert(loader:isDone())

-- tests/lua/integration/test_asset_hot_reload.lua
-- (tylko w development mode)
```

**Zależności**: `lurek.filesystem`, `lurek.image`, `lurek.audio`, `lurek.font`, `lurek.serial`

---

## NM-06 — `lurek.replay` (Input Replay) 🎮🤖

**Namespace**: `lurek.replay`
**Tier**: Feature Systems
**Priorytet**: Medium
**Uzasadnienie**: Deterministic input recording/playback. Kluczowe dla: AI training data collection, bug reproduction, speedrun tools, demo recordings.

**Precedensy**: LÖVE `love.event` recording, Quake demo format, Factorio replay system

**API Design**:
```lua
-- Recording
local recorder = lurek.replay.newRecorder()
recorder:start()
-- ... game runs, input captured automatically ...
recorder:stop()
local replay_data = recorder:getData()  -- serializable
recorder:saveToFile("replays/run_001.replay")

-- Playback
local player = lurek.replay.newPlayer()
player:loadFromFile("replays/run_001.replay")
player:loadFromData(replay_data)
player:setSpeed(1.0)   -- 1x = realtime, 2.0 = 2x speed
player:play()
-- Input events are replayed via lurek.input

-- Frame-by-frame
player:pause()
player:stepForward()
player:stepBackward()
player:seekToFrame(500)
player:seekToTime(10.5)  -- seconds
local current_frame = player:getCurrentFrame()
local total_frames = player:getTotalFrames()

-- Callbacks
player:onComplete(function()
  print("Replay finished")
end)
player:onFrame(function(frame_num, input_state)
  -- Custom logic per frame during playback
end)

-- Configuration
lurek.replay.setRecordingRate(60)  -- frames per second
lurek.replay.setCompression(true)  -- LZ4 compress replay file
```

**Testy**:
```lua
-- tests/lua/unit/test_replay_core.lua

-- test_recorder_start_stop
local rec = lurek.replay.newRecorder()
assert(not rec:isRecording())
rec:start()
assert(rec:isRecording())
rec:stop()
assert(not rec:isRecording())
local data = rec:getData()
assert(data ~= nil)

-- test_serialize_roundtrip
local rec = lurek.replay.newRecorder()
rec:start()
rec:stop()
local data = rec:getData()
local player = lurek.replay.newPlayer()
player:loadFromData(data)
assert(player:getTotalFrames() >= 0)

-- tests/lua/integration/test_replay_playback.lua
-- Records simple input sequence and verifies playback matches
```

**Examples**:
```
content/examples/replay/record_and_playback.lua
content/examples/replay/ai_training_data.lua    -- Collect human demos for ML
```

---

## NM-07 — `lurek.learning.onnx` 🤖

**Namespace**: `lurek.learning.onnx`
**Tier**: Feature Systems (sub of `lurek.learning`)
**Priorytet**: Medium
**Uzasadnienie**: Import pretrained models z PyTorch / TensorFlow / scikit-learn przez ONNX format. Game changer dla AI-first: trenuj model w Python, uruchom w grze.

**Precedensy**: ONNX Runtime (Microsoft), candle (HuggingFace Rust), tract

**API Design**:
```lua
-- Load pretrained ONNX model
local model = lurek.learning.onnx.load("models/classifier.onnx")

-- Inference (input shapes must match model spec)
local input = lurek.learning.onnx.tensor({1, 3, 224, 224})  -- batch=1, RGB 224x224
input:fill(pixel_data)
local output = model:run({input})
local probabilities = output[1]:toTable()

-- Model introspection
local info = model:getInfo()
-- info.inputs: [{name, shape, dtype}, ...]
-- info.outputs: [{name, shape, dtype}, ...]
-- info.opset_version: number

-- Common ML patterns
local embedding_model = lurek.learning.onnx.load("models/text_embed.onnx")
local text_embed = embedding_model:embed("A fire dragon in a cave")
-- text_embed: array of floats

-- Tensor operations
local t = lurek.learning.onnx.tensor({batch, features})
t:set(batch_idx, feature_idx, value)
t:get(batch_idx, feature_idx)
local result = t:softmax(dim=1)
local argmax = t:argmax()
```

**Rust Implementation**:
- Crate: `ort` (ONNX Runtime Rust bindings) lub `tract`
- `src/learning/onnx.rs` — nowy plik
- Wymaga dodania do `Cargo.toml`: `ort = "2"` lub `tract-onnx = "*"`

**Testy**:
```lua
-- tests/lua/unit/test_learning_onnx.lua (z minimalnym modelem)

-- test_load_simple_model
-- (requires test model file)
local model = lurek.learning.onnx.load("tests/data/simple_add.onnx")
assert(model ~= nil)
local info = model:getInfo()
assert(#info.inputs > 0)

-- test_tensor_creation
local t = lurek.learning.onnx.tensor({2, 3})
assert(t:getShape()[1] == 2)
assert(t:getShape()[2] == 3)
```

**Zależności**: `lurek.learning`, `lurek.filesystem`; zewnętrzna: `ort` crate

---

## NM-08 — `lurek.learning.env` (RL Environment) 🤖

**Namespace**: `lurek.learning.env`
**Tier**: Feature Systems
**Priorytet**: Medium
**Uzasadnienie**: Interfejs zgodny z OpenAI Gym dla game-as-environment ML research. Pozwala używać gry jako środowiska treningowego dla RL agentów.

**Precedensy**: OpenAI Gymnasium, PettingZoo (multi-agent), Unity ML-Agents

**API Design**:
```lua
-- Define environment (implement these callbacks)
local env = lurek.learning.env.define({
  -- Observation space definition
  observation_space = {
    type = "box",
    shape = {8},          -- 8-dimensional observation vector
    low = -1.0,
    high = 1.0
  },

  -- Action space definition
  action_space = {
    type = "discrete",
    n = 4                 -- 4 possible actions
  },
  -- Or continuous:
  -- action_space = { type = "box", shape = {2}, low = -1.0, high = 1.0 }

  -- Gym-compatible interface
  reset = function(seed)
    -- Reset game state, return initial observation
    return { x=0, y=0, health=1.0, ... }
  end,

  step = function(action)
    -- Apply action, advance one step
    -- Returns: observation, reward, done, truncated, info
    local obs = get_observation()
    local reward = calculate_reward()
    local done = player_died or level_complete
    return obs, reward, done, false, { level=current_level }
  end,

  render = function(mode)
    -- Optional: render current state
    if mode == "human" then lurek.scene.draw() end
  end
})

-- Use environment
local obs = env:reset()
local total_reward = 0
for step = 1, 1000 do
  local action = agent:act(obs)
  local next_obs, reward, done, _, info = env:step(action)
  total_reward = total_reward + reward
  obs = next_obs
  if done then break end
end

-- Multi-agent environment
local multi_env = lurek.learning.env.defineMulti({
  agents = {"player_1", "player_2"},
  -- ... per-agent observation/action spaces
})

-- Wrappers (composable transforms)
local wrapped = lurek.learning.env.frameStack(env, 4)    -- stack 4 frames
local wrapped = lurek.learning.env.normalize(env)          -- normalize observations
local wrapped = lurek.learning.env.timeLimit(env, 1000)    -- max 1000 steps
```

**Testy**:
```lua
-- tests/lua/unit/test_learning_env.lua

-- test_env_reset_returns_obs
local env = lurek.learning.env.define({
  observation_space = {type="box", shape={2}, low=0, high=1},
  action_space = {type="discrete", n=2},
  reset = function() return {0.5, 0.3} end,
  step = function(a) return {0.4, 0.2}, 1.0, false, false, {} end
})
local obs = env:reset()
assert(#obs == 2)

-- test_env_step_returns_tuple
local obs, r, done, trunc, info = env:step(0)
assert(type(r) == "number")
assert(type(done) == "boolean")

-- test_env_episode
local obs = env:reset()
local steps = 0
repeat
  local a = math.random(0, 1)
  obs, _, done = env:step(a)
  steps = steps + 1
until done or steps > 100
assert(steps > 0)
```

---

## NM-09 — `lurek.proc.wfc` (Wave Function Collapse) 🎮

**Namespace**: `lurek.proc.wfc`
**Tier**: Feature Systems (sub of `lurek.procgen`)
**Priorytet**: Medium
**Uzasadnienie**: WFC to algorytm generowania proceduralnego kompatybilny z `lurek.tilemap`. AI-assisted level design: LLM opisuje zasady, WFC generuje mapy.

**Precedensy**: `wfc` crate (Rust), fast-wfc (C++), mxgmn WFC (Python)

**API Design**:
```lua
-- Grid-based WFC (dla tilemap)
local wfc = lurek.proc.wfc.newGrid({
  width = 20,
  height = 20,
  tile_size = 16
})

-- Define tiles
wfc:addTile("grass", {
  weight = 10,               -- higher = more common
  edges = {
    north = "land",          -- edge type (must match adjacent)
    south = "land",
    east  = "land",
    west  = "land"
  }
})
wfc:addTile("water", {
  weight = 3,
  edges = { north="water", south="water", east="water", west="water" }
})
wfc:addTile("coast", {
  weight = 5,
  edges = { north="land", south="water", east="coast", west="coast" }
})

-- Or learn from example (texture synthesis mode)
local example_map = lurek.tilemap.load("content/example_island.tmx")
wfc:learnFromTilemap(example_map)

-- Generate
local success = wfc:collapse(seed=42)  -- false if contradiction
if not success then
  wfc:reset()
  success = wfc:collapse(seed=43)  -- retry with different seed
end

-- Extract result
local result = wfc:getResult()
-- result: 2D array of tile names: result[y][x] = "grass"

-- Convert to tilemap
local map = wfc:toTilemap(tileset="content/tilesets/nature.tsj")

-- Constraints (seeding specific tiles)
wfc:constrain(10, 10, "castle")  -- force tile at position
wfc:constrainRegion(0, 0, 5, 20, "water")  -- force region

-- Progressive generation (streaming)
wfc:startAsync()
-- check wfc:getProgress() each frame
-- wfc:onComplete(fn)
```

**Testy**:
```lua
-- tests/lua/unit/test_proc_wfc.lua

-- test_wfc_collapses_simple
local wfc = lurek.proc.wfc.newGrid({width=5, height=5})
wfc:addTile("a", {weight=1, edges={north="x",south="x",east="x",west="x"}})
local ok = wfc:collapse(seed=1)
assert(ok, "simple single-tile always collapses")
local result = wfc:getResult()
assert(#result == 5)
assert(#result[1] == 5)

-- test_wfc_respects_constraints
local wfc = lurek.proc.wfc.newGrid({width=3, height=3})
wfc:addTile("a", {weight=1, edges={north="e",south="e",east="e",west="e"}})
wfc:constrain(1, 1, "a")
local ok = wfc:collapse(seed=1)
assert(ok)
assert(wfc:getResult()[1][1] == "a")

-- tests/lua/demos/test_wfc_island.lua (screenshot demo)
```

---

## NM-10 — `lurek.network.sse` (Server-Sent Events) 🤖

**Namespace**: `lurek.network.sse`
**Tier**: Core Runtime (sub of `lurek.network`)
**Priorytet**: Medium
**Uzasadnienie**: SSE jest standardowym protokołem do streaming LLM token output (OpenAI streaming API, Ollama streaming mode). Bez SSE client trzeba polling lub WebSocket.

**API Design**:
```lua
-- SSE streaming client
local stream = lurek.network.sse.connect("http://localhost:11434/api/generate", {
  method = "POST",
  body = lurek.serial.toJson({ model="llama3", prompt="Hello", stream=true }),
  headers = { ["Content-Type"] = "application/json" }
})

-- Event-driven (non-blocking, called each frame via poll)
stream:onEvent(function(event_type, data)
  if event_type == "message" then
    local chunk = lurek.serial.fromJson(data)
    io.write(chunk.response)  -- stream token by token
    if chunk.done then stream:close() end
  end
end)

stream:onError(function(err)
  print("SSE error:", err)
end)

stream:onClose(function()
  print("Stream closed")
end)

-- Poll loop (call each frame)
stream:poll()

-- Status
stream:isConnected()  -- bool
stream:close()        -- disconnect

-- Convenience: collect full response (blocking)
local full_text = lurek.network.sse.collectText("http://...", body, options, timeout_ms)
```

**Testy**:
```lua
-- tests/lua/unit/test_network_sse.lua

-- test_sse_connect_returns_stream
local stream = lurek.network.sse.connect("http://localhost:11434/api/generate", {
  method = "POST",
  body = lurek.serial.toJson({model="llama3", prompt="hi", stream=true})
})
assert(stream ~= nil)
-- @requires ollama
stream:close()

-- tests/lua/integration/test_network_sse_streaming.lua
-- @requires ollama
local tokens = {}
local stream = lurek.network.sse.connect(...)
stream:onEvent(function(_, data)
  local chunk = lurek.serial.fromJson(data)
  table.insert(tokens, chunk.response or "")
  if chunk.done then stream:close() end
end)
-- run 100 poll cycles
for i = 1, 100 do
  stream:poll()
  if not stream:isConnected() then break end
  lurek.timer.sleep(50)
end
assert(#tokens > 0, "received at least one token")
```

---

## NM-11 — `lurek.pathfind.navmesh` 🎮

**Namespace**: `lurek.pathfind.navmesh`
**Tier**: Feature Systems (sub of `lurek.pathfind`)
**Priorytet**: Medium
**Uzasadnienie**: Aktualnie `lurek.pathfind` wspiera tylko grid-based A*. Dla gier z nieregularnymi przestrzeniami (platformówki, areny) potrzebny navmesh.

**API Design**:
```lua
-- Build navmesh from polygon obstacles
local nav = lurek.pathfind.navmesh.new()
nav:addObstacle({{0,0},{100,0},{100,100},{0,100}})  -- square obstacle
nav:addWalkableRegion({{-500,-500},{500,-500},{500,500},{-500,500}})
nav:build()

-- Find path
local path = nav:findPath({x=0, y=0}, {x=400, y=300})
-- path: array of {x, y} waypoints

-- Dynamic obstacles (moving units)
local obstacle_id = nav:addDynamicObstacle({x=200, y=200}, radius=20)
nav:moveDynamicObstacle(obstacle_id, {x=210, y=200})
nav:removeDynamicObstacle(obstacle_id)

-- Load from Tiled map (collision layer)
local nav = lurek.pathfind.navmesh.fromTilemap(tilemap, collision_layer="collision")

-- Debug visualization
nav:draw()  -- draws navmesh wireframe via lurek.render
```

**Testy**:
```lua
-- tests/lua/unit/test_pathfind_navmesh.lua

-- test_navmesh_simple_path
local nav = lurek.pathfind.navmesh.new()
nav:addWalkableRegion({{0,0},{100,0},{100,100},{0,100}})
nav:build()
local path = nav:findPath({x=10,y=10}, {x=90,y=90})
assert(path ~= nil)
assert(#path >= 2)
assert(path[1].x ~= nil)

-- test_navmesh_blocked_path
local nav = lurek.pathfind.navmesh.new()
nav:addWalkableRegion({{0,0},{10,0},{10,10},{0,10}})
nav:addObstacle({{3,0},{7,0},{7,10},{3,10}})  -- vertical wall
nav:build()
-- Path around obstacle should exist or nil if impossible
local path = nav:findPath({x=1,y=5}, {x=9,y=5})
-- Either finds path around or returns nil
assert(path == nil or #path >= 2)
```

---

## NM-12 — `lurek.pathfind.flowfield` 🎮

**Namespace**: `lurek.pathfind.flowfield`
**Tier**: Feature Systems
**Priorytet**: Low
**Uzasadnienie**: Flow field pathfinding — optimal dla wielu units zmierzających do tego samego celu (RTS, tower defense). Używany w StarCraft II.

**API Design**:
```lua
-- Build flow field for tilemap (one goal, many units)
local field = lurek.pathfind.flowfield.build(tilemap, goal = {x=50, y=30})
-- Returns field: 2D array of direction vectors

-- Query direction for any unit position
local dir = field:getDirection(unit.x, unit.y)
-- dir: {x, y} normalized direction vector toward goal

-- Move unit along field
unit.x = unit.x + dir.x * speed * dt
unit.y = unit.y + dir.y * speed * dt

-- Dynamic goal (rebuild when goal moves)
field:rebuild({x=new_goal_x, y=new_goal_y})

-- Async rebuild (non-blocking)
field:rebuildAsync({x=gx, y=gy}, function(new_field)
  -- swap when ready
end)
```

---

## NM-13 — `lurek.pool` (Object Pool) 🎮

**Namespace**: `lurek.pool`
**Tier**: Foundations
**Priorytet**: Medium
**Uzasadnienie**: `lurek.patterns.ObjectPool` istnieje ale jest schowany w module patterns. Object pools są tak fundamentalne że powinny być w Foundations jako `lurek.pool`.

> **Uwaga**: Zamiast nowego modułu — wyodrębnić z `lurek.patterns` i ustawić jako top-level. Patrz Plan 1 opcjonalne zadanie.

**API Design**:
```lua
-- Typed pool
local bullet_pool = lurek.pool.new({
  create = function() return { x=0, y=0, active=false, damage=10 } end,
  reset  = function(b)  b.x=0; b.y=0; b.active=false end,
  capacity = 200
})

-- Acquire/release
local b = bullet_pool:acquire()
b.x = player.x; b.y = player.y; b.active = true
-- ... when bullet done ...
bullet_pool:release(b)

-- Iteration over active
bullet_pool:forEach(function(b)
  b.x = b.x + b.vx * dt
end)

-- Stats
bullet_pool:getActiveCount()
bullet_pool:getIdleCount()
bullet_pool:getCapacity()
```

**Testy**:
```lua
-- tests/lua/unit/test_pool.lua

-- test_acquire_release_cycle
local pool = lurek.pool.new({
  create = function() return {value=0} end,
  reset = function(o) o.value = 0 end,
  capacity = 5
})
local obj = pool:acquire()
assert(obj ~= nil)
assert(pool:getActiveCount() == 1)
obj.value = 42
pool:release(obj)
assert(pool:getActiveCount() == 0)

-- test_reuse_after_release
local o1 = pool:acquire()
pool:release(o1)
local o2 = pool:acquire()
assert(o2.value == 0, "reset was called")

-- test_capacity_limit
for i = 1, 5 do pool:acquire() end
local over = pool:acquire()
assert(over == nil, "capacity exceeded")
```

---

## Podsumowanie nowych modułów

### Mapa priorytetów

| ID | Moduł | Tier | Priorytet | Rust? | Zewn. crate? |
|---|---|---|---|---|---|
| NM-01 | `lurek.ai.llm` | Feature | 🔴 Critical | Tak | Nie (używa network) |
| NM-02 | `lurek.ai.memory` | Feature | 🔴 Critical | Tak | Nie |
| NM-04 | `lurek.input.actions` | Platform | 🟠 High | Tak | Nie |
| NM-05 | `lurek.asset` | Platform | 🟠 High | Tak | Nie |
| NM-03 | `lurek.easing` | Foundations | 🟡 Medium | Tak | Nie |
| NM-06 | `lurek.replay` | Feature | 🟡 Medium | Tak | Nie |
| NM-07 | `lurek.learning.onnx` | Feature | 🟡 Medium | Tak | Tak (ort/tract) |
| NM-08 | `lurek.learning.env` | Feature | 🟡 Medium | Tak | Nie |
| NM-09 | `lurek.proc.wfc` | Feature | 🟡 Medium | Tak | Tak (wfc crate?) |
| NM-10 | `lurek.network.sse` | Core | 🟡 Medium | Tak | Nie (używa network) |
| NM-11 | `lurek.pathfind.navmesh` | Feature | 🟡 Medium | Tak | Nie (rapier?) |
| NM-12 | `lurek.pathfind.flowfield` | Feature | 🟢 Low | Tak | Nie |
| NM-13 | `lurek.pool` | Foundations | 🟡 Medium | Tak | Nie |

### Recommended implementation order

```
Phase 1 (AI-first core):
  NM-01 lurek.ai.llm  ← needs Plan 1 P1-J1 (httpJson) first
  NM-02 lurek.ai.memory

Phase 2 (Engine completeness):
  NM-03 lurek.easing  ← prerequisite for tween/animation refactor
  NM-04 lurek.input.actions
  NM-05 lurek.asset
  NM-13 lurek.pool

Phase 3 (Advanced features):
  NM-06 lurek.replay
  NM-07 lurek.learning.onnx
  NM-08 lurek.learning.env
  NM-10 lurek.network.sse

Phase 4 (Specialized):
  NM-09 lurek.proc.wfc
  NM-11 lurek.pathfind.navmesh
  NM-12 lurek.pathfind.flowfield
```

### Cross-cutting concerns dla każdego nowego modułu

Każdy nowy moduł MUSI zawierać przy implementacji:
1. `docs/specs/<module>.md` — spec w standardowym formacie (wygenerowany z `python tools/gen_all_docs.py`)
2. `src/<module>/` — Rust implementation (`src/lua_api/<module>_api.rs` jako binding-only)
3. `tests/lua/unit/test_<module>.lua` — min. 5 unit tests
4. `tests/lua/integration/test_<module>_*.lua` — min. 1 integration test
5. `content/examples/<category>/<example>.lua` — min. 1 example
6. Wpis w `docs/specs/README.md`
7. Wpis w `docs/CHANGELOG.md`
8. Regeneracja `docs/api/lurek.lua` po dodaniu API
