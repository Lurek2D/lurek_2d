# 🕹️ Pinball — Classic Arcade Pinball

**Category:** Sports / Arcade Pinball  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Pinball** to niezwykle dynamiczna, klasyczna zręcznościowa gra w pinball z pionowym stołem, będąca bezpośrednim hołdem dla kultowego *3D Pinball: Space Cadet* (Windows 95) oraz klasycznych fizycznych flipperów z salonów gier. Gracz kontroluje metalową kulkę za pomocą dwóch ruchomych łapek (flippers) na dole planszy. Cel gry to utrzymanie kulki na stole, odbijanie jej od sprężystych zderzaków (bumpers), trafianie w sekwencje celów (targets) i rampy, oraz nabijanie jak najwyższego wyniku dzięki combo-mnożnikom. Gra w mistrzowski sposób demonstruje fizykę sprężystych zderzeń kołowych, wektory odbić od odcinków, zaawansowane animacje obrotu łapek (flippers rotation angles) i dynamiczne cząsteczki świetlne.

### Pętla Rozgrywki i Mechaniki
1. **Wystrzał i Plunger (Launch Plunger):**
   - Gra rozpoczyna się od załadowania wyrzutnika (Plunger) w prawej rynnie.
   - Przytrzymaj **Spację**, by rozciągnąć sprężynę wyrzutnika (ładowanie paska mocy 0% - 100%), a następnie puść, by wystrzelić kulkę z zawrotną prędkością na stół!
2. **Łapki i Fizyka Odbić (Flippers & Physics):**
   - Kontroluj lewą łapkę za pomocą **A / Left** oraz prawą za pomocą **D / Right**.
   - Kąty łapek zmieniają się płynnie w zakresie od 30° do -30°. Uderzenie kulki w trakcie ruchu łapki nadaje jej dodatkowy pionowy pęd (flipper boost).
3. **Elementy Stołu i Mnożniki (Table Obstacles):**
   - **Bumpers (Zderzaki - 3 sztuki):** Okrągłe, aktywne zderzaki w górnej części stołu. Trafienie w zderzak nadaje kulce 150% prędkości bocznej, wyzwala jasny rozbłysk i dodaje 100 pkt.
   - **Bumper Combo:** Uderzenie kilku zderzaków pod rząd bez dotykania łapek aktywuje mnożnik wyniku (Multiplier: 2x → 3x → 4x).
   - **Targets (Cele - 5 sztuk):** Trafienie chowa cel i daje 50 pkt. Zestrzelenie wszystkich 5 celów wyzwala cząsteczki i przyznaje **bonus 500 pkt**, po czym cele się resetują.
   - **Ramps (Rampy - 2 sztuki):** Wjazd na skośne szyny ramp daje 200 pkt i pozwala kulce spłynąć z powrotem na dół.
4. **Kule, TILT i Wyniki:**
   - Masz do dyspozycji 3 kule. Zdobycie 5000 punktów przyznaje **Extra Ball** (dodatkowe życie).
   - **TILT (T):** Pozwala na fizyczne potrząśnięcie (nudge) stołem, co modyfikuje tor lotu kulki i może uratować ją przed wpadnięciem w szczelinę (drain), ale grozi zablokowaniem flipperów.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Pinball** is a high-speed, physically simulated vertical pinball table standing as a direct mechanical tribute to the legendary *3D Pinball: Space Cadet* (Windows 95) and classic retro coin-op cabinets. Launch a heavy steel ball onto a hazard-filled table using a spring-loaded plunger, flip twin physical flippers to keep the ball in active play, and rack up high scores by triggering bumpers, hitting target corridors, and rolling up ramps. Features an escalating combo multiplier system, tilt nudge physics, extra ball milestones, and dazzling impact light sparkles. This project represents Lurek2D's premier masterclass in complex line-segment collision checking, spring physics, and flipper rotation tweens!

### Gameplay Loop & Mechanics
1. **Spring-Loaded Plunger Launch:**
   - Ball play begins in the right launch lane.
   - Hold **Space** to compress the plunger spring (charging your launch meter from 0% - 100%), then release to shoot the ball onto the field.
2. **Flipper Geometry & Deflection Boosts:**
   - Control the left flipper with **A / Left** and the right with **D / Right**.
   - Flippers sweep smoothly between resting 30° angles and active -30° upward strokes. Striking the ball mid-swing applies an extra kinetic velocity boost.
