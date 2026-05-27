# 🏰 Tower Defense — Path Defense Sandbox

**Category:** Strategy / Tower Defense  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Tower Defense** to wciągająca, klasyczna gra strategiczna typu obrona wieżami (Tower Defense), nawiązująca do kultowych tytułów takich jak *Desktop Tower Defense* oraz seria *Kingdom Rush*. Zadaniem gracza jest obrona bazy przed falami wrogich najeźdźców, którzy maszerują wzdłuż wyznaczonej krętej ścieżki. Rozmieszczaj cztery wyspecjalizowane typy wież (podstawowa, szybkostrzelna, snajperska, obszarowa) na wolnych polach planszy, optymalizuj budżet i przetrwaj wszystkie 6 fal szturmowych. Gra doskonale prezentuje zaawansowane mechaniki detekcji kolizji, dynamiczną interpolację pocisków, wskaźniki zasięgu oraz systemy cząsteczek.

### Pętla Rozgrywki i Mechaniki
1. **Faza Budowania (Build Phase):**
   - Gra rozpoczyna się w trybie planowania. Gracz posiada 200 sztuk złota i 20 punktów życia (Lives).
   - Wybierz odpowiedni typ wieży (Tab/Q) i postaw ją za pomocą lewego przycisku myszy (LMB) na dowolnym wolnym zielonym kafelku (budowanie na ścieżce jest niedozwolone).
   - Naciśnij **Spację**, aby uruchomić falę wrogów i przejść do fazy walki.
2. **Katalog Wież Obronnych:**
   - **Basic (Podstawowa - $50):** 8 DMG, Zasięg 90px, prędkość 1.0/s. Zrównoważona wieża na start.
   - **Rapid (Szybka - $80):** 4 DMG, Zasięg 70px, prędkość 3.0/s. Świetna na szybkie, lekkie jednostki.
   - **Sniper (Snajper - $120):** 25 DMG, Zasięg 160px, prędkość 0.5/s. Zadaje potężne obrażenia z gigantycznego dystansu.
   - **Splash (Obszarowa - $150):** 12 DMG, Zasięg 80px (obszar wybuchu 60px), prędkość 0.8/s. Zadaje obrażenia wszystkim wrogom w promieniu eksplozji.
3. **Faza Walki i Przeciwnicy:**
   - Wrogowie wchodzą na planszę z lewej strony i podążają za wyznaczoną ścieżką w kierunku bazy (prawej strony).
   - Wieże automatycznie namierzają przeciwnika wysuniętego najdalej wzdłuż ścieżki i wystrzeliwują pociski z płynną interpolacją ruchu.
   - Każdy pokonany wróg zasila sakiewkę gracza złotem i daje punkty. Przedostanie się wroga poza krawędź planszy odbiera 1 punkt życia.
4. **Zwycięstwo i Bonusy:**
   - Przetrwaj wszystkie 6 fal o rosnącej trudności (HP wrogów rośnie z każdą falą).
   - Po każdej udanej fali otrzymujesz bonus finansowy w wysokości 30 sztuk złota, pozwalający na dalszą rozbudowę obrony.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Tower Defense** is a highly polished, classic path-based strategy game inspired by monumental genre titles like *Desktop Tower Defense* and the *Kingdom Rush* franchise. As commander of the outpost, you must safeguard your sector by tactically placing defense structures on a grid to stop marching columns of monsters. Deploy four specialized turret classes (Basic, Rapid, Sniper, and Splash Area-of-Effect) on non-path tiles, manage your gold reserves, and survive 6 scaling enemy waves. Featuring smooth projectile lerping, real-time target indexing, and vibrant impact particles, this project represents a masterclass in path-following logic and turret targeting loops!

### Gameplay Loop & Mechanics
1. **Planning Phase (Build Mode):**
   - The game begins in design mode. You start with 200 gold and 20 Lives.
   - Cycle through available turrets (Tab/Q) and place them with Left-Click (LMB) on green meadow tiles (placement on the gravel road is blocked).
   - Press **Space** to deploy the next wave and switch to combat mode.
2. **Defensive Turret Registry:**
   - **Basic ($50):** 8 DMG, 90px Range, 1.0 shots/sec. General-purpose defense.
   - **Rapid ($80):** 4 DMG, 70px Range, 3.0 shots/sec. Shreds fast, low-HP scout units.
   - **Sniper ($120):** 25 DMG, 160px Range, 0.5 shots/sec. High-velocity armor penetrator.
   - **Splash ($150):** 12 DMG, 80px Range (60px explosion radius), 0.8 shots/sec. Deals explosive area damage to clustered columns.
