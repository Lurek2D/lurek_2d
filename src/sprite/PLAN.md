# Plan Implementacji — src/sprite

Ten plik przedstawia plan rozwoju modułu `sprite` na podstawie pomysłów zebranych w pliku `IDEA.md`, po analizie istniejącego kodu źródłowego.

## Stan obecny vs IDEA.md

Zgodnie z plikiem `IDEA.md`, w module wprowadzono już następujące ułatwienia:
* **Helper odtwarzania animacji**: Dodano pomocnik `sprite_animator` dla częstego wzorca sprite-sheet playback, znajdujący się w bibliotece Lua pod adresem `library/sprite/sprite_animator.lua`.

Pozostałe pomysły zostały ocenione pod kątem zysku do kosztu implementacji (Value added vs. Cost).

---

## Kategoryzacja zadań (MUST / SHOULD / COULD)

### 1. MUST (Wysoka wartość dodana, niski/umiarkowany koszt)

* **Ekspozycja API pakowania atlasów tekstur w locie (`newAtlasPacker`)**
  * **Wartość**: Bardzo wysoka. Pakowanie na poziomie CPU jest już zaimplementowane w Rust (`src/image/texture_atlas.rs`), ale nie ma do niego dostępu z poziomu skryptów Lua. Umożliwi to dynamiczne wczytywanie zewnętrznych grafik (np. modów do gier) i łączenie ich w jeden atlas w celu optymalizacji rysowania (batching).
  * **Koszt**: Niski. Wymaga dodania mostka Lua dla typu `TextureAtlas` (np. eksponującego metody pakowania obrazów i zwracającego współrzędne UV).
  
* **Ograniczenie alokacji w `SpriteSheet::get_row` oraz `get_column`**
  * **Wartość**: Bardzo wysoka (optymalizacja hot-path). Metody te są często wywoływane w pętlach gry do pobierania zestawów klatek. Obecnie prawdopodobnie zwracają nowo alokowane wektory `Vec`, co generuje zbędne operacje na stercie i obciąża GC.
  * **Koszt**: Niski. Przejście na zwracanie referencji do wycinków (`&[Sprite]`) lub niestandardowych struktur iteratorów bezalokacyjnych.

---

### 2. SHOULD (Średnia/wysoka wartość, umiarkowany/wysoki koszt)

* **Wsparcie dla oświetlonych duszków (`normal-map` / `lit sprites`)**
  * **Wartość**: Bardzo wysoka dla efektów wizualnych. Umożliwi nakładanie map normalnych na sprite'y i ich dynamiczne oświetlanie w integracji z modułem `light` i rendererem.
  * **Koszt**: Wysoki. Wymaga modyfikacji struktury wierzchołków (`Vertex`), dodania mapowania tekstur normalnych w potoku wgpu oraz wprowadzenia parametrów normalnych w API Lua.
  
* **Usunięcie duplikacji parserów Aseprite (`sprite` vs `animation`)**
  * **Wartość**: Średnia. Uporządkowanie architektury. Obecnie pliki Aseprite JSON są parsowane niezależnie w obu modułach, co może prowadzić do niespójności.
  * **Koszt**: Umiarkowany. Wydzielenie wspólnego parsera JSON Aseprite do modułu bazowego (np. `asset` lub współdzielonego pomocnika) i zasilanie nim struktur sprite i animacji.
  
* **Rozszerzenie testów parserów atlasów (Aseprite / TexturePacker)**
  * **Wartość**: Średnia. Zabezpiecza parser przed błędami parsowania niekompletnych lub niepoprawnych plików JSON generowanych przez różne wersje programów graficznych.
  * **Koszt**: Niski. Napisanie dedykowanych testów sprawdzających reakcję na błędne ścieżki (error-path).

---

### 3. COULD (Umiarkowana/niska wartość, wysoki koszt)

* **Szybki binarny format atlasów tekstur**
  * **Wartość**: Niska dla mniejszych gier, przydatna tylko przy tysiącach assetów w celu skrócenia czasu ładowania gry (pominięcie parsowania dużych plików tekstowych JSON).
  * **Koszt**: Umiarkowany. Wymaga zaimplementowania własnego binarnego formatu zapisu/odczytu (np. opartego o `bincode`) oraz dodania narzędzia eksportującego.
  
* **Fuzz targety dla parserów JSON atlasów**
  * **Wartość**: Niska w normalnych warunkach.
  * **Koszt**: Wysoki. Konfiguracja infrastruktury fuzzingu XML/JSON w Rust.

---

## Rekomendowany harmonogram wdrożenia

1. **Faza 1 (Wydajność i API - MUST)**:
   * Zmienić sygnatury `get_row`/`get_column` w `SpriteSheet` na bezalokacyjne.
   * Dodać bindingi Lua do `TextureAtlas` i wystawić fabrykę `newAtlasPacker`.
2. **Faza 2 (Architektura i jakość - SHOULD)**:
   * Zdeduplikować parsery Aseprite pomiędzy modułami `sprite` i `animation`.
   * Rozszerzyć bazę testów jednostkowych o niepoprawne pliki JSON.
3. **Faza 3 (Grafika - SHOULD/COULD)**:
   * Opracować potok renderowania sprite'ów z mapowaniem normalnych.
