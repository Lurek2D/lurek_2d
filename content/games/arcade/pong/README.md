# Pong

_Absolutny klasyk gier wideo — zmierz się w pojedynku dwóch paletek, odbijaj przyspieszającą piłeczkę pod różnymi kątami i zdobądź 7 punktów, aby wygrać._

## 🎮 O grze (About the Game)

**Pong** to dwuosobowa symulacja tenisa stołowego, uznawana za jeden z fundamentów elektronicznej rozrywki. Gra oferuje lokalną rozgrywkę dla dwóch graczy kontrolujących paletki po lewej i prawej stronie ekranu. 

Piłka porusza się wewnątrz wirtualnego stołu, odbijając się od górnej i dolnej ściany. Zderzenie piłki z paletką powoduje jej stopniowe **przyspieszenie (velocity scaling)** przy każdym udanym odbiciu, co eskaluje tempo i stopień trudności. Kąt odbicia piłki nie jest stały – zależy od miejsca, w którym piłka trafi w paletkę (uderzenie bliżej krawędzi paletki nadaje piłce bardziej stromy kąt, co pozwala na taktyczne zagrania).
Zwycięża gracz, który jako pierwszy zdobędzie 7 punktów. Gra posiada dopracowany ekran tytułowy, dynamiczne efekty cząsteczkowe zderzeń oraz system wyskakujących powiadomień o zdobytych punktach.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/arcade/pong
```

## 🕹️ Sterowanie (Controls)

Gra oferuje zmapowane akcje klawiatury dla obydwu graczy na jednym ekranie.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W** / **S** | Gracz 1 (Lewa paletka) | Ruch paletki w górę / w dół |
| **↑** / **↓** | Gracz 2 (Prawa paletka) | Ruch paletki w górę / w dół |
| **Enter** | Start | Rozpoczęcie gry z ekranu tytułowego |
| **R** | Restart | Restart gry po wygranej jednego z graczy |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Pong (1972) stworzony przez Allana Alcorna dla firmy Atari**
  - *Opis powiązania*: Gra stanowi wierny i usprawniony hołd dla pierwszej komercyjnie udanej gry wideo w historii, wydanej pod okiem Nolana Bushnella. Nasza wersja w Lurek2D dokładnie odtwarza mechanikę fizyki odbicia zależnej od segmentu kolizji paletki (tzw. "paddle segment angling") oraz ciągłą akcelerację prędkości piłki. Została jednak znacznie ulepszona wizualnie: wprowadziliśmy płynne cząsteczki iskier sypiących się przy zderzeniu piłki z paletką, pulsujące napisy punktowe (score pop) oparte o interpolacje oraz czysty podział na warstwę gry (`lurek.render`) i interfejsu HUD (`lurek.render_ui`).

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra jest świetnym przykładem na to, jak za pomocą prostych kształtów geometrycznych i czystej fizyki kolizji AABB stworzyć angażującą rozgrywkę:

- `lurek.render` – Rysuje minimalistyczne prostokąty paletek, kwadratową retro piłeczkę, przerywaną linię siatki dzielącą stół oraz dynamiczne efekty kolizji w podziale na warstwę gry i interfejs HUD.
- `lurek.input` – Obsługuje jednoczesne wejście dla dwóch graczy (multiplayer kanapowy) bez konfliktów i opóźnień w odczycie klawiszy akcji.
- `lurek.particle` – Generuje efektowne rozbłyski iskier (sparks) w miejscu zderzenia piłki z paletką, dodając dynamizmu uderzeniom.
- `lurek.tween` – Animuje powiększanie i rozmywanie się cyfr punktacji (score pops) w momencie zdobycia bramki.
- `lurek.timer` – Mierzy Delta Time w celu zapewnienia równej prędkości ruchu paletek i piłki niezależnie od liczby klatek na sekundę (FPS).
- `lurek.window` & `lurek.event` – Kontrolują konfigurację okna oraz wyjście z gry.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: Pong to najlepszy, elementarny pokaz **lokalnego trybu wieloosobowego (couch co-op / versus)** oraz czystej, zoptymalizowanej **fizyki kolizji typu Box-to-Box (AABB)** z zaawansowaną kalkulacją kąta odbicia (vector reflection based on contact offset). Pokazuje jak za pomocą niespełna kilkuset linii kodu w Lua stworzyć kompletny, grywalny produkt.
- **Unikalność**: Jedyna gra w sekcji Arcade oferująca **pełnoprawny tryb versus dla dwóch żywych graczy na jednej klawiaturze**, reprezentująca czystą, surową mechanikę sportową pozbawioną losowości.
- **Podobne gry**: *Brick Breaker* (kategoria Action - odbijanie piłki paletką w celu niszczenia klocków), jednak *Pong* skupia się na rywalizacji dwuosobowej na przeciwległych stronach ekranu.
