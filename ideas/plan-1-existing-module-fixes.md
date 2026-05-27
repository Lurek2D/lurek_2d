# Plan 1: Poprawki Istniejących Modułów

> **Cel**: Naprawić naming, duplikaty, braki API, wrong-tier assignments i niespójności w istniejących modułach bez wprowadzania nowych modułów.
> **Agent owner**: Developer (Rust/API changes), Lua-Designer (API surface), Doc-Writer (spec sync)
> **Nie obejmuje**: Nowych modułów (patrz Plan 2)

---

## Metodologia planowania

Każde zadanie ma:
- **ID** — unikalny identyfikator (P1-XX)
- **Priorytet** — Critical / High / Medium / Low
- **Owner** — agent który wykonuje
- **Gate** — warunek ukończenia (binarny)
- **Zależności** — które taski muszą być przed
- **Zakres zmian** — dokładnie co i gdzie

Kolejność wykonania: Krytyczne najpierw → High → Medium → Low. Zadania bez zależności mogą być równoległe.

---

## BLOK A — Krytyczne rename i deduplikacja (bez zmian Rust)

> Żadne zadanie z tego bloku nie wymaga zmian w `src/`. Tylko dokumentacja i spec pliki.

### P1-A1 — Scalić `lua_api.md` i `runtime.md`

**Priorytet**: Critical
**Owner**: Doc-Writer
**Zależności**: brak

**Problem**: Dwa spec pliki (`docs/specs/lua_api.md`, `docs/specs/runtime.md`) mapują na ten sam namespace `lurek.runtime`. To duplikat w dokumentacji.

**Co zrobić**:
1. Otworzyć oba pliki i porównać sekcje.
2. Wybrać `runtime.md` jako plik kanoniczny (bardziej kompletny).
3. Przenieść wszystkie unikalne sekcje z `lua_api.md` do `runtime.md`.
4. Usunąć `docs/specs/lua_api.md`.
5. Zaktualizować `docs/specs/README.md` — usunąć wpis `lua_api`.
6. Zaktualizować `docs/CHANGELOG.md`.

**Gate**: `docs/specs/lua_api.md` nie istnieje. `docs/specs/runtime.md` zawiera wszystkie API z obu plików. `README.md` nie ma wpisu `lua_api`.

---

### P1-A2 — Przenieść `vscode-extension.md` poza `docs/specs/`

**Priorytet**: Critical
**Owner**: Doc-Writer
**Zależności**: brak

**Problem**: `docs/specs/vscode-extension.md` dokumentuje narzędzie deweloperskie, nie część lurek.* API Lua. Zaśmieca przestrzeń specs.

**Co zrobić**:
1. Przenieść plik do `extensions/vscode/docs/vscode-extension.md`.
2. Usunąć `docs/specs/vscode-extension.md`.
3. Zaktualizować `docs/specs/README.md` — usunąć wpis `vscode-extension`.
4. Dodać link do nowej lokalizacji z `extensions/vscode/README.md`.
5. Zaktualizować `docs/CHANGELOG.md`.

**Gate**: Plik nie istnieje w `docs/specs/`. Istnieje w `extensions/vscode/docs/`. Żadne linki w `docs/specs/README.md` do niego nie wskazują.

---

### P1-A3 — Wyjaśnić `bin.md` i usunąć z lurek.* surface

**Priorytet**: Critical
**Owner**: Doc-Writer + Developer (weryfikacja)
**Zależności**: brak

**Problem**: `bin.md` nie ma primary Lua namespace. Jest w Edge/Integration tier. Niejasne czy to spec dla binarki engine czy coś innego.

**Co zrobić**:
1. Sprawdzić `src/bin/` lub analogiczne — czy jest kod powiązany z `bin.md`.
2. Jeśli to spec dla main binary (`src/main.rs` lub entry point) — przenieść do `docs/architecture/binary-entry.md`.
3. Jeśli `bin.md` dokumentuje coś co ma API — uzupełnić `Primary Lua namespace`.
4. Usunąć z `docs/specs/` jeśli nie jest częścią lurek.* API.
5. Zaktualizować `docs/specs/README.md`.

**Gate**: `bin.md` albo ma poprawny namespace albo nie istnieje w `docs/specs/`.

---

## BLOK B — Rename namespace `lurek.data` → `lurek.binary`

> Wymaga zmian w Rust (`src/lua_api/binary_api.rs`), testach, przykładach i docs.

### P1-B1 — Rename `lurek.data` na `lurek.binary` w bindings

**Priorytet**: Critical
**Owner**: Developer + Lua-Designer
**Zależności**: brak (blok A może iść równolegle)

**Problem**: `binary.md` spec file, `src/binary/` source, ale namespace = `lurek.data`. Powoduje konfuzję z `lurek.dataframe`.

**Co zrobić w Rust** (`src/lua_api/binary_api.rs`):
1. Znaleźć gdzie namespace jest rejestrowany (pattern: `lua.globals().set("lurek", ...)`  lub `create_table` z `"data"`).
2. Zmienić string `"data"` na `"binary"` w rejestracji namespace.
3. Uruchomić `cargo build` — błędy kompilacji wskażą inne miejsca do zmiany.

**Co zrobić w dokumentacji**:
1. Zaktualizować `docs/specs/binary.md` — zmienić `Primary Lua namespace: lurek.data` na `lurek.binary`.
2. Zaktualizować wszystkie odniesienia do `lurek.data` w `docs/specs/` (grep: `lurek\.data`).

**Co zrobić w testach** (`tests/lua/`):
1. `grep -r "lurek\.data" tests/lua/` — znaleźć wszystkie pliki.
2. Podmienić `lurek.data` na `lurek.binary` w każdym pliku testowym.
3. Kluczowe pliki: `tests/lua/unit/test_binary_core_unit.lua`, `tests/lua/stress/test_binary_stress.lua`, `tests/lua/integration/test_binary_filesystem.lua`, `tests/lua/integration/test_binary_compute.lua`, `tests/lua/golden/test_binary_golden.lua`.

