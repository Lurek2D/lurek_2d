# ⚙️ Factory — Factorio-Lite Grid Automation Sandbox

**Category:** Simulation  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Factory** to miniaturowy, niezwykle satysfakcjonujący symulator automatyzacji i logistyki (Factorio-lite) zbudowany na planszy opartej na siatce kafelków. Jako inżynier przemysłowy masz za zadanie zaprojektować wydajne, bezobsługowe linie produkcyjne, które przekształcą surową rudę z głębi ziemi w gotowe produkty i wygenerują fortunę. Buduj automatyczne wiertnice (Miners) na żyłach surowców, łącz maszyny taśmociągami (Conveyors), wytapiaj metal w piecach hutniczych (Smelters), twórz zaawansowane towary w fabrykach montażowych (Assemblers), a gotowy urobki kieruj do stref magazynowych (Storage). Czy zdołasz zoptymalizować przepustowość swojej fabryki i osiągnąć cel 500 sztuk złota bez wywoływania zatorów na pasach transmisyjnych?

### Pętla Rozgrywki i Mechaniki
1. **Złoża i Strefa Zbytu:** Na mapie 25x18 kafelków generowanych jest losowo 8 bogatych złóż rudy (kolor brązowy). Na prawym krańcu mapy znajdują się 2 zielone strefy magazynowe (Storage), w których automatycznie sprzedajesz produkty.
2. **Łańcuch Technologiczny (Production Chain):**
   - **Ruda (Raw Ore):** Wydobywana przez automatyczne wiertnice (Miners) z prędkością 1 sztuki na 3 sekundy.
   - **Sztabki (Ingots):** Piec hutniczy (Smelter) pobiera 1 sztukę rudy i przetapia ją w sztabkę żelaza w czasie 5 sekund.
   - **Produkt (Product):** Fabryka montażowa (Assembler) pobiera 2 sztabki i montuje z nich produkt końcowy w czasie 8 sekund.
3. **Logistyka i Taśmociągi:** Taśmy transportują przedmioty w wybranym kierunku (prawo, dół, lewo, góra) z prędkością 32 pikseli na sekundę. Budując taśmy, musisz precyzyjnie zaprojektować skrzyżowania i kierunki, by dostarczać odpowiednie surowce do wejść maszyn.
4. **Maszyny i Koszty Inwestycji:** Dysponujesz ograniczonym budżetem początkowym (50 złota), który inwestujesz w rozbudowę:
   - **Conveyor (Taśma):** Koszt: 1 złota. Podstawowy pas transmisyjny kierujący przedmioty w 4 strony świata.
   - **Miner (Wiertnica):** Koszt: 10 złota. Musi zostać postawiony na złożu rudy. Wydobywa surową rudę.
   - **Smelter (Piec hutniczy):** Koszt: 20 złota. Przetapia rudę w sztabki.
   - **Assembler (Montownia):** Koszt: 30 złota. Tworzy gotowy produkt ze sztabek.
   - **Tryb usuwania (Delete):** Darmowa rozbiórka obiektów w celu odzyskania przestrzeni i korekty tras taśmociągów.
5. **Faza Zbytu (Auto-Sell):** Co 10 sekund system zlicza produkty dostarczone do magazynów. Każdy produkt sprzedaje się za 15 złota, co wyzwala widowiskowe złote iskry na planszy.
6. **Kontrola Prędkości:** Kontroluj czas dzięki trzystopniowemu przyspieszeniu rozgrywki (1x, 2x, 4x), idealnemu do przyspieszenia faz akumulacji kapitału.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Factory** is a miniature, immensely satisfying grid-based automation and logistics simulator (Factorio-lite). As a pioneer industrial engineer, your goal is to design efficient, belt-driven production assembly lines to extract raw minerals from sub-surface veins and refine them into profitable commercial goods. Deploy automated Miners on resource veins, link machinery with dynamic conveyor belts, smelt raw ore inside industrial Smelters, construct advanced items inside specialized Assemblers, and direct finished payloads toward dedicated selling hubs. Optimize your logistics flow, eliminate bottleneck clogs, and amass 500 gold coins to establish your manufacturing empire!

### Gameplay Loop & Mechanics
1. **Veins & Trading Hubs:** A 25x18 layout hosts 8 randomly spawned mineral veins (brown tiles). The rightmost edge features 2 green Storage bays where finished products are deposited and sold.
2. **The Industrial Recipe (Production Chain):**
   - **Raw Ore:** Extracted by automated Miners stationed on ore tiles every 3 seconds.
   - **Ingots:** Smelters pull in 1 Raw Ore from conveyor belts, processing it into 1 metal Ingot in 5 seconds.
   - **Finished Product:** Assemblers pull in 2 Ingots, manufacturing them into 1 profitable final Product in 8 seconds.
3. **Logistics & Belt Physics:** Conveyors route items across grids in one of 4 cardinal directions at 32 pixels per second. Plan your intersections and terminal loops carefully; items enter machines automatically when aligned with input feeds.
4. **Machinery Costs & Investments:** Manage your starting budget of 50 gold to fund your expansion:
   - **Conveyor Belt:** Costs 1 gold. Routes materials in the desired direction.
   - **Miner:** Costs 10 gold. Must be constructed directly on top of resource veins.
   - **Smelter:** Costs 20 gold. Refines Raw Ore into high-grade Ingots.
   - **Assembler:** Costs 30 gold. Fabricates high-value products from Ingots.
   - **Deconstruct Mode (Delete):** Instantly dismantles layout tiles, clearing grid space for lane optimizations.
