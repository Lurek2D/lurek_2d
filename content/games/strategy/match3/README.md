# 💎 Match 3 — Cascade Gem-Swapping Puzzle

**Category:** Strategy / Match-3 Puzzle  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Match 3** to niezwykle płynna, kolorowa gra logiczna i strategiczna (Tile-matching Puzzle), będąca bezpośrednim hołdem dla kultowych światowych hitów, takich jak *Bejeweled* oraz seria *Candy Crush Saga*. Gracz staje przed wyzwaniem polegającym na zamianie miejscami sąsiadujących ze sobą kolorowych klejnotów na planszy 8x8 w celu utworzenia linii 3 lub więcej identycznych kamieni. Twórz spektakularne reakcje łańcuchowe (kaskady), odblokowuj wybuchowe klejnoty specjalne (Bomby) przy dopasowaniach powyżej 5 kamieni, kontroluj ograniczoną pulę ruchów (30 ruchów) i śrubuj rekordy punktowe z rosnącymi mnożnikami combo. Precyzyjne animacje spadania i cofania błędnych ruchów czynią tę grę wspaniałym pokazem płynności silnika Lurek2D.

### Pętla Rozgrywki i Mechaniki
1. **Plansza i Kolorystyka:** Gra toczy się na planszy o rozmiarze 8x8 kafelków. W grze występuje 6 wyrazistych barw klejnotów (czerwony, zielony, niebieski, żółty, fioletowy, błękitny).
2. **Klejnoty Specjalne (Bombs):**
   - Utworzenie dopasowania o rozmiarze **5 lub więcej identycznych klejnotów** automatycznie promuje jeden z kamieni do rangi **Bomby** (oznaczonej pomarańczową zębatą ikoną).
   - Dopasowanie Bomby wyzwala potężną, widowiskową eksplozję uwalniającą znacznie większą pulę punktów.
3. **Logika Zamiany i Fizyka Cofania (Swap & Revert):**
   - Kliknij na klejnot, aby go podświetlić, a następnie kliknij na sąsiadujący z nim pionowo lub poziomo kamień, by dokonać zamiany (Swap).
   - Silnik gry interpretuje zamianę w czasie 0.12s. Jeśli zamiana doprowadzi do utworzenia linii match-3+ — kombinacja zostaje rozbita.
   - **Cofnięcie (Revert):** Jeśli zamiana nie doprowadzi do żadnego dopasowania, gra automatycznie i płynnie cofa klejnoty na ich pierwotne pozycje, chroniąc przed marnowaniem ruchów.
4. **Fizyka Spadania i Kaskady (Gravity & Cascades):**
   - Po rozbiciu dopasowanych klejnotów, puste pola są uzupełniane przez kamienie znajdujące się powyżej. Nowe klejnoty wjeżdżają na planszę z góry ekranu.
   - Płynny ruch spadania (300px/s) zliczany jest w czasie rzeczywistym.
   - **Kaskady (Combos):** Spadające klejnoty mogą automatycznie utworzyć nowe linie dopasowań. Każda kolejna kaskada w jednym ruchu zwiększa mnożnik Combo (`combo`), drastycznie mnożąc przyznawane punkty!
5. **Limit Ruchów (Moves Limit):** Gracz rozpoczyna z pulą 30 ruchów. Każda udana zamiana pomniejsza pulę o 1. Osiągnięcie limitu 0 ruchów kończy grę i wyświetla panel podsumowania z wynikiem końcowym (Score).

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Match 3** is a highly fluid, vibrant tile-matching puzzle designed in Lurek2D as a direct tribute to iconic global phenomena like *Bejeweled* and the *Candy Crush* franchise. Challenge your spatial foresight on an 8x8 grid by swapping adjacent gems to align horizontal or vertical rows of 3 or more identical stones. Trigger spectacular cascading chains, create explosive special items (Bombs) with matches of 5 or more, navigate a strict 30-move allowance, and maximize your scores with compounding combo multipliers. Blending soft physics-based fall logic with elastic swapping and error-reversions, this title serves as a premier showcase of game juice in Lurek2D!

### Gameplay Loop & Mechanics
1. **The Grid & Color Registry:** Play on an 8x8 layout populated by 6 harmonious gem colors (Red, Green, Blue, Yellow, Purple, Cyan).
2. **Special Items (Bombs):**
   - Matching a line of **5 or more identical gems** automatically upgrades a tile into an explosive **Bomb** (represented by a glowing orange segmented ring).
   - Activating a Bomb in a match triggers a massive shockwave, clearing larger areas and awarding massive score bonuses.