**Co zrobić w examples** (`content/examples/`):
1. `grep -r "lurek\.data" content/` — znaleźć wszystkie przykłady.
2. Podmienić namespace.

**Gate**: `cargo clippy -- -D warnings` czyste. `cargo test` zielone. `grep -r "lurek\.data" src/ tests/ content/` zwraca 0 wyników (poza `dataframe`).

**Przykładowa zmiana API** (przed / po):
```lua
-- PRZED
local bd = lurek.data.newByteData(1024)
local hash = lurek.data.hash(data, "sha256")

-- PO
local bd = lurek.binary.newByteData(1024)
local hash = lurek.binary.hash(data, "sha256")
```

---

## BLOK C — Naprawa namespace `lurek.input`

### P1-C1 — Naprawić primary namespace `input.md` z `lurek.input.keyboard` na `lurek.input`

**Priorytet**: Critical
**Owner**: Doc-Writer + Developer (weryfikacja)
**Zależności**: brak

**Problem**: `docs/specs/input.md` deklaruje `Primary Lua namespace: lurek.input.keyboard` zamiast `lurek.input`. Sugeruje że tylko klawiatura istnieje lub że root namespace jest nieodpowiedni.

**Co zrobić**:
1. Sprawdzić `src/lua_api/input_api.rs` — jakie sub-namespaces są naprawdę zarejestrowane (`keyboard`, `mouse`, `gamepad`?).
2. Jeśli `lurek.input.keyboard`, `lurek.input.mouse`, `lurek.input.gamepad` są osobnymi tabelami — dokumentować to w `input.md` z sekcją per sub-namespace.
3. Zmienić `Primary Lua namespace: lurek.input.keyboard` na `Primary Lua namespace: lurek.input` i dodać listę sub-namespaces.
4. Jeśli cały input jest pod `lurek.input.keyboard` — rozważyć refactor rejestracji na `lurek.input` (Developer task).

**Gate**: `input.md` ma `Primary Lua namespace: lurek.input`. Specyfikacja wymienia wszystkie dostępne sub-namespaces.

---

## BLOK D — Naprawa duplikatów

### P1-D1 — Zredukować overlap `lurek.event.Signal` vs `lurek.patterns.EventBus`

**Priorytet**: High
**Owner**: Lua-Designer + Doc-Writer
**Zależności**: brak

**Problem**: `lurek.event.LSignal` (pub-sub z wildcard) i `lurek.patterns.EventBus` (named event bus z wildcard, priority, one-shot) są konceptualnie tym samym. Programista nie wie którego użyć.

**Diagnoza**:
- `LSignal` (event module) — lightweight, Rust-backed, single signal
- `EventBus` (patterns module) — multi-channel, priority ordering, Lua-level

**Decyzja architektoniczna** (do wpisania w spec):
- `lurek.event.Signal` = **niskopoziomowy** single-signal dispatcher; używaj gdy jeden konkretny event type (np. `on_player_death`)
- `lurek.patterns.EventBus` = **wielokanałowy** pub-sub broker; używaj gdy wiele typów eventów przez jedną szynę

**Co zrobić w `docs/specs/event.md`**:
1. Dodać sekcję `## Boundaries` z wyjaśnieniem kiedy Signal vs EventBus.
2. Dodać cross-reference do `patterns.md`.

**Co zrobić w `docs/specs/patterns.md`**:
1. Dodać sekcję `## Boundaries` z odniesieniem do `event.Signal`.

**Co zrobić w `content/examples/`**:
1. Stworzyć `content/examples/event/signal_vs_eventbus.lua` — example pokazujący różnicę.

```lua
-- content/examples/event/signal_vs_eventbus.lua
-- KIEDY Signal: jeden konkretny event z prostymi callbackami
local onDeath = lurek.event.newSignal()
onDeath:connect("player_death", function(victim) print("killed:", victim) end)
onDeath:emit("player_death", "Player1")

-- KIEDY EventBus: wiele kanałów przez jedną szynę z priorityzacją
local bus = lurek.patterns.newEventBus()
bus:subscribe("combat.*", function(e, data) ... end, { priority = 10 })
bus:subscribe("ui.*", function(e, data) ... end)
bus:publish("combat.hit", { damage = 50 })
```

**Gate**: Oba spec pliki mają sekcję `## Boundaries`. Example plik istnieje. Żadna zmiana Rust nie jest potrzebna.

---

### P1-D2 — Zredukować overlap `lurek.validator` vs `lurek.serial.validate`

**Priorytet**: High
**Owner**: Developer + Lua-Designer
**Zależności**: brak

**Problem**: `lurek.validator` i `lurek.serial.validate` oba robią schema validation. Duplikacja kodu i confusion dla użytkownika.

**Co zrobić**:
1. Sprawdzić `src/lua_api/validator_api.rs` i `src/serialize/schema.rs` — czy kod jest zduplikowany czy jeden wola drugi.
2. Jeśli zduplikowany: refactor `src/serialize/schema.rs` aby był publiczny i używany przez `validator` module jako backend.
3. Zaktualizować `docs/specs/validator.md` i `docs/specs/serialize.md` z dokumentacją relacji.
4. Dodać example: `content/examples/data/validate_config.lua`.

```lua
-- content/examples/data/validate_config.lua
-- Walidacja przez lurek.serial (inline, lekka)
local ok, err = lurek.serial.validate(config, {
  type = "map",
  fields = { width = {type="number", min=1}, height = {type="number", min=1} }
})

-- Walidacja przez lurek.validator (reusable schema object)
local schema = lurek.validator.new()
schema:addRule("width", {type="number", min=1, required=true})
schema:addRule("height", {type="number", min=1, required=true})
local result = schema:validate(config)
```

**Gate**: Jeden z modułów używa kodu drugiego jako backend (bez duplikacji). Oba mają cross-reference w spec. Example istnieje.

---

