Niniejszy raport stanowi **pogłębioną analizę architektoniczną i strukturalną** plików API Twojego projektu (`lurek`, `lureksome` oraz komponentu niskopoziomowego w Rust). Dokument został sformatowany w sposób bezpośrednio przyswajalny dla **lokalnego agenta AI (np. działającego w środowisku `antigravity`)**, który ma za zadanie automatycznie zmodyfikować kod źródłowy, naprawić skrypty generujące lub przeprowadzić migrację struktur danych.

---

### SPECYFIKACJA OPERACYJNA DLA AGENTA (OPERATIONAL BOUNDS)

* **Środowisko docelowe:** Repo `antigravity` zawierające silnik Lurek2D (Rust) oraz framework Lureksome (Lua).
* **Zadanie:** Identyfikacja długu technologicznego, usunięcie niespójności w generatorach dokumentacji, ujednolicenie systemów typowania LuaCATS oraz standaryzacja konwencji nazewniczych.

---

### I. GŁĘBOKA ANALIZA STRUKTURALNA I ANTYWZORCE (DEEP REFACTORING LOG)

#### 1. Błąd Naiwnego Parsowania Przeciążeń w `tools/gen_docs_lua.py`

* **Objawy:** W pliku `api/lurek.md`, w sekcji modułu `lurek.render`, występuje masowa duplikacja identycznych sygnatur funkcji bezpośrednio pod sobą.
* **Konkretne lokacje błędów:**
* `lurek.render.beginSortGroup( id : integer )` — zdublowane w MD.
* `lurek.render.drawBevelRect( x : number, y : number, w : number, h : number, bevelW : number?, style : string?, opts : table? )` — zdublowane w MD.
* `lurek.render.drawColoredPolygon`, `drawCubicBezier`, `drawGradientRect`, `drawHexTile`, `drawIsoCubeTile`, `drawPath`, `drawQuadBezier`, `flushSortGroup`, `popLayer`, `pushLayer`, `pushSortKey` — wszystkie te elementy posiadają dokładnie zdublowane wpisy sygnatur.


* **Przyczyna techniczna:** Skrypt `gen_docs_lua.py` błędnie interpretuje wielokrotne adnotacje przeciążeń (overloading) w plikach źródłowych lub nie posiada bufora unikalności (deduplication layer) podczas zapisu do Markdown. Traktuje każdą znalezioną sygnaturę jako nowy publiczny punkt końcowy, zamiast agregować je w jeden blok z wieloma sygnaturami.
* **Instrukcja dla Agenta:** Zaimplementuj w `tools/gen_docs_lua.py` mechanizm śledzenia unikalności (np. za pomocą struktury `OrderedDict` lub zbioru `set()`), który uniemożliwi dopisanie do pliku Markdown funkcji o identycznej nazwie i sygnaturze w obrębie tego samego modułu.

#### 2. Przeciek Komentarzy Deweloperskich i Brak Filtra Długu Technicznego (`TODO` Leaks)

* **Objawy:** Komentarze implementacyjne dedykowane dla programistów systemu (core devs) trafiają do publicznej dokumentacji użytkownika końcowego.
* **Konkretna lokacja błędu:**
* W definicji klasy `CombatBattle` i jej metody `attack` (plik `api/lureksome.lua` oraz `api/lureksome.md`) widnieje wpis:
> `TODO(P4 lift): switch to lurek.math.newRng() for seedable, deterministic battle replays. Currently uses the global Lua RNG which makes saves non-deterministic across reloads.`


* Tagi `TODO` pojawiają się również przy strukturach sieciowych takich jak `NetState`.


* **Przyczyna techniczna:** Generator dokumentacji traktuje każdą linię komentarza jako opis biznesowy funkcji. Brak filtru Regex odrzucającego linie zawierające wzorce deweloperskie.
* **Instrukcja dla Agenta:** Zmodyfikuj skrypty `tools/gen_docs_lua.py` oraz `tools/gen_docs_rust.py`. Wprowadź filtr odrzucający z bloków komentarzy linie dopasowane do wyrażenia regularnego: `(?i)TODO(\([^)]+\))?:?.*`. Informacje o niedeterministycznym generatorze liczb losowych (RNG) w systemie walki powinny zostać przeniesione do wewnętrznego pliku `DEBT.md` lub trackera zadań.