5. **Periodic Liquidations (Auto-Sell):** Every 10 seconds, stockpiled products in the Storage zones are liquidated. Every product yields 15 gold, triggering brilliant particle explosions.
6. **Simulation Speed Dials:** Toggle simulation speed settings (1x, 2x, 4x) to accelerate material transport and processing during long assembly pipelines.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/simulation/factory
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB (Lewy Klik)** | Budowa / Umieszczenie | Stawia wybraną maszynę lub taśmociąg w miejscu kursora myszy. |
| **W** | Pas: Góra | Ustawia kierunek taśmy w górę (**DIR_UP**) i włącza tryb budowy taśm. |
| **A** | Montownia (Assembler) | Wybiera fabrykę montażową (**Assembler**) jako aktywny obiekt budowy (Koszt: 30 gold). |
| **S** | Piec hutniczy (Smelter) | Wybiera piec hutniczy (**Smelter**) jako aktywny obiekt budowy (Koszt: 20 gold). |
| **D** | Usuń (Delete) | Uruchamia tryb demontażu (**Delete Mode**) maszyn i taśmociągów. |
| **M** | Wiertnica (Miner) | Wybiera automatyczną wiertnicę (**Miner**) jako aktywny obiekt budowy (Koszt: 10 gold). |
| **1** | Prędkość normalna | Ustawia prędkość symulacji na standardową (1x speed modifier). |
| **2** | Prędkość 2x | Przyspiesza działanie taśm i maszyn dwukrotnie (2x speed modifier). |
| **3** | Prędkość 4x | Przyspiesza działanie taśm i maszyn czterokrotnie (4x speed modifier). |
| **Esc** | Wyjście | Zamyka bezpiecznie aplikację. |

> [!NOTE]
> Ze względu na jednoliterowe skróty klawiszowe, klawisze **A**, **S**, **D** pełnią podwójną funkcję: po naciśnięciu najpierw aktywują tryb budowy pasów (odpowiednio w lewo, w dół, w prawo), a następnie natychmiast przełączają tryb budowy na maszynę przypisaną do tego klawisza. Ułatwia to błyskawiczną kontrolę nad układem fabryki.

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Factorio (2020) by Wube Software**
  - *Opis powiązania*: Gra stanowi czysty, minimalistyczny demake Factorio. Adaptuje kluczowe koncepty: automatyzację bez udziału gracza, sieć pasów transmisyjnych (belts), transport przedmiotów z widocznym podglądem fizycznych jednostek na taśmie oraz łańcuch przetwarzania surowca (Ore → Ingot → Product).
- **Mindustry (2020) by Anuken**
  - *Opis powiązania*: Kafelkowa siatka, prostota struktur, surowy techniczny styl graficzny oraz wiertnice wydobywające kruszec bezpośrednio z wydzielonych pól rudy.
- **Satisfactory by Coffee Stain Studios**
  - *Opis powiązania*: Łańcuchy produkcyjne wymagające łączenia kilku komponentów o różnych czasach przetwarzania w celu zoptymalizowania łącznego współczynnika Items/min.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Factory demonstruje szczyt możliwości logicznych i optymalizacyjnych silnika Lurek2D:
- `lurek.window` – Wygodna aktualizacja nagłówka okna systemowego (`lurek.window.setTitle`) prezentująca statystyki finansowe, dzień fabryki oraz płynność FPS.
- `lurek.input` – Zaawansowana obsługa pobierania pozycji myszy w siatce kafelków (`lurek.input.mouse.getPosition()`) przekształcana na współrzędne wirtualnej mapy.
- `lurek.render` – Rysowanie całej infrastruktury fabrycznej (paski postępu maszyn, ikony produktów, wektory strzałek kierunku taśmociągów za pomocą `rect`, `circ` i `text_`).
- `lurek.timer` – Wykorzystywany do precyzyjnego zarządzania czasem procesowym w maszynach oraz do płynnego przyspieszania symulacji za pomocą mnożników czasu delta.
- `lurek.event` – Wykrywanie klawisza Esc w celu czystego wyjścia z gry.
- **Wbudowane Narzędzie Tweeningu:** Wykorzystywane do łagodnej interpolacji dynamicznie rosnących i malejących zasobów złota, zapobiegając nagłym przeskokom liczb w interfejsie.
- **Widowiskowy System Cząsteczek (Particles):**
  - *Iskry montażowe (Assembler Sparks)*: Żółto-niebieskie iskry sypiące się z pieców hutniczych i montowni w czasie ich pracy.
  - *Eksplozje Finansowe (Gold Bursts)*: Złote gejzery cząsteczek tryskające z pól magazynowych przy każdym cyklu zbytu towarów.
  - *Pył Rozbiórkowy (Deconstruction Dust)*: Czerwone, wygasające drobiny towarzyszące usuwaniu struktur z mapy.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Najbardziej złożona gra symulacyjno-logistyczna w bibliotece Lurek2D. Pokazuje, jak zaimplementować pełne wykrywanie stanów na siatce kafelków, dynamiczną translację współrzędnych ekranu do siatki (World-Grid Mapping), symulację ponad 100 niezależnych jednostek poruszających się po taśmach i optymalizację pętli logistycznych bez utraty stabilności 60 FPS.
- **Unikalność (Uniqueness):** Jedyna gra w portfolio skupiająca się na automatyzacji pasywnej (Idle/Automation), w której gracz tworzy system działający całkowicie samodzielnie. Gra uczy logicznego myślenia, planowania przestrzennego i zarządzania przepustowością, co wyróżnia ją na tle tradycyjnych gier akcji i RPG.
- **Podobne gry (Similar Games):** Podobna do `colony_sim` i `province_economy_demo` pod względem ekonomicznym, lecz jako jedyna oferuje pełne, dynamiczne taśmociągi transportujące pojedyncze obiekty w czasie rzeczywistym.
