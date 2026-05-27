# Infiltration

_Top-down skradanka szpiegowska — przeniknij do ściśle strzeżonego kompleksu, unikaj obracających się kamer strażniczych, hakuj systemy i wykorzystuj gadżety taktyczne, by wykraść tajne dane._

## 🎮 O grze (About the Game)

W **Infiltration** wcielasz się w postać elitarnego szpiega infiltrującego tajną placówkę badawczą. Gra toczy się w rzucie z góry (top-down) na mapie o wymiarach 20×15 pól. Dysponujesz ściśle ograniczonym czasem 180 sekund, aby zlokalizować główny terminal danych, zhakować go i bezpiecznie ewakuować się przez portal wyjściowy.

Gra stawia na ciche planowanie i inteligentne korzystanie z gadżetów:
1. **Gadżety Taktyczne (Gadgets Inventory)**:
   - **Karta Dostępu (Keycard)** [3 użycia] – błyskawicznie otwiera elektroniczne drzwi bezpieczeństwa.
   - **Impuls EMP** [2 użycia] – generuje impuls elektromagnetyczny, który unieruchamia wszystkie kamery w placówce na 8 sekund.
   - **Wytrych (Lockpick)** [3 użycia] – służy do cichego otwierania tradycyjnych zamków mechanicznych.
2. **Kamery i Stożki Wzroku (Cameras Vision Cones)**:
   - Obrotowe kamery bezpieczeństwa nieprzerwanie skanują korytarze, rzucając **widoczny stożek światła (vision cone)**. Wejście w pole widzenia kamery natychmiast uruchamia system alarmowy.
3. **Dynamiczny System Alarmu (Alert Level System)**:
   - Wskaźnik alarmu rośnie od 0 do 100%, kiedy jesteś wykryty. Przebywanie w ukryciu powoduje powolny spadek alarmu. Wysoki poziom alarmu blokuje niektóre przejścia, a osiągnięcie 100% oznacza natychmiastowe uwięzienie i porażkę misji.
4. **Minigra Hakerska (Hack Mini-game)**:
   - Zhakowanie niektórych drzwi i terminala danych wymaga przejścia zręcznościowo-logicznej minigry polegającej na łączeniu przewodów (wire-matching sequence) poprzez wciskanie odpowiednich klawiszy numerycznych w wyznaczonej kolejności.

Dla zaawansowanych graczy dostępny jest cel poboczny: włamanie do skarbca (Vault) poprzez użycie wszystkich trzech typów gadżetów na przyległych polach.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/infiltration
```

## 🕹️ Sterowanie (Controls)

Sterowanie łączy poruszanie się po siatce korytarzy z obsługą ekwipunku gadżetów i interakcją z systemami.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W, A, S, D** / **Strzałki** | Ruch agenta | Przemieszczanie się po siatce korytarzy placówki |
| **1** | Użyj Karty Dostępu | Otwiera drzwi magnetyczne (na sąsiednim polu) |
| **2** | Użyj EMP | Wyłącza kamery bezpieczeństwa w placówce na 8 sekund |
| **3** | Użyj Wytrychu | Otwiera zablokowane drzwi mechaniczne |
| **E** | Interakcja (Hack) | Zhakowanie terminala danych / rozpoczęcie minigry hakerskiej |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Metal Gear Solid (1998) firmy Konami** oraz **klasyki stealth typu Splinter Cell / Monaco**
  - *Opis powiązania*: Gra to niezwykle przemyślany hołd dla korzeni gatunku skradanek taktycznych (stealth action). Nasza wersja Lurek2D w pełni replikuje fundamentalne mechaniki: **dynamiczne stożki wzroku kamer (rotating vision cones)** wyliczane trygonometrycznie, wskaźnik alarmu (Alert Level System) bezpośrednio wpływający na zachowanie otoczenia (blokowanie drzwi przy wysokim zagrożeniu) oraz korzystanie ze specjalistycznego sprzętu szpiegowskiego. Hacking w postaci minigry łączenia kabli unowocześnia rozgrywkę, dodając presji czasu.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra reprezentuje wysoki poziom logiki interakcji i prezentuje zaawansowane stożki światła 2D:

- `lurek.render` – Rysuje kafelkową mapę bazy, postać agenta, drzwi o różnych stanach otwarcia, dynamicznie **obracające się i cieniowane stożki wzroku kamer (colored vision cones)**, fale radiowe EMP oraz rozbudowany panel hakerski i wskaźniki HUD.
- `lurek.input` – Obsługuje ruch po siatce gridowej, precyzyjne odczytywanie klawiszy ekwipunku (1-3) oraz klawiszy numerycznych podczas minigry.
- `lurek.particle` – Generuje niebieskie wyładowania elektryczne przy użyciu EMP (wyłączającym kamery), zielone iskry przy udanym hacku oraz czerwone błyski alarmowe.
- `lurek.tween` – Animuje rozwijanie się minigry hakerskiej, pulsowanie wskaźnika czasu oraz płynne wysuwanie komunikatów tekstowych.
- `lurek.timer` – Odmierza 180 sekund limitu czasu misji, 8 sekund paraliżu kamer po EMP oraz płynnie zarządza Delta Time obrotu kamer.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: Wybitny pokaz **trygonometrii stożków pola widzenia (field of view / vision cone calculation)** – dynamiczne wyliczanie wielokąta światła kamery obracającego się w czasie z precyzyjną detekcją kolizji Line-Of-Sight z agentem. Prezentuje również doskonałe wdrożenie **ekwipunku gadżetów (inventory management)** oraz logiki wbudowanych minigier (nested mini-games).
- **Unikalność**: Jedyna gra skradankowa (stealth puzzle) w kolekcji oferująca **mechanikę unikania dynamicznych stref wzroku (vision cones)**, wskaźniki hałasu/alarmu oraz taktyczne zarządzanie zużywalnym ekwipunkiem.
- **Podobne gry**: *Dyna Blaster* (labirynt kafelkowy), ale *Infiltration* wyróżnia się brakiem walki bezpośredniej – kluczem jest pozostawanie w cieniu, hakowanie systemów i ucieczka, a nie eliminacja przeciwników.
