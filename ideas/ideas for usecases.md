Canvas 2: Ocena i Ekspansja Use Case'ów Lurek2D

Niniejszy dokument stanowi rygorystyczny audyt technologiczny scenariuszy użycia opisanych w plikach use_cases.md oraz positioning.md w bezpośrednim zderzeniu z udostępnionym plikiem specyfikacji api. Ocena została przeprowadzona z perspektywy architekta systemów oprogramowania i ma na celu zweryfikowanie spójności wywołań oraz identyfikację fizycznych ograniczeń runtime'u.

1. Krytyczna Walidacja Istniejących Use Case'ów (UC-01 do UC-49)

Analiza wykazała, że większość zaprojektowanych scenariuszy użycia wykazuje unikalną, niespotykaną w innych silnikach gier spójność z API. Lurek2D nie jest jedynie "silnikiem graficznym" z doklejonym interpreterem; to zunifikowane środowisko obliczeniowe. Poniżej znajduje się szczegółowa weryfikacja techniczna reprezentatywnych use case'ów.

A. Weryfikacja: UC-22 (Supply Chain & Logistics Optimiser) — SUKCES

Analiza spójności z API: Moduł lurek.flownet idealnie pokrywa ten scenariusz. Zamiast pisać własny graf przepływu w Lua, programista otrzymuje natywny, skompilowany w Rust silnik sieci przepływowych:

Tworzenie struktury sieci za pomocą lurek.graph.newGraph().

Definiowanie węzłów transformujących (np. huty, fabryki) metodą LGraphNode:setConversion(in_type, out_type, in_count, out_count).

Modelowanie buforów magazynowych za pomocą LGraphNode:setQueueCapacity(c) oraz setOverflowPolicy(p) (obsługujące polityki typu reject, destroy czy queue).

Wydajność: Kluczowe znaczenie ma funkcja LGraph:tickParallel(dt). Dzięki implementacji opartej na bibliotece rayon w Rust, symulacja sieci logistycznej zawierającej $N \ge 10\ 000$ węzłów może być procesowana wielowątkowo, co eliminuje narzut jednowątkowego środowiska Lua.

B. Weryfikacja: UC-24 (Personal Finance & Budget Dashboard) — SUKCES

Analiza spójności z API: Scenariusz ten udowadnia, że Lurek2D może zastąpić frameworki typu Electron w lekkich aplikacjach biznesowych (rozmiar binarka $\le 10$ MB).

Kluczowe mapowanie API:

Wczytywanie danych: lurek.dataframe.fromCSVFileAsync(path) pozwala na asynchroniczne ładowanie plików bazodanowych bez blokowania wątku renderowania UI. Zwraca obiekt LDataFrameTask, którego stan odpytujemy nieblokująco przez task:isDone().

Silnik zapytań: Klasa LDatabase i metoda LDatabase:queryAsync(sql_str) implementują in-memory silnik SQL (parser i executor w Rust). Pozwala to na wykonywanie zapytań typu SELECT category, SUM(amount) FROM txs GROUP BY category bezpośrednio na ramkach danych.

Wizualizacja: Integracja z LGuiTable:setDataFrame(df, opts) automatycznie parsuje i renderuje tabele danych w interfejsie użytkownika, eliminując potrzebę pisania pętli renderujących w Lua.

C. Weryfikacja: UC-36 (Offline DSP Audio Processing Pipeline) — SUKCES

Analiza spójności z API: Scenariusz ten w pełni wykorzystuje tryb --headless oraz dedykowany moduł lurek.dsp:

Nieliniowe i liniowe filtry aplikowane są bezpośrednio na plikach za pomocą lurek.dsp.processOffline(input_path, output_path, effects_table).

Automatyczna normalizacja sygnału: lurek.dsp.normalize(input, output, target_level).

Generowanie podglądów wizualnych (np. dla systemów CMS lub edytorów) realizowane jest bezalokacyjnie przez lurek.dsp.waveformToPng i lurek.dsp.spectrogramToPng (generujący spektrogram oparty na oknie Hanna i transformacie DFT).

2. Architektoniczne "Czerwone Flagi" (Gaps & Limitations)

Mimo wybitnej spójności z API, identyfikuję trzy krytyczne obszary ryzyka (Red Flags), w których teoretyczne use case'y mogą zderzyć się z ograniczeniami technologicznymi Lurek2D.

🚩 Red Flag 1: Brak wejściowego API audio (Audio Capture Gap)

Problem: Scenariusze takie jak UC-19 (Music Sequencer) oraz projektowana instalacja UC-58 (reagująca na głos) zakładają analizę sygnału mikrofonowego w czasie rzeczywistym. Jednak dokładna analiza lurek.audio i lurek.dsp ujawnia, że silnik posiada API wyłącznie do odtwarzania (playback), dekodowania oraz syntezy (synthesis).

Brakujące ogniwo: W API nie ma żadnej funkcji typu lurek.audio.startCapture() ani lurek.audio.getMicrophoneBuffer().

Konsekwencja: Scenariusze wymagające interakcji głosowej w czasie rzeczywistym są obecnie niemożliwe do zrealizowania bez zewnętrznego procesu przekazującego próbki audio przez mostek sieciowy (np. WebSocket za pomocą LNetworkRuntime:wsConnect).

🚩 Red Flag 2: Pamięciożerność baz in-memory na urządzeniach Edge (RAM Constraints)

Problem: Scenariusz UC-25 (Stock & Market Data Dashboard) oraz UC-11 (Robotics Visualiser) zakładają ciągłą agregację danych pomiarowych lub giełdowych do struktur LDataFrame i LDatabase na urządzeniach Edge ARM (np. Raspberry Pi z 4GB RAM).

Fizyczne ograniczenie: LDataFrame przechowuje dane w pamięci RAM (ColumnStore w Rust). Lurek2D nie posiada natywnego sterownika do baz dyskowych (brak SQLite/PostgreSQL w specyfikacji API).

Konsekwencja: Przy intensywnym strumieniowaniu danych (np. $100$ ticków na sekundę), system bardzo szybko wyczerpie pamięć RAM lub doprowadzi do agresywnego zrzucania pamięci (GC thrashing) w LuaJIT. Programista musi implementować własną politykę rotacji danych (np. za pomocą LRingBuffer lub lurek.binary.newRingBuffer) na poziomie skryptu Lua.

🚩 Red Flag 3: Izolacja wątków (Shared-Nothing Architecture)

Problem: Use case'y zakładające ciężkie obliczenia równoległe (np. wieloagentowe symulacje) mogą napotkać wąskie gardło wydajnościowe na poziomie komunikacji między wątkami.

Architektura: Moduł lurek.thread implementuje model aktorów bez współdzielenia pamięci. Każdy LThreadHandle to całkowicie wydzielona instancja maszyny wirtualnej Lua. Komunikacja odbywa się wyłącznie przez przesyłanie komunikatów na kanale LChannel.

Wąskie gardło: Przesyłanie dużych struktur danych (np. całych tabel Lua lub ramek danych) wymaga ich serializacji do formatu MessagePack za pomocą lurek.binary.toMsgPack i deserializacji po drugiej stronie. Koszt procesora na operacje $I/O$ w kanale przy wysokiej częstotliwości może zniwelować zyski z wielowątkowości.