#### 3. Schizofrenia Nazewnicza i Duplikacja Typów w `lureksome.lua`

* **Objawy:** Kompletny rozpad konwencji nazewniczych w definicjach klas LuaCATS frameworku rozgrywki. Część obiektów zachowuje elegancki format `PascalCase`, podczas gdy inne są skrajnymi skrótami pisanymi małymi literami `lower_case`.
* **Konkretne lokacje anomalii:**
* Standard prawidłowy: `---@class AudioManager`, `---@class StatusEffect`, `---@class CombatAction`, `---@class DollTemplate`.
* Anomalia 1 (Skróty i małe litery): `---@class seq`, `---@class part`, `---@class tmpl`, `---@class doll`.
* Anomalia 2 (Moduł Inventory): `---@class item`, `---@class stack`, `---@class slot`, `---@class container`, `---@class iset`, `---@class inv`, `---@class it`, `---@class pool`, `---@class builder`, `---@class history`, `---@class manager`.


* **Zagrożenie architektoniczne:** Współistnienie `---@class DollTemplate` oraz `---@class tmpl` w tym samym pliku sugeruje duplikację pojęć domenowych (wygląda na to, że silnik posiada dojrzały system `DollTemplate`, ale w logice wyższego poziomu ktoś używa skrótu `tmpl`). Używanie skrótów takich jak `inv` zamiast `Inventory`, czy `it` zamiast `ItemType`/`Item` niszczy czytelność podpowiedzi IntelliSense dla deweloperów gier.
* **Instrukcja dla Agenta:** Przeprowadź pełną migrację (Global Rename) w obrębie repozytorium `antigravity`:
* `inv` $\rightarrow$ `Inventory`
* `iset` $\rightarrow$ `ItemSet`
* `it` $\rightarrow$ `ItemType`
* `pool` $\rightarrow$ `ItemPool`
* `part` $\rightarrow$ `DollPart`
* `tmpl` oraz `doll` $\rightarrow$ zintegruj lub usuń na rzecz istniejących klas `Doll` i `DollTemplate`.



#### 4. Niespójność Konwencji Cyklu Życia Silnika (`lurek.lua`)

* **Objawy:** Mieszanie stylów `snake_case` oraz `camelCase` w głównych punktach wejścia (callbacks) silnika gier.
* **Konkretne lokacje anomalii:**
```lua
function lurek.process_physics(dt) end
function lurek.fixedUpdate(dt) end -- Alias for process_physics
function lurek.process_late(dt) end

```


* **Analiza:** Posiadanie dwóch aliasów dla tego samego kroku fizyki, z których jeden używa `snake_case` (`process_physics`), a drugi `camelCase` (`fixedUpdate`), świadczy o braku rygoru w warstwie pomostowej (bindings). Psuje to jednolity styl API, który we wszystkich pozostałych modułach (np. `lurek.agent`, `lurek.ai`) opiera się na strukturze `camelCase` dla metod obiektów (np. `LAISystem:addAgent`, `LAgent:setContextSize`).
* **Instrukcja dla Agenta:** Oznacz funkcję `lurek.fixedUpdate(dt)` jako `@deprecated` w pliku meta i zaimplementuj ostrzeżenie w konsoli silnika (Runtime Warning), wymuszając na deweloperach przejście na ujednoliconą strukturę pętli silnika.

#### 5. Ograniczenie Analityczne: Puste Szkielety Klas (Opaque Types)

