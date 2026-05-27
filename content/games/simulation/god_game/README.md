# 🌍 God Game — Populous-Style Divine Simulation Sandbox

**Category:** Simulation  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**God Game** to zachwycający, potężny symulator boga w czasie rzeczywistym (God-Sim), będący bezpośrednim hołdem dla legendarnych klasyków gatunku, takich jak *Populous* oraz *Black & White*. Jako bóstwo kontrolujące wirtualną krainę posiadasz absolutną władzę nad rzeźbą terenu oraz losem swoich wyznawców. Kształtuj kontynenty za pomocą kliknięć myszy (podnoszenie i obniżanie terenu), zsyłaj boskie cuda (życiodajny deszcz, niszczycielskie trzęsienia ziemi, potężne pioruny i błogosławieństwa płodności), stawiaj mury obronne i chroń niebieskich osadników przed czerwonymi plemionami wrogich niewiernych (Rivals). Zadbaj o zaopatrzenie w żywność, rozwijaj osadnictwo i poprowadź swoją cywilizację do osiągnięcia limitu 50 dusz, by ustanowić wieczną chwałę!

### Pętla Rozgrywki i Mechaniki
1. **Rzeźbienie Świata (Terraforming):** Plansza o rozmiarze 30x22 kafelków to zróżnicowany archipelag. Trzymając lewy klawisz myszy, podnosisz poziom terenu; prawym klawiszem go obniżasz:
   - **Water (Woda - 0):** Niebieska próżnia. Osadnicy nie potrafią pływać — wejście do wody natychmiast ich topi!
   - **Sand (Piasek - 1):** Stabilne nabrzeże.
   - **Grass (Trawa - 2):** Zielone niziny. **Jedyny teren, na którym osadnicy mogą budować domy!**
   - **Forest (Las - 3):** Głęboka puszcza. Generuje żywność (1 punkt co 2 sekundy za każde 8 pól lasu).
   - **Mountain (Góra - 4):** Szare szczyty nieprzebytej skały.
2. **Rozwój Cywilizacji (Autonomiczne AI):**
   - Osadnicy (niebieskie okręgi) wędrują samodzielnie, preferując żyzne polany i lasy, unikając gór i wody.
   - Jeśli populacja przekracza pojemność mieszkalną, budowniczowie automatycznie stawiają nowe domy (Houses) na wolnych polach trawiastych. Każdy dom mieści 3 mieszkańców.
   - Nowi osadnicy rodzą się co 3 sekundy, pod warunkiem, że w spichlerzu jest nadmiar żywności, a populacja mieści się w limicie domów (koszt: 1 żywności).
3. **Cuda i Boskie Interwencje (Miracles):** Twoja potęga zależy od poziomu **Wiary (Faith)**, która przyrasta co sekundę o 1 punkt za każde 5 żyjących wyznawców. Wydawaj wiarę na potężne cuda:
   - **Rain (Deszcz - R):** Koszt: 10 wiary. Nawadnia całą trawę, błyskawicznie zamieniając ją w las. Natychmiast daje zapas żywności równy *populacja * 2*.
   - **Earthquake (Trzęsienie ziemi - E):** Koszt: 20 wiary. Niszczycielski kataklizm obniżający poziom terenu w promieniu 5 kafelków wokół myszy.
   - **Lightning (Piorun - L):** Koszt: 15 wiary. Wyzwala potężne wyładowanie atmosferyczne, które wypala las na trawę i natychmiast uśmierca wszystkich wrogich osadników w promieniu 3 pól.
   - **Blessing (Błogosławieństwo - B):** Koszt: 5 wiary. Sprowadza na świat 1-3 nowych wiernych bezpośrednio przy ich domach.
   - **Wall (Mur - W):** Koszt: 5 wiary. Stawia kamienną barykadę blokującą ścieżki ekspansji wrogów.
