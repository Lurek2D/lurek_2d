# 🗺️ Wargame — Turn-Based Hex Tactics

**Category:** Strategy / Hex-Grid Military Simulation  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Wargame** to zaawansowana wojskowa gra strategiczna na planszy heksagonalnej, będąca głębokim hołdem dla kultowych serii, takich jak *Panzer General*, *Hexagon Strategy* oraz gry planszowe wydawnictwa *Avalon Hill*. Dowódź połączonymi siłami militarnymi (piechota, czołgi, artyleria, zwiad) na heksagonalnej mapie o wymiarach 14x9 pól o zróżnicowanej topografii (równiny, góry, lasy, strategiczne miasta z zaopatrzeniem). Gra oferuje pełen turowy system dowodzenia, rygorystyczne modyfikatory bojowe i ruchowe wynikające z ukształtowania terenu, inteligentnego przeciwnika AI oraz dynamiczny log walki. To niesamowity pokaz możliwości silnika Lurek2D w zakresie obliczeń matematycznych na siatkach heksagonalnych.

### Pętla Rozgrywki i Mechaniki
1. **Siatka Heksagonalna (Hex Math):**
   - Plansza oparta jest na heksach z płaską górą (flat-top hexes) w układzie przesuniętym (offset coordinate system).
   - Silnik gry przelicza w czasie rzeczywistym pozycję kursora myszy na współrzędne heksagonalne oraz oblicza odległości heksagonalne (Hex Distance) przy użyciu konwersji na trójwymiarowe współrzędne sześcienne (Cube Coordinates).
2. **Katalog Jednostek Bojowych:**
   - **Infantry (Piechota - INF):** 10 HP, 5 ATK, 1 DEF, 2 Ruch, Zasięg 1. Trzon armii, dobrze radzi sobie w lasach i miastach.
   - **Tank (Czołg - TNK):** 16 HP, 9 ATK, 2 DEF, 3 Ruch, Zasięg 1. Pancerna szpica bojowa o dużej sile ognia, lecz **nie może wkraczać w góry**.
   - **Artillery (Artyleria - ART):** 8 HP, 12 ATK, 0 DEF, 1 Ruch, Zasięg 3. Jednostka dalekiego zasięgu, idealna do niszczenia wrogich pozycji z dystansu.
   - **Recon (Zwiad - RCN):** 6 HP, 3 ATK, 0 DEF, 4 Ruch, Zasięg 2. Mobilny zwiad zdolny do szybkiego zajmowania pozycji.
3. **Wpływ Terenu na Taktykę:**
   - **Plain (Równina):** Brak bonusów. Standardowa walka.
   - **Forest (Las):** Daje **+1 do obrony** wrogim atakom, ale wjazd kosztuje dodatkowe punkty ruchu.
   - **Mountain (Góry):** Daje **+2 do obrony**. Całkowicie zablokowane dla czołgów (TNK).
   - **City (Miasto):** Daje **+2 do obrony**. Stanowi strategiczny punkt zaopatrzenia.
4. **Faza AI i Cel Walki:**
   - Po wykonaniu akcji (ruch + atak) swoimi jednostkami, naciśnij **Enter**, aby oddać turę wrogowi.
   - Przeciwnik AI przeanalizuje rozstawienie, przesunie swoje oddziały w kierunku Twoich sił i przeprowadzi ataki. Zniszcz wszystkie wrogie jednostki, by wygrać!

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Wargame** is a sophisticated, turn-based military simulator on a hexagonal grid, standing as a direct mechanical tribute to legendary tabletop and digital classics like *Panzer General*, *Hexagon Strategy*, and *Avalon Hill* board games. Command a combined-arms division consisting of Infantry, Tanks, Artillery, and Recon vehicles across a 14x9 hex grid featuring varied terrain layouts (plains, mountains, forests, and supply-hub cities). Model strict combined-arms matchups: fire artillery from afar, cross open plains with swift armor divisions, and capture cities with garrisoned infantry. With a dynamic floating text log and advanced hexagonal grid calculations, this is Lurek2D's premier demonstration of mathematical coordinate translations!

### Gameplay Loop & Mechanics
1. **Hexagonal Coordinate Math:**
   - Built on flat-topped hexagonal tiles organized in an offset coordinate layup.
   - The engine translates pixel cursor positions into hex coordinates and calculates accurate Hex Distances by converting 2D offset coordinates into 3D Cube Coordinates behind the scenes.
