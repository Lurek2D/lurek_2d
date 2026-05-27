# Sports Manager — Lurek2D

> **Kategoria / Category:** Sports · Management Simulation  
> **Uruchamianie / Run:** `cargo run -- content/games/sports/sports_manager`

---

## O grze / About

**PL:** Symulator zarządzania klubem piłkarskim z 14-tygodniową ligą round-robin (8 drużyn). Gracz zarządza składem 16 zawodników (GK/DEF/MID/FWD), zleca treningi, kupuje zawodników na rynku transferowym i symuluje mecze z play-by-play. Zwycięstwa przynoszą złoto (waluta), kontuzje losowo wyłączają zawodników.

**EN:** A football club management simulator with a 14-week round-robin league (8 teams). The player manages a 16-player roster (GK/DEF/MID/FWD), runs weekly training sessions, buys players from the transfer market, and simulates matches with a play-by-play commentary feed. Wins earn gold (currency); injuries randomly bench players.

---

## Pętla rozgrywki / Gameplay Loop

1. **Office** — hub tygodnia: podgląd tabeli, budżet, stan składu.
2. **Roster** (R) — kliknij zawodnika aby dodać/usunąć z jedenastki startowej; max 11 startujących.
3. **Training** (T) — wybierz fokus raz na tydzień: Offence / Defence / Fitness / Morale.
4. **Transfer** (B) — kup jednego z 3 zawodników na rynku (cena = skill-based).
5. **Match** (Space) — symulacja meczu: 6 eventów, live play-by-play (text), animowane goal-particles.
6. **Season End** — po 14 tygodniach: finalna pozycja w tabeli, wynik sezonu.

---

## Uruchamianie / Run

```bash
cargo run -- content/games/sports/sports_manager
```

---

## Sterowanie / Controls

| Klawisz / Key | Akcja / Action |
|---|---|
| `R` | Roster (zarządzanie składem) |
| `T` | Training |
| `B` | Transfer market |
| `Space` | Symuluj następny mecz |
| `O / D / F / M` | Wybór opcji treningu |
| `1 / 2 / 3` | Kup zawodnika z rynku |
| `LMB` | Kliknij zawodnika w roster |
| `Escape` | Wyjście |

---

## Inspiracje / Inspirations

| Tytuł | Nawiązanie |
|---|---|
| **Football Manager** (Sports Interactive) | Roster, treningi, liga, transfery |
| **Sensible World of Soccer** (Amiga 1994) | Szybka symulacja meczu z play-by-play |
| **New Star Soccer** | Budżet + morale + stamina system |
| **Championship Manager 01/02** | Tabela ligowa, round-robin schedule |

---

## Lurek Engine API — kluczowe funkcje

| API | Zastosowanie |
|---|---|
| `lurek.ui.loadLayoutFile` | Multi-screen TOML: office, roster, match, training, transfer, season-end |
| `lurek.input.bind` + `mouse1` | Klikalne wiersze w roster (pozycja myszy) |
| Tween (manualny) | Animowane punkty w tabeli, score display |
| Particle (manualny, 3 typy) | Goal confetti, training sparks, transfer gold |
| `lurek.timer.getFPS` | FPS counter |
| `lurek.event.quit` | Bezpieczne zamknięcie |

---

## Przydatność i unikalność / Showcase Value

**PL:** Sports Manager jest jedyną grą w bibliotece demonstrującą **kompletny cykl zarządzania** (roster → trening → transfer → mecz → liga) oraz **proceduralny generator piłkarzy** z losowymi imionami, pozycjami i statystykami. Pokazuje jak Lurek może obsłużyć złożony stan gry zarządzany przez wiele ekranów TOML bez żadnego frameworka UI.

**EN:** Sports Manager is the only demo in the library with a **complete management loop** (roster → training → market → match → league table), a **procedural player generator** with random names and stats, and a **TOML multi-screen UI** driven entirely from Lua state. It demonstrates that Lurek can handle complex persistent game state across multiple screens.

### Podobne gry / Similar games to watch for overlap
- **Sensible Soccer** — ta sama tematyka futbolowa, ale gameplay zręcznościowy nie zarządczy.
- ✅ **Verdict:** Jedyny management sim w bibliotece — **keep**. Potencjalne ryzyko duplikacji tylko gdyby dodano drugą grę zarządzania.
