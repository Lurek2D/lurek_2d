# 📐 Physics Puzzle — Structural Contraption Gravity Puzzle

**Category:** Strategy / Physics-Based Contraption  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Physics Puzzle** to wciągająca, dynamiczna gra logiczno-konstrukcyjna (Contraption Physics Puzzle), stanowiąca hołd dla kultowych gier, takich jak *The Incredible Machine*, *Fantastic Contraption* oraz *Crayon Physics Deluxe*. Zadaniem gracza jest zaprojektowanie drogi dla spadającej kulki i doprowadzenie jej bezpośrednio do zielonego kosza (Goal). Do dyspozycji masz limitowaną pulę elementów (klocki, pochylnie, platformy) o zróżnicowanych kształtach i wymiarach. Rozmieszczaj obiekty na planszy, obracaj je pod dowolnym kątem, a następnie zwolnij grawitację i obserwuj, jak sprężysta kulka toczy się, odbija i zjeżdża po Twojej konstrukcji. Szybkość dotarcia do celu decyduje o wielkości przyznanej nagrody punktowej!

### Pętla Rozgrywki i Mechaniki
1. **Wieloetapowe Łamigłówki (3 poziomy):** Gra oferuje 3 zróżnicowane wyzwania przestrzenne o rosnącej skali trudności:
   - **Level 1: "Reach the bucket" (Złap do kosza):** Prosty spadek z budżetem 4 elementów. Idealny na rozgrzewkę.
   - **Level 2: "Long drop" (Długi lot):** Głęboki spadek wymagający kaskadowego przekazywania kulki przez 5 elementów.
   - **Level 3: "Tight landing" (Ciasne lądowanie):** Wąska szczelina z dala od punktu spawnu, z budżetem 6 elementów.
2. **Katalog Klocków Konstrukcyjnych (Shapes Inventory):**
   - **Plank (Deska):** Wymiary: 100x10. Idealna do budowy mostów i płaskich platform spowalniających.
   - **Ramp (Rampa):** Wymiary: 120x14. Długa pochylnia nadająca kulce dużą prędkość.
   - **Block (Klocek):** Wymiary: 40x40. Służy do odbijania pod kątem prostym lub blokowania.
   - **Wedge (Klin):** Wymiary: 60x60. Trójkątny wspornik do zmiany kierunku.
3. **Tryb Projektowania (Build Mode):**
   - Na planszy wyświetla się półprzezroczysty podgląd aktualnie wybranego klocka.
   - **Tab:** Zmienia typ aktywnego klocka.
   - **Q / E:** Obraca klocek pod dowolnym kątem z krokiem 15 stopni w lewo lub w prawo.
   - **Left Click:** Stawia klocek w wybranym miejscu na planszy (jeśli mieścisz się w budżecie).
4. **Fizyka i Symulacja (Simulation Mode - Spacja):**
   - Naciśnięcie **Spacji** zwalnia kulkę z niebieskiego punktu startu i włącza silnik fizyczny grawitacji (GRAVITY = 400px/s^2).
   - Silnik gry precyzyjnie kalkuluje kolizje okręgu z prostokątami (Circle-Rect AABB Collisions) w czasie rzeczywistym. Kulka sprężyście odbija się od postawionych klocków oraz stałych ścian planszy z zachowaniem wektorów odbicia i tarcia.
   - **Czas i Wynik:** Im szybciej doprowadzisz kulkę do celu, tym większą premię punktową zdobędziesz (premia maleje z każdą sekundą symulacji). Jeśli kulka spadnie poniżej ekranu — przegrywasz i musisz skorygować układ klocków (R).

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Physics Puzzle** is a highly engaging, dynamics-driven logical construction puzzle (Contraption Physics Puzzle) built in Lurek2D as an elite tribute to creative classics like *The Incredible Machine*, *Fantastic Contraption*, and *Crayon Physics Deluxe*. Armed with a strictly capped budget of geometric shapes (planks, ramps, blocks), you must build structures to route a falling ball directly into a green target bucket. Strategically place items, rotate them at complex angles, and unleash gravity! Watch the ball bounce, roll, and slide along your ramps. Squeezing down simulation times to secure high-speed completions demands spatial reasoning, rewarding you with maximum scores!

### Gameplay Loop & Mechanics
1. **Dynamic Levels Suite (3 challenges):** Tackle three spatial conundrums with distinct layouts:
   - **Level 1: "Reach the bucket":** An introductory drop with a 4-shape construction allowance.
   - **Level 2: "Long drop":** A deep drop requiring cascading transfers using a 5-shape budget.
   - **Level 3: "Tight landing":** A narrow drop vector located across the board, requiring a 6-shape budget.
2. **Construction Palette (Shapes Inventory):**
   - **Plank:** Dimensions: 100x10. Perfect for bridging gaps and deceleration pads.
   - **Ramp:** Dimensions: 120x14. Heavy slope deck imparting high velocity.
   - **Block:** Dimensions: 40x40. Useful for blocking and triggering right-angle bounces.
   - **Wedge:** Dimensions: 60x60. Triangle wedges for acute angle redirection.
3. **Drafting Phase (Build Mode):**
   - A translucent preview of the chosen shape floats beneath the cursor.
   - **Tab:** Cycles through active shape selections.
   - **Q / E:** Rotates the active preview in increments of 15° clockwise or counter-clockwise.
   - **Left Click:** Places the shape onto the canvas (restricted by level budgets).
