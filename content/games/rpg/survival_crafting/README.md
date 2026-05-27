# 🌲 Survival Crafting — Grid-Based Wilderness Survival Game

**Category:** RPG / Survival & Crafting Simulation  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Survival Crafting** to wciągająca, taktyczna gra survivalowa w świecie kaflowym. Twoim zadaniem jest przetrwanie w dzikim, nieprzyjaznym środowisku pełnym lasów, skał i zbiorników wodnych. Zbieraj drewno, ciosaj kamienie, zbieraj pożywne owoce leśne, wytwarzaj zaawansowane narzędzia w menu rzemiosła (Crafting) i stawiaj drewniane palisady. Przygotuj się dobrze przed nadejściem nocy, kiedy to z mroku wyłaniają się krwiożercze bestie polujące na Twoje życie!

### Pętla Rozgrywki i Mechaniki
1. **Eksploracja i Zbieractwo:** Poruszasz się krokowo po siatce 25x18 kafelków. Podejdź do surowca i wciśnij Spację, aby rozpocząć wydobycie (Mining):
    *   🌳 **Trees (Drzewa):** Dają 2 sztuki drewna (Wood).
    *   🪨 **Stones (Skały):** Dają 2 sztuki kamienia (Stone).
    *   🍓 **Berry Bushes (Krzewy):** Dają 3 owoce leśne (Berry).
2. **System Przetrwania (Survival):** Stale monitorujesz dwa kluczowe wskaźniki:
    *   🍖 **Głód (Hunger):** Spada z czasem. Gdy osiągnie 0, zaczniesz drastycznie tracić punkty życia. Jedz owoce (klawisz B), aby przywracać głód (+20%).
    *   ❤️ **Zdrowie (HP):** Spada z głodu lub w wyniku obrażeń zadawanych przez potwory. Utrata HP do 0 oznacza śmierć.
3. **Menu Rzemiosła (Crafting - C):** Otwórz okno rzemiosła, aby tworzyć:
    *   🛠️ **Pickaxe (Kilof):** Kosztuje 2 drewna + 3 kamienie. Zmniejsza czas wydobycia surowców o połowę (z 1.0s do 0.5s).
    *   🧱 **Wall Block (Palisada):** Kosztuje 4 drewna. Służy do zabezpieczania bazy.
4. **Budowanie Fortyfikacji (P):** Wciśnij P, aby postawić blok palisady na kafelku przed sobą. Palisady tworzą fizyczne bariery, blokując ruch potworów!
5. **Cykl Dnia i Nocy:** Każda doba trwa 60 sekund. W 36. sekundzie dnia zapada zmierzch (ekran płynnie ciemnieje). Wtedy rozpoczyna się nocny najazd wrogów. Wraz z nadejściem świtu potwory ulatniają się, dając Ci czas na odbudowę i zbiory.
6. **Nocne Potwory (Enemies):** Czerwone bestie spawnują się na krawędziach i tropią pozycję gracza w czasie rzeczywistym.

---

## 🇬🇧 Game Description English

### Short Pitch (Elevator Pitch)
**Survival Crafting** is a grid-based top-down survival simulation. Gather timber, quarry stones, pick fresh berries, craft highly efficient pickaxes or structural wall blocks in the crafting menu, and fortify your campsite. You must build secure barriers before twilight falls, as aggressive nocturnal entities emerge from the map borders to hunt you down. Manage hunger, health, and barricades to survive as many days as possible.

### Gameplay Loop & Mechanics
1. **Grid Exploration & Mining:** Navigate a randomized 25×18 tile wilderness. Step adjacent to resources and press Space to mine:
    *   🌳 **Trees:** Yield 2 units of Wood.
    *   🪨 **Stones:** Yield 2 units of Stone.
    *   🍓 **Berry Bushes:** Yield 3 Berries.
2. **Biological Survival Gauges:**
    *   🍖 **Hunger:** Drains constantly (-2/s). At zero hunger, starvation kicks in, draining health directly. Consume berries (B) to restore hunger (+20).
    *   ❤️ **Health (HP):** Drains from starvation or monster attacks. Reaching zero triggers permanent death.
3. **Crafting Blueprints (C):** Open the overlaid menu to fabricate:
    *   🛠️ **Pickaxe:** Costs 2 wood + 3 stones. Halves mining delay from 1.0s down to a rapid 0.5s.
    *   🧱 **Wall Block:** Costs 4 wood. Essential for building defensive perimeters.
