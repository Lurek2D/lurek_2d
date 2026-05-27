# 🥊 Boxing Ring — 2D Arcade Fighter

**Category:** Sports / 2D Fighter  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Boxing Ring** to dynamiczna, dwuwymiarowa gra zręcznościowa o tematyce bokserskiej, będąca bezpośrednim mechanicznym hołdem dla nieśmiertelnych klasyków, takich jak *Punch-Out!!* (NES) czy zręcznościowe automaty z lat 90. Wciel się w rolę pretendenta, wyjdź na ring i zmierz się z wymagającym przeciwnikiem sterowanym przez sztuczną inteligencję w 3-rundowym pojedynku. Gra kładzie ogromny nacisk na zarządzanie poziomem kondycji (Stamina), tworzenie zabójczych kombinacji ciosów (Combos) oraz błyskawiczne uniki (kucanie, odchylanie) i bloki. Boxing Ring to rewelacyjna prezentacja silnika Lurek2D w zakresie zaawansowanej sztucznej inteligencji opartej na stanach (FSM AI), animacji tweeningowych oraz profesjonalnego interfejsu użytkownika wczytywanego z szablonu TOML.

### Pętla Rozgrywki i Mechaniki
1. **System Walki i Kombinacji:**
   - Zadawaj ciosy o zróżnicowanych właściwościach i zasięgu:
     - **Jab (J - Lewy Prosty):** Szybki cios (5 DMG, 5 stamina, 0.2s CD). Dobry do budowania combosów.
     - **Hook (K - Sierpowy):** Średnia szybkość i zasięg (10 DMG, 10 stamina, 0.5s CD).
     - **Uppercut (L - Podbródkowy):** Powolny, lecz niszczycielski cios z bliska (20 DMG, 20 stamina, 1.0s CD).
   - Trafienia pod rząd budują licznik kombinacji (Combo), który daje potężny bonus punktowy.
2. **Kondycja i Obrona (Stamina & Defense):**
   - **Stamina (Kondycja):** Każdy wyprowadzony cios kosztuje energię. Jej całkowite wyczerpanie spowalnia ruchy i blokuje możliwość ataku do czasu regeneracji.
   - **Block (Spacja):** Redukuje otrzymywane obrażenia aż o 80%.
   - **Uniki (Dodging):** 
     - **Duck (W - Kucnięcie):** Całkowicie unika ciosów prostych (Jabs) i sierpowych (Hooks).
     - **Lean back (S - Odchylenie):** Pozwala uniknąć potężnych podbródkowych (Uppercuts).
3. **Inteligentny Rywal i Rundy:**
   - Sztuczna inteligencja dynamicznie przełącza się między zbliżaniem, wycofywaniem, blokowaniem i wyprowadzaniem ciosów w zależności od odległości.
   - Poziom trudności rośnie w każdej z 3 rund (AI reaguje szybciej i atakuje częściej).
   - Między rundami zawodnicy odzyskują 20% maksymalnego zdrowia. Wygraj przez nokaut (KO - HP rywala do 0) lub zdobywając przewagę punktową na dystansie 3 rund!

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Boxing Ring** is a high-octane 2D side-view arcade boxing game standing as a direct mechanical tribute to timeless blockbusters like *Punch-Out!!* (NES) and retro 90s coin-op cabinets. Step into the ring and challenge a highly reactive, state-driven AI boxer across a gruelling 3-round championship match. Success demands strict management of your stamina reserve, racking up high-value hit Combos, and executing split-second defensive reactions including active blocking and targeted dodging (ducking under jabs vs leaning back from uppercuts). Sporting premium TOML-based UI nodes, fluid stagger state machines, and sweat-dropping emitters, this project is a magnificent showcase of real-time combat systems in Lurek2D!

### Gameplay Loop & Mechanics
1. **Strike Dynamics & Combos:**
   - Sling three distinct punch varieties with varied ranges, cooldowns, and costs:
     - **Jab (J):** Fast, short range (5 DMG, 5 stamina, 0.2s CD). Perfect for keeping pressure.
     - **Hook (K):** Medium speed and reach (10 DMG, 10 stamina, 0.5s CD).
     - **Uppercut (L):** Slow, close-quarters devastator (20 DMG, 20 stamina, 1.0s CD).
   - Chaining consecutive hits builds a Combo multiplier, yielding massive score spikes.
2. **Stamina & Tactical Defense:**
   - **Stamina:** Throwing punches burns energy. Running out of stamina severely dampens movement speed and locks out attacks until you regenerate.
   - **Block (Space):** Erects a tight guard absorbing 80% of incoming damage.
   - **Dodging (Dodge Frames):**
     - **Duck (W):** Safely crouches underneath incoming Jabs and Hooks.
     - **Lean (S):** Sways back to dodge heavy Uppercuts.