3. Ekspansja Katalogu: Zaawansowane Scenariusze Użycia (UC-50 do UC-70)

W celu podwojenia liczby scenariuszy użycia i zaprezentowania pełni możliwości modularnych silnika Lurek2D, poniżej znajduje się katalog nowo zaprojektowanych use case'ów, skupiających się na nietrywialnych synergiach modułów analitycznych, AI, graficznych i sieciowych.

UC-50: Autonomiczny Red-Teaming i Symulator Lateral Movement (Edge ARM)

Cel: Modelowanie topologii sieci IT i automatyczna symulacja propagacji zagrożeń (np. ransomware) za pomocą autonomicznych agentów na fizycznym urządzeniu Edge (Raspberry Pi) wpiętym do sieci laboratoryjnej.

Miks Modułów: flownet · dataframe · agent · pipeline · validator

Implementacja API:

flownet: Reprezentuje topologię sieci. Węzły (LGraphNode) to hosty/serwery, a krawędzie (LGraphEdge) to połączenia sieciowe. Wektory ataku są modelowane jako LGraphItem płynące w sieci z prędkością zależną od LGraphEdge:getSpeedModifier().

dataframe: Przechowuje bazę podatności i logi skanowania maszyn. Za pomocą LDataFrame:query agent filtruje cele o najwyższym współczynniku podatności (np. zscore otwartych portów).

agent: Model lokalny (Ollama) analizuje konfigurację firewalli i generuje w locie skrypty eksploitacji, uruchamiane w odizolowanym środowisku przez LAgent:evalCode(code).

pipeline: Koordynuje fazy cyberataku (Reconnaissance $\rightarrow$ Intrusion $\rightarrow$ Lateral Movement $\rightarrow$ Exfiltration) jako transakcyjne kroki z obsługą błędów.

Złożoność: ⭐⭐⭐⭐⭐ (bardzo wysoka)

UC-51: Predykcyjny Kontroler Farm Fotowoltaicznych i Mikrosieci (ARM64 Edge)

Cel: Autonomiczne sterowanie przepływem energii (panele, magazyny, sieć zewnętrzna) w czasie rzeczywistym na podstawie prognoz pogody i lokalnego wnioskowania predykcyjnego.

Miks Modułów: learning (ONNX) · dataframe · network · ui · pipeline

Implementacja API:

network: Pobiera prognozę nasłonecznienia z zewnętrznego API i odpytuje inwertery za pomocą LNetworkRuntime:httpGet().

dataframe: Gromadzi dane historyczne o zużyciu, obliczając średnie kroczące za pomocą LDataFrame:rollingMean() w celu estymacji profilu obciążenia.

learning: Model LOnnxModel (załadowany przez loadOnnx()) przetwarza tensor wejściowy LTensor (historyczne zużycie + pogoda) i generuje prognozę produkcji na kolejne $24$ godziny.

pipeline: Zarządza harmonogramem ładowania baterii, realizując przełączenia przekaźników fizycznych (symulowanych przez stan FSM).

Złożoność: ⭐⭐⭐⭐ (wysoka)

UC-52: AI-Driven Generative RPG Dungeon Master (Desktop / Edge)

Cel: Klasyczna gra RPG, w której świat, lochy, questy oraz interakcje z NPC są w 100% generowane w czasie rzeczywistym przez lokalne modele LLM współpracujące z algorytmami proceduralnymi.

Miks Modułów: agent · procgen (WFC z LLM) · dialog · tilemap · render

Implementacja API:

procgen: Funkcja lurek.procgen.wfcFromPrompt(prompt, config) pyta lokalną Ollamę o zasady sąsiedztwa płytek graficznych (np. "lochy w stylu gotyckim"), po czym natywny algorytm Wave Function Collapse (wfcGenerate) buduje spójną mapę kafelkową.

agent: Generuje opisy pokoi, unikalne statystyki potworów i zapisuje je do LAgentMemory (pamięć epizodyczna).

dialog: Dynamicznie tworzy drzewa dialogowe z NPC na podstawie ich celów życiowych i nastroju.

Złożoność: ⭐⭐⭐⭐⭐ (bardzo wysoka)

UC-53: Automatyczny Optymalizator Linii Produkcyjnej (RL Digital Twin)

Cel: Symulator taśmy produkcyjnej w fabryce, który w tle automatycznie trenuje agenta Reinforcement Learning w celu maksymalizacji przepustowości i eliminacji wąskich gardeł.

Miks Modułów: learning (LEnv/LQLearner) · flownet · dataframe · charts · pipeline

Implementacja API:

flownet: Symuluje fizyczną linię produkcyjną. Maszyny to węzły z czasem procesowania (setProcessTime), a taśmociągi to krawędzie (LGraphEdge) z przepustowością.

learning: lurek.learning.defineEnv owija sieć flownet w środowisko kompatybilne z Gym, gdzie akcją jest zmiana priorytetu maszyn, a stanem – zapełnienie kolejek.

LQLearner uczy się optymalnego sterowania ruchem produktów, dążąc do maksymalizacji nagrody (przepustowości).

Złożoność: ⭐⭐⭐⭐ (wysoka)

UC-54: Mobilny Terminal Taktyczny dla Służb Ratunkowych (ARM64 Offline)

Cel: Tablet dla straży pożarnej działający w strefie klęski żywiołowej bez zasięgu sieci komórkowej, służący do wyznaczania stref zagrożenia pożarowego i dróg ewakuacji.

Miks Modułów: globe / province · pathfind (HPA*) · network (lokalne ad-hoc) · ui · save (offline)

Implementacja API:

province: Przechowuje mapę topograficzną terenu jako siatkę wielokątów.

pathfind: Algorytm findHpaPath na siatce nawigacyjnej wyznacza najbezpieczniejszą drogę dla wozów strażackich, omijając aktywne ogniska pożaru.

network: Wykorzystuje lokalne radio ad-hoc do synchronizacji pozycji innych zespołów za pomocą syncEntity i biletów przekaźnikowych (newRelayTicket).

Złożoność: ⭐⭐⭐⭐ (wysoka)

UC-55: Autonomiczny Asystent Programowania Gier (Self-Debugging Lua Assistant)

Cel: IDE i runtime, w którym silnik gry sam wykrywa błędy wykonania Lua, przesyła traceback do lokalnego LLM, generuje poprawkę i aplikuje ją w locie (hot-patching) bez restartu gry.

Miks Modułów: agent (evalCode) · devtools · repl · debugbridge · validator

Implementacja API:

devtools: Wyłapuje błąd wykonania i pobiera pełny stos wywołań przez lurek.devtools.getCallStack().

agent: Odbiera kod błędu, analizuje podejrzany plik za pomocą lurek.grep i generuje poprawny fragment kodu.

evalCode: Funkcja LAgent:evalCode(code) uruchamia poprawiony fragment bezpośrednio w działającej maszynie wirtualnej, natychmiast naprawiając błąd.

Złożoność: ⭐⭐⭐⭐⭐ (bardzo wysoka)

UC-56: Inteligentny Trenażer i Analizator EKG / Sygnałów Medycznych (Desktop / Edge)