### P1-D3 — Udokumentować relację `lurek.patterns.BehaviorTree` vs `lurek.ai.behavior_tree`

**Priorytet**: High
**Owner**: Doc-Writer
**Zależności**: brak

**Problem**: `lurek.patterns` zawiera `BehaviorTree` (strukturalne nodes i builder). `lurek.ai` zawiera BT executor z Lua callbacks. Użytkownik nie wie czego użyć.

**Co zrobić**:
1. Sprawdzić `src/ai/behavior_tree.rs` — czy importuje z `src/patterns/behavior_tree.rs`.
2. Dokumentować podział w obu specs:
   - `patterns.BehaviorTree` = **data structure** — nodes, builder, tree shape
   - `ai.BehaviorTree` = **runtime executor** — tick, Lua callbacks, running state
3. Dodać diagram ASCII w `docs/specs/ai.md` sekcja `## Dependencies`.

**Co zrobić w `docs/specs/patterns.md`**:
```markdown
## Boundaries
`lurek.patterns.newBehaviorTree` buduje strukturę drzewa (nodes, edges).
Dla AI execution z Lua callbackami użyj `lurek.ai` — które importuje patterns jako backend.
```

**Gate**: Oba spec mają sekcję Boundaries. Żadna zmiana Rust nie jest potrzebna.

---

### P1-D4 — Naprawa `lurek.event.exit` vs `lurek.event.quit` API

**Priorytet**: High
**Owner**: Developer + Lua-Designer
**Zależności**: brak

**Problem**: `lurek.event.exit` (z optional exit code) i `lurek.event.quit` (hardcoded 0) robią to samo z różnym interfejsem.

**Co zrobić**:
1. Sprawdzić `src/lua_api/event_api.rs` — jak są zarejestrowane.
2. Opcja A (bezpieczna): Deprecated `quit`, zmienić implementation `quit` na call `exit(0)`. Dodać `--- @deprecated` w docstring.
3. Opcja B (breaking): Usunąć `quit`, zostawić tylko `exit(code?)`.
4. Rekomendacja: Opcja A — backward compat.

**Co dodać w `src/lua_api/event_api.rs`**:
```rust
// lurek.event.quit — deprecated, use exit(0)
// Docstring: "Deprecated: use lurek.event.exit(0) instead."
```

**Co zrobić w testach** — dodać test że `quit()` jest równoważne `exit(0)`:
```lua
-- tests/lua/unit/test_event.lua (nowy test case)
-- test_quit_is_exit_zero
-- Sprawdza że quit() nie crashuje i jest aliasem exit(0)
```

**Gate**: `lurek.event.quit` ma `@deprecated` docstring wskazujący na `exit`. Nowy test case istnieje w `test_event.lua`.

---

## BLOK E — Naprawa `physics.CellularWorld` w złym module

### P1-E1 — Przenieść `CellularWorld` z `physics` do `procgen`

**Priorytet**: High
**Owner**: Developer
**Zależności**: brak

