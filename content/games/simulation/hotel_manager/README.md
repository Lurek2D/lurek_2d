# 🏨 Hotel Manager — Tiny-Tower Side-View Economics Simulator

**Category:** Simulation  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Hotel Manager** to niezwykle wciągająca gra strategiczno-ekonomiczna w rzucie bocznym (Side-view Hotel Tycoon), silnie inspirowana klasykami pokroju *Tiny Tower* oraz *Theme Hotel*. Wciel się w rolę ambitnego menedżera, którego celem jest przekształcenie skromnego, trzygwiazdkowego pensjonatu w luksusowy, pięciogwiazdkowy hotel i zgromadzenie fortuny o wartości 1000 sztuk złota. Rozbudowuj hotel w pionie do 8 pięter wysokości, zarządzaj strukturą pokoi (Standard, Deluxe, luksusowe Suite), zatrudniaj automatycznych pokojowych (Cleaners), dbaj o zadowolenie wymagających gości oraz utrzymuj nienaganną czystość apartamentów. Każda decyzja o inwestycjach w windy lub modernizację pokoi ma bezpośredni wpływ na opinie gości i dynamicznie zmieniający się prestiż Twojego imperium!

### Pętla Rozgrywki i Mechaniki
1. **Pionowa Ekspansja (Vertical Growth):** Hotel składa się z siatki o rozmiarze 5 kolumn i 8 pięter. Możesz stawiać pokoje na wyższych kondygnacjach pod warunkiem, że bezpośrednio pod nimi znajduje się inny pokój (oparcie konstrukcji).
2. **Katalog Pokoi (Room Portfolio):**
   - **Standard (Zielony):** Koszt: 50g | Dochód za noc: 10g. Podstawowy pokój.
   - **Deluxe (Niebieski):** Koszt: 100g | Dochód za noc: 20g. Lepszy standard.
   - **Suite (Złoty):** Koszt: 200g | Dochód za noc: 40g. Najwyższy luksus i największe zyski.
   - **Upgrades (Modernizacja):** Używając narzędzia **Upgrade (U)**, możesz w dowolnej chwili podnieść standard pokoju do wyższego tieru, płacąc wyłącznie różnicę w cenie.
3. **Logistyka i Koszt Windy:** Budowanie powyżej pierwszego piętra wymaga dopłaty w wysokości **30 sztuk złota opłaty dźwigowej (Elevator Fee)** na każde nowe piętro, co odzwierciedla budowę szybu windy po lewej stronie hotelu.
4. **Obsługa Gości i Cykl Nocny:**
   - Klienci przybywają w tempie proporcjonalnym do ogólnej oceny hotelu.
   - Każdy nocny cykl (co 20 sekund) generuje dochód z zajętych pokoi, zmniejsza czas pobytu gościa (staysLeft) i **brudzi pokój o +1 stopień**.
   - **Zadowolenie (Satisfaction) i Gwiazdki:** Jeśli pokój jest brudny (brud >= 2), zadowolenie gościa drastycznie spada (-0.3 na noc), a ocena hotelu maleje o 0.2 gwiazdki. W czystych pokojach zadowolenie rośnie (+0.1), a ocena hotelu pnie się w górę o 0.1 gwiazdki. Gość opuszczający hotel z zadowoleniem poniżej 30% dodatkowo trwale obniża prestiż hotelu.
5. **Utrzymanie Czystości (Cleaning):**
   - **Manualne (C):** Za opłatą 5 złota możesz kliknąć na brudny pokój, by go posprzątać (trwa to 3 sekundy).
   - **Automatyczne (H):** Zatrudnij pokojówkę za 20 złota. Każda pokojówka automatycznie i bezkosztowo sprząta do 5 pokoi na cykl, uwalniając Cię od żmudnego klikania.