Cel: Urządzenie monitorujące sygnały biomedyczne w czasie rzeczywistym, filtrujące szum, wykrywające anomalie pracy serca i wizualizujące wykresy medyczne.

Miks Modułów: compute (FFT/Filters) · dataframe · charts · ui · audio

Implementacja API:

compute: Wykonuje szybką transformatę Fouriera lurek.compute.fft na buforze wejściowym sygnału EKG w celu eliminacji zakłóceń sieciowych (filtr cyfrowy Notch 50Hz).

dataframe: Analizuje odległości między załamkami R (interwał R-R), obliczając średnią kroczącą i odchylenie standardowe zmienności rytmu serca (HRV).

charts + ui: Rysuje płynny, przewijany elektrokardiogram oraz wykres widma częstotliwościowego.

Złożoność: ⭐⭐⭐ (średnia)

UC-57: Symulator i Planer Taktyczny dla Autonomicznych Rojów Dronów (Edge ARM)

Cel: Planowanie misji poszukiwawczo-ratunkowych dla roju dronów. Każdy dron posiada lokalny miks modułów do unikania kolizji i mapowania terenu.

Miks Modułów: ai (ORCA Solver) · pathfind (Flow Field) · visibility (Fov) · network · thread

Implementacja API:

ai: lurek.ai.newORCASolver(time_horizon) oblicza bezkolizyjne wektory prędkości dla każdego dronu w roju w czasie rzeczywistym.

pathfind: Generuje globalne pole przepływu newFlowField(grid) kierujące rój do strefy docelowej.

visibility: Każdy dron skanuje otoczenie za pomocą algorytmu rzucania cieni (shadowcasting) lurek.visibility.newFov(), budując wspólną mapę widoczności.

thread: Dystrybuuje obliczenia nawigacyjne na osobne wątki CPU na pokładzie komputera drona (ARM64).

Złożoność: ⭐⭐⭐⭐⭐ (bardzo wysoka)

UC-58: Multimedialna Instalacja Artystyczna Reagująca na Ruch i Muzykę

Cel: Projekcja wielkoformatowa generująca płynne obrazy cząsteczkowe na podstawie analizy pasm częstotliwości wejścia audio i kamer ruchu.

Miks Modułów: dsp (SpectrumAnalyzer) · compute · particle · light · camera

Implementacja API:

dsp: lurek.dsp.newSpectrumAnalyzer() analizuje sygnał audio i dzieli go na 32 pasma częstotliwości.

compute: Mapuje energię pasma basowego na siłę grawitacji emiterów cząsteczek, a wysokie tony na ich prędkość rotacji.

particle: Generuje efekty cząsteczkowe za pomocą lurek.particle.newSystem().

light: Dynamicznie steruje światłami Light2D z efektem migotania addFlicker zsynchronizowanym z rytmem.

Złożoność: ⭐⭐⭐ (średnia)

UC-59: Narzędzie do Proceduralnego Generowania i Testowania Map w CI/CD

Cel: Narzędzie uruchamiane w chmurze CI/CD, które generuje 1000 wariantów poziomu gry, przechodzi je automatycznie botem AI i raportuje współczynnik ukończenia (solvability).

Miks Modułów: procgen · pathfind · ai (BehaviorTree) · dataframe · serial

Implementacja API:

procgen: Generuje unikalny układ korytarzy i komnat na podstawie zdefiniowanych kafelków za pomocą lurek.procgen.wfcGenerate().

pathfind: Buduje siatkę nawigacyjną i sprawdza podstawową osiągalność punktu końcowego za pomocą findPath().

ai: Uruchamia bota testowego opartego na drzewie zachowań lurek.ai.newBehaviorTree(), który próbuje przejść poziom.

dataframe: Zapisuje wyniki każdego testu. SQL-owe zapytanie generuje na koniec raport: "Zidentyfikowano 12 nieprzejezdnych konfiguracji map".

Złożoność: ⭐⭐⭐⭐ (wysoka)

UC-60: Cyfrowy Bliźniak Autonomicznej Floty Magazynowej (AGV Robot Fleet)

Cel: Trójwarstwowy system monitoringu i optymalizacji floty wózków widłowych w magazynie. Lurek2D wizualizuje pozycje maszyn, symuluje ich optymalne ścieżki i planuje zlecenia transportowe.

Miks Modułów: flownet · pathfind (JpsGrid) · ui · network · dataframe

Implementacja API:

network: Odbiera pozycje rzeczywistych wózków z sensorów Ultra-Wideband (UWB) po WebSockecie.

pathfind: Oblicza najkrótsze ścieżki przejazdu omijające regały za pomocą szybkiego algorytmu Jump Point Search lurek.pathfind.newJpsGrid(width, height).

flownet: Kolejkuje zlecenia pobrania palet (LCommandQueue) i przypisuje je do wolnych wózków na bazie ich aktualnego obciążenia i odległości.

ui + dataframe: Wyświetla panel wydajności floty (KPI) i czasy oczekiwania na załadunek.

Złożoność: ⭐⭐⭐⭐⭐ (bardzo wysoka)

UC-61: Predykcyjny System Zarządzania Ruchem Miejskim (Smart City Traffic Control)

Cel: Monitorowanie skrzyżowań, symulowanie przepływu pojazdów i dynamiczne sterowanie cyklami świateł w celu minimalizacji korków przy użyciu algorytmów genetycznych.

Miks Modułów: flownet · learning (LGeneticAlgorithm) · dataframe · timer · ui

Implementacja API:

flownet: Reprezentuje siatkę ulic. Skrzyżowania to węzły o ograniczonej przepustowości, a drogi to krawędzie LGraphEdge z czasem przejazdu zależnym od natężenia ruchu.

learning: Algorytm genetyczny lurek.learning.newGeneticAlgorithm(pop_size, gene_count, seed) optymalizuje czasy trwania zielonego światła (geny) na poszczególnych skrzyżowaniach. Funkcja fitness jest wyliczana jako ujemna średnia czasu oczekiwania pojazdów pobrana z dataframe.

dataframe: Rejestruje czasy przejazdu każdego wirtualnego pojazdu i agreguje je w czasie rzeczywistym.

Złożoność: ⭐⭐⭐⭐⭐ (bardzo wysoka)

UC-62: Decentralny Symulator Giełdy Energii Peer-to-Peer

Cel: Symulacja lokalnego rynku energii, na którym domostwa z panelami fotowoltaicznymi handlują nadwyżkami prądu z sąsiadami przy użyciu teorii gier i ubiegania się o zasoby (Dijkstra/GoalMap).

Miks Modułów: pathfind (GoalMap) · economy (library) · dataframe · network · agent

Implementacja API:

economy: Każde domostwo posiada instancję ResourceManager zarządzającą saldem walutowym i stanem energii (baterii).

pathfind: Sieć dystrybucyjna jest modelowana jako GoalMap, gdzie źródłami (sources) są domostwa z nadwyżką energii. Koszt Dijkstra reprezentuje straty na przesyle sieciowym.

agent: Agenci LLM reprezentują "inteligentnych konsumentów", którzy negocjują ceny zakupu/sprzedaży energii na podstawie prognozy zużycia w dataframe.

