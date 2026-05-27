# Trajectory Sports — Lurek2D

> **Kategoria / Category:** Sports · Projectile Mini-Games  
> **Uruchamianie / Run:** `cargo run -- content/games/sports/trajectory_sports`

---

## O grze / About

**PL:** Cztery minigry rzutowe / celownicze w jednym tytule: **Archery** (łucznictwo), **Basketball** (koszykówka), **Bowling** (kręgle), **Darts** (rzutki). Każda dyscyplina ma inną mechanikę trajektorii, własny system punktacji i medal (Gold/Silver/Bronze). Na koniec sumowane jest łączne championship ranking.

**EN:** Four projectile/aiming mini-games bundled in one title: **Archery**, **Basketball**, **Bowling**, and **Darts**. Each sport has a distinct trajectory mechanic, individual scoring system, and medal (Gold/Silver/Bronze). A final championship rank is computed from all four medals.

---

## Pętla rozgrywki / Gameplay Loop

1. **Title** → **Sport Select** (klawisze 1–4).
2. **Playing** — specyficzna mechanika per sport.
3. **Round End** — medal, wynik, pauza 3s.
4. Wróć do **Sport Select** dla kolejnego sportu.
5. **Final Scores** — wszystkie medale + championship rank (Participant → Bronze → Silver → Gold → Champion).

### Mechaniki sportów / Sport mechanics

| Sport | Mechanika |
|---|---|
| **Archery** | Trzymaj Space = ładuj moc; W/S = kąt; 10 strzałów; wind drift; bulls-eye scoring |
| **Basketball** | Trzymaj Space = ładuj; W/S = kąt; 10 rzutów; swish=3pt, rim bounce=2pt |
| **Bowling** | A/D = pozycja; Space = moc; kule toczą się, zderzają kręgle; spin A/D w ruchu; 10 klatek |
| **Darts** | Celownik porusza się figurą ósemkową (wobble); Space = rzut w chwili celowania; 301 countdown; 5 tur × 3 strzałki |

---

## Uruchamianie / Run

```bash
cargo run -- content/games/sports/trajectory_sports
```

---

## Sterowanie / Controls

| Klawisz / Key | Akcja / Action |
|---|---|
| `1 / 2 / 3 / 4` | Wybór sportu (Archery/Basketball/Bowling/Darts) |
| `W / S` | Kąt strzału (Archery, Basketball) |
| `A / D` | Pozycja / Spin (Bowling), ruch (ogólny) |
| `Space` | Ładuj moc / Rzut / Strzał |
| `Escape` | Wyjście |

---

## Inspiracje / Inspirations

| Tytuł | Nawiązanie |
|---|---|
| **Wii Sports** (Nintendo, 2006) | Multi-sport minigame bundle |
| **Archer Maclean's Darts** (Amiga, 1989) | Wobbling crosshair darts |
| **10th Frame** (Konami, 1987) | Klasyczne kręgle z framescoring |
| **Street Hoops** | Charge-shot basketball |
| **Golden Tee** | Arcade power mechanic dla sportu |

---

## Lurek Engine API — kluczowe funkcje

| API | Zastosowanie |
|---|---|
| Tween (manualny) | Score counter animacje w każdym sporcie |
| Particle (manualny) | Impact sparks przy strzale (każdy sport) + pin knockdown |
| `lurek.camera.new` | Kamera inicjalizacja |
| `lurek.ui.loadLayoutFile` | Multi-screen TOML: per-sport HUD panels, round-end, final scores |
| `lurek.input.bind` | Power/aim/move + sport-select binding |
| `lurek.render.circle/rectangle/line` | Dartboard, kręgle, kosz, tarczę łuczniczą |

---

## Przydatność i unikalność / Showcase Value

**PL:** Trajectory Sports jest jedyną grą demonstrującą **4 różne mechaniki fizyki rzutowej** (balistyka łuku, grawitacja koszykówki, toczenie kręgielne, rzutki z figury-8) w jednym tytule. Pokazuje jak engine obsługuje przełączanie między kompletnie różnymi mini-grami z własnym stanem i particle/tween logiką.

**EN:** Trajectory Sports is the only demo featuring **4 distinct projectile physics models** (ballistic arc, basketball gravity, bowling rolling + pin chain reaction, darts figure-8 wobble) in a single title. It shows Lurek handling clean sport-state hot-swapping with isolated physics per mini-game and a shared scoring/medal layer.

### Podobne gry / Similar games to watch for overlap
- **Ski Jump** — también projectile, pero single-sport con fases de aproximación; diferente.
- **Track & Field** — multi-event bundle; but mash-based vs. trajectory-based.
- **Golf Classic** — też siła + kąt, ale pełna trasa golfowa vs. stacjonarne strzały.
- ✅ **Verdict:** Unikalne połączenie czterech fizyk w jednym tytule — **keep**.
