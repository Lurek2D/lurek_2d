# Track & Field — Lurek2D

> **Kategoria / Category:** Sports · Athletics  
> **Uruchamianie / Run:** `cargo run -- content/games/sports/track_and_field`

---

## O grze / About

**PL:** Olimpijska gra lekkoatletyczna z **5 konkurencjami**: 100m Sprint, Skok w dal, Rzut oszczepem, Skok wzwyż, 110m Płotki. Mash-based mechanika biegu (alternuj A/D), 3 AI rywali, system staminy, medale złoto/srebro/brąz per dyscyplina i tally medalowe na koniec.

**EN:** Olympic athletics game with **5 events**: 100m Sprint, Long Jump, Javelin Throw, High Jump, 110m Hurdles. Mash-based running (alternate A/D keys), 3 AI rivals, stamina system, per-event gold/silver/bronze medals, and a final medal tally.

---

## Pętla rozgrywki / Gameplay Loop

1. **Title** — `Space` aby zacząć; gra przechodzi przez 5 dyscyplin kolejno.
2. **Event Intro** (2.5s) — nazwa i opis dyscypliny.
3. **Event** — specyficzna mechanika per dyscyplina (patrz niżej).
4. **Event Result** (3.5s) — ranking, medal, bonus za wynik kwalifikacyjny.
5. **Final** — tabela medali: Złoto / Srebro / Brąz, łączne punkty.

### Mechaniki dyscyplin / Event mechanics

| Dyscyplina | Mechnika |
|---|---|
| **100m Sprint** | Mash A/D alternatywnie; 3 AI rywali; czas = wynik |
| **Skok w dal** | Mash → skok `Space` na desce; 3 próby; odległość w metrach |
| **Rzut oszczepem** | Mash → trzymaj `Space` aby ustawić kąt → zwolnij aby rzucić; wiatr wpływa na dystans |
| **Skok wzwyż** | Mash → `Space` blisko drążka; każde przejście podnosi drążek o 5 cm; 3 próby na wysokość |
| **110m Płotki** | Mash A/D + `Space` do skoku nad każdym płotkiem; kara 0.5s za uderzenie |

---

## Uruchamianie / Run

```bash
cargo run -- content/games/sports/track_and_field
```

---

## Sterowanie / Controls

| Klawisz / Key | Akcja / Action |
|---|---|
| `A / ← ` | Mash (lewa noga) |
| `D / →` | Mash (prawa noga) |
| `Space` | Skok / Rzut / Kontekstowa akcja |
| `Escape` | Wyjście |

---

## Inspiracje / Inspirations

| Tytuł | Nawiązanie |
|---|---|
| **Track & Field** (Konami, 1983, Arcade) | Mash mechanic, multi-event athletics |
| **Hyper Sports** (Konami, 1984) | Rzut oszczepem, skok wzwyż |
| **Summer Games** (Epyx, C64, 1984) | Olimpijska struktura dyscyplin |
| **QWOP** (Bennet Foddy, 2008) | Stylized running control stress |

---

## Lurek Engine API — kluczowe funkcje

| API | Zastosowanie |
|---|---|
| `lurek.particle.newSystem` (4 systemy) | Dust (bieg), impact (lądowanie), trail (oszczep), confetti (złoto) |
| `lurek.tween.to` | Speed meter, distance counter, medal alpha reveal |
| `lurek.camera.new` | Kamera śledząca gracza |
| `lurek.ui.loadLayoutFile` | Multi-event TOML HUD: speed bar, distance, medal, event intro |
| `lurek.input.bind` (gamepad) | D-pad mash + gamepad:0:0/2 action |
| `lurek.render.triangle` | Grafika trójkątna (brak do tej pory) |

---

## Przydatność i unikalność / Showcase Value

**PL:** Track & Field jest jedyną grą w bibliotece z **5 osobnymi kompletymi mechanikami sportowymi** w jednym tytule, **systemem staminy** wpływającym na efektywność mash, **4 równoległymi particle systems** i **tweened medal reveal**. Najlepszy showcase złożoności multi-state w engine.

**EN:** Track & Field is the only demo in the library with **5 fully distinct sport mechanics** in a single title, a **stamina system** that degrades mash effectiveness over time, **4 simultaneous particle systems** (dust, impact, trail, confetti), and a **tween-driven medal reveal**. Best multi-state complexity showcase in the library.

### Podobne gry / Similar games to watch for overlap
- **Ski Jump** — single-event winter sport vs. 5-event multi-sport.
- **Trajectory Sports** — projectile-based vs. mash-based; different mechanic families.
- ✅ **Verdict:** Wysoka wartość showcase — jedyna multi-event mash gra — **keep**.
