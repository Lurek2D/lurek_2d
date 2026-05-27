# Tetris

_Klasyczna zręcznościowa gra logiczna — dopasowuj i układaj spadające klocki Tetromino, planuj ruchy z podglądem cienia (ghost preview), wymieniaj klocki w kieszeni (Hold) i wywołuj spektakularne czyszczenie linii._

## 🎮 O grze (About the Game)

W **Tetris** Twoim celem jest układanie spadających geometrycznych klocków (Tetromino) na planszy o wymiarach 10×20 pól w taki sposób, aby tworzyć pełne poziome linie. Ukończenie linii powoduje jej usunięcie, nagrodzenie punktami oraz zwolnienie miejsca na kolejne klocki. Im więcej linii usuniesz jednocześnie (1, 2, 3 lub maksymalnie 4 – tzw. "Tetris"), tym większy mnożnik punktowy otrzymujesz (100 / 300 / 500 / 800 pomnożone przez aktualny poziom gry).

Każde oczyszczone 10 linii zwiększa poziom gry oraz szybkość opadania klocków, podnosząc presję czasu. Gra posiada zaawansowane mechaniki znane z nowoczesnych wersji gry:
- **Kieszeń Hold (Hold Piece)** – pozwala na schowanie aktualnie spadającego klocka za pomocą klawisza C i użycie go w dogodniejszym momencie (maksymalnie jedna wymiana na zrzut).
- **Cień klocka (Ghost Preview)** – wyświetla półprzezroczysty zarys na samym dole planszy, precyzyjnie pokazując, gdzie wyląduje klocek przy szybkim zrzucie.
- **Dynamiczne efekty (Juice & Polish)** – usunięcie linii wywołuje silny wstrząs ekranu (screen shake), rozbłysk światła oraz deszcz kolorowych iskier (particles).

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/arcade/tetris
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o zaawansowane mapowanie akcji wejściowych silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **←** | Ruch w lewo | Przesunięcie klocka o jedną kolumnę w lewo |
| **D** / **→** | Ruch w prawo | Przesunięcie klocka o jedną kolumnę w prawo |
| **W** / **↑** | Obrót | Obraca klocek o 90 stopni zgodnie z ruchem wskazówek zegara |
| **S** / **↓** (przytrzymanie) | Miękki zrzut (Soft Drop) | Przyspiesza opadanie klocka |
| **Spacja** | Twardy zrzut (Hard Drop) | Błyskawicznie zrzuca klocek na sam dół i go blokuje |
| **C** | Hold (Kieszeń) | Zapisuje klocek lub zamienia go z klockiem w kieszeni |
| **Enter** | Start | Uruchomienie gry z poziomu ekranu tytułowego |
| **R** | Restart | Restart gry po przegranej (gdy klocki zablokują szczyt planszy) |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Tetris (1984) stworzony przez Aleksieja Pażytnowa**
  - *Opis powiązania*: Gra jest hołdem dla najpopularniejszej gry logicznej wszech czasów. Nasza implementacja w Lurek2D łączy klasyczną mechanikę wymyśloną przez radzieckiego programistę z nowoczesnymi standardami turniejowymi (Tetris Guideline), takimi jak obecność strefy Hold, precyzyjny podgląd cienia klocka na dnie planszy (Ghost Piece) oraz generator losowy zapobiegający długim seriom tych samych klocków. Wykorzystanie wstrząsów ekranu i rozbłysków podczas usuwania linii dodaje grze niezwykle satysfakcjonującego, współczesnego charakteru typu "game juice".

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra stanowi kompleksowy pokaz zaawansowanych technik manipulowania siatką i sprzężenia zwrotnego z graczem:

- `lurek.camera` – Służy do centrowania planszy, a także do wywoływania efektów dynamicznego trzęsienia ekranu (`camera.setOffset`) na bazie Delta Time.
- `lurek.render` – Rysuje precyzyjny grid planszy, kolorowe klocki z obrysem, półprzezroczysty cień klocka (25% alpha), panel boczny z następnym klockiem (Next) i schowanym (Hold), oraz teksty interfejsu (render_ui).
- `lurek.input` – Odpowiada za precyzyjne odczytywanie akcji rotacji i zrzutów, w tym rozróżnienie pojedynczego naciśnięcia od trzymania (soft vs hard drop).
- `lurek.tween` – Kontroluje płynne wygaszanie wstrząsów ekranu oraz jasny rozbłysk planszy przy udanym Tetrisie.
- `lurek.particle` – Generuje widowiskowy deszcz iskier rozchodzący się wzdłuż usuwanych wierszy planszy.
- `lurek.timer` – Mierzy precyzyjnie czas opadania klocka na sekundy (Gravity), obsługuje animacje wstrząsów oraz wyświetla FPS.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i poprawnym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: Tetris to majstersztyk pokazujący zaawansowane **sprzężenie zwrotne z graczem (game feel / juice)** – wstrząsy kamery i rozbłyski ekranu zrealizowane całkowicie w Lua przy użyciu interpolacji matematycznych (`lurek.tween`). Pokazuje również zaawansowaną dwuwymiarową detekcję kolizji macierzowych (obrócenie klocka wymaga sprawdzenia, czy nowe koordynaty nie nachodzą na ściany lub inne klocki).
- **Unikalność**: Jedyna gra w sekcji Arcade łącząca **dynamiczne modyfikowanie właściwości kamery (screen shake)** z rozbudowanym logicznym planowaniem (Hold slot i Ghost preview).
- **Podobne gry**: Brak innych gier logicznych o zbliżonej charakterystyce spadających i obracanych klocków.
