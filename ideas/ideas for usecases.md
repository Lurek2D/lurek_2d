Lurek2D — Kompletny Katalog Przypadków Użycia (UC-01 do UC-70)

Niniejsze zestawienie stanowi kompletny rejestr wszystkich 70 przypadków użycia (use cases) dla silnika Lurek2D, podzielonych na kategorie tematyczne. Każdy scenariusz został poddany analizie pod kątem technicznym, wymaganego zestawu modułów, docelowego odbiorcy oraz problemu, który bezpośrednio rozwiązuje unikalna architektura Lurek2D.

1. Kategorie Gier (Klasyczne, Arcade, RPG i AI-First)

Ta grupa obejmuje produkcje rozrywkowe, od prostych klonów retro po dynamicznie generowane lochy napędzane przez LLM i systemy dialogowe.

ID

Nazwa Przypadku Użycia

Kluczowe Moduły Lurek2D

Trudność

Docelowy Odbiorca / Klient

Rozwiązywany Problem

Profil Budowania & Status

UC-01

Indie 2D Desktop Game

render, audio, physics, input, window, timer, scene, sprite, animation, tween, tilemap, ui, save, camera

⭐⭐

Solo deweloperzy, małe studia indie

Trudność wdrażania na różne systemy, wysokie opłaty licencyjne w Unity/GameMaker.

dist / release



 (Aktualny)

UC-02

Game Jam / Rapid Prototype

render, input, timer, audio, ui

⭐

Uczestnicy hackathonów i jamów gier

Powolna faza początkowa projektu (boilerplate code).

dev / release



 (Aktualny)

UC-16

Retro Arcade Clone

render, input, timer, physics, audio, particle, tween, scene, effect

⭐

Uczniowie, hobbyści, retro deweloperzy

Trudna implementacja efektów CRT oraz detekcji kolizji od zera.

dev / release



 (Aktualny)

UC-17

Visual Novel / Interactive Fiction

render, ui, audio, tween, save, input, scene, i18n, biblioteki dialog i narrative

⭐⭐

Pisarze, projektanci narracji

Brak wbudowanego systemu grafu konwersacji w prostych silnikach.

release / dist



 (Aktualny)

UC-18

Sports & Physics Arcade

physics (Rapier2D), render, input, audio, camera, tween, particle

⭐⭐⭐

Deweloperzy gier zręcznościowych

Matematyka fizyki kołowej i wieloboków oraz siły tarcia w 2D.

release / dist



 (Aktualny)

UC-19

Music Sequencer & Creative Tool

audio (synthesis), dsp, midi, render, input, timer, serial

⭐⭐⭐⭐

Muzycy, programiści audio

Brak natywnej obróbki sygnałów i parsowania plików MIDI w silnikach 2D.

release



 (Aktualny)

UC-20

Terminal / Hacking Game

terminal (grid), render, input, tween, effect (CRT), timer

⭐⭐

Twórcy gier tekstowych/cyberpunk

Brak wydajnej siatki tekstowej o stałej szerokości znaku z post-processingu.

release / dist



 (Aktualny)

UC-52

AI-Driven Generative RPG Dungeon Master

agent, procgen (WFC z LLM), dialog, narrative, render, tilemap

⭐⭐⭐⭐⭐

Twórcy nowoczesnych gier RPG

Monotonny, statycznie zaprojektowany świat gry i powtarzalne dialogi z NPC.

release



 (Edge / Desktop)

UC-70

Cyberpunk Network Hacking Grid

graph, patterns (Mediator), render (shaders), audio (synth), ui

⭐⭐⭐

Twórcy gier strategicznych / logicznych

Trudności z reprezentacją grafu sieci i dynamicznym mapowaniem połączeń.

release / dist



 (Aktualny)

2. Edukacja i Badania Naukowe

Lurek2D jako otwarty ekosystem napisany w Rust z interfejsem Lua doskonale nadaje się do celów akademickich i eksperymentalnych.

ID

Nazwa Przypadku Użycia

Kluczowe Moduły Lurek2D

Trudność

Docelowy Odbiorca / Klient

Rozwiązywany Problem

Profil Budowania & Status

