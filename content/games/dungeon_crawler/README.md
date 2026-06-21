# Dungeon Crawler

_Eksploruj trójwymiarowe korytarze lochów z perspektywy pierwszej osoby (FPP) — przemierzaj labirynt przy świetle pochodni, odkrywaj mgłę wojny na minimapie i zbieraj mistyczne kule._

## 🎮 O grze (About the Game)

**Dungeon Crawler** to niezwykle zaawansowana technologicznie produkcja zrealizowana na silniku Lurek2D, nawiązująca do klasyków gatunku RPG z przełomu lat 80. i 90. Gra renderuje w pełni trójwymiarowy widok jaskiń i lochów z perspektywy pierwszej osoby (FPP) przy użyciu techniki **raycastingu (rzucania promieni) wbudowanej w akcelerowany sprzętowo potok GPU (`buildScene`)**.

Rozgrywka polega na eksploracji olbrzymiego labiryntu lochów o wymiarach 36×36 pól w poszukiwaniu 10 ukrytych, świecących kul (Orbs). Cechy gry:
- **Płynny ruch FPP** – ruch i obracanie odbywają się w sposób ciągły w czasie rzeczywistym na bazie Delta Time, w przeciwieństwie do klasycznego, skokowego ruchu kafelkowego.
- **Dynamiczne oświetlenie** – korytarze oświetlane są ruchomym światłem pochodni gracza (point lights) z precyzyjnym ściemnianiem wraz z odległością (distance dimming).
- **Zróżnicowane tekstury** – gra wykorzystuje 6 zewnętrznych tekstur PNG wczytywanych przez silnik do rysowania ścian, podłóg i sufitów z nadpisywaniem tekstur poszczególnych komórek (per-cell overrides).
- **Aktywna minimapa** – w rogu ekranu wyświetlana jest minimapa ze zintegrowaną mgłą wojny (fog of war), która odkrywa korytarze wyłącznie na podstawie rzeczywistego zasięgu wzroku gracza (FOV/raycast visibility traces).

Gra przechodzi w stan `COMPLETE` po pomyślnym zebraniu wszystkich 10 kul rozrzuconych w najdalszych zakątkach lochów.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/retro/dungeon_crawler
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparse o klasyczne obłożenie klawiatury dla gier trójwymiarowych typu FPS/RPG.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W** | Ruch w przód | Poruszanie się postacią do przodu w kierunku spojrzenia |
| **S** | Ruch w tył | Poruszanie się postacią do tyłu |
| **A** | Krok w lewo (Strafe) | Przemieszczanie się bokiem (strafe) w lewą stronę |
| **D** | Krok w prawo (Strafe) | Przemieszczanie się bokiem (strafe) w prawą stronę |
| **Q** | Obrót w lewo | Obracanie kamery w lewo (zmiana kąta spojrzenia) |
| **E** | Obrót w prawo | Obracanie kamery w prawo (zmiana kąta spojrzenia) |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Eye of the Beholder (1991) autorstwa Westwood Studios** oraz **Dungeon Master (1987) firmy FTL Games**
  - *Opis powiązania*: Gra jest hołdem dla kultowych, pierwszoosobowych gier RPG z siatką kafelkową i mroczną atmosferą. W przeciwieństwie do pierwowzorów, które oferowały wyłącznie skokowy ruch co 1 kafelek i obrót o 90 stopni, nasza wersja w Lurek2D wprowadza **płynne poruszanie się i płynną rotację kamery 360 stopni** w stylu wczesnego *Wolfenstein 3D*, zachowując przy tym głęboki, klaustrofobiczny klimat jaskiń, dynamiczne oświetlenie pochodnią, rzuty tekstur na ściany, podłogi i sufity oraz interaktywną minimapę LOS (Line of Sight) odkrywającą korytarze.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra reprezentuje szczyt możliwości optymalizacyjnych i technologicznych 2D-raycastera silnika Lurek:

- `lurek.raycaster` (potok `buildScene`) – Sprzętowo akcelerowany moduł raycastingowy w GPU, generujący trójwymiarowy rzut korytarzy z precyzyjnym mapowaniem tekstur i cieniowaniem odległościowym.
- `lurek.raycaster.revealCellsFromRays` – Zaawansowane API silnika wykonujące analizę widoczności i automatycznie aktualizujące mgłę wojny na mapie na podstawie rzucanych promieni.
- `lurek.raycaster.buildMinimapWindow` – Generuje zoptymalizowaną, dostosowaną do Line-of-Sight minimapę z płynnym oświetleniem odkrytych pól.
- `lurek.render` – Rysuje dwuwymiarowy interfejs HUD nałożony na widok 3D, minimapę, znaczniki zebranych kul oraz teksty podsumowania.
- `lurek.input` – Obsługuje jednoczesny ruch i rotację za pomocą zmapowanych akcji (Strafe i Turn).
- `lurek.timer` – Kontroluje odczyt Delta Time dla płynnego poruszania się oraz obsługuje migotanie światła pochodni na bazie sinusoidy czasu.
- `lurek.window` & `lurek.event` – Cykl życia okna i bezpieczne zamknięcie.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To najbardziej zaawansowany technologicznie pokaz **silnika raycastingowego 3D (raycaster showcase)** działającego wewnątrz silnika zoptymalizowanego pod kątem 2D. Dowodzi potęgi optymalizacji Lurek2D, wykonując setki rzutów promieni, teksturowanie ścian i sufitów oraz obliczenia LOS (Line of Sight) w pełnych 60 klatkach na sekundę przy minimalnym obciążeniu procesora.
- **Unikalność**: Jedyna gra w całej kolekcji oferująca **perspektywę pierwszej osoby (FPP 3D view)** oraz sprzętowo wspomagane teksturowanie trójwymiarowe, co czyni ją bezkonkurencyjną wizytówką technologiczną silnika Lurek.
- **Podobne gry**: *Raycaster FPS* (również raycaster), ale *Dungeon Crawler* skupia się na eksploracji lochów, mrocznym klimacie RPG i zbieraniu artefaktów pod osłoną mgły wojny, zamiast na szybkiej wymianie ognia z przeciwnikami.
