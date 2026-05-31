# Plan Implementacji — src/terminal

Ten plik przedstawia plan rozwoju modułu `terminal` na podstawie pomysłów zebranych w pliku `IDEA.md`, po analizie istniejącego kodu źródłowego.

## Stan obecny vs IDEA.md

Zgodnie z plikiem `IDEA.md`, w module wprowadzono już następujące funkcjonalności:
* **Parsowanie ANSI 256-color i true-color (24-bit)**: W pełni zaimplementowane w `ansi.rs` (obsługuje sekwencje SGR `38;5;n`, `48;5;n` oraz pełne RGB `38;2;r;g;b`, `48;2;r;g;b`).
* **Interakcje myszy (hover/highlight)**: Dodano trasowanie zdarzeń myszy i obsługę fokusu w `terminal_tests.rs` oraz logikę detekcji kliknięć w `test_terminal_core_unit.lua`.
* **Wydzielenie pomocników zapisu komórek**: Wspólne helpery takie jak `set_render_cell`, `clear_render_rect` i `write_render_text` zostały zdeduplikowane i zintegrowane w rdzeniu terminala.

Pozostałe pomysły zostały ocenione pod kątem zysku do nakładu pracy (Value added vs. Cost).

---

## Kategoryzacja zadań (MUST / SHOULD / COULD)

### 1. MUST (Wysoka wartość dodana, niski/umiarkowany koszt)

* **Skróty klawiaturowe terminala (clipboard, edycja tekstu)**
  * **Wartość**: Bardzo wysoka. Aby terminal w grze (np. konsola deweloperska, REPL) był wygodny, niezbędna jest obsługa skrótów takich jak Ctrl+C (kopiowanie), Ctrl+V (wklejanie), Ctrl+A (zaznacz wszystko), a także usuwanie całych słów (Ctrl+Backspace).
  * **Koszt**: Umiarkowany. Wymaga przechwytywania odpowiednich modyfikatorów klawiszy w obsłudze zdarzeń wejściowych i integracji z systemowym schowkiem (clipboard).
  
* **Przeniesienie generycznych pomocników tekstowych do `text_utils`**
  * **Wartość**: Wysoka (architektura i deduplikacja). Operacje takie jak łamanie tekstu, mierzenie szerokości znaków UTF-8 czy usuwanie kodów ANSI są przydatne również w innych modułach (UI, czcionki).
  * **Koszt**: Niski. Czyste przeniesienie kodu z `ansi.rs`/`widget.rs` do nowo utworzonego pliku narzędziowego (np. `src/math/text_utils.rs` lub `src/terminal/text_utils.rs`) i aktualizacja importów.

---

### 2. SHOULD (Średnia wartość, umiarkowany/wysoki koszt)

* **Ograniczenie klonowania bufora siatki (grid buffer) przy kompozycji**
  * **Wartość**: Średnia. Wpływa na wydajność procesora (CPU time) przy renderowaniu rozbudowanych interfejsów terminalowych z wieloma zagnieżdżonymi widgetami. Zmniejsza narzut alokacji w każdej klatce.
  * **Koszt**: Wysoki. Wymaga przejścia na referencje oparte na czasie życia (`lifetimes`) lub sprytne współdzielenie buforów (`Arc`/`Rc` / double buffering) zamiast bezpośredniego kopiowania siatki znaków podczas składania (renderowania) drzewa widgetów.
  
* **Rozszerzenie testów widgetów terminalowych (focus/zagnieżdżenia)**
  * **Wartość**: Średnia. Zapewni, że złożone layouty terminalowe z dynamicznym przełączaniem fokusu między dziećmi nie będą zawierać błędów typu "deadlock wejściowy".
  * **Koszt**: Niski. Wymaga napisania dodatkowych scenariuszy testowych w `terminal_tests.rs`.

---

### 3. COULD (Umiarkowana wartość, niski/średnia koszt)

* **Ekstrakcja modułu jako opcjonalnego Feature Flag (TIER-2-PLUGIN)**
  * **Wartość**: Niska/Średnia. Przydatna dla deweloperów, którzy chcą zminimalizować rozmiar pliku binarnego silnika Rust (binary footprint) dla gier, które w ogóle nie korzystają z retro-terminala CLI.
  * **Koszt**: Umiarkowany. Wymaga owinięcia całego modułu `terminal` w Cargo feature (np. `#[cfg(feature = "terminal")]`) i wyczyszczenia powiązań w mostku Lua.

---

## Rekomendowany harmonogram wdrożenia

1. **Krok 1**: Wydzielić generyczne funkcje tekstowe do współdzielonego modułu narzędziowego.
2. **Krok 2**: Dodać pełną obsługę skrótów klawiaturowych (schowek + nawigacja po słowach) w pętli obsługi wejścia terminala.
3. **Krok 3**: Dokonać profilowania alokacji i zoptymalizować przepływ danych w widgetach, aby wyeliminować klonowanie siatki.
4. **Krok 4**: (Opcjonalnie) Dodać bramkę kompilacji feature gate w `Cargo.toml`.
