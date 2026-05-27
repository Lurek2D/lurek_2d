# 🏰 Maze Defense — Grid-Based Maze Tower Defense

**Category:** Strategy / Tower Defense  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Maze Defense** to wciągająca, hybrydowa gra strategiczna typu Tower Defense (Maze-building Tower Defense), mocno inspirowana klasykami takimi jak *Desktop Tower Defense* oraz *Fieldrunners*. W odróżnieniu od tradycyjnych gier tego gatunku, wrogowie nie poruszają się po z góry narzuconej ścieżce. Plansza to pusta, otwarta siatka, na której **to Ty budujesz labirynt**! Używaj murów obronnych (Walls) oraz wieżyczek strzelających (Towers), by wydłużyć drogę wrogów z punktu startowego do bazy. Wykorzystaj algorytm przeszukiwania BFS w czasie rzeczywistym, by przechytrzyć system, optymalizować zasięg wież, odpierać coraz silniejsze fale uderzeniowe i chronić swoją bazę przed zniszczeniem!

### Pętla Rozgrywki i Mechaniki
1. **Siatka Taktyczna (Tactical Grid):** Plansza ma rozmiar 20x14 kafelków. Punkt startowy przeciwników (Spawn) znajduje się po lewej stronie planszy (kolumna 1, wiersz 7), a Twoja baza po prawej (kolumna 20, wiersz 7).
2. **Budowa Labiryntu (Build Phase):**
   - **Mury (Walls - Lewy Klik):** Koszt: 10g. Podstawowy element blokujący ruch wrogów i tworzący ścieżki labiryntu.
   - **Wieżyczki (Towers - Prawy Klik):** Koszt: 25g. Wieże bojowe o zasięgu strzału równym 3 kafelkom (114px). Strzelają pociskami w najbliższego wroga, zadając 8 obrażeń (cooldown 0.8s).
   - **Inteligentne Blokowanie (Valid BFS Paths):** Gra uniemożliwi Ci postawienie muru lub wieży, jeśli ich umieszczenie całkowicie zamknęłoby jedyną drogę do bazy (algorytm BFS natychmiast wykrywa brak ścieżki i anuluje transakcję).
3. **Płynna Re-kalkulacja Ścieżki:** Po każdym pomyślnym postawieniu muru lub wieżyczki, gra natychmiast przelicza najkrótszą drogę za pomocą algorytmu BFS i wizualnie podświetla ją ciemnozielonym kolorem na planszy.
4. **Faza Bitwy (Combat Phase - Spacja):**
   - Po naciśnięciu **Spacji** rozpoczyna się faza walki. Z portalu wylewa się fala czerwonych przeciwników.
   - Siła fal rośnie: z każdą falą wrogowie mają więcej zdrowia (HP: 15 + fala * 8) oraz poruszają się szybciej (speed: 60 + fala * 5).
   - Pokonanie wroga daje złoto (5g + fala) oraz +10 punktów wyniku. Śmierć wroga wyzwala eksplozję pomarańczowych cząsteczek.
   - Przeciwnicy, którzy pomyślnie przedrą się przez labirynt do bazy, zabierają 1 punkt życia (lives). Rozpoczynasz z pulą 20 serc. Spadek do 0 oznacza Game Over.
5. **Warunek Zwycięstwa:** Przetrwanie **5 coraz trudniejszych fal** bojowych zapewnia ostateczne zwycięstwo (Victory).

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Maze Defense** is a highly engaging, tactical hybrid Tower Defense game (Maze-building Tower Defense) heavily inspired by web-classic *Desktop Tower Defense* and the *Fieldrunners* franchise. Unlike traditional defense games, the invaders do not follow a fixed, pre-determined road. The battlefield is a wide-open grid where **you build the maze**! Deploy solid stone barricades (Walls) and defensive cannons (Towers) to actively divert, slow down, and extend the invaders' travel times from their spawn to your base. Leveraging real-time Breadth-First Search (BFS) pathfinding, design choke-points, optimize your firing arcs, and survive 5 waves of hostile pressure to protect your base from annihilation!

### Gameplay Loop & Mechanics
1. **Tactical Combat Grid:** The arena is composed of a 20x14 tile grid. The enemy entrance portal (Spawn) sits on the left edge (Col 1, Row 7), while your Command Base is stationed on the right edge (Col 20, Row 7).
2. **Construction Mode (Build Phase):**
   - **Barricades (Walls - Left Click):** Costs 10g. The baseline structure used to funnel enemies and establish winding pathways.
   - **Cannons (Towers - Right Click):** Costs 25g. Active defensive structures with a firing radius of 3 tiles (114px). Fires yellow laser energy at the leading target, dealing 8 damage (0.8s fire rate cooldown).
   - **Anti-Blocking Safety:** The engine runs a BFS lookup instantly upon placement. If a wall or tower would completely seal off the base (leaving 0 legal paths), the build is rejected, reverting the grid tile and saving your gold.
