# 🌉 Bridge Builder — Structural Engineering Physics Puzzle

**Category:** Strategy / Physics Puzzle  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Bridge Builder** to zaawansowana gra logiczno-inżynieryjna z pełną symulacją fizyczną naprężeń materiałowych (Bridge Engineer), będąca bezpośrednim hołdem dla kultowych klasyków takich jak *Bridge Builder (2000)* oraz seria *Poly Bridge*. Jako inżynier mostowy stajesz przed wyzwaniem zaprojektowania i wybudowania bezpiecznych konstrukcji nośnych nad głębokimi kanionami i rwącymi rzekami. Dysponując ograniczonym budżetem i trzema rodzajami materiałów (jezdnia, stalowe wsporniki, wiszące liny), musisz wznieść konstrukcję zdolną przenieść ciężar przejeżdżających pojazdów. Testuj swoje mosty pod obciążeniem, obserwuj dynamiczne naprężenia (od bezpiecznej zieleni po krytyczną czerwień) i reaguj na pękające z trzaskiem belki!

### Pętla Rozgrywki i Mechaniki
1. **Zróżnicowane Poziomy (8 wyzwań):** Gra oferuje 8 odblokowywanych kolejno poziomów o rosnącej skali trudności (od "Gentle Creek" po monumentalny "Grand Canyon"). Każdy poziom charakteryzuje się inną szerokością przepaści (gap: 160-500px), budżetem (budget: 50-200g) oraz ciężarem pojazdu testowego (weight: 1.0-3.0x).
2. **Katalog Materiałów Budowlanych:**
   - **Road (Droga):** Koszt: 10g. Podstawa jezdna mostu. Posiada ograniczenie **horiz_only** (można ją układać wyłącznie w poziomie, z tolerancją różnicy wysokości do 5px).
   - **Steel (Stal):** Koszt: 15g. Sztywny element konstrukcyjny o dużej wytrzymałości na ściskanie i rozciąganie. Można go łączyć pod dowolnym kątem.
   - **Cable (Lina stalowa):** Koszt: 5g. Elastyczna lina działająca **wyłącznie na rozciąganie (tension_only)**. Nie przenosi obciążeń ściskających.
3. **Tryb Projektowania (Building Mode):**
   - Klikaj na ekranie w wolnym obszarze, by tworzyć swobodne węzły konstrukcyjne (Nodes), lub klikaj na zakotwiczone w skale złote punkty stałe (Fixed Anchors).
   - Kliknij na jeden węzeł, a następnie na drugi, by rozciągnąć między nimi wybrany materiał. Jeśli zmieścisz się w budżecie, element zostanie zamontowany.
   - **Delete Mode (D):** Pozwala na kliknięcie i usuwanie pojedynczych belek.
   - **Undo (Z):** Umożliwia cofnięcie ostatnio postawionego elementu.
4. **Tryb Testu Obciążeniowego (Testing Mode - T):**
   - Po naciśnięciu **T** na most wjeżdża pojazd testowy (niebieski samochód osobowy lub ciężki czerwony samochód ciężarowy w zależności od poziomu).
   - Silnik fizyczny gry dynamicznie kalkuluje naprężenia każdej belki w czasie rzeczywistym. Kolor elementu zmienia się płynnie od bezpiecznej zieleni, przez ostrzegawczą żółć, aż po krwistą czerwień.
   - Przekroczenie krytycznego naprężenia (stress >= 1.0) powoduje pęknięcie belki, co wyzwala sypiące się odłamki i może doprowadzić do widowiskowej katastrofy budowlanej!