UC-03

Education — Programming & Architecture

Wszystkie moduły Lua API + kod źródłowy silnika w Rust

⭐⭐

Uniwersytety, szkoły programowania, bootcampy

Trudność w przejściu z prostego języka skryptowego (Lua) do systemowego (Rust).

dev



 (Aktualny)

UC-15

Teaching Instrument for AI/ML Research

agent, thread, dataframe, learning, compute, render, charts

⭐⭐⭐⭐

Naukowcy badający AI, doktoranci

Brak lekkiego środowiska symulacyjnego opartego na jednym pliku wykonywalnym.

release --headless



 (Bliska przyszłość)

UC-21

Hackathon Teaching Platform

Wszystkie wbudowane przykłady, VS Code Intellisense

⭐

Organizatorzy hackathonów, mentorzy

Długi czas instalacji środowiska i SDK przez uczestników przed samym wydarzeniem.

dev



 (Aktualny)

UC-40

Scientific Computing Workbench

compute (LArray), charts, render, ui, dataframe, terminal (REPL)

⭐⭐⭐⭐

Fizycy, statystycy, inżynierowie

Konieczność instalacji ciężkich środowisk (Python + Anaconda, MATLAB) na prostych stacjach.

release / headless



 (Aktualny)

UC-56

Inteligentny Trenażer i Analizator EKG

compute (FFT/Filters), dataframe, charts, ui, audio

⭐⭐⭐

Centra szkolenia medycznego, inżynierowie medyczni

Brak przystępnych cenowo, interaktywnych symulatorów sygnałów biologicznych.

release



 (Aktualny)

UC-68

Autonomiczny Ekosystem Sztucznego Życia

learning (Neuroevolution), ai (Needs/Fov), physics, dataframe, render

⭐⭐⭐⭐⭐

Badacze biologii syntetycznej, AI

Wysoki koszt obliczeniowy symulacji ewolucyjnej w środowiskach jednowątkowych.

release



 (Aktualny)

3. Symulacje i Strategie (Digital Twins / Przemysł)

Wyjątkowa kategoria, w której Lurek2D wyróżnia się na tle tradycyjnych silników 2D dzięki natywnej integracji struktur grafowych, sieci przepływów i map regionalnych.

ID

Nazwa Przypadku Użycia

Kluczowe Moduły Lurek2D

Trudność

Docelowy Odbiorca / Klient

Rozwiązywany Problem

Profil Budowania & Status

UC-05

Simulation Sandbox & Strategy Research

province, globe, dataframe, graph, pathfind, flownet, compute

⭐⭐⭐

Analitycy geopolityczni, badacze systemów

Trudność w wizualizacji skomplikowanych zależności regionalnych na mapach wielokątów.

release / headless



 (Aktualny)

UC-06

Digital Twin Visualiser

globe, province, flownet, pathfind, dataframe, network (WebSocket), render

⭐⭐⭐⭐

Inżynierowie utrzymania ruchu, fabryki

Skomplikowany proces wdrażania (Docker, node.js) prostych wizualizacji procesów przemysłowych.

release



 (Bliska przyszłość)

UC-12

Wargame / Military Decision-Support

province, globe, pathfind, dataframe, graph, agent (Ollama), flownet, automation

⭐⭐⭐⭐

Jednostki planowania taktycznego, think tanki

Brak systemów zdolnych do pracy w środowisku w pełni odizolowanym (Air-gapped) z lokalnym LLM.

dist (Headless)



 (Przyszłość)

UC-22

Supply Chain & Logistics Optimiser

flownet, graph, pathfind, dataframe, agent, render, ui, charts

⭐⭐⭐⭐⭐

Menedżerowie logistyki, planiści

Wąskie gardła obliczeniowe przy symulacji tysięcy połączonych punktów dystrybucji.

release



 (Bliska przyszłość)

UC-50

Symulator Cyberataków i Lateral Movement

flownet, dataframe, agent (evalCode), pipeline, ai

⭐⭐⭐⭐⭐

Administratorzy bezpieczeństwa IT, Red-Teams

Brak bezpiecznych platform symulacyjnych do analizowania scenariuszy penetracji sieci w locie.

