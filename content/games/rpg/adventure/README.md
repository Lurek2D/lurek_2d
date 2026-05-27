# Point-and-Click Adventure — The Lost Egg

_Klasyczna gra przygodowa typu Point-and-Click — eksploruj połączone komnaty, rozmawiaj z maszyna piszącą dialogi, zbieraj przedmioty i łącz je ze sobą, by rozwiązać starożytne zagadki i odnaleźć Złote Jajo._

## 🎮 O grze (About the Game)

**The Lost Egg** to nastrojowa, klasyczna gra przygodowo-narracyjna (Point-and-Click Adventure) zrealizowana na silniku Lurek2D, nawiązująca bezpośrednio do legendarnego stylu dawnych produkcji z komputerów PC i Amiga. Wcielasz się w postać poszukiwacza przygód badającego tajemniczą posiadłość złożoną z **5 połączonych ze sobą lokacji** (Sypialnia, Korytarz, Kuchnia, Ogród oraz Strych).

Cechy i zaawansowane mechaniki gry:
- **Hotspoty (Interactive Hotspots)** – każde pomieszczenie skrywa interaktywne punkty (meble, drzewa, ukryte przejścia). Możesz przełączać się między nimi klawiszem **Tab** i badać je klawiszem **E**.
- **System Ekwipunku i Łączenia (Inventory & Combine)** – zbieraj kluczowe przedmioty (klucz, latarka, nóż, lina, złote jajo). Otwierając ekran ekwipunku, możesz **łączyć przedmioty w locie** w celu tworzenia nowych narzędzi (np. *nóż + lina = hak wspinaczkowy*).
- **Maszyna Pisząca (Typewriter Dialogs)** – wszystkie teksty narracyjne i opisy przedmiotów wyświetlane są za pomocą klimatycznej animacji maszyny do pisania (taktowanie liter co 0.03s).
- **Kompletny Łańcuch Zagadek (Puzzle Chain)**:
  *Znajdź klucz → otwórz szufladę → zdobądź latarkę → oświetl strych → znajdź nóż i linę → połącz w hak wspinaczkowy → wdrap się na drzewo → zdobądź Złote Jajo → umieść jajo na piedestale → wygraj grę.*

Każda lokacja posiada dedykowaną, nastrojową paletę kolorystyczną budującą unikalny klimat.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/rpg/adventure
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o zmapowane akcje eksploracji i interakcji z przedmiotami.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W, A, S, D** / **Strzałki** | Ruch między pokojami | Przejście przez wyznaczone krawędzie drzwi do sąsiedniej lokacji |
| **Tab** | Przełącz Hotspot | Przełączanie aktywnego interaktywnego punktu w pokoju |
| **E** | Zbadaj / Interakcja | Zbadanie aktywnego punktu / przewijanie dialogów narracji |
| **U** | Użyj przedmiotu | Użycie wybranego przedmiotu z ekwipunku na aktywnym obiekcie |
| **C** | Ekwipunek / Łączenie | Otwiera plecak z przedmiotami i pozwala na ich łączenie |
| **Escape** | Zamknij menu / Wyjście | Zamknięcie ekwipunku lub wyjście z aplikacji |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Gry przygodowe LucasArts (Maniac Mansion, Monkey Island) oraz klasyki Sierra On-Line (King's Quest)**
  - *Opis powiązania*: Gra to kompletny, czuły hołd dla złotego wieku gier przygodowych. Wersja Lurek2D precyzyjnie rekonstruuje **dwuwymiarowy silnik przygodowy (adventure-logic state engine)**: logiczną sieć pokojów z przejściami kierunkowymi, system hotspotów z podświetleniem (bounding box highlights), rozbudowany inwentarz z mechaniką rzemiosła (crafting/combining items) oraz nastrojową, literowaną narrację. Klimatyczne zmiany barw pokojów, cząsteczki kurzu oświetlane latarką w ciemnym strychu oraz tweeny tekstu oddają niezrównany urok wczesnych lat 90.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra jest świetnym pokazem elastyczności silnika w tworzeniu gier logiczno-narracyjnych o bogatym interfejsie:

- `lurek.camera` – Statycznie kadruje pokoje, a także snapuje przy przechodzeniu do kolejnych lokacji.
- `lurek.render` – Generuje stylowe, retro-geometryczne pokoje (łóżko, szuflady, strych z promieniami światła, drzewo z koroną, piedestał), postać gracza, dynamiczne podświetlenia hotspotów.
- `lurek.render_ui` – Rysuje rozbudowany panel dialogowy (dialog box) na dole, okno ekwipunku (inventory layout) z ikonami przedmiotów oraz menu łączenia przedmiotów.
- `lurek.input` – Obsługuje precyzyjnie kolejkowanie klawiszy akcji (Tab i Enter).
- `lurek.particle` – Generuje błyszczące iskierki przy zbieraniu przedmiotów, rozbłyski przy rozwiązaniu zagadki oraz unoszący się kurz oświetlany latarką na strychu.
- `lurek.tween` – Kontroluje płynne unoszenie się tekstu podnoszonych przedmiotów (+flashlight, +rope), cieniowanie dialogów oraz przejścia menu.
- `lurek.timer` – Odmierza Delta Time, steruje taktowaniem liter maszyny piszącej (co 0.03s) oraz czasem wyświetlania opisów.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To jedyny w całym repozytorium pokaz **silnika przygodowego Point-and-Click (adventure narrative-logic engine)**. Doskonale ilustruje, jak zaprojektować system **interakcji z otoczeniem (hotspot mapping)**, dynamiczne łączenie struktur w tablicy Lua (crafting recipe logic) oraz klimatyczny rendering tekstu maszyny piszącej (character typewriter generator).
- **Unikalność**: Jedyna gra przygodowo-logiczna w sekcji RPG oferująca **system zbierania i łączenia przedmiotów (item combining)** oraz dialogi typu typewriter.
- **Podobne gry**: *Dungeon Crawler*, *Roguelite* (widok z góry/FPP), ale *Adventure* całkowicie rezygnuje z elementów zręcznościowej walki na rzecz powolnej eksploracji, rozwiązywania zagadek środowiskowych i bogatej narracji tekstowej.