6. **Warunek Zwycięstwa:** Osiągnięcie pełnej **5-gwiazdkowej oceny (5.0 stars)** oraz zgromadzenie **1000 sztuk złota**.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Hotel Manager** is an immersive, side-scrolling vertical hotel economics simulator (Side-view Hotel Tycoon) heavily inspired by mobile and web legends like *Tiny Tower* and *Theme Hotel*. Step into the executive shoes of a hotel tycoon tasked with transforming a modest 3-star building into a towering 5-star skyscraper while amassing 1,000 gold coins. Expand your hotel upward across 8 functional floors, choose the optimal layout of guest rooms (Standard, Deluxe, and Suite), hire automatic cleaning staff, monitor customer satisfaction, and protect your precious reputation. Strategic investments in elevators and room upgrades directly dictate customer reviews and your empire's overall standing!

### Gameplay Loop & Mechanics
1. **Vertical Architecture:** Your grid covers 5 rooms in width and 8 floors in height. You can only construct rooms on higher floors if there is a supportive structure directly beneath them on the floor below.
2. **Room Tiers:**
   - **Standard (Green):** Costs 50g | Yields 10g per night. Core budget housing.
   - **Deluxe (Blue):** Costs 100g | Yields 20g per night. Mid-tier premium.
   - **Suite (Gold):** Costs 200g | Yields 40g per night. Luxury penthouse yielding maximum returns.
   - **Upgrades (U):** Refine existing spaces. Target any constructed room and upgrade it to the next tier instantly by paying only the cost difference.
3. **Elevator Logistics:** Building above the ground floor (Floor 1) demands a **30 gold Elevator Fee** per new floor, which visually constructs a grey mechanical elevator shaft along the left edge of your hotel.
4. **Nightly Cycles & Satisfaction Ratings:**
   - Customers arrive at intervals scaled by your hotel's overall star rating.
   - Every night (every 20 seconds), checked-in guests pay rent, decrease their staysLeft counter, and **dirty their rooms by +1**.
   - **Star Ratings:** Staying in a dirty room (dirt >= 2) penalizes customer satisfaction (-0.3 per night) and cuts your overall rating by 0.2 stars. Clean rooms boost satisfaction (+0.1) and rating (+0.1 stars). Guests checking out with satisfaction below 30% drop your rating permanently.
5. **Sanitation Systems (Cleaning):**
   - **Manual Clean (C):** Spend 5 gold per room to manually sweep it (takes 3 seconds).
   - **Hire Maid (H):** Hire automatic Cleaners for 20 gold. Maids automatically and cost-effectively clean up to 5 dirty rooms per cycle, allowing you to focus on high-level infrastructure.
6. **Victory Milestone:** Secure a perfect **5.0-star rating** and accrue a treasury of **1,000 gold**.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/simulation/hotel_manager
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB (Lewy Klik)** | Budowa / Wybór | Potwierdza działanie (budowę pokoju lub wykonanie operacji) na klikniętym kafelku siatki. |
| **1** | Narzędzie: Pokój Standard | Wybiera pokój Standard jako aktywny obiekt budowy (Koszt: 50g). |
| **2** | Narzędzie: Pokój Deluxe | Wybiera pokój Deluxe jako aktywny obiekt budowy (Koszt: 100g). |
| **3** | Narzędzie: Luksusowy Suite | Wybiera pokój Suite jako aktywny obiekt budowy (Koszt: 200g). |
| **C** | Narzędzie: Sprzątanie | Włącza tryb manualnego sprzątania brudnych pokoi (Koszt: 5g). |
| **U** | Narzędzie: Modernizacja | Włącza tryb ulepszania pokoi do wyższego standardu (Upgrade). |
| **H** | Zatrudnij sprzątaczkę (Hire) | Automatycznie zatrudnia nową pokojówkę (Koszt: 20g). |
| **Esc** | Wyjście | Zamyka bezpiecznie aplikację. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Tiny Tower (2011) by NimbleBit**
  - *Opis powiązania*: Bezpośrednie nawiązanie do rzutu bocznego (cross-section grid view), pionowego rozwoju budynku piętro po piętrze, konieczności kładzenia nowych kafelków na solidnej bazie dolnej kondygnacji oraz obecności szybu windy spajającego logistycznie cały obiekt.