Złożoność: ⭐⭐⭐⭐⭐ (bardzo wysoka)

UC-63: Heraldyczny Generator i Encyklopedia Rodów (RPG Lore Factory)

Cel: System generujący unikalne tarcze herbowe, drzewa genealogiczne, historie rodów oraz ich relacje dyplomatyczne w grze strategicznej.

Miks Modułów: procgen (Markov NameGen) · image · patterns (RelationshipManager) · serial · render

Implementacja API:

procgen: Generuje unikalne nazwiska rodów za pomocą lurek.procgen.generateNames(samples, count).

image: Proceduralnie składa herby z gotowych elementów (szarże, tarcze, barwy) na warstwach LLayeredImage i zapisuje je jako PNG.

patterns: lurek.patterns.newRelationshipManager() zarządza sojuszami, wrogami i historią małżeństw między rodami, dynamicznie zmieniając ich stany w FSM.

Złożoność: ⭐⭐⭐ (średnia)

UC-64: Akustyczny Lokalizator i Radar dla Okrętów Podwodnych (Stealth Sonar Sim)

Cel: Symulator sonaru pasywnego i aktywnego na okręcie podwodnym. Gracz analizuje sygnały hydroakustyczne (widmo częstotliwości), aby wykryć i zidentyfikować wrogie jednostki w cieniu akustycznym.

Miks Modułów: dsp (SpectrumAnalyzer) · compute (FFT/Filters) · visibility (Fov) · physics · render

Implementacja API:

physics: Okręty poruszają się w środowisku fizycznym rapier2d. Prędkość śrub napędowych generuje hałas (stimulus) w LStimulusWorld.

dsp: lurek.dsp.analyzeFft() analizuje szum oceanu i nakłada filtry pasmowe w celu wyizolowania częstotliwości charakterystycznych dla silników spalinowych.

visibility: Ukształtowanie dna morskiego (baza w LTerrain) działa jak blocker dla rozchodzenia się fal dźwiękowych, obliczany przez rekurencyjny shadowcasting w lurek.visibility.newFov().

Złożoność: ⭐⭐⭐⭐ (wysoka)

UC-65: Inteligentny Diagnosta Sieci Kolejowej (Train Operations Digital Twin)

Cel: Monitorowanie sieci kolejowej, symulowanie rozkładów jazdy, predykcja opóźnień i automatyczne wykrywanie konfliktów na jednotorowych odcinkach linii.

Miks Modułów: flownet · pathfind (NavGrid) · dataframe · pipeline · ui

Implementacja API:

flownet: Sieć kolejowa jest odwzorowana jako graf. Stacje to węzły, a tory to krawędzie o pojemności setCapacity(1) (reprezentujące blokadę liniową — na torze może znajdować się tylko jeden pociąg).

pathfind: Pociągi wyznaczają trasy alternatywne w przypadku opóźnień za pomocą LUnitPathfinder:findPath().

pipeline: Każdy pociąg realizuje przejazd jako sekwencję kroków pipeline'u (odjazd $\rightarrow$ jazda $\rightarrow$ mijanka $\rightarrow$ postój) z obsługą timeoutów i opóźnień.

dataframe + ui: Loguje czasy odjazdów i rysuje wykresy ruchu (wykresy wstęgowe) na żywo.

Złożoność: ⭐⭐⭐⭐⭐ (bardzo wysoka)

UC-66: AI-Driven Procgen Level Evaluator (WFC + LLM Quality Loop)

Cel: W pełni automatyczny pipeline projektowania poziomów do gry logicznej. Generator WFC tworzy układ, boty BehaviorTree go testują, a LLM modyfikuje reguły sąsiedztwa płytek, aby dopasować poziom trudności.

Miks Modułów: procgen (WFC) · ai (BehaviorTree) · agent · dataframe · serial

Implementacja API:

procgen: Generuje poziomy za pomocą lurek.procgen.wfcGenerate().

ai: Bot sterowany przez lurek.ai.newBehaviorTree() podejmuje próby przejścia wygenerowanej planszy.

dataframe: Loguje historię ruchów bota, liczbę cofnięć i ostateczny czas przejścia planszy.

agent: Ollama analizuje statystyki z dataframe i generuje nowy zestaw reguł sąsiedztwa w formacie JSON (za pomocą lurek.procgen.setConstraintsFromLLM), aby celowo ułatwić lub utrudnić kolejną generację.

Złożoność: ⭐⭐⭐⭐⭐ (bardzo wysoka)

UC-67: Taktyczny Panel Mapowy dla Zarządzania Kryzysowego (Crisis GIS Map)

Cel: Interaktywny dashboard do koordynacji działań ratunkowych podczas powodzi. Łączy mapy prowincji z sensorami poziomu rzek i automatycznym routingiem dla dostaw amfibiami.

Miks Modułów: province · pathfind (Dijkstra) · dataframe · network (SSE Stream) · ui

Implementacja API:

province: Reprezentuje mapowane obszary i gminy za pomocą LProvinceRegistry.

network: Odbiera na żywo odczyty z sensorów hydrograficznych za pomocą strumienia Server-Sent Events lurek.network.sseConnect().

dataframe: Agreguje odczyty i automatycznie podnosi poziom alarmu powodziowego dla prowincji (LProvinceRegistry:setFogState reprezentuje stan podtopienia).

pathfind: Wyznacza bezpieczne trasy transportowe dla pojazdów ratunkowych omijające zalane prowincje.

Złożoność: ⭐⭐⭐⭐ (wysoka)

UC-68: Autonomiczny Ekosystem Sztucznego Życia (Artificial Life Simulation)

Cel: Symulacja ewolucyjna populacji organizmów (botów) posiadających zmysły (FOV), cechy osobowości (Traits), potrzeby (Needs) i mózgi (sieci neuronowe) ewolujące w czasie.

Miks Modułów: learning (Neuroevolution) · ai (Needs + Fov) · physics · dataframe · render

Implementacja API:

physics: Organizmy to fizyczne koła poruszające się w lurek.physics.newWorld().

ai: Każdy bot posiada LNeedSystem (głód, pragnienie) oraz LFov do skanowania otoczenia w poszukiwaniu jedzenia. Ich cechy (agresja, szybkość) są zapisane w LTraitProfile.

learning: Sieć neuronowa bota (LNeuralNet) przyjmuje na wejściu wektor zmysłów z FOV i potrzeb, a na wyjściu generuje wektor siły aplikowanej do ciała fizycznego. Populacja ewoluuje za pomocą LNeuroevolution na podstawie długości przeżycia.

Złożoność: ⭐⭐⭐⭐⭐ (bardzo wysoka)

UC-69: Symulator Ruchu Statków i Zarządzania Portem (Maritime Logistics Digital Twin)

Cel: Cyfrowy bliźniak portu morskiego. Monitoruje pozycje statków na oceanie (globe), ich wejście do kanałów portowych (flownet) oraz rozładunek kontenerów za pomocą dźwigów.

Miks Modułów: globe · flownet · network · dataframe · charts

Implementacja API:

globe: Wizualizuje globalny ruch statków na kuli ziemskiej LGlobe za pomocą markerów i łuków tras LGlobe:addArc().