release



 (Edge ARM / PC)

UC-53

Optymalizator Linii Produkcyjnej (RL)

learning (QLearner), flownet, dataframe, charts, pipeline

⭐⭐⭐⭐

Inżynierowie automatyki, zakłady produkcyjne

Ręczne konfigurowanie harmonogramów taśmociągów rzadko przynosi optimum wydajnościowe.

release



 (Aktualny)

UC-54

Mobilny Terminal Taktyczny dla Straży

globe / province, pathfind (HPA*), network, ui, save

⭐⭐⭐⭐

Służby ratunkowe (straż, GOPR)

Całkowity brak zasięgu GSM i internetu w strefie katastrofy uniemożliwia tradycyjny routing GIS.

release (ARM64 Edge)



 (Aktualny)

UC-57

Planer Taktyczny dla Rojów Dronów

ai (ORCA Solver), pathfind (Flow Field), visibility, network, thread

⭐⭐⭐⭐⭐

Projektanci robotyki, ekipy poszukiwawcze

Trudność z bezkolizyjnym poruszaniem się rojów urządzeń bez centralnego serwera.

release (ARM64 Edge)



 (Aktualny)

UC-60

Cyfrowy Bliźniak Floty Magazynowej (AGV)

flownet, pathfind (JpsGrid), ui, network, dataframe

⭐⭐⭐⭐⭐

Logistyka wewnętrzna, magazyny Amazon-style

Kolizje i opóźnienia wózków widłowych spowodowane brakiem dynamicznego przeliczania ścieżek.

release



 (Aktualny)

UC-61

Zarządzanie Ruchem Miejskim (Algorytmy Gen.)

flownet, learning (Genetic), dataframe, timer, ui

⭐⭐⭐⭐⭐

Planowanie miejskie, Smart Cities

Kongestia miejska przez statycznie zaprogramowane cykle sygnalizacji świetlnej.

release



 (Aktualny)

UC-62

Decentralna Giełda Energii P2P

pathfind (GoalMap), economy (ResourceManager), dataframe, agent

⭐⭐⭐⭐⭐

Sektor energetyczny, mikrosieci

Brak rozproszonych mechanizmów wymiany energii bez centralnego operatora.

release



 (Aktualny)

UC-65

Diagnosta Sieci Kolejowej (Digital Twin)

flownet, pathfind (NavGrid), dataframe, pipeline, ui

⭐⭐⭐⭐⭐

Operatorzy infrastruktury kolejowej

Trudność w przewidywaniu propagacji opóźnień na liniach jednotorowych.

release



 (Aktualny)

UC-67

Panel Mapowy dla Zarządzania Kryzysowego

province, pathfind (Dijkstra), dataframe, network (SSE), ui

⭐⭐⭐⭐

Centra powodziowe, sztaby kryzysowe

Brak możliwości zintegrowania danych z sensorów w czasie rzeczywistym z dynamiczną mapą drogową.

release



 (Aktualny)

UC-69

Zarządzanie Portem i Ruchem Statków

globe, flownet, network, dataframe, charts

⭐⭐⭐⭐⭐

Operatorzy portów handlowych, logistycy

Chaos w dokach z powodu braku płynnego przejścia ze współrzędnych GPS do sieci portowych.

release



 (Aktualny)

4. Sztuczna Inteligencja i Duże Modele Językowe (AI & LLM)

Integracja z lokalnym serwerem LLM za pomocą natywnego modułu lurek.agent to unikalny wyróżnik rynkowy Lurek2D.

ID

Nazwa Przypadku Użycia

Kluczowe Moduły Lurek2D

Trudność

Docelowy Odbiorca / Klient

Rozwiązywany Problem

Profil Budowania & Status

UC-07

Local AI-Driven NPC / Game Logic

agent, ai (FSM/BT), learning, thread (worker VMs), dataframe

⭐⭐⭐

Twórcy nowoczesnych gier RPG i symulacji

Blokowanie pętli gry przy asynchronicznym odpytywaniu modeli językowych o dialogi.

release



 (Aktualny)

UC-32

LLM Inference Server with GUI

