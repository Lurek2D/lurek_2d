Master Plan Konsolidacji i Migracji Dokumentacji Lurek2D

Status: Aktywny kontrakt wykonawczy dla Agenta AI / Dewelopera.
Rygor: Bezwzględny zakaz utraty informacji (Zero-Loss Policy). Wszystkie szczegóły techniczne, tabele, standardy, przykłady kodu oraz wizje systemów z plików zewnętrznych muszą zostać wtopione w struktury plików w katalogu architecture/.

1. Wykaz Źródeł i Matryca Mapowania (Overlap Matrix)

Poniższa tabela stanowi pełne zestawienie plików przeznaczonych do migracji i konsolidacji. Każdy element musi zostać precyzyjnie przeniesiony do wskazanej lokalizacji docelowej:

Plik źródłowy (Do usunięcia)

Kluczowa zawartość techniczna

Plik docelowy w architecture/

Szczegółowy zakres fuzji i rozszerzenia

index.md

Główne wprowadzenie, spis modułów, stos technologiczny (tabele wersji).

README.md

Przekształcenie w główny portal wejściowy. Fuzja spisu treści z listami ról deweloperskich.

handbook.md

Profile użytkowników, Quickstart, komendy CLI, VS Code tasks, szablony main.lua/conf.lua, przewodnik engine-change.

developer-workflow.md (Nowy)



 README.md (Indeks)

Wyodrębnienie sekcji wdrożeniowych. Stworzenie operacyjnego przewodnika "how-to" dla nowych kontrybutorów.

codding_standards.md

Wersje bibliotek, standardy mod.rs, safe-borrow SharedState, propagacja błędów, konwencje nazewnicze, docstringi generatora, standardy skryptów Lua, asercje testowe.

scripting-bridge.md



 quality-assurance.md

Ważne: Standardy kodu i docstringów idą do scripting-bridge.md. Standardy asercji i testów jednostkowych idą do quality-assurance.md.

extension_plan.md

Układ paneli Webview, pełna lista i specyfikacja 41 dedykowanych edytorów graficznych i logicznych.

developer-ecosystem.md

Głębokie, kompletne wtopienie wizji i 8 cech funkcjonalnych dla każdego z 41 edytorów.

build_info.md

Kompilacja Windows (crt-static, MSVC runtime), dystrybucja Linux (glibc compatibility, AppImage).

build-and-distribution.md (Nowy)

Połączenie z linux_build.md w jeden, ostateczny dokument dystrybucyjny.

linux_build.md

Zależności deweloperskie, playbooki Mint/Fedora, GNU vs MUSL, optymalizacje rozmiaru (strip, UPX, tar.xz).

build-and-distribution.md (Nowy)

Kompletny, zautomatyzowany przewodnik kompilacji i dystrybucji cross-platformowej.

positioning.md

Teza rynkowa, porównanie z 10 silnikami, macierz 15 obszarów rynkowych, scorecard rynkowy, persony.

market-positioning.md (Nowy)

Strategiczny dokument pozycjonowania i obrony modelu API-first, AI-native.

2. KROK 1: Standardy Kodowania i Integracja Mostu (codding_standards.md ➔ scripting-bridge.md & quality-assurance.md)

2.1 Fuzja z architecture/scripting-bridge.md

Wprowadź na końcu pliku scripting-bridge.md sekcję ## Standardy Kodowania i Spójności API. Zaimplementuj następujące elementy o wysokim rygorze:

A. Wersje Zależności i Pinned Crate Policy

Silnik Lurek2D opiera się na ściśle określonych wersjach bibliotek bazowych. Wszelkie próby aktualizacji bez zgody Architekta są odrzucane przez Quality Gate:

Rust: stable $\ge 1.78$ (wymuszone przez rust-toolchain.toml)

mlua: 0.9 z włączonymi features ["luajit", "vendored"]

wgpu: 22 (brak planów migracji ze względu na stabilność kodu renderera)

winit: 0.30

rapier2d: 0.32

rodio: 0.17

fontdue: 0.9

B. Rygor Struktury Plików i mod.rs