flownet: Gdy statek zbliża się do portu, przechodzi pod kontrolę sieci kolejkowania portowego. Kanały i doki to krawędzie i węzły flownet kontrolujące przepływ kontenerów (LGraphItem).

network: Pobiera rzeczywiste dane o pozycjach AIS statków przez integrację z publicznymi API.

Złożoność: ⭐⭐⭐⭐⭐ (bardzo wysoka)

UC-70: Cyberpunk Network Hacking Grid (Tactical Graph Board)

Cel: Turowa gra hackerska, w której gracz infekuje węzły sieci korporacyjnej, unika wykrycia przez programy antywirusowe (ICE) i wykrada dane. Sieć jest generowana proceduralnie jako graf.

Miks Modułów: graph · patterns (Mediator) · render (Shader) · audio (Synth) · ui

Implementacja API:

graph: Sieć komputerowa to lurek.patterns.newGraph(undirected). Węzły to serwery, krawędzie to połączenia sieciowe. Gracz przemieszcza się, infekując sąsiadów (g:neighbors()).

patterns: LMediator zarządza przesyłaniem komunikatów między zainfekowanymi węzłami a systemem obronnym (ICE).

render: Nałożenie shadera CRT i cyber-siatki za pomocą render.newShader() oraz PostFxStack.

audio: Generuje retro-beaty i dźwięki systemowe syntezatorem proceduralnym lurek.dsp.newSynthWave().

Złożoność: ⭐⭐⭐ (średnia)


Canvas 1: Pozycjonowanie i Architektura Lurek2D

1. Pozycjonowanie Strategiczne: Lurek2D vs. Inne Runtimy 2D

Lurek2D redefiniuje pojęcie silnika gier 2D, przesuwając go z kategorii "narzędzie do rysowania duszków" (jak klasyczne Love2D) do kategorii "wysokowydajny runtime dla systemów agentowych i symulacji". Poniższa tabela przedstawia pozycjonowanie Lurek2D na tle konkurencji w kluczowych wymiarach technologicznych:

Wymiar

Lurek2D

Love2D

Godot 4 (2D)

Bevy

Pygame

Model programowania

API-first / Code-only

Code-only

Editor-centric

ECS-centric (Rust)

Code-only (Python)

Integracja z AI/LLM

Natywna (lurek.agent.* + Ollama)

Brak (wymaga bibliotek HTTP)

Brak (pluginy)

Brak

Brak

Przetwarzanie danych

Wbudowane (dataframe, compute)

Brak

Brak

Brak

NumPy / Pandas (zewnętrzne)

Orkiestracja zadań

Natywny DAG (pipeline)

Brak

Brak

Brak

Brak

Dystrybucja

Pojedynczy binarek $\le 10$ MB

Pojedynczy binarek ~10 MB

Duży szablon (60+ MB)

Kompilowany binarek

Zależność od Pythona

Uruchamianie bez okna

Pełny tryb --headless

Emulator/Sztuczki

Ograniczony

Niewygodny

Brak

Kluczowa przewaga rynkowa (The Defensible Moat)

Tradycyjne silniki cierpią na tzw. "AI-slop" – kiedy asystent LLM (np. Copilot) próbuje wygenerować grę w Godocie lub Unity, często halucynuje właściwości edytora, powiązania scen, czy niekompatybilne wersje API.

Lurek2D eliminuje ten problem u źródła poprzez "The Single-Namespace Mandate" i 100% pokrycie dokumentacją LuaCATS. AI nie musi zgadywać struktury sceny – całe zachowanie gry jest bezpośrednim, deterministycznym wywołaniem funkcji z przestrzeni lurek.*.

Lurek2D został zaprojektowany z myślą o elastyczności sprzętowej. Architektura ta doskonale skaluje się od potężnych stacji roboczych (x86_64) po energooszczędne systemy wbudowane (ARM64 Edge).

+-------------------------------------------------------------------------+
|                              Lurek2D Core                               |
+------------------------------------+------------------------------------+
|        Desktop (x86_64)            |          Edge (ARM64)              |
|  - Pełne wsparcie dla LuaJIT       |  - Flaga kompilacji: `lua54`       |
|  - Akceleracja GPU: wgpu (Vulkan/  |  - Optymalizacja: -C target-cpu    |
|    DX12/Metal)                     |  - Fallback programowy wgpu        |
|  - Zoptymalizowana alokacja pamięci|  - Bezpośrednia integracja z       |
|  - Ciężkie obliczenia wielowątkowe|    lokalnymi modelami (Jetson CUDA) |
+------------------------------------+------------------------------------+


Desktop (Windows, Linux, macOS)

Optymalizacja wykonania: Pełne wykorzystanie kompilatora JIT (LuaJIT) zapewnia wydajność bliską natywnemu C. Przetwarzanie dużych struktur danych w dataframe i compute odbywa się z prędkością procesora (często zrównoleglone za pomocą biblioteki rayon w Rust).

Grafika i Zasoby: API wgpu mapuje się bezpośrednio na natywne niskopoziomowe API (DirectX 12, Vulkan, Metal), minimalizując narzut narzucony przez sterowniki graficzne.

Edge ARM (aarch64 — Raspberry Pi 5, NVIDIA Jetson, Apple Silicon)

Problem JIT na ARM: Na niektórych platformach ARM JIT jest niedostępny lub zablokowany ze względów bezpieczeństwa. Lurek2D rozwiązuje to poprzez kompilację z flagą --no-default-features --features lua54. Klasyczny interpreter Lua 5.4 gwarantuje 100% stabilności i przenośności.

Kompensacja wydajności interpreterem: Aby zrekompensować brak JIT, krytyczne operacje matematyczne i przetwarzanie danych są delegowane do natywnego rdzenia w Rust:

Wszelkie operacje na macierzach i transformaty Fouriera w lurek.compute.* wykorzystują zrównoleglone pętle skompilowane z flagą -C target-cpu=native.

Wyszukiwanie ścieżek lurek.pathfind.* korzysta z wielowątkowego planera w Rust, odciążając jednowątkowy interpreter Lua.

Brak natywnego GPU na Edge: Jeśli urządzenie Edge (np. niektóre dystrybucje Linuxa na Raspberry Pi) nie posiada sprawnych sterowników Vulkan, wgpu automatycznie przełącza się na rendering programowy (CPU rasterization) lub stabilny OpenGL, zapewniając poprawne wyświetlanie dashboardu technicznego.

3. Synergia Modułów "Non-Game" w Środowisku Runtime

Choć Lurek2D technicznie bazuje na architekturze silnika gry (pętla klatek, obsługa zdarzeń wejściowych, renderowanie warstwowe), implementacja modułów takich jak dataframe, compute, learning, agent, pipeline i automation czyni z niego potężne środowisko aplikacyjne.

       [ Input / Sensors ]            [ Local LLM / Ollama ]
               |                                |
               v                                v
       +---------------+                +---------------+
       |   netstate    |                |  lurek.agent  |
       +-------+-------+                +-------+-------+
               |                                |
               v                                v
       +---------------+  SQL Query     +---------------+
       |   LDatabase   | -------------> |  LAISystem    |
       +-------+-------+                +-------+-------+
               |                                |
               | transform                      | actions
               v                                v
       +---------------+                +---------------+
       |   LVecFrame   |                |   LPipeline   |
       +-------+-------+                +-------+-------+
               |                                |
               +--------------->+<--------------+
                                |
                                v
                       [ render / dsp / ui ]


