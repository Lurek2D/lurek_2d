# Plan Implementacji — src/pipeline

Ten plik przedstawia plan rozwoju modułu `pipeline` po analizie istniejącego kodu źródłowego i zrealizowanych zmian.

## Status realizacji (DONE / TODO)

### DONE

* MUST: deklaratywny builder grafu z tabel Lua (`fromTable`) — zrealizowane.
* MUST: ograniczenie klonowania stringów w hot-path DAG/scheduler — zrealizowane.
* MUST: inkrementalna zmiana nazewnictwa (`task_graph` alias w Rust + `lurek.task_graph` alias w Lua) — zrealizowane.

### TODO

* SHOULD: równoległe uruchamianie niezależnych gałęzi grafu.
* SHOULD: ocena overlapu z `automation`.
* SHOULD: feature-gate modułu.
* COULD: pełne dynamic branching (if/else dla podgrafów).

## Stan obecny

Moduł ten odpowiada za generyczne zarządzanie grafami zadań (DAG - Directed Acyclic Graph). Posiada mechanizm warunkowego pomijania kroków (`addConditional` wyeksponowany w Lua API) oraz podstawowy topological sort w `dag.rs` i `scheduler.rs`.

Pozostałe pomysły zostały ocenione pod kątem korzyści architektonicznych i wydajnościowych (Value added vs. Cost).

---

## Kategoryzacja zadań (MUST / SHOULD / COULD)


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
