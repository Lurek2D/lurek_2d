# Centipede

_Klasyczna zręcznościowa strzelanka retro — eliminuj wijącą się stonogę pośród grzybowego lasu, unikając niebezpiecznych pająków, pcheł i skorpionów._

## 🎮 O grze (About the Game)

W **Centipede** sterujesz małym statkiem (Bug Blasterem) w dolnej strefie ekranu, walcząc z nacierającymi falowo segmentami gigantycznej stonogi schodzącej pośród rosnących na planszy grzybów. Każde trafienie w segment stonogi powoduje jej podzielenie na dwa oddzielnie poruszające się stworzenia oraz pozostawia po sobie grzyb o wytrzymałości 4 punktów życia (HP).

Rozgrywkę urozmaicają i utrudniają trzej unikalni przeciwnicy o zróżnicowanych zachowaniach:
- **Pająk (Spider)** – porusza się zygzakiem w strefie gracza, starając się go zniszczyć. Nagroda za jego zestrzelenie zależy od bliskości (im bliżej gracza, tym więcej punktów: od 300 do 900).
- **Pchła (Flea)** – spada pionowo w dół, kiedy zagęszczenie grzybów w strefie gracza jest zbyt małe, generując po drodze nowe grzyby.
- **Skorpion (Scorpion)** – przemieszcza się poziomo w górnej części ekranu, zatruwając każdy napotkany grzyb. Jeśli stonoga dotknie zatrutego grzyba, wpada w szał i natychmiast schodzi pionowo na sam dół planszy.

Gracz ma 3 życia, a po każdej stracie życia plansza ulega regeneracji (uszkodzone grzyby wracają do pełnego zdrowia).

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/arcade/centipede
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o system akcji wejściowych silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **←** | Ruch w lewo | Przesuwa gracza w lewo w obrębie dolnej strefy |
| **D** / **→** | Ruch w prawo | Przesuwa gracza w prawo w obrębie dolnej strefy |
| **W** / **↑** | Ruch w górę | Pozwala na ruch w górę (ograniczony do strefy bezpieczeństwa) |
| **S** / **↓** | Ruch w dół | Pozwala na powrót w dół planszy |
| **Spacja** | Strzał (Fire) | Wystrzeliwuje pocisk pionowo w górę |
| **R** | Restart | Restartuje rozgrywkę po utracie wszystkich żyć |
| **Escape** | Wyjście | Natychmiastowe zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Centipede (1980) autorstwa Atari**
  - *Opis powiązania*: Gra stanowi wierną i niezwykle dynamiczną implementację legendarnego hitu z salonów gier stworzonego przez Donę Bailey i Eda Logga. Nasza implementacja w Lurek2D w pełni replikuje algorytm ruchu stonogi omijającej przeszkody, mechanikę podziału na niezależne łańcuchy, a także specyficzne wzorce zachowań przeciwników pobocznych (pająk, pchła, skorpion) wraz z ich oryginalną punktacją. Wzbogaciliśmy wersję o nowoczesne, wielokolorowe niszczenie grzybów (zmiana kolorystyki zielony → żółty → pomarańczowy → czerwony obrazująca stan zużycia) oraz neonowe cząsteczki eksplozji.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje elastyczność i wydajność silnika Lurek w symulowaniu wielu niezależnych obiektów na siatce gridowej:

- `lurek.render` – Używany do dynamicznego generowania sprajtów stonogi, grzybów, pająka oraz efektów interfejsu HUD w podziale na fazę renderowania gry i interfejsu (render/render_ui).
- `lurek.input` – Obsługuje precyzyjną, action-bound kontrolę ruchu wewnątrz wydzielonej, bezpiecznej dolnej strefy gracza.
- `lurek.particle` – Odpowiada za iskry przy rozbijaniu grzybów, zniszczeniu stonogi oraz eliminacji pająka.
- `lurek.tween` – Generuje płynną animację wyskakujących punktów (tzw. "score pops") przy likwidowaniu wrogów.
- `lurek.timer` – Mierzy Delta Time oraz kontroluje odliczanie do respawnu wrogów (częstotliwość pojawiania się skorpiona, pająka i pchły).
- `lurek.window` – Nadaje tytuł oknu gry i monitoruje jego wymiary.
- `lurek.event` – Wykrywa i przetwarza sygnał zamknięcia aplikacji (Escape).

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: Doskonały przykład gry typu **state-machine** z rozbudowaną sztuczną inteligencją wrogów (proste maszyny stanów pająka, pchły zrzucającej grzyby przy niskim zagęszczeniu oraz skorpiona zatruwającego grzyby). Pokazuje również zaawansowaną logikę łączenia i dzielenia list segmentów (linked-list logic w Lua) w czasie rzeczywistym przy podziale stonogi.
- **Unikalność**: Jedyna gra w sekcji Arcade z dynamicznie generowanym środowiskiem (mushroom field), które bezpośrednio wpływa na pathfinding i trajektorię ruchu wrogów (stonoga omija grzyby, a zatrute grzyby drastycznie zmieniają jej zachowanie).
- **Podobne gry**: *Space Invaders*, *Galaga* (pod kątem eliminacji celów z dołu ekranu), ale *Centipede* wyróżnia się dwuwymiarowym ruchem gracza (również w osi Y) oraz interaktywnym, zmiennym polem przeszkód.
