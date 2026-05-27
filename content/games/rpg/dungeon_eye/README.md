# 👁️ Dungeon Eye — First-Person 3D Raycaster Dungeon Crawler

**Category:** RPG / First-Person Dungeon Crawler  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Dungeon Eye** to hołd dla klasycznych, trójwymiarowych dungeon crawlerów z widokiem pierwszoosobowym (FPP), takich jak legendarny *Eye of the Beholder*. Wykorzystując zaimplementowany w silniku Lurek2D sprzętowy moduł renderowania raycast (rzutowania promieni), gra przenosi Cię w głąb tajemniczego lochu o wymiarach 15x15 pól. Twoim celem jest przetrwanie starć z czyhającymi w ciemnościach potworami, zbieranie wyposażenia, zarządzanie ekwipunkiem i odnalezienie zielonej bramy wyjściowej, by uciec na wolność.

### Pętla Rozgrywki i Mechaniki
1. **Ruch i Orientacja:** Poruszasz się po lochu skokowo (grid-based movement) w czterech kierunkach (Północ, Wschód, Południe, Zachód). Raycaster generuje perspektywiczny widok korytarzy w 3D.
2. **Eksploracja i Interakcja (Space / E):** Możesz badać kafelki przed sobą, otwierać drzwi oraz wchodzić w interakcję z otoczeniem.
3. **Walka w Zwarciu (Melee Combat):** Wejście na kafelek zajmowany przez wroga (zaznaczonego na minimapie jako czerwona kropka) automatycznie rozpoczyna walkę wręcz. Zadajesz obrażenia oparte na sile broni i przyjmujesz kontrataki. Pokonanie wroga daje szansę na zdobycie mikstury życia.
4. **Zarządzanie Ekwipunkiem (I / Inventory):** Zbieraj porozrzucane w lochu przedmioty:
    *   🗡️ **Sword (Miecz):** Zwiększa siłę Twoich ataków fizycznych.
    *   🛡️ **Shield (Tarcza):** Zwiększa obronę, redukując obrażenia od potworów.
    *   🧪 **Health Potion (Mikstura Życia):** Przywraca 12 punktów HP po użyciu z poziomu plecaka.
    *   🔦 **Torch (Pochodnia) & Magic Key (Magiczny Klucz):** Przedmioty fabularne i użytkowe.
5. **Dziennik Zdarzeń (Status Log):** Pasek u dołu ekranu na bieżąco informuje Cię o ostatnich akcjach (zadanych obrażeniach, zebranych przedmiotach, napotkanych przeszkodach) z estetycznym zanikaniem tekstu.
6. **Wektorowa Minimapa:** W prawym górnym rogu ekranu 3D wyświetlana jest podręczna mapa lochu, pokazująca ściany, gracza (żółta kropka), potwory (czerwone) oraz upragnione wyjście (zielone).

---

## 🇬🇧 Game Description (English)

### Short Pitch (Elevator Pitch)
**Dungeon Eye** is a gripping grid-based 3D first-person dungeon crawler inspired by PC gaming milestones like *Eye of the Beholder* (1992). Navigating a dangerous 15x15 block labyrinth using the Lurek2D engine's native GPU-accelerated raycasting engine, you must scavenge for epic weaponry, battle monsters in direct melee combat, consume life-saving potions from your grid inventory, and survive long enough to locate the green exit portal.

### Gameplay Loop & Mechanics
1. **Grid-Based Exploration:** Move step-by-step through dark, winding corridors. The raycaster engine handles projection, giving a fully immersive first-person 3D illusion.
2. **Environmental Interaction (Space / E):** Inspect tiles ahead, search for secrets, and trigger switches.
3. **Turn-Based Melee Combat:** Walking directly into a monster's grid tile triggers combat. Attacks deal variable damage based on your weapon, and enemies hit back immediately. Defeated monsters sometimes drop health potions.
4. **Itemization & Inventory (I):** Collect drops from around the dungeon to fill your 16-slot grid inventory:
    *   🗡️ **Sword:** Scales up physical melee damage.
    *   🛡️ **Shield:** Enhances passive defense to mitigate monster counter-attacks.
    *   🧪 **Health Potion:** Consumed directly from the bag to restore 12 HP.
    *   🔦 **Torch & Magic Key:** Key utility items that enhance survival.
