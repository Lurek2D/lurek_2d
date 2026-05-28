# Plan 1: Poprawki IstniejÄ…cych ModuĹ‚Ăłw

> **Cel**: NaprawiÄ‡ naming, duplikaty, braki API, wrong-tier assignments i niespĂłjnoĹ›ci w istniejÄ…cych moduĹ‚ach bez wprowadzania nowych moduĹ‚Ăłw.
> **Agent owner**: Developer (Rust/API changes), Lua-Designer (API surface), Doc-Writer (spec sync)
> **Nie obejmuje**: Nowych moduĹ‚Ăłw (patrz Plan 2)

---

## Metodologia planowania

KaĹĽde zadanie ma:
- **ID** â€” unikalny identyfikator (P1-XX)
- **Priorytet** â€” Critical / High / Medium / Low
- **Owner** â€” agent ktĂłry wykonuje
- **Gate** â€” warunek ukoĹ„czenia (binarny)
- **ZaleĹĽnoĹ›ci** â€” ktĂłre taski muszÄ… byÄ‡ przed
- **Zakres zmian** â€” dokĹ‚adnie co i gdzie

KolejnoĹ›Ä‡ wykonania: Krytyczne najpierw â†’ High â†’ Medium â†’ Low. Zadania bez zaleĹĽnoĹ›ci mogÄ… byÄ‡ rĂłwnolegĹ‚e.

---

## BLOK A â€” Krytyczne rename i deduplikacja (bez zmian Rust)

> Ĺ»adne zadanie z tego bloku nie wymaga zmian w `src/`. Tylko dokumentacja i spec pliki.

### P1-A1 â€” ScaliÄ‡ `lua_api.md` i `runtime.md`

**Priorytet**: Critical
**Owner**: Doc-Writer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: Dwa spec pliki (`docs/specs/lua_api.md`, `docs/specs/runtime.md`) mapujÄ… na ten sam namespace `lurek.runtime`. To duplikat w dokumentacji.

**Co zrobiÄ‡**:
1. OtworzyÄ‡ oba pliki i porĂłwnaÄ‡ sekcje.
2. WybraÄ‡ `runtime.md` jako plik kanoniczny (bardziej kompletny).
3. PrzenieĹ›Ä‡ wszystkie unikalne sekcje z `lua_api.md` do `runtime.md`.
4. UsunÄ…Ä‡ `docs/specs/lua_api.md`.
5. ZaktualizowaÄ‡ `docs/specs/README.md` â€” usunÄ…Ä‡ wpis `lua_api`.
6. ZaktualizowaÄ‡ `docs/CHANGELOG.md`.

**Gate**: `docs/specs/lua_api.md` nie istnieje. `docs/specs/runtime.md` zawiera wszystkie API z obu plikĂłw. `README.md` nie ma wpisu `lua_api`.

---

### P1-A2 â€” PrzenieĹ›Ä‡ `vscode-extension.md` poza `docs/specs/`

**Priorytet**: Critical
**Owner**: Doc-Writer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: `docs/specs/vscode-extension.md` dokumentuje narzÄ™dzie deweloperskie, nie czÄ™Ĺ›Ä‡ lurek.* API Lua. ZaĹ›mieca przestrzeĹ„ specs.

**Co zrobiÄ‡**:
1. PrzenieĹ›Ä‡ plik do `extension/vscode/docs/vscode-extension.md`.
2. UsunÄ…Ä‡ `docs/specs/vscode-extension.md`.
3. ZaktualizowaÄ‡ `docs/specs/README.md` â€” usunÄ…Ä‡ wpis `vscode-extension`.
4. DodaÄ‡ link do nowej lokalizacji z `extension/vscode/README.md`.
5. ZaktualizowaÄ‡ `docs/CHANGELOG.md`.

**Gate**: Plik nie istnieje w `docs/specs/`. Istnieje w `extension/vscode/docs/`. Ĺ»adne linki w `docs/specs/README.md` do niego nie wskazujÄ….

---

### P1-A3 â€” WyjaĹ›niÄ‡ `bin.md` i usunÄ…Ä‡ z lurek.* surface

**Priorytet**: Critical
**Owner**: Doc-Writer + Developer (weryfikacja)
**ZaleĹĽnoĹ›ci**: brak

**Problem**: `bin.md` nie ma primary Lua namespace. Jest w Edge/Integration tier. Niejasne czy to spec dla binarki engine czy coĹ› innego.

**Co zrobiÄ‡**:
1. SprawdziÄ‡ `src/bin/` lub analogiczne â€” czy jest kod powiÄ…zany z `bin.md`.
2. JeĹ›li to spec dla main binary (`src/main.rs` lub entry point) â€” przenieĹ›Ä‡ do `docs/architecture/binary-entry.md`.
3. JeĹ›li `bin.md` dokumentuje coĹ› co ma API â€” uzupeĹ‚niÄ‡ `Primary Lua namespace`.
4. UsunÄ…Ä‡ z `docs/specs/` jeĹ›li nie jest czÄ™Ĺ›ciÄ… lurek.* API.
5. ZaktualizowaÄ‡ `docs/specs/README.md`.

