# ☖ Tactical Battle — Turn-Based Squad Tactics

**Category:** Strategy / Tactical Turn-Based RPG  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Tactical Battle** to wciągająca strategiczna gra turowa, będąca bezpośrednim hołdem dla legendarnych serii, takich jak *Fire Emblem* oraz *Final Fantasy Tactics*. Gracz przejmuje kontrolę nad 5-osobowym elitarnym oddziałem (Żołnierz, Łucznik, Rycerz, Mag) i stawia czoła wrogiemu oddziałowi na siatce taktycznej o wymiarach 12x9 pól. Gra oferuje rozbudowany system walki z podziałem na tury, zróżnicowane klasy postaci o unikalnych statystykach (punkty ruchu, zasięg ataku, współczynnik obrony), modyfikatory terenowe (lasy dające premię do obrony, nieprzejezdna woda) oraz inteligentną turę przeciwnika sterowaną przez AI. To wspaniała prezentacja silnika Lurek2D w zakresie obsługi stanów turowych, renderowania siatek kaflowych i dynamicznych rejestrów walki (Combat Log).

### Pętla Rozgrywki i Mechaniki
1. **System Tur i Akcji:**
   - Każda tura należy w całości do gracza lub wroga.
   - Każda jednostka może w swojej turze wykonać **ruch** oraz **atak** (kolejność ma znaczenie). Jednostki w pełni zużyte zostają wyszarzone.
   - Po wykonaniu wszystkich akcji gracz naciska klawisz **Enter**, aby przekazać turę przeciwnikowi.
2. **Katalog Klas Bojowych:**
   - **Soldier (Żołnierz - S):** 20 HP, 6 ATK, 1 DEF, 3 Ruch, Zasięg 1. Zrównoważona jednostka piechoty.
   - **Knight (Rycerz - K):** 30 HP, 7 ATK, 3 DEF, 4 Ruch, Zasięg 1. Pancerny obrońca o dużej mobilności, lecz podatny na magię.
   - **Archer (Łucznik - A):** 14 HP, 9 ATK, 0 DEF, 2 Ruch, Zasięg 3. Jednostka dystansowa, idealna do nękania wrogów zza osłony.
   - **Mage (Mag - M):** 12 HP, 12 ATK, 0 DEF, 2 Ruch, Zasięg 2. Potężna siła ognia ignorująca pancerz wroga.
3. **Modyfikatory Terenu:**
   - **Plains (Równina):** Podstawowy teren, brak modyfikatorów.
   - **Forest (Las):** Daje **+1 do obrony** jednostce stojącej na tym polu (redukuje obrażenia).
   - **Water (Woda):** Całkowicie nieprzejezdna bariera taktyczna.
4. **Faza AI i Warunki Zwycięstwa:**
   - W turze wroga sztuczna inteligencja podejmuje racjonalne decyzje: wyszukuje najbliższe jednostki gracza, przemieszcza się ku nim i wykonuje precyzyjne ataki.
   - Pokonaj wszystkie jednostki wroga, aby wygrać! Jeśli wszystkie Twoje jednostki zostaną zniszczone, gra kończy się porażką.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Tactical Battle** is a deep, highly engaging turn-based squad tactics game directly inspired by legendary tactical hits like *Fire Emblem* and *Final Fantasy Tactics*. Command a specialized 5-unit roster (Soldier, Archer, Knight, Mage) against an opposing AI force on a 12x9 tactical grid. The game models classic strategy systems including discrete grid movement, unit action exhaustion, terrain defense multipliers (forest cover vs impassable water hazards), and individual class stats (move speeds, attack ranges, armor values). With a dynamic combat log overlay and distinct visual unit shading, this is a premium demonstration of turn-based state machines built entirely in Lurek2D!

### Gameplay Loop & Mechanics
1. **Turn & Action Structure:**
   - Gameplay shifts between dedicated Player and Enemy turn phases.
   - Each unit may **Move** and **Attack** once per turn. Exhausted units are shaded gray.
   - Press **Enter** at any time to pass the phase and let the enemy AI plan its maneuvers.