4. **Zagrożenie ze Strony Rywali (Rival Faction):** Z prawej strony mapy nadciąga wrogie czerwone plemię. Rywale agresywnie się mnożą i automatycznie atakują Twoich wyznawców przy bliskim kontakcie. Musisz aktywnie razić ich piorunami, topić w wodzie lub blokować murami, by chronić swoje plemię przed anihilacją.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**God Game** is a breathtaking real-time divine simulator (God-Sim) built in Lurek2D as a direct tribute to genre-defining masterpieces like *Populous* and *Black & White*. As an all-powerful deity controlling an island archipelago, you wield absolute authority over both the landscape and the mortals who inhabit it. Reshape continents with simple mouse clicks (raising and lowering tiles), cast epic miracles (famine-ending rains, devastating earthquakes, localized lightning strikes, and fertility blessings), build tactical stone blockades, and shield your blue loyalists from hostile red rival factions. Secure food pipelines, expand housing automatically, and grow your flock to 50 loyal souls to achieve ultimate divine victory!

### Gameplay Loop & Mechanics
1. **Topography Sculpting (Terraforming):** A 30x22 tile landscape represents an organic, procedural archipelago. Holding Left Mouse Button raises the terrain level; Right Mouse Button lowers it:
   - **Water (0):** Deep sea abyss. Mortals cannot swim; falling into water instantly drowns them!
   - **Sand (1):** Lowland shorelines.
   - **Grass (2):** Fertile plains. **The exclusive terrain where citizens can construct residential houses!**
   - **Forest (3):** Deep woodland. Yields food automatically every 2 seconds (1 food per 8 forest tiles).
   - **Mountain (4):** Impassable grey peaks.
2. **Autonomous Tribal AI:**
   - Blue loyalist villagers wander autonomously, scoring tiles by terrain preference (favoring grass and forests, avoiding high peaks and water).
   - When population exceeds housing capacity, villagers automatically construct cozy wooden huts (Houses) on vacant grass tiles. Each house hosts 3 citizens.
   - New villagers spawn every 3 seconds if food stocks surpass current headcounts and housing limits permit (consumes 1 food).
3. **Casting Miracles (Faith Economy):** Your divine energy is represented by **Faith**, generating automatically at a rate of 1 Faith per second for every 5 living followers. Spend Faith to trigger miracles:
   - **Rain (R):** Costs 10 Faith. Hydrates grass tiles into dense forests. Instantly yields food stockpiles equal to *population * 2*.
   - **Earthquake (E):** Costs 20 Faith. Triggers an seismic shockwave, lowering land heights in a 5x5 grid around the mouse.
   - **Lightning (L):** Costs 15 Faith. Strikes the earth, clearing forests into grass and instantly vaporizing any rival units within 3 tiles.
   - **Blessing (B):** Costs 5 Faith. Summons 1-3 new loyalists directly at their doorsteps.
   - **Wall (W):** Costs 5 Faith. Deploys stone defensive blockades blocking pathfinding lanes.
4. **Hostile Heathens (Rival Faction):** Red heathens expand from the right side of the map. Rivals multiply quickly and murder blue villagers upon close quarters contact. Smite them down with lightning, drown them by eroding their coasts, or barricade them with stone walls to prevent tribal extinction!

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/simulation/god_game
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB (Hold)** | Podnieś teren | Podnosi poziom kafelka pod myszą (np. zamienia wodę w piasek, piasek w trawę). |
| **RMB (Hold)** | Obniż teren | Obniża poziom kafelka pod myszą (np. zamienia góry w lasy, piasek w wodę). |
| **R** | Cud: Deszcz (Rain) | Nawadnia trawę w lasy i przywraca obfity zapas żywności (Koszt: 10 wiary). |
| **E** | Cud: Trzęsienie ziemi | Obniża poziomy terenu w promieniu 5 kafelków wokół myszy (Koszt: 20 wiary). |
| **L** | Cud: Piorun (Lightning) | Raży wyładowaniem, zabijając wrogich osadników i wypalając lasy (Koszt: 15 wiary). |
| **B** | Cud: Błogosławieństwo | Błyskawicznie powołuje na świat 1-3 nowych wiernych przy ich domach (Koszt: 5 wiary). |
| **W** | Stawianie Muru (Wall) | Stawia nieprzebytą barykadę kamienną na wskazanym kafelku (Koszt: 5 wiary). |
| **1** | Prędkość 1x | Ustawia symulację na prędkość normalną (1x speed multiplier). |
| **2** | Prędkość 2x | Przyspiesza bieg czasu dwukrotnie (2x speed multiplier). |
| **3** | Prędkość 3x | Przyspiesza bieg czasu trzykrotnie (3x speed multiplier). |
| **Esc** | Wyjście | Zamyka bezpiecznie aplikację. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Populous (1989) by Peter Molyneux / Bullfrog Productions**
  - *Opis powiązania*: Bezpośredni przodek i absolutna inspiracja. God Game przenosi cały rdzeń rozgrywki: podnoszenie i obniżanie terenu w celu płaskiego wyrównania pod budowę domów, zbieranie many/wiary od wyznawców, automatyczna ekspansja domków oraz niszczenie wrogiego bóstwa i jego podwładnych.
