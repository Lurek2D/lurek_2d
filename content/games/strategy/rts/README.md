# ⚔️ RTS — Real-Time Strategy Sandbox

**Category:** Strategy / Real-Time Strategy  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**RTS** to w pełni grywalny piaskownica strategii czasu rzeczywistego (RTS), stanowiąca bezpośredni hołd dla przełomowych klasyków gatunku, takich jak *Warcraft II: Tides of Darkness* czy pierwsze odsłony serii *Command & Conquer*. Gracz obejmuje dowództwo nad bazą wojskową na rozległej, przewijanej mapie o wymiarach 1800x1200 pikseli. Zadaniem dowódcy jest optymalizacja bazy, wydobywanie złota i ścinanie drewna przez wysyłanie żołnierzy w pobliże naturalnych złóż, wznoszenie koszar, szkolenie nowych jednostek bojowych oraz odpieranie coraz silniejszych fal wrogich najeźdźców. Gra w znakomity sposób pokazuje, jak silnik Lurek2D radzi sobie z obsługą wielu jednostek w czasie rzeczywistym, sztuczną inteligencją wyszukującą cele, przewijaniem kamery oraz dynamicznymi efektami cząsteczkowymi.

### Pętla Rozgrywki i Mechaniki
1. **Zarządzanie Zasobami:**
   - **Gold (Złoto):** Wydobywane z żółtych złóż rudy rozlokowanych na mapie.
   - **Wood (Drewno):** Pozyskiwane z zielonych lasów.
   - **Automatyczne zbieranie:** Dowolna jednostka gracza stojąca w bliskiej odległości od złoża (poniżej 60 pikseli) zaczyna automatycznie wydobywać surowiec z prędkością 8 jednostek na sekundę, wyczerpując zasób i powiększając skarbiec gracza.
2. **Budowanie i Rekrutacja:**
   - **Base (Kwatera Główna):** Serce bazy (200 HP). Jeśli zostanie zniszczona przez wroga, gra kończy się porażką.
   - **Barracks (Koszary):** Budynek rekrutacyjny (80 HP). Pozwala na szkolenie żołnierzy.
   - **Szkolenie (T):** Kosztuje 50 sztuk złota. Jednostka pojawia się w pobliżu koszar po 4 sekundach odnowienia.
3. **Sterowanie i Walka:**
   - Wybierz jednostkę za pomocą lewego przycisku myszy (LMB) — pod jednostką pojawi się błękitny pierścień zaznaczenia i wyzwolone zostaną cząsteczki.
   - Wydaj rozkaz ruchu lub ataku za pomocą prawego przycisku myszy (RMB) na mapie.
   - Jednostki automatycznie wykrywają wrogów w swoim zasięgu i przechodzą w tryb walki, zadając obrażenia co 1 sekundę.
4. **System Fal Wrogów (Wave System):**
   - Co 20-30 sekund z prawego górnego rogu mapy wyrusza kolejna fala wrogich najeźdźców, kierujących się prosto na bazę gracza.
   - Trudność rośnie z każdą falą (więcej wrogów o większej sile). Przetrwaj wszystkie 5 fal i wyeliminuj wszystkich wrogów, aby odnieść zwycięstwo!

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**RTS** is a fully functional real-time strategy sandbox, standing as a direct mechanical tribute to genre-defining hits like *Warcraft II: Tides of Darkness* and early *Command & Conquer* blockbusters. The player assumes command of a military outpost on a vast 1800x1200 scrollable map. Your mission: balance resource extraction, build barracks to train soldiers, and defend your Town Hall from increasingly aggressive enemy waves. Soldiers standing near resource nodes automatically harvest gold and wood to fund your expansion. With dynamic selection particle rings, intuitive keyboard-mouse controls, and autonomous targeting AI, this project is a prime showcase of Lurek2D's high-performance real-time loops!

### Gameplay Loop & Mechanics
1. **Resource Pipelines:**
   - **Gold:** Mined from yellow mineral deposits scattered across the map.
   - **Wood:** Harvested from dense green forest groves.
   - **Auto-Harvesting:** Any player unit standing within 60px of a resource node automatically starts gathering at a rate of 8 units/second, draining the node and filling the player's treasury.
2. **Base Infrastructure & Recruiting:**
   - **Base (Town Hall):** The core building (200 HP). If destroyed by invaders, it is instant game over.
   - **Barracks:** The training academy (80 HP). Allows you to draft new soldiers.
   - **Train Unit (T):** Costs 50 gold. Spawns a new soldier near the barracks after a 4-second cooldown.