A. DataFrame & Compute jako Silnik Analityczny

Moduł lurek.dataframe.* dostarcza strukturę LDataFrame oraz bazę danych LDatabase bezpośrednio do przestrzeni skryptowej Lua.

Wydajność pamięciowa: Zamiast alokować tysiące małych tabel Lua dla rekordów (co zabiłoby garbage collector), dane przechowywane są w ciągłych, typowanych blokach pamięci Rust (ColumnStore w Rust).

SQL-on-the-Edge: Za pomocą LDatabase:queryAsync(sql) lub LDataFrame:query(sql) programista może filtrować, łączyć (JOIN) i agregować dane w czasie rzeczywistym, używając natywnego parsera SQL w Rust.

Wektorowa akceleracja: Moduł lurek.dataframe.toVec(df) konwertuje ramkę danych do LVecFrame, umożliwiając masowe operacje matematyczne (np. vf:colAdd("price", 1.2), vf:colSqrt("velocity")) wykonywane wektorowo w pamięci podręcznej procesora.

B. Agent i AI jako Autonomiczny Kontroler Decyzyjny

Integracja lurek.agent.* z lokalnym serwerem Ollama umożliwia budowanie systemów, które same analizują stan symulacji i podejmują decyzje:

Orkiestracja LAISystem: Pozwala zdefiniować sieć agentów (np. analyst, planner, operator), którzy wymieniają się informacjami.

Generowanie kodu przez LLM: Za pomocą LAgent:evalCode(code) silnik potrafi odebrać wygenerowany przez LLM skrypt Lua i bezpiecznie uruchomić go w locie w celu adaptacji logiki gry/symulacji do nowych warunków.

Pamięć semantyczna i epizodyczna: Klasy LAgentMemory, LEpisodicMemory i LSemanticMemory pozwalają agentom zapamiętywać wydarzenia z określonych klatek symulacji (tick), budując trwały kontekst decyzyjny.

C. Pipeline jako Menedżer Cyklu Życia i DAG

W klasycznych silnikach gier asynchroniczność (np. ładowanie plików, zapytania sieciowe, długie obliczenia) jest trudna do okiełznania i prowadzi do tzw. "callback hell". Lurek2D wprowadza menedżera przepływu zadań opisanego jako acykliczny graf skierowany (DAG) poprzez lurek.pipeline.*:

Deklaratywne kroki: Tworzymy instancję LPipeline, dodajemy kroki za pomocą addStep() lub addBranch(), definiując jawne zależności (np. krok process_data zależy od load_csv).

Wbudowana odporność: Każdy krok posiada niezależne mechanizmy setTimeout, setRetryCount oraz setRetryDelay. Jeśli zdalne API nie odpowie, pipeline ponowi próbę automatycznie bez blokowania głównego wątku renderowania.

Wykonanie asynchroniczne: Wywołanie LPipeline:runAsync() uruchamia orkiestrator w formie korutyny Lua, która co klatkę (update(dt)) sprawdza statusy zadań i uruchamia kolejne krotki, gdy ich zależności zostaną spełnione.

D. Automation i Input Recording jako Silnik Determinizmu

Moduł lurek.automation.* oraz lurek.input (z rejestratorem LInputRecording) stanowią kompletne środowisko do testowania i symulacji:

Weryfikacja wizualna: Krok visualassert w skryptach automatyzacji pozwala na bezobsługowe porównywanie klatek renderowanych przez GPU z wzorcami PNG (Visual Regression Testing).

Dokładność co do mikrosekundy: Rejestracja wejścia przez lurek.input.startRecording() zapisuje zdarzenia klawiatury i myszy z dokładnością do klatki systemowej, co pozwala na idealne odtwarzanie scenariuszy testowych w potokach CI/CD.

eof


# Canvas 2: Ocena i Ekspansja Use Case'ów

## 1. Walidacja i Audyt Istniejących Scenariuszy Użycia

Dostarczone w pliku `use_cases.md` scenariusze użycia (UC-01 do UC-15 oraz UC-16 do UC-49) zostały przeanalizowane pod kątem spójności z rzeczywistym API Lurek2D (plik `api`). Poniżej znajduje się weryfikacja techniczna najważniejszych z nich:

### UC-24: Personal Finance & Budget Dashboard (Weryfikacja: SUKCES)
*   **Sens techniczny**: Bardzo wysoki. Aplikacje biznesowe typu dashboardy finansowe zazwyczaj wymagają ciężkich frameworków (Electron, Qt). Lurek2D realizuje to w pliku o wadze poniżej 10 MB.
*   **Spójność z API**:
    *   Wczytywanie danych realizowane asynchronicznie przez `lurek.dataframe.fromCSVFileAsync(path)` – zapobiega zamarzaniu interfejsu przy plikach CSV powyżej 100k wierszy.
    *   Agregacja danych poprzez `LDataFrame:groupAgg(group_col, agg_col, fn_name)` oraz `LDataFrame:pivotTable`.
    *   Wizualizacja wykresów bezpośrednio przez moduł `lurek.charts.*` (np. `lurek.charts.newBar()` i `lurek.charts.newLine()`), których wyjścia renderowane są jako tekstury GPU.

### UC-35: DAG Workflow Orchestrator (Weryfikacja: SUKCES)
*   **Sens techniczny**: Znakomity use case dla trybu `--headless`. Umożliwia pisanie skomplikowanych skryptów automatyzacji (ETL, backupy, budowanie zasobów) w prostym języku Lua.
*   **Spójność z API**:
    *   `lurek.pipeline.newPipeline(name)` tworzy orkiestrator.
    *   Kroki definiowane są za pomocą `lurek.pipeline.newStep(name, callback)`.
    *   Zależności są budowane płynnie metodą `LPipelineStep:dependsOn(dep)`.
    *   Obsługa asynchroniczności (np. długie pobieranie plików) jest w pełni wspierana przez `LPipelineStep:setAsync(true)` oraz wywołania korutynowe w pętli `LPipeline:update(dt)`.

### UC-39: Headless Game Regression Framework (Weryfikacja: SUKCES)
*   **Sens techniczny**: Kluczowy dla profesjonalnego QA.
*   **Spójność z API**:
    *   `lurek.input.startRecording()` oraz `lurek.input.stopRecording()` generują instancję `LInputRecording`.
    *   Zapis do formatu JSON za pomocą `LInputRecording:toJson()` i ładowanie przez `lurek.input.loadRecording(json)`.
    *   Wykonywanie testów wizualnych w trybie headless za pomocą `lurek.render.captureScreenshot(callback)`.

---

## 2. Nowe, Zaawansowane Use Case'y (Ekspansja Katalogu)

W odpowiedzi na wymaganie *"dopisz drugie razy tyle"* oraz skupiając się na zaawansowanych miksach modułowych dla Desktop i Edge ARM, poniżej znajduje się katalog nowo zaprojektowanych scenariuszy użycia (UC-50 do UC-60):

