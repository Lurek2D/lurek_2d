# 🏎️ Drift Racing — Top-Down Racing Physics

**Category:** Sports / Racing  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Drift Racing** to dynamiczna gra wyścigowa z widokiem z góry (Top-Down Racer), stanowiąca hołd dla kultowych zręcznościówek retro takich jak seria *Micro Machines* oraz klasyczne gry wyścigowe z automatów typu *Super Off Road*. Zasiądź za sterami tuningowanego bolidu i zmierz się z dwoma inteligentnymi rywalami AI na 3 trasach o rosnącym stopniu trudności. Kluczem do sukcesu nie jest tylko prędkość, ale precyzyjny poślizg kontrolowany (drifting) na zakrętach, zbieranie doładowań nitro (boost pads) oraz unikanie spowalniającego pobocza. Gra stanowi spektakularną demonstrację zaawansowanej fizyki jazdy 2D, dynamicznego śledzenia śladów opon, systemów cząsteczek dymu oraz płynnej wirtualnej kamery śledzącej pojazd.

### Pętla Rozgrywki i Mechaniki
1. **Model Fizyki i Poślizgu (Drifting Physics):**
   - Samochód posiada realistyczną fizykę wektorową uwzględniającą przyspieszenie, hamowanie, tarcie oraz poślizg boczny.
   - **Driftowanie:** Wjechanie w zakręt z dużą prędkością (powyżej 150 px/s) przy jednoczesnym skręcaniu inicjuje poślizg kontrolowany. Kąt poślizgu (drift angle) rośnie płynnie, a opony pozostawiają trwałe czarne ślady dymu na asfalcie.
   - Drifting zasila Twój licznik punktów poślizgu (Drift Score).
2. **Rywalizacja AI i Checkpointy:**
   - Ścigasz się z 2 wrogimi kierowcami AI o zróżnicowanych profilach jazdy i prędkościach bazowych.
   - Aby ukończyć okrążenie, musisz zaliczyć wszystkie punkty kontrolne (checkpoints) w odpowiedniej kolejności, co zapobiega skracaniu trasy. Wyścig trwa 3 okrążenia.
3. **Doładowania Nitro (Boost Pads):**
   - Rozmieszczone na trasie żółte platformy dają doładowanie nitro.
   - Po zebraniu naciśnij **Spację**, aby aktywować nitro (Boost) — samochód gwałtownie przyspieszy o 150%, wyzwalając płomienie z rury wydechowej.
4. **Trzy Zróżnicowane Trasy:**
   - **Coastal Loop (Łatwa):** Klasyczny owal z łagodnymi zakrętami.
   - **Mountain Pass (Średnia):** Kręta górska serpentyna wymagająca ciągłych ugięć wektora jazdy.
   - **Drift City (Trudna):** Ciasny miejski tor z ostrymi szykanami i nawrotami.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Drift Racing** is a high-speed top-down racing simulator celebrating classic arcade blockbusters like *Micro Machines* and coin-op icons like *Super Off Road*. Take the wheel of a high-performance racing car and out-maneuver two challenging AI opponents across 3 winding asphalt tracks. In this game, sliding sideways at extreme velocities is the key to maintaining momentum: execute perfect drifts around corners to accumulate high drift points, dodge speed-dampening grass shoulders, and deploy yellow rocket Boost pads to surge ahead. Featuring real-time vector traction calculations, persistent skid marks, and smooth spring camera follow-loops, this is Lurek2D's ultimate vehicle physics showcase!

### Gameplay Loop & Mechanics
1. **Dynamic Vector Drift Physics:**
   - Features a robust 2D vehicle physics model factoring in thrust, braking, tire friction, and lateral sliding forces.
   - **Initiating Drift:** Steer hard into corners at high speeds (exceeding 150px/s) to break traction. Your drift angle scales dynamically, emitting tire smoke particles and drawing physical skid marks on the road.
   - Drifting continuously rewards you with drift score multipliers.
2. **AI Competition & Checkpoint Gates:**
   - Race against 2 distinct AI drivers equipped with customized target-chasing algorithms and simulated steering wobble.
   - You must navigate through a sequence of checkpoint gates to register a lap, preventing short-cuts. The race runs for 3 full laps.
