# Plan Implementacji — src/spine

Ten plik przedstawia plan rozwoju modułu `spine` po analizie istniejącego kodu źródłowego i zrealizowanych zmian.

## Status realizacji (DONE / TODO)

### DONE

* MUST: importer formatów Spine/DragonBones JSON — zrealizowane.
* MUST: usunięcie klonowania animacji/constraints w hot-path — zrealizowane.

### TODO

* SHOULD: testy integracyjne pełnego potoku (Animacja -> IK -> Render).
* SHOULD: benchmark `update_world_transforms`.
* SHOULD: feature-gating modułu Spine.
* COULD: deformacja siatki i wagi wierzchołków.

## Stan obecny

W module wprowadzono już następujące zaawansowane mechanizmy:
* **Maszyna stanów i blending animacji**: Dodano funkcję `animation_blended()` obsługującą parametr wagowy `blend_weight` (w zakresie 0.0 - 1.0) bezpośrednio w `timeline.rs`, co pozwala płynnie mieszać klatki kluczowe sąsiadujących animacji.
* **Pomocniki Lua do animacji**: Zaimplementowano w `timeline.rs` oraz wystawiono do mostka Lua metody `poseAt`, `reverse` oraz `animationFromJson`.

Pozostałe pomysły zostały uszeregowane pod kątem relacji wartości do skomplikowania implementacji (Value added vs. Cost).

---

## Kategoryzacja zadań (MUST / SHOULD / COULD)

### 1. MUST (Kluczowe dla przydatności modułu, wysoka wartość)

* **Importer standardowych formatów szkieletów (Spine / DragonBones JSON)**
  * **Wartość**: Niezwykle wysoka. Bez parsera JSON z zewnętrznych narzędzi projektant gry musiałby ręcznie tworzyć struktury szkieletów w kodzie, co jest nierealne. Jest to absolutny warunek konieczny, by moduł `spine` stał się przydatnym narzędziem produkcyjnym.
  * **Koszt**: Wysoki. Wymaga opracowania solidnego, odpornego na błędy parsera JSON odczytującego hierarchię kości, sloty, constraints, załączniki (attachments) oraz klatki kluczowe i mapującego je na wewnętrzne struktury silnika.

* **Usunięcie klonowania animacji i ograniczeń (constraints) w hot-path**
  * **Wartość**: Bardzo wysoka (krytyczna dla wydajności). Aktualizacje szkieletu (`update_world_transforms`) zachodzą w każdej klatce dla każdej postaci na ekranie. Klonowanie struktur danych wewnątrz tej pętli generuje ogromną presję na stertę i niszczy wydajność. Przejście na dostęp indeksowany w tablicach to kluczowa optymalizacja.
  * **Koszt**: Średnio-wysoki. Wymaga przebudowania wewnętrznych referencji do struktur kości i constraints na bazie indeksów (`usize`) zamiast wskaźników czy klonowanych kopii.

---

### 2. SHOULD (Zalecane dla stabilności i utrzymania)

* **Testy integracyjne pełnego potoku (Animacja -> IK -> Render)**
  * **Wartość**: Wysoka. Gwarantuje, że zmiany w matematyce kości, działaniu solvera IK (`ik.rs`) lub potoku renderowania nie popsują końcowego ułożenia szkieletu na ekranie.
  * **Koszt**: Umiarkowany. Napisanie testu wczytującego prosty rig, nakładającego animację oraz solver IK, a następnie sprawdzającego wyjściowe pozycje wierzchołków.

* **Benchmark wydajnościowy `update_world_transforms`**
  * **Wartość**: Średnia. Umożliwi określenie maksymalnego budżetu wydajnościowego (np. ile rigów zawierających 100+ kości silnik potrafi przetworzyć w 16ms).
  * **Koszt**: Niski. Napisanie prostego benchmarku `criterion` w Rust.

* **Feature-gating modułu Spine jako TIER-2-PLUGIN**
  * **Wartość**: Średnia. Animacje szkieletowe to ciężka funkcjonalność. Gry jej nieużywające powinny mieć możliwość wyłączenia modułu w celu zmniejszenia rozmiaru pliku binarnego.
  * **Koszt**: Niski. Standardowe użycie flag kompilacji Cargo.

---

### 3. COULD (Opcjonalne, bardzo wysoki koszt)

* **Deformacja siatki / Wagi wierzchołków (Mesh deformation / Weighted vertices)**
  * **Wartość**: Bardzo wysoka dla jakości wizualnej (płynne uginanie rąk, powiewanie tkanin).
  * **Koszt**: Ekstremalnie wysoki. Wymaga przejścia z prostych prostokątnych slotów na w pełni deformowalne siatki wierzchołkowe (mesh deformation), modyfikacji shaderów GPU, dodania interpolacji wag na CPU lub GPU. Zalecane do odłożenia do czasu ustabilizowania podstawowych cech Spine.

---

## Rekomendowany harmonogram wdrożenia

1. **Faza 1 (Wydajność - MUST)**:
   * Wyeliminować klonowanie struktur w `update_world_transforms` i przeorganizować pamięć na dostęp indeksowany.
2. **Faza 2 (Import danych - MUST)**:
   * Opracować i przetestować parser Spine/DragonBones JSON.
3. **Faza 3 (Weryfikacja - SHOULD)**:
   * Dodać testy integracyjne dla solvera IK oraz benchmarki.
   * Wprowadzić feature-flag w `Cargo.toml`.
