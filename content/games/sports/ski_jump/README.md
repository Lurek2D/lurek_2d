# Ski Jump — Lurek2D

> **Kategoria / Category:** Sports · Winter  
> **Uruchamianie / Run:** `cargo run -- content/games/sports/ski_jump`

---

## O grze / About

**PL:** Widokowa z boku gra skokowa w narciarstwie klasycznym. Gracz przechodzi przez trzy fazy: **rozbieg** (kucnięcie + przyspieszenie), **lot** (wychylenie ciała dla optymalnego lotu), **lądowanie** (Telemark). Trzy skocznie (Small 90m / Normal 120m / Large 150m), trzy rundy, pięciu sędziów oceniających styl.

**EN:** A side-view ski jumping game with three distinct phases: **approach** (crouch for speed), **airborne** (lean forward/back for lift vs. drag), and **landing** (Telemark bonus). Three hill sizes (Small K90 / Normal K120 / Large K150), three rounds, five judges scoring style.

---

## Pętla rozgrywki / Gameplay Loop

1. **Title** — wybór skoczni (1/2/3), start `Space`.
2. **Approach** — trzymaj `D` (kucnięcie) dla większej prędkości; naciśnij `Space` przy końcu najazdu.
3. **Airborne** — `W` = wychylenie do przodu (lift), `S` = wychylenie do tyłu; dopasuj kąt do trajektorii lotu.
4. **Landing** — jakość = różnica kąta ciała vs. stoку; `Space` = bonus Telemark.
5. **Score** — sędziowie ujawniają oceny (1 co 0.4s); wynik = dystans + średnia sędziów.
6. **Final** — suma 3 rund.

---

## Uruchamianie / Run

```bash
cargo run -- content/games/sports/ski_jump
```

---

## Sterowanie / Controls

| Klawisz / Key | Akcja / Action |
|---|---|
| `1 / 2 / 3` | Wybór skoczni (Small/Normal/Large) |
| `D` | Kucnięcie na najezdzie |
| `Space` | Skok (timing!) / Telemark |
| `W / S` | Wychylenie w locie (forward/back) |
| `Escape` | Wyjście |

---

## Inspiracje / Inspirations

| Tytuł | Nawiązanie |
|---|---|
| **Ski Jump Challenge** (PC, 2000) | Trzy fazy, K-point, sędziowie |
| **Deluxe Ski Jump 4** (Flash, 2008) | Side-view, wind factor, lean mechanic |
| **Winter Games** (Epyx, C64, 1985) | Multidyscyplinarne zimowe sportowe |
| **Pitstop II** | Fazowy podział akcji gracza |

---

## Lurek Engine API — kluczowe funkcje

| API | Zastosowanie |
|---|---|
| `lurek.particle.newSystem` (manualne) | Śnieg na najezdzie, rozprysk przy lądowaniu, confetti |
| `lurek.render.push/translate/rotate/pop` | Obrót narciarza przy koziołku (tumble) |
| `lurek.render.triangle` | Góry w tle, drzewa |
| `lurek.ui.loadLayoutFile` | TOML HUD: prędkość, czas lotu, wiatr, oceny sędziów |
| `lurek.tween` (lerp) | Animowany wskaźnik lean, wygładzony zoom kamery |
| `lurek.timer.getFPS` | FPS w UI |

---

## Przydatność i unikalność / Showcase Value

**PL:** Ski Jump jest jedyną grą w bibliotece z **trójfazową logiką sportową** (najazd → lot → lądowanie), **dynamicznym wiatrem**, **systemem sędziów** ujawniającym wyniki z opóźnieniem oraz **matrycą transformacji renderera** (push/rotate/pop) do obrotu postaci. Doskonały dowód na to, że Lurek obsługuje złożone stany fizyczne w Lua.

**EN:** Ski Jump is the only demo with a **three-phase sport loop**, **wind physics** affecting flight trajectory, **five-judge reveal system** with animated score disclosure, and **render matrix transforms** (push/rotate/pop) for tumble animation — all in pure Lua. It is an excellent showcase for multi-phase game state management.

### Podobne gry / Similar games to watch for overlap
- **Trajectory Sports** — also uses projectile physics, but no approach phase or judge scoring.
- **Track & Field** — multi-event structure, but no winter theme or lean mechanic.
- ✅ **Verdict:** Unikalna mechanika trójfazowa — **keep**.