### UC-50: Autonomiczny Red-Teaming & Symulacja Cyberataków w Sieciach IT (Edge ARM)
*   **Cel**: Modelowanie topologii sieci i automatyczne symulowanie propagacji zagrożeń (ransomware, lateral movement) na fizycznym urządzeniu Edge (np. Raspberry Pi) wpiętym do sieci laboratoryjnej.
*   **Miks Modułów**: `flownet` · `agent` · `dataframe` · `pipeline` · `ai` (FSM/BT)
*   **Rola modułów**:
    *   `flownet`: Reprezentuje topologię sieci. Węzły (`LGraphNode`) to hosty/serwery, a krawędzie (`LGraphEdge`) to połączenia sieciowe. Pakiety lub wektory ataku są reprezentowane przez przedmioty (`LGraphItem`) płynące w sieci.
    *   `dataframe`: Przechowuje logi skanowania i podatności maszyn. SQL-owe zapytania filtrują najbardziej podatne cele.
    *   `agent`: Analizuje nietypowe zachowania i generuje raporty podatności w naturalnym języku dla administratora.
    *   `pipeline`: Zarządza fazami ataku (Reconnaissance $\rightarrow$ Intrusion $\rightarrow$ Lateral Movement $\rightarrow$ Exfiltration) jako krokami z obsługą błędów i timeoutów.
*   **Złożoność**: ⭐⭐⭐⭐⭐ (bardzo wysoka)

---

### UC-51: Inteligentny Kontroler Mikrosieci i Farm Fotowoltaicznych (ARM64 Edge)
*   **Cel**: Autonomiczne zarządzanie przepływem energii (panele, magazyny, sieć zewnętrzna) na bazie prognoz pogody w czasie rzeczywistym i lokalnego wnioskowania.
*   **Miks Modułów**: `learning` (ONNX/QLearner) · `dataframe` · `pipeline` · `network` · `ui` (lokalny ekran)
*   **Rola modułów**:
    *   `network`: Pobiera prognozę nasłonecznienia z zewnętrznego API i odpytuje inwertery po protokole HTTP/JSON.
    *   `dataframe`: Gromadzi cogodzinne dane o produkcji i zużyciu energii, oblicza średnie kroczące (`rollingMean`) i odchylenia standardowe.
    *   `learning`: Model `LOnnxModel` wczytuje sieć neuronową przewidującą optymalny profil ładowania baterii na kolejne 6 godzin. Wbudowany `LQLearner` doucza się lokalnie na bazie sukcesów/porażek bilansowych.
    *   `pipeline`: Koordynuje cykl: pobierz dane $\rightarrow$ prognozuj $\rightarrow$ przełącz przekaźniki, dbając o to, by błąd jednego odczytu nie zawiesił sterownika.
*   **Złożoność**: ⭐⭐⭐⭐ (wysoka)

---

### UC-52: AI-Driven Generative RPG Dungeon Master (Desktop / Edge)
*   **Cel**: Gra RPG, w której świat, lochy, zadania oraz interakcje z przeciwnikami są w 100% generowane w locie przez lokalny model LLM współpracujący z algorytmami proceduralnymi.
*   **Miks Modułów**: `agent` · `procgen` (WFC z LLM) · `dialog` · `narrative` (library) · `render` · `tilemap`
*   **Rola modułów**:
    *   `procgen`: Funkcja `lurek.procgen.wfcFromPrompt(prompt, config)` pyta lokalną Ollamę o zasady sąsiedztwa płytek (np. "lochy w stylu gotyckim"), po czym natywny algorytm Wave Function Collapse (`wfcGenerate`) natychmiast buduje spójną mapę kafelkową.
    *   `agent`: Generuje opisy pokoi, unikalne statystyki potworów i zapisuje je do `LAgentMemory` (pamięć epizodyczna).
    *   `dialog` + `narrative`: Generuje drzewa dialogowe z NPC-ami na bazie ich celów życiowych i humoru.
    *   `tilemap` + `render`: Wyświetla wygenerowany świat z dynamicznym oświetleniem.
*   **Złożoność**: ⭐⭐⭐⭐⭐ (bardzo wysoka)

---

### UC-53: Automatyczny Optymalizator Linii Produkcyjnej (RL Digital Twin)
*   **Cel**: Symulator taśmy produkcyjnej w fabryce, który w tle automatycznie trenuje agenta Reinforcement Learning w celu maksymalizacji przepustowości i eliminacji wąskich gardeł.
*   **Miks Modułów**: `learning` (QLearner/DefineEnv) · `flownet` · `dataframe` · `charts` · `pipeline`
*   **Rola modułów**:
    *   `flownet`: Symuluje fizyczną linię produkcyjną. Maszyny to węzły z czasem procesowania (`setProcessTime`), a taśmociągi to krawędzie (`LGraphEdge`) z przepustowością.
    *   `learning.defineEnv`: Owija sieć `flownet` w środowisko kompatybilne z Gym, gdzie akcją jest zmiana priorytetu maszyn, a stanem – zapełnienie kolejek.
    *   `learning.newQLearner`: Agent Q-Learning uczy się sterowania ruchem produktów, dążąc do maksymalizacji nagrody (przepustowości).
    *   `dataframe` + `charts`: Agreguje statystyki i rysuje wykres zbieżności nagrody w czasie rzeczywistym na dashboardzie operatora.
*   **Złożoność**: ⭐⭐⭐⭐ (wysoka)

---

### UC-54: Mobilny Terminal Taktyczny dla Służb Ratunkowych (ARM64 Edge Offline)
*   **Cel**: Tablet dla straży pożarnej działający w strefie klęski żywiołowej bez zasięgu sieci komórkowej, służący do wyznaczania stref zagrożenia pożarowego i dróg ewakuacji.
*   **Miks Modułów**: `globe` / `province` · `pathfind` (HPA*) · `network` (lokalne ad-hoc) · `ui` · `save` (offline)
*   **Rola modułów**:
    *   `province` / `globe`: Przechowuje mapę topograficzną terenu jako siatkę wielokątów (prowincji).
    *   `pathfind`: Algorytm `findHpaPath` na siatce nawigacyjnej wyznacza najbezpieczniejszą drogę dla wozów strażackich przez las, omijając aktywne ogniska pożaru.
    *   `network`: Wykorzystuje lokalne radio ad-hoc do synchronizacji pozycji innych zespołów za pomocą `syncEntity` i biletów przekaźnikowych (`newRelayTicket`).
    *   `save`: Zrzuca pełną historię zdarzeń taktycznych do skompresowanego pliku save, gotowego do odczytu po powrocie do bazy.
*   **Złożoność**: ⭐⭐⭐⭐ (wysoka)

---

### UC-55: Autonomiczny Asystent Programowania Gier (Self-Debugging Lua Assistant)
*   **Cel**: IDE i runtime, w którym silnik gry sam wykrywa błędy wykonania Lua, przesyła traceback do lokalnego LLM, generuje poprawkę i aplikuje ją w locie (hot-patching) bez restartu gry.
*   **Miks Modułów**: `agent` (`evalCode`) · `devtools` · `repl` · `debugbridge` · `validator`
*   **Rola modułów**:
    *   `devtools`: Wyłapuje błąd wykonania i pobiera pełny stos wywołań przez `lurek.devtools.getCallStack()`.
    *   `agent`: Odbiera kod błędu, analizuje podejrzany plik za pomocą `lurek.grep` i generuje poprawny fragment kodu.
    *   `evalCode`: Funkcja `LAgent:evalCode(code)` uruchamia poprawiony fragment bezpośrednio w działającej maszynie wirtualnej, natychmiast naprawiając błąd.
    *   `debugbridge`: Wysyła powiadomienie do VS Code programisty o automatycznie zaaplikowanej łatce.