**Gate**: `bin.md` albo ma poprawny namespace albo nie istnieje w `docs/specs/`.

---

## BLOK B â€” Rename namespace `lurek.data` â†’ `lurek.binary`

> Wymaga zmian w Rust (`src/lua_api/binary_api.rs`), testach, przykĹ‚adach i docs.

### P1-B1 â€” Rename `lurek.data` na `lurek.binary` w bindings

**Priorytet**: Critical
**Owner**: Developer + Lua-Designer
**ZaleĹĽnoĹ›ci**: brak (blok A moĹĽe iĹ›Ä‡ rĂłwnolegle)

**Problem**: `binary.md` spec file, `src/binary/` source, ale namespace = `lurek.data`. Powoduje konfuzjÄ™ z `lurek.dataframe`.

**Co zrobiÄ‡ w Rust** (`src/lua_api/binary_api.rs`):
1. ZnaleĹşÄ‡ gdzie namespace jest rejestrowany (pattern: `lua.globals().set("lurek", ...)`  lub `create_table` z `"data"`).
2. ZmieniÄ‡ string `"data"` na `"binary"` w rejestracji namespace.
3. UruchomiÄ‡ `cargo build` â€” bĹ‚Ä™dy kompilacji wskaĹĽÄ… inne miejsca do zmiany.

**Co zrobiÄ‡ w dokumentacji**:
1. ZaktualizowaÄ‡ `docs/specs/binary.md` â€” zmieniÄ‡ `Primary Lua namespace: lurek.data` na `lurek.binary`.
2. ZaktualizowaÄ‡ wszystkie odniesienia do `lurek.data` w `docs/specs/` (grep: `lurek\.data`).

**Co zrobiÄ‡ w testach** (`tests/lua/`):
1. `grep -r "lurek\.data" tests/lua/` â€” znaleĹşÄ‡ wszystkie pliki.
2. PodmieniÄ‡ `lurek.data` na `lurek.binary` w kaĹĽdym pliku testowym.
3. Kluczowe pliki: `tests/lua/unit/test_binary_core_unit.lua`, `tests/lua/stress/test_binary_stress.lua`, `tests/lua/integration/test_binary_filesystem.lua`, `tests/lua/integration/test_binary_compute.lua`, `tests/lua/golden/test_binary_golden.lua`.

**Co zrobiÄ‡ w examples** (`content/examples/`):
1. `grep -r "lurek\.data" content/` â€” znaleĹşÄ‡ wszystkie przykĹ‚ady.
2. PodmieniÄ‡ namespace.

**Gate**: `cargo clippy -- -D warnings` czyste. `cargo test` zielone. `grep -r "lurek\.data" src/ tests/ content/` zwraca 0 wynikĂłw (poza `dataframe`).

**PrzykĹ‚adowa zmiana API** (przed / po):
```lua
-- PRZED
local bd = lurek.data.newByteData(1024)
local hash = lurek.data.hash(data, "sha256")

-- PO
local bd = lurek.binary.newByteData(1024)
local hash = lurek.binary.hash(data, "sha256")
```

---

## BLOK C â€” Naprawa namespace `lurek.input`

### P1-C1 â€” NaprawiÄ‡ primary namespace `input.md` z `lurek.input.keyboard` na `lurek.input`

**Priorytet**: Critical
**Owner**: Doc-Writer + Developer (weryfikacja)
**ZaleĹĽnoĹ›ci**: brak

**Problem**: `docs/specs/input.md` deklaruje `Primary Lua namespace: lurek.input.keyboard` zamiast `lurek.input`. Sugeruje ĹĽe tylko klawiatura istnieje lub ĹĽe root namespace jest nieodpowiedni.

**Co zrobiÄ‡**:
1. SprawdziÄ‡ `src/lua_api/input_api.rs` â€” jakie sub-namespaces sÄ… naprawdÄ™ zarejestrowane (`keyboard`, `mouse`, `gamepad`?).
2. JeĹ›li `lurek.input.keyboard`, `lurek.input.mouse`, `lurek.input.gamepad` sÄ… osobnymi tabelami â€” dokumentowaÄ‡ to w `input.md` z sekcjÄ… per sub-namespace.
3. ZmieniÄ‡ `Primary Lua namespace: lurek.input.keyboard` na `Primary Lua namespace: lurek.input` i dodaÄ‡ listÄ™ sub-namespaces.
4. JeĹ›li caĹ‚y input jest pod `lurek.input.keyboard` â€” rozwaĹĽyÄ‡ refactor rejestracji na `lurek.input` (Developer task).

**Gate**: `input.md` ma `Primary Lua namespace: lurek.input`. Specyfikacja wymienia wszystkie dostÄ™pne sub-namespaces.

