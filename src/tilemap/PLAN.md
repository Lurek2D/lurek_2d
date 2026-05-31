# Plan Implementacji — src/tilemap

Ten plik przedstawia plan rozwoju modułu `tilemap` po analizie istniejącego kodu źródłowego i zrealizowanych zmian.

## Status realizacji (DONE / TODO)

### DONE

* MUST: ustrukturyzowane błędy importu TMX/LDtk do Lua — zrealizowane.
* MUST: helpery Lua `camera_follow_walker` i `tilemap_minimap` — zrealizowane.
* MUST: doprecyzowanie overlapu tilemap/physics — zrealizowane.

### TODO

* SHOULD: pełny renderer map heksagonalnych (`HexMap`).
* SHOULD: viewport/dirty-driven aktualizacja animowanych kafli.
* SHOULD: podział dużych plików `mapgen.rs` i `tilemap.rs`.
* COULD: wsparcie Wang tiles.
* COULD: rozszerzenie testów error-path parserów + fuzz XML.

## Stan obecny

W module wprowadzono już następujące usprawnienia:
* **Szybki indeks typów kafli (`tile_type_index_cache`)**: Zaimplementowany w `tilemap.rs` jako cache `Vec<HashMap<u32, Vec<(u32, u32)>>>`, aktualizowany automatycznie podczas operacji modyfikujących warstwy (`add_layer`, `set_tile`, `fill`, `clear_tile`).
* **Ulepszony viewport culling**: Viewport culling w renderowaniu dużych map został w pełni zaimplementowany w `render.rs` (camera-space culling) oraz w `large_map_renderer.rs` (chunking + poziom szczegółowości LOD).

Pozostałe pomysły wymagają zaplanowania i kategoryzacji pod kątem dodanej wartości do kosztu implementacji (Value added vs. Cost).

---

## Kategoryzacja zadań (MUST / SHOULD / COULD)

### 1. MUST (Wysoka wartość dodana, niski/umiarkowany koszt)

* **Ustrukturyzowane błędy importu TMX/LDtk do Lua**
  * **Wartość**: Bardzo wysoka dla twórców gier (GameDev) i modyfikacji. Obecnie błędy są zwracane jako proste ciągi znaków `String` lub powodują awarie mostka. Ustrukturyzowane tabele błędów (np. nazwa pliku, linia, kolumna, kod błędu, opis) ułatwią debugowanie uszkodzonych assetów.
  * **Koszt**: Niski. Wymaga dodania typu błędu implementującego `IntoLua` i mapowania błędów XML/JSON w `tmx.rs` oraz `ldtk.rs`.

* **Helpery Lua (`camera_follow_walker` i `tilemap_minimap`)**
  * **Wartość**: Bardzo wysoka. Są to niezwykle częste wzorce w grach 2D (śledzenie gracza kamerą poruszającego się po kafelkach, generowanie minimapy w oparciu o istniejący render minimap).
  * **Koszt**: Niski. Możliwe do zrealizowania bezpośrednio jako biblioteki Lua w folderze `library/` lub cienkie API helperów.

* **Doprecyzowanie overlapu kolizji tilemapy z helperami w `physics`**
  * **Wartość**: Wysoka. Unika duplikacji logiki kolizyjnej i zapewnia spójność zachowania fizyki opartej o Rapier2d z zapytaniami o kafelki (np. raycasting po gridzie).
  * **Koszt**: Umiarkowany. Wymaga przejrzenia metod intersekcji w `tilemap.rs`/`polygon_map.rs` i połączenia ich z sensorami/colliderami Rapier.

---

### 2. SHOULD (Średnia/wysoka wartość, umiarkowany/wysoki koszt)

* **Pełny renderer map heksagonalnych (`HexMap`)**
  * **Wartość**: Wysoka (otwiera drogę dla gier strategicznych typu 4X/tactical). Matematyka heksagonalna (konwersje współrzędnych axialnych, wyszukiwanie sąsiadów, spirale, linie, Chebyshev) jest już gotowa w `coords.rs`. Brakuje jednak powiązania tego z generowaniem instrukcji renderowania w `render.rs`.
  * **Koszt**: Umiarkowany. Należy rozszerzyć `generate_render_commands` o obsługę rzutowania hexagonalnego na bazie `to_screen_hex`.

* **Optymalizacja aktualizacji animowanych kafli (viewport/dirty-driven)**
  * **Wartość**: Średnia/Wysoka przy ogromnych mapach z dużą ilością animowanej wody/ognia. Pozwoli uniknąć aktualizacji stanów animacji kafelków, które są całkowicie poza ekranem.
  * **Koszt**: Umiarkowany. Wymaga dodania bufora dirty oraz sprawdzania widoczności (frustum) przed aktualizacją liczników klatek animacji.

* **Refaktoryzacja i podział dużych plików (`mapgen.rs`, `tilemap.rs`)**
  * **Wartość**: Wysoka dla utrzymania kodu (code health/quality). `tilemap.rs` (~1100 linii) i `mapgen.rs` (~800 linii) stają się trudne w nawigacji.
  * **Koszt**: Umiarkowany (głównie czasochłonność refaktoryzacji, ryzyko regresji w testach).

---

### 3. COULD (Niska/średnia wartość, wysoki koszt)

* **Wsparcie dla Wang tiles (autotiling)**
  * **Wartość**: Umiarkowana. Pozwala na tworzenie bardziej naturalnych przejść terenu (autotiling wielokierunkowy), ale standardowy autotiler (`autotile_sheet.rs`) pokrywa 90% potrzeb typowych gier 2D.
  * **Koszt**: Wysoki. Złożona matematyka dopasowywania krawędzi i narożników Wang, potrzeba nowego formatu konfiguracji.

* **Rozszerzenie testów error-path parserów TMX/LDtk + Fuzz XML**
  * **Wartość**: Niska w codziennym użytkowaniu, przydatna tylko przy celowo uszkodzonych plikach wejściowych.
  * **Koszt**: Wysoki. Uruchomienie stabilnego XML fuzzera w Rust wymaga konfiguracji dodatkowego środowiska (cargo-fuzz).

---

## Rekomendowany harmonogram wdrożenia

1. **Faza 1 (Szybkie zwycięstwa - MUST)**:
   * Zaimplementować ustrukturyzowane błędy w `tmx.rs` i `ldtk.rs`.
   * Stworzyć helpery Lua dla kamery i integracji z fizyką.
2. **Faza 2 (Kluczowe funkcjonalności - SHOULD)**:
   * Dodać renderowanie `HexMap` do `render.rs` na podstawie `coords.rs`.
   * Wydzielić mniejsze moduły z `tilemap.rs` i `mapgen.rs`.
3. **Faza 3 (Dalsze optymalizacje - COULD)**:
   * Wdrożyć dirty-driven updates dla animowanych kafelków.
