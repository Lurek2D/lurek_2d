# 🗺️ Europa Universalis 2 Lite — Grand Strategy Province GPU Renderer

**Category:** Strategy / Grand Strategy Engine Showcase  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Europa Universalis 2 Lite** to monumentalny, zaawansowany silnik i pokaz technologiczny wielkoskalowego renderowania map politycznych i geograficznych (Grand Strategy Map Engine), będący hołdem dla klasycznych, globalnych gier strategicznych studia Paradox Interactive, a w szczególności kultowego *Europa Universalis II (2001)*. Gra demonstruje potężną, niskopoziomową integrację silnika Lurek2D z dedykowanym modułem Rust GPU (`lurek.province`). Umożliwia płynne przeglądanie, przybliżanie i przeciąganie gigantycznej mapy świata podzielonej na tysiące rzeczywistych prowincji. Przełączaj tryby mapy (polityczny, geograficzny, widoczności), badaj powiązania sąsiedzkie i podziwiaj wydajność renderowania wektorowych granic oraz etykiet tekstowych w 60 klatkach na sekundę!

### Pętla Rozgrywki i Mechaniki
1. **Globalna Mapa Świata:** Silnik wczytuje oryginalną mapę prowincji historycznych z pliku `map.png` (szerokość 1000px, wysokość 450px) z pomocą dedykowanych bibliotek kolorów (`prov_cols.csv`) oraz pliku konfiguracyjnego `province.toml` zawierającego metadane wszystkich prowincji Europy i świata.
2. **Dynamiczne Tryby Mapy (Map Modes):**
   - **Political (Polityczny - Klawisz 1):** Prezentuje układ polityczny świata z unikalnymi barwami poszczególnych królestw, imperiów i księstw oraz wyrazistymi czerwonymi liniami granicznymi (seed_country_borders).
   - **Terrain (Geograficzny - Klawisz 2):** Pokazuje fizyczną mapę świata z podziałem na typy terenu (lasy, niziny, góry, morza, rzeki) zgodnie z geografią.
   - **Visibility (Widoczność - Klawisz 3):** Demonstruje dynamiczny system mgły wojny (Fog of War) lub zasięgu widzenia poszczególnych państw.
3. **Interaktywne Badanie Prowincji:**
   - Przesuwaj kursor myszy nad mapą, by natychmiastowo podświetlać poszczególne prowincje. HUD automatycznie wyświetla historyczną nazwę prowincji (z usuniętymi podkreśleniami, np. "East Prussia" zamiast "East_Prussia"), jej typ terenu, unikalny ID, numer w bazie gry oraz **liczbę bezpośrednich prowincji sąsiadujących** (Neighbors) pobieraną z bazy relacji.
   - **Wybór (Select):** Kliknij lewym przyciskiem myszy, by na stałe zaznaczyć wybraną prowincję i śledzić jej parametry.
4. **Zaawansowana Nawigacja (RTS Camera):**
   - **Drag & Pan:** Przytrzymaj lewy przycisk myszy i przeciągaj, by płynnie przesuwać kamerę nad całym globem.
   - **Tactical Zoom:** Użyj kółka myszy, by przybliżać i oddalać widok. Zoom centruje się precyzyjnie w miejscu położenia kursora myszy. Przekroczenie określonego progu przybliżenia (Zoom >= 3.0) automatycznie renderuje nazwy stolic państw, nazwy prowincji oraz sieć dróg handlowych.
5. **Optymalizacja buforowania (Canvas Caching):** Silnik gry stosuje zaawansowane renderowanie do wirtualnej tekstury. Mapa jest rysowana na GPU do bufora `map_canvas` wyłącznie wtedy, gdy kamera ulegnie przesunięciu lub zmieni się tryb wyświetlania. Dzięki temu statyczny podgląd mapy nie obciąża procesora, gwarantując ultra-płynne 60 FPS.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Europa Universalis 2 Lite** is a monumental tech demo and high-performance grand strategy map engine built within Lurek2D, paying direct homage to Paradox Interactive's pioneering historical strategies, particularly the iconic *Europa Universalis II (2001)*. This showcase demonstrates the low-level capability of the custom Rust-GPU province subsystem (`lurek.province`). Seamlessly pan, drag, and zoom across a massive global canvas divided into thousands of authentic historical provinces. Toggle between dynamic map modes (Political, Terrain, Visibility), analyze province adjacency networks, and marvel at the seamless GPU-accelerated rendering of vector borders, capitals, trade roads, and geographic labels at a locked 60 frames per second!

### Gameplay Loop & Mechanics
1. **Grand Campaign Map:** The engine parses an authentic historical province layout from `map.png` (1000x450 grid) mapped alongside a precise indexing database (`prov_cols.csv`) and metadata configs (`province.toml`) detailing coordinates, capitals, and names.
2. **Dynamic Map Modes:**
   - **Political (Key 1):** Colors the globe according to sovereign boundaries, outlining distinct kingdoms, empires, and duchies with bold red national borders.
   - **Terrain (Key 2):** Displays a geographic physical map, categorizing provinces by terrain types (forests, plains, mountains, oceans, rivers).
   - **Visibility (Key 3):** Showcases dynamic Fog of War overlay systems or national sensor ranges.