2. **Specialized Combat Classes:**
   - **Soldier (S):** 20 HP, 6 ATK, 1 DEF, 3 Move, 1 Range. Reliable frontline trooper.
   - **Knight (K):** 30 HP, 7 ATK, 3 DEF, 4 Move, 1 Range. Heavy ironclad tank with high mobility.
   - **Archer (A):** 14 HP, 9 ATK, 0 DEF, 2 Move, 3 Range. Snipes high-value targets from afar.
   - **Mage (M):** 12 HP, 12 ATK, 0 DEF, 2 Move, 2 Range. Destructive spells that bypass basic defenses.
3. **Tactical Terrain Layout:**
   - **Plains:** Flat grass tiles, standard movement and defense.
   - **Forest:** Grants **+1 Defense** to any occupant, reducing incoming physical strikes.
   - **Water:** Impassable deep channels forming natural choke points.
4. **AI Behavior & Win Conditions:**
   - The enemy AI evaluates the board, seeking out your weakest units, closing distances, and executing coordinated attacks.
   - Annihilate all enemy forces to secure victory. If your roster is wiped out, you face defeat!

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/tactical_battle
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB (Klik)** | Wybór / Ruch / Atak | Wybiera jednostkę, wskazuje niebieskie pole do ruchu lub czerwone do ataku wroga. |
| **Enter** | Zakończ turę (End Turn) | Przekazuje turę przeciwnikowi (uruchamia fazę AI). |
| **Esc** | Wyjście (Quit) | Zamyka grę w bezpieczny sposób. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Fire Emblem (Seria) by Intelligent Systems / Nintendo**
  - *Opis powiązania*: Bezpośrednie odwzorowanie pętli rozgrywki: klasy postaci z charakterystycznymi skrótami (S, A, K, M), siatka taktyczna lasów i rzek, paski HP pod ikonami jednostek oraz wyszarzenie postaci po wykonaniu akcji.
- **Final Fantasy Tactics (1997) by Square**
  - *Opis powiązania*: Wdrożenie precyzyjnych modyfikatorów terenowych dających przewagi defensywne oraz obecność maga rzucającego niszczycielskie zaklęcia dystansowe.
- **Heroes of Might and Magic (Seria)**
  - *Opis powiązania*: Koncepcja turowego starcia dwóch oddziałów na wydzielonej planszy taktycznej z widocznymi zasięgami ruchu (niebieskie nakładki) i ataku (czerwone nakładki).

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

- `lurek.input` – Pobieranie koordynatów myszy oraz translacja na indeksy siatki kaflowej (wiersz/kolumna). Obsługa klawisza Enter do płynnego przełączania stanów tur.
- `lurek.render` – Rysowanie siatki bitewnej, nakładek zasięgu ruchu (`rect` z alfą), wskaźników HP oraz tekstu logu bojowego przy użyciu dynamicznych zmian kolorów (`setColor`).
- `lurek.window` / `lurek.event` – Inicjalizacja stabilnej rozdzielczości okna gry i bezpieczne zamykanie procesu silnika przy Esc.
- **Aż Trzy Systemy Cząsteczek (Multiple Particle Systems):**
  - *Iskry ataku (Attack Sparks)*: Tryskające pomarańczowo-żółte iskry generowane w punkcie uderzenia przy każdym ataku.
  - *Rozbłysk śmierci (Death Burst)*: Intensywny wybuch ciemnoczerwonych i pomarańczowych cząsteczek przy eliminacji jednostki z planszy.
  - *Pył ruchu (Movement Dust)*: Lekkie, brązowo-szare chmurki kurzu unoszące się pod stopami jednostki w momencie przemieszczenia na nowe pole.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Doskonały przykład implementacji deterministycznej logiki taktycznej na siatce. Pokazuje, jak w czystym skrypcie Lua zrealizować wyszukiwanie ścieżek zasięgu ruchu, warunki kolizji z terenem oraz prostą, lecz niezwykle satysfakcjonującą sztuczną inteligencję przeciwnika.
- **Unikalność (Uniqueness):** Jedyny taktyczny bitewniak turowy na siatce w całym portfolio gier. Stawia na czystą taktykę szachową, eliminując losowość fizyczną i zręcznościową na rzecz planowania rozstawienia jednostek.
- **Podobne gry (Similar Games):** Gra dzieli turowy charakter z `wargame` oraz `card_game`, jednak wyróżnia się zastosowaniem klasycznej kwadratowej siatki taktycznej i naciskiem na RPG-owe zróżnicowanie klas jednostek (np. walka wręcz rycerzy vs dystansowe strzały łuczników).