---

## BLOK D â€” Naprawa duplikatĂłw

### P1-D1 â€” ZredukowaÄ‡ overlap `lurek.event.Signal` vs `lurek.patterns.EventBus`

**Priorytet**: High
**Owner**: Lua-Designer + Doc-Writer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: `lurek.event.LSignal` (pub-sub z wildcard) i `lurek.patterns.EventBus` (named event bus z wildcard, priority, one-shot) sÄ… konceptualnie tym samym. Programista nie wie ktĂłrego uĹĽyÄ‡.

**Diagnoza**:
- `LSignal` (event module) â€” lightweight, Rust-backed, single signal
- `EventBus` (patterns module) â€” multi-channel, priority ordering, Lua-level

**Decyzja architektoniczna** (do wpisania w spec):
- `lurek.event.Signal` = **niskopoziomowy** single-signal dispatcher; uĹĽywaj gdy jeden konkretny event type (np. `on_player_death`)
- `lurek.patterns.EventBus` = **wielokanaĹ‚owy** pub-sub broker; uĹĽywaj gdy wiele typĂłw eventĂłw przez jednÄ… szynÄ™

**Co zrobiÄ‡ w `docs/specs/event.md`**:
1. DodaÄ‡ sekcjÄ™ `## Boundaries` z wyjaĹ›nieniem kiedy Signal vs EventBus.
2. DodaÄ‡ cross-reference do `patterns.md`.

**Co zrobiÄ‡ w `docs/specs/patterns.md`**:
1. DodaÄ‡ sekcjÄ™ `## Boundaries` z odniesieniem do `event.Signal`.

**Co zrobiÄ‡ w `content/examples/`**:
1. StworzyÄ‡ `content/examples/event/signal_vs_eventbus.lua` â€” example pokazujÄ…cy rĂłĹĽnicÄ™.

```lua
-- content/examples/event/signal_vs_eventbus.lua
-- KIEDY Signal: jeden konkretny event z prostymi callbackami
local onDeath = lurek.event.newSignal()
onDeath:connect("player_death", function(victim) print("killed:", victim) end)
onDeath:emit("player_death", "Player1")

-- KIEDY EventBus: wiele kanaĹ‚Ăłw przez jednÄ… szynÄ™ z priorityzacjÄ…
local bus = lurek.patterns.newEventBus()
bus:subscribe("combat.*", function(e, data) ... end, { priority = 10 })
bus:subscribe("ui.*", function(e, data) ... end)
bus:publish("combat.hit", { damage = 50 })
```

**Gate**: Oba spec pliki majÄ… sekcjÄ™ `## Boundaries`. Example plik istnieje. Ĺ»adna zmiana Rust nie jest potrzebna.

---

### P1-D2 â€” ZredukowaÄ‡ overlap `lurek.validator` vs `lurek.serial.validate`

**Priorytet**: High
**Owner**: Developer + Lua-Designer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: `lurek.validator` i `lurek.serial.validate` oba robiÄ… schema validation. Duplikacja kodu i confusion dla uĹĽytkownika.

**Co zrobiÄ‡**:
1. SprawdziÄ‡ `src/lua_api/validator_api.rs` i `src/serialize/schema.rs` â€” czy kod jest zduplikowany czy jeden wola drugi.
2. JeĹ›li zduplikowany: refactor `src/serialize/schema.rs` aby byĹ‚ publiczny i uĹĽywany przez `validator` module jako backend.
3. ZaktualizowaÄ‡ `docs/specs/validator.md` i `docs/specs/serialize.md` z dokumentacjÄ… relacji.
4. DodaÄ‡ example: `content/examples/data/validate_config.lua`.

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

**Gate**: Jeden z moduĹ‚Ăłw uĹĽywa kodu drugiego jako backend (bez duplikacji). Oba majÄ… cross-reference w spec. Example istnieje.

---

### P1-D3 â€” UdokumentowaÄ‡ relacjÄ™ `lurek.patterns.BehaviorTree` vs `lurek.ai.behavior_tree`

**Priorytet**: High
**Owner**: Doc-Writer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: `lurek.patterns` zawiera `BehaviorTree` (strukturalne nodes i builder). `lurek.ai` zawiera BT executor z Lua callbacks. UĹĽytkownik nie wie czego uĹĽyÄ‡.

**Co zrobiÄ‡**:
1. SprawdziÄ‡ `src/ai/behavior_tree.rs` â€” czy importuje z `src/patterns/behavior_tree.rs`.
2. DokumentowaÄ‡ podziaĹ‚ w obu specs:
   - `patterns.BehaviorTree` = **data structure** â€” nodes, builder, tree shape
   - `ai.BehaviorTree` = **runtime executor** â€” tick, Lua callbacks, running state
3. DodaÄ‡ diagram ASCII w `docs/specs/ai.md` sekcja `## Dependencies`.