3. **Yellow Boost Pads:**
   - Collect yellow pads to charge your Nitro reserves.
   - Tap **Space** to engage Boost — unleashing a 1.5x velocity multiplier accompanied by jet fire particles from the exhausts.
4. **Three Specialized Tracks:**
   - **Coastal Loop (Easy):** A gentle oval track for beginner speed runs.
   - **Mountain Pass (Medium):** High-elevation curves testing your entry speed.
   - **Drift City (Hard):** Tight metropolitan turns and hairpins requiring absolute drift mastery.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/sports/drift_racing
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **W / Up** | Gaz (Accelerate) | Przyspiesza samochód do przodu (Aktywuje ciąg silnika). |
| **S / Down** | Hamulec / Wsteczny (Brake) | Hamuje samochód lub cofa (zmniejsza prędkość). |
| **A / Left** | Skręt w lewo (Steer Left) | Skręca koła pojazdu w lewą stronę. |
| **D / Right** | Skręt w prawo (Steer Right) | Skręca koła pojazdu w prawą stronę. |
| **Space (Spacja)** | Nitro (Activate Boost) | Zużywa ładunek nitro, dając 150% prędkości na 2 sekundy. |
| **Esc** | Wyjście (Quit) | Zamyka grę w bezpieczny sposób. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Micro Machines (Seria) by Codemasters**
  - *Opis powiązania*: Bezpośrednie źródło widoku z góry (Top-Down perspective), miniaturowych zbalansowanych tras o stałej szerokości drogi, spowalniającego pobocza trawy oraz systemu kamery śledzącej lidera.
- **Ivan 'Ironman' Stewart's Super Off Road (1989) by Leland Corporation**
  - *Opis powiązania*: Wykorzystanie platform doładowań nitro (Boosts) dawkowanych przyciskiem Space oraz dynamicznych poślizgów kół na zakrętach.
- **Ridge Racer**
  - *Opis powiązania*: Koncepcja zbierania punktów za widowiskowe, długie slajdy bokiem przez zakręty (Drift Score).

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

- `lurek.ui` – Wczytywanie zautomatyzowanego interfejsu TOML (`ui.toml`) z dynamicznymi etykietami prędkości, numeru okrążenia, czasu wyścigu, licznika punktów driftu oraz ekranu wyników końcowych.
- `lurek.input` – Precyzyjna obsługa wektora wejściowego klawiatury dla jednoczesnego przyspieszania i skręcania bez opóźnień.
- `lurek.window` / `lurek.event` – Płynne skalowanie okna, wyświetlanie dynamicznego FPS w tytule okna oraz bezszwowe wyjście przy Esc.
- **Trzy Niezależne Systemy Cząsteczek i Ślady Opon (Multiple Particles & Trails):**
  - *Dym spod opon (Tire Smoke)*: Szare chmurki cząsteczek dymu ulatniające się spod kół podczas poślizgu.
  - *Płomień nitro (Boost Flame)*: Jasnopomarańczowe i żółte rozbłyski ognia tryskające z tyłu wydechu przy nitro.
  - *Rozbłyski checkpointu (Checkpoint Flash)*: Błyszczące gwiazdki wyzwalane przy zaliczeniu punktu kontrolnego.
  - *Trwałe ślady opon (Persistent Skidmarks)*: Tablica rysująca na asfalcie ciemne ślady opon w strefie poślizgu.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Niezwykle zaawansowana demonstracja fizyki kół i tarcia 2D. Pokazuje, jak w Lua zaimplementować wektorowy rozkład sił (sideway slip angle), kontrolowany dryf kamery wirtualnej z wygładzeniem (lerp camera smoothing) oraz system trwałego bufora śladów opon bez obciążania pamięci.
- **Unikalność (Uniqueness):** Jedyna gra wyścigowa z widokiem z góry z pełną symulacją tarcia nawierzchni, poślizgu kontrolowanego, checkpointami i przeciwnikami AI.
- **Podobne gry (Similar Games):** Brak bezpośrednich duplikatów. Dzieli top-down widok z `colony_sim` i `wargame`, jednak jej stricte zręcznościowy, zorientowany na fizykę charakter czyni ją całkowicie unikalną perłą w portfolio.