5. **Punktacja i Efektywność:** Po udanym przejeździe pojazdu na drugą stronę otrzymujesz ocenę punktową obliczaną na podstawie zaoszczędzonego budżetu oraz efektywności materiałowej konstrukcji.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Bridge Builder** is a highly sophisticated, physics-driven structural engineering and bridge design puzzle directly inspired by pioneering classics like *Bridge Builder (2000)* and the *Poly Bridge* franchise. As a bridge architect, you must construct stable crossings over deep canyons and rushing rivers. Armed with a strict budget and three engineering materials (road decks, steel girders, and suspension cables), design support trusses and load-bearing triangles. Put your structural integrity to the ultimate test: send heavy vehicles across and watch the real-time stress analysis shift dynamically from safe green to warning yellow and catastrophic red. Adjust your trusses, prevent structural collapse, and achieve maximum material efficiency!

### Gameplay Loop & Mechanics
1. **Dynamic Level Progression (8 challenges):** Master 8 progressively wider gaps (from the introductory "Gentle Creek" to the monumental "Grand Canyon"). Gaps range from 160px to 500px, budgets span 50g to 200g, and vehicle weights scale from light 1.0x cars to heavy 3.0x haulers.
2. **Engineering Materials:**
   - **Road:** Costs 10g. The driving deck. Restricted to horizontal layups (maximum vertical difference of 5px).
   - **Steel:** Costs 15g. Rigid support girders with superior tensile and compressive strength. Can be constructed at any angle to form triangular trusses.
   - **Cable:** Costs 5g. Flexible suspension cables that **only support tension**. Compressive forces yield instant structural slack.
3. **Design Phase (Building Mode):**
   - Click in open space to place structural grid nodes, or snap connections directly to gold rock-fixed anchor nodes.
   - Click one node and select another to lay down a support beam of the chosen material type.
   - **Delete Mode (D):** Dismantles individual beams at click targets to reclaim budget allocations.
   - **Undo (Z):** Reverts the last placed beam layout instantly.
4. **Stress Testing Phase (Testing Mode - T):**
   - Press **T** to dispatch the test vehicle (a blue passenger car or a heavy red cargo truck).
   - The engine computes real-time beam stress. Trusses dynamically blend colors from safe green to warnings of yellow, orange, and critical red.
   - If stress exceeds the threshold (stress >= 1.0), the beam snaps with a crack, emitting physics-based debris particles that can cause catastrophic structure failures!
5. **Efficiency Scores:** Successfully crossing the gorge triggers dynamic scoring calculated from remaining budget and material stress optimization.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/bridge_builder
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB (Klik)** | Postaw węzeł / Połącz | Tworzy nowy węzeł na planszy lub łączy dwa wcześniej kliknięte węzły wybranym materiałem. |
| **R** | Narzędzie: Droga (Road) | Wybiera kładzenie jezdni mostowej (Koszt: 10g, układ wyłącznie poziomy). |
| **S** | Narzędzie: Stal (Steel) | Wybiera kładzenie stalowego wspornika (Koszt: 15g, dowolny kąt). |
| **C** | Narzędzie: Lina (Cable) | Wybiera kładzenie liny stalowej (Koszt: 5g, elastyczna lina wisząca). |
| **T** | Test obciążenia | Uruchamia symulację i wysyła pojazd na most (zmienia tryb Build -> Test). |
| **Z** | Cofnij (Undo) | Cofa ostatnio postawiony element mostu. |
| **D** | Tryb usuwania (Delete) | Przełącza wskaźnik w tryb kasowania pojedynczych belek kliknięciem. |
| **1 - 8** | Wybór poziomu | Wybiera odblokowany poziom w ekranie wyboru poziomu (Level Select). |
| **Enter (Return)** | Potwierdzenie / Dalej | Uruchamia grę z menu głównego lub przechodzi z podsumowania sukcesu/porażki do menu wyboru. |
| **Esc** | Powrót / Wyjście | Cofa się do menu wyboru poziomów lub zamyka całkowicie grę. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Bridge Builder (2000) by Alex Austin**
  - *Opis powiązania*: Bezpośrednia mechaniczna inspiracja. Przeniesienie kultowego rzutu z boku na kanion, podziału na węzły stałe i swobodne, a przede wszystkim dynamiczne badanie naprężeń z przejściem kolorystycznym belek od zieleni do czerwieni.