3. **Interactive Province Audit:**
   - Hover the cursor over any land or sea area to trigger instantaneous GPU pixel-lookups. The HUD dynamically presents the historical province name (formatted clean, e.g., "Warmia" instead of "Warmia_"), its terrain classification, database ID, and the **total count of adjacent neighboring provinces** extracted from adjacency matrices.
   - **Selection:** Left-click to lock target coordinates, highlighting the chosen province.
4. **Fluid RTS Camera navigation:**
   - **Drag & Pan:** Hold Left Mouse Button and drag to slide the view across the globe.
   - **Tactical Zoom:** Roll the mouse wheel to scale views. Zooming centers precisely on the cursor coordinates. Crossing the tactical zoom threshold (Zoom >= 3.0) automatically triggers rendering of province labels, national capitals, and trade route vectors.
5. **Canvas Caching Optimizations:** To sustain peak frame rates, the map is rendered directly to a GPU texture buffer (`map_canvas`) only when camera matrices, map modes, or label toggles change. This caching model preserves GPU cycles, ensuring a seamless 60 FPS performance.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/eu2
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB + Drag** | Przeciąganie mapy | Przesuwa kamerę nad mapą świata (panowanie kamery). |
| **LMB (Klik)** | Wybór prowincji | Kliknięcie w granicach prowincji zaznacza ją na stałe na ekranie. |
| **Mouse Wheel** | Zoom kamery | Przybliża i oddala widok mapy w punkcie wskazanym przez kursor myszy. |
| **1** | Tryb: Polityczny (Political) | Przełącza widok mapy na podział polityczny państw. |
| **2** | Tryb: Geograficzny (Terrain) | Przełącza widok na mapę fizyczną z ukształtowaniem terenu. |
| **3** | Tryb: Widoczność (Visibility) | Przełącza widok na mapę mgły wojny (Fog of War). |
| **L** | Przełącz etykiety (Labels) | Włącza i wyłącza rysowanie etykiet tekstowych prowincji na mapie. |
| **Esc** | Wyjście | Zamyka bezpiecznie aplikację. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Europa Universalis II (2001) by Paradox Interactive**
  - *Opis powiązania*: Bezpośredni przodek estetyczny i mechaniczny. Gra wykorzystuje oryginalne pliki graficzne mapy oraz koncepcję podziału prowincjonalnego ze słynnej drugiej odsłony serii. Przenosi układ prowincji, stolic państwowych, a także podział na mapy polityczne i geograficzne.
- **Crusader Kings / Hearts of Iron (Seria)**
  - *Opis powiązania*: Wykorzystanie silnika opartego na prowincjach (Province-based grand strategy), w którym interakcje taktyczne, przemieszczanie wojsk i dyplomacja odbywają się poprzez klikanie na wielokąty prowincji na mapie.
- **Victoria 2 by Paradox Development Studio**
  - *Opis powiązania*: Koncepcja mapy taktycznej ze szczegółowymi połączeniami sąsiedzkimi, gdzie każda prowincja posiada zdefiniowane surowce, rzeźbę terenu i stolice handlowe.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra stanowi szczytowy pokaz integracji niskopoziomowej w silniku Lurek2D:
- `lurek.province` – Całkowite serce gry. Dedykowane API w języku Rust obsługujące dynamiczną sanityzację obrazów PNG (`lurek.province.sanitizeMarkedPng`), wczytywanie map prowincji z bazy pikseli (`lurek.province.newFromPng`), importowanie złożonych plików metadanych TOML (`importMetadataFromFiles`) oraz sprawne przeliczanie współrzędnych ekranu do bazy prowincji (`screenToProvince`).
- `lurek.input` – Obsługa przeciągania myszką (Drag & Pan) na podstawie przesunięcia delty oraz przechwytywanie zdarzeń kółka myszy (`wheelmoved`) do płynnego i dokładnego zoomowania kamery.
- `lurek.render` – Tworzenie wirtualnego bufora renderowania (`R.newCanvas`), rysowanie mapy do tekstury pomocniczej, a następnie szybkie wyświetlanie bufora na ekranie (`R.draw`), co optymalizuje wydajność rysowania do absolutnego maksimum.
- `lurek.timer` – Odczyt wskaźników płynności (FPS) i statystyk wywołań rysowania karty graficznej.
- `lurek.event` – Wykrywanie klawisza Esc do płynnego i bezpiecznego zamknięcia aplikacji.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Najbardziej zaawansowany pokaz technologii renderowania w Lurek2D. Udowadnia, że silnik potrafi obsługiwać gigantyczne bazy danych geograficznych i historycznych (ponad 300 KB plików TOML metadanych, tysiące prowincji), renderować wektorowe granice oraz dynamiczne opisy tekstowe w czasie rzeczywistym dzięki zaawansowanej integracji Rust-GPU i buforowaniu klatek (Canvas Caching).
- **Unikalność (Uniqueness):** Jedyna gra w portfolio typu Grand Strategy Map Renderer. Całkowicie rezygnuje z prostych figur geometrycznych na rzecz renderowania rzeczywistych, nieregularnych wielokątów prowincji geograficznych, co czyni ją najważniejszym pokazem możliwości silnika dla zaawansowanych strategii geopolitycznych.
- **Podobne gry (Similar Games):** Gra dzieli strategiczny charakter z `hex_strategy` oraz `wargame`, ale jako jedyna oferuje pełne, dynamiczne renderowanie mapy rzeczywistego świata na poziomie prowincji za pomocą niskopoziomowego modułu Rust.