3. **Combat Phase & Path-Following Enemies:**
   - Monsters enter from the left, navigating the pre-calculated waypoint path towards your exit zone on the right.
   - Turrets automatically target the lead enemy furthest along the route, discharging linear projectiles that interpolate smoothly toward their target.
   - Defeating invaders yields gold bounties. Any leak through the boundary deducts 1 Life.
4. **Progression & Scoreboards:**
   - Defend your border successfully across 6 progressively tougher waves.
   - Clearing a wave yields a 30 gold budget bonus, allowing you to strengthen your line.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/tower_defense
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB (Klik)** | Postaw wieżę (Build Tower) | Buduje wybraną wieżę na wskazanym wolnym kafelku (jeśli posiadasz złoto). |
| **Tab** | Następna wieża (Next Type) | Przełącza wybór wieży na kolejny typ z katalogu. |
| **Q** | Poprzednia wieża (Prev Type) | Cofa wybór wieży na poprzedni typ z katalogu. |
| **Space (Spacja)** | Wyślij falę (Start Wave) | Kończy fazę budowy i wypuszcza kolejną falę wrogów na ścieżkę. |
| **Esc** | Wyjście (Quit) | Zamyka grę w bezpieczny sposób. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Desktop Tower Defense (2007) by Paul Preece**
  - *Opis powiązania*: Bezpośrednie źródło mechaniki: czysta siatka 2D, typy wież o ulepszanych właściwościach (od szybkich strzelców po ciężką artylerię), oraz konieczność odpierania fal wrogów wchodzących z lewej krawędzi.
- **Kingdom Rush by Ironhide Game Studio**
  - *Opis powiązania*: Koncepcja predefiniowanej krętej ścieżki z punktami orientacyjnymi (Waypoints), obok której gracz rozmieszcza strategiczne punkty obrony, oraz wizualne paski HP wrogów.
- **Bloons TD by Ninja Kiwi**
  - *Opis powiązania*: Wykorzystanie pocisków obszarowych (Splash) o określonym promieniu wybuchu oraz mechanika stopniowego przyspieszania wrogów wraz z postępem rund.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

- `lurek.input` – Obsługa zaznaczania pól myszą, wygodna rotacja typów wież za pomocą klawiszy Tab/Q oraz wyzwalanie fali spacją.
- `lurek.render` – Rysowanie planszy (ścieżki, wieże, wrogowie, pociski) za pomocą `rect` i `circ`. Wyświetlanie zaawansowanego HUD-u z poziomem złota, falą i życiem przy użyciu dynamicznych czcionek.
- `lurek.window` / `lurek.event` – Inicjalizacja stabilnej rozdzielczości 800x600 oraz czysta obsługa wyjścia przy Esc.
- **Aż Trzy Systemy Cząsteczek (Multiple Particle Systems):**
  - *Iskry trafienia (Hit Sparks)*: Pomarańczowo-żółty gejzer iskier wyzwalany w miejscu uderzenia pocisku we wroga.
  - *Rozbłysk zgonu (Death Burst)*: Ciemnoczerwony wybuch cząsteczek oznaczający eliminację potwora i przyznanie złota.
  - *Błysk budowy (Place Flash)*: Błękitny okrąg cząsteczkowy rozszerzający się wokół nowo postawionej wieży obronnej.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Doskonały pokaz algorytmów parametrycznych w Lua. Gra implementuje wyznaczanie pozycji świata na bazie procentowego postępu wzdłuż wielosegmentowej ścieżki łamanej (Waypoint path interpolation) oraz algorytm sortujący wrogów w celu wyłonienia optymalnego celu dla wieży.
- **Unikalność (Uniqueness):** Jedyna gra obronna z automatycznym celowaniem pocisków interpolujących w czasie rzeczywistym i predefiniowanym torem ruchu wrogich agentów.
- **Podobne gry (Similar Games):** Dzieli mechanikę obrony z `maze_defense`, jednak różni się od niej zastosowaniem predefiniowanej, stałej ścieżki najeźdźców, co upraszcza układ obronny i kładzie nacisk na dobór typów wież, a nie budowanie labiryntu.