3. **Scaling AI Match & Rounds:**
   - The AI boxer cycles between approach, retreat, active blocking, and striking states based on dynamic distance checking.
   - Opponent AI reactions, speed, and blocking rates scale up automatically in rounds 2 and 3.
   - Fighters recover 20% HP during round intervals. Win instantly by Knockout (KO) or out-damage your rival over 3 full rounds!

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/sports/boxing_ring
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **A / D** | Ruch (Move Left/Right) | Przemieszcza boksera w lewo lub w prawo wewnątrz ringu. |
| **W** | Kucnięcie (Duck Dodge) | Wykonuje szybki przysiad (unik przed ciosami na głowę - Jab/Hook). |
| **S** | Odchylenie (Lean Dodge) | Odchyla tułów w tył (unik przed podbródkowym - Uppercut). |
| **J** | Lewy Prosty (Jab Punch) | Wyprowadza szybki, tani energetycznie cios prosty (Koszt: 5 Stamina). |
| **K** | Sierpowy (Hook Punch) | Wyprowadza mocniejszy cios sierpowy (Koszt: 10 Stamina). |
| **L** | Podbródkowy (Uppercut) | Wyprowadza powolny, niszczycielski cios z dołu (Koszt: 20 Stamina). |
| **Space (Spacja)** | Blok (Guard Block) | Utrzymuje podwójną gardę redukującą 80% obrażeń. |
| **Esc** | Wyjście (Quit) | Zamyka grę w bezpieczny sposób. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Punch-Out!! (1987) by Nintendo**
  - *Opis powiązania*: Wyraźna inspiracja taktyczną walką bokserską z bliska, koniecznością obserwowania zachowania rywala w celu wykonania uniku w odpowiednią stronę (kucnięcie lub odchylenie) oraz animacją chwiejnego oszołomienia (Stagger) po ciosie.
- **Super K.O. Boxing**
  - *Opis powiązania*: Wdrożenie liczników kondycji (Stamina) ograniczających bezmyślne mashingowanie klawiszy oraz bonusowych mnożników punktacji za kombinacje ciosów.
- **Street Fighter II**
  - *Opis powiązania*: Klasyczne paski zdrowia, ułamkowe czasy odnowienia ataków (Attack cooldown frames) oraz dynamiczny tłum wokół ringu z linami.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

- `lurek.ui` – Kompletne wczytywanie profesjonalnego interfejsu graficznego z pliku TOML (`ui.toml`). Dynamiczna obsługa przycisków, ekranów zwycięstwa, rund oraz etykiet wyniku.
- `lurek.input` – Zaawansowane mapowanie akcji wejściowych dla precyzyjnego wykrywania jednoczesnych ruchów, uników i szybkich sekwencji ciosów.
- `lurek.camera` – Wdrożenie wirtualnej kamery (`lurek.camera.new`) centrującej widok na ringu i stabilizującej pozycje zawodników.
- `lurek.tween` – Płynna interpolacja czerwonych pasków obrażeń HP, animacji opadania banera rundy oraz chwiejnego staggeru zawodnika.
- **Trzy Niezależne Systemy Cząsteczek (Multiple Particle Systems):**
  - *Iskry uderzenia (Punch Impact)*: Dynamiczny żółto-czerwony snop iskier wyzwalany w punkcie trafienia ciosu.
  - *Cząsteczki potu (Sweat Drops)*: Niebieskawe kropelki potu tryskające z zawodnika o skrajnie niskim poziomie stamina.
  - *Gwiazdki KO (KO Stars)*: Tęczowy wieniec wirujących gwiazdek celebrujący nokaut rywala.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Najbardziej złożony technicznie bijatyka w portfolio silnika. Pokazuje wspaniałe wykorzystanie stanowej sztucznej inteligencji AI do symulowania ludzkich odruchów walki bokserskiej, bezszwowe łączenie fizyki ringu z ramkami animacji (frame-data) oraz wczytywanie skomplikowanych układów interfejsu TOML.
- **Unikalność (Uniqueness):** Jedyna gra z widokiem z boku w 100% dedykowana pojedynkom bokserskim, z unikalnymi mechanikami uników strefowych (Duck/Lean) i wyczerpaniem kondycji.
- **Podobne gry (Similar Games):** Dzieli mechanikę walki 2D z `fighting_game` oraz `platform_fighter`, jednak wyróżnia się znacznie bardziej rozbudowanym systemem obronnym (strefowe uniki) oraz kompletnym systemem rundowym.