3. **Command & Combat Resolution:**
   - Click a unit with the Left Mouse Button (LMB) to select it, triggering a cyan particle ring.
   - Right-click (RMB) in the world to dispatch selected units to move or attack destinations.
   - Units automatically scan for enemies in their vicinity, engaging in battle and dealing damage every 1.0 seconds.
4. **Invader Wave Loop:**
   - Every 20-30 seconds, an enemy wave spawns at the top-right corner of the map, marching directly toward your Base.
   - Waves scale in count and stats. Defend your base through 5 waves and purge all remaining enemy units to secure victory!

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/rts
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB (Klik)** | Zaznacz jednostkę (Select) | Zaznacza jednostkę gracza pod kursorem, aktywując cząsteczkowy pierścień. |
| **RMB (Klik)** | Rozkaz (Order Move/Attack) | Wydaje wybranym jednostkom rozkaz marszu lub ataku we wskazanym punkcie. |
| **T** | Szkól jednostkę (Train) | Zleca rekrutację nowego żołnierza w koszarach (Koszt: 50 złota, 4s CD). |
| **W / A / S / D** | Przewijanie kamery (Scroll) | Przesuwa wirtualną kamerę po mapie (góra / lewo / dół / prawo). |
| **Esc** | Wyjście (Quit) | Zamyka grę w bezpieczny sposób. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Warcraft II: Tides of Darkness (1995) by Blizzard Entertainment**
  - *Opis powiązania*: Wyraźna inspiracja systemem zbierania dwóch surowców (drewno + złoto), wyglądem jednostek o okrągłych kształtach na płaskiej zielonej trawie oraz schematem szkolenia piechoty w koszarach w celu obrony głównego budynku.
- **Command & Conquer (1995) by Westwood Studios**
  - *Opis powiązania*: Wdrożenie przewijanej, dużej mapy bitewnej, systemu walki opartego na zasięgu wzroku jednostek, oraz natychmiastowego marszu wrogich kolumn prosto na pozycje obronne gracza.
- **Dune II (1992) by Westwood Studios**
  - *Opis powiązania*: Wdrożenie wysepek zasobów naturalnych, które wyczerpują się w miarę eksploatacji, zmuszając gracza do eksploracji dalszych obszarów mapy.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

- `lurek.input` – Obsługa zaawansowanego mapowania klawiatury i myszy: translacja kliknięć myszy na koordynaty świata gry (uwzględniając przesunięcie kamery) oraz mapowanie sterowania przewijaniem ekranu (WASD).
- `lurek.render` – Dynamiczne renderowanie obiektów w przestrzeni gry przy użyciu `rect`, `circ` oraz `text_`. Zarządza również automatycznym dopasowaniem tła i rysowaniem pasków HP jednostek.
- `lurek.window` / `lurek.event` – Inicjalizacja okna o wymiarach 900x640 pikseli, nadanie unikalnego tytułu oraz czysty powrót do systemu przy Esc.
- `lurek.timer` – Precyzyjna synchronizacja zegara gry (`dt`) dla odliczania czasu rekrutacji, spływu surowców oraz stałej prędkości poruszania się jednostek.
- **Dwa Równoległe Systemy Cząsteczek (Multiple Particle Systems):**
  - *Iskry śmierci (Death Sparks)*: Żywy wybuch pomarańczowo-czerwonych cząsteczek z zanikaniem w miejscu śmierci zlikwidowanej jednostki.
  - *Pierścień wyboru (Selection Ring)*: Rozszerzający się, niebieski pierścień cząsteczkowy wyzwalany w miejscu zaznaczenia żołnierza.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Najbardziej kompletna gra RTS w całej bibliotece. Idealnie demonstruje transformację współrzędnych ekranu na współrzędne wirtualnego świata gry o dużym formacie, oraz implementację sztucznej inteligencji zdolnej do samodzielnego obierania celów i patrolowania bazy.
- **Unikalność (Uniqueness):** Jedyna gra strategiczna w czasie rzeczywistym z ciągłym pozyskiwaniem surowców z wyczerpujących się złóż, wznoszeniem struktur produkcyjnych i bezpośrednią kontrolą nad grupą jednostek w otwartym terenie.
- **Podobne gry (Similar Games):** Dzieli sterowanie myszą i kamerą z `eu2` oraz `colony_sim`, lecz wyróżnia się nastawieniem na zręcznościową mikrokontrolę jednostek bojowych w czasie rzeczywistym i odpieraniem zorganizowanych najazdów.
