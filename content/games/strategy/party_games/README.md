# 🥳 Party Games — Local Multiplayer Mini-Game Duel Pack

**Category:** Strategy / Party Game  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Party Games** to wesoły, niezwykle dynamiczny pakiet czterech rywalizacyjnych minigier dla dwóch graczy na jednym ekranie (Local Multiplayer Party Pack), inspirowany hitami takimi jak *Mario Party*, *WarioWare* oraz *Bishi Bashi*. Gra stawia naprzeciw siebie dwóch rywali w zaciętym pojedynku zręczności, refleksu, pamięci oraz logicznego myślenia. Rozegrajcie 3 emocjonujące rundy, w skład których wchodzą cztery zróżnicowane wyzwania (szybki klik, sekwencje pamięciowe, wyścig pisania słów na czas, pojedynek matematyczny) i zdobądźcie tytuł Mistrza Imprezy. Widowiskowe błyski zwycięstwa i konfetti czynią tę grę wspaniałym show na każdym lokalnym spotkaniu!

### Minigry i Mechaniki Duelowe
Gra składa się z 3 pełnych rund, w których gracze toczą pojedynki w 4 odmiennych dyscyplinach minigier:
1. **Reaction Game (Pojedynek Refleksu):**
   - **Rdzeń:** Na ekranie widnieje komunikat "Wait for the signal...". Po losowym czasie (1-4s) ekran błyska na zielono i pojawia się napis "NOW!".
   - **Cel:** Naciśnij swój przycisk brzęczyka szybciej niż rywal! Gracz 1 klika **Z**, Gracz 2 klika **Shift**. Gra precyzyjnie mierzy czas reakcji (w milisekundach).
2. **Memory Game (Szybka Pamięć):**
   - **Rdzeń:** Gra wyświetla w centrum ekranu losową sekwencję cyfr od 1 do 4 (długość sekwencji rośnie z każdą rundą).
   - **Cel:** Zapamiętaj sekwencję i powtórz ją bezbłędnie! Gracz 1 używa klawiszy **1-4**, Gracz 2 klika na klawiaturze numerycznej **KP1-KP4**.
3. **Typing Race (Wyścig Pisania):**
   - **Rdzeń:** Na ekranie pojawia się losowe, trudne słowo pisane wersalikami (LUREK, PLASMA, ROCKET, BANANA, WIZARD).
   - **Cel:** Przepisz słowo na klawiaturze tak szybko, jak to możliwe. Pierwszy gracz, który wprowadzi bezbłędnie cały ciąg znaków, zdobywa punkt.
4. **Math Duel (Szybka Matematyka):**
   - **Rdzeń:** Generator losuje proste równanie arytmetyczne (dodawanie, odejmowanie, mnożenie, np. "8 × 7 = ?").
   - **Cel:** Oblicz wynik w pamięci i wpisz go za pomocą cyfr. Kto pierwszy wprowadzi poprawną wartość cyfrową — wygrywa pojedynek!

### System Wyników i Flesze
- Zwycięzca każdej pojedynczej minigry otrzymuje +1 punkt do tabeli wyników.
- W momencie wygranej minigry ekran ulega nastrojowemu rozbłyskowi (Flash) w barwach gracza (zielony dla gracza 1, niebieski dla gracza 2).
- Po rozegraniu wszystkich rounds gra przechodzi do ekranu podsumowania (Scoreboard), ogłaszając ostatecznego zwycięzcę meczu w deszczu złotych fajerwerków.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Party Games** is a cheerful, highly dynamic local multiplayer collection of four competitive mini-games (Local Party Pack) designed as a direct tribute to classic party titles like *Mario Party*, *WarioWare*, and the legendary *Bishi Bashi* arcade series. Pit two players against one another in high-stakes duels of reaction, split-second memory, rapid keyboard typing, and mental arithmetic. Survive 3 full tournament rounds across all four mini-games, earn score points, and crown the ultimate Party Master. Featuring vibrant winner screens, custom flash overlays, and physics-based victory confetti, this title delivers elite casual party action!

### The Mini-Game Suite & Mechanics
Compete across 3 tournament rounds, with each round cycling through four distinct multiplayer arenas:
1. **Reaction Game (Reflex Duel):**
   - **Core:** A warning reads "Wait for the signal...". After a randomized delay of 1 to 4 seconds, the screen flashes green alongside a massive "NOW!" alert.
   - **Goal:** Slap your buzzer faster than your opponent! Player 1 buzzes with **Z**, Player 2 buzzes with **Shift**. The engine calculates response times down to the millisecond.
2. **Memory Game (Visual Sequencer):**
   - **Core:** The board flashes a sequence of digits ranging 1 to 4 (sequence lengths extend with each successive round).
   - **Goal:** Memorize the digits and repeat them! Player 1 enters sequences via keyboard **1-4**, Player 2 inputs using Numpad **KP1-KP4**.
3. **Typing Race (Keyboard Speedrun):**
   - **Core:** The screen reveals a randomized capitalized word (e.g., LUREK, PLASMA, ROCKET, BANANA, WIZARD).
   - **Goal:** Type out the word on your keyboard. The first player to successfully input the correct character sequence secures the win.
