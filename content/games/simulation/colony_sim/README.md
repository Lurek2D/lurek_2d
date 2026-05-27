# 🚀 Colony Sim — Colony Management & Survival Sandbox

**Category:** Simulation  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Colony Sim** to minimalistyczna, lecz niezwykle wciągająca strategiczna gra symulacyjna czasu rzeczywistego (RTS/Colony Manager), inspirowana klasykami takimi jak *RimWorld*, *Settlers* oraz *Banished*. Jako zarządca rodzącej się kolonii musisz poprowadzić grupę pionierów do stworzenia samowystarczalnej osady na nieprzyjaznej, generowanej proceduralnie mapie. Przydzielaj zadania osadnikom, zarządzaj zasobami (drewno, kamień, żywność), wznoś budynki mieszkalne, produkcyjne i militarne, kontroluj tempo gry, a przede wszystkim odpieraj najazdy łupieżców, dbając o to, by koloniści nie pomarli z głodu. Cel jest prosty: rozwiń populację do 20 mieszkańców!

### Pętla Rozgrywki i Mechaniki
1. **Proceduralna Mapa:** Świat składa się z siatki kafelków (25x18) z czterema typami terenu: żyzna trawa (T_GRASS), woda (T_WATER), skały (T_ROCK) i las (T_FOREST).
2. **Dynamiczne Cykle Produkcyjne:** Co 10 sekund (regulowane czasem gry) następuje faza podsumowania:
   - **Głód i Konsumpcja:** Każdy osadnik zjada 1 jednostkę żywności. Jeśli jedzenia zabraknie, koloniści zaczynają umierać z głodu!
   - **Produkcja:** Farmy produkują żywność, kopalnie wydobywają kamień, a drwale zbierają drewno z lasów.
3. **Zarządzanie Pracą:** Kliknij na dowolnego kolonistę i naciśnij klawisz, aby przypisać mu zawód:
   - **Builder (B) - Budowniczy:** Wznosi zaplanowane budynki.
   - **Farmer (F) - Rolnik:** Generuje dodatkowe punkty jedzenia w cyklu z farm.
   - **Miner (M) - Górnik:** Wydobywa kamień z kopalni.
   - **Guard (G) - Strażnik:** Broni kolonii przed najeźdźcami.
   - **Idle (I) - Wolny/Bezrobotny:** Odpoczywa, kręcąc się po osadzie.
4. **Rozbudowa Osady:** Zbieraj surowce, by stawiać kluczowe obiekty:
   - **House (H) - Dom:** Koszt: 10 drewna. Zwiększa limit populacji (+2).
   - **Farm (A) - Farma:** Koszt: 5 drewna. Zwiększa produkcję jedzenia o 2 na cykl.
   - **Mine (N) - Kopalnia:** Koszt: 5 drewna, 5 kamienia. Daje +3 kamienia na cykl.
   - **Barracks (K) - Koszary:** Koszt: 15 drewna, 10 kamienia. Zwiększa limit strażników (+1).
5. **Cykliczne Najazdy (Raids):** Co 60 sekund następuje atak łupieżców. Jeśli masz wystarczająco strażników (Guard), odeprzesz atak. Jeśli nie — łupieżcy zabiją bezbronnych osadników i zniszczą część surowców.
6. **Modyfikatory Prędkości:** Kontroluj czas dzięki trzystopniowemu przyspieszeniu rozgrywki (1x, 2x, 4x), optymalizując czas oczekiwania na cykle.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Colony Sim** is a minimalist yet deeply engaging real-time colony management simulation inspired by beloved strategy titles like *RimWorld*, *Settlers*, and *Banished*. As the overseer of a budding frontier colony, you guide a group of pioneers to establish a self-sustaining settlement on a procedurally generated grid map. Assign specialist jobs to colonists, manage core stockpiles (wood, stone, food), construct residential and industrial infrastructures, speed up or slow down time, and defend against relentless raiders while avoiding widespread starvation. Your ultimate milestone: expand and sustain a thriving population of 20 colonists!

