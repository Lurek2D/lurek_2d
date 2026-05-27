# Platformer

_Precyzyjna platformówka kafelkowa 2D — pokonuj ruchome platformy, wykonuj ślizgi ścienne (wall slides) i wykorzystaj Coyote Time, by przetrwać pośród zdradzieckich kolców._

## 🎮 O grze (About the Game)

**Platformer** to zręcznościowa platformówka 2D stawiająca na niezwykle precyzyjne sterowanie, fizykę skoków i czułość ruchu. Twoim zadaniem jest dotarcie do flagi końcowej (Goal Flag) na każdym z trzech zróżnicowanych poziomów, omijając pułapki i przeciwników.

Gra zaimplementowała zaawansowane mechaniki ułatwiające i uatrakcyjniające ruch (game feel):
- **Czas Kojota (Coyote Time)** – krótki, 0.1-sekundowy bufor czasu po spadnięciu z krawędzi platformy, podczas którego silnik wciąż pozwala na wykonanie skoku. Zapobiega to frustracji przy minimalnym spóźnieniu reakcji.
- **Ślizg Ścienny (Wall Slide)** – przyciśnięcie kierunku ruchu w stronę pionowej ściany podczas opadania w powietrzu spowalnia opadanie bohatera, umożliwiając wykonywanie precyzyjnych i bezpiecznych lądowań w trudnym terenie.
- **Ruchome platformy** – poziome i pionowe pomosty poruszające się po stałych trajektoriach. Stanowią ruchome podłoże, z którego gracz może skakać.
- **Zagrożenia i Walka** – zbieraj złote monety (+100 pkt) oraz niszcz wędrujące owalne stworki poprzez naskakiwanie na nie z góry. Kontakt z kolcami (Spikes) oraz zderzenie z wrogiem z boku skutkuje utratą jednego z 3 żyć.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/platformer
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o responsywne akcje platformowe silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **←** | Ruch w lewo | Marsz bohatera w lewą stronę |
| **D** / **→** | Ruch w prawo | Marsz bohatera w prawą stronę |
| **W** / **↑** / **Spacja** | Skok (Jump) | Wykonanie wysokiego skoku (także podczas Coyote Time lub ślizgu ściennego) |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Super Mario Bros. (1985) firmy Nintendo** oraz **współczesne platformówki precyzyjne, jak Celeste**
  - *Opis powiązania*: Gra łączy nostalgiczne, kafelkowe fundamenty z lat 80. z nowoczesnymi technikami ułatwiania kontroli ruchu (tzw. "coyote time" i "wall slide") spopularyzowanymi przez współczesne hity niezależne, takie jak *Celeste*. Nasza wersja w Lurek2D doskonale realizuje **bezbłędne kolizje z kafelkową mapą (AABB tile collision matrix)**, stabilne poruszanie się po ruchomych platformach (moving platform physics) oraz interaktywne cząsteczki zniszczeń wroga i pyłu przy skokach.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra stanowi idealny pokaz nienagannej fizyki platformowej opartej o Delta Time i interaktywne cząsteczki:

- `lurek.camera` – Kamera dynamicznie śledzi pozycję gracza w dwóch osiach (X i Y), zachowując gładkie przejścia i wycentrowanie na bohaterze.
- `lurek.render` – Rysuje kafelkową strukturę poziomów (ściany, platformy, kolce), ruchome platformy, postać gracza (odkształcającą się plastycznie przy skoku), owalnych wrogów, monety oraz interfejs statystyk.
- `lurek.input` – Przechwytuje responsywne wejście platformowe.
- `lurek.particle` – Odpowiada za bogaty zestaw efektów: chmurki kurzu spod stóp przy wybiciu i lądowaniu (jump dust), złote rozbłyski monet (sparks) oraz pył zniszczenia wroga (stomp poof).
- `lurek.tween` – Kontroluje pulsowanie flagi wyjściowej oraz płynne animacje liczników HUD.
- `lurek.timer` – Precyzyjnie odmierza Delta Time do płynnych obliczeń prędkości grawitacji, czas Coyote Time (0.1 sekundy) oraz współczynniki ruchu wrogów.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To wzorcowy pokaz **funkcji poprawiających komfort ruchu (comfort-movement mechanics)** – Coyote Time i Wall Slide napisanych całkowicie w Lua. Ilustruje precyzyjną fizykę kolizji pionowych i poziomych oraz matematykę **ruchomych platform (moving platform offset mapping)**, na których gracz stoi i przemieszcza się synchronicznie z wektorem ruchu platformy.
- **Unikalność**: Jedyna gra w całej kolekcji posiadająca zaimplementowaną fizykę **Coyote Time** oraz **ślizgów ściennych (wall slide)**, co czyni ją technologicznym wzorcem dla platformówek precyzyjnych.
- **Podobne gry**: *Giana Sisters*, *Metroidvania* (również platformówki kafelkowe), ale *Platformer* wyróżnia się prostszą, bardziej liniową strukturą z silnym naciskiem na techniczne cechy skoków (Coyote Time/Wall Slide) oraz obecnością przemieszczających się fizycznie, ruchomych platform.
