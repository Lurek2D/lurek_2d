# Plan Implementacji: Refaktoryzacja Audio i DSP

## 1. Cel i Uzasadnienie
Analiza `src/lua_api/audio_api.rs` oraz `src/lua_api/dsp_api.rs` ujawnia rażące łamanie zasad projektowych – wielkie bloki logiczne zamknięte wewnątrz funkcji anonimowych (closures). Tworzy to silne spaghetii powiązań Lifetime, uniemożliwia reużycie logiki biznesowej oraz drastycznie pogarsza testowalność API na poziomie języka Rust.
Cel zmiany:
1. Wydzielenie closures do czystych, nazwanych funkcji (Named Helpers) – każda metoda zdefiniowana raz na górze/dole pliku.
2. Usunięcie `LuaAnyUserData` i wymuszenie poprawnego, ścisłego typowania (`borrow_mut::<SoundData>()`).
3. Oddzielenie struktury logiki parsowania DSP od kontekstu `Lua`.

## 2. Pliki do Edycji
- `src/lua_api/audio_api.rs`
- `src/lua_api/dsp_api.rs`
- `src/dsp/offline.rs` (dla uwolnienia struktury `OfflineEffect` z Lua)

## 3. Szczegółowe Zmiany (Kod Przed i Po)

### A. Ekstrakcja wielkiego parsera parametrów w `dsp_api.rs`
**Plik:** `src/lua_api/dsp_api.rs`

**KOD PRZED:**
```rust
// Gigantyczne, 60-linijkowe anonimowe closure!
tbl.set("processOffline", lua.create_function(move |_, (input, output, effects_tbl): (String, String, mlua::Table)| {
    // Sprawdzanie ścieżek
    if input.contains("..") { return Err(...); }
    // Pobieranie stanu i ścieżek
    let game_dir = s.borrow().game_dir.clone();
    let mut effects = Vec::new();
    // Parsowanie tablicy
    for pair in effects_tbl.sequence_values::<mlua::Table>() {
        let t = pair.map_err(LuaError::external)?;
        let typ_str: String = t.get("type").unwrap_or_default();
        let p1: f32 = t.get("p1").unwrap_or(1000.0);
        // ... switch-case match na każdy typ wewnątrz closure
        let typ = match typ_str.as_str() {
            "lowpass" => EffectType::Lowpass,
            // ... reszta ...
        };
        effects.push(crate::dsp::OfflineEffect { typ, p1, p2, p3 });
    }
    // Właściwe wywołanie
    crate::dsp::offline::process_offline(&input_path, &output_path, &effects).map_err(...)
})?)?;
```

**KOD PO:**
```rust
// REJESTRACJA API (Bardzo krótka i czysta):
let s_clone = state.clone();
tbl.set("processOffline", lua.create_function(move |lua, args| {
    dsp_api_helpers::process_offline_handler(lua, &s_clone, args)
})?)?;

// --- Gdzieś indziej, w module `dsp_api_helpers` ---:
pub fn parse_effect_table(t: &mlua::Table) -> LuaResult<crate::dsp::OfflineEffect> {
    let typ_str: String = t.get("type").unwrap_or_default();
    let p1: f32 = t.get("p1").unwrap_or(1000.0);
    let p2: f32 = t.get("p2").unwrap_or(1.0);
    let p3: f32 = t.get("p3").unwrap_or(0.5);
    
    let typ = match typ_str.as_str() {
        "lowpass" => EffectType::Lowpass,
        "reverb" => EffectType::Reverb,
        _ => return Err(LuaError::external(format!("unknown effect type: {}", typ_str))),
    };
    Ok(crate::dsp::OfflineEffect { typ, p1, p2, p3 })
}

pub fn process_offline_handler(_: &Lua, state: &Rc<RefCell<SharedState>>, args: (String, String, mlua::Table)) -> LuaResult<()> {
    let (input, output, effects_tbl) = args;
    if input.contains("..") || output.contains("..") {
        return Err(LuaError::external("path traversal not allowed"));
    }
    
    let game_dir = state.borrow().game_dir.clone();
    let input_path = game_dir.join(&input).to_string_lossy().into_owned();
    let output_path = game_dir.join(&output).to_string_lossy().into_owned();
    
    let mut effects = Vec::new();
    for pair in effects_tbl.sequence_values::<mlua::Table>() {
        let t = pair.map_err(LuaError::external)?;
        effects.push(parse_effect_table(&t)?);
    }
    
    crate::dsp::offline::process_offline(&input_path, &output_path, &effects).map_err(LuaError::external)
}
```

### B. Typowanie i Metody w `audio_api.rs`
Tak samo jak w DSP, usunięcie inline lambd w `audio_api.rs` dla np. `methods.add_method("setVolume", ...)` z wykorzystaniem funkcji nazwanych, co standaryzuje wywołania.

## 4. Przykłady Użycia (Lua)
Dla użytkownika końcowego API nie ulega zmianie, zyskuje on jednak na stabilności:

```lua
local source = lurek.audio.newSource("sfx.wav", "static")

-- Poprawne ścisłe typowanie obroni użytkownika przed takimi błędami:
local success, err = pcall(function()
    -- Wcześniej mogło spowodować Rust Panic, teraz rzuci ładny błąd MLua:
    lurek.dsp.applyLowpass(lurek.audio.newBus("master"), 500.0) 
end)

assert(string.find(err, "argument must be LSoundData"))
```

## 5. Testy

### Test Jednostkowy Rust (`tests/rust/unit/lua_api_tests.rs`)
Dzięki wyciągnięciu funkcji `parse_effect_table` oraz handlerów z closures do czystych funkcji Rustowych, możemy napisać czysty Unit Test **bez instancjowania maszyny wirtualnej w skomplikowanym środowisku gier**:

```rust
#[test]
fn test_dsp_effect_parser() {
    let lua = mlua::Lua::new();
    
    // Tworzymy tabelę z parametrami "na sucho"
    let table = lua.create_table().unwrap();
    table.set("type", "compressor").unwrap();
    table.set("p1", 0.7).unwrap();
    
    // Testujemy CZYSTĄ funkcję API
    let effect = crate::lua_api::dsp_api_helpers::parse_effect_table(&table).unwrap();
    
    assert_eq!(effect.typ, crate::dsp::EffectType::Compressor);
    assert_eq!(effect.p1, 0.7);
    assert_eq!(effect.p2, 1.0); // Wartość domyślna wyciągnięta poprawnie
}
```

### Test Integracyjny Lua (`tests/lua/test_audio_dsp_chain.lua`)
```lua
function test_dsp_offline_chain()
    -- Gwarancja, że zrefaktoryzowane podłączenia do metod działają poprawnie
    local effects = {
        { type = "reverb", p1 = 1000.0 },
        { type = "limiter", p1 = 0.9 }
    }
    
    local success, err = pcall(function()
        lurek.dsp.processOffline("content/examples/assets/vocals.wav", "content/examples/assets/out.wav", effects)
    end)
    
    assert(success, "DSP offline process failed after refactoring: " .. tostring(err))
end
```