3. **Dynamic Path Highlighting:** Upon every successful build placement, the BFS pathfinder recalculates the shortest path to the base, immediately rendering a dark green path highlight along the newly formed route.
4. **Active Invasion Mode (Combat Phase - Space):**
   - Press **Space** to conclude building and trigger the invasion. A wave of red square invaders marches along the computed path.
   - Scaling Invader Threats: With each progressive wave, enemy health points scale (HP: 15 + wave * 8) and movement speeds accelerate (speed: 60 + wave * 5).
   - Slaying invaders awards gold bounties (5g + wave) and +10 score points. Defeated invaders explode in a flash of fiery orange particles.
   - Invaders reaching your Command Base subtract 1 Life point. You start with 20 Lives. Dropping to 0 triggers an immediate system breach (Game Over).
5. **Victory Threshold:** Survive **5 increasingly relentless waves** of invasions to secure absolute victory.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/maze_defense
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB (Lewy Klik)** | Postaw Mur (Wall) | Wznosi kamienną ścianę blokującą w miejscu kursora myszy (Koszt: 10g). |
| **RMB (Prawy Klik)** | Postaw Wieżę (Tower) | Wznosi aktywną wieżyczkę obronną w miejscu kursora (Koszt: 25g). |
| **Space (Spacja)** | Uruchom Falę (Start Wave) | Zamyka tryb budowy, pobiera nagrodę za turę i wzywa kolejną falę wrogów. |
| **Esc** | Wyjście | Zamyka bezpiecznie aplikację. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Desktop Tower Defense (2007) by Paul Preece**
  - *Opis powiązania*: Bezpośrednie odwzorowanie pętli rozgrywki. Maze Defense czerpie stamtąd system budowania labiryntu na otwartym polu, w którym wieże i mury stawia się bezpośrednio pod nogi wrogom, a także konieczność zachowania przynajmniej jednej poprawnej ścieżki do wyjścia.
- **Fieldrunners (2008) by Subatomic Studios**
  - *Opis powiązania*: System kafelków siatki z widocznymi, maszerującymi falami wrogów o rosnących paskach życia, oraz wieżyczki strzelające liniowymi pociskami do najbliższych celów w zasięgu.
- **Defense Grid (Seria)**
  - *Opis powiązania*: Wizualne podświetlanie najkrótszej drogi (PATH) w czasie rzeczywistym, co pomaga graczowi zobaczyć trasę wrogów jeszcze przed wciśnięciem przycisku startu.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Maze Defense demonstruje bogatą paletę zaawansowanych możliwości logicznych Lurek2D:
- `lurek.input` – Wzorcowa obsługa lewego i prawego przycisku myszy w celu pozycjonowania struktur w siatce kafelków (`place_wall`, `place_tower`), oraz mapowanie klawisza Space dla fali.
- `lurek.render` – Generowanie dynamicznych kafelków planszy (droga wrogów, wieżyczki, portale i wskaźnik najazdu kursora za pomocą `rect` i `circ`), rysowanie laserowych pocisków i interfejsu HUD.
- `lurek.timer` – Precyzyjne odmierzanie delta time do płynnej animacji ruchu wrogów po kafelkach oraz zliczanie klatek (FPS).
- `lurek.event` – Wyjście z gry przy naciśnięciu Esc.
- **Zaawansowany Algorytm Szukania Drogi (Lua BFS Pathfinder):** Pełna, wydajna implementacja algorytmu Breadth-First Search w języku Lua, która błyskawicznie bada spójność grafu kafelków przy każdej próbie budowy, uniemożliwiając zablokowanie drogi i dynamicznie wytyczając ścieżkę.
- **Rozpryski Cząsteczek (Particles):** Wdrożenie zintegrowanego systemu cząsteczek (`particle_sys`) emitującego dynamiczne, gasnące gejzery ognistych iskier w momencie zniszczenia każdego przeciwnika.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Niezwykle ważny pokaz taktycznego algorytmu szukania drogi (BFS Pathfinding) zintegrowanego bezpośrednio z mechaniką gry. Pokazuje programistom, jak łatwo połączyć logikę grafów w Lua z silnikiem Lurek2D, jak obsłużyć dynamiczne pozycjonowanie wrogów na zakrętach ścieżki (progress interpolation) oraz jak zarządzać fazami gry (Build / Combat).
- **Unikalność (Uniqueness):** Jedyny Tower Defense o charakterze labiryntowym (Maze-building TD) w portfolio. Zmusza gracza do twórczego, przestrzennego projektowania najdłuższych możliwych tras i korytarzy śmierci (kill-zones), co stanowi wspaniałe wyzwanie strategiczne.
- **Podobne gry (Similar Games):** Gra dzieli elementy obrony wież z `tower_defense` oraz `maze_defense` (tradycyjne TD), ale jako jedyna oferuje pełną swobodę wznoszenia murów blokujących ruch na otwartym polu i dynamiczny algorytm BFS.