Każdy plik mod.rs w silniku musi być czystym punktem re-eksportu. Dodaj do standardu mostu zakaz umieszczania jakiejkolwiek logiki biznesowej, funkcji, struktur oraz testów jednostkowych (#[cfg(test)]) w plikach mod.rs. Dozwolone są wyłącznie:

pub mod <nazwa>;

pub use <sciezka>;

Atrybuty modułu (np. #[allow(...)]) i opisy //! w formacie list wypunktowanych.

C. Bezpieczeństwo Pożyczeń (Safe State Borrowing)

Podczas wywoływania callbacków Lua z poziomu silnika Rust zachodzi krytyczne ryzyko paniki (RefCell::borrow_mut() already borrowed). Standard kodowania musi bezwzględnie wymuszać zwolnienie blokady borrow_mut() przed wejściem na granicę maszyny wirtualnej:

// POPRAWNIE: Blokada pożyczenia ulega destrukcji (drop) przed wywołaniem Lua
let value_to_pass = {
    let guard = state.borrow();
    guard.some_field.clone()
};
lua_callback(value_to_pass)?; // Bezpieczne wywołanie

// BŁĘDNIE: Blokada guard żyje na tym samym stosie co wywołanie callbacku Lua.
// Jeśli skrypt Lua wywoła re-entrantnie funkcję silnika próbującą pożyczyć stan mutowalnie -> PANIC.
let guard = state.borrow();
lua_callback(guard.some_field.clone())?;


D. Propagacja Błędów na Granicy Środowisk

Każdy błąd przekazywany przez granicę Lua-Rust musi zostać opatrzony jednoznacznym kontekstem wskazującym na miejsce wywołania. Błędy nie mogą być przekazywane w postaci surowej:

Format błędu: lurek.<module>.<function>: <opis błędu>

Przykład:

methods.add_method("load", |_, this, path: String| {
    this.inner.load(&path).map_err(|e| {
        LuaError::RuntimeError(format!("lurek.audio.load: failed to load file from path '{}': {}", path, e))
    })
});


E. Standardy Docstringów dla Generatora Dokumentacji

Generator dokumentacji parsuje wyłącznie rygorystyczny format komentarzy w plikach *_api.rs. Wprowadź poniższy szablon jako jedyny dopuszczalny standard:

Format parametru: /// @param | nazwaParametru | TypLua | Opis techniczny.

Format zwracanej wartości: /// @return | TypLua | Opis techniczny.

Obowiązkowe stosowanie spacji wokół znaku potoku (|).

Obowiązkowy separator // -- nazwaFunkcji -- bezpośrednio nad blokiem dokumentacji danej metody.

Wszystkie typy eksponowane do Lua jako UserData muszą posiadać implementację metod type() (zwraca LXxx) oraz typeOf(name) (zwraca boolean porównujący z LXxx i LObject).

2.2 Fuzja z architecture/quality-assurance.md

Wprowadź sekcję ## Standardy i Metodyki Testowania do pliku quality-assurance.md:

A. Rygor Asercji Testów Lua (BDD Layer)

Zakaz stosowania gołego assert(): Gołe asercje nie generują kontekstu diagnostycznego. Wszystkie testy BDD muszą korzystać z helperów frameworka testowego (expect_equal, expect_near, expect_true, expect_error, itp.).

Porównywanie wartości zmiennoprzecinkowych: Każde porównanie typu float musi korzystać z expect_near z zadeklarowaną tolerancją (domyślnie $1e-5$). Bezpośrednie porównanie za pomocą expect_equal na liczbach zmiennoprzecinkowych jest błędem krytycznym testu.

Zasada Izolacji Awarii (Single-Failure Point): Jeden test (it()) powinien sprawdzać tylko jeden, konkretny warunek logiczny. Łączenie wielu niezależnych asercji w jednym teście utrudnia precyzyjne przypisywanie błędów (Attribution).

B. Przykład Wzorcowego Testu BDD

Umieść kompletny, przetestowany szablon kodu z codding_standards.md jako wzorzec referencyjny na końcu pliku:

-- Lurek2D Shape API Tests
-- @describe Walidacja zachowania modułu shape i kontenera LCircle.
describe("lurek.shape", function()
    -- @covers lurek.shape.newCircle
    it("newCircle stores correct coordinates and radius", function()
        local c = lurek.shape.newCircle(10, 20, 5)
        expect_near(10, c.x)
        expect_near(20, c.y)
        expect_near(5, c.radius)
    end)

    -- @covers LCircle:contains
    it("contains returns true for internal point", function()
        local c = lurek.shape.newCircle(0, 0, 10)
        expect_true(c:contains(5, 5))
    end)
end)
test_summary()


3. KROK 2: Integracja Specyfikacji 41 Edytorów (extension_plan.md ➔ developer-ecosystem.md)

Zastąp uproszczoną listę edytorów w developer-ecosystem.md pełnym, wyczerpującym katalogiem technicznym. Przenieś kompletne opisy oraz wszystkie 8 cech funkcjonalnych dla każdego edytora:

3.1 Map and World Tools

1. TileMapEditor

Inspiracja/Referencje: Tiled Map Editor, Godot TileMap Node.

Przypadek użycia: Ręczne projektowanie 2D poziomów opartych na siatce kafelków.

Integracja z API: Bezpośredni zapis do struktury .ltm (Lurek Tile Map) ładowanej przez lurek.tilemap.

Wizja: Zapewnienie precyzyjnego, deterministycznego projektowania światów z automatycznym generowaniem kolizji.

Lista funkcji (Feature List):

Zarządzanie warstwami (dodawanie, usuwanie, reorder) dla paralaksy i sortowania głębi.

Interaktywny selektor palety kafelków pobierający dane z zdefiniowanych Tilesetów.

Pędzel do rysowania kafelków o zmiennej średnicy.

Narzędzie Flood Fill do szybkiego wypełniania dużych obszarów jednym kafelkiem.

Narzędzie Stamp do zapisywania i wklejania wielokafelkowych schematów (np. całych budynków).

Malowanie masek kolizyjnych na dedykowanej warstwie pomocniczej.

Wsparcie dla autotilingu na bazie masek bitowych w czasie rzeczywistym.

Wstrzykiwanie własnych właściwości TOML per-kafelek na potrzeby wyzwalaczy logicznych.

2. TilesetEditor

Inspiracja/Referencje: RPG Maker Tileset Manager.

Przypadek użycia: Importowanie arkuszy graficznych i definiowanie właściwości pojedynczych kafelków.

Integracja z API: Generuje pliki właściwości kafli konsumowane przez lurek.tilemap.

Wizja: Oddzielenie definicji fizycznych właściwości grafiki od samego procesu rysowania mapy.

Lista funkcji:

Definiowanie rozmiaru siatki (np. 16x16, 32x32, 64x64) i przesunięcia (offset).

Rysowanie wielokątów kolizji (solid, semi-solid, one-way) na kafelku.

Konfiguracja masek bitowych i zasad sąsiedztwa dla autotilingu.

Animowanie kafelków poprzez łączenie klatek w sekwencje o stałym interwale czasowym.

Przypisywanie tagów podłoża (np. "lód" -> śliski, "woda" -> spowolnienie).

Narzędzia precyzyjnego powiększania (zoom) i pozycjonowania siatki pikseli.

Masowa edycja właściwości kafelków przy użyciu selekcji ramką.

Eksport do ustrukturyzowanego formatu JSON/TOML zawierającego referencje do tekstury źródłowej.

3. TilemapScriptEditor

Inspiracja/Referencje: Triggery z Warcraft III World Editor.

Przypadek użycia: Przypisywanie skryptów Lua bezpośrednio do fizycznych współrzędnych siatki kafelków.

Integracja z API: Tworzy mapę triggerów wyzwalanych przez zdarzenia lurek.event przy wejściu jednostki na dany kafelek.

Wizja: Łatwe programowanie interaktywnych elementów świata (drzwi, pułapki, portale) bez zaśmiecania głównego kodu pętli gry.

Lista funkcji:

Wbudowany edytor kodu z kolorowaniem składni Lua i podpowiedziami Lurek API.

Wizualne wiązanie skryptu z konkretną komórką lub obszarem kafelkowym.

Wybór zdarzenia wyzwalającego (OnStep, OnInteract, OnLeave).

Konsola diagnostyczna dedykowana dla logów z triggerów kafelkowych.

Panel parametrów pozwalający projektantowi na zmianę zmiennych w skrypcie bez edycji kodu.

System gotowych szablonów (np. teleportacja, zadanie obrażeń, odtworzenie dźwięku).

Walidacja składni kodu Lua w locie przed zapisem.

Wizualizacja zasięgu i połączeń między triggerami na mapie.

4. WorldMapEditor

Inspiracja/Referencje: Lunar Magic (Super Mario World Map Editor), mapy z gier Paradox.

Przypadek użycia: Projektowanie makro-struktury nawigacyjnej świata gry (np. połączone punkty podróży).

Integracja z API: Eksportuje graf połączeń odczytywany przez systemy nawigacyjne lurek.pathfind i lurek.graph.

Wizja: Dostarczenie narzędzia do tworzenia poziomów wyboru misji, podróży po mapie świata i strategii terytorialnej.

Lista funkcji:

Tworzenie i pozycjonowanie węzłów (Points of Interest) na mapie tła.

Łączenie punktów ścieżkami (splajnami) z automatycznym wyliczaniem wag odległości.

Rysowanie granic regionów (poligonów) z przypisywaniem nazw i typów terenu.

Konfiguracja stref zagrożenia i losowych potyczek na ścieżkach.

Przypisywanie warunków odblokowania węzłów na podstawie flag zapisu gry.

Wizualizacja aktualnej pozycji gracza i ścieżki podróży w czasie rzeczywistym.

Przypisywanie dźwięków otoczenia (ambient) i efektów pogodowych do regionów.

Eksport kompletnej struktury grafu do formatu JSON.

5. ProvinceEditor

Inspiracja/Referencje: Nudge Tool z gier Hearts of Iron IV i Europa Universalis.

Przypadek użycia: Definiowanie terytoriów, prowincji i ich statystyk dla gier strategicznych.

Integracja z API: Tworzy bazę danych prowincji mapowaną na identyfikatory kolorów tekstury prowincji w lurek.province.

Wizja: Prosty proces podziału mapy na regiony administracyjne przy użyciu indeksowania kolorów pikseli.

Lista funkcji:

Narzędzie do precyzyjnego rysowania granic prowincji z automatycznym wykrywaniem sąsiedztwa.

Przypisywanie unikalnego koloru RGB (ID prowincji) do każdego regionu.

Panel właściwości prowincji: populacja, zasoby, typ podatków, przynależność terytorialna.

Automatyczna generacja listy prowincji sąsiadujących wraz z długością wspólnej granicy.

Filtry mapy umożliwiające podgląd prowincji według bogactwa, populacji czy kontroli militarnej.

Narzędzie lasso do masowej edycji terytorialnej.

Eksport mapy prowincji do skompresowanej tablicy indeksów.

Obsługa tagowania prowincji jako morskich, lądowych lub pustynnych.

6. GlobeEditor

Inspiracja/Referencje: Projektowanie planetarne w Kerbal Space Program / Google Earth.

Przypadek użycia: Projektowanie map i pozycjonowanie obiektów na sferycznej powierzchni planety.

Integracja z API: Zapisuje współrzędne geograficzne (szerokość/długość) przetwarzane przez trójwymiarowe rzutowanie sfery w lurek.globe.

Wizja: Zapewnienie bezszwowego i wolnego od zniekształceń rzutowania map na trójwymiarową sferę bezpośrednio w silniku 2D.

Lista funkcji:

Interaktywny podgląd 3D globu z możliwością swobodnej rotacji i przybliżania.

Rysowanie i edycja tła globu przy użyciu tekstur o rzucie walcowym równokątnym (Equirectangular).

Tworzenie i pozycjonowanie punktów orientacyjnych na bazie współrzędnych sferycznych.

Obliczanie najkrótszej odległości ortodromicznej (Great-Circle Distance) między węzłami na kuli.

Nakładanie siatki południków i równoleżników z regulowanym krokiem.

Symulacja linii terminatora (dzień/noc) na powierzchni globu.

Wizualne ostrzeżenia o zniekształceniach mapy w okolicach biegunów.

Eksport sferycznych współrzędnych punktów do tablic wektorów.

7. Procedural Map Generator (ProcMapEditor)

Inspiracja/Referencje: World Machine, Blender Geometry Nodes.

Przypadek użycia: Wizualne strojenie generatorów szumów i algorytmów tworzenia map proceduralnych.

Integracja z API: Generuje parametry i ziarna (seed) dla modułu lurek.procgen.

Wizja: Eliminacja metody prób i błędów przy kodowaniu generatorów losowych poprzez wizualny feedback generacji.

Lista funkcji:

Interaktywny podgląd generowanej mapy wysokości (heatmap) w czasie rzeczywistym.

Konfiguracja parametrów szumu Perlin, Simplex i Cellular (częstotliwość, oktawy, persystencja).

Łączenie wielu szumów przy użyciu operacji matematycznych (dodawanie, mnożenie, maskowanie).

Wizualizacja wpływu ziarna generatora (seed) na strukturę terenu.

Aplikowanie filtrów erozji hydraulicznej i termicznej bezpośrednio na podglądzie.

Generowanie jaskiń przy użyciu automatów komórkowych (Cellular Automata) z podglądem kroków.

Eksport gotowych parametrów generacji do pliku konfiguracyjnego TOML.

Bezpośredni zapis wygenerowanego heightmapu do pliku graficznego PNG.

8. NavMeshEditor

Inspiracja/Referencje: Unity Navigation Mesh, Godot NavigationPolygon.

Przypadek użycia: Definiowanie obszarów poruszania się (walkable) i przeszkód dla swobodnego pathfindingu jednostek.

Integracja z API: Zapisuje poligony nawigacyjne wykorzystywane przez algorytmy A* w lurek.pathfind.

Wizja: Wsparcie dla płynnego ruchu jednostek poza siatką kafelków przy minimalnym koszcie CPU.

Lista funkcji:

Narzędzie do rysowania poligonów nawigacyjnych z przyciąganiem do wierzchołków.

Narzędzie do wycinania "dziur" (przeszkód) wewnątrz obszarów nawigacyjnych.

Automatyczne wyprowadzanie marginesu szerokości agenta (agent radius baking).

Zarządzanie warstwami poruszania się (np. pieszo, pływanie, latanie).

Wizualny podgląd wygenerowanej siatki trójkątów nawigacyjnych (triangulacja Delaunaya).

Testowanie ścieżki w czasie rzeczywistym poprzez przeciąganie punktu startowego i końcowego.

Przypisywanie kosztów poruszania się (weights) do konkretnych poligonów.

Eksport upakowanej tablicy wierzchołków bezpośrednio do kodu Lua.

3.2 Node and Graph Tools

9. SceneFlowEditor

Inspiracja/Referencje: Unity Animator State Machine, Unreal Engine State Tree.

Przypadek użycia: Projektowanie globalnego przepływu stanów gry i przejść między scenami.

Integracja z API: Generuje plik konfiguracyjny maszyny stanów dla lurek.scene.

Wizja: Wizualna kontrola nad architekturą gry (Menu -> Game -> Pause -> Game Over) bez pisania spaghetti code warunków przejść.

Lista funkcji:

Tworzenie węzłów reprezentujących sceny gry z możliwością podglądu tła.

Łączenie scen kierunkowymi liniami przejść (transitions).

Definiowanie warunków przejścia (np. czas trwania, wywołanie eventu, zmiana flagi stanu).

Wybór i wizualna konfiguracja efektu przejścia (fade, slide, wipe, dissolve).

Narzędzie do walidacji grafu pod kątem scen nieosiągalnych lub martwych pętli.

Śledzenie aktywnego stanu gry w locie (live debugging) podczas testów silnika.

Tworzenie pod-maszyn stanów (nested state machines) dla skomplikowanych menu.

Eksport struktury przejść bezpośrednio do formatu JSON.

10. DialogEditor

Inspiracja/Referencje: Twine, Yarn Spinner.

Przypadek użycia: Tworzenie rozgałęzionych drzew dialogowych z postaciami NPC.

Integracja z API: Tworzy struktury danych dla integracji lurek.dialog i LDialogueAI.

Wizja: Projektowanie bogatych wątków fabularnych w wygodnej, wizualnej formie z pełnym wsparciem dla skryptowania.

Lista funkcji:

Wizualny edytor węzłów dialogowych (kwestie postaci, wybory gracza).

Przypisywanie warunków logicznych do opcji wyboru (np. wymagany przedmiot w ekwipunku).

Wstrzykiwanie skryptów Lua uruchamianych w trakcie wyświetlania danej kwestii (np. dodanie złota).

System tagowania i lokalizacji kluczy tekstowych dla tłumaczeń.

Łączenie grafik portretów postaci i nagrań głosowych z kwestiami dialogowymi.

Automatyczne układanie i organizacja węzłów (auto-layout) w rozbudowanych drzewach.

Narzędzie do symulowania przebiegu rozmowy bezpośrednio wewnątrz edytora.

Eksport bazy dialogowej do zunifikowanego pliku JSON.

11. QuestTreeEditor

Inspiracja/Referencje: Articy: Draft Quest Designer.

Przypadek użycia: Projektowanie struktury i celów zadań (quests) w grze.

Integracja z API: Współpracuje z modułami zapisu stanu gry lurek.save i obsługi zdarzeń lurek.event.

Wizja: Wizualna orkiestracja celów fabularnych gry gwarantująca brak sprzeczności w logice postępu.

Lista funkcji:

Tworzenie węzłów zadań z podziałem na etapy (zaczęte, aktywne cele, ukończone).

Definiowanie zależności i wymagań wstępnych między zadaniami (pre-requisites).

Konfiguracja celów etapu (zabij X, przynieś Y, porozmawiaj z Z).

Przypisywanie nagród za ukończenie etapów lub całego zadania.

Wizualna symulacja stanów zadań (sandbox) w celu walidacji ścieżek krytycznych gry.

System notatek i komentarzy autorskich dla scenarzystów wbudowany w graf.

Live tracking postępów zadań podczas uruchomionej instancji gry.

Eksport bazy zadań do formatu JSON/TOML.

12. AI Behavior Tree Editor (AiBehaviorEditor)

Inspiracja/Referencje: Unreal Engine Behavior Tree Editor, NodeCanvas.

Przypadek użycia: Wizualne projektowanie logiki sztucznej inteligencji przeciwników i NPC.

Integracja z API: Kompiluje drzewa zachowań bezpośrednio do natywnych struktur lurek.ai i LBehaviorTree.

Wizja: Czytelne, modularne projektowanie zachowań AI oparte na standardzie drzew zachowań.

Lista funkcji:

Hierarchiczna wizualizacja wykonywania drzewa od góry do dołu.

Dodawanie węzłów kontrolnych (Sequence, Selector, Parallel).

Dodawanie węzłów dekoracyjnych (Inverter, Repeater, Cooldown, Condition).

Tworzenie własnych węzłów akcji (Action Nodes) połączonych ze skryptami Lua.

Wizualny podgląd wykonywania logiki (aktywny węzeł miga na zielono) w czasie rzeczywistym.

Integracja z tablicą informacyjną (Blackboard) dla przechowywania stanu pamięci AI.

Kopiowanie i ponowne używanie poddrzew (sub-trees) między różnymi typami przeciwników.

Kompilacja drzewa do zoptymalizowanego kodu Lua.

13. GraphEditor

Inspiracja/Referencje: Unreal Engine Blueprints, Godot VisualScript.

Przypadek użycia: Generyczne programowanie wizualne logiki gry i zdarzeń.

Integracja z API: Zapisuje przepływy logiczne parsowane przez moduł lurek.graph.

Wizja: Umożliwienie projektantom tworzenia mechanik gry bez pisania surowego kodu tekstowego.

Lista funkcji:

Nieskończona, płynnie powiększana płaszczyzna robocza dla grafu.

Kolorowe piny reprezentujące typy danych (exec, float, string, vector).

Przeciąganie połączeń z automatycznym sprawdzaniem poprawności typów.

Grupowanie i komentowanie bloków kodu wizualnego przy użyciu pól tła.

Podgląd przepływu danych i wartości zmiennych na pinach podczas działania gry.

Funkcja diffowania grafów w celu ułatwienia kontroli wersji (Git).

Mini-mapa ułatwiająca nawigację po gigantycznych skryptach grafowych.

Eksport wizualnej logiki do zoptymalizowanego, wykonywalnego kodu Lua.

14. Sound DSP Panel (SoundDspEditor)

Inspiracja/Referencje: Pure Data, Max/MSP, FL Studio Patcher.

Przypadek użycia: Tworzenie efektów dźwiękowych w czasie rzeczywistym i łańcuchów przetwarzania sygnału (DSP).

Integracja z API: Konfiguruje filtry i efekty bezpośrednio w mikserze lurek.audio.

Wizja: Generowanie dynamicznych modyfikacji dźwięku (np. tłumienie pod wodą) bezpośrednio przez procesor dźwiękowy silnika.

Lista funkcji:

Grafowe łączenie filtrów audio (LowPass, HighPass, Reverb, Delay, Distortion).

Wizualizacja krzywej korektora parametrycznego (EQ) z uchwytami kontrolnymi.

Suwaki czasu odbicia, tłumienia i rozmiaru pomieszczenia dla procesora pogłosu (Reverb).

Konfiguracja parametrów kompresora dynamiki (Threshold, Ratio, Attack, Release).

Analizator spektrum audio (FFT) w czasie rzeczywistym wyświetlany na wyjściu.

Podgląd kształtu fali (waveform) odtwarzanego próbki dźwiękowej.

Przełączniki Solo/Mute/Bypass dla poszczególnych węzłów przetwarzania.

Eksport łańcucha DSP do pliku JSON ładowanego przez magistralę audio.

15. VisualShaderEditor

Inspiracja/Referencje: Godot VisualShader, Unity Shader Graph.

Przypadek użycia: Tworzenie shaderów fragmentów, wierzchołków i obliczeniowych bez pisania kodu WGSL/GLSL.

Integracja z API: Kompiluje grafy do kodu shaderów uruchamianego przez lurek.compute i lurek.render.

Wizja: Intuicyjne tworzenie zaawansowanych efektów graficznych (dissolve, water ripple, wind sway) za pomocą bloczków.

Lista funkcji:

Podgląd renderowanego efektu na sferze, płaszczyźnie lub niestandardowym duszku (sprite) w locie.

Węzły operacji matematycznych, wektorowych i teksturowych.

Łatwy import i mapowanie tekstur szumów jako wejść dla zniekształceń.

Automatyczna generacja zoptymalizowanego kodu shaderów WGSL 22.

Wstrzykiwanie zmiennych zewnętrznych (Uniforms) bezpośrednio do inspektora właściwości.

System tworzenia funkcji pomocniczych (sub-graphs) dla wielokrotnego użytku.

Obsługa shaderów wierzchołkowych (Vertex displacement) i obliczeniowych (Compute).

Statystyki wydajnościowe (GPU instruction counts) wyświetlane dla wygenerowanego kodu.

16. NetworkTopologyEditor

Inspiracja/Referencje: Godot MultiplayerSynchronizer.

Przypadek użycia: Wizualne konfigurowanie synchronizacji sieciowej encji i komunikatów RPC.

Integracja z API: Generuje reguły replikacji dla systemu sieciowego lurek.network.

Wizja: Uproszczenie implementacji kodu multiplayer poprzez wizualne przypisanie autorytetu sieciowego.

Lista funkcji:

Wizualna lista zmiennych encji z flagami synchronizacji (Server -> Client, Bidirectional).

Rejestracja zdarzeń RPC z określeniem poziomu uprawnień i trybu dostarczania (Reliable/Unreliable).

Definiowanie autorytetu sieciowego (Server Authoritative vs Client Predictive) dla typów obiektów.

Konfiguracja interpolacji i ekstrapolacji pozycji w celu maskowania lagów.

Reguły replikacji tworzenia i usuwania (spawning/despawning) encji w sieci.

Szacowanie zużycia pasma sieciowego (bandwidth estimation) na sekundę w locie.

Symulator opóźnienia sieci (ping) i utraty pakietów (packet loss) do celów testowych.

Eksport manifestu sieciowego do pliku konfiguracyjnego.

3.3 Asset and Visual Tools

17. PixelArtEditor

Inspiracja/Referencje: Aseprite, Piskel.

Przypadek użycia: Szybkie rysowanie i edycja duszki pikselowych bezpośrednio w IDE z automatycznym hot-reloadem.

Integracja z API: Zapisuje pliki PNG odczytywane i automatycznie przeładowywane przez lurek.image i lurek.sprite.

Wizja: Bezszwowy workflow grafika bez potrzeby przełączania się między zewnętrznymi programami.

Lista funkcji:

Narzędzia ołówka i gumki z trybem Pixel-Perfect (eliminacja podwójnych pikseli).

Wypełnianie kubełkiem (bucket fill) i różdżka z regulowaną tolerancją barw.

Zarządzanie warstwami z osobną przezroczystością i trybami mieszania (blend modes).

Paleta kolorów z blokowaniem do konkretnych gam kolorystycznych (np. NES, GameBoy).

Symetria rysowania w pionie i poziomie z ruchomymi osiami.

Oś czasu animacji (timeline) z obsługą klatek kluczowych.

System Onion Skinning pozwalający na podgląd sąsiednich klatek animacji.

Siatka pikseli z opcją przyciągania pędzla.

18. Particle Designer (ParticleEditor)

Inspiracja/Referencje: Particle Designer, Godot CPUParticles2D.

Przypadek użycia: Tworzenie i testowanie efektów cząsteczkowych (ogień, dym, wybuchy).

Integracja z API: Generuje parametry układów cząsteczkowych odczytywane przez lurek.particle.

Wizja: Wysoce interaktywne narzędzie do projektowania dynamicznych efektów wizualnych.

Lista funkcji:

Wybór kształtu emitera (punkt, okrąg, linia, prostokąt, maska).

Suwaki czasu życia, gęstości emisji, prędkości początkowej i maksymalnej liczby cząstek.

Krzywe (splajny) zmian koloru, rozmiaru i prędkości cząstki w czasie.

Wpływ grawitacji, sił wiatru i oporu powietrza na ruch cząsteczek.

Natychmiastowy, interaktywny podgląd cząsteczek na żywo w oknie edytora.

Wsparcie dla emisji impulsowej (burst mode) wyzwalanej zdarzeniami.

Możliwość przypisania własnego obrazka PNG jako tekstury pojedynczej cząstki.

Eksport konfiguracji do formatu JSON/TOML.

19. Sprite Animation Editor (SpriteAnimEditor)

Inspiracja/Referencje: Spine 2D, Godot AnimationPlayer.

Przypadek użycia: Tworzenie klipów animacji z arkuszy sprite'ów (spritesheets).

Integracja z API: Zapisuje definicje klatek i animacji ładowane przez lurek.animation.

Wizja: Szybki proces przekształcania statycznych arkuszy graficznych w płynne animacje postaci.

Lista funkcji:

Oś czasu do układania klatek z regulacją czasu trwania każdej z nich.

Obsługa trybów odtwarzania: Loop (pętla), Ping-pong, Once (raz).

Narzędzie do rysowania i synchronizowania masek kolizji (Hitbox/Hurtbox) bezpośrednio na klatkach.

Podgląd odtwarzania animacji w czasie rzeczywistym z kontrolą prędkości (FPS).

Onion Skinning dla ułatwienia pozycjonowania i płynności przejść.

Przypisywanie zdarzeń (events) do konkretnych klatek animacji (np. odtwórz dźwięk kroku na klatce 3).

Automatyczne wykrywanie klatek i wycinanie siatki (slice grid) z arkusza sprite'ów.

Eksport kompletnego pliku klatek kluczowych do formatu TOML.

20. Shader Preview (ShaderPreviewEditor)

Inspiracja/Referencje: ShaderToy.

Przypadek użycia: Testowanie kodu shaderów w czasie rzeczywistym na różnych próbkach graficznych.

Integracja z API: Testuje shadery ładowane do systemów lurek.render i lurek.compute.

Wizja: Szybki podgląd zmian w kodzie shaderów bez konieczności restartowania całej gry.

Lista funkcji:

Edytor kodu shaderów (WGSL) obok okna podglądu na żywo.

Automatyczna kompilacja przy zapisie z zaznaczaniem linii błędów.

Przypisywanie zmiennych ujednoliconych (Uniforms) do suwaków w edytorze.

Wbudowane zmienne czasu (iTime) i rozdzielczości (iResolution) do animacji shaderów.

Dodawanie tekstur wejściowych (samplers) do shadera poprzez przeciąganie plików graficznych.

Wybór shaderów wierzchołkowych i fragmentów osobno.

Wyświetlanie liczby klatek na sekundę (FPS) i czasu wykonania shadera na GPU.

Zapis zoptymalizowanego shadera bezpośrednio do katalogu zasobów gry.

21. VoxelEditor

Inspiracja/Referencje: MagicaVoxel, Blockbench.

Przypadek użycia: Tworzenie modeli voxelowych i generowanie rzutów izometrycznych 2.5D.

Integracja z API: Eksportuje sprite-sheety rzutów 2D dla lurek.sprite i warstwy dla lurek.raycaster.

Wizja: Proste tworzenie obiektów trójwymiarowych i automatyczne sprowadzanie ich do wydajnej formy 2D.

Lista funkcji:

Trójwymiarowa siatka robocza do rysowania voxeli.

Narzędzia ołówka, gumki i wiadra z farbą w przestrzeni 3D.

Edycja warstwowa ułatwiająca tworzenie pustych w środku struktur.

Paleta kolorów z obsługą kodów szesnastkowych.

Narzędzia wytłaczania (extrude) i wycinania ścian voxelowych.

Kamera z obsługą widoku perspektywicznego i ortograficznego.

Eksport gotowego modelu do zoptymalizowanego arkusza sprite'ów rzutów izometrycznych pod 8 kątami.

Eksport warstw przekroju poprzecznego do formatu obsługiwanego przez raycaster.

22. Skeleton Rigging Editor (SkeletonRiggingEditor)

Inspiracja/Referencje: Spine, DragonBones.

Przypadek użycia: Tworzenie szkieletu i deformacja siatki duszka 2D do animacji szkieletowej.

Integracja z API: Zapisuje kości, wagi i animacje odtwarzane przez lurek.spine.

Wizja: Płynne, oszczędne pamięciowo animacje postaci na bazie kości bez potrzeby rysowania setek klatek.

Lista funkcji:

Tworzenie i hierarchiczne łączenie kości postaci (parent-child relationship).

Narzędzie Kinematyki Odwrotnej (IK chains) dla kończyn.

Ręczne i automatyczne tworzenie siatki wierzchołków (mesh) na grafice 2D.

Malowanie wag wierzchołków (weight painting) przypisujące ich deformację do kości.

Oś czasu animacji z kluczowaniem pozycji, rotacji i skali kości.

System ubrań (skins) pozwalający na zmianę grafiki przy zachowaniu tego samego szkieletu.

Symulacja fizyki szmacianej lalki (ragdoll) na kościach w czasie rzeczywistym.

Eksport danych szkieletu do formatu JSON.

23. Lighting Environment Editor (LightingEnvironmentEditor)

Inspiracja/Referencje: Godot WorldEnvironment, oświetlenie 2D.

Przypadek użycia: Wizualne ustawianie oświetlenia otoczenia, świateł punktowych i cieni.

Integracja z API: Konfiguruje parametry oświetlenia silnika lurek.light.

Wizja: Nadanie głębi i nastroju scenom 2D za pomocą zaawansowanego oświetlenia i dynamicznych cieni.

Lista funkcji:

Kolor i energia oświetlenia otoczenia (ambient light).

Pozycjonowanie i konfiguracja świateł 2D (kolor, zasięg, intensywność, kąt).

Tworzenie poligonów blokujących światło (shadow casters) na obiektach.

Wybór filtra cieni (None, PCF5, PCF13) dla regulacji miękkości krawędzi.

Wsparcie dla map normalnych (Normal Maps) duszka dające złudzenie trójwymiarowości.

Konfiguracja masek oświetlenia (light masks) określających, co ma być oświetlane.

Suwak gęstości mgły wolumetrycznej (volumetric fog) reagującej na źródła światła.

Eksport konfiguracji oświetlenia do globalnego stanu sceny.

24. PostFX Overlay Designer (PostFxOverlayEditor)

Inspiracja/Referencje: Unity Post Processing Stack v2, ReShade.

Przypadek użycia: Projektowanie globalnych filtrów i efektów ekranowych (post-process).

Integracja z API: Konfiguruje łańcuchy efektów nakładane przez lurek.pipeline i lurek.effect.

Wizja: Łatwe i szybkie nakładanie kinowych efektów na obraz gry.

Lista funkcji:

Suwaki intensywności efektu Bloom (poświata), progu odcięcia i szerokości kolana.

Efekt aberracji chromatycznej z separacją przesunięcia kanałów RGB.

Symulacja ekranu CRT (krzywizna kineskopu, linie skanowania, szum).

Winieta, rozmycie soczewkowe (Depth of Field) i motion blur.

Import i miksowanie tablic LUT (Look-Up Tables) dla korekcji barwnej.

Podgląd przed/po (split screen) bezpośrednio na zrzucie ekranu z gry.

Monitor wydajnościowy pokazujący narzut efektów post-process na GPU.

Eksport konfiguracji post-process do TOML.

25. Color Palette Editor (ColorPaletteEditor)

Inspiracja/Referencje: Lospec.

Przypadek użycia: Definiowanie i pilnowanie spójnej palety kolorów całego projektu.

Integracja z API: Tworzy stałe kolorów odczytywane przez systemy rysowania lurek.render.

Wizja: Gwarancja doskonałej spójności artystycznej gry poprzez ograniczenie kolorów do wybranej palety.

Lista funkcji:

Koło kolorów z obsługą standardów HEX, RGB i HSL.

Zapisywanie próbek kolorów z nadawaniem im czytelnych nazw (np. "Base_Grass").

Narzędzie generowania gradientów między dwoma kolorami z interpolacją.

Sprawdzanie kontrastu kolorów pod kątem dostępności dla graczy (WCAG).

Automatyczna generacja kolorów dopełniających, triady i analogicznych.

Eksport palety do formatu skryptu Lua zawierającego tablicę kolorów.

Import gotowych palet z popularnych formatów .gpl i .hex.

Narzędzie do mapowania kolorów na obrazach w celu ograniczenia ich do palety.

26. Font Preview Editor (FontPreviewEditor)

Inspiracja/Referencje: BMFont, FontForge.

Przypadek użycia: Podgląd renderowania czcionek wektorowych i rastrowych przy różnych skalach.

Integracja z API: Przygotowuje atlasy czcionek i metryki dla lurek.render i lurek.html.

Wizja: Precyzyjna kontrola nad czytelnością tekstów i optymalizacją ich renderowania.

Lista funkcji:

Pole testowe do wpisywania własnego tekstu i sprawdzania renderu czcionki.

Podgląd wyglądu czcionki przy różnych rozmiarach i stopniach wygładzania (antialiasing).

Ręczne dostrajanie kerningu (odstępu między literami) i wysokości linii.

Wizualizacja wygenerowanego atlasu tekstury czcionki (font atlas texture packing).

Wyszukiwanie i podświetlanie brakujących glifów w czcionce.

Eksport konfiguracji metryk czcionki do pliku TOML.

Szacowanie zużycia pamięci VRAM przez atlas czcionki.

Konfiguracja czcionek rezerwowych (fallback fonts).

3.4 UI, Data, and System Tools

27. GUI Widget Editor (GuiWidgetEditor)

Inspiracja/Referencje: Figma, Unity UI Builder.

Przypadek użycia: Wizualne układanie interfejsów użytkownika (HUD, ekrany ekwipunku, menu).

Integracja z API: Eksportuje pliki układu HTML/CSS renderowane natywnie przez lurek.html.

Wizja: Projektowanie nowoczesnych interfejsów przy użyciu sprawdzonych technologii webowych bez ręcznego kodowania stylów.

Lista funkcji:

Płótno drag-and-drop do układania kontenerów, przycisków, obrazów i tekstów.

System kotwiczenia (anchoring) i wyrównywania elementów interfejsu.

Inspektor właściwości CSS (marginesy, dopełnienia, układ Flexbox, kolory).

Zarządzanie warstwami z indeksem głębokości (z-index).

Symulacja stanów przycisku (Hover, Active, Pressed) w czasie rzeczywistym.

Testowanie responsywności UI na różnych proporcjach ekranu (16:9, 4:3, 21:9).

Podgląd wygenerowanego kodu HTML i CSS bezpośrednio w panelu.

Eksport struktury interfejsu do pliku szablonu .html.

28. GUI Theme Editor (GuiThemeEditor)

Inspiracja/Referencje: Godot Theme Editor.

Przypadek użycia: Definiowanie globalnego stylu (skóry) dla wszystkich widżetów UI.

Integracja z API: Generuje pliki stylów CSS wstrzykiwane globalnie do dokumentów w lurek.html.

Wizja: Szybka i łatwa zmiana wyglądu całej gry (re-skin) poprzez modyfikację jednego pliku stylu.

Lista funkcji:

Definiowanie domyślnych stylów dla klas przycisków, paneli, suwaków i pól tekstowych.

Konfiguracja techniki 9-slice dla skalowania obramowań widżetów bez zniekształceń.

Przypisywanie czcionek, kolorów tekstu i cieni do klas tematycznych.

Definiowanie zmiennych globalnych stylu (CSS variables) dla kolorów akcentów.

Podgląd stylów na przykładowej galerii wszystkich dostępnych widżetów.

Narzędzia do kopiowania stylów między motywami.

Obsługa motywu jasnego i ciemnego z przełącznikiem w locie.

Eksport spójnego arkusza stylów .css.

29. DatabaseEditor

Inspiracja/Referencje: CastleDB, RPG Maker Database.

Przypadek użycia: Zarządzanie arkuszami danych gry (statystyki broni, przeciwników, cenniki przedmiotów).

Integracja z API: Zapisuje ustrukturyzowane bazy danych odczytywane przez lurek.data i lurek.dataframe.

Wizja: Wygodne środowisko dla projektantów balansu gry eliminujące potrzebę edycji setek plików JSON/TOML.

Lista funkcji:

Widok tabeli (arkusza kalkulacyjnego) z kolumnami o silnym typowaniu (int, float, string, boolean, enum, asset).

Relacje między tabelami (klucze obce) z wygodnym menu wyboru powiązanego wiersza.

Filtrowanie, sortowanie i grupowanie rekordów bazy danych.

Masowe operacje matematyczne (np. zwiększ obrażenia wszystkich mieczy o 10%).

Import i eksport tabel do powszechnie stosowanego formatu CSV.

Walidacja poprawności wpisywanych danych na podstawie zdefiniowanych reguł (np. cena nie może być ujemna).

Wyszukiwanie powiązań i użycia danego rekordu w innych plikach projektu.

Eksport bazy danych do skonsolidowanego pliku JSON.

30. Input Mapper (InputMapperEditor)

Inspiracja/Referencje: Steam Input, Godot Input Map.

Przypadek użycia: Definiowanie wirtualnych akcji sterowania i przypisywanie ich do fizycznych klawiszy.

Integracja z API: Zapisuje mapowania klawiszy odczytywane przez moduł wejścia lurek.input.

Wizja: Pełna separacja fizycznego sprzętu (klawiatura, pad) od logiki gry, umożliwiająca łatwy remapping klawiszy przez gracza.

Lista funkcji:

Tworzenie wirtualnych akcji sterowania (np. "Skok", "Atak", "Ruch_X").

Przypisywanie wielu fizycznych klawiszy do jednej akcji (np. Space na klawiaturze, przycisk A na padzie).

Konfiguracja martwych stref (deadzones) i krzywych czułości dla gałek analogowych.

Obsługa kombinacji klawiszy (chords, np. Shift + Ctrl + S).

Testowanie sterowania na żywo z wizualnym podglądem wciśniętych przycisków wirtualnego kontrolera.

System wykrywania konfliktów przypisań klawiszy z ostrzeżeniami.

Eksport konfiguracji sterowania do standardowego pliku TOML.

Obsługa profili sterowania per-urządzenie.

31. LocalizationEditor

Inspiracja/Referencje: POEditor, Crowdin.

Przypadek użycia: Zarządzanie tłumaczeniami tekstów gry na wiele języków.

Integracja z API: Tworzy słowniki lokalizacyjne .locale.json konsumowane przez lurek.i18n.

Wizja: Wygodne narzędzie do internacjonalizacji gry z zapobieganiem brakującym tłumaczeniom.

Lista funkcji:

Widok siatki prezentujący klucze tekstowe i tłumaczenia w kolumnach dla różnych języków obok siebie.

Automatyczne oznaczanie pustych lub nieaktualnych pól tłumaczeń kolorem ostrzegawczym.

Filtrowanie i wyszukiwanie po kluczach lub treści oryginalnego tekstu.

Wsparcie dla parametrów dynamicznych w tekstach (np. "Witaj {name}!").

Narzędzia eksportu i importu do otwartych formatów tłumaczeń CSV i JSON.

Podgląd postępu procentowego tłumaczeń na poszczególne języki.

System komentarzy kontekstowych dla tłumaczy (np. wyjaśnienie gry słów).

Wykrywanie i zapobieganie powielaniu tych samych kluczy lokalizacyjnych.

32. Physics Materials Editor (PhysicsMaterialsEditor)

Inspiracja/Referencje: Unity Physics Material 2D, Godot PhysicsMaterial.

Przypadek użycia: Definiowanie właściwości fizycznych materiałów w grze (tarcie, sprężystość).

Integracja z API: Generuje właściwości fizyczne obiektów aplikowane w lurek.physics.

Wizja: Łatwe nadawanie realistycznych zachowań fizycznych obiektom (np. śliski lód, sprężysta guma).

Lista funkcji:

Suwaki współczynników tarcia statycznego i dynamicznego.

Suwak współczynnika restytucji (sprężystość/odbijanie) z kontrolą utraty energii.

Definiowanie gęstości materiału wpływającej na automatyczne wyliczanie masy obiektu.

Mała, wbudowana piaskownica fizyczna (sandbox) do natychmiastowego testowania odbić i ślizgania.

Tworzenie nazwanych szablonów materiałów (np. "Bouncy_Ball", "Sticky_Mud").

Konfiguracja macierzy kolizji (collision layers) określającej interakcje warstw fizycznych.

Eksport stałych fizycznych do globalnego kodu gry.

Opcje włączania ciągłego wykrywania kolizji (CCD) dla bardzo szybkich obiektów.

33. Audio Mixer (AudioMixerEditor)

Inspiracja/Referencje: Mikser z programu FL Studio / Reaper.

Przypadek użycia: Zarządzanie poziomami głośności, efektami i routingiem kanałów audio.

Integracja z API: Steruje mikserem dźwiękowym lurek.audio i magistralami AudioBus.

Wizja: Profesjonalna kontrola nad miksem dźwiękowym gry z dynamicznym routingiem.

Lista funkcji:

Pionowe suwaki głośności (faders) dla dedykowanych kanałów (Master, BGM, SFX, Ambient, Voice).

Wizualne mierniki poziomu głośności w decybelach (Peak/RMS Meters).

Przełączniki Mute (wycisz) i Solo (izoluj) per-kanał.

Dynamiczne ścieżki routingu dźwięku między kanałami (Sends).

Suwaki balansu panoramy stereo (Pan) dla pozycjonowania dźwięku 2D.

System kaczora głośności (Audio Ducking) – np. automatyczne ciszenie muzyki podczas kwestii mówionych.

Wizualne ostrzeżenia przed przesterowaniem dźwięku (clipping indicator).

Eksport konfiguracji miksera do pliku profilu audio TOML.

34. Global Autoload Editor (GlobalAutoloadEditor)

Inspiracja/Referencje: Godot Autoloads / Project Settings.

Przypadek użycia: Rejestrowanie skryptów, które mają działać jako globalne singletone'y przez cały czas działania gry.

Integracja z API: Konfiguruje rejestr trwałych skryptów silnika lurek.system i lurek.scene.

Wizja: Prosty sposób na trzymanie stanów gry (np. statystyki gracza, ekwipunek) niezależnie od ładowanych scen.

Lista funkcji:

Tabela rejestracji skryptów ze wskazaniem ścieżki do pliku .lua.

Nadawanie unikalnych nazw globalnych, pod którymi skrypt będzie dostępny (np. "PlayerStats").

Konfiguracja kolejności inicjalizacji skryptów (load order).

Przełączniki pozwalające na wyłączanie konkretnych singletonów na czas testów.

Inspektor podglądu zmiennych wewnątrz zarejestrowanych singletonów na żywo.

Konfiguracja momentu bootowania (inicjalizacja przed czy po ładowaniu pierwszej sceny).

Eksport wpisów autoload do centralnego pliku konfiguracyjnego gry.

Zabezpieczenia przed błędami cyklicznych zależności między skryptami autoload.

35. Asset Manifest Editor (AssetManifestEditor)

Inspiracja/Referencje: Unity Addressables, Unreal Asset Registry.

Przypadek użycia: Zarządzanie indeksowaniem i optymalizacją asynchronicznego ładowania zasobów gry.

Integracja z API: Generuje manifesty zasobów dla sandboksa lurek.filesystem.

Wizja: Zapobieganie przycięciom gry (frametime spikes) poprzez grupowanie zasobów do załadowania w tle.

Lista funkcji:

Grupowanie zasobów w nazwane paczki (Loading Buckets, np. "Level_1_Assets").

Estymator zużycia pamięci RAM/VRAM dla każdej zdefiniowanej paczki zasobów.

Konfiguracja priorytetów kolejki pobierania i asynchronicznego ładowania plików.

Automatyczne wykrywanie i flagowanie nieużywanych (osieroconych) zasobów w projekcie.

Narzędzie do masowej zmiany formatów lub kompresji obrazów i dźwięków.

Pakowanie i szyfrowanie paczek zasobów do skompresowanych archiwów .pak.

Interaktywna wizualizacja zajętości pamięci przez zasoby w locie.

Eksport manifestu do zunifikowanego formatu JSON.

36. Performance Profiler (PerformanceProfilerEditor)

Inspiracja/Referencje: Profiler z silnika Godot, Chrome DevTools Performance.

Przypadek użycia: Monitorowanie wydajności gry, zużycia pamięci, liczby wywołań rysowania oraz wątków.

Integracja z API: Odbiera dane telemetryczne z lurek.devtools i lurek.debugbridge.

Wizja: Centrala dowodzenia optymalizacją gry gwarantująca stabilne 60 FPS na docelowym sprzęcie.

Lista funkcji:

Wykresy czasu klatki (Frame-time graphs) z podziałem na CPU, GPU i logikę Lua.

Licznik operacji rysowania (Draw Calls) i stopnia upakowania geometrii (Sprite Batching).

Monitor zużycia pamięci RAM oraz alokacji na karcie graficznej (VRAM).

Wykresy aktywności procesów odśmiecania pamięci (Lua Garbage Collector pauses).

Wykresy czasu trwania poszczególnych kroków fizycznych (physics simulation steps).

Wykres płomieniowy (Flame Graph) pokazujący czas wykonywania poszczególnych funkcji Lua.

Zdalne profilowanie skompilowanej gry działającej na innej maszynie przez sieć.

Możliwość zapisywania i porównywania zrzutów wydajności (performance snapshots).

37. Project Export Editor (ProjectExportEditor)

Inspiracja/Referencje: Godot Export Templates.

Przypadek użycia: Konfigurowanie platform docelowych i pakowanie gotowej gry do dystrybucji.

Integracja z API: Kompiluje i konfiguruje parametry dystrybucyjne silnika lurek.engine.

Wizja: Łatwy proces publikacji gry na wszystkie wspierane systemy desktopowe jednym kliknięciem.

Lista funkcji:

Wybór platformy docelowej (Windows, Linux, macOS).

Przypisywanie ikon gry dla różnych rozdzielczości systemowych per-platforma.

Ustawienia domyślne okna: Fullscreen, Resizable, VSync, blokada klatek, proporcje obrazu.

Flagi bezpieczeństwa (np. wyłączenie konsoli deweloperskiej i debuggera w wydaniu Release).

Filtry wykluczania plików (np. pomijanie surowych plików .psd lub .wav przy eksporcie).

System podpisywania kodu i przygotowania instalatorów (np. integracja z NSIS dla Windows).

Wskaźnik postępu i logi procesu pakowania gry w czasie rzeczywistym.

Eksport gotowych paczek bezpośrednio do katalogu wyjściowego.

38. Test Runner (TestRunnerEditor)

Inspiracja/Referencje: VS Code Test Explorer, Jest Runner.

Przypadek użycia: Zarządzanie i uruchamianie testów jednostkowych Lua BDD oraz testów integracyjnych Rust.

Integracja z API: Wykonuje testy poprzez interfejsy lurek.debugbridge i lurek.devtools.

Wizja: Narzędzie wspierające metodykę TDD (Test-Driven Development) gwarantujące brak regresji przy zmianach w kodzie.

Lista funkcji:

Wizualna lista wszystkich testów podzielona na kategorie (Passed, Failed, Skipped, Running).

Wyszukiwanie i filtrowanie testów przy użyciu wyrażeń regularnych.

Przyciski uruchamiania pojedynczych testów, całych plików lub wszystkich testów naraz.

Rozwijany stos błędów (stack trace) ze wskazaniem konkretnej linii kodu Lua w przypadku awarii.

Raportowanie pokrycia kodu testami (code coverage) w postaci wizualnej nakładki na edytor.

Mierniki czasu wykonania każdego testu w milisekundach w celu wykrywania wąskich gardeł.

Tryb ciągłego monitorowania (Watch Mode) automatycznie uruchamiający test po zapisaniu pliku.

Rejestrowanie logów i wyjścia konsoli osobno dla każdego uruchomionego testu.

39. API Reference Browser (ApiReferenceEditor)

Inspiracja/Referencje: Dash, Zeal.

Przypadek użycia: Szybki, lokalny dostęp do pełnej dokumentacji silnika Lurek2D.

Integracja z API: Odczytuje wygenerowane pliki dokumentacji z generatora lurek.docs.

Wizja: Kompletne, offline'owe źródło prawdy o funkcjach silnika bezpośrednio w zasięgu ręki programisty.

Lista funkcji:

Szybkie wyszukiwanie (fuzzy search) wszystkich modułów, funkcji, stałych i typów silnika.

Czyszczenie i renderowanie plików Markdown dokumentacji w atrakcyjny, czytelny sposób.

Gotowe przykłady użycia i fragmenty kodu (code snippets) z opcją kopiowania jednym kliknięciem.

Aktywne linkowanie między powiązanymi funkcjami i typami parametrów.

Szybkie kopiowanie sygnatur funkcji bezpośrednio do schowka systemowego.

Wsparcie dla ciemnego i jasnego motywu czytnika dokumentacji.

Przegląd parametrów wejściowych i typów zwracanych w postaci ustrukturyzowanych tabel.

Szybki skrót klawiszowy otwierający dokumentację dla słowa, na którym stoi kursor.

4. KROK 3: Kompilacja i Dystrybucja Cross-Platformowa (build_info.md + linux_build.md ➔ build-and-distribution.md)

Stwórz nowy, wyczerpujący dokument w katalogu architecture/build-and-distribution.md o następującej strukturze i szczegółach:

4.1 Windows Standalone Release

Domyślnie Windows dynamicznie linkuje MSVC runtime, co skutkuje błędem o braku VCRUNTIME140.dll na czystych instalacjach systemu.

Rozwiązanie: Statyczne linkowanie C runtime przy użyciu flag kompilatora Rust.

Konfiguracja w .cargo/config.toml:

[target.x86_64-pc-windows-msvc]
rustflags = ["-C", "target-feature=+crt-static"]


Polecenie kompilacji:

$env:RUSTFLAGS="-C target-feature=+crt-static"
cargo build --release


4.2 Linux Portability & GLIBC Conflict

Problem z GLIBC_X.XX not found występuje, gdy binarka jest kompilowana na nowszej wersji glibc niż ta obecna w systemie użytkownika. Glibc gwarantuje kompatybilność wyłącznie wsteczną.

Zasada budowania: Kompiluj silnik na najstarszej dystrybucji docelowej posiadającej stabilne wydanie (zalecane: Ubuntu 20.04 Focal z GLIBC 2.31).

Musl Warning: Odrzuć target musl jako domyślny pod oprogramowanie graficzne. musl wykazuje poważne problemy z kompatybilnością sterowników graficznych Vulkan (wgpu) oraz obsługą okien winit/X11/Wayland.

A. Wymagane Biblioteki Systemowe na Linux (Runtime)

Upewnij się, że silnik informuje lub pakiet instalacyjny zawiera zależności:

libX11.so.6, libXcursor.so.1, libXrandr.so.2, libXi.so.6 (X11)

libwayland-client.so.0 (Wayland)

libxkbcommon.so.0 (Klawiatura)

libvulkan.so.1 (Vulkan)

libasound.so.2 (ALSA dla rodio)

B. Przygotowanie Paczki AppImage pod Linuksa

Kroki automatyzacji dla skryptów dystrybucyjnych:

Kompilacja silnika w środowisku ze starszym glibc (np. Docker z Ubuntu 20.04):

cargo build --profile dist


Pobranie narzędzia linuxdeploy:

wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage


Przygotowanie struktury lurek2d.desktop:

[Desktop Entry]
Name=Lurek2D Game
Exec=lurek2d
Icon=lurek2d
Type=Application
Categories=Game;


Pakowanie za pomocą linuxdeploy (wypakowanie zależności oprócz glibc i czarnej listy):

./linuxdeploy-x86_64.AppImage --appdir AppDir \
   --executable target/dist/lurek2d \
   --desktop-file lurek2d.desktop \
   --icon assets/lurek2d.png \
   --output appimage


4.3 Strategie Kompresji i Redukcji Rozmiaru Binarek

Aby osiągnąć optymalne rozmiary plików wykonywalnych:

Strip: Zawsze usuwaj tabele symboli z binarnej wersji dystrybucyjnej:

strip --strip-unneeded target/release/lurek2d


UPX: Dopuszczalne, ale opcjonalne. Dodaj do dokumentacji zastrzeżenie, że niektóre systemy antywirusowe flagują spakowane za pomocą UPX pliki jako false-positive. Kompresja wewnątrz paczki AppImage lub spakowanie do tar.xz jest zalecaną alternatywą.

5. KROK 4: Pozycjonowanie Rynkowe (positioning.md ➔ market-positioning.md)

Stwórz nowy plik architecture/market-positioning.md o strukturze i detalach z positioning.md:

5.1 Teza AI-Native

Wyjaśnij szczegółowo, dlaczego Lurek2D jest rewolucją w dobie asystentów programowania:

Standardowe silniki wymagają manipulacji wizualnej (klikana hierarchia scen), która jest niewidoczna dla kontekstu LLM.

Lurek2D mapuje całe zachowanie gry wyłącznie na potężne, deterministyczne i w pełni przetestowane API lurek.*.

Asystent AI nie musi halucynować kodu ani zgadywać ułożenia węzłów w edytorze – operuje na idealnie odwzorowanym modelu API, co redukuje współczynnik błędów (AI Slop Rate) do minimum.

5.2 Macierz Porównawcza i Scorecard

Umieść kompletną macierz porównania silnika Lurek2D z Godot, Love2D, Unity i GameMaker. Opisz każdy z 15 obszarów rynkowych oraz tabelę scorecard, udowadniając przewagę w dobie asystentów AI.

6. KROK 5: Przewodnik Deweloperski i Podręcznik (handbook.md + index.md ➔ developer-workflow.md & README.md)

6.1 Portale Wejściowe w architecture/README.md

Zmień plik architecture/README.md w zunifikowany hub. Powinien on zawierać:

Szybkie wprowadzenie do silnika (stos technologiczny, wersje wgpu/mlua).

Mapę ról deweloperskich (GameDev, EngDev, Modder, Player, GameTest, EngTest) wraz z przypisaniem ich do odpowiednich plików dokumentacji architektury.

Główny spis treści odsyłający do wszystkich skonsolidowanych dokumentów z katalogu architecture/.

6.2 Nowy plik architecture/developer-workflow.md

Stwórz plik architecture/developer-workflow.md zawierający operacyjne instrukcje krok po kroku z podręcznika:

Przewodnik "First 30 minutes":

Wymóg instalacji stabilnego narzędziownika Rust $\ge 1.78$ i Pythona $\ge 3.10$.

Skompilowanie i uruchomienie ekranu powitalnego: cargo run.

Uruchomienie gier demonstracyjnych: cargo run -- content/games/showcase/hello_world.

Instrukcje tworzenia pierwszej gry:

Struktura katalogu gry (wymóg main.lua, opcjonalnie conf.lua).

Wklej wzorcowy, najprostszy kod gry (obsługa lurek.init, lurek.process(dt), lurek.draw()).

Instrukcje wdrożenia zmian w silniku:

Wyszukanie modułu w src/.

Wprowadzenie zmiany w kodzie Rust.

Obowiązkowa regeneracja specyfikacji i API stubs za pomocą python tools/gen_all_docs.py.

Dodanie testów Lua BDD w tests/lua/unit/ oraz testów integracyjnych w Rust.

Uruchomienie pełnego przejścia przez jakość (Quality Gate) przed commitem.

7. Instrukcje Techniczne i Walidacja dla Agenta (Automation-Friendly)

Dla zagwarantowania, że proces konsolidacji nie popsuje automatycznych walidatorów, agent wykonujący migrację musi przestrzegać poniższego algorytmu:

Bezwzględne unikanie duplikacji: Podczas przenoszenia reguł z codding_standards.md do scripting-bridge.md, upewnij się, że nie powielasz już istniejących tam sekcji. Łącz bloki tekstu logicznie.

Zgodność wyrażeń regularnych: Wszelkie komentarze do API (docstringi) modyfikowane w procesie czyszczenia muszą być kompatybilne z parserem tools/docs/gen_lua_api_data.py. Naruszenie formatu potoków | w @param i @return popsuje build.

Wykonanie skryptów po migracji:
Po fizycznym skasowaniu starych plików z katalogu głównego, uruchom w terminalu:

python tools/gen_all_docs.py
python tools/validate/cag_validate.py
cargo test
cargo clippy -- -D warnings


Dowolny status inny niż exit 0 oznacza regresję i błąd w procesie migracji.

Dokument zatwierdzony przez Architekta Systemu Lurek2D.



---------------------------


Plan Migracji i Konsolidacji Dokumentacji Lurek2D

Status: Aktywny plan wykonawczy dla Agenta AI / Developera.
Cel: Przeniesienie i pełna fuzja wszystkich rozproszonych plików dokumentacji (*.md z katalogu głównego) do zunifikowanego, spójnego i rygorystycznego standardu w katalogu architecture/ bez utraty szczegółów technicznych.

1. Ocena i Analiza Plików Wejściowych (Audit)

Poniższa tabela przedstawia analizę plików znajdujących się obecnie poza katalogiem architecture/ oraz ich relację do istniejących dokumentów architektury:

Plik źródłowy

Zawartość i kluczowe informacje

Status & Analiza Nakładania się (Overlap)

index.md

Strona główna, krótki opis stosu i linki.

Do usunięcia. Linki i stos zostaną zintegrowane bezpośrednio z nowym spisem treści oraz plikiem architecture/README.md.

handbook.md

Przewodnik wdrożeniowy: Quickstart, Repotour, Build & Run, Pisanie pierwszej gry/zmiany w silniku, pipeline dokumentacji.

Do migracji. Instrukcje wdrożeniowe i "First game/engine change" zostaną wydzielone do nowego pliku architecture/developer-workflow.md.

codding_standards.md

Standardy kodu Rust/Lua, standardy docstringów *_api.rs, standardy testów i kompletne przykłady implementacji.

Duży overlap. Standardy *_api.rs pokrywają się z scripting-bridge.md. Standardy testów pokrywają się z quality-assurance.md. Wszystkie unikalne reguły (np. upvalue, dt, borrow_mut) muszą zostać wtopione w dokumenty docelowe.

extension_plan.md

UI/UX paneli VS Code, szczegółowy opis i wizja 41 dedykowanych edytorów.

Duży overlap. Plik architecture/developer-ecosystem.md wymienia te edytory tylko z nazwy. Unikalne, głębokie opisy (wizja, 8 cech funkcjonalnych dla każdego z 41 edytorów) muszą zostać wtopione bezpośrednio do developer-ecosystem.md.

build_info.md

Budowanie standalone (Windows crt-static, Linux glibc, AppImage).

Overlap. Częściowo pokrywa się z linux_build.md. Oba pliki zostaną skonsolidowane w nowy dokument: architecture/build-and-distribution.md.

linux_build.md

Kompleksowy przewodnik dystrybucji Linux (GNU vs MUSL, UPX, AppImage, playbooki Mint/Fedora).

Do konsolidacji. Łączy się z build_info.md tworząc jednolity plik architecture/build-and-distribution.md.

positioning.md

Pozycjonowanie rynkowe, analiza porównawcza z 10 silnikami, scorecard, unikalność podejścia AI-first.

Do migracji. Zostanie przekształcony w nowy plik wewnątrz katalogu: architecture/market-positioning.md.

2. Docelowa Mapa Architektury (Target Map)

Wszystkie pliki po konsolidacji muszą znajdować się w katalogu architecture/. Poniższa struktura staje się jedynym źródłem prawdy dla projektu:

architecture/
├── README.md                  # Zaktualizowany indeks (fuzja index.md + handbook tour)
├── philosophy.md              # [BEZ ZMIAN] Filozofia i twarde ograniczenia
├── engine-core.md             # [ENRICHED] Architektura rdzenia i cykl życia
├── render-pipeline.md         # [BEZ ZMIAN] Trójwarstwowy model renderowania
├── scripting-bridge.md        # [ENRICHED] Integracja standardów kodowania i docstringów z codding_standards.md
├── modularity-plugins.md      # [BEZ ZMIAN] Podział na wtyczki i Feature Surfaces
├── developer-ecosystem.md     # [ENRICHED] Integracja 41 szczegółowych specyfikacji edytorów z extension_plan.md
├── quality-assurance.md       # [ENRICHED] Integracja standardów testowania i asercji z codding_standards.md
├── developer-workflow.md      # [NEW] Przewodnik "First 30 minutes", "First game", "First engine change" (z handbook.md)
├── build-and-distribution.md  # [NEW] Kompilacja standalone, glibc, AppImage, UPX (fuzja build_info.md + linux_build.md)
└── market-positioning.md      # [NEW] Analiza rynkowa, scorecard, AI-first philosophy (z positioning.md)


3. Szczegółowe Instrukcje Migracji Krok po Kroku

Krok 1: Konsolidacja standardów kodowania (codding_standards.md)

A. Fuzja z architecture/scripting-bridge.md

Wtop sekcję standardów do scripting-bridge.md jako dedykowany rozdział na końcu dokumentu, zachowując:

Regułę bezpiecznego pożyczania SharedState (zwolnienie mutowalnego borrow przed callbackiem Lua w celu uniknięcia reentrance panic).

Standardy nazewnictwa typów Lua (prefix Lua w Rust, widoczne jako L w Lua, np. LuaVec2 -> LVec2).

Zasady walidacji na granicy typów (clamping floatów, walidacja zakresu integerów przy castowaniu do u32/usize, walidacja string-enumów).

Standardy skryptów Lua (§6 z codding_standards.md):

Bezwzględne użycie wyłącznie przestrzeni lurek.*.

Separacja logiczna on_process(dt) (mutacja stanu) od on_render() (czyste rysowanie bez mutacji).

Bezwzględny wymóg mnożenia zmian fizycznych/ruchowych przez dt.

Przetrzymywanie stanu w zmiennych lokalnych (local), zakaz upvalues przeżywających zmianę sceny.

Ścieżki zasobów wyłącznie relatywne do katalogu gry.

Appendix C (Kompletny przykład implementacji LuaUserData dla LuaCircle) – wklej jako integralną część dokumentu scripting-bridge.md w sekcji standardów kodu.

B. Fuzja z architecture/quality-assurance.md

Przenieś standardy testowania jednostkowego Lua i Rust z codding_standards.md (§7 i §8) do quality-assurance.md:

Zasady asercji: Bezwzględny zakaz stosowania gołego assert(). Wprowadź tabelę dozwolonych funkcji asercyjnych harnessu (expect_equal, expect_near, etc.).

Porównywanie floatów: Wymóg stosowania expect_near dla wszystkich typów zmiennoprzecinkowych.

Zasada "Jeden test = jeden powód awarii": Przenieś przykłady poprawnego i błędnego testu clamping_volume.

Appendix D (Kompletny plik testowy Lua BDD) – wklej na końcu quality-assurance.md jako wzorcowy szablon testu jednostkowego.

Krok 2: Specyfikacja Edytorów i Ekosystemu (extension_plan.md)

Wykonaj głęboką fuzję danych z extension_plan.md bezpośrednio do architecture/developer-ecosystem.md.

A. Rozbudowa sekcji "Editor catalog and local specs"

Zamiast obecnej płaskiej listy edytorów, zmień tę sekcję w szczegółowy katalog. Dla każdego z 41 edytorów (pogrupowanych w sekcje: Map and world tools, Node and graph tools, Asset and visual tools, UI/Data/System tools) przenieś z extension_plan.md:

Inspiracje / Referencje (np. Aseprite, Piskel dla PixelArtEditor).

Przypadek użycia (Use Case).

Integracja z API Lurek2D (np. powiązanie z lurek.tilemap dla TileMapEditor).

Wizję i unikalne cechy (Ideas / Vision).

Pełną listę 8 cech funkcjonalnych (Feature list).

B. Dodanie UX/UI Layout Conventions

Przenieść sekcję "UX / UI Layout Conventions for Webview Editors" z extension_plan.md na początek opisu edytorów w developer-ecosystem.md. Musi ona precyzyjnie definiować rozkład przestrzenny (Action Toolbar, Left Sidebar, Right Sidebar, Center Canvas, Bottom Panel).

Krok 3: Budowanie Standalone i Dystrybucja Linux (build_info.md + linux_build.md)

Stwórz nowy dokument: architecture/build-and-distribution.md.

A. Sekcja Windows Build

Zintegruj informacje o statycznym linkowaniu runtime C++ (VCRUNTIME140.dll):

Użycie flagi $env:RUSTFLAGS="-C target-feature=+crt-static" przy cargo build --release.

Konfiguracja w .cargo/config.toml dla targetu x86_64-pc-windows-msvc.

B. Sekcja Linux Build & Portability

Zintegruj pełną treść z linux_build.md i build_info.md:

Problem wersji GLIBC: Wyjaśnienie mechanizmu kompatybilności wstecznej glibc i konieczność budowania na najstarszej wspieranej dystrybucji (np. Ubuntu 20.04 z glibc 2.31).

Dynamiczne zależności: Lista bibliotek współdzielonych (libX11, libwayland-client, libvulkan, libasound, etc.).

Instrukcje dystrybucji:

Spakowanie jako portable folder + archiwum tar.xz.

Budowanie paczki AppImage z użyciem linuxdeploy (dokładne 4 kroki: przygotowanie binarki, pobranie linuxdeploy, struktura .desktop, pakowanie AppDir).

Strategia kompresji i rozmiaru ELF:

Zastosowanie strip --strip-unneeded i wydzielenie symboli debugowania.

Opcjonalne użycie UPX oraz zalety kompresji wbudowanej w AppImage.

Playbooki instalacyjne dla deweloperów: Kompleksowe polecenia apt (Mint/Ubuntu) oraz dnf (Fedora) ze wszystkimi nagłówkami deweloperskimi (np. libasound2-dev, alsa-lib-devel).

Krok 4: Pozycjonowanie Rynkowe (positioning.md)

Stwórz nowy dokument: architecture/market-positioning.md.

Przenieś do niego bez zmian strukturalnych:

Główną tezę pozycjonowania: "Lurek2D is the API-first, AI-native 2D runtime".

Macierz porównawczą silników (Engine Comparison Matrix) dla 10 alternatywnych technologii (Godot, Love2D, Unity, Bevy, Solar2D, itp.).

Szczegółową ocenę 15 obszarów rynkowych (API Surface Size, Documentation Completeness, AI-First Tooling, etc.).

Tabelę wyników (Summary Scorecard) z oceną gwiazdkową (★).

Model "API as Building Blocks" wyjaśniający różnicę w podejściu rynkowym Lurek2D względem GameMaker.

Krok 5: Integracja Podręcznika Wdrożeniowego (handbook.md + index.md)

A. Zaktualizowanie architecture/README.md

Zintegruj zawartość index.md i handbook.md (Spis treści i wprowadzenie) bezpośrednio z głównym plikiem indeksu architektury, tak aby stanowił on punkt wejścia do całej dokumentacji.

B. Stworzenie architecture/developer-workflow.md

Przenieś operacyjne sekcje z handbook.md do dedykowanego pliku przepływu pracy programisty:

Pierwsze 30 minut (First 30 minutes): Instalacja Rust, klonowanie, uruchamianie splash screenu oraz demo showcase.

Zalecane rozszerzenia VS Code i rola katalogu .vscode/.

Tabela zadań Workspace (Common Workspace Tasks): Mapowanie etykiet zadań VS Code na surowe komendy CLI (np. clippy, fmt, sweepy, testy).

Pisanie pierwszej gry (Writing your first game): Kod źródłowy minimalnego szkieletu main.lua z cyklem życia (init, process, draw) oraz pliku conf.lua.

Wdrożenie pierwszej zmiany w silniku (Writing your first engine change): Instrukcja krok po kroku dodawania nowych funkcjonalności i modyfikacji specyfikacji modułów.

4. Instrukcja Cleanup i Walidacji dla Agenta

Po zakończeniu fizycznego przenoszenia i scalania treści do katalogu architecture/, Agent wykonujący migrację musi bezwzględnie przeprowadzić następujące kroki czyszczące:

Usunięcie starych plików z głównego katalogu:

rm index.md handbook.md codding_standards.md extension_plan.md build_info.md linux_build.md positioning.md


Aktualizacja spisu treści:
Zaktualizuj plik architecture/README.md oraz odnośniki w pozostałych plikach tak, aby wszystkie ścieżki wskazywały na nowe lokalizacje (np. codding_standards.md -> scripting-bridge.md#code--documentation-standards).

Uruchomienie skryptów walidacyjnych:
Deweloper / Agent musi upewnić się, że parser dokumentacji i testów nie zgłasza błędów:

python tools/validate/cag_validate.py
python tools/audit/doc_coverage.py
python tools/audit/lua_test_structure_audit.py


Zgłoszenie gotowości:
Dodaj odpowiedni wpis w docs/CHANGELOG.md opisujący konsolidację struktury dokumentacji pod wersją 1.0.0.

Plan wygenerowany przez Architekta Systemu Lurek2D. Wszystkie ograniczenia techniczne i architektoniczne zostały zachowane.