### Gameplay Loop & Mechanics
1. **Procedural Grid Map:** The environment features a 25x18 tilemap composed of fertile grass (T_GRASS), water blockades (T_WATER), mineral rocks (T_ROCK), and dense timber forests (T_FOREST).
2. **Economic Cycles:** Every 10 seconds, a colony-wide evaluation occurs:
   - **Consumption & Famine:** Every active colonist consumes 1 unit of food. If your stockpiles empty, colonists suffer starvation and will begin to die off!
   - **Yields:** Active farms yield food, mines extract stone, and builders generate structures.
3. **Colonist Job System:** Click on any colonist to select them, then press the designated key to assign their profession:
   - **Builder (B):** Commits to constructing designated blueprints.
   - **Farmer (F):** Tends to crops, yielding 2 food per farm during cycles.
   - **Miner (M):** Works the quarries, generating 3 stone per mine during cycles.
   - **Guard (G):** Stations as defensive military, protecting citizens during hostile raids.
   - **Idle (I):** Free wanderer, consuming food without contributing specialized labor.
4. **Infrastructure Blueprints:** Gather resources to deploy structures anywhere on the map:
   - **House (H):** Costs 10 wood. Extends maximum population limit (+2 colonists).
   - **Farm (A):** Costs 5 wood. Yields +2 food per cycle.
   - **Mine (N):** Costs 5 wood, 5 stone. Yields +3 stone per cycle.
   - **Barracks (K):** Costs 15 wood, 10 stone. Extends guard capacity (+1).
5. **Periodic Raider Outbreaks:** Hostile raiders invade every 60 seconds. Having active Guards proportional to the raid pressure neutralizes the threat. Otherwise, raiders pillage resources and murder defenceless citizens.
6. **Time Warp Dials:** Shift gears between 1x, 2x, and 4x speed multipliers to fast-forward through resource accumulation phases.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/simulation/colony_sim
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB (Lewy Klik)** | Wybór kolonistów / Budowa | Kliknij na osadnika, by go wybrać, lub kliknij na siatkę w trybie budowy, by postawić budynek. |
| **B** | Zmień pracę na Budowniczego | Przypisuje wybranemu osadnikowi rolę Budowniczego (**Builder**). |
| **F** | Zmień pracę na Rolnika | Przypisuje wybranemu osadnikowi rolę Rolnika (**Farmer**). |
| **M** | Zmień pracę na Górnika | Przypisuje wybranemu osadnikowi rolę Górnika (**Miner**). |
| **G** | Zmień pracę na Strażnika | Przypisuje wybranemu osadnikowi rolę Strażnika (**Guard**). |
| **I** | Zmień pracę na Bezrobotnego | Zwalnia osadnika z zadań, czyniąc go wolnym strzelcem (**Idle**). |
| **H** | Tryb budowy: Dom | Wybiera budynek mieszkalny (**House**) do wybudowania (Koszt: 10 drewna). |
| **A** | Tryb budowy: Farma | Wybiera budynek rolniczy (**Farm**) do wybudowania (Koszt: 5 drewna). |
| **N** | Tryb budowy: Kopalnia | Wybiera kopalnię (**Mine**) do wybudowania (Koszt: 5 drewna, 5 kamienia). |
| **K** | Tryb budowy: Koszary | Wybiera garnizon (**Barracks**) do wybudowania (Koszt: 15 drewna, 10 kamienia). |
| **1** | Prędkość 1x | Ustawia prędkość gry na normalną (1x speed multiplier). |
| **2** | Prędkość 2x | Przyspiesza grę dwukrotnie (2x speed multiplier). |
| **3** | Prędkość 4x | Przyspiesza grę czterokrotnie (4x speed multiplier). |
| **Esc** | Wyjście | Zamyka bezpiecznie aplikację. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **RimWorld (2018) / Dwarf Fortress**
  - *Opis powiązania*: Gra bezpośrednio adaptuje rdzeń symulatorów kolonii — dynamiczny podział ról, priorytetyzację zadań osadników, mechanikę spożywania żywności i katastrofalne eventy w postaci zewnętrznych najazdów. Zamiast skomplikowanych łańcuchów produkcyjnych, Colony Sim upraszcza pętlę do formy czytelnej planszy RTS z natychmiastowym przydziałem ról.
