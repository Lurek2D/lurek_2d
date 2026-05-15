# Lurek2D Runtime Modes — Master Plan (As Built)

## Cel

Jedna binarka `lurek2d.exe` obsługuje cztery tryby uruchomienia: `gui`, `tui`, `headless`, `cli`.

Wybór trybu jest robiony przez CLI (`--mode=...`, `--gui`, `--tui`, `--headless`, `--cli`) albo przez `conf.toml` w sekcji `[runtime]`.

Nie ma żadnej zależności od VS Code extension. Wszystko dotyczy uruchamiania `lurek2d.exe`.

---

## Status

Stan na 2026-05-15:

- wdrożone: parsowanie trybów, config, GUI/TUI/CLI w jednej ścieżce okienkowej, prawdziwy headless bez okna, release-safe `src/repl/`, `lurek.repl`, `LTerminal:print`, Rust testy, Lua testy, przykłady, specy,
- niewdrożone jeszcze: pełny hard reset VM z GUI CLI po `:reset`, multiline input w CLI, automatyczne ładowanie podanego `main.lua` w trybie CLI.

---

## Macierz trybów

| Tryb | Okno | Render | Input | `terminal` | `main.lua` | Kod startowy |
|------|------|--------|-------|------------|------------|--------------|
| `gui` | tak | pełny | pełny | opcjonalny | normalnie z game dir | `App::run()` |
| `tui` | tak | tylko terminal-grid | klawiatura + mysz | wymagany | z podanego game dir albo z built-in TUI script | `App::run()` |
| `headless` | nie | brak | brak | wyłączony | ładowany tylko gdy podano game dir i istnieje `main.lua` | `runtime::run_headless()` |
| `cli` | tak | tylko terminal-grid | klawiatura | wymagany | nie jest automatycznie uruchamiany; przy podanym game dir ścieżka jest tylko pokazana w UI | `App::run()` |

---

## Wywołanie

```text
lurek2d [game_dir]
lurek2d --mode=gui [game_dir]
lurek2d --mode=tui [game_dir]
lurek2d --mode=headless [game_dir] [--eval CODE] [--frames N]
lurek2d --mode=cli [game_dir]

lurek2d --gui [game_dir]
lurek2d --tui [game_dir]
lurek2d --headless [game_dir] [--eval CODE] [--frames N]
lurek2d --cli [game_dir]
```

Uwagi:

- `--eval` i `--frames` są używane tylko przez headless.
- `--mode` z CLI ma priorytet nad `[runtime].mode` w `conf.toml`.
- jeśli nie podano `game_dir`, GUI i headless używają bieżącego katalogu, a TUI i CLI generują tymczasowy runtime script.

---

## Wspólna architektura

### 1. Jeden bootstrap w `src/lib.rs`

`lurek_run()`:

- parsuje flagi runtime,
- ładuje `Config::load(&game_dir)`,
- wybiera `RuntimeMode`,
- dla `gui`, `tui`, `cli` uruchamia wspólny `App::run()`,
- dla `headless` omija `app` i przechodzi bezpośrednio do `runtime::run_headless()`.

### 2. TUI i CLI nie mają osobnych `tui_app.rs` / `cli_app.rs`

Zamiast osobnych app-ek, obecna implementacja używa wspólnego okienkowego runtime:

- `src/lib.rs` ustawia rozmiar okna z `[tui]` albo `[cli]`,
- wymusza `render`, `input`, `window`, `terminal`,
- buduje tymczasowy katalog z `main.lua` i `conf.toml` przez `create_builtin_game_dir()`,
- odpala zwykłe `App::run()`.

To jest świadoma decyzja: jedna ścieżka okienkowa, jeden event loop, jedno GPU bootstrap, różne skrypty startowe.

### 3. Konfiguracja trybów w `src/runtime/config.rs`

Runtime modes siedzą w:

```toml
[runtime]
mode = "gui"

[tui]
cols = 80
rows = 25
cell_width = 10
cell_height = 20

[cli]
cols = 100
rows = 30
cell_width = 10
cell_height = 20
max_history = 200

[headless]
frames = 0
dt = 0.0166666667
```

---

## Tryb GUI

GUI jest punktem odniesienia i zachowuje dotychczasowy model:

