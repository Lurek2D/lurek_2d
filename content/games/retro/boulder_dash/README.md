# Boulder Dash

_Drąż tunele w podziemnej jaskini, zbieraj lśniące diamenty, unikaj lawin spadających głazów i znajdź wyjście przed upływem czasu._

## 🎮 O grze (About the Game)

W **Boulder Dash** (klon kultowego przeboju z 1984 roku) wcielasz się w postać jaskiniowego poszukiwacza przygód (Rockforda), eksplorującego podziemne labirynty o wymiarach 40×26 pól. Twoim zadaniem jest przekopywanie się przez ziemię w celu zbierania rozrzuconych diamentów. 

Jaskinia rządzi się surowymi prawami fizyki kafelkowej:
- **Ziemia (Earth)** – blokuje ruch głazów i diamentów. Drążenie (ruch gracza na pole ziemi) usuwa ją bezpowrotnie.
- **Głazy (Boulders) i Diamenty (Diamonds)** – podlegają grawitacji. Jeśli pod nimi znajduje się pusta przestrzeń, spadają w dół. Mogą również zsuwać się z zaokrąglonych krawędzi innych głazów i ścian, wywołując spektakularne reakcje łańcuchowe lawin.
- **Pchanie** – gracz może przepychać głazy w poziomie, o ile za głazem znajduje się puste pole.
- **Śmiertelne niebezpieczeństwo** – spadający głaz lub diament uderzający w gracza powoduje natychmiastową utratę życia.

Po zebraniu określonej dla danego poziomu liczby diamentów, na mapie aktywuje się pulsujący portal wyjściowy (Exit). Musisz do niego dotrzeć przed upływem czasu. Gra oferuje **trzy progresywne poziomy trudności z generowaniem proceduralnym**, co oznacza, że każda rozgrywka przynosi nowy układ jaskiń!

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/retro/boulder_dash
```

## 🕹️ Sterowanie (Controls)

Gra korzysta ze zmapowanych klawiszy kierunkowych silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **Strzałki** | Ruch gracza / Drążenie | Poruszanie Rockfordem w czterech kierunkach i usuwanie kafelków ziemi |
| **Strzałki** (w bok na głaz) | Pchanie głazu | Przepychanie głazu w lewo/prawo na sąsiednie wolne pole |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Boulder Dash (1984) stworzony przez Petera Liepę i Chrisa Graya dla First Star Software**
  - *Opis powiązania*: Gra jest niezwykle zaawansowaną rekonstrukcją jednego z najważniejszych przebojów 8-bitowych komputerów (Atari, Commodore 64, ZX Spectrum). Nasza wersja Lurek2D wiernie implementuje **unikalny, kafelkowy model fizyki fizykalnej** (sliding physics) – w tym specyficzne zsuwanie się głazów z innych obiektów i tworzenie lawin, co stanowiło o geniuszu oryginału. Nowością jest całkowicie **proceduralny generator jaskiń**, co daje nieskończoną regrywalność, oraz zaawansowane, neonowe efekty pulsowania aktywnego wyjścia i diamentów zrealizowane geometrycznie bez użycia rastrowych sprajtów.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje precyzyjną fizykę siatki gridowej i interaktywne animacje:

- `lurek.render` – Rysuje stylowe, retro-geometryczne reprezentacje jaskini (ziemne korytarze, betonowe ściany, cieniowane okrągłe głazy, błyszczące trójwymiarowo diamenty, animowaną postać gracza) z dynamicznym podziałem na warstwę gry i interfejs HUD.
- `lurek.input` – Przechwytuje responsywne wejście kierunkowe, dbając o płynne poruszanie się po siatce co 0.18 sekundy.
- `lurek.timer` – Kontroluje taktowanie fizyki spadania i zsuwania obiektów (cykl fizyczny oddzielony od szybkości renderowania grafiki), a także odmierza czas na ukończenie jaskini.
- `lurek.window` & `lurek.event` – Cykl życia okna i zdarzenia systemowe.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To kapitalny przykład **złożonej fizyki logicznej (custom grid-physics simulation)** zaimplementowanej w czystym Lua bez polegania na silnikach fizycznych w rodzaju Rapiera. Pokazuje, jak napisać deterministyczny system opadania i zsuwania się obiektów na siatce 2D z detekcją kolizji i reakcjami łańcuchowymi.
- **Unikalność**: Jedyna gra w sekcji Retro z **proceduralną generacją poziomów (procedural cave generator)**, która tworzy unikalny, grywalny labirynt przy każdym uruchomieniu, oraz jedyna z tak zaawansowaną fizyką grawitacji klocków.
- **Podobne gry**: *Dyna Blaster*, *Pac-Man* (poruszanie po siatce), ale *Boulder Dash* wyróżnia się obecnością dynamicznej, stale spadającej i zsuwającej się grawitacyjnie materii (głazy i diamenty).
