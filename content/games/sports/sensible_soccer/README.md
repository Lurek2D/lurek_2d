# Sensible Soccer — Lurek2D

> **Kategoria / Category:** Sports · Football  
> **Uruchamianie / Run:** `cargo run -- content/games/sports/sensible_soccer`

---

## O grze / About

**PL:** Zręcznościowa piłka nożna widok z góry inspirowana klasycznym **Sensible Soccer** (Renegade Software / Amiga, 1992). Mecz 5-na-5 z ręcznie sterowanym napastnikiem, automatycznym przełączaniem na zawodnika najbliższego piłki, strzałem z aftertouch (krzywa piłki) i prostą AI CPU. Mecz trwa 90 sekund.

**EN:** A top-down arcade football game inspired by the classic **Sensible Soccer** (Renegade Software / Amiga, 1992). 5-a-side match with the player controlling the teammate nearest the ball, aftertouch shooting (curved ball), sliding tackles, and a simple CPU AI. Match duration: 90 seconds.

---

## Pętla rozgrywki / Gameplay Loop

1. **Kickoff** — naciśnij `Space` aby rozpocząć.
2. **Play** — poruszaj się WASD; gra automatycznie przełącza sterowanie na zawodnika najbliżej piłki.
3. **Strzał** — naciśnij `Space` gdy piłka jest blisko; kierunek biegu = kierunek strzału + aftertouch krzywej.
4. **Goal** — pauza 2.5 s, wznowienie z kickoff.
5. **Full Time** — wynik końcowy po 90 sekundach.

CPU drużyna automatycznie goni piłkę i strzela w stronę bramki gracza.

---

## Uruchamianie / Run

```bash
cargo run -- content/games/sports/sensible_soccer
```

---

## Sterowanie / Controls

| Klawisz / Key | Akcja / Action |
|---|---|
| `W / A / S / D` | Ruch gracza |
| `Space` | Strzał / Kickoff |
| `Escape` | Wyjście |

---

## Inspiracje / Inspirations

| Tytuł | Nawiązanie |
|---|---|
| **Sensible Soccer** (Amiga 1992) | Top-down football, 5-a-side, aftertouch |
| **Kick Off 2** (Amiga 1990) | Momentum-based ball physics |
| **FIFA Street** | Mały skład, uproszczone zasady |
| **New Star Soccer** | Automatyczne przełączanie gracza |

---

## Lurek Engine API — kluczowe funkcje

| API | Zastosowanie |
|---|---|
| `lurek.ui.loadLayoutFile` | TOML HUD: wynik, zegar, overlaye (kickoff / goal / FT) |
| `lurek.input.bind` | WASD + Space action binding |
| `lurek.render.setColor` | Boisko, zawodnicy, piłka |
| `lurek.render.circle` | Okrągłe sprite'y zawodników i piłki |
| `lurek.render.line` | Środkowe linie boiska |
| `lurek.keypressed` | Strzał na keypress event |

---

## Przydatność i unikalność / Showcase Value

**PL:** Sensible Soccer jest jedyną grą w bibliotece demonstrującą **multi-agent AI** (10 zawodników z niezależnymi celami), **automatyczne przełączanie kontroli** i **aftertouch momentum** — wszystko bez fizyki Rapier. Pokazuje jak wbudować prostą symulację piłki za pomocą czystej matematyki Lua.

**EN:** The only demo in the library combining **multi-agent AI positioning** (10 independent players), **auto-player-switching logic**, and **aftertouch ball curving** — entirely in pure Lua physics without Rapier. It showcases team-state management and real-time control switching patterns.

### Podobne gry / Similar games to watch for overlap
- **Sports Manager** — współdzieli temat futbolu, ale to symulator zarządzania a nie zręcznościówka.
- ✅ **Verdict:** Unikalna w kategorii „arcade sport" — **keep**.