* **Objawy:** Narzędzia takie jak `lureksome.lua` definiują typy jedynie jako puste tablice referencyjne dla metod (np. `StatusEffect = {}`, `Combatant = {}`). Brakuje deklaracji pól instancji.
* **Konkretne lokacje:** Wszystkie klasy na początku pliku `api/lureksome.lua`.
* **Analiza:** Programista wie, jakie metody wywołać na obiekcie klasy `Combatant` (np. `:getHp()`, `:getMaxHp()`), ale linter (Lua Language Server) nie zna wewnętrznej struktury pól tego obiektu, ponieważ nie zostały one zadeklarowane za pomocą dyrektywy `---@field`. Uniemożliwia to zaawansowaną analizę statyczną stanu obiektów w czasie kompilacji/lintowania.
* **Instrukcja dla Agenta:** Zautomatyzuj proces wzbogacania klas LuaCATS. Agent powinien przeanalizować konstruktory (np. funkcję `library.battle.newCombatant(name)`), wyciągnąć klucze inicjalizacyjne i dopisać je jako `---@field public [nazwa] [typ]` bezpośrednio nad deklaracją `---@class Combatant`.

---

### II. ARCHITEKTONICZNE WNIOSKI I REKOMENDACJE (STRATEGIC INSIGHTS)

1. **Potencjał Systemu Agentowego (`lurek.agent`):** Twój silnik posiada niezwykle rzadką i nowoczesną cechę – wbudowaną bezpośrednio w rdzeń architektoniczny integrację z lokalnymi modelami językowymi (LLM) za pomocą serwera Ollama (`LOllamaManager`, `LAISystem`, `LAgentMemory` z podziałem na pamięć roboczą, epizodyczną i semantyczną). Fakt, że lokalny agent w środowisku `antigravity` wdraża te poprawki, tworzy idealną pętlę zwrotną: silnik jest zoptymalizowany pod bycie modyfikowanym i sterowanym przez AI.
2. **Rekomendacja Bezpieczeństwa dla Modowania (`lurek.mods`):** Silnik zawiera moduł `mods::mod_sandbox` w Rust. Upewnij się, że podczas refaktoryzacji nazewnictwa klas w Lua (`lureksome`), do piaskownicy (`ApiRegistry`) nie zostaną przypadkowo dopisane surowe, niebezpieczne metody niskopoziomowe języka Rust, które mogłyby posłużyć do eskalacji uprawnień przez skrypty modów użytkowników.

---

### III. GOTOWE INSTRUKCJE WYKONAWCZE DLA AGENTA (ACTIONABLE EXECUTION PLAN)

Agent deweloperski uruchomiony na repozytorium `antigravity` powinien wykonać następujące makrokroki:

```yaml
KROK_1:
  Akcja: Patchowanie skryptu generatora dokumentacji Lua
  Ścieżka: tools/gen_docs_lua.py
  Instrukcja:
    - Dodaj strukturę `seen_functions = set()` dla każdego przetwarzanego modułu Markdown.
    - Zaimplementuj pomijanie linii, jeśli `line.contains("TODO")` za pomocą filtru regex.

KROK_2:
  Akcja: Refaktoryzacja nazw typów i klas (Global Naming Alignment)
  Ścieżka: api/lureksome.lua oraz kod źródłowy Lureksome
  Instrukcja:
    - Znajdź i zamień definicje klas: `seq` -> `Sequence`, `part` -> `DollPart`, `inv` -> `Inventory`, `iset` -> `ItemSet`, `it` -> `ItemType`.
    - Zaktualizuj wszystkie pliki `.lua` w projekcie implementujące te moduły, aby zachować zgodność z nowym systemem typów PascalCase.

KROK_3:
  Akcja: Deprecjonowanie niespójnych punktów wejścia pętli gry
  Ścieżka: api/lurek.lua oraz inicjalizator silnika
  Instrukcja:
    - Dodaj adnotację `---@deprecated Use lurek.process_physics instead` bezpośrednio nad `function lurek.fixedUpdate(dt) end`.

```

Wdrożenie powyższych poprawek przez Twojego lokalnego agenta pozwoli na całkowite usunięcie drobnych błędów technicznych i sprawi, że interfejs programistyczny Twojego zaawansowanego silnika będzie w 100% spójny, przewidywalny i w pełni zoptymalizowany pod kątem nowoczesnych systemów IntelliSense.
