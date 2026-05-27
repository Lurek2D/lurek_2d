# 🚀 Star Voyage — Retro 2D Space Exploration RPG

**Category:** RPG / Space Exploration  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Star Voyage** to kosmiczna gra fabularno-eksploracyjna bezpośrednio inspirowana klasycznym arcydziełem **Star Control II** (1992). Wciel się w rolę dowódcy gwiezdnego krążownika, przemierzaj rozległą galaktykę, ląduj na obcych planetach, nawiązuj stosunki dyplomatyczne z pozaziemskimi cywilizacjami oraz podejmuj trudne wybory w nieliniowych dialogach. Zbieraj cenne surowce, ostrzegaj stacje orbitalne przed wiszącym zagrożeniem Ur-Quanów i doprowadź swoją misję badawczą do sukcesu, zanim zabraknie Ci paliwa!

### Pętla Rozgrywki i Mechaniki
1. **Fizyka Lotu Kosmicznego (Ship Physics):** Sterujesz statkiem kosmicznym z uwzględnieniem bezwładności, obrotu wokół własnej osi, ciągu silników (Thrust) oraz oporu grawitacyjnego (Drag). Wciskanie ciągu zużywa paliwo.
2. **Eksploracja Galaktyki (Space Exploration):** Podróżujesz po wirtualnym obszarze o wymiarach 1400x1000 pikseli. Świat gry zawija się na krawędziach (world wrap), zapewniając wrażenie nieskończoności kosmosu.
3. **Paralaksowe Tło (Parallax Starfield):** Trójwarstwowe gwiezdne niebo generowane z unikalnego ziarna losowości (`newRandomGenerator`) przemieszcza się z różnymi prędkościami, dając wspaniałe poczucie głębi trójwymiarowej.
4. **Dokowanie i Dyplomacja (Docking):** Zbliżenie się do planety umożliwia zadokowanie (Space). Odwiedzone planety oznaczane są zielonym pierścieniem na mapie. W grze znajduje się 5 unikalnych światów:
    *   🌌 **Vela Prime** — Handlarze rzadkimi minerałami.
    *   🛰️ **Keth Station** — Stacja badawcza ostrzegająca przed flotą Ur-Quan.
    *   🌿 **Myrrh World** — Pokojowo nastawiona rasa szukająca sojuszników przeciw piratom.
    *   ☄️ **Debris Field** — Pole szczątków z automatyczną boją ratunkową.
    *   🌍 **Homeworld** — Sztab admirała floty, w którym zdajesz raporty z wyprawy.
5. **Nieliniowy System Dialogowy:** Wykorzystuje silnik `library.dialog` z zaawansowanymi węzłami wyboru (`choice`) oraz węzłami funkcjonalnymi (`call`), które wykonują w locie kod Lua w zależności od wybranej opcji, aby dynamicznie generować odpowiedzi rozmówców.

---

## 🇬🇧 Game Description (English)

### Short Pitch (Elevator Pitch)
**Star Voyage** is a space-exploration RPG deeply inspired by the retro MS-DOS classic **Star Control 2** (1994). Step into the captain's deck of a scouting starship, pilot using inertia-based momentum physics through a vast seed-generated parallax starfield, dock at colorful alien homeworlds, and engage in branching diplomatic dialogues. Manage your fuel, explore the sector boundaries, warn outposts of the imminent Ur-Quan threat, and report findings to the Admiral.

### Gameplay Loop & Mechanics
1. **Space Inertia Physics:** Rotate and thrust through open space. Navigation accounts for realistic momentum, thrust drag damping, and automatic boundary wrapping (1400×1000 virtual space).
2. **Seeded Parallax Universe:** Features 180 stars distributed across 3 parallax layers using Lurek's custom `newRandomGenerator` math API, providing an immersive depth effect as your camera scrolls.
3. **Planet Docking (Space):** Approach alien circles to dock. Visited planets are highlighted with a glowing green ring indicator. Explore 5 distinct worlds:
    *   🌌 **Vela Prime:** Mineral merchants trading precious belt ores.
    *   🛰️ **Keth Station:** Scrambled outpost warning of Ur-Quan dreadnought war patrols.
    *   🌿 **Myrrh World:** Pacifist agricultural aliens seeking anti-piracy protection.
    *   ☄️ **Debris Field:** Ruined hulls broadcasting automated distress beacons.
    *   🌍 **Homeworld:** The military command root where you submit sector progress to your Admiral.
