# Plan Implementacji — src/pipeline

Ten plik przedstawia plan rozwoju modułu `pipeline` na podstawie pomysłów zebranych w pliku `IDEA.md`, po analizie istniejącego kodu źródłowego.

## Stan obecny vs IDEA.md

Zgodnie z plikiem `IDEA.md`, moduł ten odpowiada za generyczne zarządzanie grafami zadań (DAG - Directed Acyclic Graph). Posiada już mechanizm warunkowego pomijania kroków (`addConditional` wyeksponowany w Lua API) oraz podstawowy topological sort w `dag.rs` i `scheduler.rs`.

Pozostałe pomysły zostały ocenione pod kątem korzyści architektonicznych i wydajnościowych (Value added vs. Cost).

---

## Kategoryzacja zadań (MUST / SHOULD / COULD)

### 1. MUST (Krytyczne dla czytelności i podstawowej wydajności)

* **Uporządkowanie nazewnictwa: zmiana nazwy z `pipeline` na np. `task_graph`**
  * **Wartość**: Bardzo wysoka (usuwa dezorientację pojęciową). Nazwa "pipeline" silnie kojarzy się z potokiem graficznym GPU w renderowaniu (np. `postfx_pipeline`). Moduł ten zajmuje się jednak generycznym harmonogramowaniem zadań logicznych w grafie. Zmiana nazwy na `task_graph` lub `execution_graph` drastycznie ułatwi czytelność całego silnika Lurek2D.
  * **Koszt**: Niski. Klasyczna zmiana nazwy modułu, folderu i dostosowanie importów.
  
* **Ograniczenie klonowania stringów w sortowaniu topologicznym i grupach**
  * **Wartość**: Wysoka (optymalizacja). Krokami sterują identyfikatory tekstowe, które podczas budowy grafu i jego cyklicznych aktualizacji są wielokrotnie klonowane. Przejście na współdzielone wskaźniki (`Arc<str>`) lub lekkie typy kluczy (np. liczby `u32` / `StringId`) przyspieszy działanie harmonogramu.
  * **Koszt**: Niski. Zmiana typów kluczy w `dag.rs` i `step.rs`.

* **Pomocnik/builder do deklaratywnego składania grafu z tabel Lua**
  * **Wartość**: Bardzo wysoka dla twórców gier. Zamiast pisać 10 linijek wywołań metod `addStep()`, deweloper powinien móc przekazać jedną tabelę opisującą graf (np. `{ steps = { { name = "ai", deps = { "physics" } } } }`).
  * **Koszt**: Niski/Umiarkowany. Cienki wrapper parsujący tabelę Lua w `pipeline_api.rs`.

---

### 2. SHOULD (Rekomendowane dla zaawansowanych systemów i optymalizacji)

* **Równoległe uruchamianie niezależnych gałęzi grafu (Parallel DAG Execution)**
  * **Wartość**: Bardzo wysoka na wielordzeniowych procesorach. Obecnie sortowanie topologiczne ustawia wszystkie kroki sekwencyjnie. Jeśli krok A (np. ładowanie dźwięku) i krok B (np. kalkulacja AI) są niezależne, powinny być wysyłane do puli wątków roboczych równolegle.
  * **Koszt**: Wysoki. Wymaga wdrożenia wielowątkowego dispatchera (np. za pomocą wątków roboczych z `lurek.thread`), synchronizacji mutexami/kanałami ukończenia zadań i radzenia sobie z pożyczaniem stanów w Rust.

* **Ocena overlapu modułu `pipeline` z sekwencjami w module `automation`**
  * **Wartość**: Średnia. Uniknięcie pisania podwójnego kodu do sekwencyjnych makro-zadań.
  * **Koszt**: Niski. Analiza porównawcza i ewentualne połączenie funkcjonalności.

* **Utrzymanie modułu jako TIER-2-PLUGIN (feature-gate)**
  * **Wartość**: Średnia. Nie każda prosta gra 2D potrzebuje silnika grafów zadań w Rust (wiele gier robi to w czystym Lua). Feature-gate pozwoli odchudzić silnik.
  * **Koszt**: Niski. Standardowe otoczenie modułu dyrektywami `cfg`.

---

### 3. COULD (Opcjonalne, bardzo wysoki koszt)

* **Pełne rozgałęzienia warunkowe if/else na poziomie grafu (Dynamic Branching)**
  * **Wartość**: Umiarkowana. Pozwala na dynamiczny wybór zupełnie różnych podgrafów w zależności od stanu gry. Zazwyczaj jednak prosty `addConditional` (pomijanie pojedynczego kroku) jest w 100% wystarczający.
  * **Koszt**: Bardzo wysoki. Wymaga przepisania parsera i ewaluatora grafów do obsługi węzłów decyzyjnych oraz dynamicznej modyfikacji topologii w trakcie działania.

---

## Rekomendowany harmonogram wdrożenia

1. **Faza 1 (Czytelność i Ergonomia - MUST)**:
   * Zmienić nazwę modułu na `task_graph` (lub pokrewną) w celu uniknięcia kolizji z renderowaniem.
   * Dodać deklaratywny parser tabel w Lua API.
2. **Faza 2 (Optymalizacja hot-path - MUST/SHOULD)**:
   * Zastąpić ciągłe klonowanie `String` lekkimi kluczami typu `Arc<str>`.
   * Przeanalizować integrację z modułem `automation`.
3. **Faza 3 (Wielowątkowość - SHOULD)**:
   * Zaprojektować i wdrożyć równoległy harmonogram zadań wykorzystujący pulę wątków roboczych Rust.
