# Asteroids

_Przetrwaj w pasie asteroid, manewrując statkiem kosmicznym z fizyką bezwładności dryfu i niszcząc kosmiczne skały w neonowej estetyce retro._

## 🎮 O grze (About the Game)

W **Asteroids** wcielasz się w pilota statku kosmicznego uwięzionego w niebezpiecznym, zapętlającym się pasie asteroid. Gra charakteryzuje się zaawansowaną fizyką poruszania się – Twój statek ma bezwładność, co oznacza, że po włączeniu silnika dryfuje w przestrzeni, a spowalnianie wymaga odpowiedniego obracania i kontrowania ciągu. 

Głównym celem gry jest przetrwanie i zdobycie jak najwyższego wyniku poprzez rozbijanie nadlatujących asteroid za pomocą działka laserowego. Większe asteroidy po trafieniu rozpadają się na dwie średnie, te z kolei na mniejsze, a najmniejsze ulegają całkowitej destrukcji. Każda kolejna fala przynosi więcej wyzwań i szybsze tempo. Gra oferuje dynamiczne efekty cząsteczkowe wybuchów, uroczy neonowy styl wektorowy oraz zaawansowane owijanie ekranu (screen wrapping) – wylatując za dowolną krawędź ekranu, natychmiast pojawiasz się po jej przeciwnej stronie.

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę na silniku Lurek, wykonaj poniższe polecenie w terminalu:

```powershell
cargo run -- content/games/arcade/asteroids
```

## 🕹️ Sterowanie (Controls)

Gra korzysta ze zmapowanych akcji wejściowych silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **←** | Obrót w lewo | Obraca dziób statku przeciwnie do wskazówek zegara |
| **D** / **→** | Obrót w prawo | Obraca dziób statku zgodnie ze wskazówkami zegara |
| **W** / **↑** | Ciąg silnika (Thrust) | Dodaje przyspieszenie w kierunku, w którym jest zwrócony statek |
| **Spacja** | Strzał (Fire) | Wystrzeliwuje pocisk laserowy (maksymalnie 4 aktywne pociski na ekranie) |
| **R** | Restart | Restartuje grę po przegranej (utracie wszystkich 3 żyć) |
| **Escape** | Wyjście | Natychmiastowe zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Asteroids (1979) autorstwa Atari**
  - *Opis powiązania*: Gra jest bezpośrednim, wiernym hołdem dla kultowego automatu z 1979 roku stworzonego przez Lyle'a Rainsa i Eda Logga. Nasza wersja perfekcyjnie oddaje fizykę poślizgu (momentum & drag), podział asteroid po trafieniach na mniejsze części oraz charakterystyczną, czarnobiałą grafikę wektorową. Wzbogaciliśmy ją o nowoczesne rozszerzenia, takie jak płynne efekty cząsteczkowe wylotu z silnika odrzutowego, precyzyjne animacje interfejsu (pop-upy wyników z tweenami) oraz system fal trudności.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra stanowi doskonały poligon doświadczalny dla podstawowych i zaawansowanych modułów silnika Lurek:

- `lurek.camera` – Ustawia stałą rozdzielczość wirtualną viewportu 800×600 niezależnie od rozmiaru okna fizycznego, dbając o retro proporcje ekranu.
- `lurek.render` – Rysuje dynamiczne linie, wielokąty statku, okręgi asteroid oraz interfejs graficzny w czasie rzeczywistym.
- `lurek.input` – Obsługuje sterowanie oparte o akcje (Action Mapping) zamiast surowych klawiszy, co ułatwia ewentualną zmianę mapowania.
- `lurek.particle` – Odpowiada za iskry wybuchów przy rozbijaniu asteroid oraz ogon płomieni ciągnący się za statkiem przy uruchomionym ciągu.
- `lurek.tween` – Odpowiada za płynne animacje zanikania i unoszenia się punktów (+25, +50, +100) wyświetlanych na ekranie w miejscu zniszczenia asteroidy.
- `lurek.timer` – Śledzi czas klatek (Delta Time) do fizyki poruszania się, a także mierzy FPS oraz czas niewrażliwości statku po odrodzeniu (blinking invincibility).
- `lurek.window` – Dynamicznie kontroluje tytuł okna gry oraz jego podstawowe parametry.
- `lurek.event` – Zapewnia czyste i bezpieczne zamknięcie aplikacji w reakcji na zdarzenie wyjścia.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: Pokazuje, jak Lurek radzi sobie z precyzyjną fizyką ruchu opartej o wektory i siły ciągnące (momentum, friction/drag) w czystym Lua bez używania pełnego silnika fizyki Rapier2D. Prezentuje również doskonałe, płynne działanie wbudowanych emiterów cząsteczkowych (`lurek.particle`) i interpolacji (`lurek.tween`).
- **Unikalność**: Wyróżnia się spośród innych gier zastosowaniem **grafiki czysto wektorowej/liniowej** zamiast rastrowych sprajtów. Wykorzystuje również zaawansowane owijanie świata gry (screen wrapping), które wymaga precyzyjnego pozycjonowania i rysowania duplikowanego wzdłuż krawędzi ekranu w celu uniknięcia "odcinania" grafiki.
- **Podobne gry**: *Space Invaders*, *Galaga* (pod kątem kosmicznej strzelanki), jednak *Asteroids* to jedyna gra w kolekcji z pełną swobodą ruchu 360 stopni oraz dryfem bezwładnościowym.
