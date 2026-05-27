# 🌾 Farming Sim — Stardew-Lite Agricultural Sandbox

**Category:** Simulation  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Farming Sim** to urocza, relaksująca gra rolnicza i ekonomiczna (Stardew-lite) zrealizowana na siatce kafelków, która idealnie demonstruje możliwości obsługi stanów, cząsteczek i cykli czasowych w silniku Lurek2D. Jako ambitny rolnik przejmujesz kontrolę nad zaniedbanym polem uprawnym z celem wygenerowania fortuny o wartości 200 sztuk złota. Korzystaj z narzędzi, by orać glebę, siać różnorodne rośliny (pszenicę, marchew, pomidory), dbać o regularne nawadnianie w celu przyspieszenia wzrostu, obserwować cykle dnia i nocy oraz dynamiczne zjawiska pogodowe (deszcz), a następnie zbierać plony sierpem i handlować nimi na lokalnym rynku. 

### Pętla Rozgrywki i Mechaniki
1. **Zarządzanie Polem (Grid Map):** Gospodarstwo to siatka o rozmiarze 12x8 kafelków. Każdy kafelek posiada własny, niezależnie aktualizowany mikrosystem:
   - **Soil Tilling (Orka):** Użyj motyki (**Hoe**), aby spulchnić suchą ziemię.
   - **Planting (Siew):** Użyj torby nasiennej (**Seeds**), by zasadzić zboże, marchew lub pomidora na zaoranej glebie.
   - **Watering (Nawadnianie):** Podlej grządkę konewką (**Water Can**), aby **skrócić czas wzrostu rośliny o połowę**!
   - **Harvesting (Zbiory):** Gdy roślina dojrzeje i zmieni barwę na złotą, zbierz plony za pomocą sierpa (**Sickle**).
2. **Cykl Dnia i Nocy oraz Pogoda:**
   - Każda doba trwa 120 sekund (60s dzień, 60s noc). Noc charakteryzuje się nastrojowym niebieskim ściemnieniem ekranu.
   - **Uprawy rosną wyłącznie w dzień!**
   - O świcie istnieje 20% szans na wystąpienie **Deszczu (Rain)**. Deszcz automatycznie nawadnia wszystkie zasadzone rośliny na polu, oszczędzając czas rolnika.
3. **Katalog Upraw (Crops Directory):**
   - **Wheat (Pszenica):** Koszt nasion: 2g | Cena sprzedaży: 5g | Czas wzrostu: 15s (7.5s po podlaniu).
   - **Carrot (Marchewka):** Koszt nasion: 3g | Cena sprzedaży: 8g | Czas wzrostu: 10s (5s po podlaniu).
   - **Tomato (Pomidor):** Koszt nasion: 5g | Cena sprzedaży: 12g | Czas wzrostu: 20s (10s po podlaniu).
4. **Lokalny Rynek (Market - M):** Naciśnij klawisz **M**, aby otworzyć okno handlu. Możesz tu sprzedawać zebrane plony i kupować nowe nasiona. Poruszaj się klawiszami W/S, zatwierdzaj spacją, a wyjdziesz klawiszem Esc.
5. **Cel Finansowy:** Rozpoczynasz z 30 sztukami złota oraz kilkoma nasionami startowymi. Osiągnięcie poziomu **200 sztuk złota** kończy grę zwycięstwem.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Farming Sim** is a charming, relaxing grid-based agricultural and economic simulator (Stardew-lite) demonstrating state serialization, particle emission, and day/night cycles in the Lurek2D engine. As a passionate virtual farmer managing a 12x8 field grid, your goal is to grow and harvest crops to reach a financial milestone of 200 gold. Master your suite of agricultural tools to till barren soil, plant a variety of high-yield crops (wheat, carrots, tomatoes), water your plots to double their growth speed, watch day turn to night under cozy atmospheric lighting, let morning rainstorms irrigate your fields, and sell your organic goods at the local farmers' market!

### Gameplay Loop & Mechanics
1. **Field Grid Management:** The farm is structured on a 12x8 plot grid. Each tile tracks its own status:
   - **Soil Tilling:** Use the **Hoe** tool to turn dry earth into fertile soil.
   - **Sowing Seeds:** Use the **Seeds** tool to plant wheat, carrots, or tomatoes on tilled plots.
   - **Irrigation:** Hydrate plots with the **Water Can** to **cut the crop's remaining growth duration in half**!
   - **Reaping Plons:** Once crops mature into a beautiful golden hue, slice them using the **Sickle** to harvest.
2. **Day & Night Cycles & Weather:**
   - A full day lasts 120 seconds (60 seconds daytime, 60 seconds nighttime). Night shifts the screen into a cozy deep-blue atmospheric tint.
   - **Crops only grow during the daytime!**
   - At dawn, there is a 20% chance of a **Rainstorm**. Rain drops irrigate all crops in the field automatically, freeing up precious player time.
3. **Crop Directory:**
   - **Wheat:** Seeds cost 2g | Sells for 5g | Grow time: 15s (7.5s if watered).
   - **Carrot:** Seeds cost 3g | Sells for 8g | Grow time: 10s (5s if watered).
   - **Tomato:** Seeds cost 5g | Sells for 12g | Grow time: 20s (10s if watered).