**Co zrobiÄ‡ w `docs/specs/patterns.md`**:
```markdown
## Boundaries
`lurek.patterns.newBehaviorTree` buduje strukturÄ™ drzewa (nodes, edges).
Dla AI execution z Lua callbackami uĹĽyj `lurek.ai` â€” ktĂłre importuje patterns jako backend.
```

**Gate**: Oba spec majÄ… sekcjÄ™ Boundaries. Ĺ»adna zmiana Rust nie jest potrzebna.

---

### P1-D4 â€” Naprawa `lurek.event.exit` vs `lurek.event.quit` API

**Priorytet**: High
**Owner**: Developer + Lua-Designer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: `lurek.event.exit` (z optional exit code) i `lurek.event.quit` (hardcoded 0) robiÄ… to samo z rĂłĹĽnym interfejsem.

**Co zrobiÄ‡**:
1. SprawdziÄ‡ `src/lua_api/event_api.rs` â€” jak sÄ… zarejestrowane.
2. Opcja A (bezpieczna): Deprecated `quit`, zmieniÄ‡ implementation `quit` na call `exit(0)`. DodaÄ‡ `--- @deprecated` w docstring.
3. Opcja B (breaking): UsunÄ…Ä‡ `quit`, zostawiÄ‡ tylko `exit(code?)`.
4. Rekomendacja: Opcja A â€” backward compat.

**Co dodaÄ‡ w `src/lua_api/event_api.rs`**:
```rust
// lurek.event.quit â€” deprecated, use exit(0)
// Docstring: "Deprecated: use lurek.event.exit(0) instead."
```

**Co zrobiÄ‡ w testach** â€” dodaÄ‡ test ĹĽe `quit()` jest rĂłwnowaĹĽne `exit(0)`:
```lua
-- tests/lua/unit/test_event.lua (nowy test case)
-- test_quit_is_exit_zero
-- Sprawdza ĹĽe quit() nie crashuje i jest aliasem exit(0)
```

**Gate**: `lurek.event.quit` ma `@deprecated` docstring wskazujÄ…cy na `exit`. Nowy test case istnieje w `test_event.lua`.

---

## BLOK E â€” Naprawa `physics.CellularWorld` w zĹ‚ym module

### P1-E1 â€” PrzenieĹ›Ä‡ `CellularWorld` z `physics` do `procgen`