- **Black & White (2001) by Bullfrog / Lionhead Studios**
  - *Opis powiązania*: Obecność spichlerza z żywnością podtrzymującego życie plemienia, konieczność dbania o zasoby leśne oraz cud deszczu ratujący gospodarkę rolniczą.
- **SimCity (Klasyki)**
  - *Opis powiązania*: Poczucie pełnego terraformowania krainy, w której gracz wpływa na warunki naturalne (tworzenie wysp, odcinanie kanałów wodnych, sypanie gór), by stworzyć optymalny układ pod zabudowę.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

God Game to fenomenalny popis technologiczny Lurek2D pod kątem interakcji, rzeźbienia i dynamicznej fizyki:
- `lurek.input` – Kompleksowe pobieranie stanów myszy w czasie rzeczywistym (`lurek.input.isActionDown` dla lewego i prawego przycisku) w celu natychmiastowego rzeźbienia terenu w pętli update, oraz rejestracja skrótów klawiatury dla cudów.
- `lurek.render` – Generowanie dynamicznie cieniowanych kafelków wyspy, płynnych obwódek zaznaczenia, rysowanie ikon budynków, murów, barwnych pasków wiary i interfejsu HUD za pomocą poleceń `rect`, `circ` i `ln`.
- `lurek.timer` – Kontrolowanie delta time symulacji z uwzględnieniem modyfikatorów czasu `game_speed` (1x, 2x, 3x) w celu natychmiastowego przyspieszenia cykli urodzeń i gromadzenia wiary.
- `lurek.event` – Wykrywanie klawisza Esc do płynnego i bezpiecznego zamknięcia aplikacji.
- **Dynamiczny System Tweenów:** Wykorzystywany do niezwykle płynnego, wielokolorowego łagodzenia (Color Tweening) zmian terenu. Po zmianie wysokości kafelka jego kolor łagodnie interpoluje do nowej barwy w czasie 0.3s, dając piękny, organiczny efekt plastyczny.
- **Wielokanałowy System Cząsteczek (Dynamic Miracle Particles):**
  - *Krople Deszczu (Rain)*: Jasnoniebieski deszcz pionowo opadających cząsteczek nad całym ekranem.
  - *Pył Trzęsienia (Earthquake)*: Ciężkie, brązowo-szare drobiny ziemi wyrzucane w powietrze z punktu uderzenia.
  - *Błyskawica (Lightning)*: Żółto-białe, chaotyczne cząsteczki eksplodujące w punkcie uderzenia pioruna.
  - *Złote Błogosławieństwo (Blessing)*: Złociste, unoszące się ku górze iskierki wiary otaczające rodzących się wyznawców.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Najlepszy dowód na to, jak wydajny jest silnik Lurek2D w dynamicznych obliczeniach na siatce grid. Wykazuje idealną płynność przy dynamicznym interpolowaniu kolorów 660 kafelków (Color Lerping), koordynacji ponad 50 poruszających się autonomicznie jednostek AI (wyszukiwanie optymalnych tras na podstawie preferencji terenu) oraz jednoczesnej obsłudze 4 dynamicznych emiterów cząsteczek.
- **Unikalność (Uniqueness):** Jedyna gra z gatunku symulatorów bóstwa w bibliotece. Oferuje unikalną mechanikę teraformowania (terraforming) jako podstawy rozgrywki — gracz bezpośrednio przekształca siatkę krainy, wpływając na zachowanie i przeżywalność jednostek, co czyni ją technologicznym majstersztykiem.
- **Podobne gry (Similar Games):** Gra ekonomicznie przypomina `colony_sim`, ale różni się od niej czynną, bezpośrednią walką plemienną z frakcją wrogów (Rival AI) oraz pełną swobodą rzeźbienia wysokości kafelków planszy.