agent (Ollama process management), ui, render, terminal

⭐⭐

Deweloperzy AI, entuzjaści lokalnych LLM

Brak lekkich, natywnych GUI dla procesów Ollama bez Electrona.

release



 (Bliska przyszłość)

UC-33

Multi-Agent Game Design Tool

agent (AgentManager), ui, render, dataframe, save, serial

⭐⭐⭐

Projektanci gier, pisarze lore

Brak strukturalnego narzędzia do współpracy wielu wyspecjalizowanych agentów lokalnych.

release



 (Bliska przyszłość)

UC-34

Procedural Content Factory

procgen, agent, thread, dataframe, serial, filesystem

⭐⭐⭐⭐

Studia gier generujące masowe assety

Wysokie koszty API chmurowych (OpenAI) przy generowaniu tysięcy opisów przedmiotów.

release --headless



 (Aktualny)

UC-38

Dialogue-Driven NPC System

dialog, ai, agent (LLM fallback), save, serial, audio

⭐⭐⭐⭐

Twórcy gier narracyjnych

Brak mechanizmów dynamicznego powrotu do LLM, gdy gracz zada pytanie spoza drzewa dialogów.

release / library



 (Aktualny)

UC-41

AI Skill-Injection Chatbot

agent (LAISystem), ui, terminal, save, serial, dataframe

⭐⭐⭐⭐⭐

Twórcy asystentów biznesowych

Brak automatycznego wstrzykiwania wiedzy dziedzinowej do promptu na bazie słów kluczowych.

release



 (Bliska przyszłość)

UC-47

Agent evalCode Sandbox

agent (evalCode), terminal, ui, dataframe, serial, save

⭐⭐⭐⭐

Deweloperzy systemów autonomicznych

Brak bezpiecznych metod uruchamiania kodu generowanego przez LLM w czasie rzeczywistym.

release



 (Bliska przyszłość)

UC-55

Autonomiczny Asystent Programowania (Self-Debugging)

agent (evalCode), devtools, repl, debugbridge, validator

⭐⭐⭐⭐⭐

Programiści gier, systemy autonomiczne

Przestoje gry i awarie aplikacji w środowisku produkcyjnym z powodu błędów runtime Lua.

release



 (Aktualny)

UC-66

AI-Driven Procgen Level Evaluator

procgen (WFC), ai (BehaviorTree), agent, dataframe, serial

⭐⭐⭐⭐⭐

Projektanci poziomów, QA

Trudność z celowym i precyzyjnym doborem poziomu trudności generowanych map logicznych.

release



 (Aktualny)

5. Analiza Danych, DSP i Narzędzia Kreatywne

Moduły matematyczno-obliczeniowe (compute, dataframe, dsp) pozwalają na przetwarzanie dźwięków, obrazów i danych z pełną prędkością kodu skompilowanego w Rust.

ID

Nazwa Przypadku Użycia

Kluczowe Moduły Lurek2D

Trudność

Docelowy Odbiorca / Klient

Rozwiązywany Problem

Profil Budowania & Status

UC-04

Demo Scene / Interactive Visual Art

render, effect, particle, raycaster, procgen, light, compute

⭐⭐⭐

Demoscenowcy, artyści nowomedialni

Powolne renderowanie skomplikowanych efektów cząsteczkowych na CPU w środowiskach skryptowych.

release / dist



 (Aktualny)

UC-08

Headless Batch Compute & Data Pipeline

compute, dataframe, procgen, graph, serial, filesystem, thread

⭐⭐

Data Scientists, inżynierowie danych

Narzut pamięciowy i instalacyjny Pythona w prostych procesach wsadowych.

release --headless



 (Aktualny)

UC-23

Network Graph Visualiser

graph, render, input, camera, ui, dataframe, tween

⭐⭐⭐

Administratorzy sieci, badacze powiązań

Brak płynnego skalowania i zoomu na grafach posiadających tysiące połączonych węzłów.

release



 (Aktualny)

UC-24

Personal Finance & Budget Dashboard

dataframe (SQL in-memory), ui (LGuiTable), charts, serial, save

⭐⭐⭐⭐⭐