- **Poly Bridge (Seria) by Dry Cactus**
  - *Opis powiązania*: Estetyczna prezentacja, wesoły podział na lekkie samochody i ciężkie ciężarówki wywołujące odmienne ugięcia jezdni pod wpływem masy, oraz wdrożenie wskaźników procentowych sprawności budżetowej konstrukcji.
- **Pontifex by Chronic Logic**
  - *Opis powiązania*: Wdrożenie elastycznych lin wiszących, które nie przenoszą siły ściskającej (tension-only), co zmusza gracza do tworzenia łuków wiszących i odciągów.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra stanowi kapitalny pokaz zaawansowanych możliwości obliczeniowych, fizycznych i wizualnych Lurek2D:
- `lurek.input` – Kompleksowa obsługa mapowania akcji klawiatury dla precyzyjnego wyboru materiałów (R/S/C), sterowania testem (T), cofania (Z) oraz transformowania kliknięć myszką na pozycje węzłów.
- `lurek.render` – Dynamiczne rysowanie przekroju kanionu (tekstury skał, niebieski rurociąg rzeki, zróżnicowane linie grubości belek, dynamiczny gradient kolorów naprężeń belek za pomocą `rect`, `circ` oraz `ln`).
- `lurek.camera` – Wdrożenie wirtualnej kamery viewportu (`lurek.camera.new`) zapewniającej wycentrowany widok przepaści oraz stabilną perspektywę rysowania mostu.
- `lurek.timer` – Wykorzystywany do precyzyjnego odmierzania kroku czasowego delta (`dt`) w fizycznym ruchu pojazdu i aktualizacji układu sił konstrukcji.
- `lurek.event` – Prawidłowa i bezpieczna realizacja wyjścia z gry przy naciśnięciu klawisza Esc.
- **Wbudowane Animacje Tweeningu:** Płynna interpolacja animacji sumowania wyniku końcowego (Score) z wygładzeniem typu Out Quad w panelu sukcesu.
- **Aż Cztery Zaawansowane Systemy Cząsteczek (Multiple Particle Systems):**
  - *Iskry budowlane (Construction Sparks)*: Złoto-pomarańczowe, jasne iskierki sypiące się z węzłów w momencie pomyślnego łączenia struktur.
  - *Odłamki zniszczenia (Debris)*: Brązowo-szare odłamki drewna i stali wybuchające w powietrzu w miejscu pęknięcia przeciążonej belki.
  - *Plusk wodny (Water Splash)*: Błękitno-biała fontanna kropli tryskająca w górę w momencie wpadnięcia pojazdu do rzeki po zawaleniu mostu.
  - *Konfetti sukcesu (Success Confetti)*: Tęczowy deszcz powoli opadających kolorowych kwadracików celebrujący pomyślny przejazd pojazdu.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Prawdziwy pokaz zaawansowanych algorytmów obliczeniowych i mechaniki matematycznej w skryptach Lua. Pokazuje, jak w Lurek2D zaimplementować dynamiczne rzutowanie odległości punktów do odcinków (Distance to Segment), pętlę fizyki ugięć opartą na naprężeniach dynamicznych oraz koordynację 4 potężnych emiterów cząsteczek bez utraty stabilności klatek.
- **Unikalność (Uniqueness):** Jedyna gra inżynieryjna w portfolio. Cakowicie rezygnuje z tradycyjnej zręcznościówki na rzecz czystego myślenia technicznego, planowania rozkładu sił oraz optymalizacji budżetowej, co doskonale demonstruje potencjał edukacyjny silnika.
- **Podobne gry (Similar Games):** Gra dzieli fizyczny charakter z `physics_puzzle` oraz `worms_artillery`, ale wyróżnia się unikalną statyczną fizyką badającą naprężenia konstrukcji nośnych pod obciążeniem dynamicznym.
