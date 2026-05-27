# Pac-Man

_Przemierzaj labirynt, zjadaj kropki, unikaj czterech duchów o unikalnych osobowościach sztucznej inteligencji i poluj na nich po zjedzeniu Super-Pigułki._

## 🎮 O grze (About the Game)

W **Pac-Man** wcielasz się w postać żółtego, pożerającego kropki bohatera uwięzionego w klasycznym labiryncie o wymiarach 28×31 pól. Twoim celem jest oczyszczenie planszy z 240 małych kropek (10 pkt każda) oraz 4 dużych **Super-Pigułek (Power Pellets)** (50 pkt każda). 

Rozgrywkę utrudniają cztery duchy, z których każdy posiada w pełni zaimplementowaną, **oryginalną sztuczną inteligencję o odmiennych osobowościach**:
- **Blinky (Czerwony)** – najbardziej agresywny duch; bezpośrednio ściga Pac-Mana, obierając za cel jego aktualną pozycję.
- **Pinky (Różowy)** – stara się zastawić zasadzkę; celuje w pozycję znajdującą się 4 pola przed kierunkiem, w którym aktualnie porusza się Pac-Man.
- **Inky (Turkusowy)** – najbardziej nieprzewidywalny; jego algorytm celowania bazuje na pozycji Blinky'ego oraz wektora wybiegającego 2 pola przed Pac-Mana.
- **Clyde (Pomarańczowy)** – tchórzliwy; ściga Pac-Mana, gdy jest daleko (powyżej 8 pól), ale gdy zbliży się zbytnio, wpada w panikę i ucieka do swojego domowego narożnika.

Duchy dynamicznie przełączają się pomiędzy dwoma trybami: **Pościgu (Chase)** oraz **Rozproszenia (Scatter)** (kiedy to wycofują się do swoich narożników) na bazie precyzyjnego zegara. Zjedzenie Super-Pigułki wprowadza duchy w stan **Przerażenia (Frightened)** na około 6 sekund – stają się niebieskie, uciekają i mogą zostać zjedzone przez Pac-Mana za rosnącą liczbę punktów (200 → 400 → 800 → 1600).
Plansza zawiera również charakterystyczne boczne tunele, które owijają pozycję gracza i duchów wokół ekranu.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/arcade/pac_man
```

## 🕹️ Sterowanie (Controls)

Sterowanie wykorzystuje zmapowane akcje kierunkowe silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W** / **↑** | Ruch w górę | Skręca Pac-Mana w górę przy najbliższym skrzyżowaniu |
| **S** / **↓** | Ruch w dół | Skręca Pac-Mana w dół przy najbliższym skrzyżowaniu |
| **A** / **←** | Ruch w lewo | Skręca Pac-Mana w lewo przy najbliższym skrzyżowaniu |
| **D** / **→** | Ruch w prawo | Skręca Pac-Mana w prawo przy najbliższym skrzyżowaniu |
| **Enter** | Start | Start gry z ekranu tytułowego |
| **R** | Restart | Restart rozgrywki po ekranie porażki |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Pac-Man (1980) stworzony przez Toru Iwatani dla firmy Namco**
  - *Opis powiązania*: Gra jest niezwykle zaawansowaną i szczegółową rekonstrukcją jednego z najważniejszych tytułów w historii branży gier wideo. Nasza wersja w Lurek2D nie ogranicza się do losowego poruszania wrogów, ale wiernie odtwarza **oryginalne algorytmy sztucznej inteligencji duchów** (Blinky, Pinky, Inky, Clyde) opisane przez Toru Iwatani. Replikuje również strefy Scatter/Chase, zachowanie bocznych tuneli spowalniających duchy oraz eskalację punktową przy pożeraniu przestraszonych wrogów. Unowocześnieniem są cząsteczki rozbłysków przy zjadaniu kropek oraz płynne animacje pulsowania pigułek i wyskakujących punktów.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra kompleksowo testuje możliwości renderowania geometrycznego oraz algorytmów sztucznej inteligencji w Lurek2D:

- `lurek.camera` – Centruje widok na planszy labiryntu, zachowując kultowe proporcje arcade i dbając o ostrość pikseli.
- `lurek.render` – Generuje cały labirynt oparty na siatce kafli (grid), rysuje Pac-Mana (okrąg z dynamicznie wycinanym klinem ust w zależności od kierunku i czasu), duchy z ruchomymi źrenicami oczu oraz błyszczące Super-Pigułki.
- `lurek.input` – Odpowiada za dynamiczne kolejkowanie ruchów (gracz może nacisnąć klawisz skrętu wcześniej, a silnik wykona go automatycznie dopiero na najbliższym wolnym skrzyżowaniu, co replikuje płynność sterowania z oryginalnego automatu).
- `lurek.tween` – Obsługuje płynne pulsowanie dużych Super-Pigułek oraz animacje zanikania punktów.
- `lurek.particle` – Generuje efektowne żółte iskierki (sparkles) przy zjadaniu kropek oraz niebieskie eksplozje cząsteczkowe przy zjedzeniu ducha.
- `lurek.timer` – Kontroluje taktowanie stanów duchów (Scatter/Chase/Frightened) oraz czas trwania błysków ostrzegawczych przed końcem czasu przerażenia duchów.
- `lurek.window` & `lurek.event` – Cykl życia okna i zdarzenia systemowe.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To absolutnie najlepszy w całym repozytorium pokaz **zaawansowanej sztucznej inteligencji opartej o kafelkowy pathfinding (A* lub target-tile seek)** w środowisku o ograniczonej strukturze (labirynt). Doskonale ilustruje, jak tworzyć asymetryczną rozgrywkę PvE, w której wrogowie współpracują ze sobą poprzez różne cele logiczne.
- **Unikalność**: Jedyna gra w sekcji Arcade z **kolejkowaniem wejścia (input buffering/queuing)** gwarantującym absolutnie profesjonalny feeling sterowania w ciasnych korytarzach oraz kompletny zbiór asymetrycznych profili AI.
- **Podobne gry**: *Dyna Blaster* (poruszanie się w labiryncie kafelkowym), jednak *Pac-Man* charakteryzuje się ciągłym, dynamicznym ruchem bez zatrzymywania oraz znacznie bardziej zaawansowaną inteligencją przeciwników.
