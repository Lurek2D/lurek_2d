# Plan Implementacji — src/render

Ten plik przedstawia plan rozwoju modułu `render` na podstawie pomysłów zebranych w pliku `IDEA.md`, po analizie istniejącego kodu źródłowego.

## Stan obecny vs IDEA.md

Zgodnie z plikiem `IDEA.md`, w module wprowadzono już następujące usprawnienia:
* **Podstawowa implementacja grubych linii (`thick lines`)**: Zaimplementowana w `gpu_renderer.rs` za pomocą metody `push_thick_line()`, która automatycznie przekształca linie o zadanej grubości na prostokątne quady w celu poprawnego renderowania przez GPU.

Pozostałe pomysły zostały ocenione pod kątem wpływu na wydajność i jakość architektury (Value added vs. Cost).

---

## Kategoryzacja zadań (MUST / SHOULD / COULD)

### 1. MUST (Krytyczne dla wydajności i utrzymania kodu)

* **Rozbicie gigantycznego pliku `gpu_renderer.rs` na podmoduły**
  * **Wartość**: Ekstremalnie wysoka dla jakości kodu. Plik `gpu_renderer.rs` ma obecnie około 280 KB i blisko 6000 linii kodu! Utrzymanie, debugowanie i dodawanie nowych funkcji do tak ogromnego monolitu jest skrajnie trudne i ryzykowne.
  * **Koszt**: Umiarkowany. Przeniesienie poszczególnych przebiegów renderowania (np. renderowanie tekstu, renderowanie kształtów wektorowych, sprite'y) do mniejszych plików w folderze `src/render/` przy zachowaniu spójnego API publicznego.
  
* **Cache'owanie geometrii statycznej (Geometry / Static draw caching)**
  * **Wartość**: Bardzo wysoka dla wydajności CPU. Wiele elementów interfejsu lub tła jest niezmiennych. Ponowna tessellacja (zamiana na trójkąty) i przesyłanie buforów wierzchołków co klatkę to marnowanie zasobów. Zapisywanie gotowej geometrii w buforach GPU drastycznie przyspieszy renderowanie.
  * **Koszt**: Średnio-wysoki. Wymaga wdrożenia menedżera buforów statycznych i mechanizmu unieważniania cache (dirty flags).
  
* **Adaptacyjny poziom szczegółowości okręgów (Adaptive circle LOD)**
  * **Wartość**: Wysoka. Rysowanie bardzo małych okręgów (np. pociski o promieniu 2 pikseli) z taką samą liczbą wierzchołków jak duże koła marnuje czas procesora na tessellację oraz obciąża potok GPU. Adaptacyjna redukcja liczby wierzchołków na podstawie promienia przyniesie szybki wzrost wydajności.
  * **Koszt**: Niski. Modyfikacja pętli generującej wierzchołki koła (dopasowanie liczby kroków interpolacji kątowej do promienia okręgu w przestrzeni ekranu).

* **Wydzielenie wspólnych pomocników shaderów i usunięcie duplikacji w `postfx_pipeline.rs`**
  * **Wartość**: Wysoka. Plik `postfx_pipeline.rs` posiada duplikacje konfiguracji blendowania i zarządzania shadow mapami. Przeniesienie ich do wspólnych helperów poprawi stabilność.
  * **Koszt**: Niski/Umiarkowany.

---

### 2. SHOULD (Rekomendowane dla zaawansowanej grafiki i optymalizacji)

* **Instancjonowanie GPU (GPU instancing)**
  * **Wartość**: Bardzo wysoka dla systemów cząsteczkowych (particles) i gęsto upakowanych środowisk. Zamiast wysyłać tysiące identycznych wierzchołków ze zmienionymi pozycjami, wysyła się jedną definicję geometrii i bufor transformacji dla instancji.
  * **Koszt**: Wysoki. Wymaga zmian w shaderach oraz potoku renderowania wgpu do obsługi wejścia instancyjnego (instance buffers).
  
* **Antyaliasing linii i kształtów (MSAA lub algorytmy wygładzania wektorowego)**
  * **Wartość**: Bardzo wysoka. Ostro rysowane wektory na ekranach o standardowej rozdzielczości mają poszarpane krawędzie (aliasing). Gładkie linie nadadzą grze profesjonalny wygląd.
  * **Koszt**: Wysoki. Uruchomienie MSAA w wgpu wymaga dodatkowych pasażów renderowania lub implementacji shaderów z piórkowaniem krawędzi wierzchołków (edge feathering).

* **Uporządkowanie nazewnictwa i zakresów (`render` vs `pipeline` vs `effect`)**
  * **Wartość**: Średnia. Ułatwi nowym programistom zrozumienie, gdzie leży granica między ogólnym potokiem zadań, potokami renderowania a efektami post-procesowymi.
  * **Koszt**: Niski. Czysto architektoniczne ustalenie granic i ewentualne refaktoryzacje nazw.

---

## Rekomendowany harmonogram wdrożenia

1. **Faza 1 (Architektura i Szybkie Zwycięstwa - MUST)**:
   * Rozbić `gpu_renderer.rs` na mniejsze podmoduły tematyczne.
   * Wdrożyć adaptacyjne LOD dla okręgów w generatorze geometrii.
   * Wydzielić wspólne pomocniki shaderów w `postfx_pipeline.rs`.
2. **Faza 2 (Optymalizacja Buforowania - MUST/SHOULD)**:
   * Zaimplementować statyczny cache geometrii.
   * Wdrożyć instancjonowanie GPU dla powtarzalnych obiektów.
3. **Faza 3 (Estetyka - SHOULD)**:
   * Zaimplementować potok antyaliasingu wektorów (np. wygładzanie krawędzi w shaderze).