4. **The Town Market (M):** Press the **M** key to toggle the dark-mode market overlay. Buy seed packets or sell harvested stock. Select items with W/S, commit trades with Space, and close the interface using Escape.
5. **Winning Threshold:** Start with 30 gold coins and a few basic seeds. Accumulating **200 gold** unlocks agricultural victory.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/simulation/farming_sim
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **W, A, S, D** | Poruszanie postacią | Sterowanie niebieską ramką gracza po siatce gospodarstwa. |
| **Space (Spacja)** | Użyj narzędzia / Interakcja | Wykonuje akcję narzędzia na grządce (Orka, Siew, Podlewanie, Zbiór plonów). |
| **1** | Narzędzie: Motyka (Hoe) | Wybiera motykę. Służy do spulchniania ziemi (PLOT_EMPTY → PLOT_TILLED). |
| **2** | Narzędzie: Nasiona (Seeds) | Wybiera siewnik. Służy do sadzenia wybranej rośliny na zaoranej glebie. |
| **3** | Narzędzie: Konewka (Water) | Wybiera konewkę. Nawadnia roślinę, podwajając tempo jej wzrostu. |
| **4** | Narzędzie: Sierp (Sickle) | Wybiera sierp. Służy do zbioru gotowych do plonowania upraw (PLOT_READY). |
| **Q** | Wybór nasion: Pszenica | Ustawia pszenicę (**Wheat**) jako aktywny typ nasion. |
| **E** | Wybór nasion: Marchewka | Ustawia marchewkę (**Carrot**) jako aktywny typ nasion. |
| **R** | Wybór nasion: Pomidor | Ustawia pomidora (**Tomato**) jako aktywny typ nasion. |
| **M** | Otwórz/Zamknij Rynek | Włącza i wyłącza nakładkę handlową rynku (Market). |
| **Esc** | Powrót / Wyjście | Zamyka okno rynku lub zamyka całkowicie grę. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Harvest Moon (1996) / Story of Seasons**
  - *Opis powiązania*: Bezpośrednie odwzorowanie cyklu farmerskiego: orka motyką, siew z woreczków, podlewanie z konewki i zbieranie sierpem. Gra świetnie oddaje ten ustrukturyzowany rytm pracy na roli.
- **Stardew Valley (2016) by ConcernedApe**
  - *Opis powiązania*: Estetyka przytulnego gospodarstwa, obecność wskaźników nawodnienia gleby, podział na uprawy o różnym czasie wzrostu i stopniu zyskowności oraz nastrojowa noc spowalniająca tempo pracy.
- **Animal Crossing by Nintendo**
  - *Opis powiązania*: Uroczy klimat, relaksująca muzyka w tle (reprezentowana przez sielski design) oraz ekonomiczna pętla gromadzenia złota ze sprzedaży surowców.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Farming Sim w niesamowity sposób łączy zaawansowane mechaniki Lurek2D:
- `lurek.input` – Mapowanie klawiatury (`lurek.input.bind`) obsługujące płynny ruch ramką gracza, cyfrowy wybór narzędzi (1-4) oraz szybkie klawisze nasion (Q/E/R).
- `lurek.camera` – Wdrożenie wirtualnej kamery 2D (`lurek.camera.new`) zapewniającej stabilny i wycentrowany rzut na pole uprawne.
- `lurek.render` – Generowanie dynamicznie skalowanych okręgów upraw (`circ`), siatki grządek (`rect` z obramowaniami typu `line`) oraz nastrojowego filtra nocnego i deszczowego (kolorowe filtry nakładane z wartością kanału alfa).
- `lurek.timer` – Odmierzanie precyzyjnych faz czasu delta do obliczania wzrostu roślin i zjawisk pogodowych.
- `lurek.event` – Wykrywanie klawisza Esc do zamykania gry lub menu handlu.
- **Zaawansowane Systemy Cząsteczek (Multiple Particle Systems):**
  - *Spryskiwanie Gleby (Harvest Sparks)*: Złoto-pomarańczowe drobinki tryskające wokół przy pomyślnym zbiorze dojrzałej rośliny.
  - *Siew i Pył (Plant Dust)*: Brązowe cząsteczki gleby uwalniane podczas orki i siewu nasion.
  - *Płynny Deszcz (Rain Particles)*: Strumień błękitnych, szybkich kropli opadających ukośnie na ekran podczas opadów atmosferycznych.
  - *Błysk Wzrostu (Growth Sparks)*: Jasnozielone iskierki wyrzucane w powietrze w momencie osiągnięcia dojrzałości przez uprawę.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Znakomita demonstracja działania niezależnych maszyn stanowych na siatce kafelków. Każda grządka ma unikalny stan uprawy i poziom nawodnienia, co udowadnia elastyczność struktur danych w skryptach Lua dla Lurek2D. Dodatkowo gra wspaniale łączy cztery niezależnie konfigurowane systemy cząsteczek działające jednocześnie bez spadków wydajności.
- **Unikalność (Uniqueness):** Jedna z niewielu gier kładąca nacisk na klimat "Cozy" (przytulny, powolny gameplay). Zamiast walki, gracz skupia się na relaksującej pętli planowania zasiewów, pielęgnowania roślin i handlu, co idealnie poszerza gatunkową różnorodność silnika.
- **Podobne gry (Similar Games):** Gra wykazuje zbieżności ekonomiczne i mechaniczne z `survival_crafting` oraz `colony_sim`, ale jest całkowicie pozbawiona aspektów walki, wrogów i zagrożenia, skupiając się w 100% na rolniczym pacyfizmie.
