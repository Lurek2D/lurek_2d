# Rhythm Game — Lurek2D

> **Kategoria / Category:** Sports · Rhythm  
> **Uruchamianie / Run:** `cargo run -- content/games/sports/rhythm_game`

---

## O grze / About

**PL:** Czterotorowa gra rytmiczna ze scrollującymi nutami, oknami trafień (Perfect / Good / Miss), nutami hold i narastającym combo-multiplierem. Wybierz jeden z trzech utworów (Easy Beat, Medium Groove, Hard Rush), traf nuty w odpowiednim momencie i zdobądź wynik S.

**EN:** A four-lane rhythm game with scrolling notes, timing windows (Perfect / Good / Miss), hold notes, and an escalating combo multiplier. Choose one of three songs (Easy Beat, Medium Groove, Hard Rush), hit notes on beat, and aim for an S rank.

---

## Pętla rozgrywki / Gameplay Loop

1. **Song Select** — nawigacja ↑/↓, potwierdzenie Enter.
2. **Playing** — nuty spadają z góry; traf klawiszem D/F/J/K w momencie dotknięcia strefy trafienia.
   - **Perfect** → +300 × multiplier, leczenie life-baru.
   - **Good** → +100 × multiplier.
   - **Miss** → utrata życia, reset combo.
   - **Hold** — przytrzymaj klawisz przez czas trwania nuty.
3. **Results** — ocena S/A/B/C/F, max combo, liczba trafień.

Gra kończy się automatycznie po ukończeniu utworu lub gdy life-bar spadnie do zera.

---

## Uruchamianie / Run

```bash
cargo run -- content/games/sports/rhythm_game
```

---

## Sterowanie / Controls

| Klawisz / Key | Akcja / Action |
|---|---|
| `D` / Gamepad ○ | Lane 1 (czerwona) |
| `F` / Gamepad △ | Lane 2 (niebieska) |
| `J` / Gamepad □ | Lane 3 (zielona) |
| `K` / Gamepad ✕ | Lane 4 (żółta) |
| `↑ / ↓` | Nawigacja w menu |
| `Enter` | Potwierdź / Start |
| `Escape` | Pauza / Wyjście |

---

## Inspiracje / Inspirations

| Tytuł | Nawiązanie |
|---|---|
| **Dance Dance Revolution** (Konami, 1998) | 4-torowy układ, oceny Perfect/Good/Miss |
| **Guitar Hero** / **Rock Band** | Scrollujące nuty, hit-zone na dole ekranu |
| **osu!** | PC-centric input, combo multiplier |
| **beatmania IIDX** | Nuty hold, okna czasowe per-note |

---

## Lurek Engine API — kluczowe funkcje

| API | Zastosowanie |
|---|---|
| `lurek.particle.newSystem` | Hit-burst i combo-milestone particles |
| `lurek.tween.to` | Animowany life-bar i score counter |
| `lurek.ui.loadLayoutFile` | TOML HUD: score, combo, life-fill, progress |
| `lurek.input.bind` | Mapowanie 4 klawiszy lane + gamepad |
| `lurek.timer.getFPS` | Live FPS w HUD |
| `lurek.render.setBackgroundColor` | Pulsujące tło zsynchronizowane z combo |

---

## Przydatność i unikalność / Showcase Value

**PL:** Rhythm Game jest jedyną grą w bibliotece demonstrujacą **precyzyjny timing input** (okna ±30–60 ms), **combo-multiplier z 4 poziomami** oraz **połączenie tween + particle na każdym trafieniu**. To silny dowód że Lurek obsługuje gry zależne od klatki-po-klatce maszyny stanów.

**EN:** Rhythm Game is the only demo in the library that combines **frame-precise timing windows**, a **4-tier combo multiplier**, and **tween-driven score/life bars with per-hit particle bursts** — all in a single Lua script. It is a strong showcase for Lurek's particle, tween, and UI systems working in tight coordination.

### Podobne gry / Similar games to watch for overlap
- **Guitar Hero / DDR clones** — if a dedicated rhythm demo with custom chart import is added, this game becomes redundant.
- **Pinball** — also requires precise timing, but different enough in genre.
- ✅ **Verdict:** High showcase value; unique timing mechanic in current library — **keep**.