Osoby prywatne, biura rachunkowe

Zależność od platform chmurowych i brak prywatności przy analizie finansowej.

release / dist



 (Aktualny)

UC-25

Stock & Market Data Dashboard

network (WebSocket), dataframe (rolling calculations), charts, save

⭐⭐⭐⭐⭐

Inwestorzy giełdowi, traderzy

Zastój interfejsu (GC thrashing) przy ciągłym odświeżaniu wykresów świecowych.

release



 (Bliska przyszłość)

UC-26

Data Visualisation Studio

dataframe (async CSV), charts, render, ui, camera, dialog

⭐⭐⭐

Naukowcy, analitycy biznesowi

Trudność z dystrybucją narzędzi analitycznych do końcowych użytkowników bez instalatora.

release



 (Aktualny)

UC-27

Image Processing Workbench

image (pixel operations), render (shaders), ui, thread (batch)

⭐⭐⭐⭐

Fotografowie, graficy komputerowi

Powolne przetwarzanie seryjne i brak podglądu filtrów GPU w czasie rzeczywistym.

release / headless



 (Bliska przyszłość)

UC-28

Data Integration Hub

network (REST/JSON), dataframe (joins), serial, filesystem, timer

⭐⭐⭐⭐

Systemy ETL, integracje API

Konieczność instalacji ciężkich brokerów integracyjnych dla prostych zadań synchronizacyjnych.

release --headless



 (Bliska przyszłość)

UC-36

Offline DSP Audio Processing Pipeline

dsp (lowpass, normalisation), audio, filesystem, thread

⭐⭐⭐⭐

Sound designerzy, twórcy gier

Brak darmowych, konsolowych narzędzi wsadowych do normalizacji dźwięków bez interfejsu GUI.

release --headless



 (Aktualny)

UC-37

Audio Analysis & Fingerprinting Tool

dsp (analyzeRms, FFT), compute (cross-correlation), charts, dataframe

⭐⭐⭐⭐

Badacze audio, programiści gier

Wykrywanie duplikatów i przesterowań w bibliotekach dźwiękowych wymaga ręcznego odsłuchu.

release / headless



 (Aktualny)

UC-48

Real-Time Audio Spectrogram Visualiser

dsp (SpectrumAnalyzer), audio, compute (FFT), charts, render, ui

⭐⭐⭐⭐⭐

Inżynierowie dźwięku, akustycy

Trudności w uzyskaniu idealnej synchronizacji 60 FPS dla spektrogramów w czasie rzeczywistym.

release



 (Aktualny)

UC-58

Interaktywna Instalacja Artystyczna (Audio-Ruch)

dsp (SpectrumAnalyzer), compute, particle, light, camera

⭐⭐⭐

Galerie sztuki, kuratorzy wystaw

Brak elastycznych narzędzi do mapowania widma częstotliwości bezpośrednio na fizykę cząsteczek.

release



 (Aktualny)

UC-63

Heraldyczny Generator i Encyklopedia Rodów

procgen (Markov), image, patterns (RelationshipManager), render

⭐⭐⭐

Autorzy RPG, deweloperzy

Trudne proceduralne składanie warstw graficznych herbu z automatyczną zmianą dyplomacji.

release



 (Aktualny)

UC-64

Radar i Akustyczny Lokalizator Podwodny

dsp (SpectrumAnalyzer), compute, visibility (Fov), physics, render

⭐⭐⭐⭐

Deweloperzy gier militarnych / symulatorów

Brak symulatorów sonaru pasywnego i aktywnego uwzględniających ukształtowanie dna morskiego.

release



 (Aktualny)

6. Operacje, Monitorowanie i DevOps

Tryb headless i stabilność rdzenia napisanego w Rust umożliwiają wykorzystanie Lurek2D w potokach Continuous Integration i na serwerach jako demona systemowego.

ID

Nazwa Przypadku Użycia

Kluczowe Moduły Lurek2D

Trudność

Docelowy Odbiorca / Klient

Rozwiązywany Problem

Profil Budowania & Status

UC-29

Infrastructure Monitoring Dashboard

network (metrics polling), dataframe, charts, ui, agent (LLM)