2. **Combined-Arms Roster:**
   - **Infantry (INF):** 10 HP, 5 ATK, 1 DEF, 2 Move, 1 Range. Excellent for holding cities and navigating forests.
   - **Tank (TNK):** 16 HP, 9 ATK, 2 DEF, 3 Move, 1 Range. Powerful armor breakthrough unit, but **blocked from entering mountains**.
   - **Artillery (ART):** 8 HP, 12 ATK, 0 DEF, 1 Move, 3 Range. Support asset that fires devastating bombardment over obstacles.
   - **Recon (RCN):** 6 HP, 3 ATK, 0 DEF, 4 Move, 2 Range. High mobility scout to flank defenses.
3. **Strategic Terrain Modifiers:**
   - **Plain:** Standard grass land, no modifiers.
   - **Forest:** Grants **+1 Defense** against incoming strikes, but incurs movement cost.
   - **Mountain:** Grants **+2 Defense** and represents impassable high ground for Tanks.
   - **City:** Grants **+2 Defense** and serves as a vital strategic stronghold.
4. **Autonomous AI Turn & Victory:**
   - Click a unit to move (blue hex highlight) and attack (red hex highlight). Press **Enter** to pass the phase.
   - The opposing military AI dynamically prioritizes targets, repositions forces, and conducts tactical counter-attacks. Eliminate all enemy divisions to win!

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/wargame
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB (Klik)** | Zaznacz / Ruch / Atak | Zaznacza jednostkę, wskazuje niebieski heks do ruchu lub czerwony do ataku wroga. |
| **Enter** | Zakończ turę (End Turn) | Przekazuje turę przeciwnikowi (faza AI). |
| **Esc** | Wyjście (Quit) | Zamyka grę w bezpieczny sposób. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Panzer General (1994) by Strategic Simulations, Inc. (SSI)**
  - *Opis powiązania*: Bezpośrednie mechaniczne natchnienie: siatka heksagonalna z płaską górą, kombinacja jednostek (INF, TNK, ART, RCN), paski HP pod ikonami, teren wpływający na obronę oraz ograniczenia ruchu czołgów w górach.
- **Battle for Wesnoth**
  - *Opis powiązania*: Wdrożenie wyraźnego podziału na heksy lasów, gór i miast dających różne współczynniki ochrony w zależności od zajmowanego kafelka.
- **Kriegspiel / Avalon Hill Games**
  - *Opis powiązania*: Autentyczna prezentacja wojskowa o szarych i niebieskich barwach taktycznych sztabu oraz obecność Combat Logu podsumowującego wymianę ognia w turze.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

- `lurek.input` – Zaawansowane pobieranie współrzędnych myszy i transformacja na pozycje w układzie heksagonalnym. Obsługa Spacji i Enter do kontroli tur.
- `lurek.render` – Rysowanie siatki heksów o płaskiej górze, podświetlanie zasięgów (`rect` z alfą), wskaźniki HP oraz tekst dynamicznego dziennika bitewnego na dole ekranu.
- `lurek.window` / `lurek.event` – Inicjalizacja okna gry (880x600 px) z unikalnym tytułem i powrotem przy klawiszu Esc.
- **Trzy Wyspecjalizowane Systemy Cząsteczek (Multiple Particle Systems):**
  - *Rozbłysk walki (Attack Sparks)*: Jasnożółty i pomarańczowy gejzer iskier tryskający w miejscu trafienia.
  - *Wybuch zniszczenia (Death Sparks)*: Duży wybuch czerwono-czarnych cząsteczek oznaczający eliminację jednostki i dodanie wyniku do Score.
  - *Kurz marszowy (Move Dust)*: Jasnobrązowe cząsteczki pyłu unoszące się za czołgami i zwiadem podczas ruchu po bezdrożach.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Niesamowity pokaz czystej logiki matematycznej i geometrii w skryptach Lua. Prezentuje algorytmy konwersji heksów offsetowych na współrzędne sześcienne (Cube Coordinates) w celu sprawnego mierzenia dystansu (Hex Distance) i określania prawidłowych sąsiedztw pól bez uciekania się do uproszczeń kwadratowych.
- **Unikalność (Uniqueness):** Jedyna gra w całej bibliotece silnika wykorzystująca w 100% pełne heksy i mechanikę walki połączonych sił zbrojnych w taktycznym ujęciu sztabowym.
- **Podobne gry (Similar Games):** Dzieli turowy i siatkowy charakter z `tactical_battle` oraz `hex_strategy`, jednak wyróżnia się zastosowaniem heksów offsetowych zamiast kwadratów i stricte militarnym sztabowym charakterem.
