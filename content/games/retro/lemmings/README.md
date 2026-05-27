# Lemmings

_Ratuj bezmyślne stworki przed zagładą — przypisuj im zadania (budowanie, kopanie, blokowanie) i modyfikuj w pełni zniszczalny teren, aby bezpiecznie przeprowadzić je do wyjścia._

## 🎮 O grze (About the Game)

W **Lemmings** (hołd dla absolutnego klasyka z 1991 roku) przejmujesz kontrolę nad grupą 12 bezradnych stworzeń (Lemingów), które pojawiają się z klapy w suficie i bezmyślnie maszerują przed siebie. Ignorują one niebezpieczeństwa, bezwzględnie spadając w przepaście lub wpadając w pułapki, o ile nie wydasz im odpowiednich poleceń.

Twoim celem jest uratowanie wymaganej liczby lemingów (minimum 8 z 12) poprzez przypisywanie im specjalnych zadań, które pozwalają przekształcać otoczenie i kierować ruchem grupy:
- **Blocker (Klawisz 1)** – leming zatrzymuje się w miejscu i działa jak twarda ściana, zmuszając inne maszerujące lemingi do zawrócenia.
- **Digger (Klawisz 2)** – zaczyna kopać pionowo w dół, przebijając się przez zniszczalny grunt.
- **Builder (Klawisz 3)** – buduje skośne schody w górę (dokładnie 8 stopni), umożliwiając pokonanie pionowych ścian lub przepaści.
- **Basher (Klawisz 4)** – kopie w poziomie w kierunku, w którym maszeruje, wycinając tunele w ścianach.

Gra oferuje **w pełni zniszczalny teren (fully destructible terrain)** – kopacze fizycznie wycinają piksele z mapy gry, co na bieżąco modyfikuje ścieżki poruszania się postaci. Kampania składa się z trzech zróżnicowanych poziomów z unikalnym ukształtowaniem terenu i limitowaną pulą zadań do przypisania.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/retro/lemmings
```

## 🕹️ Sterowanie (Controls)

Sterowanie łączy precyzyjną obsługę myszy z klawiszami numerycznymi.

| Klawisz / Wejście | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **Mysz (Hover)** | Celowanie | Nakierowanie kursora nad leminga, któremu chcesz przydzielić zadanie |
| **1** | Przypisz Blockera | Zamienia leminga w stacjonarną barierę (blokadę) |
| **2** | Przypisz Diggera | Leming zaczyna kopać pionowo w dół |
| **3** | Przypisz Buildera | Leming buduje 8-stopniowe schody skośne w górę |
| **4** | Przypisz Bashera | Leming kopie poziomy tunel w gruncie |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Lemmings (1991) stworzony przez DMA Design (późniejsze Rockstar North) i wydany przez Psygnosis**
  - *Opis powiązania*: Gra jest niezwykle zaawansowanym hołdem dla jednego z największych hitów logicznych w historii gier wideo. Nasza wersja Lurek2D odtwarza kluczową innowację oryginału – **w pełni zniszczalną geometrię świata (destructible terrain)**, w której Diggerzy i Basherzy fizycznie "rzeźbią" w masce kolizyjnej poziomu w czasie rzeczywistym. Gra implementuje cztery najważniejsze role lemingów, fizykę grawitacji (w tym śmiertelność przy upadku z dużych wysokości) oraz dynamiczny panel HUD informujący o liczbie pozostałych lemingów i stanie zasobów.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra reprezentuje zaawansowane techniki detekcji kolizji na poziomie maski bitowej oraz interakcję z myszą:

- `lurek.render` – Rysuje zniszczalny grunt jaskini, klapę wejściową, portal wyjściowy, dynamiczny HUD, kursor myszy oraz poszczególne klatki animacji lemingów (chodzenie, kopanie, budowanie schodów).
- `lurek.input` – Przechwytuje pozycję kursora myszy (`input.getMousePosition`) w celu precyzyjnej selekcji małych, dynamicznych jednostek oraz mapuje klawisze numeryczne do ról.
- `lurek.particle` – Generuje odłamki ziemi (debris) sypiące się spod kilofów kopaczy oraz radosne rozbłyski przy dotarciu leminga do wyjścia.
- `lurek.tween` – Animuje wskaźniki HUD, płynne otwieranie się klapy startowej oraz napisy zwycięstwa.
- `lurek.timer` – Odmierza 2-sekundowe interwały wypuszczania lemingów z wejścia oraz kontroluje czas animacji.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i poprawnym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To unikalny w skali całego repozytorium pokaz **dynamicznie niszczalnej maski kolizyjnej (destructible collision mask)** oraz zaawansowanej **selekcji jednostek myszką (raycast/hover pixel selection)**. Pokazuje, jak w Lua modyfikować i sprawdzać kolizje bezpośrednio na dynamicznie rysowanej masce bitowej (bitmap collision), a nie tylko na sztywnej siatce kafelków czy prostokątach AABB.
- **Unikalność**: Jedyna gra w całej kolekcji Lureka z **pełnym niszczeniem podłoża przez aktywne jednostki** i budowaniem trwałej geometrii (schody) modyfikującej pathfinding innych stworzeń.
- **Podobne gry**: *Worms Artillery* (kategoria Strategy - niszczenie terenu eksplozjami), ale *Lemmings* to gra czysto logiczno-zarządcza czasu rzeczywistego (lemmings-routing puzzle), skupiona na ratowaniu jednostek, a nie ich wzajemnej eliminacji.