3. **Table Hazards & Score Multipliers:**
   - **Bumpers (3):** Circular obstacles at the top. Striking a bumper repels the ball at 1.5x speed, flashes white, and grants 100 pts.
   - **Bumper Combo:** Chaining multiple bumper bounces without touching the flippers advances your score multiplier (2x → 3x → 4x).
   - **Drop Targets (5):** Hitting a target knocks it down (50 pts). Clearing all 5 targets awards a **500 pt bonus** and resets the array.
   - **Ramps (2):** Diagonal rolling channels that reward 200 pts upon successful entry.
4. **Extra Balls & Table Nudging (TILT):**
   - You start with 3 balls. Crossing the 5,000 pt threshold awards an **Extra Ball**!
   - **Nudge/TILT (T):** Physically shakes the table, shifting the ball's coordinates to save it from the drain, but overuse risks locking the paddles!

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/sports/pinball
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **Space (Spacja - Przytrzymaj)** | Cofnij plunger (Pull Plunger) | Cofa tłok wyrzutnika, naciągając sprężynę (0% - 100%). |
| **Space (Spacja - Puść)** | Wypuść plunger (Release) | Zwalnia sprężynę, wystrzeliwując kulkę na stół. |
| **A / Left Arrow** | Lewa łapka (Left Flipper) | Aktywuje lewy flipper (unosi łapkę w górę). |
| **D / Right Arrow** | Prawa łapka (Right Flipper) | Aktywuje prawy flipper (unosi łapkę w górę). |
| **T** | Szturchnięcie (Nudge / TILT) | Potrząsa stołem, delikatnie zmieniając wektor ruchu kulki. |
| **Esc** | Wyjście (Quit) | Zamyka grę w bezpieczny sposób. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **3D Pinball: Space Cadet (1995) by Maxis / Microsoft**
  - *Opis powiązania*: Wyraźna inspiracja pionowym układem stołu, obecnością trzech bumperów w trójkątnym układzie na górze, systemem celów do zestrzelenia na środku planszy oraz Plungerem w bocznej rynnie.
- **Pinball Dreams (1992) by Digital Illusions (DICE)**
  - *Opis powiązania*: Wdrożenie mechaniki combosów (Multiplier) za uderzenia w zderzaki oraz charakterystyczne rampy podające kulkę.
- **Williams & Bally Pinball Machines**
  - *Opis powiązania*: Koncepcja TILT oznaczająca dyskwalifikację lub ostrzeżenie po zbyt mocnym potrząśnięciu stołem przez gracza.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

- `lurek.ui` – Dynamiczny interfejs TOML (`ui.toml`) wyświetlający aktualny wynik z efektem powolnego zliczania (Score rolling), mnożnik combo, liczbę kul oraz High Score.
- `lurek.input` – Precyzyjna obsługa wejścia klawiatury w czasie rzeczywistym (wykrywanie stanów przytrzymania spacji i kliknięć flipperów).
- `lurek.window` / `lurek.event` – Inicjalizacja stabilnej rozdzielczości pionowej, śledzenie FPS w tytule okna oraz bezszwowe wyjście przy Esc.
- **Trzy Niezależne Systemy Cząsteczek (Multiple Particle Systems):**
  - *Rozbłysk zderzaka (Bumper hit)*: Rozchodzące się żółte gwiazdki i iskry wyzwalane przy silnym odbiciu od zderzaka.
  - *Cząsteczki celu (Target clear)*: Zielonkawe rozbłyski cząsteczek przy schowaniu celu.
  - *Wypadnięcie kuli (Ball drain)*: Pomarańczowo-czerwona eksplozja cząsteczek oznaczająca stratę kuli w dolnym slocie.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Prawdziwy majstersztyk matematyki fizycznej 2D w skryptach Lua. Gra implementuje zaawansowane rzutowanie wektorów ruchu na linie (Point-to-segment distance projection) w celu sprawnego wykrywania zderzeń z skośnymi rampami i ruchomymi flipperami, oraz dynamiczną fizykę grawitacji i sprężystości.
- **Unikalność (Uniqueness):** Jedyna gra w portfolio o charakterze fizycznej zręcznościówki pinballowej z dynamicznymi ruchomymi barierami odbijającymi (flippers).
- **Podobne gry (Similar Games):** Dzieli charakter fizyczny i odbicia z `golf_classic` oraz `physics_puzzle`, lecz wyróżnia się unikalną dynamiką pionową (stałe spadanie kulki pod wpływem grawitacji) i potrzebą błyskawicznego operowania łapkami.
