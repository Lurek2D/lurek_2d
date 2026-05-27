# 👾 Creature Collector — Pokemon-style RPG in Lurek2D

**Category:** RPG / Turn-Based Battle  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Creature Collector** to klasyczna, turowa gra RPG inspirowana legendarną serią *Pokémon*. Eksploruj generowaną losowo mapę kafelkową, przedzieraj się przez dzikie zarośla, stawiaj czoła niebezpiecznym stworzeniom i zbieraj je do swojej drużyny. Dzięki klasycznemu trójkątowi typów żywiołów (Ogień, Woda, Trawa) każda walka wymaga zręcznego planowania taktycznego i zarządzania zasobami. Twoim celem jest złapanie wszystkich 6 unikalnych gatunków stworzeń i wyszkolenie ich na najwyższy poziom!

### Pętla Rozgrywki i Mechaniki
1. **Eksploracja (Overworld):** Poruszasz się po kafelkowym świecie (25x18 kafelków) składającym się z ścieżek, drzew, wody, trawy i punktu leczenia (czerwony krzyż).
2. **Losowe Walki (Random Encounters):** Wchodzenie na kafelki wysokiej trawy wiąże się z 10% szansą na zaatakowanie przez dzikie stworzenie.
3. **Walka Turowa (Turn-Based Battles):** Podczas potyczki masz cztery opcje:
    *   **Fight (Walka):** Wybierz jeden z dwóch unikalnych ataków swojego stworzenia.
    *   **Catch (Łapanie):** Rzuć kapsułę łapiącą. Szansa na złapanie wzrasta, im mniej punktów HP ma przeciwnik (30% bazowo, do 70% przy krytycznie niskim HP).
    *   **Switch (Zmiana):** Zmień aktywne stworzenie na inne z drużyny (maksymalnie 3 stworzenia w drużynie).
    *   **Run (Ucieczka):** Bezpieczne wycofanie się z potyczki.
4. **Zależności Typów (Type Advantages):** Klasyczny układ kamień-papier-nożyce. Ogień pokonuje Trawę, Trawa pokonuje Wodę, Woda pokonuje Ogień. Atak super-skuteczny zadaje 1.5x większe obrażenia i wyzwala potężne, dedykowane efekty cząsteczkowe.
5. **Rozwój Drużyny (Party & Experience):** Stworzenia zyskują PD (XP) za pokonanie lub złapanie przeciwników. Awans na kolejny poziom zwiększa maksymalne HP, Atak oraz Obronę.
6. **Leczenie (Healing Spot):** Odwiedzenie czerwonego kafelka szpitala w lewym górnym rogu mapy natychmiastowo przywraca pełne HP całej Twojej drużynie.

### Gatunki Stworzeń (Creature Species)
*   🔥 **Flamepup** & **Emberclaw** (Typ Ognisty / Fire) — Ataki: Ember, Fire Fang, Scratch, Blaze Rush
*   💧 **Aquafin** & **Tidalink** (Typ Wodny / Water) — Ataki: Splash, Tidal Crash, Bubble, Aqua Jet
*   🌿 **Leafling** & **Thornvine** (Typ Trawiasty / Grass) — Ataki: Vine Whip, Leaf Storm, Thorn Jab, Root Slam

---

## 🇬🇧 Game Description (English)

### Short Pitch (Elevator Pitch)
**Creature Collector** is an authentic retro Pokémon-inspired turn-based RPG. Explore a tile-based wilderness, navigate tall grass to trigger wild creature encounters, battle using type advantages, manage your 3-creature party, and catch wild beasts to complete your collection. With dynamic leveling, scaling stats, and smooth health transitions, it is a perfect tribute to Game Boy classics.

### Gameplay Loop & Mechanics
1. **Tile-Based Exploration:** Wander around a 25×18 overworld grid composed of grass, water, trees, pathways, and a dedicated healing center.
2. **Tall Grass Encounters:** Moving through grass tiles gives a 10% chance per step of triggering a wild creature attack.
3. **Tactical Battles:** Choose between:
    *   **Fight:** Select one of two creature-specific moves with variable power.
    *   **Catch:** Capture the wild beast. Capture rates scale based on enemy remaining HP (30% base, 40% at half-HP, 70% at quarter-HP).
    *   **Switch:** Swap your active team fighter (party limit of 3).
    *   **Run:** Safely escape the battle.