4. **Narrative Dialogue Engine:** Utilizes the `library.dialog` parser, supporting conversational branching (`choice`) and callable procedural responses (`call` nodes) that evaluate dynamic Lua return tables based on your key choices.

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **W / ↑** | Ciąg silników do przodu (zużywa paliwo) | Fire forward thrusters (consumes fuel) |
| **A / D / ← / →** | Obrót statku w lewo / w prawo | Rotate ship left / right |
| **Space** | Dokowanie na pobliskiej planecie / Dalej | Dock at nearby planet / Advance dialogue line |
| **1 / 2 / 3** | Wybór opcji dialogowej (podczas narad) | Select branching dialogue option (during discussions) |
| **Escape** | Wyjście z gry | Quit to OS |

---

## 🌌 Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
Gra oddaje hołd pionierskiemu **Star Control II: The Ur-Quan Masters** (Toys for Bob, 1992), uznawanemu za jedną z najlepszych space-oper w historii gier. Odtwarza charakterystyczne cechy tamtej rozgrywki:
*   Fizyka bezwładności i kontroli ciągu statku kosmicznego na płaszczyźnie 2D.
*   Zbliżenia na planety otoczone barwną poświatą atmosferyczną.
*   Charakterystyczny układ ekranu dialogowego z portretem kosmity (dopasowanym kolorystycznie do typu planety) oraz oknem dialogowym na dole.
*   System raportów militarno-ekonomicznych.

### Modernizacja w Lurek2D
Lurek2D wspaniale optymalizuje i wzbogaca to doświadczenie za pomocą zintegrowanych bibliotek:
*   **Modularny Silnik Dialogowy (`library.dialog`):** Wykorzystanie zintegrowanego modułu dialogowego z węzłami funkcyjnymi (`call`) pozwala na pisanie niezwykle złożonych drzew dialogowych bezpośrednio w skryptach Lua, bez potrzeby rozwijania skomplikowanych parserów.
*   **Optymalny Paralakser wektorowy:** Rysowanie i aktualizacja 180 warstwowych gwiazd w czasie rzeczywistym zachowuje idealne 60 klatek na sekundę bez obciążania pamięci.

---

## 🛠️ Wykorzystane API silnika Lurek2D / Lurek APIs Showcased

*   `library.dialog` (`require("library.dialog")`): Zaawansowane zarządzanie przebiegiem nieliniowych konwersacji przy użyciu węzłów typu `line`, `choice` oraz dynamicznych wywołań zwrotnych `call`.
*   `lurek.math.newRandomGenerator`: Tworzenie deterministycznego i spójnego układu ciał niebieskich oraz gwiazd w oparciu o sztywne ziarno generatora (`rng`).
*   `lurek.render`: Rysowanie trójkątnego wielokąta statku (`polygon`), atmosfer planet (`circle`), nakładek HUD oraz paneli dialogowych z obramowaniami (`rectangle`, `print`, `setColor`).
*   `lurek.input`: Sprawdzanie stanów ciągłych klawiatury (`isActionDown`) dla fizyki sterowania ciągiem statku.
*   `lurek.camera`: Płynne śledzenie pozycji statku w galaktyce z automatyczną adaptacją współrzędnych ekranu.
*   `lurek.window` & `lurek.event`: Ustawianie paska okna z licznikiem FPS (`setTitle`) oraz bezpieczne wyjście z gry (`quit`).

---

## 💎 Unikalność i Wartość Prezentacyjna / Showcase Value & Uniqueness

### Dlaczego ta gra jest wyjątkowa?
**Star Voyage** to wyśmienity dowód na to, jak za pomocą **kilkuset linijek czystego kodu Lua** można stworzyć rozbudowaną grę o eksploracji kosmosu w Lurek2D:
1.  **Pokazuje dynamiczne programowanie dialogów:** Dzięki węzłom `call` gra udowadnia, że drzewa dialogowe w Lurek2D nie muszą być statyczne — mogą reagować na zmienne gry, wykonywać kod Lua i modyfikować stan w czasie rzeczywistym.
2.  **Świetna fizyka 2D:** Implementacja wektorowego ciągu, bezwładności oraz oporu aerodynamicznego uczy programistów podstaw fizyki gier bez potrzeby korzystania z silników fizyki typu Rapier.
3.  **Deterministyczny Generator Świata:** Użycie stabilnego RNG gwarantuje, że kosmos zawsze wygeneruje się w identyczny sposób, co ułatwia testowanie i projektowanie zbalansowanych misji.

To idealny, kompletny technicznie szablon dla każdego dewelopera pragnącego stworzyć własną kosmiczną odyseję, handlowego RPG lub grę eksploracyjną na silniku Lurek2D!
