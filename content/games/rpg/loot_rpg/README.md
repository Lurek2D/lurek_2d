# 💎 Loot RPG — Procedural Dungeon Crawler Loot Grinder

**Category:** RPG / Inventory & Stat Progression  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Loot RPG** to uzależniająca gra typu dungeon crawler zorientowana na zbieranie łupów (lootu), optymalizowanie statystyk i ulepszanie ekwipunku. Przemierzaj kolejne piętra proceduralnych podziemi, walcz z potworami o coraz większej sile, zbieraj legendarne przedmioty o losowych statystykach i zarządzaj wagą swojego plecaka. Czy uda Ci się zbudować niepowstrzymaną postać (build) i pobić rekord oczyszczonych pokoi, zanim zabraknie Ci punktów HP?

### Pętla Rozgrywki i Mechaniki
1. **Eksploracja Pokoi (Room Progression):** Lochy pokonujesz pokój po pokoju. Każde kolejne 5 pokoi składa się na nowe piętro, co drastycznie podnosi trudność przeciwników, ale też zwiększa jakość wypadającego łupu.
2. **Automatyczna Walka Turowa (Combat):** Stajesz twarzą w twarz z różnymi rodzajami potworów (Gobliny, Szkielety, Orcy, Wampiry, Demony). Walka przebiega turowo. O Twojej sile decyduje wyłącznie jakość aktualnie ubranego sprzętu oraz odrobina szczęścia przy rzutach kośćmi.
3. **Zarządzanie Ekwipunkiem i Statystykami:** Postać posiada 5 dedykowanych slotów na wyposażenie:
    *   🗡️ **Weapon (Broń):** Zwiększa zadawane obrażenia (Damage).
    *   🛡️ **Armor (Pancerz) & Helm (Hełm):** Podnoszą obronę (Defense), redukując ciosy potworów.
    *   🥾 **Boots (Buty):** Zwiększają szybkość (Speed).
    *   💍 **Accessory (Pierścień):** Zapewnia bonus do maksymalnego zdrowia (HP Bonus).
4. **Proceduralne Generowanie Łupów (Looting):** Pokonanie wroga otwiera ekran skrzyń ze skarbcem. Przedmioty wypadają z uwzględnieniem jednego z 4 stopni rzadkości (Rarities):
    *   ⚪ **Common (Pospolity):** Mnożnik statystyk x1.0.
    *   🔵 **Rare (Rzadki):** Mnożnik statystyk x1.5.
    *   🟣 **Epic (Epicki):** Mnożnik statystyk x2.0.
    *   🟠 **Legendary (Legendarny):** Potężny mnożnik x3.0 (wyzwala złoty deszcz cząsteczek!).
5. **Wyczerpujący Ekwipunek (Backpack Weight):** Twój plecak posiada sztywne ograniczenie wagowe (**20 kg**). Każdy przedmiot (zwłaszcza ciężka zbroja) ma swoją wagę. Musisz stale decydować, co zachować, a co odrzucić.
6. **Sklep i Potencjalne Leczenie (Potion Merchant):** Pomiędzy pokojami możesz zakupić miksturę leczenia za 5 sztuk złota, przywracającą 30 punktów życia.

---

## 🇬🇧 Game Description (English)

### Short Pitch (Elevator Pitch)
**Loot RPG** is an engaging, mathematical procedural dungeon crawler focused entirely on loot cycles, stat customization, and equipment management. Descend floor-by-floor, vanquishing tough scaled monsters, rolling for legendary drop multipliers across 5 dedicated gear slots, and managing your weight-restricted backpack. Build an unstoppable warrior, purchase potions, and survive as long as possible before your HP drops to zero.

### Gameplay Loop & Mechanics
1. **Procedural Crawling:** Ascend rooms one at a time. Every 5 rooms represent a complete floor transition, which dramatically scales up enemy base stats and drops.
2. **Turn-Based Auto Combat:** Battle unique monster strains (Goblins, Slimes, Wraiths, Demons, Vampires). Combat rolls your attack values against enemy defenses in a fully simulated, gear-dependent turn system.
3. **5-Slot Gear Layout:** Equipping items instantly scales your active battlefield parameters:
    *   🗡️ **Weapon:** Scales up base physical Damage rolls.
    *   🛡️ **Armor & Helm:** Boosts passive Defense to mitigate incoming enemy blows.
    *   🥾 **Boots:** Enhances Speed modifiers.
    *   💍 **Accessory (Ring):** Grants a massive bonus to maximum HP (HP Bonus).
4. **Procedural Rarity System:** Defeating monsters rewards you with a chest containing up to 3 randomized items categorized into 4 beautifully color-coded tiers:
    *   ⚪ **Common:** Stat multiplier x1.0.
    *   🔵 **Rare:** Stat multiplier x1.5.
    *   🟣 **Epic:** Stat multiplier x2.0.
    *   🟠 **Legendary:** Stat multiplier x3.0 (triggers heavy gold particle fountains).