4. **Elemental Combat Triangle:** Fire melts Grass, Grass drinks Water, Water douses Fire. Super-effective hits deal 1.5× damage, trigger custom elemental particles, and shake the screen.
5. **Progression:** Defeating or catching foes grants XP, allowing creatures to level up, which scales their HP, ATK, and DEF.
6. **Rejuvenation:** Step on the red cross tile in the top-left to completely heal all fainted and damaged members of your squad.

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **W, A, S, D / ↑, ↓, ←, →** | Ruch postacią po mapie | Move player around the overworld |
| **1** | Wybór akcji 1 (Walka / Atak 1 / Start) | Action Option 1 (Fight / Move 1 / Start) |
| **2** | Wybór akcji 2 (Łapanie / Atak 2) | Action Option 2 (Catch / Move 2) |
| **3** | Wybór akcji 3 (Zmiana stworzenia) | Action Option 3 (Switch Creature) |
| **4** | Wybór akcji 4 (Ucieczka) | Action Option 4 (Run from Battle) |
| **Escape** | Wyjście z gry | Quit to OS |

---

## 🐉 Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
Gra nawiązuje bezpośrednio do pierwszych generacji gier **Pokémon Red/Blue/Yellow** (1996) wydanych na konsolę Nintendo Game Boy. Implementuje kluczowe filary tamtej rozgrywki:
*   Trójpolowy trójkąt żywiołów stanowiący fundament walki taktycznej.
*   Zasada step-encounters — nieprzewidywalność podróży przez dzikie trawy.
*   Zbieractwo i zapełnianie wewnętrznej bazy danych (Pokedex) jako główny warunek zwycięstwa (złapanie wszystkich 6 unikalnych stworzeń).

### Modernizacja w Lurek2D
Lurek2D dodaje wizualne zaawansowanie techniczne nieobecne na czarnobiałym ekranie Game Boya:
*   **Efekty Cząsteczkowe:** Walki wyzwalają kolorowe rozbryzgi cząsteczek reprezentujące typy ataków (czerwono-pomarańczowe dla ognia, niebieskie dla wody, zielone dla liści).
*   **Płynne Animacje (Tweens):** Paski HP nie spadają skokowo, lecz drenują się płynnie za pomocą interpolacji matematycznej napędzanej czasem delty.
*   **Praca Kamery:** Kamera płynnie podąża za pozycją gracza na mapie (`lurek.camera`), tworząc wrażenie ciągłości świata, i resetuje się do statycznego interfejsu podczas sceny walki.

---

## 🛠️ Wykorzystane API silnika Lurek2D / Lurek APIs Showcased

*   `lurek.camera`: Płynne śledzenie pozycji gracza w świecie kaflowym z automatycznymi ograniczeniami krawędzi mapy (`setPosition`) oraz resetowanie rzutowania dla stabilnego interfejsu walki i HUD (`reset`).
*   `lurek.render`: Rysowanie kafelkowej mapy overworld, szczegółów źdźbeł traw, minimalistycznego okręgu reprezentującego stwory oraz nakładek tekstowych (`rectangle`, `circle`, `print`, `setColor`).
*   `lurek.input`: Obsługa dwuosiowego systemu ruchu WASD oraz precyzyjne odczytywanie numerycznych klawiszy funkcyjnych do walki turowej za pomocą mapowania akcji (`bind`, `isActionDown`).
*   `lurek.window`: Aktualizacja paska tytułowego okna gry, w tym dynamiczne renderowanie FPS (`setTitle`).
*   `lurek.timer`: Precyzyjne odmierzanie czasu do wyciszania drgań kamery oraz kontrola płynności ruchu kafelkowego (`getFPS`, `delta time`).
*   `lurek.event`: Natychmiastowe i bezpieczne wyłączenie programu poprzez wywołanie zdarzenia `quit()`.

---

## 💎 Unikalność i Wartość Prezentacyjna / Showcase Value & Uniqueness

### Dlaczego ta gra jest wyjątkowa?
**Creature Collector** to kompletna, bogata mechanicznie gra RPG zaprogramowana w całości w jednym pliku skryptowym Lua. Jest to niesamowite narzędzie prezentacyjne silnika Lurek2D, ponieważ:
1.  **Łączy dwa zupełnie różne stany graficzne:** Zręcznościowy świat eksploracji w rzucie z góry (2D Top-Down Camera) oraz w pełni statyczną, turową arenę bitewną wywoływaną dynamicznie.
2.  **Zaawansowany minimap-renderer:** Renderuje w czasie rzeczywistym zmniejszony obraz kafelków z zaznaczoną kropką pozycji gracza, pokazując, jak łatwo pisać złożone transformacje rysowania 2D w Lurek2D.
3.  **Matematyczna Mechanika Walki:** Implementuje pełną formułę obliczania zadawanych obrażeń z uwzględnieniem statystyk Ataku napastnika, Obrony ofiary oraz modyfikatorów typów, co dowodzi przydatności silnika do rozwijania gier o złożonej matematyce RPG.

Nie jest to prosta, nudna gra o unikaniu przeszkód. To pełnoprawny, wciągający prototyp RPG, stanowiący świetny szablon dla przyszłych twórców chcących zbudować własną grę z łapaniem stworów!
