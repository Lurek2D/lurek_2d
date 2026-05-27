# 🤖 Logic Game — Autonomous Robot Programming Puzzle

**Category:** Strategy / Logic Coding Puzzle  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Logic Game** to wciągająca gra logiczno-strategiczna oparta na programowaniu autonomicznym (Robot Programming Puzzle), inspirowana hitami takimi jak *Cargobot*, *RoboZZle* oraz grami studia Zachtronics. Jako inżynier robotyki musisz zaprogramować algorytm ruchu dla bezbronnego robota badawczego, aby bezpiecznie przeprowadzić go przez naszpikowane przeszkodami labirynty do wyznaczonego zielonego celu. Robot nie reaguje na bezpośrednie klawisze ruchu w czasie rzeczywistym — musisz ułożyć pełną sekwencję instrukcji krok po kroku w rejestrze pamięci, a następnie uruchomić program i obserwować jego bezbłędne wykonanie. Gra stanowi doskonałe ćwiczenie wyobraźni przestrzennej oraz logicznego myślenia algorytmicznego.

### Pętla Rozgrywki i Mechaniki
1. **Wyzwania Algorytmiczne (Levels):** Gra oferuje 2 zróżnicowane wyzwania przestrzenne o rosnącym skomplikowaniu:
   - **Level 1: "Get to the goal":** Prosty labirynt treningowy z limitem 8 komend w rejestrze. Idealny do opanowania podstaw programowania.
   - **Level 2: "Avoid the walls":** Skomplikowany labirynt z ciasnymi korytarzami, ślepymi zaułkami i limitem 12 komend.
2. **Rejestr Programowania (Edit Mode):**
   - Na dole ekranu znajduje się bufor pamięci o rozmiarze dopasowanym do limitu poziomu (8 lub 12 slotów).
   - Przełączaj aktywne sloty strzałkami Lewo/Prawo (podświetlenie fioletowe).
   - Wprowadzaj komendy przypisując je do slotu:
     - **W (UP - Góra):** Ruch o jedno pole w górę.
     - **S (DOWN - Dół):** Ruch o jedno pole w dół.
     - **A (LEFT - Lewo):** Ruch o jedno pole w lewo.
     - **D (RIGHT - Prawo):** Ruch o jedno pole w prawo.
     - **Space (WAIT - Czekaj):** Pusta instrukcja, brak ruchu w danej klatce.
   - Po wprowadzeniu komendy wskaźnik automatycznie przeskakuje na kolejny slot, ułatwiając szybkie pisanie sekwencji.
3. **Kompilacja i Wykonanie (Run Mode - Enter):**
   - Naciśnięcie klawisza **Enter** uruchamia interpretację programu. Robot wykonuje jedną komendę co 0.4 sekundy.
   - Aktywny, aktualnie wykonywany krok podświetla się na kolor pomarańczowo-złoty w HUD.
   - **Kolizje:** Jeśli robot spróbuje wejść na szary kafelek ściany (WALL), ruch zostanie zablokowany, a system wypisze ostrzeżenie "Blocked by wall!", przechodząc do kolejnego kroku programu.
4. **Warunek Zwycięstwa:** Po wykonaniu ostatniego kroku program analizuje pozycję robota. Jeśli znajduje się on na zielonym kafelku wyjścia (GOAL), poziom zostaje zaliczony w towarzystwie złotych cząsteczek. Naciśnij **N**, by przejść dalej lub **R**, by zresetować poziom i spróbować innej sekwencji.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Logic Game** is an engaging, analytical robot automation and coding puzzle designed in Lurek2D, drawing inspiration from programming brain-teasers like *Cargobot*, *RoboZZle*, and the engineering suite of Zachtronics. As a robotics systems programmer, you must compile a sequential, step-by-step movement algorithm to guide an autonomous research drone through obstacle-strewn grids to a designated green exit portal. The robot ignores direct real-time WASD steering; you must pre-write a complete array of operations in the memory register, execute the sequence, and analyze the execution flow. Perfecting clean, minimal loops while dodging blockades serves as a stellar demonstration of algorithmic logic!

### Gameplay Loop & Mechanics
1. **Algorithmic Challenges (Levels):** Climb through 2 distinct grid mazes requiring precise spatial evaluations:
   - **Level 1: "Get to the goal":** A straightforward entry-level sandbox with an 8-command instruction limit.
   - **Level 2: "Avoid the walls":** A complex corridor labyrinth featuring tight gaps, blind corners, and a 12-command instruction limit.
2. **Instruction Buffer (Edit Mode):**
   - The bottom overlay displays a memory register array proportional to the level limit (8 or 12 slots).
   - Select active instruction slots using Left/Right Arrow keys (highlights in a sleek purple).
   - Enter commands to populate the active slot:
     - **W (UP):** Move one tile north.
     - **S (DOWN):** Move one tile south.
     - **A (LEFT):** Move one tile west.
     - **D (RIGHT):** Move one tile east.
     - **Space (WAIT):** Null operation, stalls movement for 1 cycle.
   - Assigning a command automatically advances the pointer, supporting rapid sequence compiling.