3. **Swap & Revert Logic:**
   - Click a gem to select it, then click any vertically or horizontally adjacent gem to swap their positions.
   - The engine interpolates the swap over 0.12 seconds. If the swap successfully forms a match-3+ group, the match clears.
   - **Elastic Reversion:** If a swap yields no valid matches, the engine automatically slides the gems back to their original positions, preventing illegal moves.
4. **Gravity & Cascades:**
   - Cleared slots trigger gravity physics. Gems above fall down, and new gems enter from beyond the top board borders.
   - Gems descend smoothly at a rate of 300px/s.
   - **Combos (Cascades):** Falling gems can form secondary and tertiary matches automatically. Each consecutive chain reaction increments the combo multiplier (`combo`), scaling your score!
5. **Limited Turn Allowance:** Start with a pool of 30 moves. Each successful swap decrements your moves remaining. Dropping to 0 moves triggers the Game Over summary overlay, locking in your final score.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/match3
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB (Lewy Klik)** | Zaznaczenie / Zamiana | Wybiera klejnot. Drugie kliknięcie na sąsiedni klejnot zamienia je miejscami. |
| **Esc** | Wyjście | Zamyka bezpiecznie aplikację. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Bejeweled (2001) by PopCap Games**
  - *Opis powiązania*: Bezpośredni protoplasta. Przeniesienie planszy 8x8, mechaniki zamiany kafelków sąsiednich, natychmiastowego cofania niepoprawnych ruchów oraz zliczania punktów za rozbite linie o tych samych barwach.
- **Candy Crush Saga (2012) by King**
  - *Opis powiązania*: Tworzenie potężnych klejnotów specjalnych przy dopasowaniach powyżej 4 lub 5 kamieni (Bomby), system kaskadowych łańcuchów reakcji (Combos) uwalniających dodatkowe punkty oraz ograniczenie liczby ruchów na planszę.
- **Tetris Attack / Puzzle League**
  - *Opis powiązania*: Koncepcja dynamicznego opadania klocków pod wpływem grawitacji z dopasowywaniem nowych linii w locie w celu budowania mnożników combosów.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Match 3 to kapitalna prezentacja dynamiki ruchu i "soku z gry" (game juice) w Lurek2D:
- `lurek.input` – Precyzyjna rejestracja pozycji myszy przekształcana na wiersze i kolumny siatki planszy (`c` i `r`), umożliwiająca bezbłędny wybór pojedynczych klejnotów.
- `lurek.render` – Rysowanie planszy, barwnych klejnotów, obwódek zaznaczenia i HUD za pomocą poleceń `rect`, `circ` i `text_`.
- `lurek.timer` – Odmierzanie kroku czasowego delta (`dt`) do płynnego i dokładnego animowania spadania klejnotów.
- `lurek.event` – Wyjście z gry przy naciśnięciu Esc.
- **Fizyka Opadania i Reakcje (Gravity & Cascades):** Wykorzystanie relatywnych offsetów kafelków `py` w pętli update, które po zwolnieniu grawitacją przesuwają się płynnie w dół (fall_speed = 300px/s), co gwarantuje wspaniały, organiczny wygląd animacji opadu.
- **Dwa Zaawansowane Systemy Cząsteczek (Particles):**
  - *Iskry Dopasowania (Match Sparks)*: Złoto-czerwone małe cząsteczki eksplodujące w punktach środkowych klejnotów przy pomyślnych rozbiciach.
  - *Eksplozja Bomby (Bomb Burst)*: Wielkie, dynamiczne, pomarańczowo-szare gejzery ognia uwalniające się podczas aktywacji Bomb.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Wzorcowa lekcja z zakresu animacji względnych i detekcji dopasowań (Grid Scanning Algorithms). Pokazuje programistom, jak napisać algorytm przeszukiwania siatki w poziomie i pionie w celu znajdowania linii 3+ (find_matches), jak zaimplementować bezpieczne cofanie bez utraty spójności danych oraz jak obsłużyć dynamiczne spadanie gemów.
- **Unikalność (Uniqueness):** Jedyny klasyczny Match-3 w portfolio gier. Kładzie nacisk na szybką analizę układu planszy, przewidywanie kaskad oraz optymalizację ruchów, reprezentując wysoce popularny gatunek Casual.
- **Podobne gry (Similar Games):** Gra dzieli kafelkową strukturę planszy z `tetris`, ale wprowadza zupełnie odmienną mechanikę przesuwania obiektów przez gracza i grawitacji kaskadowej.