4. **Math Duel (Mental Arithmetic):**
   - **Core:** The engine generates a math equation (addition, subtraction, or multiplication, e.g., "12 × 9 = ?").
   - **Goal:** Compute the solution and input the digits. The first player to input the correct numeric answer wins!

### Scoring & Visual Juice
- Slaying a mini-game awards +1 point to that player's tournament tally.
- Securing a mini-game win triggers an atmospheric color flash (green for Player 1, blue for Player 2).
- Completing the tournament transitions players to the Final Scoreboard, crowning the victor under a dynamic shower of gold victory fireworks.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/party_games
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **Z** | Gracz 1: Brzęczyk | Aktywuje brzęczyk Gracza 1 w pojedynku refleksu (Reaction Game). |
| **1, 2, 3, 4** | Gracz 1: Klawisze pamięci | Wprowadza cyfry w grze pamięciowej (Memory Game) dla Gracza 1. |
| **A-Z (Letters)** | Gracz 1: Klawiatura | Służy do pisania słów w wyścigu literowym (Typing Race) dla Gracza 1. |
| **0-9 (Digits)** | Gracz 1: Cyfry | Służy do wpisywania wyników w pojedynku matematycznym (Math Duel) dla Gracza 1. |
| **Shift** | Gracz 2: Brzęczyk | Aktywuje brzęczyk Gracza 2 w pojedynku refleksu (Reaction Game). |
| **Numpad 1-4** | Gracz 2: Klawisze pamięci | Wprowadza cyfry w grze pamięciowej (Memory Game) dla Gracza 2 (klawisze KP1-KP4). |
| **Space (Spacja)** | Potwierdzenie / Dalej | Rozpoczyna turniej z menu głównego, a także zatwierdza przejście do kolejnej minigry. |
| **Esc** | Wyjście | Zamyka bezpiecznie aplikację. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Mario Party (Seria) by Nintendo**
  - *Opis powiązania*: Bezpośrednie nawiązanie do formatu turniejowego mini-wyzwań zliczających punkty dla poszczególnych graczy na wspólnym scoreboardzie oraz zróżnicowana typologia zadań.
- **WarioWare (Seria) by Nintendo**
  - *Opis powiązania*: Koncepcja mikrogier (microgames) trwających zaledwie kilka lub kilkanaście sekund, w których gracze muszą natychmiastowo zrozumieć zasadę i zareagować w ułamku sekundy.
- **Bishi Bashi (Seria) by Konami**
  - *Opis powiązania*: Kultowa seria automatowa skupiająca się na szybkim button-mashingu, refleksie przy brzęczykach oraz prostych wyzwaniach logicznych w kolorowej szacie graficznej.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Party Games to doskonały, wielostronny pokaz interakcji w silniku Lurek2D:
- `lurek.input` – Zaawansowane przechwytywanie klawiszy o odmiennych układach (standardowa klawiatura literowa dla Gracza 1 vs Numpad i przycisk Shift dla Gracza 2) bez konfliktów i opóźnień.
- `lurek.render` – Rysowanie nastrojowego interfejsu pojedynków, dużych czcionek cyfrowych, dynamicznych prostokątów z podświetleniem aktywnego gracza za pomocą `rect`, `circ` i `text_`.
- `lurek.timer` – Niezbędny do precyzyjnego odliczania losowych opóźnień brzęczyka oraz pobierania dokładnego czasu systemowego w milisekundach do pomiaru czasu reakcji (`os.clock()`).
- `lurek.event` – Wyjście z gry przy naciśnięciu Esc.
- **Widowiskowy System Cząsteczek (Celebration Confetti):** Wykorzystanie zintegrowanego systemu cząsteczek (`celebration_sys`) wyrzucającego potężną fontannę 200 tęczowych drobinek celebrujących zwycięstwo na ekranie końcowym.
- **Dynamiczne Rozbłyski Ekranowe (Flash Overlays):** Płynne wygaszanie kolorowych warstw alfa nałożonych na ekran w pętli update (z czasem 0.3s), dające poczucie fizycznego "uderzenia" i informujące o zwycięstwie danej strony.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Niezwykle ważny dowód na to, że w Lurek2D można stworzyć w pełni funkcjonalną grę dla dwóch graczy przy jednym komputerze (Local Shared-Screen). Demonstruje bezproblemową koordynację odmiennych zestawów sterowania klawiatury, dynamiczne przejścia stanów minigier oraz zaawansowane czasy systemowe z dokładnością do tysięcznych sekundy.
- **Unikalność (Uniqueness):** Jedyna gra w portfolio o charakterze w pełni rywalizacyjnym i imprezowym (Local Party Game). Oferuje najkrótsze, najbardziej zróżnicowane wyzwania zręcznościowe z dynamicznym scoreboardem, co czyni ją idealnym pokazem silnika dla zabawy wieloosobowej.
- **Podobne gry (Similar Games):** Gra dzieli turowe podsumowania z `sensible_soccer` pod kątem lokalnej rywalizacji 2-osobowej, ale jest unikalna pod względem zręcznościowego miksu gier w stylu *WarioWare*.