4. **Structural Barricading (P):** Press P to deploy a solid wooden wall block in your facing direction. Barricades block paths, trapping enemy movement vectors!
5. **Day / Night Engine:** A full 24-hour cycle runs for 60 seconds. Nightfall begins at `NIGHT_START = 0.6` (36 seconds in), dimming the screen to a deep blue ambient overlay. Enemies spawn at night and despawn automatically at dawn.

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **W, A, S, D / Strzałki** | Ruch postacią po siatce kafelków | Move player step-by-step |
| **Space** | Wydobywaj surowiec z sąsiedniego pola | Mine adjacent resource tile |
| **C** | Otwórz / Zamknij menu rzemiosła (Crafting) | Open / Close Crafting Menu overlay |
| **P** | Postaw palisadę obronną przed sobą | Place defensive wall block in facing direction |
| **B** | Zjedz owoc leśny, aby zaspokoić głód | Eat a berry to restore hunger status |
| **Enter** | Rozpocznij grę (z ekranu tytułowego) | Start / Restart game from titles |
| **Escape** | Wyjście z gry | Quit to OS |

---

## 🌲 Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
Gra nawiązuje do klasyków z gatunku survivalu i budowania baz, takich jak **Don't Starve**, **Minecraft 2D**, **Terraria** oraz klasycznych gier przygodowych RPG ze zbieraniem zasobów. Dzieli z nimi fundamentalne cechy:
*   Konieczność dbania o podstawowe funkcje życiowe (głód).
*   Podział doby na bezpieczny dzień (zbiory) oraz niebezpieczną noc (walka o przetrwanie).
*   Możliwość fizycznego modyfikowania mapy poprzez wznoszenie budowli ochronnych.
*   System ulepszania narzędzi skracających czas wykonywania czynności.

### Modernizacja w Lurek2D
Lurek2D dodaje wizualne zaawansowanie techniczne podnoszące jakość gry:
*   **Systemy Cząsteczek Debris:** Każde uderzenie kilofa w skałę lub siekiery w drzewo wyzwala chmury drobnych odłamków i liści (`spawn_particles`), nadając zjawisku wydobywania dużą dynamikę.
*   **Płynne Śledzenie Kamery (`lurek.camera`):** Kamera nie porusza się skokowo razem z graczem, lecz płynnie amortyzuje ruch i dopasowuje współrzędne, tworząc wrażenie niezwykle płynnego przemieszczania świata.
*   **Płynne Przejście Nocy:** Wykorzystanie matematycznej delty czasu pozwala na stopniowe i nastrojowe ściemnianie świata, budując fantastyczne poczucie nadchodzącego zagrożenia.

---

## 🛠️ Wykorzystane API silnika Lurek2D / Lurek APIs Showcased

*   `lurek.camera`: Płynna, amortyzowana matematycznie amortyzacja kamery za pozycją gracza w świecie kaflowym (`setPosition`).
*   `lurek.render`: Rysowanie kaflowego świata, szczegółów obiektów (drzewa, kamienie, owoce), oczu gracza, paska postępu wydobywania, pasków HUD oraz pełnego menu craftingu (`rectangle`, `circle`, `print`, `setColor`).
*   `lurek.input`: Obsługa ruchu WASD na siatce, sprawdzanie zdarzeń ciągłych (`isActionDown` dla sprawnego ruchu) oraz akcji jednostkowych (`wasActionPressed` dla otwierania menu, budowania, jedzenia).
*   `lurek.window` & `lurek.event`: Wyświetlanie FPS w pasku okna gry (`setTitle`) oraz bezpieczne zamknięcie programu (`quit`).
*   `lurek.timer`: Dostarczanie czasu delty klatek do kontroli prędkości potworów, opadania głodu i animacji cząsteczek.

---

## 💎 Unikalność i Wartość Prezentacyjna / Showcase Value & Uniqueness

### Dlaczego ta gra jest wyjątkowa?
**Survival Crafting** to jeden z najbardziej kompletnych mechanicznie i wciągających projektów RPG w Lurek2D:
1.  **Pokazuje pełną modyfikację środowiska gry:** Gracz może niszczyć kafelki surowców i wznosić na ich miejscu fizyczne palisady obronne, co uczy deweloperów obsługi dynamicznych tablic dwuwymiarowych.
2.  **Zaawansowana Fizyka Kolizji Potworów:** AI potworów wyszukuje ścieżki i omija postawione palisady, co dowodzi świetnego zintegrowania kolizji w silniku.
3.  **Klimatyczny Cykl Dobowy:** Płynna zmiana tonacji kolorystycznej świata i wskaźników bio-fizycznych (głód wpływający na HP) tworzy głęboki, dojrzały gameplay.

To idealny, inspirujący kodowo szablon dla każdego twórcy pragnącego stworzyć grę typu survival, budowanie baz, RPG akcji lub symulację rzemiosła w silniku Lurek2D!