3. **Execution Phase (Run Mode - Enter):**
   - Press **Enter** to trigger the program compiler. The robot executes one instruction every 0.4 seconds.
   - The active command step is highlighted in a glowing orange/gold block.
   - **Wall Collisions:** Trying to enter a solid grey wall block (WALL) halts movement and logs a "Blocked by wall!" alert, stepping automatically to the next queue item.
4. **Winning Evaluation:** Once the final instruction step completes, the engine checks the robot's coordinates. If positioned atop the green exit block (GOAL), the level concludes in a brilliant golden particle burst. Press **N** to advance or **R** to reset and rewrite your instructions.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/logic_game
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **Left / Right (Strzałki)** | Wybór slotu programu | Przesuwa fioletową ramkę wyboru slotu w buforze pamięci. |
| **W** | Instrukcja: Ruch w górę | Wpisuje polecenie **UP** w aktywny slot i przechodzi dalej. |
| **S** | Instrukcja: Ruch w dół | Wpisuje polecenie **DOWN** w aktywny slot i przechodzi dalej. |
| **A** | Instrukcja: Ruch w lewo | Wpisuje polecenie **LEFT** w aktywny slot i przechodzi dalej. |
| **D** | Instrukcja: Ruch w prawo | Wpisuje polecenie **RIGHT** w aktywny slot i przechodzi dalej. |
| **Space (Spacja)** | Instrukcja: Czekaj (Wait) | Wpisuje pustą instrukcję **WAIT** w aktywny slot i przechodzi dalej. |
| **Enter (Return)** | Uruchom program (Run) | Rozpoczyna autonomiczną interpretację programu krok po kroku. |
| **R** | Resetuj (Reset) | Czyści program, przywraca robota na pozycję startową i włącza tryb edycji. |
| **N** | Następny poziom | Przechodzi do kolejnej planszy po pomyślnym zaliczeniu obecnej. |
| **Esc** | Wyjście | Zamyka bezpiecznie aplikację. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Cargo-Bot (2012) by Two Lives Left**
  - *Opis powiązania*: Bezpośrednie odzwierciedlenie mechaniki "programowania przed uruchomieniem", w którym gracz układa klocki poleceń, a potem obserwuje ruch ramienia dźwigu wykonującego instrukcje z bufora w identycznym takcie czasowym.
- **TIS-100 / Shenzhen I/O by Zachtronics**
  - *Opis powiązania*: Koncepcja ograniczonego rejestru komend (Assembly-like programming), w której gracz walczy z ciasnymi limitami pamięci, by osiągnąć cel jak najprostszymi instrukcjami bez wywoływania błędów kolizji.
- **RoboZZle by Igor Ostrovsky**
  - *Opis powiązania*: Kierowanie ruchem małego statku po siatce kafelków przy użyciu predefiniowanych strzałek kierunkowych ułożonych w liniową sekwencję.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Logic Game demonstruje przydatność silnika Lurek2D w grach edukacyjnych i akademickich:
- `lurek.input` – Mapowanie klawiatury (`lurek.input.bind`) obsługujące wieloklawiszowy wprowadzacz instrukcji ruchu, nawigację po slotach i wyzwalanie kompilatora przyciskiem Enter.
- `lurek.render` – Rysowanie planszy logicznej (kafelki, niebieski robot w postaci spowolnionego wektora, fioletowa ramka edycji i barwne ikony poleceń za pomocą `rect` i `text_`).
- `lurek.timer` – Odmierzanie precyzyjnego czasu taktowania kroków procesora (co 0.4s) za pomocą delta time.
- `lurek.event` – Wyjście z gry przy naciśnięciu Esc.
- **Dwa Niezależne Systemy Cząsteczek (Particles):**
  - *Płynny krok (Step Dust)*: Jasnoniebieskie cząsteczki emitowane wokół robota przy każdym poprawnym kroku na siatce kafelków.
  - *Fajerwerki Wygranej (Win Fireworks)*: Złote i pomarańczowe gejzery cząsteczek tryskające z zielonego kafelka wyjścia w momencie pomyślnego zaliczenia poziomu.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Najbardziej oryginalna gra logiczno-programistyczna w portfolio. Pokazuje, jak w Lurek2D w prosty sposób zaimplementować interpreter poleceń, parser tablic, dynamiczny krok procesora i stany kolizji kafelkowej bez skomplikowanych bibliotek zewnętrznych, co czyni ją idealnym materiałem szkoleniowym.
- **Unikalność (Uniqueness):** Jedyna gra w portfolio oparta na programowaniu statycznym przed rozgrywką. Gracz nie steruje bezpośrednio postacią, a jedynie projektuje zachowanie ("inteligentnego agenta"), co stawia ją w zupełnie innej kategorii zaangażowania intelektualnego.
- **Podobne gry (Similar Games):** Gra dzieli kafelkowy charakter planszy z `roguelike` oraz `farming_sim`, ale różni się od nich brakiem kontroli w czasie rzeczywistym i turowym, wprowadzając unikalną mechanikę kompilatora instrukcji.