**Problem**: `lurek.physics.CellularWorld` (cellular automata — Conway's Game of Life style) nie jest fizyką. Powinno być w `lurek.procgen` (procedural generation).

**Co zrobić w Rust**:
1. Sprawdzić `src/physics/` — gdzie jest `CellularWorld` struct.
2. Przenieść plik `cellular_world.rs` (lub analogiczny) do `src/procgen/cellular_world.rs`.
3. Zaktualizować `src/physics/mod.rs` — usunąć `pub mod cellular_world`.
4. Zaktualizować `src/procgen/mod.rs` — dodać `pub mod cellular_world`.
5. Zaktualizować `src/lua_api/physics_api.rs` — usunąć binding `CellularWorld`.
6. Zaktualizować `src/lua_api/procgen_api.rs` — dodać binding `CellularWorld`.
7. Nowy namespace: `lurek.procgen.newCellularWorld(...)`.

**Co zrobić w testach**:
1. Przenieść testy cellular world do `tests/lua/unit/test_procgen_cellular.lua` (nowy plik).
2. Zaktualizować istniejące testy w `tests/lua/unit/test_physics.lua` jeśli testują `CellularWorld`.

**Co zrobić w dokumentacji**:
1. Zaktualizować `docs/specs/physics.md` — usunąć `CellularWorld` z Types i Functions.
2. Zaktualizować `docs/specs/procgen.md` — dodać `CellularWorld` do Types i Functions.
3. Regenerować API z `python tools/gen_all_docs.py`.

**Gate**: `cargo test` czyste. `grep "CellularWorld" src/physics/` = 0 wyników. `grep "CellularWorld" src/procgen/` > 0 wyników. `lurek.procgen.newCellularWorld` działa w Lua.

**Evidence test** (`tests/lua/unit/test_procgen_cellular.lua`):
```lua
-- test_cellular_world_basic
local world = lurek.procgen.newCellularWorld(50, 50)
world:fill(0.4)  -- 40% alive
world:step()
local alive = world:countAlive()
assert(type(alive) == "number", "countAlive returns number")
assert(alive >= 0 and alive <= 2500, "alive count in range")
```

---

## BLOK F — Naprawa `procgen` tier

### P1-F1 — Zmienić tier `procgen` z Foundations na Feature Systems

**Priorytet**: Medium
**Owner**: Doc-Writer (tylko spec zmiana)
**Zależności**: P1-E1 (cellular world move)

**Problem**: `procgen` jest w Foundations tier ale korzysta z `math`, `tilemap`, `render`. Zależności cross-tier są dozwolone (Foundations → wyżej) ale tutaj jest odwrotnie — Foundations dependuje od Feature Systems (`tilemap`).

**Co zrobić w `docs/specs/procgen.md`**:
1. Zmienić `Module group: Foundations` na `Module group: Feature Systems`.
2. Zaktualizować `docs/specs/README.md` — przenieść `procgen` z sekcji Foundations do Feature Systems.
3. Sprawdzić `docs/architecture/philosophy.md` — czy diagram tier zależy od tej klasyfikacji.

**Gate**: `procgen.md` ma `Module group: Feature Systems`. `README.md` zawiera `procgen` w sekcji Feature Systems.

---

## BLOK G — Naprawa `serialize` namespace niespójności

### P1-G1 — Synchronizacja nazwy: `serialize.md` / `src/serialize/` / `lurek.serial`

**Priorytet**: Medium
**Owner**: Developer + Doc-Writer
**Zależności**: brak

**Problem**: Trzy różne nazwy dla jednego modułu: spec = `serialize.md`, src = `src/serialize/`, namespace = `lurek.serial`. Niespójność.

**Decyzja**: Zmienić namespace z `lurek.serial` na `lurek.serialize` dla spójności (breaking change, ale lepiej teraz niż później).

**Alternatywa (mniej breaking)**: Zmienić tylko spec i src folder na `serial`, pozostawić namespace. Brak wartości.

**Co zrobić** (opcja recommended — align wszystko na `serialize`):
1. `src/lua_api/serialize_api.rs` — zmienić rejestrację namespace z `"serial"` na `"serialize"`.
2. `grep -r "lurek\.serial" tests/ content/ docs/` — znaleźć wszystkie użycia.
3. Podmienić `lurek.serial` na `lurek.serialize` wszędzie.
4. Sprawdzić czy `lurek.data.parseToml` / `lurek.data.encodeToml` (z binary.md!) powinny być przeniesione do `lurek.serialize` — to dodatkowy overlap do rozwiązania.

**Test unit** (aktualizacja istniejących):
```lua
-- tests/lua/unit/test_serialize.lua (jeśli istnieje, aktualizuj)
local data = {name = "test", value = 42}
local json = lurek.serialize.toJson(data)
assert(type(json) == "string")
local back = lurek.serialize.fromJson(json)
assert(back.name == "test")
```

**Gate**: `grep -r "lurek\.serial[^i]" tests/ content/ src/lua_api/` = 0 wyników. `lurek.serialize.toJson` działa.

---

## BLOK H — Naprawa rendering overlap (`DepthSorter` w złym module)

### P1-H1 — Przenieść `DepthSorter` Lua API z `scene` do `render`

**Priorytet**: Medium
**Owner**: Developer + Lua-Designer
**Zależności**: brak

**Problem**: `lurek.scene.newDepthSorter()` i `LDepthSorter` są zakotwiczone w `scene` module, ale depth sorting jest generalnym rendering concern używanym poza kontekstem scene management.

**Co zrobić**:
1. Dodać `lurek.render.newDepthSorter()` jako alias lub przeniesienie z `scene`.
2. Zachować `lurek.scene.newDepthSorter()` jako deprecated alias wskazujący na `lurek.render.newDepthSorter()`.
3. Zaktualizować `docs/specs/render.md` — dodać `LDepthSorter`.
4. Zaktualizować `docs/specs/scene.md` — dodać deprecation note.

**Nowe testy** (`tests/lua/unit/test_render.lua`):
```lua
-- test_depth_sorter_via_render
local sorter = lurek.render.newDepthSorter()
assert(sorter ~= nil)
sorter:add(function() end, 5.0)
sorter:add(function() end, 1.0)
assert(sorter:getCount() == 2)
sorter:flush()
assert(sorter:getCount() == 0)
```

**Gate**: `lurek.render.newDepthSorter()` działa. `lurek.scene.newDepthSorter()` działa z deprecation log. Nowy test zielony.

---

## BLOK I — Naprawa `input` — brakujące convenience API

### P1-I1 — Dodać `lurek.input.actions` — action mapping system

**Priorytet**: High
**Owner**: Developer + Lua-Designer
**Zależności**: P1-C1

**Problem**: Brak action mapping system (Godot `InputMap` style). Hardkodowane klawisze są złą praktyką. Kluczowe dla moddability.

**Co zrobić w Rust** (nowy plik `src/input/actions.rs`):
```rust
// src/input/actions.rs
// ActionMap: maps string action names to one or more key/button bindings
pub struct ActionMap {
    bindings: HashMap<String, Vec<ActionBinding>>,
}

pub enum ActionBinding {
    Key(KeyCode),
    MouseButton(MouseButton),
    GamepadButton(GamepadButton),
}

impl ActionMap {
    pub fn bind(name: &str, binding: ActionBinding) -> Result<()>
    pub fn unbind(name: &str) -> bool
    pub fn is_pressed(name: &str) -> bool
    pub fn is_just_pressed(name: &str) -> bool
    pub fn is_just_released(name: &str) -> bool
    pub fn get_axis(neg: &str, pos: &str) -> f32  // -1.0 to 1.0
    pub fn get_vector(left: &str, right: &str, up: &str, down: &str) -> Vec2
}
```

**Nowe Lua API** (`src/lua_api/input_api.rs`):
```lua
-- lurek.input.actions
lurek.input.actions.bind("jump", "Space")
lurek.input.actions.bind("jump", "Gamepad:A")  -- multiple bindings
lurek.input.actions.unbind("jump", "Space")
lurek.input.actions.clear("jump")
lurek.input.actions.isPressed("jump")        -- bool
lurek.input.actions.isJustPressed("jump")   -- bool
lurek.input.actions.isJustReleased("jump")  -- bool
lurek.input.actions.getAxis("move_left", "move_right")  -- -1.0 to 1.0
lurek.input.actions.getVector("left", "right", "up", "down")  -- Vec2
lurek.input.actions.save()   -- serialize to TOML (returns string)
lurek.input.actions.load(toml_str)  -- restore from TOML
```

**Testy** (`tests/lua/unit/test_input_actions.lua`):
```lua
-- test_bind_and_check
lurek.input.actions.bind("jump", "Space")
assert(lurek.input.actions.isBound("jump"))
lurek.input.actions.unbind("jump", "Space")
assert(not lurek.input.actions.isBound("jump"))

-- test_axis_neutral
lurek.input.actions.bind("move_left", "A")
lurek.input.actions.bind("move_right", "D")
local axis = lurek.input.actions.getAxis("move_left", "move_right")
assert(axis == 0.0, "neutral axis = 0")

-- test_save_load_roundtrip
lurek.input.actions.bind("attack", "MouseButton:Left")
local saved = lurek.input.actions.save()
lurek.input.actions.clear("attack")
lurek.input.actions.load(saved)
assert(lurek.input.actions.isBound("attack"))
```

**Evidence** (`tests/lua/evidence/test_input_actions_evidence.lua`):
```lua
-- Demonstrates action mapping workflow
lurek.input.actions.bind("jump", "Space")
lurek.input.actions.bind("jump", "Gamepad:A")
-- In game loop:
-- if lurek.input.actions.isJustPressed("jump") then player:jump() end
```

**Gate**: `cargo test` czyste. Nowe Lua testy zielone. `docs/specs/input.md` ma sekcję `## Actions System`. `python tools/gen_all_docs.py` regeneruje docs bez błędów.

---

## BLOK J — Naprawa `network` — AI-friendly convenience API

### P1-J1 — Dodać `lurek.network.httpJson(url, body, headers)` convenience function

**Priorytet**: High
**Owner**: Developer + Lua-Designer
**Zależności**: brak

**Problem**: HTTP/WebSocket już istnieje ale jest ukryte za `newRuntime()` boilerplate. Dla AI-first use case (call OpenAI API) potrzebny shortcut.

**Co zrobić w Rust** (`src/lua_api/network_api.rs`):
Dodać statyczne convenience functions które internalizują `NetworkRuntime` lifecycle:

```rust
// lurek.network.httpGet(url, options?) -> {status, body, headers} or error
// lurek.network.httpPost(url, body, options?) -> {status, body, headers}
// lurek.network.httpJson(url, body, options?) -> parsed Lua table (auto-decode JSON response)
// Wszystkie synchroniczne (blocking, w tle NetworkRuntime) z timeout
```

**Nowe Lua API**:
```lua
-- Krótki helper — bez zarządzania runtime
local resp = lurek.network.httpGet("https://api.example.com/data")
-- resp.status, resp.body, resp.headers

-- AI-first: automatyczny JSON encode/decode
local result = lurek.network.httpJson(
  "http://localhost:11434/api/generate",  -- Ollama
  { model = "llama3", prompt = "Hello!" },
  { timeout = 30000 }
)
print(result.response)  -- LLM response text

-- SSE convenience (streaming LLM)
lurek.network.httpStream(url, body, function(chunk)
  io.write(chunk)  -- streaming token output
end)
```

**Testy** (`tests/lua/unit/test_network_http.lua`):
```lua
-- test_httpGet_returns_table (mock lub skip w CI)
-- @requires network
local resp = lurek.network.httpGet("http://httpbin.org/get")
assert(resp ~= nil)
assert(type(resp.status) == "number")
assert(resp.status == 200)

-- test_httpJson_roundtrip (local mock server lub skip)
-- @requires network
local data = { test = true, value = 42 }
local resp = lurek.network.httpJson("http://httpbin.org/post", data)
assert(resp ~= nil)
```

**Integration example** (`content/examples/network/llm_request.lua`):
```lua
-- content/examples/network/llm_request.lua
-- Przykład integracji z Ollama (local LLM)
local function askLLM(prompt)
  local result = lurek.network.httpJson(
    "http://localhost:11434/api/generate",
    { model = "llama3", prompt = prompt, stream = false }
  )
  if result and result.response then
    return result.response
  end
  return nil
end

local answer = askLLM("What is 2+2?")
print("LLM says:", answer)
```

**Gate**: Nowe funkcje istnieją w `lurek.network`. Tests zielone (z `@requires network` skip dla CI). Example plik istnieje. Docs zaktualizowane.

---

## BLOK K — Naprawa `physics` — brakujące joints

### P1-K1 — Dodać `lurek.physics.joint` API (Rapier2D joints)

**Priorytet**: Medium
**Owner**: Developer + Lua-Designer
**Zależności**: brak

**Problem**: Rapier2D wspiera joints (spring, distance, revolute, prismatic). Brak eksponowania przez `lurek.physics`.

**Co zrobić w Rust** (`src/physics/` + `src/lua_api/physics_api.rs`):
```rust
// Nowe typy joint
pub enum JointType { Fixed, Revolute, Prismatic, Distance, Spring }
pub struct JointHandle(rapier2d::dynamics::ImpulseJointHandle);
```

**Nowe Lua API**:
```lua
lurek.physics.createFixedJoint(body_a, body_b)          -- JointHandle
lurek.physics.createRevoluteJoint(body_a, body_b, anchor_a, anchor_b)  -- hinge
lurek.physics.createDistanceJoint(body_a, body_b, rest_length)  -- rope/chain
lurek.physics.createSpringJoint(body_a, body_b, stiffness, damping)
lurek.physics.destroyJoint(handle)
lurek.physics.setJointMotor(handle, target_velocity, max_force)  -- dla revolute
```

**Testy** (`tests/lua/unit/test_physics_joints.lua`):
```lua
-- test_revolute_joint_creation
local world = lurek.physics.newWorld()
local a = world:createBody({type="dynamic", x=0, y=0})
local b = world:createBody({type="dynamic", x=2, y=0})
local joint = world:createRevoluteJoint(a, b, {x=0,y=0}, {x=-1,y=0})
assert(joint ~= nil)
assert(joint:getType() == "revolute")
world:destroyJoint(joint)
```

**Gate**: `cargo test` czyste. Joint Lua tests zielone. `docs/specs/physics.md` zaktualizowane z joints sekcją.

---

## BLOK L — Naprawa `camera` — brakujące helpers

### P1-L1 — Dodać `lurek.camera.shake`, `follow`, `worldToScreen`

**Priorytet**: Medium
**Owner**: Developer + Lua-Designer
**Zależności**: brak

**Nowe Lua API**:
```lua
-- Camera shake via noise/spring
lurek.camera.shake(intensity, duration, falloff?)
-- falloff: "linear" | "exponential" (default: "linear")

-- Smooth follow (call each frame)
lurek.camera.follow(target_x, target_y, lerp_speed)
-- target_x, target_y: world position to follow
-- lerp_speed: 0.0 (instant) to 1.0 (never catch up), default 0.1

-- Coordinate conversion
local sx, sy = lurek.camera.worldToScreen(wx, wy)
local wx, wy = lurek.camera.screenToWorld(sx, sy)
```

**Testy** (`tests/lua/unit/test_camera_helpers.lua`):
```lua
-- test_worldToScreen_identity_at_origin
lurek.camera.setPosition(0, 0)
lurek.camera.setZoom(1.0)
local sx, sy = lurek.camera.worldToScreen(0, 0)
-- Should map to screen center
local w, h = lurek.window.getSize()
assert(math.abs(sx - w/2) < 1, "origin maps to screen center X")
assert(math.abs(sy - h/2) < 1, "origin maps to screen center Y")

-- test_screenToWorld_inverse
local wx, wy = lurek.camera.screenToWorld(sx, sy)
assert(math.abs(wx) < 0.01, "inverse round-trip X")
assert(math.abs(wy) < 0.01, "inverse round-trip Y")
```

**Gate**: Nowe metody istnieją. Tests zielone. `docs/specs/camera.md` zaktualizowane.

---

## BLOK M — Naprawa `learning` — unified inference interface

### P1-M1 — Dodać `lurek.learning.Model` common interface

**Priorytet**: High
**Owner**: Lua-Designer + Developer
**Zależności**: brak

**Problem**: `NeuralNet`, `QLearner`, `GeneticAlgorithm`, `Neuroevolution`, `Bandit` — każdy ma inne metody do inference. Brak unified `model:predict(input)` interface.

**Co zrobić**:
1. Sprawdzić obecne API każdego typu w `docs/specs/learning.md`.
2. Dodać unified `:predict(input)` method jako alias:
   - `NeuralNet:predict(inputs)` → alias `forward(inputs)`
   - `QLearner:predict(state)` → alias `selectAction(state)`
   - `Bandit:predict()` → alias `pull()`
3. Dodać `lurek.learning.wrap(model)` — wraps any model in a common `LModel` interface.

**Nowe Lua API**:
```lua
-- Każdy model ma :predict()
local net = lurek.learning.newNeuralNet({layers = {2, 4, 1}})
net:setWeights(weights)
local output = net:predict({0.5, 0.3})  -- alias dla net:forward(...)

local qlearner = lurek.learning.newQLearner({states=10, actions=4})
local action = qlearner:predict(current_state)  -- alias dla selectAction

-- Universal model wrapper
local model = lurek.learning.wrap(net)
local result = model:predict(input)   -- works for any model type
model:save("model.json")
model:load("model.json")
```

**Testy** (`tests/lua/unit/test_learning_inference.lua`):
```lua
-- test_neural_net_predict_alias
local net = lurek.learning.newNeuralNet({layers = {2, 4, 1}})
local out_forward = net:forward({0.5, 0.3})
local out_predict = net:predict({0.5, 0.3})
assert(#out_forward == #out_predict, "predict = forward")
assert(math.abs(out_forward[1] - out_predict[1]) < 0.0001)

-- test_qlearner_predict_alias
local q = lurek.learning.newQLearner({states=5, actions=3})
local a1 = q:selectAction(0)
local a2 = q:predict(0)
assert(a1 == a2, "predict = selectAction")

-- test_wrap_interface
local net2 = lurek.learning.newNeuralNet({layers={1,1}})
local model = lurek.learning.wrap(net2)
assert(model ~= nil)
local r = model:predict({0.5})
assert(type(r) == "table")
```

**Gate**: `:predict()` działa na wszystkich model types. `lurek.learning.wrap()` istnieje. Tests zielone.

---

## BLOK N — Dokumentacja boundaries UI trio

### P1-N1 — Zdefiniować hierarchię `lurek.ui` / `lurek.html` / `lurek.layout`

**Priorytet**: High
**Owner**: Doc-Writer + Architect (design decision)
**Zależności**: brak

**Problem**: Trzy moduły UI bez dokumentacji który jest primary i jak są połączone.

**Decyzja do wpisania w specyfikacjach**:
- `lurek.layout` = **TOML layout engine** — definiuje hierarchię elementów UI w danych (`.toml` files). Jest backend/data layer.
- `lurek.html` = **HTML/CSS renderer** — renderuje strony HTML. Primary dla AI-generated UI (AI pisze HTML). Zależy od `lurek.layout` jako fallback i `lurek.render` jako backend.
- `lurek.ui` = **2D Game UI widgets** — immediate-mode style game-specific widgets (health bars, inventory slots, dialog boxes). Dla game-specific UI gdy HTML jest za ciężki.

**Hierarchia zależności**:
```
lurek.render (GPU backend)
    ↑
lurek.layout (TOML data) → lurek.html (HTML renderer)
                               ↑
                           lurek.ui (game widgets, uses html or direct render)
```

**Co zrobić w docs**:
1. Dodać sekcję `## UI Architecture` do każdego z trzech spec plików.
2. Stworzyć `docs/architecture/ui-hierarchy.md` z pełnym diagramem.
3. Stworzyć przykłady dla każdego:

```lua
-- content/examples/ui/layout_toml.lua — when to use layout
-- content/examples/ui/html_generated.lua — AI generates HTML UI
-- content/examples/ui/ui_widgets.lua — game-specific widgets
```

**Gate**: Każdy z trzech spec plików ma sekcję `## UI Architecture` z opisem roli i cross-references. `docs/architecture/ui-hierarchy.md` istnieje.

---

## BLOK O — Naprawa `visibility` tier assignment

### P1-O1 — Przenieść `visibility.md` z Edge do Feature Systems

**Priorytet**: Medium
**Owner**: Doc-Writer
**Zależności**: brak

**Problem**: `lurek.visibility` (fog of war, line of sight) jest w Edge/Integration tier ale to core game feature używana z `lurek.ai`, `lurek.pathfind` i `lurek.tilemap`.

**Co zrobić**:
1. Zmienić `Module group: Edge/Integration` na `Module group: Feature Systems` w `docs/specs/visibility.md`.
2. Zaktualizować `docs/specs/README.md` — przenieść `visibility` do Feature Systems sekcji.
3. Dodać cross-references do `ai.md`, `pathfind.md`, `tilemap.md` (wspólny use case: fog of war z AI agents).

**Gate**: `visibility.md` ma `Module group: Feature Systems`. `README.md` zawiera `visibility` w Feature Systems.

---

## BLOK P — Naprawa `cursor.md` tier

### P1-P1 — Przenieść `cursor.md` z Edge do Platform Services

**Priorytet**: Low
**Owner**: Doc-Writer
**Zależności**: brak

**Problem**: `lurek.cursor` (mouse cursor management) jest w Edge/Integration. Logicznie należy do Platform Services obok `lurek.window` i `lurek.input`.

**Co zrobić**:
1. Zmienić `Module group: Edge/Integration` na `Module group: Platform Services` w `docs/specs/cursor.md`.
2. Zaktualizować `docs/specs/README.md`.
3. Dodać cross-reference z `docs/specs/window.md` i `docs/specs/input.md`.

**Gate**: `cursor.md` ma `Module group: Platform Services`.

---

## BLOK Q — Naprawa `grep.md` — scalenie z `filesystem`

### P1-Q1 — Scalić `lurek.grep` funkcjonalność z `lurek.filesystem`

**Priorytet**: Medium
**Owner**: Developer + Doc-Writer
**Zależności**: brak

**Problem**: `lurek.grep` (pattern search in files) jest osobnym modułem Edge tier podczas gdy logicznie należy do `lurek.filesystem`.

**Co zrobić**:
1. Sprawdzić `src/lua_api/grep_api.rs` — jakie funkcje są eksponowane.
2. Dodać te funkcje do `src/lua_api/filesystem_api.rs` jako `lurek.filesystem.grep(path, pattern, options?)`.
3. Zachować `lurek.grep` jako deprecated namespace z aliasami.
4. Zaktualizować `docs/specs/filesystem.md` — dodać grep funkcje.
5. Dodać deprecation note do `docs/specs/grep.md`.

**Nowe Lua API** w `lurek.filesystem`:
```lua
-- lurek.filesystem.grep(path, pattern, options?) -> array of matches
local matches = lurek.filesystem.grep("content/", "lurek%.ai", {
  recursive = true,
  extensions = {".lua"},
  context = 2  -- lines of context around match
})
-- matches[i] = { file, line, content, context_before, context_after }
```

**Gate**: `lurek.filesystem.grep()` działa. `lurek.grep` nadal działa z deprecation warning. Tests zaktualizowane.

---

## BLOK R — Naprawa `log` — structured logging

### P1-R1 — Dodać structured logging do `lurek.log`

**Priorytet**: Medium
**Owner**: Developer + Lua-Designer
**Zależności**: brak

**Problem**: Brak machine-readable log output. Dla AI-first: agent logi powinny być parsowalne przez inne systemy.

**Nowe Lua API**:
```lua
-- Structured log z polami klucz-wartość (emituje JSON line do log output)
lurek.log.info("agent_step", {
  agent_id = "npc_guard_01",
  action = "patrol",
  position = {x = 100, y = 200},
  tick = 1234
})
-- Output: {"level":"info","event":"agent_step","agent_id":"npc_guard_01","action":"patrol",...}

-- Span dla distributed tracing
local span = lurek.log.beginSpan("pipeline_run", {pipeline_id = "main"})
-- ... do work ...
span:addField("nodes_executed", 5)
span:end()

-- Log sink configuration
lurek.log.setSink("json_file", "logs/agent.jsonl")  -- JSON lines output
lurek.log.setSink("console")  -- default human-readable
```

**Testy** (`tests/lua/unit/test_log_structured.lua`):
```lua
-- test_structured_log_fields
lurek.log.info("test_event", {field_a = 1, field_b = "hello"})
-- Verify no crash, output is valid (integration test checks file content)

-- test_span_lifecycle
local span = lurek.log.beginSpan("test_span")
assert(span ~= nil)
span:addField("count", 42)
local ok = span:finish()
assert(ok == true)
```

**Gate**: `lurek.log.info(event, fields)` działa. Span API działa. `docs/specs/log.md` zaktualizowane.

---

## BLOK S — Naprawa `ecs` — snapshot API

### P1-S1 — Dodać `lurek.ecs.snapshot()` / `lurek.ecs.restore()`

**Priorytet**: Medium
**Owner**: Developer + Lua-Designer
**Zależności**: brak

**Problem**: Brak world state serialization. Kluczowe dla AI rollback, MCTS tree search, save/load systems.

**Nowe Lua API**:
```lua
-- Capture entire ECS world state
local snapshot = lurek.ecs.snapshot()
-- snapshot is opaque userdata or serializable table

-- Restore from snapshot
lurek.ecs.restore(snapshot)

-- Lightweight snapshot (only specific components)
local partial = lurek.ecs.snapshot({ components = {"Position", "Health", "Velocity"} })

-- Serialize snapshot to bytes (for save file)
local bytes = snapshot:serialize()
local restored = lurek.ecs.deserializeSnapshot(bytes)
```

**Testy** (`tests/lua/unit/test_ecs_snapshot.lua`):
```lua
-- test_snapshot_roundtrip
local world = lurek.ecs.newWorld()
local e = world:spawn()
world:add(e, "Health", {current = 80, max = 100})
world:add(e, "Position", {x = 10, y = 20})

local snap = world:snapshot()
world:set(e, "Health", {current = 50, max = 100})  -- modify
assert(world:get(e, "Health").current == 50)

world:restore(snap)
assert(world:get(e, "Health").current == 80, "restored to 80")
assert(world:get(e, "Position").x == 10, "position restored")

-- test_partial_snapshot
local partial = world:snapshot({components = {"Health"}})
world:set(e, "Health", {current = 10, max = 100})
world:set(e, "Position", {x = 99, y = 99})
world:restore(partial)
assert(world:get(e, "Health").current == 80, "health restored from partial")
assert(world:get(e, "Position").x == 99, "position NOT restored in partial")
```

**Gate**: `world:snapshot()` i `world:restore()` działają. Tests zielone.

---

## BLOK T — Naprawa `math` — module-level helpers

### P1-T1 — Dodać `lurek.math.lerp`, `clamp`, `smoothstep` jako top-level

**Priorytet**: Low
**Owner**: Lua-Designer (tylko API binding, logika już istnieje)
**Zależności**: brak

**Nowe Lua API**:
```lua
lurek.math.lerp(a, b, t)        -- linear interpolate: a + (b-a)*t
lurek.math.clamp(x, min, max)   -- clamp x to [min, max]
lurek.math.smoothstep(edge0, edge1, x)  -- smooth interpolation
lurek.math.sign(x)              -- -1, 0, or 1
lurek.math.round(x)             -- round to nearest integer
lurek.math.map(x, in_min, in_max, out_min, out_max)  -- remap range
```

**Testy** (`tests/lua/unit/test_math_helpers.lua`):
```lua
assert(lurek.math.lerp(0, 10, 0.5) == 5.0)
assert(lurek.math.clamp(15, 0, 10) == 10)
assert(lurek.math.clamp(-5, 0, 10) == 0)
assert(lurek.math.sign(-3) == -1)
assert(lurek.math.sign(0) == 0)
assert(lurek.math.sign(7) == 1)
assert(lurek.math.map(5, 0, 10, 0, 100) == 50)
```

**Gate**: Wszystkie nowe funkcje w `lurek.math`. Tests zielone.

---

## Podsumowanie planu

### Mapa zależności i kolejność

```
BLOK A (deduplikacja docs) ────────────────┐
BLOK B (rename lurek.data)  ───────────────┤
BLOK C (fix input namespace) ──────────────┤→ BLOK I (input.actions, zależy od C1)
BLOK D (duplikaty: Signal/EventBus) ───────┤
BLOK E (CellularWorld → procgen) ──────────┤→ BLOK F (procgen tier, zależy od E1)
BLOK G (serialize namespace) ──────────────┤
BLOK H (DepthSorter → render) ─────────────┤
BLOK J (network httpJson) ─────────────────┤
BLOK K (physics joints) ───────────────────┤
BLOK L (camera helpers) ───────────────────┤
BLOK M (learning inference) ───────────────┤
BLOK N (UI trio docs) ─────────────────────┤
BLOK O (visibility tier) ──────────────────┤
BLOK P (cursor tier) ──────────────────────┤
BLOK Q (grep → filesystem) ────────────────┤
BLOK R (structured log) ───────────────────┤
BLOK S (ecs snapshot) ─────────────────────┤
BLOK T (math helpers) ─────────────────────┘
```

### Tabela wszystkich zadań

| ID | Blok | Priorytet | Owner | Rust? | Lua Tests? | Zależności |
|---|---|---|---|---|---|---|
| P1-A1 | A | Critical | Doc-Writer | Nie | Nie | — |
| P1-A2 | A | Critical | Doc-Writer | Nie | Nie | — |
| P1-A3 | A | Critical | Doc-Writer + Dev | Nie | Nie | — |
| P1-B1 | B | Critical | Developer | Tak | Tak | — |
| P1-C1 | C | Critical | Doc-Writer + Dev | Nie | Nie | — |
| P1-D1 | D | High | Lua-Designer | Nie | Tak | — |
| P1-D2 | D | High | Developer | Tak | Tak | — |
| P1-D3 | D | High | Doc-Writer | Nie | Nie | — |
| P1-D4 | D | High | Developer | Tak | Tak | — |
| P1-E1 | E | High | Developer | Tak | Tak | — |
| P1-F1 | F | Medium | Doc-Writer | Nie | Nie | P1-E1 |
| P1-G1 | G | Medium | Developer | Tak | Tak | — |
| P1-H1 | H | Medium | Developer | Tak | Tak | — |
| P1-I1 | I | High | Developer | Tak | Tak | P1-C1 |
| P1-J1 | J | High | Developer | Tak | Tak | — |
| P1-K1 | K | Medium | Developer | Tak | Tak | — |
| P1-L1 | L | Medium | Developer | Tak | Tak | — |
| P1-M1 | M | High | Lua-Designer + Dev | Tak | Tak | — |
| P1-N1 | N | High | Doc-Writer | Nie | Nie | — |
| P1-O1 | O | Medium | Doc-Writer | Nie | Nie | — |
| P1-P1 | P | Low | Doc-Writer | Nie | Nie | — |
| P1-Q1 | Q | Medium | Developer | Tak | Tak | — |
| P1-R1 | R | Medium | Developer | Tak | Tak | — |
| P1-S1 | S | Medium | Developer | Tak | Tak | — |
| P1-T1 | T | Low | Lua-Designer | Tak | Tak | — |

### Quality Gate per task
Każdy task przed zamknięciem musi przejść:
1. `cargo test` — zero failures
2. `cargo clippy -- -D warnings` — zero warnings
3. `python tools/gen_all_docs.py` — bez błędów (jeśli zmieniono API)
4. `python tools/validate/cag_validate.py` — (jeśli zmieniono .agents/)
5. Nowe Lua testy w poprawnej lokalizacji (`tests/lua/unit/` lub `tests/lua/integration/`)
6. `docs/CHANGELOG.md` zaktualizowany
