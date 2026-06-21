# Household Finance Lab

_Kompleksowe laboratorium finansów domowych — analityczny dashboard oparty o bazy danych SQL, biblioteki Dataframe, zaawansowane wykresy statystyczne oraz interaktywne widżety UI._

## 🎮 O aplikacji (About the Application)

**Household Finance Lab** to zaawansowana aplikacja demonstracyjna o charakterze analityczno-biznesowym (data science), prezentująca możliwości silnika Lurek poza obszarem tradycyjnych gier wideo. Jest to w pełni funkcjonalny, pięcioosobowy dashboard finansów gospodarstwa domowego, obsługujący wieloletnie analizy budżetowe.

Kluczowe mechaniki i potok przetwarzania danych (data pipeline):
1. **Generowanie Danych** – aplikacja wykorzystuje generator liczb losowych silnika (`lurek.math.newRandomGenerator`) do deterministycznego wygenerowania wieloletniego zbioru transakcji CSV (lata 2021-2025) dla 5 domowników.
2. **Potok Analityczny i SQL (LDatabase & LDataFrame)**:
   - Wczytuje wygenerowany plik CSV asynchronicznie za pomocą `lurek.dataframe.fromCSVFileAsync`.
   - Buduje bazę danych w pamięci (**LDatabase**) i wykonuje złożone, parametryzowane zapytania SQL zlokalizowane w zewnętrznych plikach katalogu `sql/` przy użyciu `LDatabase:queryParams`.
   - Wykorzystuje silnik analityczny **LDataFrame** do zaawansowanych obliczeń statystycznych: wyznaczanie z-score, detekcja anomalii (outliers), ruchome średnie (rolling mean), ruchome sumy, zmiany procentowe oraz wyliczanie wskaźnika płynności finansowej (runway months).
3. **Pamięć Podręczna (Database Cache)**:
   - Zapisuje i odtwarza przetworzoną bazę za pomocą `LDatabase:save` i `lurek.dataframe.loadDatabase`, a mały plik manifestu serializuje z użyciem `lurek.serial.toJson`.
4. **Interaktywne Widżety UI (lurek.ui)**:
   - Bogaty interfejs użytkownika z zakładkami (Tabs), filtrami, listami rozwijanymi (Combo Boxes), suwakami (Sliders), przełącznikami oraz tabelami GUI (`LGuiTable`) zasilanymi bezpośrednio z DataFrame.
   - Generuje dynamiczne wykresy finansowe na bazie danych DataFrame i zapisuje je jako tekstury/obrazy do wyrenderowania na ekranie.
   - Posiada wbudowaną **ochronę przed przeciążeniem (debounce filter)** – suwaki nie wywołują zapytań SQL przy każdym mikroruchu wskaźnika, lecz dopiero po krótkiej chwili stabilizacji.

Aplikacja uruchamia się w natywnej, nieprzeskalowanej czcionce bitmapowej (`scale_mode = "none"`), gwarantując absolutną ostrość i czytelność danych tekstowych bez rozmyć fractional scaling.

## 🚀 Uruchomienie (Run Instructions)

Uruchom aplikację na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/apps/household_finance_lab
```

## 🕹️ Obsługa i Interfejs (Controls & Interface)

Sterowanie opiera się w pełni na precyzyjnej interakcji myszką z elementami interfejsu GUI.

| Kontrolka UI | Akcja | Opis działania |
| :--- | :--- | :--- |
| **Kursor myszy / LPM** | Kliknięcie / Wybór | Obsługa zakładek, rozwijanie Combo Boxów, klikanie przycisków eksportu |
| **Suwaki (Sliders)** | Przeciąganie suwaka | Filtrowanie zakresów kwot lub dat (zabezpieczone debouncingiem SQL) |
| **Zakładka Widgets/API** | Informacje techniczne | Wyświetla stan bazy danych, liczbę tabel, status wykresów oraz raport testów |
| **Escape** | Wyjście | Zamknięcie aplikacji i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Platformy analityczne typu Tableau / PowerBI** oraz **biblioteki Pandas w Pythonie**
  - *Opis powiązania*: Aplikacja to niesamowity hołd dla profesjonalnych narzędzi analitycznych (Business Intelligence) oraz bibliotek analityki danych. Udowadnia, że lekki silnik gier Lurek2D jest w stanie z powodzeniem pełnić funkcję **wysokowydajnego środowiska aplikacyjnego i raportowego (analytic dashboard)**. Integruje wewnątrz zintegrowanego środowiska Lua zapytania SQL, manipulacje tabelaryczne rodem z pytonowego *Pandasa*, rendering GUI oparty o elastyczne pliki layoutów TOML, oraz generowanie wykresów statystycznych w czasie rzeczywistym.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Aplikacja jest najbardziej kompleksowym pokazem zaawansowanych funkcji bazodanowych, matematycznych oraz widżetów interfejsu w Lurek2D:

- `lurek.dataframe` (`LDataFrame` & `LDatabase`) – Baza danych SQL w pamięci, asynchroniczne ładowanie CSV, funkcje data-science (rolling stats, outliers, z-score).
- `lurek.ui` – Zaawansowane wczytywanie i generowanie całego bogatego interfejsu użytkownika na podstawie plików definicji TOML (`layouts/`), w tym widżety tabel i wykresów.
- `lurek.math.newRandomGenerator` – Generuje spójne, deterministyczne dane transakcyjne na przestrzeni 5 lat.
- `lurek.serial.toJson` – Serializuje metadane i stany pamięci podręcznej do JSON.
- `lurek.render` – Niskopoziomowy rendering statycznych, ultra-ostrych czcionek wektorowych i bitmapowych oraz wykresów.
- `lurek.timer` – Kontroluje opóźnienia filtrów (debouncing) oraz dostarcza precyzyjne czasy klatkowe i renderowania (`timer.getFPS`).
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To absolutnie najważniejszy, koronny pokaz **analityki danych i systemów bazodanowych (data science & database query engine)** oraz **profesjonalnego tworzenia aplikacji biznesowych (enterprise app GUI showcase)**. Udowadnia, że Lurek to nie tylko zabawka do robienia prostych zręcznościówek retro, ale potężna platforma obliczeniowa zdolna asynchronicznie przetwarzać tysiące wierszy CSV, wyliczać statystyki kroczące i renderować responsywne kokpity managerskie z debouncingiem SQL.
- **Unikalność**: Jedyna aplikacja biznesowo-analityczna (data science application) w całej kolekcji, nieposiadająca charakteru gry, prezentująca unikalne moduły SQL i DataFrame oraz natywne renderowanie ostrych czcionek bitmapowych bez skalowania.
- **Podobne gry**: Brak zbliżonych produkcji w repozytorium. Household Finance Lab to całkowicie unikalna, profesjonalna kategoria demonstracyjna.