- **Theme Hotel (2012) by Flash Games**
  - *Opis powiązania*: Rdzeń menedżera hotelowego z podziałem pokoi na Standard, Deluxe i Suite, konieczność sprzątania zabrudzonych pomieszczeń przed check-inem kolejnych gości oraz system gwiazdkowych ocen ratingowych (1-5 gwiazdek).
- **SimTower (1994) by Maxis**
  - *Opis powiązania*: Legendarna symulacja drapacza chmur, z której Hotel Manager czerpie mechaniki dbania o nastroje mieszkańców i konieczność inwestycji w pionową komunikację windową.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Hotel Manager to wspaniała demonstracja elastyczności graficznej i logicznej silnika Lurek2D:
- `lurek.input` – Mapowanie akcji klawiatury dla narzędzi (1-3, C, U, H) oraz obsługa kliknięć myszką w celu zaznaczania i wyboru kafelków siatki hotelowej.
- `lurek.camera` – Wdrożenie wirtualnej kamery viewportu (`lurek.camera.new`) zapewniającej wycentrowany widok przekroju hotelu.
- `lurek.render` – Rysowanie przekroju budynku (ściany pokoi, dynamiczny szary szyb windy, poruszające się buźki gości oznaczane kolorami nastrojów za pomocą `rect` i `circ`) oraz renderowanie paska statusowego gwiazdek i HUD.
- `lurek.timer` – Odmierzanie precyzyjnych interwałów czasu delta do kontrolowania cyklu nocnego pobierania czynszu oraz czasu sprzątania pokojówek.
- `lurek.event` – Wykrywanie klawisza Esc do czystego wyjścia z gry.
- **System Tweenów:** Płynna interpolacja przyrostu i spadku salda finansowego (Gold) dla zapewnienia przyjemnego, dynamicznie rosnącego efektu liczbowego w HUD.
- **Płynna Emisja Cząsteczek (Particles):**
  - *Budowa i Modernizacja*: Cząsteczki w kolorze wybranego typu pokoju (zielone, niebieskie, złote) sypiące się z punktu środkowego podczas budowy lub ulepszania.
  - *Czyszczenie i Piana*: Jasnoniebieskie, bąbelkowe cząsteczki emitowane przy sprzątaniu (zarówno manualnym, jak i przez pokojówki), symbolizujące środki czystości.
  - *Zamelduj i Świętuj*: Ciepłe, złociste iskierki rozbłyskujące przy pomyślnym zameldowaniu nowego gościa.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Gra w znakomity sposób pokazuje, jak zaimplementować symulator typu "tycoon" w widoku z boku (side-view cross-section). Demonstruje precyzyjną translację kliknięć myszą do pionowych kondygnacji i pokoi, dynamiczne systemy oceny reputacji, automatycznie działające boty (autonomiczni sprzątacze) oraz wielowątkowe stany pokoi (Dirty, Occupant, CleanTimer) działające równocześnie w tle.
- **Unikalność (Uniqueness):** Jedyna gra w portfolio w rzucie bocznym przekroju poprzecznego (cross-section). Skupia się na mikrozarządzaniu, obsłudze gości o zmiennych nastrojach i planowaniu przestrzennym w pionie, co stanowi doskonałą odmianę od standardowych gier zręcznościowych i przygodowych.
- **Podobne gry (Similar Games):** Gra dzieli mechaniki budowania i zarządzania z `colony_sim` oraz `province_economy_demo`, ale wyróżnia się unikalną pionową ekspansją pięter oraz bezpośrednią zależnością zysków od poziomu czystości pokoi.