4. **Gravity Simulation (Run Mode - Space):**
   - Press **Space** to deploy the blue ball from its spawn portal, triggering gravity simulation (GRAVITY = 400px/s^2).
   - The custom physics engine calculates real-time Circle-to-Rectangle AABB collisions. The ball bounces realistically off walls, blocks, and planks, preserving bounce vectors and friction.
   - **Time Attack Scores:** Reaching the Goal (green bucket) rewards scores inversely proportional to simulation elapsed times (favouring rapid trajectories). Falling below the board floor triggers failure, prompting a deconstruction retry (R).

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/physics_puzzle
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB (Lewy Klik)** | Postaw klocek | Umieszcza wybrany, obrócony klocek w miejscu kursora myszy. |
| **Tab** | Następny kształt | Przełącza aktywny kształt klocka (Plank -> Ramp -> Block -> Wedge). |
| **Q / E** | Obróć klocek | Obraca trzymany klocek o 15 stopni odpowiednio w lewo (Q) lub w prawo (E). |
| **Space (Spacja)** | Uruchom symulację | Zwalnia kulkę z punktu startowego i uruchamia fizykę grawitacji. |
| **R** | Resetuj / Edycja | Czyści postawione obiekty (w trybie edycji) lub przywraca kulkę do portalu. |
| **N** | Następny poziom | Przechodzi do kolejnego wyzwania po udanym zaliczeniu obecnego. |
| **Esc** | Wyjście | Zamyka bezpiecznie aplikację. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **The Incredible Machine (1992) by Dynamix**
  - *Opis powiązania*: Bezpośrednie mechaniczne powiązanie z gatunkiem maszyn Rube Goldberga. Układanie statycznych desek, pochylni i bloków w celu pokierowania dynamicznym ruchem spadającej kuli z wykorzystaniem zasad grawitacji i odbić.
- **Fantastic Contraption (2008) by Colin Northway**
  - *Opis powiązania*: Pętla oparta na budżecie klocków do postawienia oraz celowaniu kulą w okrągły, zielony obszar docelowy (Goal), co zmusza do precyzyjnych testów ułożeń.
- **Crayon Physics Deluxe (2009) by Petri Purho**
  - *Opis powiązania*: Wykorzystanie klocków geometrycznych i sprężystej fizyki odbić kulki, w której prędkość i kreatywność tras decyduje o finalnym sukcesie inżynieryjnym.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Physics Puzzle to wspaniały popis precyzyjnej matematyki zderzeniowej w Lurek2D:
- `lurek.input` – Obsługa pozycji myszy w czasie rzeczywistym w celu sterowania wskaźnikiem klocka, mapowanie klawisza Tab dla kształtów oraz Q/E do płynnego obracania.
- `lurek.render` – Generowanie dynamicznych kształtów wektorowych (niebieska kulka, zielony kosz wyjściowy, brązowe klocki za pomocą `rect` i `circ`), rysowanie linii i wielokolorowego interfejsu HUD.
- `lurek.timer` – Odmierzanie czasu delta (`dt`) niezbędnego do płynnej, bezbłędnej integracji fizyki grawitacji (400px/s^2).
- `lurek.event` – Wyjście z gry przy naciśnięciu Esc.
- **Własny Silnik Fizyki Kolizji (Circle-Rect AABB Physics):** Zaawansowany moduł matematyczny w języku Lua, który precyzyjnie wylicza najkrótszy dystans od środka kulki do krawędzi klocka (`collide_circle_rect`), generuje wektory normalne zderzenia, głębokość penetracji i precyzyjnie odbija prędkości z tłumieniem (`* 0.7`), dając idealnie sprężysty efekt odbicia.
- **Aż Trzy Systemy Cząsteczek (Particles):**
  - *Ślad kulki (Ball Trail)*: Subtelna, niebieska chmurka cząsteczek pozostawiana za kulką w locie, wizualizująca jej trasę (tor lotu).
  - *Złote Fajerwerki (Win Burst)*: Potężna, kolista eksplozja 80 złotych i pomarańczowych cząsteczek rozświetlająca kosz w momencie wygranej.
  - *Iskry Zderzeniowe (Bounce Sparks)*: Małe, dynamiczne żółte iskierki uwalniające się w punkcie zderzenia kulki z klockami przy każdym odbiciu.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Imponujący pokaz pisania niestandardowych silników fizycznych w Lua dla Lurek2D. Udowadnia, że silnik bezproblemowo pozwala na pisanie własnych, zoptymalizowanych systemów kolizyjnych (Circle vs AABB) i sprężystości, integrowanie śladów cząsteczek w czasie rzeczywistym, obsługę stanów (Place / Simulating) oraz dynamiczne odmierzanie czasu premii punktowych.
- **Unikalność (Uniqueness):** Jedyny symulator konstrukcyjny z zaawansowaną fizyką odbić i toczenia. Zmusza gracza do twórczego dopasowywania kątów odbić klocków, co reprezentuje wysoce satysfakcjonujący, edukacyjny wymiar strategiczny.
- **Podobne gry (Similar Games):** Gra dzieli fizyczny i techniczny charakter z `bridge_builder` oraz `worms_artillery`, ale jako jedyna oferuje całkowitą swobodę układania obracanych klocków na pustej planszy w celu pokierowania toczącym się obiektem.
