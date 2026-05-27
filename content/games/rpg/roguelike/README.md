# 🐉 Roguelike — Turn-Based Grid Roguelike with Procedural Generation

**Category:** RPG / Turn-Based Roguelike  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Roguelike** to hołd dla tradycyjnych gier z gatunku roguelike z widokiem z góry, łączący klasyczny, krokowy system turowy (grid-based movement), proceduralnie generowane korytarze podziemi, mgłę wojny (Fog of War) oraz zasadę permadeath (nieodwołalnej śmierci). Przemierzaj coraz niebezpieczniejsze piętra pełne szczurów, goblinów i orków, zbieraj mikstury leczenia, ulepszaj swój miecz i sprawdź, na które piętro zdołasz dotrzeć, zanim Twoje życie dobiegnie końca.

### Pętla Rozgrywki i Mechaniki
1. **Ruch Turowy i Czas:** Każdy Twój ruch lub atak (1 kafelek za pomocą WASD/strzałek) stanowi jedną turę gry. Po Twojej akcji ruch wykonują wszyscy widoczni przeciwnicy.
2. **Proceduralne Lochy (Dungeon Generation):** Każde piętro jest generowane od nowa — system tworzy losową liczbę pokoi (od 6 do 10) o zmiennych wymiarach i łączy je krętymi korytarzami, umieszczając na końcu schody w dół.
3. **Mgła Wojny (Fog of War):** Widzisz tylko kafelki w promieniu 5 pól wokół siebie. Kafelki wcześniej zbadane stają się ciemniejsze i tracisz podgląd na ruchy wrogów w cieniu.
4. **Walka Zderzeniowa (Bump Combat):** Aby zaatakować wroga, wystarczy na niego "wejść". Zadawane obrażenia obliczane są według formuły: `Obrażenia = Atak gracza - Obrona wroga`. Powyżej wrogów wyświetlają się dynamiczne, lecące w górę liczby zadanych obrażeń.
5. **Ewolucja i Awans (Leveling):** Każde 5 zabójstw awansuje Cię na wyższy poziom, trwale zwiększając Atak (+1) oraz maksymalne HP (+2).
6. **Ekwipunek na Ziemi (Pickups):**
    *   🧪 **Green Potions (!):** Przywracają 15 punktów życia.
    *   ⚔️ **Gold Upgrades (+):** Zwiększają na stałe Twój Atak o 2 punkty.
7. **Pasek Komunikatów (Log):** U dołu ekranu wyświetlanych jest 5 ostatnich wpisów bojowych (zadane/otrzymane obrażenia, awanse, śmierć).
8. **Podręczna Minimapa:** W prawym górnym rogu ekranu HUD renderowana jest wektorowa mapa zbadanych korytarzy z zaznaczonym graczem i potworami.

---

## 🇬🇧 Game Description (English)

### Short Pitch (Elevator Pitch)
**Roguelike** is a faithful tribute to the pioneering golden era of ASCII and graphical turn-based roguelikes. Featuring procedurally generated room-and-corridor layouts on every floor transition, grid-locked turn-based movements, a dynamic fog of war line-of-sight system, bump combat, and permanent death, it tests your tactical foresight to the absolute limit. Scavenge for resources, scale up your character level, and dive into the deep dark unknown.

### Gameplay Loop & Mechanics
1. **Turn-Based Grid Loop:** Every keyboard step (WASD / Arrows) represents a single tick. Once you take action, all nearby monsters compute pathfinding and navigate towards you.
2. **Procedural Generation:** Instantly builds 6 to 10 non-overlapping rectangular chambers connected via programmatic L-shaped corridors on every floor, hiding down-stairs in the final room.
3. **Fog of War & Memory:** Player visibility is locked to a 5-tile radius. Explored sectors outside your field of view are drawn dim and hide active enemy movements.
4. **Bump Combat Engine:** Attack enemies simply by walking directly into their grid cells. Damage formulas subtract targets' defenses from your attack power. Damage popups rise and fade over hit entities in real-time.
5. **Leveling Modifiers:** Every 5 kills levels up your character, raising max health (+2 HP) and physical strength (+1 ATK).
6. **Ground Items:**
    *   🧪 **Green Potions (!):** Quench injuries to heal 15 HP.
    *   ⚔️ **Gold Weapon Swags (+):** Instantly augment physical base Attack by +2.
