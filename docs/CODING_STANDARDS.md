# Lurek2D — Coding Standards

> **Cel dokumentu.** Jeden plik opisujący wszystkie standardy programowania w projekcie Lurek2D.
> Dokument jest przeznaczony do wczytania przez agenta AI (np. Gemini), który ma edytować kod Rust i Lua.
> Agenty powinny przestrzegać każdej reguły opisanej poniżej bez wyjątku.

---

## Spis treści

1. [Architektura i zasady ogólne](#1-architektura-i-zasady-ogólne)
2. [Rust — standardy kodu](#2-rust--standardy-kodu)
3. [Rust — standardy dokumentacji (Rustdoc)](#3-rust--standardy-dokumentacji-rustdoc)
4. [Lua API — cienka warstwa bindingów (`src/lua_api/`)](#4-lua-api--cienka-warstwa-bindingów-srclua_api)
5. [Docstringi w `*_api.rs` — format generatora dokumentacji](#5-docstringi-w-_apirs--format-generatora-dokumentacji)
6. [Lua — standardy skryptów](#6-lua--standardy-skryptów)
7. [Testy jednostkowe Lua (`tests/lua/unit/`)](#7-testy-jednostkowe-lua-testslualunit)
8. [Testy Rust (`tests/rust/unit/`)](#8-testy-rust-testsrustunit)
9. [Generowanie dokumentacji — pipeline](#9-generowanie-dokumentacji--pipeline)
10. [Synchronizacja artefaktów](#10-synchronizacja-artefaktów)
11. [Bramy jakości przed commitem](#11-bramy-jakości-przed-commitem)

---

## 1. Architektura i zasady ogólne

### 1.1 Stos technologiczny

| Warstwa       | Biblioteka                  | Wersja    |
|---------------|-----------------------------|-----------|
| Rust          | stable                      | ≥ 1.78    |
| Lua runtime   | LuaJIT (mlua)               | mlua 0.9  |
| Grafika       | wgpu                        | 22        |
| Okno          | winit                       | 0.30      |
| Fizyka        | rapier2d                    | 0.32      |
| Audio         | rodio                       | 0.17      |
| Czcionki      | fontdue                     | 0.9       |

**Nie aktualizuj żadnej z powyższych zależności bez wyraźnej zgody.** Każda aktualizacja wymaga korekty API wgpu/winit.

### 1.2 Grupy modułów (bez cykli)

```
Foundations → Core Runtime → Platform Services → Feature Systems → Edge/Integration
```

Cykl zależności między modułami jest **defektem krytycznym**, nie ostrzeżeniem. Kompozycja działa tylko w jedną stronę.

### 1.3 Ograniczenia projektowe (nie do złamania)

- **A-01** Runtime only. Brak wbudowanego edytora. Rozszerzenie VS Code jest opcjonalną warstwą DX, nie częścią binarki.
- **A-02** Tylko desktop. Brak mobile, brak WASM.
- **A-03** Tylko 2D. Brak pipeline 3D.
- **B-01** LuaJIT jest głównym runtime. `lua54` tylko w CI jako fallback.
- **B-02** wgpu 22 — jedyny backend renderowania.
- **B-03** Cel: 60 FPS przy 1080p na zintegrowanym GPU.
- **B-04** Rust threads do współbieżności. VMs LuaJIT nie współdzielą stanu.
- **B-05** TOML dla konfiguracji, JSON tylko dla zewnętrznego interop. Nigdy YAML.
- **C-01** Wyłącznie `lurek.*` w skryptach Lua. Żadnych gołych globals, żadnych tabel alternatywnych.

---

## 2. Rust — standardy kodu

### 2.1 Struktura pliku `mod.rs`

`mod.rs` w `src/` **może zawierać wyłącznie**:
- `pub mod <name>;`
- `pub use <path>;`
- Komentarze dokumentacyjne (`///` lub `//!`)
- Atrybuty `#[allow(...)]`

**Zabronione w `mod.rs`:** funkcje, struktury, implementacje, logika biznesowa, `#[cfg(test)]`.

```rust
// POPRAWNIE — src/audio/mod.rs
//! Audio subsystem: playback, mixing, spatial sound, MIDI routing.

pub mod decoder;
pub mod mixer;
pub mod sound_data;
pub mod source;

pub use mixer::Mixer;
pub use sound_data::SoundData;
pub use source::SourceType;
```

### 2.2 Separacja logiki biznesowej od bindingów

```
src/<module>/          ← logika biznesowa, typy, algorytmy
src/lua_api/<module>_api.rs  ← cienki wrapper: LuaUserData, rejestracja, konwersja typów
```

Jeśli w `*_api.rs` pojawia się blok `if/match/for` z logiką domenową — plik dryfuje. Logika musi wrócić do `src/<module>/`.

### 2.3 Brak `#[cfg(test)]` w `src/`

**Zabronione.** Każdy test kodu prywatnego z `src/` trafia do `tests/rust/unit/<module>_tests.rs` jako osobny target binarny.

### 2.4 Reguła bezpiecznego pożyczania `SharedState`

Nigdy nie trzymaj `borrow_mut()` lub `RefCell::borrow_mut()` przez wywołanie callbacku Lua. Wzorzec:

```rust
// POPRAWNIE
let value = {
    let guard = state.borrow();
    guard.field.clone()
}; // borrow zwolniony przed wywołaniem Lua
lua_callback(value)?;

// BŁĘDNIE — może spowodować runtime panic przy reentrance
let guard = state.borrow();
lua_callback(guard.field.clone())?; // guard wciąż żyje
```

### 2.5 Propagacja błędów przez granicę Lua

Używaj `?` do propagacji, ale **nigdy** nie pozwól, żeby przeszedł przez callback Lua bez komunikatu.

```rust
// POPRAWNIE
methods.add_method("load", |_, this, path: String| {
    this.inner.load(&path).map_err(|e| {
        LuaError::RuntimeError(format!("lurek.audio.load: {}", e))
    })
});

// BŁĘDNIE — surowy błąd bez kontekstu call-site
methods.add_method("load", |_, this, path: String| {
    Ok(this.inner.load(&path)?)
});
```

Komunikat błędu zawsze zaczyna się od `lurek.<module>.<function>:`.

### 2.6 Bloki `unsafe`

Każdy blok `unsafe` musi być:
- Jak najmniejszy — jeden cel
- Opatrzony komentarzem `// SAFETY:` wyjaśniającym niezmiennik

```rust
// POPRAWNIE
// SAFETY: ptr pochodzi z Box::into_raw i jeszcze nie był zwolniony
let val = unsafe { Box::from_raw(ptr) };

// BŁĘDNIE
unsafe { do_something_dangerous(); }
```

Nie używaj `unsafe` dla wygody, kiedy istnieje bezpieczna alternatywa.

### 2.7 Import modułów

**Preferuj explicit imports**, nie glob:

```rust
// POPRAWNIE
use crate::math::{clamp, lerp, Vec2};

// BŁĘDNIE
use crate::math::*;
```

### 2.8 Nazewnictwo

| Element          | Konwencja         | Przykład                    |
|------------------|-------------------|-----------------------------|
| Typ, Struct, Enum| `PascalCase`      | `SoundData`, `SourceType`   |
| Funkcja, metoda  | `snake_case`      | `load_from_file`            |
| Stała            | `UPPER_SNAKE_CASE`| `MAX_SOURCES`               |
| Moduł            | `snake_case`      | `audio_api`                 |
| Typ Lua-visible  | `LPascalCase`     | `LuaVec2`, `LuaSource`      |

Typy eksponowane do Lua mają prefix `Lua` w Rust (np. `LuaVec2`) i są widoczne przez Lua jako `LVec2` (przez `TYPE_NAME`).

### 2.9 Pinned wersje

Nie zmieniaj wersji w `Cargo.toml` bez zgody:

```toml
mlua = { version = "0.9", features = ["luajit", "vendored"] }
wgpu = "22"
winit = "0.30"
rapier2d = "0.32"
rodio = "0.17"
fontdue = "0.9"
```

---

## 3. Rust — standardy dokumentacji (Rustdoc)

Komentarze istnieją dla agentów AI czytających kod. **Maksymalny sygnał na token. Bez prozy, bez powtórzeń.**

### 3.1 Co wymaga `///`

Każda z poniższych linii musi mieć `///` bezpośrednio powyżej, bez wyjątku:

- `pub fn`, `pub async fn`
- `fn` (każda prywatna funkcja)
- `pub struct`, `struct`
- `pub enum`, `enum`
- `pub mod` (każde wystąpienie, w każdym pliku)
- `pub type`, `pub const`, `pub static`
- `impl Trait for Type` — jedna linia opisująca co trait dostarcza dla tego typu
- Każde pole wewnątrz struktury — pub i prywatne — jedna linia
- Każdy wariant enum — jedna linia

### 3.2 Nagłówek pliku (`//!`)

Format: bullet-pointy, każda linia zaczyna się od `//! - `.

Rozmiar proporcjonalny do rozmiaru pliku:
- Mały plik (<3000 znaków): ~300 znaków, 3–4 bullety
- Średni plik (3000–10000 znaków): ~600 znaków, 5–7 bulletów
- Duży plik (>10000 znaków): ~1200 znaków, 8–12 bulletów

Kolejność bulletów:
1. Co plik dostarcza (grupy możliwości)
2. Jak powiązane funkcje/typy działają i jakie algorytmy stosują
3. Decyzje projektowe: reprezentacje danych, zachowania fallback, obsługa przypadków zdegenerowanych
4. Notatki integracyjne: kto używa (runtime, testy, bindingi Lua, narzędzia)

**Nie wymieniaj nazw indywidualnych funkcji, struktur ani metod.** Opisuj możliwości i zachowania.

```rust
// POPRAWNIE
//! - Provides standalone 2D geometry algorithms over scalar coordinates and flat vertex arrays.
//! - Basic helpers compute angle, circle containment, circle-circle overlap, and segment-circle intersections.
//! - Polygon helpers compute signed area, centroid with arithmetic-mean fallback, point-in-polygon by ray casting,
//!   and convex hull by Andrew monotone chain.
//! - Functions favor simple tuples and slices so they can be used from runtime, tests, and Lua bindings.
//! - Degenerate paths return conservative values (empty sets, arithmetic centroids, false intersections) instead of panicking.

// BŁĘDNIE
//! Contains the compute_angle(), check_circle(), convex_hull() functions.
```

### 3.3 Struktury i pola

```rust
/// Holds decoded audio sample data for playback or signal processing.
pub struct SoundData {
    /// Raw interleaved PCM samples in f32 format; length = frames × channels.
    pub samples: Vec<f32>,
    /// Sample rate in Hz; typically 44100 or 48000.
    pub sample_rate: u32,
    /// Channel count: 1 = mono, 2 = stereo.
    pub channels: u16,
}
```

### 3.4 Enumy i warianty

```rust
/// Playback mode for an audio source created through the Lua API.
pub enum SourceType {
    /// One-shot playback; source is released after the clip ends.
    Static,
    /// Loops continuously until explicitly stopped.
    Streaming,
    /// Queued buffers driven by external Lua-side logic.
    Queueable,
}
```

### 3.5 Impl bloki

```rust
/// Provides matrix decomposition and spatial query helpers for Transform.
impl Transform {
    /// Decomposes this transform into translation, rotation, and uniform scale.
    pub fn decompose(&self) -> (Vec2, f32, f32) { ... }
}
```

Czyste bloki `impl Type {}`: zachowaj istniejące `///`, dodaj kiedy blok grupuje wyraźnie odrębny zestaw metod. Nigdy nie usuwaj istniejącego `///`.

### 3.6 Funkcje i metody

**Jedna linia.** Opisuje co robi I co zwraca, włącznie z edge cases inline.

```rust
/// Decodes file and returns chunk decoder; returns error on open/decode failure.
pub fn from_file(path: &str) -> Result<Decoder, AudioError> { ... }

/// Returns signed area; negative when vertices are clockwise.
fn signed_area(vertices: &[Vec2]) -> f32 { ... }
```

Jeden kompaktowy przykład (jeśli konieczny), wbudowany w jedną linię — nie sekcja `# Examples`.

### 3.7 Zabronione frazy w Rustdoc

Nie używaj żadnego z poniższych:
- "returns a fully initialised instance"
- "the insertion is O(1) amortised"
- "this accessor incurs no allocation"
- "call it freely in hot paths"
- "alias for `foo()`" / "shorthand for" / "convenience wrapper"

Nie używaj sekcji `# Arguments`, `# Returns`, `# Errors` — zamiast tego one-liner z wszystkimi informacjami.

---

## 4. Lua API — cienka warstwa bindingów (`src/lua_api/`)

### 4.1 Zasada cienkiej warstwy (Thin Wrapper Rule)

`src/lua_api/*_api.rs` zawiera **wyłącznie**:
- Definicje struct `LuaXxx` (tylko wrappery handle/Arc)
- Implementacje `LuaUserData` — `add_fields`, `add_methods`, `add_meta_method`
- Funkcję `register(lua: &Lua, state: &SharedState) -> mlua::Result<()>`
- Konwersje typów na granicy Lua↔Rust
- Helper functions lokalnej walidacji (walidacja zakresu, parsowanie handle)

**Zabronione w `*_api.rs`:** logika biznesowa, algorytmy, operacje I/O, dostęp do bazy danych, kalkucje domenowe.

Jeśli plik `*_api.rs` przekracza ~20 linii dla jednej metody — logika dryfuje. Wyodrębnij do `src/<module>/`.

### 4.2 Struktura pliku `*_api.rs`

```rust
//! `lurek.<module>` — <one-line description of what this binding exposes>.

use super::SharedState;
use crate::<module>::{Type1, Type2};
use mlua::prelude::*;

// ── Helper functions (validation, type parsing) ───────────────────────────────

/// Parses a Lua value into an internal handle type.
fn parse_handle(val: &LuaValue) -> LuaResult<HandleType> { ... }

// ── LuaXxx wrapper types ──────────────────────────────────────────────────────

/// Lua-visible handle for <Type>.
pub struct LuaXxx {
    /// Internal handle key used to look up the resource in the engine store.
    pub key: XxxKey,
}

/// Provides Lua methods for <Type>.
impl LuaUserData for LuaXxx {
    fn add_fields<'lua, F: LuaUserDataFields<'lua, Self>>(fields: &mut F) {
        // fields...
    }

    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- methodName --
        /// One-line description.
        /// @param | paramName | LuaType | Description.
        /// @return | ReturnType | Description.
        methods.add_method("methodName", |_, this, param: ParamType| {
            // thin: validate + delegate to domain
        });
    }
}

// ── Module registration ───────────────────────────────────────────────────────

/// Registers the `lurek.<module>` table and all its functions into the Lua VM.
pub fn register(lua: &Lua, state: &SharedState) -> mlua::Result<()> {
    let module = lua.create_table()?;
    // ... add functions ...
    lua.globals().get::<_, mlua::Table>("lurek")?.set("<module>", module)?;
    Ok(())
}
```

### 4.3 Typy wrapperów Lua

Każdy typ eksponowany do Lua to struct z `pub struct LuaXxx` i `TYPE_NAME = "LXxx"`.

```rust
/// Lua-visible handle for an audio source.
pub struct LuaSource {
    /// Slotmap key identifying the source in the mixer store.
    pub key: SoundKey,
}

impl LuaUserData for LuaSource {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- type --
        /// Returns the Lua-visible type name for this source handle.
        /// @return | string | The string `LSource`.
        methods.add_method("type", |_, _, ()| Ok("LSource"));

        // -- typeOf --
        /// Returns whether this source handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LSource` and `Object`.
        /// @return | boolean | True when the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSource" || name == "LObject")
        });
    }
}
```

Każdy typ musi implementować metody `type()` i `typeOf()`.

### 4.4 Funkcja `register`

Każdy `*_api.rs` eksportuje dokładnie jedną funkcję `register`, wywoływaną z `src/lua_api/register.rs`.

```rust
/// Registers the `lurek.audio` table and all its functions into the Lua VM.
pub fn register(lua: &Lua, state: &SharedState) -> mlua::Result<()> {
    let audio = lua.create_table()?;
    let s = state.clone();

    // Free functions
    let s2 = s.clone();
    audio.set("setMasterVolume", lua.create_function(move |_, vol: f64| {
        // clamp at boundary, not deep in domain
        let clamped = vol.clamp(0.0, 1.0) as f32;
        s2.borrow_mut().mixer.set_master_volume(clamped);
        Ok(())
    })?)?;

    // UserData constructors
    audio.set("newSource", lua.create_function(move |lua, (path, kind): (String, String)| {
        let source_type = SourceType::from_str(&kind)
            .map_err(|_| LuaError::RuntimeError(
                format!("lurek.audio.newSource: unknown source type '{}'", kind)
            ))?;
        let key = s.borrow_mut().mixer.load(&path, source_type)?;
        lua.create_userdata(LuaSource { key })
    })?)?;

    lua.globals().get::<_, mlua::Table>("lurek")?.set("audio", audio)?;
    Ok(())
}
```

### 4.5 Konwersja typów na granicy

Checklist dla każdej funkcji granicznej:

1. **Zakresy integer**: przed castowaniem `i64 → u32` lub `usize`, sprawdź zakres
2. **Stringi enum-like**: waliduj zawartość stringa i zwróć błąd z listą dozwolonych wartości
3. **f32/f64**: zaciśnij do sensownego zakresu gry na granicy, nie głęboko w module

```rust
// POPRAWNIE — clamp na granicy
let vol = vol.clamp(0.0_f64, 1.0) as f32;

// POPRAWNIE — integer range check
if n < 0 || n > u32::MAX as i64 {
    return Err(LuaError::RuntimeError("lurek.module.fn: index out of range".into()));
}
let idx = n as u32;

// POPRAWNIE — string enum validation
let kind = match kind.as_str() {
    "static" => SourceType::Static,
    "streaming" => SourceType::Streaming,
    other => return Err(LuaError::RuntimeError(
        format!("lurek.audio.newSource: unknown type '{}'; expected 'static' or 'streaming'", other)
    )),
};
```

### 4.6 Obsługa handle (uchwytów)

Użytkownicy Lua mogą trzymać uchwyt po zwolnieniu zasobu. Zawsze waliduj:

```rust
/// Creates a consistent stale-handle runtime error for source methods.
fn invalid_source_handle(function_name: &str) -> LuaError {
    LuaError::RuntimeError(format!(
        "{}: invalid or already-released audio source handle",
        function_name
    ))
}
```

### 4.7 Callbacki Lua (registry pattern)

```rust
// POPRAWNIE — przechowaj callback w registry
let cb_key = lua.create_registry_value(callback)?;

// Nigdy nie pozwól, żeby pożyczony LuaFunction przeżył bieżący stack — zdangles
// gdy Lua state awansuje
```

### 4.8 `add_methods` — dozwolone wywołania

`add_methods` może wywoływać **wyłącznie**:
- `add_method`
- `add_method_mut`
- `add_function`
- `add_meta_method`

**Zabronione w `add_methods`:** efekty uboczne, lazy-init, zmiany globalnego stanu.

---

## 5. Docstringi w `*_api.rs` — format generatora dokumentacji

Generator (`tools/docs/gen_lua_api_data.py` + `gen_luadoc.py`) parsuje specjalny format komentarzy.

### 5.1 Format `@param` i `@return`

```rust
/// One-line description of what this method does.
/// @param | paramName | LuaType | Human description.
/// @return | LuaType | Human description.
```

Reguły:
- Spacje wokół `|` są wymagane
- Typ musi być jednym z dopuszczalnych (patrz niżej)
- `@param` i `@return` — **jedna para na linię**
- Opis parametru lub returna — po ostatnim `|`

### 5.2 Dozwolone typy w docstringach

| Typ Lua         | Kiedy używać                                              |
|-----------------|-----------------------------------------------------------|
| `string`        | Tekst UTF-8                                               |
| `number`        | f64 / f32 wartości zmiennoprzecinkowe                    |
| `integer`       | i64 / i32 / usize wartości całkowite                     |
| `boolean`       | true/false                                                |
| `table`         | Generyczna tabela Lua                                     |
| `string[]`      | Tablica stringów                                          |
| `number[]`      | Tablica liczb                                             |
| `integer[]`     | Tablica liczb całkowitych                                 |
| `LXxx`          | Konkretny typ userdata (np. `LVec2`, `LSource`, `LWorld`)|
| `any`           | Polimorficzne API akceptujące wiele rodzajów wartości     |

**Zabronione:**
- Surowe unie `A\|B\|C` w docstringach (`@return | string\|nil |` → użyj `string?`)
- `@return any` dla zwykłych funkcji (tylko gdy API naprawdę jest polimorficzne)
- Typy Rust w docstringach (`mlua::Table`, `LuaValue`, itp.)

Opcjonalność: dołącz `?` do typu: `string?`, `table?`, `LVec2?`

### 5.3 Pola UserData (`@field`)

```rust
/// Holds spatial query result data.
/// @field | bodyId | integer | Internal physics body identifier.
/// @field | x | number | Contact point x coordinate in world space.
/// @field | y | number | Contact point y coordinate in world space.
/// @field | normalX | number | Collision normal x component.
/// @field | normalY | number | Collision normal y component.
pub struct LuaRaycastHit { ... }
```

### 5.4 Nagłówek pliku `*_api.rs`

```rust
//! `lurek.<module>` — <one-line description matching docs/specs/<module>.md>.
```

Zawsze zaczyna się od nazwy modułu Lua (`lurek.<module>`).

### 5.5 Sekcje rozdzielające metody

Przed każdą metodą w `add_methods` dodaj separator:

```rust
// -- methodName --
/// One-line description.
/// @param | ...
/// @return | ...
methods.add_method("methodName", |_, this, param| { ... });
```

Separator `// -- methodName --` jest parsowany przez generator jako znacznik sekcji.

### 5.6 `type()` i `typeOf()` — obowiązkowe

Każdy typ LuaUserData musi implementować:

```rust
// -- type --
/// Returns the Lua-visible type name for this handle.
/// @return | string | The string `LXxx`.
methods.add_method("type", |_, _, ()| Ok("LXxx"));

// -- typeOf --
/// Returns whether this handle matches a supported type name.
/// @param | name | string | Type name to compare against `LXxx` and `Object`.
/// @return | boolean | True when the supplied name matches this handle.
methods.add_method("typeOf", |_, _, name: String| {
    Ok(name == "LXxx" || name == "LObject")
});
```

### 5.7 Nigdy nie edytuj `docs/api/lurek.lua`

Plik `docs/api/lurek.lua` jest **auto-generowany**. Wszelkie poprawki API wprowadza się w `src/lua_api/*_api.rs`, następnie regeneruje dokumentację.

```powershell
# Regeneruj po każdej zmianie *_api.rs
python tools/docs/gen_lua_api_data.py
python tools/docs/gen_luadoc.py
python tools/docs/gen_extension_api.py
```

---

## 6. Lua — standardy skryptów

### 6.1 Tylko `lurek.*`

**Absolutna reguła:** wszystkie wywołania API engine używają `lurek.*`. Żadnych gołych globals, żadnych tabel `engine.*`, żadnych alternatywnych namespace.

```lua
-- POPRAWNIE
local pos = lurek.math.vec2(10, 20)
lurek.render.setColor(1, 0, 0, 1)

-- BŁĘDNIE
local pos = math.vec2(10, 20)  -- math jest stdlib Lua
engine.setColor(1, 0, 0, 1)   -- nie istnieje
```

### 6.2 Lifecycle callbacks — separacja on_process / on_render

```lua
local state = { x = 0, y = 0 }

lurek.game.on_init = function()
    -- inicjalizacja stanu
    state.x = 100
end

lurek.game.on_process = function(dt)
    -- mutuj stan, używaj dt
    state.x = state.x + 100 * dt
    -- NIE wywołuj draw functions tutaj
end

lurek.game.on_render = function()
    -- rysuj ze stanu
    lurek.render.rect(state.x, state.y, 32, 32)
    -- NIE mutuj stanu gry tutaj
end
```

Mieszanie tych callbacków powoduje **niezdefiniowane zachowanie**.

### 6.3 Zawsze mnóż przez `dt`

Każdy ruch, fizyka, timer, tween — pomnóż przez `dt`:

```lua
-- POPRAWNIE
player.x = player.x + player.speed * dt

-- BŁĘDNIE — łamie się przy nie-60-FPS
player.x = player.x + 2
```

### 6.4 Zmienne lokalne i scope

Stan trzymaj w `local` zmiennych lub jawnych tabelach stanu. Nigdy w module-level upvalues, które przeżywają przejście sceny.

```lua
-- POPRAWNIE
local player = { x = 0, y = 0, speed = 100 }

-- BŁĘDNIE — upvalue w module scope przeżyje scene transition
player_x = 0  -- globalna
```

### 6.5 Ścieżki zasobów

Ścieżki muszą być **względne do content root** gry (folder z `conf.lua`). Używaj `/`, nigdy `..`.

```lua
-- POPRAWNIE
local img = lurek.image.newImage("assets/player.png")

-- BŁĘDNIE
local img = lurek.image.newImage("C:/games/myproject/assets/player.png")
local img = lurek.image.newImage("../shared/player.png")
```

### 6.6 Biblioteki

```lua
-- Użycie biblioteki z library/
local Inventory = lurek.require("library/inventory")
```

Biblioteki nie wywołują `lurek.game.on_*`. Dostarczają stan i logikę, którą skrypt gry łączy z callbackami.

### 6.7 `conf.lua`

Klucze konfiguracyjne muszą dokładnie odpowiadać polom `src/runtime/config.rs`. Nie zgaduj wartości domyślnych.

---

## 7. Testy jednostkowe Lua (`tests/lua/unit/`)

### 7.1 Nazewnictwo plików

```
test_<module>_<layer>.lua
```

Przykłady: `test_math_core_unit.lua`, `test_audio_core_unit.lua`, `test_physics_core_unit.lua`

Pliki, które nie pasują do wzorca, **nie są wykrywane** przez harness ani `parallel_cargo.py`.

### 7.2 Rejestracja w `tests/lua/harness.rs`

Każdy nowy plik testowy musi być zarejestrowany w `tests/lua/harness.rs` pod właściwą suitą:

```rust
// W harness.rs — dodaj do odpowiedniej listy
run_lua_file!(lua, "tests/lua/unit/test_<module>_core_unit.lua");
```

### 7.3 Funkcje harness (jedyne dozwolone asercje)

| Funkcja                                      | Kiedy używać                                       |
|----------------------------------------------|----------------------------------------------------|
| `expect_equal(expected, actual)`             | Porównanie wartości (nie-float)                    |
| `expect_near(expected, actual, epsilon)`     | Porównanie float                                   |
| `expect_true(value)`                         | Warunek boolowski                                  |
| `expect_false(value)`                        | Negacja boolowska                                  |
| `expect_type(type_string, value)`            | Sprawdzenie typu Lua                               |
| `expect_not_nil(value)`                      | Wartość nie jest nil                               |
| `expect_nil(value)`                          | Wartość jest nil                                   |
| `expect_no_error(fn)`                        | Funkcja nie rzuca błędu                            |
| `expect_error(fn)`                           | Funkcja rzuca błąd                                 |

**Zabronione:** nagie `assert()` — nie daje kontekstu przy niepowodzeniu.

### 7.4 Struktura pliku testowego

```lua
-- Lurek2D <Module> API Tests

-- @describe lurek.<module> module exists
describe("lurek.<module> module exists", function()
    -- @covers lurek.<module>
    it("<module> is a table", function()
        expect_type("table", lurek.<module>)
    end)
end)

-- @describe lurek.<module> <feature>
describe("lurek.<module> <feature>", function()
    -- @covers lurek.<module>.<function>
    it("<description of behavior>", function()
        -- arrange
        local input = ...

        -- act
        local result = lurek.<module>.<function>(input)

        -- assert
        expect_equal(expected, result)
    end)
end)

test_summary()  -- OBOWIĄZKOWE na końcu każdego pliku
```

### 7.5 Markery powyżej `it()`

Marker musi być bezpośrednio powyżej wywołania `it()`, z identycznym wcięciem:

```lua
-- @describe lurek.physics world
describe("lurek.physics world", function()
    -- @covers lurek.physics.newWorld
    it("newWorld creates a world", function()
        local world = lurek.physics.newWorld(0, 9.81)
        expect_type("userdata", world)
    end)

    -- @covers lurek.physics.newWorld
    -- @covers lurek.physics.step
    it("step advances the simulation", function()
        local world = lurek.physics.newWorld(0, 9.81)
        expect_no_error(function()
            lurek.physics.step(world, 1/60)
        end)
    end)
end)
```

**Reguły markerów `@covers`:**
- Marker musi oznaczać symbol, który jest **wywołany i asercjami pokryty** w danym `it()`
- Setup calls bez asercji walidujących kontrakt — **nie dodawaj do listy `@covers`**
- Wiele `-- @covers` nad jednym `it()` jest dozwolone (gdy test asercjami pokrywa kilka symboli)

### 7.6 Rodziny testów i ich markery

| Folder                       | Marker           | Cel                                              |
|------------------------------|------------------|--------------------------------------------------|
| `tests/lua/unit/`            | `@covers`        | Kontrakty `lurek.*` w izolacji                   |
| `tests/lua/integration/`     | `@integration`   | Zachowanie przez przynajmniej dwa podsystemy     |
| `tests/lua/security/`        | `@security`      | Odrzucanie wrogich inputów, bezpieczne awarie    |
| `tests/lua/stress/`          | `@stress`        | Przepustowość/stabilność pod dużym obciążeniem   |
| `tests/lua/evidence/`        | `@evidence`      | Artefakty potwierdzające twierdzenia o zachowaniu|
| `tests/lua/demos/`           | brak             | Testy demo headless, `test_<name>.lua`           |

Nie mieszaj markerów między rodzinami. Test w `unit/` nie może mieć markera `@integration`.

### 7.7 Porównanie float

Zawsze `expect_near`, nigdy `expect_equal` dla floatów:

```lua
-- POPRAWNIE
expect_near(3.14159, lurek.math.pi, 0.0001)

-- BŁĘDNIE — może sporadycznie failować przez precyzję
expect_equal(3.14159, lurek.math.pi)
```

### 7.8 Deterministyczność testów

- Stały seed dla `lurek.math.random` (gdy używany)
- Stałe `dt = 1/60` w testach headless
- Brak odczytu plików poza `tests/fixtures/`
- Brak wall-clock time
- Brak dostępu do okna

### 7.9 Granularność testów

Jeden test = jeden powód niepowodzenia.

```lua
-- POPRAWNIE
it("setMasterVolume clamps above 1.0", function()
    lurek.audio.setMasterVolume(2.0)
    expect_near(1.0, lurek.audio.getMasterVolume(), 0.01)
end)

it("setMasterVolume clamps below 0.0", function()
    lurek.audio.setMasterVolume(-0.5)
    expect_near(0.0, lurek.audio.getMasterVolume(), 0.01)
end)

-- BŁĘDNIE — jeden test, dwa powody awarii, niemożliwe attribution
it("volume clamping works", function()
    lurek.audio.setMasterVolume(2.0)
    expect_near(1.0, lurek.audio.getMasterVolume(), 0.01)
    lurek.audio.setMasterVolume(-0.5)
    expect_near(0.0, lurek.audio.getMasterVolume(), 0.01)
end)
```

### 7.10 Preferuj state-readback nad side-effect checks

```lua
-- MOCNIEJSZE — odczyt stanu
local x, y = lurek.physics.getBodyPosition(world, body)
expect_near(5.0, x, 0.01)

-- SŁABSZE — sprawdzenie side-effectu
expect_true(on_contact_called)
```

### 7.11 Przykładowy kompletny plik testowy

```lua
-- Lurek2D Audio API Tests

-- @describe lurek.audio module exists
describe("lurek.audio module exists", function()
    -- @covers lurek.audio
    it("lurek.audio is a table", function()
        expect_type("table", lurek.audio)
    end)
end)

-- @describe lurek.audio volume
describe("lurek.audio volume", function()
    -- @covers lurek.audio.setMasterVolume
    it("setMasterVolume accepts 0..1 range", function()
        expect_no_error(function()
            lurek.audio.setMasterVolume(0.5)
        end)
    end)

    -- @covers lurek.audio.getMasterVolume
    it("getMasterVolume returns a number", function()
        expect_type("number", lurek.audio.getMasterVolume())
    end)

    -- @covers lurek.audio.getMasterVolume
    -- @covers lurek.audio.setMasterVolume
    it("setMasterVolume/getMasterVolume roundtrip", function()
        lurek.audio.setMasterVolume(0.75)
        expect_near(0.75, lurek.audio.getMasterVolume(), 0.01)
        lurek.audio.setMasterVolume(1.0)  -- reset
    end)
end)

test_summary()
```

---

## 8. Testy Rust (`tests/rust/unit/`)

### 8.1 Umiejscowienie

Nigdy nie używaj `#[cfg(test)]` w `src/`. Testy prywatnego kodu Rust trafiają do:

```
tests/rust/unit/<module>_tests.rs
```

Uwaga: `<module>_tests.rs` (z `s` na końcu), nie `<module>_test.rs`.

### 8.2 Rejestracja w `Cargo.toml`

```toml
[[test]]
name = "audio_tests"
path = "tests/rust/unit/audio_tests.rs"
```

### 8.3 Zasada Lua-first (TST-01)

Jeśli zachowanie jest dostępne przez `lurek.*` — test trafia do `tests/lua/unit/`, nie do Rust.

Rust testy są wyłącznie dla:
- Prywatnych wewnętrznych struktur/algorytmów niedostępnych z Lua
- Funkcji pomocniczych nieeksponowanych w API
- Edge cases specyficznych dla Rust (overflow, thread safety)

### 8.4 Nazewnictwo funkcji testowych

```rust
#[test]
fn test_<behavior>_<condition>() { ... }

// Przykłady:
fn test_body_position_after_one_step() { ... }
fn test_volume_clamps_above_maximum() { ... }
fn test_decoder_returns_error_on_missing_file() { ... }
```

### 8.5 Jedna asercja — jeden powód awarii

```rust
// POPRAWNIE
#[test]
fn test_volume_clamps_above_maximum() {
    let mut mixer = Mixer::new();
    mixer.set_master_volume(2.0);
    assert_eq!(mixer.get_master_volume(), 1.0);
}

// BŁĘDNIE
#[test]
fn test_volume() {
    let mut mixer = Mixer::new();
    mixer.set_master_volume(2.0);
    assert_eq!(mixer.get_master_volume(), 1.0);
    mixer.set_master_volume(-1.0);
    assert_eq!(mixer.get_master_volume(), 0.0);
}
```

---

## 9. Generowanie dokumentacji — pipeline

### 9.1 Kiedy regenerować

Po każdej zmianie w `src/lua_api/*_api.rs`:

```powershell
python tools/docs/gen_lua_api_data.py
python tools/docs/gen_luadoc.py
python tools/docs/gen_extension_api.py
```

### 9.2 Co jest generowane

| Plik wyjściowy                  | Źródło                          |
|---------------------------------|---------------------------------|
| `docs/api/lurek.lua`            | `src/lua_api/*_api.rs` docstrings|
| `build/api.md`                  | Jw.                             |
| `build/completions.json`        | Jw.                             |
| `build/hover.json`              | Jw.                             |
| `build/signatures.json`         | Jw.                             |

**Nigdy nie edytuj ręcznie** żadnego z powyższych plików.

### 9.3 Walidacja API

Po zmianie bindingów uruchom:

```powershell
python tools/validate/validate_lua_api.py
```

Narzędzie sprawdza:
- Czy wszystkie zarejestrowane funkcje mają docstring
- Czy nazwy argumentów zgadzają się z zadeklarowanymi typami
- Czy wygenerowany stub jest zsynchronizowany

---

## 10. Synchronizacja artefaktów

Każda zmiana musi zaktualizować wszystkie powiązane artefakty **w tym samym commicie**:

| Zmiana                                    | Co zaktualizować                                                         |
|-------------------------------------------|--------------------------------------------------------------------------|
| `src/<module>/*.rs`                       | `docs/specs/<module>.md`                                                 |
| `src/lua_api/<module>_api.rs`             | `docs/specs/<module>.md` + regen API outputs                            |
| Dodanie/zmiana/usunięcie `lurek.*` API    | `content/examples/`, dotknięte `content/games/`, moduły `library/`      |
| Nowy moduł                                | `docs/specs/<module>.md` + wpis w `docs/specs/README.md`                |
| `library/<name>/init.lua`                 | `example.lua`, testy, rejestracja harness, regeneracja library docs      |
| Onboarding, build steps, quality gates   | `docs/handbook.md` + `CONTRIBUTING.md`                                  |
| Nowe demo w `content/games/`              | Pasujący test, smoke test, rejestracja harness                          |
| Każda zmiana                              | `docs/CHANGELOG.md`                                                      |

---

## 11. Bramy jakości przed commitem

Uruchom **wszystkie** przed każdym commitem:

```powershell
# 1. Kompilacja i testy
cargo test

# 2. Clippy — zero ostrzeżeń
cargo clippy -- -D warnings

# 3. Walidacja CAG (tylko jeśli dotykasz .github/)
python tools/validate/cag_validate.py

# 4. Sprawdzenie linków CAG (tylko jeśli zmieniają się ścieżki)
python tools/audit/cag_link_check.py --strict

# 5. Walidacja API Lua (po każdej zmianie *_api.rs)
python tools/validate/validate_lua_api.py
```

### 11.1 Format commitu

```
type(scope): description
```

Typy: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

Jeden logiczny change per commit.

Przykłady:
```
feat(audio): add setDopplerScale binding
fix(physics): clamp restitution coefficient to valid range
test(math): add vec2 normalization edge case tests
docs(audio): update audio.md with new DSP boundary
```

### 11.2 Staging

Nigdy nie używaj `git add .`. Staguj tylko dotknięte pliki.

---

## Appendix A — Szybka lista kontrolna dla nowego modułu

Nowy moduł Rust + Lua API:

- [ ] `src/<module>/mod.rs` — tylko `pub mod`, `pub use`, `//!`, atrybuty
- [ ] `src/<module>/<impl>.rs` — logika biznesowa, typy, algorytmy
- [ ] `src/lua_api/<module>_api.rs` — thin wrapper, `register()`, docstringi
- [ ] `pub mod <module>_api;` w `src/lua_api/mod.rs`
- [ ] Wywołanie `<module>_api::register(lua, state)?;` w `src/lua_api/register.rs`
- [ ] `docs/specs/<module>.md` — spec modułu
- [ ] Wpis w `docs/specs/README.md`
- [ ] `content/examples/<module>.lua` — przykłady użycia
- [ ] `tests/lua/unit/test_<module>_core_unit.lua` — testy Lua
- [ ] Rejestracja pliku testowego w `tests/lua/harness.rs`
- [ ] Wpis `[[test]]` w `Cargo.toml` dla opcjonalnych testów Rust prywatnych
- [ ] `docs/CHANGELOG.md` — entry dla nowego modułu
- [ ] Regeneracja API docs: `python tools/docs/gen_lua_api_data.py && python tools/docs/gen_luadoc.py`
- [ ] `cargo test && cargo clippy -- -D warnings` — zero failures, zero warnings

## Appendix B — Szybka lista kontrolna dla nowej metody w istniejącym module

- [ ] Metoda dodana do `src/<module>/<impl>.rs` (logika)
- [ ] Binding dodany do `src/lua_api/<module>_api.rs` (cienki wrapper)
- [ ] Docstring w formacie `/// description\n/// @param | name | Type | desc\n/// @return | Type | desc`
- [ ] Separator `// -- methodName --` przed docstringiem
- [ ] Typy parametrów clamped/validated na granicy
- [ ] Komunikat błędu zaczyna się od `lurek.<module>.<method>:`
- [ ] Typ implementuje `type()` i `typeOf()` (jeśli to nowy LuaUserData)
- [ ] Test w `tests/lua/unit/test_<module>_core_unit.lua` z `-- @covers`
- [ ] Regeneracja API docs
- [ ] `docs/CHANGELOG.md` zaktualizowany

## Appendix C — Kompletny przykład LuaUserData

```rust
//! `lurek.shape` — Shape creation and collision query bindings.

use super::SharedState;
use crate::shape::{Circle, Rect};
use mlua::prelude::*;

// ── LuaCircle ────────────────────────────────────────────────────────────────

/// Lua-visible handle for a circle shape used in queries and collision checks.
pub struct LuaCircle {
    /// Wrapped circle data: center and radius in world units.
    pub inner: Circle,
}

/// Provides Lua fields and methods for circle shape operations.
impl LuaUserData for LuaCircle {
    fn add_fields<'lua, F: LuaUserDataFields<'lua, Self>>(fields: &mut F) {
        /// X coordinate of the circle center in world units.
        fields.add_field_method_get("x", |_, this| Ok(this.inner.x as f64));
        fields.add_field_method_set("x", |_, this, v: f64| {
            this.inner.x = v as f32;
            Ok(())
        });
        /// Y coordinate of the circle center in world units.
        fields.add_field_method_get("y", |_, this| Ok(this.inner.y as f64));
        fields.add_field_method_set("y", |_, this, v: f64| {
            this.inner.y = v as f32;
            Ok(())
        });
        /// Radius of the circle in world units; must be positive.
        fields.add_field_method_get("radius", |_, this| Ok(this.inner.radius as f64));
        fields.add_field_method_set("radius", |_, this, v: f64| {
            this.inner.radius = (v as f32).max(0.0);
            Ok(())
        });
    }

    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- contains --
        /// Returns whether a point is inside this circle.
        /// @param | px | number | Point x coordinate in world units.
        /// @param | py | number | Point y coordinate in world units.
        /// @return | boolean | True when the point is within or on the circle boundary.
        methods.add_method("contains", |_, this, (px, py): (f64, f64)| {
            Ok(this.inner.contains(px as f32, py as f32))
        });

        // -- overlaps --
        /// Returns whether this circle overlaps another circle.
        /// @param | other | LCircle | Other circle handle.
        /// @return | boolean | True when the circles intersect or touch.
        methods.add_method("overlaps", |_, this, other: LuaAnyUserData| {
            let o = other.borrow::<LuaCircle>()?;
            Ok(this.inner.overlaps(o.inner))
        });

        // -- area --
        /// Returns the area of this circle.
        /// @return | number | Area in square world units.
        methods.add_method("area", |_, this, ()| {
            Ok(this.inner.area() as f64)
        });

        // -- type --
        /// Returns the Lua-visible type name for this circle handle.
        /// @return | string | The string `LCircle`.
        methods.add_method("type", |_, _, ()| Ok("LCircle"));

        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LCircle` and `Object`.
        /// @return | boolean | True when the supplied name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LCircle" || name == "LObject")
        });
    }
}

// ── Registration ─────────────────────────────────────────────────────────────

/// Registers the `lurek.shape` table and all its constructor functions into the Lua VM.
pub fn register(lua: &Lua, _state: &SharedState) -> mlua::Result<()> {
    let shape = lua.create_table()?;

    // -- newCircle --
    shape.set("newCircle", lua.create_function(|lua, (x, y, r): (f64, f64, f64)| {
        let radius = (r as f32).max(0.0);
        lua.create_userdata(LuaCircle {
            inner: Circle { x: x as f32, y: y as f32, radius },
        })
    })?)?;

    lua.globals().get::<_, mlua::Table>("lurek")?.set("shape", shape)?;
    Ok(())
}
```

## Appendix D — Kompletny przykład testu Lua

```lua
-- Lurek2D Shape API Tests

-- @describe lurek.shape module exists
describe("lurek.shape module exists", function()
    -- @covers lurek.shape
    it("lurek.shape is a table", function()
        expect_type("table", lurek.shape)
    end)
end)

-- @describe lurek.shape circle constructor
describe("lurek.shape circle constructor", function()
    -- @covers lurek.shape.newCircle
    it("newCircle is a function", function()
        expect_type("function", lurek.shape.newCircle)
    end)

    -- @covers lurek.shape.newCircle
    it("newCircle returns userdata", function()
        local c = lurek.shape.newCircle(0, 0, 10)
        expect_type("userdata", c)
    end)

    -- @covers lurek.shape.newCircle
    it("newCircle stores correct center coordinates", function()
        local c = lurek.shape.newCircle(5, 7, 10)
        expect_near(5, c.x, 0.001)
        expect_near(7, c.y, 0.001)
    end)

    -- @covers lurek.shape.newCircle
    it("newCircle stores correct radius", function()
        local c = lurek.shape.newCircle(0, 0, 15)
        expect_near(15, c.radius, 0.001)
    end)
end)

-- @describe lurek.shape circle methods
describe("lurek.shape circle methods", function()
    -- @covers LCircle:contains
    it("contains returns true for point inside", function()
        local c = lurek.shape.newCircle(0, 0, 10)
        expect_true(c:contains(5, 0))
    end)

    -- @covers LCircle:contains
    it("contains returns false for point outside", function()
        local c = lurek.shape.newCircle(0, 0, 10)
        expect_false(c:contains(20, 0))
    end)

    -- @covers LCircle:area
    it("area returns positive number", function()
        local c = lurek.shape.newCircle(0, 0, 5)
        local a = c:area()
        expect_type("number", a)
        expect_true(a > 0)
    end)

    -- @covers LCircle:type
    it("type returns LCircle", function()
        local c = lurek.shape.newCircle(0, 0, 1)
        expect_equal("LCircle", c:type())
    end)

    -- @covers LCircle:typeOf
    it("typeOf matches LCircle", function()
        local c = lurek.shape.newCircle(0, 0, 1)
        expect_true(c:typeOf("LCircle"))
    end)

    -- @covers LCircle:typeOf
    it("typeOf matches Object", function()
        local c = lurek.shape.newCircle(0, 0, 1)
        expect_true(c:typeOf("LObject"))
    end)

    -- @covers LCircle:typeOf
    it("typeOf rejects unknown type", function()
        local c = lurek.shape.newCircle(0, 0, 1)
        expect_false(c:typeOf("LVec2"))
    end)
end)

test_summary()
```