- **Banished (2014) by Shining Rock Software**
  - *Opis powiązania*: Konieczność wyważenia tempa wzrostu populacji (domy zwiększają limit osadników) z możliwościami rolniczymi kolonii (Farms). Zbyt szybka ekspansja mieszkalna bez odpowiedniej liczby farmerów nieuchronnie prowadzi do klęski głodu i wymarcia populacji.
- **The Settlers (Seria) by Blue Byte**
  - *Opis powiązania*: Wizualny podział kolorystyczny profesji osadników (żółty budowniczy, zielony rolnik, niebieski górnik, czerwony strażnik) oraz wznoszenie budynków poprzez przydzielanie drewna i kamienia na planszy opartej na siatce kafelków.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje elastyczność i wszechstronność silnika Lurek2D w obsługiwaniu gier o charakterze symulacyjnym i strategicznym:
- `lurek.input` – Obsługa kliknięć myszką w celu zaznaczania osadników, pobieranie pozycji kursora w czasie rzeczywistym (`lurek.input.mouse.getPosition()`) do pozycjonowania budynków, oraz mapowanie akcji klawiatury dla ról osadników i trybów budowy.
- `lurek.timer` – Wykorzystywany do precyzyjnego odmierzania czasu delta (`dt`), sterowania prędkością symulacji za pomocą modyfikatora `speed_mult`, a także do pobierania statystyk wydajności (`lurek.timer.getFPS()`).
- `lurek.render` – Generowanie dynamicznych kształtów wektorowych (`rect` dla kafelków mapy, budynków i pasków postępu; `circ` dla ciał osadników, obwódek zaznaczenia i cząsteczek) oraz renderowanie tekstowe etykiet ról i wielokolorowego interfejsu HUD.
- `lurek.event` – Wywołanie natychmiastowego i czystego zamknięcia okna gry (`lurek.event.quit()`).
- **Logika Tweeningu** – Płynna interpolacja przyrostu i spadku pasków zasobów w interfejsie HUD, eliminująca skokowe wartości na rzecz miękkich przejść.
- **System Cząsteczek (Particles)** – Symulacja unoszących się iskier budowy podczas wznoszenia budynków, chmurek pyłu przy wydobyciu surowców oraz czerwonych błysków ostrzegawczych w czasie napaści łupieżców.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Niezwykle ważny dowód na to, że silnik Lurek2D doskonale nadaje się nie tylko do prostych gier zręcznościowych (Arcade), ale potrafi zarządzać złożonymi systemami ekonomicznymi i czasowymi. Pokazuje wydajne dynamiczne rysowanie siatki 25x18 kafelków oraz płynne kontrolowanie czasu gry za pomocą mnożników prędkości bez utraty stabilności klatek.
- **Unikalność (Uniqueness):** W odróżnieniu od większości zręcznościówek w portfolio, *Colony Sim* kładzie nacisk na interakcję z myszką (Point & Click), zarządzanie czasem i zbalansowaną gospodarkę surowcową. Gra nie polega na szybkim refleksie, lecz na planowaniu przestrzennym i strategicznym przypisywaniu specjalizacji.
- **Podobne gry (Similar Games):** Gra wykazuje podobieństwo do `survival_crafting` pod kątem zbierania surowców i obrony przed potworami, ale różni się brakiem bezpośrednio sterowanego bohatera. Gracz jest tutaj niewidzialnym zarządcą ("Bogiem"), kierującym grupą autonomicznych podwładnych, co upodabnia ją również częściowo do `settlers_rise` czy `province_economy_demo`.
