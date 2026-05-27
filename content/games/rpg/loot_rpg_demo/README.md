# 💎 Loot RPG Demo — Quick-Start Sandbox & Procedural Loot Grinder

**Category:** RPG / Inventory & Stat Progression (Demo)  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Loot RPG Demo** to demonstracyjna wersja kompletnego dungeon crawlera nastawionego na zbieranie łupów i optymalizację statystyk. Służy jako bezpośredni, natychmiastowy sandbox kodowy, w którym deweloperzy mogą błyskawicznie sprawdzić działanie systemów generowania rzadkości przedmiotów, interpolacji pasków życia (HP) za pomocą tweenów oraz obsługi emiterów cząsteczek. Walcz z potworami, zbieraj epicki sprzęt, optymalizuj statystyki i sprawdź, jak działa zaawansowana pętla RPG w środowisku Lurek2D.

### Charakterystyka i Rola Wersji Demo
Gra dzieli kod źródłowy z głównym modułem `loot_rpg`, lecz jest wyodrębniona jako niezależne demo technologiczne o ułatwionym wglądzie w kod:
1.  **Pokaz Systemu Losowości:** Możliwość testowania szans na wylosowanie przedmiotów zwykłych, rzadkich, epickich oraz legendarnych (Legendary roll = 3% szans).
2.  **Szybkie Prototypowanie UI:** Przejrzyste wyświetlanie statystyk dynamicznych (Obrażenia, Obrona, Szybkość, Bonus do Poczucia Życia) aktualizowanych w czasie rzeczywistym.
3.  **Podgląd Klawiaturowego Suwaka:** Demonstracja przewijania listy plecaka przy sztywnym limicie wagowym (20.0 kg).

---

## 🇬🇧 Game Description (English)

### Short Pitch (Elevator Pitch)
**Loot RPG Demo** serves as a lightweight, quick-start technological showcase of the main `loot_rpg` system. This sandbox allows developers and players to instantly witness Lurek2D's data-science state calculations, color-coded rarity item rolls, backpack scrolling, and visual "juice" transitions (combat blood splatters and legendary item sparkle cascades) in a single-file, highly-legible Lua script.

### Sandbox Highlights & Purposes
Sharing its architecture with `loot_rpg`, this demo slice is designed as a template for creators to tinker with:
1.  **Rarity Math Sandbox:** Tweak stat rolls and scaling multiplier variables across Common, Rare, Epic, and Legendary gear.
2.  **Backpack & Weight Limits:** A great template for inventory scrolling mechanics coupled with weight constraints.
3.  **Visual Polish Harness:** Instant test-bed for mathematical life bar drains (tweens) and spatial particle explosions.

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **Space** | Rozpocznij / Atakuj w walce / Zbierz łupy z podłogi | Start game / Attack in combat / Collect chest loot |
| **E** | Automatycznie załóż najlepsze przedmioty | Auto-equip best stats items from backpack |
| **B** | Zakup eliksir leczenia (koszt: 5 złota) | Purchase health potion (costs 5 gold) |
| **↑ / ↓** | Przewijaj listę plecaka w dół / w górę | Scroll inventory list up / down |
| **Escape** | Wyjście z gry | Quit to OS |

---

## 🛡️ Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
Wzorowane na **Diablo** oraz tekstowych klasykach gatunku RPG (takich jak wczesne **Multi-User Dungeons - MUD**), demo skupia się na dostarczeniu natychmiastowej satysfakcji ze zdobywania coraz potężniejszego oręża (tzw. dopaminowej pętli lootu).

### Modernizacja w Lurek2D
*   **Łatwość Integracji:** Prosty, modularny zapis w jednym pliku `main.lua` bez zewnętrznych bibliotek, co ułatwia nowym programistom naukę mechanik RPG.
*   **Wizualny Błysk (Game Juice):** Dynamiczne, krwawe cząsteczki walki oraz złote gwiazdy z fizyką grawitacyjną dodają grze wspaniałego dynamizmu.

---

## 🛠️ Wykorzystane API silnika Lurek2D / Lurek APIs Showcased

*   `lurek.particle`: Generator cząsteczek rozbłysku skarbu (`lootSparkle`) oraz obrażeń walki (`combatFlash`).
*   `lurek.tween`: Płynne skalowanie pasków HP (`tween`).
*   `lurek.render`: Rysowanie interfejsu ekwipunku, statystyk postaci oraz logów walki (`rectangle`, `print`, `setColor`).
*   `lurek.input`: Precyzyjne przechwytywanie wciśnięć klawiatury dla celów interakcji z ekwipunkiem (`bind`, `wasActionPressed`).
*   `lurek.camera` & `lurek.window`: Rzutowanie 2D kamery oraz dynamiczna aktualizacja paska tytułowego okna gry (`setTitle`).
*   `lurek.timer` & `lurek.event`: Monitorowanie liczby klatek na sekundę (`getFPS`) i bezpieczne wyłączanie gry (`quit`).

---

## 💎 Unikalność i Wartość Prezentacyjna / Showcase Value & Uniqueness

### Dlaczego ta gra jest wyjątkowa?
**Loot RPG Demo** to idealnie zoptymalizowane, gotowe do nauki demo technologiczne:
1.  **Niezależny Szablon RPG:** Kod gry jest zwięzły, dobrze skomentowany i nie zależy od zewnętrznych zasobów graficznych, co czyni go najlepszym materiałem szkoleniowym w kategorii gier fabularnych.
2.  **Pokazuje stabilność tablic stanów:** Dowodzi, jak bezproblemowo Lurek2D obsługuje głębokie zagnieżdżenia obiektów w Lua (baza przedmiotów, sloty ekwipunku, stany walki).
3.  **Wydajność Cząsteczek:** Stabilna praca emiterów cząsteczek przy generowaniu setek obiektów na klatkę bez utraty wydajności.