*   **Złożoność**: ⭐⭐⭐⭐⭐ (bardzo wysoka)

---

### UC-56: Inteligentny Trenażer i Analizator EKG / Sygnałów Medycznych (Desktop / Edge)
*   **Cel**: Urządzenie monitorujące sygnały biomedyczne w czasie rzeczywistym, filtrujące szum, wykrywające anomalie pracy serca i wizualizujące wykresy medyczne.
*   **Miks Modułów**: `compute` (FFT/Filters) · `dataframe` · `charts` · `ui` · `audio` (alarmy dźwiękowe)
*   **Rola modułów**:
    *   `compute.fft`: Wykonuje szybką transformatę Fouriera na buforze wejściowym sygnału EKG w celu eliminacji zakłóceń sieciowych (filtr cyfrowy Notch 50Hz zaimplementowany w Lua).
    *   `dataframe`: Analizuje odległości między załamkami R (interwał R-R), obliczając średnią kroczącą i odchylenie standardowe zmienności rytmu serca (HRV).
    *   `charts` + `ui`: Rysuje płynny, przewijany elektrokardiogram oraz wykres widma częstotliwościowego.
*   **Złożoność**: ⭐⭐⭐ (średnia)

---

### UC-57: Symulator i Planer Taktyczny dla Autonomicznych Rojów Dronów (Edge ARM)
*   **Cel**: Planowanie misji poszukiwawczo-ratowniczych dla roju dronów. Każdy dron posiada lokalny miks modułów do unikania kolizji i mapowania terenu.
*   **Miks Modułów**: `ai` (ORCA Solver) · `pathfind` (Flow Field) · `visibility` (Fov) · `network` · `thread`
*   **Rola modułów**:
    *   `ai.newORCASolver`: Oblicza bezkolizyjne wektory prędkości dla każdego drona w roju w czasie rzeczywistym.
    *   `pathfind.newFlowField`: Generuje globalne pole przepływu kierujące rój do strefy docelowej.
    *   `visibility.newFov`: Każdy dron skanuje otoczenie za pomocą algorytmu rzucania cieni (shadowcasting), budując wspólną mapę widoczności.
    *   `thread`: Dystrybuuje obliczenia nawigacyjne na osobne wątki CPU na pokładzie komputera drona (ARM64).
*   **Złożoność**: ⭐⭐⭐⭐⭐ (bardzo wysoka)

---

### UC-58: Interaktywna Instalacja Artystyczna Reagująca na Głos i Ruch
*   **Cel**: Projekcja multimedialna w galerii sztuki, która generuje płynne obrazy cząsteczkowe i oświetlenie na bazie analizy pasm częstotliwości mikrofonu i kamer ruchu.
*   **Miks Modułów**: `dsp` (SpectrumAnalyzer) · `compute` · `particle` · `light` · `camera` (sway/breathing)
*   **Rola modułów**:
    *   `dsp.newSpectrumAnalyzer`: Analizuje sygnał audio z wejścia i dzieli go na 32 pasma częstotliwości.
    *   `compute`: Mapuje energię basu na siłę grawitacji emiterów cząsteczek, a wysokie tony na ich prędkość rotacji.
    *   `particle`: Generuje widowiskowe efekty wiatru, ognia i dymu na ekranie projekcyjnym.
    *   `light`: Dynamicznie zmienia barwę i pozycję świateł `Light2D` z efektem migotania (`addFlicker`) zsynchronizowanym z rytmem muzyki.
*   **Złożoność**: ⭐⭐⭐ (średnia)

---

### UC-59: Narzędzie do Generowania i Ewaluacji Proceduralnych Poziomów (Headless CI/CD)
*   **Cel**: Narzędzie uruchamiane w chmurze CI/CD, które generuje 1000 wariantów poziomu gry, automatycznie przechodzi je za pomocą botów AI i raportuje współczynnik ukończenia (solvability).
*   **Miks Modułów**: `procgen` · `pathfind` · `ai` (BehaviorTree) · `dataframe` · `serial`
*   **Rola modułów**:
    *   `procgen.wfcGenerate`: Generuje unikalny układ korytarzy i komnat na bazie zdefiniowanych kafelków.
    *   `pathfind`: Buduje siatkę nawigacyjną i sprawdza podstawową osiągalność punktu końcowego.
    *   `ai.newBehaviorTree`: Uruchamia bota testowego opartego na drzewie zachowań, który próbuje przejść poziom, zbierając klucze i pokonując przeszkody.
    *   `dataframe`: Zapisuje wyniki każdego testu (czas przejścia, zużycie HP, zablokowanie bota). SQL-owe zapytanie generuje na koniec raport: "Zidentyfikowano 12 nieprzejezdnych konfiguracji map".
*   **Złożoność**: ⭐⭐⭐⭐ (wysoka)

---

### UC-60: Autonomiczny Robot Magazynowy - Cyfrowy Bliźniak (Digital Twin)
*   **Cel**: Trójwarstwowy system monitoringu floty wózków widłowych w magazynie. Lurek2D wizualizuje pozycje maszyn, symuluje ich optymalne ścieżki i planuje zlecenia transportowe.
*   **Miks Modułów**: `flownet` · `pathfind` (JpsGrid) · `ui` · `network` · `dataframe`
*   **Rola modułów**:
    *   `network`: Odbiera pozycje rzeczywistych wózków z sensorów Ultra-Wideband (UWB) po WebSockecie.
    *   `pathfind.newJpsGrid`: Oblicza najkrótsze ścieżki przejazdu omijające regały za pomocą szybkiego algorytmu Jump Point Search.
    *   `flownet`: Kolejkuje zlecenia pobrania palet (`LCommandQueue`) i przypisuje je do wolnych wózków na bazie ich aktualnego obciążenia i odległości.
    *   `ui` + `dataframe`: Wyświetla panel wydajności floty (KPI) i czasy oczekiwania na załadunek.
*   **Złożoność**: ⭐⭐⭐⭐⭐ (bardzo wysoka)


eof


## Podsumowanie i dalsze kroki

Wszystkie powyższe use case'y są w pełni poparte strukturami danych widocznymi w dostarczonym przez Ciebie pliku `api`. Na szczególną uwagę zasługuje unikalne połączenie generowania proceduralnego ze sztuczną inteligencją (jak w `lurek.procgen.wfcFromPrompt`), co jest rzadkością w tradycyjnych silnikach gier i otwiera drogę do tworzenia niezwykle zaawansowanych systemów symulacyjnych.

Jaki krok w rozwoju projektu Lurek2D chciałbyś teraz przeanalizować? Możemy skupić się na architekturze konkretnego use case'u lub napisać przykładowy szkielet kodu w Lua dla wybranego scenariusza!
