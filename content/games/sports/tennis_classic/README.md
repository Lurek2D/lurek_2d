# Tennis Classic — Lurek2D

> **Kategoria / Category:** Sports · Racket  
> **Uruchamianie / Run:** `cargo run -- content/games/sports/tennis_classic`

---

## O grze / About

**PL:** Pełnoprawna tenisowa rozgrywka widok z góry z kompletnym systemem punktacji (15/30/40/Deuce/Advantage), serwisem dwuetapowym (podrzut → uderzenie), topspin/slice, AI przeciwnikiem z reakcją rosnącą z każdym setem i mechaniką ładowania mocy uderzenia. Format: best-of-3 sety.

**EN:** A complete top-down tennis game featuring authentic scoring (15/30/40/Deuce/Advantage), a two-phase serve (toss → hit), topspin/slice spin modifiers, an AI opponent that speeds up each set, and a charge-power hit mechanic. Match format: best-of-3 sets.

---

## Pętla rozgrywki / Gameplay Loop

1. **Title** — `Space` aby rozpocząć.
2. **Serving** — `Space` × 2: najpierw podrzut, potem uderzenie; aim_dir lewo/prawo wybiera pole serwisowe.
3. **Playing** — poruszaj się WASD; gdy piłka jest blisko i leci w Twoją stronę, naciśnij i zwolnij `Space` dla nabitego uderzenia.
   - `W` = topspin (piłka zapada się), `S` = slice (piłka unosi się).
   - `A / D` podczas uderzenia = kierunek cross/down-the-line.
4. **AI** — rywalizuje, powraca do centrum, przyspiesza co set.
5. **Deuce / Advantage / Set End / Match End** — komunikaty z timerem.

---

## Uruchamianie / Run

```bash
cargo run -- content/games/sports/tennis_classic
```

---

## Sterowanie / Controls

| Klawisz / Key | Akcja / Action |
|---|---|
| `W / A / S / D` | Ruch gracza |
| `Space` (naciśnij) | Start ładowania uderzenia / podrzut |
| `Space` (puść) | Uderzenie (siła = czas trzymania) |
| `A / D` | Kierunek cross/DTL podczas uderzenia |
| `W / S` | Topspin / Slice |
| `Escape` | Wyjście |

---

## Inspiracje / Inspirations

| Tytuł | Nawiązanie |
|---|---|
| **Pong** (Atari, 1972) | Ojciec rakietek ekranowych |
| **Wimbledon** (Amiga, 1992) | Top-down tennis z prawdziwym scoringiem |
| **Super Tennis** (SNES, 1991) | Serwis dwufazowy, spin modifier |
| **Mario Tennis** (N64, 1998) | Charge shot, AI scaling with sets |

---

## Lurek Engine API — kluczowe funkcje

| API | Zastosowanie |
|---|---|
| `lurek.particle.newSystem` | Dust (odbicia), ace (match-win), net (błąd sieciowy) |
| `lurek.ui.loadLayoutFile` | HUD wynik, sety, rally counter; overlay komunikaty |
| `lurek.camera.new` | Inicjalizacja kamery |
| `lurek.tween` (manual lerp) | Ball trail fade, score popup alpha |
| `lurek.input.bind` | WASD + Space action mapping |
| `lurek.timer.getFPS` | FPS counter |

---

## Przydatność i unikalność / Showcase Value

**PL:** Tennis Classic jest jedyną grą w bibliotece z **pełnym systemem punktacji teniса** (Deuce/Advantage, sety, mecz best-of-3), **mechaniką topspin/slice** wpływającą na trajektorię piłki i **ładowaniem mocy** uderzenia. Trzy rodzaje particle systems (dust, ace, net) działają jednocześnie.

**EN:** Tennis Classic is the only demo implementing **authentic tennis scoring** (Deuce/Advantage/sets/best-of-3), a **spin modifier system** (topspin/slice affecting ball trajectory), and a **charge-release hit mechanic**. Three simultaneous particle systems (dust, ace, net) demonstrate multi-emitter usage in Lurek.

### Podobne gry / Similar games to watch for overlap
- **Sensible Soccer, Fishing** — inne sporty rakietowe/ball; brak semantycznego nakładania.
- **Pong** (arcade/) — tematycznie zbliżone, ale Pong jest prymitywny; Tennis Classic to pełna symulacja.
- ✅ **Verdict:** Jedyna pełna rakietkowa gra — **keep**. Duplikacja ryzyka niska.