**Priorytet**: High
**Owner**: Developer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: `lurek.physics.CellularWorld` (cellular automata â€” Conway's Game of Life style) nie jest fizykÄ…. Powinno byÄ‡ w `lurek.procgen` (procedural generation).

**Co zrobiÄ‡ w Rust**:
1. SprawdziÄ‡ `src/physics/` â€” gdzie jest `CellularWorld` struct.
2. PrzenieĹ›Ä‡ plik `cellular_world.rs` (lub analogiczny) do `src/procgen/cellular_world.rs`.
3. ZaktualizowaÄ‡ `src/physics/mod.rs` â€” usunÄ…Ä‡ `pub mod cellular_world`.
4. ZaktualizowaÄ‡ `src/procgen/mod.rs` â€” dodaÄ‡ `pub mod cellular_world`.
5. ZaktualizowaÄ‡ `src/lua_api/physics_api.rs` â€” usunÄ…Ä‡ binding `CellularWorld`.
6. ZaktualizowaÄ‡ `src/lua_api/procgen_api.rs` â€” dodaÄ‡ binding `CellularWorld`.
7. Nowy namespace: `lurek.procgen.newCellularWorld(...)`.

**Co zrobiÄ‡ w testach**:
1. PrzenieĹ›Ä‡ testy cellular world do `tests/lua/unit/test_procgen_cellular.lua` (nowy plik).
2. ZaktualizowaÄ‡ istniejÄ…ce testy w `tests/lua/unit/test_physics.lua` jeĹ›li testujÄ… `CellularWorld`.

**Co zrobiÄ‡ w dokumentacji**:
1. ZaktualizowaÄ‡ `docs/specs/physics.md` â€” usunÄ…Ä‡ `CellularWorld` z Types i Functions.
2. ZaktualizowaÄ‡ `docs/specs/procgen.md` â€” dodaÄ‡ `CellularWorld` do Types i Functions.
3. RegenerowaÄ‡ API z `python tools/gen_all_docs.py`.

**Gate**: `cargo test` czyste. `grep "CellularWorld" src/physics/` = 0 wynikĂłw. `grep "CellularWorld" src/procgen/` > 0 wynikĂłw. `lurek.procgen.newCellularWorld` dziaĹ‚a w Lua.

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

## BLOK F â€” Naprawa `procgen` tier

### P1-F1 â€” ZmieniÄ‡ tier `procgen` z Foundations na Feature Systems

**Priorytet**: Medium
**Owner**: Doc-Writer (tylko spec zmiana)
**ZaleĹĽnoĹ›ci**: P1-E1 (cellular world move)

**Problem**: `procgen` jest w Foundations tier ale korzysta z `math`, `tilemap`, `render`. ZaleĹĽnoĹ›ci cross-tier sÄ… dozwolone (Foundations â†’ wyĹĽej) ale tutaj jest odwrotnie â€” Foundations dependuje od Feature Systems (`tilemap`).

**Co zrobiÄ‡ w `docs/specs/procgen.md`**:
1. ZmieniÄ‡ `Module group: Foundations` na `Module group: Feature Systems`.
2. ZaktualizowaÄ‡ `docs/specs/README.md` â€” przenieĹ›Ä‡ `procgen` z sekcji Foundations do Feature Systems.
3. SprawdziÄ‡ `docs/architecture/philosophy.md` â€” czy diagram tier zaleĹĽy od tej klasyfikacji.

**Gate**: `procgen.md` ma `Module group: Feature Systems`. `README.md` zawiera `procgen` w sekcji Feature Systems.

---

## BLOK G â€” Naprawa `serialize` namespace niespĂłjnoĹ›ci

### P1-G1 â€” Synchronizacja nazwy: `serialize.md` / `src/serialize/` / `lurek.serial`

**Priorytet**: Medium
**Owner**: Developer + Doc-Writer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: Trzy rĂłĹĽne nazwy dla jednego moduĹ‚u: spec = `serialize.md`, src = `src/serialize/`, namespace = `lurek.serial`. NiespĂłjnoĹ›Ä‡.

**Decyzja**: ZmieniÄ‡ namespace z `lurek.serial` na `lurek.serialize` dla spĂłjnoĹ›ci (breaking change, ale lepiej teraz niĹĽ pĂłĹşniej).

**Alternatywa (mniej breaking)**: ZmieniÄ‡ tylko spec i src folder na `serial`, pozostawiÄ‡ namespace. Brak wartoĹ›ci.

**Co zrobiÄ‡** (opcja recommended â€” align wszystko na `serialize`):
1. `src/lua_api/serialize_api.rs` â€” zmieniÄ‡ rejestracjÄ™ namespace z `"serial"` na `"serialize"`.
2. `grep -r "lurek\.serial" tests/ content/ docs/` â€” znaleĹşÄ‡ wszystkie uĹĽycia.
3. PodmieniÄ‡ `lurek.serial` na `lurek.serialize` wszÄ™dzie.
4. SprawdziÄ‡ czy `lurek.data.parseToml` / `lurek.data.encodeToml` (z binary.md!) powinny byÄ‡ przeniesione do `lurek.serialize` â€” to dodatkowy overlap do rozwiÄ…zania.

**Test unit** (aktualizacja istniejÄ…cych):
```lua
-- tests/lua/unit/test_serialize.lua (jeĹ›li istnieje, aktualizuj)
local data = {name = "test", value = 42}
local json = lurek.serialize.toJson(data)
assert(type(json) == "string")
local back = lurek.serialize.fromJson(json)
assert(back.name == "test")
```

**Gate**: `grep -r "lurek\.serial[^i]" tests/ content/ src/lua_api/` = 0 wynikĂłw. `lurek.serialize.toJson` dziaĹ‚a.

---

## BLOK H â€” Naprawa rendering overlap (`DepthSorter` w zĹ‚ym module)

### P1-H1 â€” PrzenieĹ›Ä‡ `DepthSorter` Lua API z `scene` do `render`

**Priorytet**: Medium
**Owner**: Developer + Lua-Designer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: `lurek.scene.newDepthSorter()` i `LDepthSorter` sÄ… zakotwiczone w `scene` module, ale depth sorting jest generalnym rendering concern uĹĽywanym poza kontekstem scene management.

**Co zrobiÄ‡**:
1. DodaÄ‡ `lurek.render.newDepthSorter()` jako alias lub przeniesienie z `scene`.
2. ZachowaÄ‡ `lurek.scene.newDepthSorter()` jako deprecated alias wskazujÄ…cy na `lurek.render.newDepthSorter()`.
3. ZaktualizowaÄ‡ `docs/specs/render.md` â€” dodaÄ‡ `LDepthSorter`.
4. ZaktualizowaÄ‡ `docs/specs/scene.md` â€” dodaÄ‡ deprecation note.

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

**Gate**: `lurek.render.newDepthSorter()` dziaĹ‚a. `lurek.scene.newDepthSorter()` dziaĹ‚a z deprecation log. Nowy test zielony.

---

## BLOK I â€” Naprawa `input` â€” brakujÄ…ce convenience API

### P1-I1 â€” DodaÄ‡ `lurek.input.actions` â€” action mapping system

**Priorytet**: High
**Owner**: Developer + Lua-Designer
**ZaleĹĽnoĹ›ci**: P1-C1

**Problem**: Brak action mapping system (Godot `InputMap` style). Hardkodowane klawisze sÄ… zĹ‚Ä… praktykÄ…. Kluczowe dla moddability.

**Co zrobiÄ‡ w Rust** (nowy plik `src/input/actions.rs`):
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

**Gate**: `cargo test` czyste. Nowe Lua testy zielone. `docs/specs/input.md` ma sekcjÄ™ `## Actions System`. `python tools/gen_all_docs.py` regeneruje docs bez bĹ‚Ä™dĂłw.

---

## BLOK J â€” Naprawa `network` â€” AI-friendly convenience API

### P1-J1 â€” DodaÄ‡ `lurek.network.httpJson(url, body, headers)` convenience function

**Priorytet**: High
**Owner**: Developer + Lua-Designer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: HTTP/WebSocket juĹĽ istnieje ale jest ukryte za `newRuntime()` boilerplate. Dla AI-first use case (call OpenAI API) potrzebny shortcut.

**Co zrobiÄ‡ w Rust** (`src/lua_api/network_api.rs`):
DodaÄ‡ statyczne convenience functions ktĂłre internalizujÄ… `NetworkRuntime` lifecycle:

```rust
// lurek.network.httpGet(url, options?) -> {status, body, headers} or error
// lurek.network.httpPost(url, body, options?) -> {status, body, headers}
// lurek.network.httpJson(url, body, options?) -> parsed Lua table (auto-decode JSON response)
// Wszystkie synchroniczne (blocking, w tle NetworkRuntime) z timeout
```

**Nowe Lua API**:
```lua
-- KrĂłtki helper â€” bez zarzÄ…dzania runtime
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
-- PrzykĹ‚ad integracji z Ollama (local LLM)
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

**Gate**: Nowe funkcje istniejÄ… w `lurek.network`. Tests zielone (z `@requires network` skip dla CI). Example plik istnieje. Docs zaktualizowane.

---

## BLOK K â€” Naprawa `physics` â€” brakujÄ…ce joints

### P1-K1 â€” DodaÄ‡ `lurek.physics.joint` API (Rapier2D joints)

**Priorytet**: Medium
**Owner**: Developer + Lua-Designer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: Rapier2D wspiera joints (spring, distance, revolute, prismatic). Brak eksponowania przez `lurek.physics`.

**Co zrobiÄ‡ w Rust** (`src/physics/` + `src/lua_api/physics_api.rs`):
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

**Gate**: `cargo test` czyste. Joint Lua tests zielone. `docs/specs/physics.md` zaktualizowane z joints sekcjÄ….

---

## BLOK L â€” Naprawa `camera` â€” brakujÄ…ce helpers

### P1-L1 â€” DodaÄ‡ `lurek.camera.shake`, `follow`, `worldToScreen`

**Priorytet**: Medium
**Owner**: Developer + Lua-Designer
**ZaleĹĽnoĹ›ci**: brak

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

**Gate**: Nowe metody istniejÄ…. Tests zielone. `docs/specs/camera.md` zaktualizowane.

---

## BLOK M â€” Naprawa `learning` â€” unified inference interface

### P1-M1 â€” DodaÄ‡ `lurek.learning.Model` common interface

**Priorytet**: High
**Owner**: Lua-Designer + Developer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: `NeuralNet`, `QLearner`, `GeneticAlgorithm`, `Neuroevolution`, `Bandit` â€” kaĹĽdy ma inne metody do inference. Brak unified `model:predict(input)` interface.

**Co zrobiÄ‡**:
1. SprawdziÄ‡ obecne API kaĹĽdego typu w `docs/specs/learning.md`.
2. DodaÄ‡ unified `:predict(input)` method jako alias:
   - `NeuralNet:predict(inputs)` â†’ alias `forward(inputs)`
   - `QLearner:predict(state)` â†’ alias `selectAction(state)`
   - `Bandit:predict()` â†’ alias `pull()`
3. DodaÄ‡ `lurek.learning.wrap(model)` â€” wraps any model in a common `LModel` interface.

**Nowe Lua API**:
```lua
-- KaĹĽdy model ma :predict()
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

**Gate**: `:predict()` dziaĹ‚a na wszystkich model types. `lurek.learning.wrap()` istnieje. Tests zielone.

---

## BLOK N â€” Dokumentacja boundaries UI trio

### P1-N1 â€” ZdefiniowaÄ‡ hierarchiÄ™ `lurek.ui` / `lurek.html` / `lurek.layout`

**Priorytet**: High
**Owner**: Doc-Writer + Architect (design decision)
**ZaleĹĽnoĹ›ci**: brak

**Problem**: Trzy moduĹ‚y UI bez dokumentacji ktĂłry jest primary i jak sÄ… poĹ‚Ä…czone.

**Decyzja do wpisania w specyfikacjach**:
- `lurek.layout` = **TOML layout engine** â€” definiuje hierarchiÄ™ elementĂłw UI w danych (`.toml` files). Jest backend/data layer.
- `lurek.html` = **HTML/CSS renderer** â€” renderuje strony HTML. Primary dla AI-generated UI (AI pisze HTML). ZaleĹĽy od `lurek.layout` jako fallback i `lurek.render` jako backend.
- `lurek.ui` = **2D Game UI widgets** â€” immediate-mode style game-specific widgets (health bars, inventory slots, dialog boxes). Dla game-specific UI gdy HTML jest za ciÄ™ĹĽki.

**Hierarchia zaleĹĽnoĹ›ci**:
```
lurek.render (GPU backend)
    â†‘
lurek.layout (TOML data) â†’ lurek.html (HTML renderer)
                               â†‘
                           lurek.ui (game widgets, uses html or direct render)
```

**Co zrobiÄ‡ w docs**:
1. DodaÄ‡ sekcjÄ™ `## UI Architecture` do kaĹĽdego z trzech spec plikĂłw.
2. StworzyÄ‡ `docs/architecture/ui-hierarchy.md` z peĹ‚nym diagramem.
3. StworzyÄ‡ przykĹ‚ady dla kaĹĽdego:

```lua
-- content/examples/ui/layout_toml.lua â€” when to use layout
-- content/examples/ui/html_generated.lua â€” AI generates HTML UI
-- content/examples/ui/ui_widgets.lua â€” game-specific widgets
```

**Gate**: KaĹĽdy z trzech spec plikĂłw ma sekcjÄ™ `## UI Architecture` z opisem roli i cross-references. `docs/architecture/ui-hierarchy.md` istnieje.

---

## BLOK O â€” Naprawa `visibility` tier assignment

### P1-O1 â€” PrzenieĹ›Ä‡ `visibility.md` z Edge do Feature Systems

**Priorytet**: Medium
**Owner**: Doc-Writer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: `lurek.visibility` (fog of war, line of sight) jest w Edge/Integration tier ale to core game feature uĹĽywana z `lurek.ai`, `lurek.pathfind` i `lurek.tilemap`.

**Co zrobiÄ‡**:
1. ZmieniÄ‡ `Module group: Edge/Integration` na `Module group: Feature Systems` w `docs/specs/visibility.md`.
2. ZaktualizowaÄ‡ `docs/specs/README.md` â€” przenieĹ›Ä‡ `visibility` do Feature Systems sekcji.
3. DodaÄ‡ cross-references do `ai.md`, `pathfind.md`, `tilemap.md` (wspĂłlny use case: fog of war z AI agents).

**Gate**: `visibility.md` ma `Module group: Feature Systems`. `README.md` zawiera `visibility` w Feature Systems.

---

## BLOK P â€” Naprawa `cursor.md` tier

### P1-P1 â€” PrzenieĹ›Ä‡ `cursor.md` z Edge do Platform Services

**Priorytet**: Low
**Owner**: Doc-Writer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: `lurek.cursor` (mouse cursor management) jest w Edge/Integration. Logicznie naleĹĽy do Platform Services obok `lurek.window` i `lurek.input`.

**Co zrobiÄ‡**:
1. ZmieniÄ‡ `Module group: Edge/Integration` na `Module group: Platform Services` w `docs/specs/cursor.md`.
2. ZaktualizowaÄ‡ `docs/specs/README.md`.
3. DodaÄ‡ cross-reference z `docs/specs/window.md` i `docs/specs/input.md`.

**Gate**: `cursor.md` ma `Module group: Platform Services`.

---

## BLOK Q â€” Naprawa `grep.md` â€” scalenie z `filesystem`

### P1-Q1 â€” ScaliÄ‡ `lurek.grep` funkcjonalnoĹ›Ä‡ z `lurek.filesystem`

**Priorytet**: Medium
**Owner**: Developer + Doc-Writer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: `lurek.grep` (pattern search in files) jest osobnym moduĹ‚em Edge tier podczas gdy logicznie naleĹĽy do `lurek.filesystem`.

**Co zrobiÄ‡**:
1. SprawdziÄ‡ `src/lua_api/grep_api.rs` â€” jakie funkcje sÄ… eksponowane.
2. DodaÄ‡ te funkcje do `src/lua_api/filesystem_api.rs` jako `lurek.filesystem.grep(path, pattern, options?)`.
3. ZachowaÄ‡ `lurek.grep` jako deprecated namespace z aliasami.
4. ZaktualizowaÄ‡ `docs/specs/filesystem.md` â€” dodaÄ‡ grep funkcje.
5. DodaÄ‡ deprecation note do `docs/specs/grep.md`.

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

**Gate**: `lurek.filesystem.grep()` dziaĹ‚a. `lurek.grep` nadal dziaĹ‚a z deprecation warning. Tests zaktualizowane.

---

## BLOK R â€” Naprawa `log` â€” structured logging

### P1-R1 â€” DodaÄ‡ structured logging do `lurek.log`

**Priorytet**: Medium
**Owner**: Developer + Lua-Designer
**ZaleĹĽnoĹ›ci**: brak

**Problem**: Brak machine-readable log output. Dla AI-first: agent logi powinny byÄ‡ parsowalne przez inne systemy.

**Nowe Lua API**:
```lua
-- Structured log z polami klucz-wartoĹ›Ä‡ (emituje JSON line do log output)
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

**Gate**: `lurek.log.info(event, fields)` dziaĹ‚a. Span API dziaĹ‚a. `docs/specs/log.md` zaktualizowane.

---

## BLOK S â€” Naprawa `ecs` â€” snapshot API

### P1-S1 â€” DodaÄ‡ `lurek.ecs.snapshot()` / `lurek.ecs.restore()`

**Priorytet**: Medium
**Owner**: Developer + Lua-Designer
**ZaleĹĽnoĹ›ci**: brak

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

**Gate**: `world:snapshot()` i `world:restore()` dziaĹ‚ajÄ…. Tests zielone.

---

## BLOK T â€” Naprawa `math` â€” module-level helpers

### P1-T1 â€” DodaÄ‡ `lurek.math.lerp`, `clamp`, `smoothstep` jako top-level

**Priorytet**: Low
**Owner**: Lua-Designer (tylko API binding, logika juĹĽ istnieje)
**ZaleĹĽnoĹ›ci**: brak

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

### Mapa zaleĹĽnoĹ›ci i kolejnoĹ›Ä‡

```
BLOK A (deduplikacja docs) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
BLOK B (rename lurek.data)  â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK C (fix input namespace) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤â†’ BLOK I (input.actions, zaleĹĽy od C1)
BLOK D (duplikaty: Signal/EventBus) â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK E (CellularWorld â†’ procgen) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤â†’ BLOK F (procgen tier, zaleĹĽy od E1)
BLOK G (serialize namespace) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK H (DepthSorter â†’ render) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK J (network httpJson) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK K (physics joints) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK L (camera helpers) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK M (learning inference) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK N (UI trio docs) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK O (visibility tier) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK P (cursor tier) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK Q (grep â†’ filesystem) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK R (structured log) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK S (ecs snapshot) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
BLOK T (math helpers) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
```

### Tabela wszystkich zadaĹ„

| ID | Blok | Priorytet | Owner | Rust? | Lua Tests? | ZaleĹĽnoĹ›ci |
|---|---|---|---|---|---|---|
| P1-A1 | A | Critical | Doc-Writer | Nie | Nie | â€” |
| P1-A2 | A | Critical | Doc-Writer | Nie | Nie | â€” |
| P1-A3 | A | Critical | Doc-Writer + Dev | Nie | Nie | â€” |
| P1-B1 | B | Critical | Developer | Tak | Tak | â€” |
| P1-C1 | C | Critical | Doc-Writer + Dev | Nie | Nie | â€” |
| P1-D1 | D | High | Lua-Designer | Nie | Tak | â€” |
| P1-D2 | D | High | Developer | Tak | Tak | â€” |
| P1-D3 | D | High | Doc-Writer | Nie | Nie | â€” |
| P1-D4 | D | High | Developer | Tak | Tak | â€” |
| P1-E1 | E | High | Developer | Tak | Tak | â€” |
| P1-F1 | F | Medium | Doc-Writer | Nie | Nie | P1-E1 |
| P1-G1 | G | Medium | Developer | Tak | Tak | â€” |
| P1-H1 | H | Medium | Developer | Tak | Tak | â€” |
| P1-I1 | I | High | Developer | Tak | Tak | P1-C1 |
| P1-J1 | J | High | Developer | Tak | Tak | â€” |
| P1-K1 | K | Medium | Developer | Tak | Tak | â€” |
| P1-L1 | L | Medium | Developer | Tak | Tak | â€” |
| P1-M1 | M | High | Lua-Designer + Dev | Tak | Tak | â€” |
| P1-N1 | N | High | Doc-Writer | Nie | Nie | â€” |
| P1-O1 | O | Medium | Doc-Writer | Nie | Nie | â€” |
| P1-P1 | P | Low | Doc-Writer | Nie | Nie | â€” |
| P1-Q1 | Q | Medium | Developer | Tak | Tak | â€” |
| P1-R1 | R | Medium | Developer | Tak | Tak | â€” |
| P1-S1 | S | Medium | Developer | Tak | Tak | â€” |
| P1-T1 | T | Low | Lua-Designer | Tak | Tak | â€” |

### Quality Gate per task
KaĹĽdy task przed zamkniÄ™ciem musi przejĹ›Ä‡:
1. `cargo test` â€” zero failures
2. `cargo clippy -- -D warnings` â€” zero warnings
3. `python tools/gen_all_docs.py` â€” bez bĹ‚Ä™dĂłw (jeĹ›li zmieniono API)
4. `python tools/validate/cag_validate.py` â€” (jeĹ›li zmieniono .agents/)
5. Nowe Lua testy w poprawnej lokalizacji (`tests/lua/unit/` lub `tests/lua/integration/`)
6. `docs/CHANGELOG.md` zaktualizowany