- pełne okno,
- pełny render,
- pełny input,
- normalne ładowanie `main.lua`,
- standardowy cykl callbacków w `App::run()`.

Kod: `src/lib.rs` + `src/app/app.rs`.

---

## Tryb TUI

### Charakter

To dalej jest GUI, ale całe okno jest traktowane jako terminal-grid renderowany przez `lurek.terminal`.

### Obecne zachowanie

- okno jest ustawiane na `cols * cell_width` i `rows * cell_height`,
- `window.resizable = false`,
- tytuł dostaje sufiks `[TUI]`,
- `terminal`, `render`, `input`, `window` są włączane przed `App::run()`,
- jeśli podano `game_dir`, ładowane jest normalne `main.lua` z tej gry,
- jeśli nie podano `game_dir`, bootstrap tworzy tymczasowy katalog z prostym built-in TUI script, który renderuje DOS-like ekran informacyjny.

### Własność modułów

- `terminal` odpowiada za siatkę, widgety i render-commandy,
- `runtime` odpowiada za wybór trybu i parametry okna,
- `app` dalej posiada event loop i GPU.

---

## Tryb HEADLESS

### Charakter

To jest prawdziwy headless CLI runtime, nie „udawane GUI bez renderu”. Nie tworzy okna, nie uruchamia `winit`, nie tworzy GPU.

### Obecne zachowanie

Kod: `src/runtime/headless.rs`.

Sekwencja:

1. `create_headless_state()` buduje `SharedState` bez okna.
2. `create_headless_vm()` klonuje `ModulesConfig`, stosuje `apply_headless_profile()`, potem uruchamia normalne rejestrowanie Lua API.
3. `install_stdout_print()` podmienia `print(...)` tak, żeby pisał na `stdout`.
4. `install_game_package_path()` dopisuje `game_dir` i `content/` do `package.path`.
5. `load_main_if_present()` ładuje `main.lua` tylko wtedy, gdy użytkownik jawnie podał `game_dir` i plik istnieje.
6. `--eval` snippets wykonują się po `main.lua`.
7. Runtime woła `lurek.init()` i `lurek.ready()`.
8. Jeśli `frames > 0`, wykonuje pętlę callbacków:

```text
process_physics(dt)
fixedUpdate(dt)
process(dt)
process_late(dt)
```

Brak `draw()` i `draw_ui()`.

### Profil modułów

Headless wymusza wyłączenie:

- `audio`
- `render`
- `input`
- `window`
- `terminal`
- `particle`
- `effect`
- `tilemap`
- `ui`
- `minimap`
- `animation`
- `tween`
- `camera`
- `raycaster`
- `spine`
- `parallax`
- `globe`

Pozostałe moduły są zachowywane zgodnie z configiem po standardowym `validate_and_fix()`.

### Ważna uwaga

Headless nie rozluźnia sandboxa `create_lua_vm()`. `load`, `loadfile`, `dofile`, `debug`, `os.execute`, `io.open`, `io.popen` dalej są zablokowane, bo headless korzysta z tej samej bezpiecznej ścieżki VM i tylko dokłada profil modułów oraz `print -> stdout`.

---

## Tryb CLI

### Charakter

To jest okno GUI renderowane jako interaktywny terminal. Nie używa systemowej konsoli jako głównego UI. Prompt i wynik są rysowane przez silnik, tak jak inne terminal surfaces.

### Obecne zachowanie

Kod startowy jest generowany w `src/lib.rs` przez `builtin_cli_script()`.

Script robi:

- `term = lurek.terminal.newTerminal(cols, rows)`
- `term:setCellSize(cell_w, cell_h)`
- `repl = lurek.repl.new(max_history)`
- lokalne buforowanie linii wyjścia,
- lokalne buforowanie historii prompta,
- `print = function(...) ... end` przekierowane do bufora terminala,
- `Enter` → `repl:eval(command)`,
- `Tab` → `repl:complete(input)`,
- `Esc` albo wynik `:quit` → `lurek.event.quit()`.

### Render i input

- okno jest ustawiane na rozmiar z `[cli]`,
- `draw()` czyści terminal, rysuje scrollback i prompt `lurek>`,
- `textinput()` dopisuje znaki do aktualnej linii,
- `keypressed()` obsługuje Enter, Backspace, Esc, Tab, Up, Down.