⭐⭐⭐⭐

Administratorzy systemów, Devops

Surowe dane z Prometheusa są mało czytelne dla osób decyzyjnych bez kontekstu słownego.

release



 (Bliska przyszłość)

UC-30

Log Analysis & Anomaly Detection

grep (regex search), filesystem, dataframe (z-score), agent (Ollama)

⭐⭐⭐⭐

Inżynierowie SRE, Sysadmins

Analiza tysięcy linii logów w poszukiwaniu przyczyn awarii systemu bywa czasochłonna.

release --headless



 (Bliska przyszłość)

UC-31

CI / Test Automation Harness

automation (input record), serial, filesystem, timer, log

⭐⭐⭐⭐

Inżynierowie QA, Release Managers

Brak stabilnych metod integracji scenariuszy testowych w potokach CI bez podłączonego ekranu.

release --headless



 (Aktualny)

UC-35

DAG Workflow Orchestrator

pipeline (Kahn's algorithm), serial, filesystem, log, thread

⭐⭐⭐⭐

Inżynierowie danych, Devops

"Callback hell" i brak odporności na błędy (retry) przy sekwencyjnym przetwarzaniu kroków.

release --headless



 (Aktualny)

UC-39

Headless Game Regression Framework

automation (visualassert), timer, serial, render (frame capture)

⭐⭐⭐⭐⭐

Programiści, testerzy QA

Niezauważone błędy graficzne (visual regressions) trafiające do wydań produkcyjnych gier.

release / headless



 (Aktualny)

UC-42

Data Quality Validator & Schema Checker

validator, dataframe (SQL filters), compute (outliers), pipeline

⭐⭐⭐⭐

Data Engineers, dbt specjaliści

Walidacja dużych schematów CSV pod kątem unikalności i wartości odstających obciąża pamięć.

release --headless



 (Bliska przyszłość)

UC-45

Linux Headless Daemon / Background Service

network, timer, dataframe, filesystem, log, thread, pipeline

⭐⭐⭐⭐

Sysadmins, backend deweloperzy

Trudności w utrzymywaniu lekkich demonów systemowych bez skomplikowanych zależności JVM/Node.

release --headless



 (Aktualny)

UC-51

Predykcyjny Kontroler Mikrosieci i Farm PV

learning (ONNX), dataframe, network (inverters), pipeline, ui

⭐⭐⭐⭐

Inżynierowie OZE, operatorzy farm

Brak lokalnej predykcji obciążenia mikrosieci powoduje nieoptymalne wykorzystanie baterii.

release (ARM64 Edge)



 (Aktualny)

UC-59

Ewaluator Proceduralnych Poziomów w CI/CD

procgen, pathfind, ai (BehaviorTree), dataframe, serial

⭐⭐⭐⭐

Projektanci poziomów, release managerzy

Poziomy wygenerowane proceduralnie bywają zablokowane i niemożliwe do ukończenia przez gracza.

release --headless



 (Aktualny)

7. Platforma, Biblioteki i Narzędzia (Tooling)

W tej sekcji zgrupowano aplikacje pomocnicze, integracje systemowe, a także wykorzystanie Lurek2D jako czystej biblioteki programistycznej dołączanej do zewnętrznych projektów w Rust.

ID

Nazwa Przypadku Użycia

Kluczowe Moduły Lurek2D

Trudność

Docelowy Odbiorca / Klient

Rozwiązywany Problem

Profil Budowania & Status

UC-09

Internal Studio Tool / Level Editor

ui, tilemap (TMX), render, filesystem, dialog, overlay

⭐⭐⭐

Projektanci poziomów, designerzy

Trudność w modyfikowaniu parametrów poziomów gry bez restartu całego procesu.

release



 (Bliska przyszłość)

UC-10

Modding Platform / Scripted App Host

mods, filesystem (GameFS Sandbox), event, patterns, serial

⭐⭐⭐

Modderzy gier, twórcy platform

Niebezpieczeństwo uszkodzenia plików systemowych przez złośliwe skrypty modów użytkowników.

release



 (Aktualny)

UC-11

Physical AI & Robotics Visual