5. **Fading Status Log:** A ticker display at the bottom monitors combat actions, items gathered, and alerts with smooth alphabetical opacity falloff.
6. **HUD Minimap:** A real-time navigation grid overlays the top-right corner of the 3D viewport, highlighting pathways, enemy positions (red), player orientation (yellow), and the exit door (green).

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **W / S / ↑ / ↓** | Ruch do przodu / do tyłu | Move forward / Step backward |
| **A / D / ← / →** | Obrót w lewo / w prawo | Turn left / Turn right 90 degrees |
| **I** | Otwórz / Zamknij ekwipunek | Open / Close slot inventory panel |
| **↑ / ↓ (w ekwipunku)** | Nawigacja po przedmiotach | Scroll through items in bag |
| **U / Enter (w ekwipunku)** | Użyj wybranego przedmiotu | Consume / Use active selected item |
| **Space / E** | Zbadaj / Interakcja z kafelkiem z przodu | Inspect / Interact with facing tile |
| **Escape** | Zamknij ekwipunek / Wyjdź z gry | Close inventory panel / Quit game |

---

## 🏰 Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
Gra stanowi wierny hołd dla rewolucyjnych gier RPG z lat 90., na czele z **Eye of the Beholder** (Capcom/Westwood), **Dungeon Master** (1987) oraz wczesnych części **Might and Magic**. Doskonale naśladuje ich cechy:
*   Krokowy system poruszania się pod kątem prostym (discrete grid navigation).
*   Dynamiczna walka w czasie rzeczywistym bezpośrednio przed twarzą gracza.
*   Zarządzanie zdrowiem i ekwipunkiem jako klucz do przetrwania.
*   Poczucie osaczenia przez zamknięte korytarze i brak widoczności z góry.

### Modernizacja w Lurek2D
Lurek2D wprowadza to klasyczne doświadczenie na wyższy poziom zaawansowania:
*   **Wbudowane Rzutowanie Promieni (`lurek.raycaster`):** Cały widok 3D jest obliczany za pomocą zaawansowanego, wydajnego algorytmu DDA zintegrowanego bezpośrednio z silnikiem. Uwalnia to programistę od konieczności pisania skomplikowanych projekcji w Lua.
*   **Płynny Błysk Ruchu (Juice):** Każde wykonanie kroku w grze generuje subtelne, płynne rozbielenie ekranu (`move_anim`), dające doskonałe kinestetyczne poczucie dynamizmu przemieszczania się.

---

## 🛠️ Wykorzystane API silnika Lurek2D / Lurek APIs Showcased

*   `lurek.raycaster`: Inicjalizacja instancji rzutowania promieni (`new`), przekazywanie układu ścian (`setCell`) oraz wysokowydajne renderowanie trójwymiarowego widoku pierwszoosobowego na ekranie (`drawView`).
*   `lurek.render`: Rysowanie podziału ekranu, paska życia gracza, ikon przedmiotów w plecaku oraz wektorowej minimapy lochu (`rectangle`, `circle`, `print`, `line`, `setColor`).
*   `lurek.input` & `keypressed`: Przechwytywanie precyzyjnych wciśnięć pojedynczych klawiszy klawiatury dla celów interaktywnej obsługi plecaka i nawigacji.
*   `lurek.window`: Dynamiczna kontrola i modyfikacja paska tytułu okna systemowego (`setTitle`).
*   `lurek.event`: Wywołanie poprawnej procedury bezpiecznego zamknięcia aplikacji (`quit`).

---

## 💎 Unikalność i Wartość Prezentacyjna / Showcase Value & Uniqueness

### Dlaczego ta gra jest wyjątkowa?
**Dungeon Eye** to jeden z najbardziej imponujących technicznie pokazów w całym portfolio Lurek2D. Stanowi kamień milowy w prezentowaniu możliwości silnika deweloperom:
1.  **Łączy 3D i 2D w jednym kadrze:** Udowadnia, że silnik stworzony z myślą o grafice 2D potrafi wygenerować kompletnie immersyjne środowisko trójwymiarowe (3D Viewport) obok klasycznych dwuwymiarowych paneli sterowania (Inventory & Stats).
2.  **Doskonały interfejs ekwipunku:** Implementuje kompletny system slotowy z obsługą definiowania parametrów przedmiotów w czystym Lua (Item Database & Inventory Module), co stanowi świetny fundament pod rozbudowane gry fabularne.
3.  **Optymalizacja Raycastingu:** Silnik stabilnie utrzymuje stałe 60 klatek na sekundę przy pełnym renderowaniu rzutowym i dynamicznej minimapie, pokazując świetne zoptymalizowanie warstwy Rust-Lua.

To obowiązkowa gra demonstracyjna dla każdego fana gier retro i programisty pragnącego poznać potęgę modułu raycastera w silniku Lurek2D.