### Obecne ograniczenia

- przy podanym `game_dir` CLI pokazuje tylko ścieżkę do `main.lua` jako informację startową; nie ładuje go automatycznie,
- historia prompta jest lokalna dla built-in Lua script, a nie oparta na `lurek.terminal.pushCmdHistory`,
- `:reset` czyści historię REPL, ale nie odtwarza jeszcze nowej VM,
- multiline input nie jest jeszcze zaimplementowany.

---

## Moduł `src/repl/`

### Rola

`src/repl/` jest release-safe rdzeniem REPL wspólnym dla GUI CLI i devtools wrappera.

### Pliki

```text
src/repl/
├── mod.rs
├── commands.rs
├── completer.rs
├── session.rs
└── value.rs
```

### Publiczny kontrakt

```rust
pub struct ReplSession {
    // bounded history only
}

pub enum ReplResult {
    Value(String),
    Ok,
    Error(String),
    Command(ReplCommand),
}

pub enum ReplCommand {
    Help,
    Quit,
    Clear,
    Reset,
    Load { path: String },
}
```

`ReplSession` nie posiada VM. Embedding runtime podaje `&mlua::Lua` przy każdym `eval_line()`.

### Lua API

`src/lua_api/repl_api.rs` rejestruje:

- `lurek.repl.new(max_history)`
- `LReplSession:eval`
- `LReplSession:history`
- `LReplSession:clear`
- `LReplSession:len`
- `LReplSession:complete`
- `LReplSession:type`
- `LReplSession:typeOf`

---

## Mapa plików wdrożenia

### Runtime / startup

- `src/lib.rs` — parsowanie CLI, wybór `RuntimeMode`, built-in TUI/CLI scripts
- `src/runtime/mode.rs` — enum `RuntimeMode` i parser tokenów
- `src/runtime/config.rs` — `[runtime]`, `[tui]`, `[cli]`, `[headless]`
- `src/runtime/headless.rs` — prawdziwa no-window ścieżka wykonania
- `src/runtime/mod.rs` — re-exporty runtime mode/headless

### Lua bridge

- `src/lua_api/register.rs` — `create_headless_vm()`
- `src/lua_api/repl_api.rs` — thin wrapper `lurek.repl`
- `src/lua_api/terminal_api.rs` — `LTerminal:print`
- `src/lua_api/system_api.rs` — runtime config inspection spójna z nowym mode state

### REPL

- `src/repl/commands.rs`
- `src/repl/completer.rs`
- `src/repl/session.rs`
- `src/repl/value.rs`
- `src/devtools/repl.rs` — wrapper zgodny z nowym core

### Testy i przykłady

- `tests/rust/unit/repl_tests.rs`
- `tests/rust/unit/runtime_tests.rs`
- `tests/engine_tests.rs`
- `tests/lua/unit/test_repl_core_unit.lua`
- `tests/lua/unit/test_runtime_core_unit.lua`
- `tests/lua/unit/test_terminal_core_unit.lua`
- `content/examples/repl.lua`
- `content/examples/terminal.lua`

### Specy i changelog

- `docs/specs/repl.md`
- `docs/specs/runtime.md`
- `docs/specs/terminal.md`
- `docs/specs/app.md`
- `docs/specs/bin.md`
- `docs/specs/lua_api.md`
- `docs/CHANGELOG.md`

---

## Follow-up backlog

To nie są błędy wdrożenia bazowego, ale dalej są to realne luki względem pierwotnie ambitniejszego planu:

1. `CLI :reset` powinno tworzyć świeżą VM, a dziś tylko czyści historię REPL.
2. `CLI + game_dir` powinno mieć jawny tryb `:load-main` albo autoload, bo dziś ścieżka do `main.lua` jest tylko pokazywana.
3. CLI powinno dostać multiline input i parser kontynuacji.
4. GUI CLI może później przejść z lokalnej historii prompta na natywne `terminal` command-history API, jeśli chcemy jedną implementację historii w całym silniku.