5. **Weight-Restricted Backpack:** Your inventory is limited to a strict weight capacity (**20 kg**). Heavy shields and swords take up substantial space, forcing you to prioritize what to keep, equip, or drop.
6. **Town Merchant Shop:** Safely spend gathered gold (5g each) to buy health potions that heal 30 HP.

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **Space** | Przejdź do pokoju / Zaatakuj w walce / Zbierz łupy | Advance room / Attack (combat) / Collect loot |
| **E** | Automatycznie załóż najlepsze przedmioty | Auto-equip best stats items from backpack |
| **B** | Kup miksturę leczenia (koszt: 5 złota) | Purchase health potion from merchant (5 gold) |
| **↑ / ↓** | Przewijaj listę plecaka w dół / w górę | Scroll inventory backpack list up / down |
| **Escape** | Wyjście z gry | Quit to OS |

---

## 🛡️ Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
Gra czerpie garściami z mechaniki losowości rodem z serii **Diablo** (Blizzard) oraz minimalistycznych tekstowych gier RPG z lat 80. (np. **Rogue** oraz gry typu **MUD**). Skupia się na:
*   Maksymalizacji współczynników liczbowych bohatera (damage, defense).
*   Kolorystycznym kodowaniu rzadkości przedmiotów, co stymuluje klasyczny pętlowy głód zdobywania coraz lepszego wyposażenia (loot spiral).
*   Strategicznej konieczności czyszczenia plecaka z bezużytecznych, ciężkich przedmiotów.

### Modernizacja w Lurek2D
Lurek2D przekształca ten klasyczny interfejs w pełne soczystości (game juice) przeżycie:
*   **Dwa Systemy Cząsteczkowe:** Złote fontanny cząsteczek przy otwieraniu skrzyń z legendarnym łupem (`lootSparkle`) oraz gwałtowne wybuchy czerwonej krwi podczas otrzymywania ciosów (`combatFlash`).
*   **Płynne Animacje (HP Drainage):** Interpolowanie zmian paska życia za pomocą matematycznego tweeningu (`lurek.tween`) gwarantuje estetyczną wizualizację utraty zdrowia.

---

## 🛠️ Wykorzystane API silnika Lurek2D / Lurek APIs Showcased

*   `lurek.particle`: Zarządzanie dwoma niezależnymi emiterami cząsteczek (`newSystem`, `emit`, `update`, `render`) dla uzyskania niesamowitego game juice podczas walki i zbierania skarbów.
*   `lurek.tween`: Dynamiczne i płynne kurczenie się paska HP za pomocą zoptymalizowanych funkcji ułatwień (`tween`).
*   `lurek.render`: Rysowanie przejrzystego interfejsu panelu bocznego, plecaka z obsługą przewijania suwakiem, pasków życia oraz logów bojowych (`rectangle`, `print`, `setColor`).
*   `lurek.input`: Mapowanie i odczytywanie klawiszy akcji (`bind`, `wasActionPressed`) dla pełnej kontroli nad ubiorem, zakupami i przemieszczaniem.
*   `lurek.camera`: Inicjalizacja stabilnego rzutowania kamery dla zachowania idealnej ostrości pixel-artowej czcionki.
*   `lurek.window` & `lurek.event`: Dynamiczne aktualizowanie paska nazwy okna o aktualne piętro (`setTitle`) oraz bezpieczne kończenie gry (`quit`).

---

## 💎 Unikalność i Wartość Prezentacyjna / Showcase Value & Uniqueness

### Dlaczego ta gra jest wyjątkowa?
**Loot RPG** to doskonała demonstracja **zaawansowanej bazy danych statystyk i struktur danych w Lua** zintegrowanej z silnikiem Lurek2D:
1.  **Pokazuje kompletny silnik statystyk RPG:** Implementuje sumowanie atrybutów z 5 osobnych slotów wyposażenia, automatyczne porównywanie wydajności przedmiotów z plecaka i dynamiczne obliczanie modyfikatora wagi.
2.  **Świetny interfejs backpack scrollingu:** Obsługuje w pełni interaktywne przewijanie listy przedmiotów w plecaku za pomocą klawiatury, co pokazuje stabilność i precyzję wejściową Lurek2D.
3.  **Optymalne wykorzystanie tweenów i cząsteczek:** Bez spowalniania gry silnik przetwarza dziesiątki instancji cząsteczek na sekundę, dodając niesamowitej dynamiki do prostej prezentacji tekstowej.

To kapitalna inspiracja dla programistów pragnących zaprojektować własną grę z zaawansowaną ekonomią przedmiotów, statystykami i głębokim systemem ekwipunku na silniku Lurek2D!