7. **Tension Ticker Log:** Keeps you informed via a 5-line scrolling log of all combat impacts and exploration cues.
8. **HUD Mini-Grid:** Real-time mini-map in the top-right displays explored tiles, player orientation, and visible monster dots.

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **W, A, S, D / Strzałki** | Ruch postacią / Atak (zderzenie z wrogiem) | Move around dungeon / Attack (bump combat) |
| **Enter** | Rozpocznij grę / Zejdź po schodach | Start game / Descend down stairs |
| **Escape** | Wyjście z gry | Quit to OS |

---

## 🐉 Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
Gra czerpie wprost z korzeni gatunku, naśladując legendarne hity **Rogue** (1980), **NetHack**, **Angband** oraz wczesne **Mystery Dungeon**. Odzwierciedla ich kluczową filozofię:
*   Trudne, nieodwracalne wybory wymuszone przez system permadeath.
*   Zależność tury — gra czeka na decyzję gracza bez pośpiechu zręcznościowego.
*   Siatka kaflowa z umowną, symboliczną ikonografią postaci (@ dla gracza, g dla goblina, r dla szczura, O dla orka).

### Modernizacja w Lurek2D
Lurek2D dodaje wizualne smaczki niosące mnóstwo satysfakcji (game juice):
*   **Wielokierunkowy Tweener Obrażeń:** Liczby ciosów unoszą się dynamicznie w górę z gradientem przezroczystości za pomocą tablic matematycznych.
*   **Cząsteczki Pochodni i Emiterów:** Migotanie schodów wyzwala niebieskie cząsteczki (`update_stair_particles`), a zbieranie przedmiotów i śmierć wrogów generują barwne poofy.
*   **Płynny Pasek HP:** Pasek życia gracza nie zmienia się gwałtownie, lecz spływa płynnie dzięki zaimplementowanej w Lua amortyzacji delty.

---

## 🛠️ Wykorzystane API silnika Lurek2D / Lurek APIs Showcased

*   `lurek.camera`: Płynne centrowanie widoku kamery na pozycji bohatera `@` z uwzględnieniem kafelkowego przesunięcia (`setPosition`).
*   `lurek.render`: Rysowanie kafelków podłogi i ścian, wektorowej minimapy, symboli tekstowych wrogów oraz chmury komunikatów i pasków życia (`rectangle`, `print`, `setColor`).
*   `lurek.input` & `keypressed`: Monitorowanie zdarzeń naciśnięcia klawiszy WASD/Strzałek dla celów realizacji czystego kroku turowego.
*   `lurek.window`: Kontrola nazwy okna systemowego i integracja z licznikiem FPS (`setTitle`).
*   `lurek.event`: Zapewnienie bezproblemowej procedury zamykania okna (`quit`).
*   `lurek.timer`: Dostarczanie delty klatek i wyznaczanie płynności działania gry (`getFPS`).

---

## 💎 Unikalność i Wartość Prezentacyjna / Showcase Value & Uniqueness

### Dlaczego ta gra jest wyjątkowa?
**Roguelike** to wzorcowy pokaz **algorytmiki proceduralnej i mechanik turowych** zrealizowanych na silniku Lurek2D:
1.  **Pokazuje autorski generator lochów:** Algorytm generuje w pełni grywalny, połączony i spójny labirynt korytarzy w ułamku sekundy, stanowiąc świetny szablon dla przyszłych twórców RPG.
2.  **Zaawansowany system Fog of War:** Zarządzanie tablicą widoczności i pamięcią odkrycia (Explored Array) dowodzi stabilności obliczeniowej Lurek2D-Lua.
3.  **Klasyczny styl ASCII-hybrid:** Łączy retro-klimat klasycznej typografii komputerowej z nowoczesnymi, płynnymi efektami cząsteczek i liczb unoszących się w przestrzeni, co daje niesamowitą satysfakcję wizualną.

To obowiązkowa pozycja dla każdego miłośnika trudnych gier taktycznych oraz doskonały podręcznik tworzenia mechanik turowych i generowania lochów na silniku Lurek2D!