Ten dokument jest planem nadrzędnym dla runtime modes, ale opisuje stan rzeczywisty, nie hipotetyczny.
        }
        Mode::Cli => {
            run_cli(config, game_dir);
        }
    }
}
```

---

## Zależności (nowe crate'y)

Żadne nowe crate'y nie są potrzebne.

- Headless: używa istniejącego `mlua` + `std::io`.
- CLI/TUI: używa istniejącego winit + wgpu + terminal module.
- REPL: czysta logika Rust nad mlua (już jest).
- Multiline detection: ręczna heurystyka (kilkanaście linii kodu).

---

## Plan fazowy

### Faza 1: Infrastruktura argumentów (1 dzień)

- Dodać `Mode` enum i parsowanie `--mode=X` / aliasy do `src/lib.rs`.
- Dodać match na `Mode` z `todo!()` dla nowych trybów.
- Gate: `cargo build` przechodzi; `lurek2d` bez argumentów = GUI jak wcześniej.

### Faza 2: Tryb HEADLESS (2 dni)

- Nowy `src/runtime/headless.rs` z `run_headless()`.
- `create_headless_vm()` w register.rs (lub wariant z wyłączonymi modułami).
- Hook `print()` → stdout.
- Obsługa `--eval`, `--frames`, game_dir.
- Gate: `lurek2d --headless --eval "print(10)"` drukuje `10` na stdout i exit 0.

### Faza 3: Moduł `src/repl/` (2 dni)

- Wydzielić `ReplSession` z obecnego `ReplConsole`.
- Dodać multiline, commands, completions.
- Testy w `tests/rust/unit/repl_tests.rs`.
- Gate: testy przechodzą, `ReplSession::eval_line` działa poprawnie.

### Faza 4: Tryb CLI (3 dni)

- Nowy `src/app/cli_app.rs`: ApplicationHandler z terminalem pełnoekranowym.
- Połączyć `ReplSession` + terminal module + render.
- Print hook Lua → terminal scrollback.
- Auto-complete lurek.* namespaces.
- Gate: `lurek2d --cli` otwiera okno, wpisuję `print(10)`, widzę `10`.

### Faza 5: Tryb TUI (2 dni)

- Nowy `src/app/tui_app.rs`: jak cli_app ale ładuje main.lua.
- Rozmiar okna z conf.toml [tui] section.
- Auto-render terminala bez lurek.draw() (opcjonalnie nadpisywalne).
- Gate: `lurek2d --tui content/games/showcase/terminal_demo` działa.

### Faza 6: Polish i docs (1 dzień)

- Dodać `docs/specs/repl.md`.
- Aktualizacja `docs/handbook.md` z nowymi trybami.
- Aktualizacja `CHANGELOG.md`.
- Gate: `cargo clippy -- -D warnings` zero warnings.

---

## Ryzyka

| Ryzyko | Mitigacja |
|--------|-----------|
| Terminal wymaga render → TUI/CLI potrzebują wgpu | To jest zamierzone. TUI i CLI są GUI z ograniczoną powierzchnią renderowaną. |
| Headless VM nie ma timera | Syntetyczny dt (1/60) przekazywany do update(). Timer moduł zarejestrowany z mock clock. |
| REPL w release: devtools feature gate blokuje | Nowy `src/repl/` nie jest za żadnym feature gate. |
| Multiline detection false positives | Prostą heurystykę (zliczanie `do/then/function/end`) można łatwo poprawić iteracyjnie. |
| Regression w GUI mode | Faza 1 nie zmienia istniejącej ścieżki `App::new().run()`. Testy regresji = istniejący test suite. |

---

## Czego NIE robimy

- Nie ruszamy VS Code extension.
- Nie zmieniamy istniejącego zachowania GUI mode.
- Nie dodajemy nowych crate'ów do Cargo.toml.
- Nie tworzymy osobnej binarki (wszystko w `lurek2d.exe`).
- Nie robimy "edytora" — CLI to shell, nie IDE.
- Nie robimy systemu plików wirtualnego dla REPL.

---

## Priorytet implementacji

```
HEADLESS → REPL moduł → CLI → TUI
```

Headless jest najprostszy (brak okna, brak render). CLI jest najważniejszy dla UX. TUI jest wariantem CLI z innym entrypointem (main.lua zamiast REPL).
