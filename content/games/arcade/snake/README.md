# Snake

_Zjadaj owoce, rośnij i unikaj własnego ogona — klasyczny wąż na kafelkowej siatce, wzbogacony o efekty cząsteczkowe i płynnie interpolowane animacje punktów._

## 🎮 O grze (About the Game)

W **Snake** sterujesz stale poruszającym się wężem po kafelkowej siatce o wymiarach 32×28 pól. Twoim głównym zadaniem jest zbieranie pojawiających się owoców. Na planszy zawsze znajdują się trzy owoce jednocześnie, co ułatwia planowanie ruchu. 

Każde zjedzenie owocu wydłuża wąż o jeden segment, zwiększa wynik punktowy oraz przyspiesza ruch węża (prędkość wzrasta z każdym zdobytym progiem 5 punktów, co drastycznie podnosi poziom trudności). Gra posiada mechanikę owijania planszy (screen wrapping) – wąż może bezkarnie przelatywać przez ściany ekranu, pojawiając się po drugiej stronie. Śmiertelnym zagrożeniem jest jednak kolizja z własnym, stale rosnącym ogonem.
Wersja ta oferuje rozbudowany HUD, dynamiczne śledzenie kierunku oczu węża oraz efekty cząsteczkowe.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/arcade/snake
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o akcje wejściowe silnika Lurek, z wbudowaną blokadą skrętu o 180 stopni (wąż nie może skręcić bezpośrednio w samego siebie).

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W** / **↑** | Skręt w górę | Kieruje węża w górę (zablokowane, gdy wąż płynie w dół) |
| **S** / **↓** | Skręt w dół | Kieruje węża w dół (zablokowane, gdy wąż płynie w górę) |
| **A** / **←** | Skręt w lewo | Kieruje węża w lewo (zablokowane, gdy wąż płynie w prawo) |
| **D** / **→** | Skręt w prawo | Kieruje węża w prawo (zablokowane, gdy wąż płynie w lewo) |
| **Enter** | Start / Restart | Uruchomienie gry lub restart po zderzeniu i śmierci |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Snake / Blockade (1976) opracowany przez Gremlin Industries** oraz **wersje z telefonów Nokia (1997)**
  - *Opis powiązania*: Gra bezpośrednio nawiązuje do korzeni gatunku zapoczątkowanego przez automat *Blockade* oraz spopularyzowanego na całym świecie dzięki kultowym telefonom komórkowym Nokia 6110 projektu Taneli Armanto. Wersja Lurek2D zachowuje esencję wciągającej rozgrywki gridowej, ale znacząco ją unowocześnia. Oprócz precyzyjnego sterowania akcjami wejściowymi, dodano unikalne kierunkowe oczy węża (zwracające się w stronę ruchu), wspaniały neonowy styl graficzny z renderingiem wielokątów, soczyste rozbłyski cząsteczek przy konsumpcji owoców oraz płynne animacje cyfr interfejsu (tween score counter).

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje wydajność i łatwość pisania gier kafelkowych w Lua na silniku Lurek:

- `lurek.camera` – Definiuje wirtualny viewport gry dla stabilnego skalowania siatki 32×28 kafelków.
- `lurek.render` – Rysuje kafelkowe tło, rosnące segmenty ciała węża z zaokrągloną głową i ruchomymi oczami, owoce oraz teksty interfejsu (podział render/render_ui).
- `lurek.input` – Obsługuje akcje ruchu i startu gry, filtrując wejście tak, aby zapobiec natychmiastowej samozagładzie przy naciśnięciu przeciwnego kierunku.
- `lurek.tween` – Realizuje płynny licznik punktów (zamiast natychmiastowej zmiany wartości, cyfry wyniku płynnie rosną, symulując obrót bębna retro licznika).
- `lurek.particle` – Tworzy kolorowy wybuch cząsteczek (burst effect) w komórce zjedzonego owocu.
- `lurek.timer` – Mierzy Delta Time oraz dynamicznie kontroluje interwały ruchu węża (ruch odbywa się co określony ułamek sekundy, malejący wraz ze wzrostem prędkości).
- `lurek.window` & `lurek.event` – Kontrolują konfigurację okna oraz wyjście z gry.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: Doskonały, elementarny przykład gry **gridowej opartej o tablicową strukturę danych (Snake Body Array)** w Lua. Pokazuje, jak w prosty sposób zarządzać tablicą pozycji jako kolejką (dodawanie nowej głowy na początku i usuwanie ogona na końcu, o ile wąż nie zjadł owocu). Pokazuje także świetne, płynne działanie mechaniki filtrowania wejścia.
- **Unikalność**: Jedyna gra w sekcji Arcade z ** dynamicznym śledzeniem wektora spojrzenia postaci (animowane oczy węża)**, trzema aktywnymi celami punktowymi na planszy jednocześnie oraz rosnącym tempem gry powiązanym z progiem punktowym.
- **Podobne gry**: *Centipede* (wąż/stonoga poruszająca się po gridzie), jednak *Snake* kładzie nacisk na unikanie kolizji z samym sobą i swobodny ruch w czterech kierunkach zamiast grawitacyjnego schodzenia w dół ekranu.
