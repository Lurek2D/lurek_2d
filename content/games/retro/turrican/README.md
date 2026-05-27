# Turrican

_Szybka, klasyczna platformowa strzelanka typu run-and-gun — kontroluj opancerzonego wojownika, korzystaj z dwubroniowego systemu bojowego i niszcz wrogie roboty w ufortyfikowanych bazach._

## 🎮 O grze (About the Game)

W **Turrican** (inspirowanym legendarnym arcydziełem Manfreda Trenza z 1990 roku na C-64 i Amigę) wcielasz się w postać opancerzonego żołnierza z przyszłości. Gra charakteryzuje się dynamiczną, zręcznościową wymianą ognia i wymagającą eksploracją trójpoziomowego, kafelkowego świata (scrolling tilemap world).

Twoim atutem jest zaawansowany **system uzbrojenia składający się z dwóch oddzielnych trybów prowadzenia ognia**:
1. **Szybki karabin plazmowy (F)** – podstawowy strzał pionierski. Zebranie czerwonego ulepszenia (Spread Shot power-up) ulepsza tę broń do potrójnego ognia rozproszonego (3-way spread shot).
2. **Obrotowy bicz laserowy (Energy Beam) (przytrzymanie G)** – wyzwala potężną wiązkę lasera, która zatacza ciągły łuk nad głową bohatera, niszcząc wszystko w zasięgu rażenia. Używanie bicza lasera zużywa zapasy amunicji.

Na Twojej drodze stoją zróżnicowani przeciwnicy:
- **Wędrowcy (Walkers)** – roboty patrolujące platformy (1 HP).
- **Latające drony (Flyers)** – latają torem sinusoidalnym i aktywnie ścigają gracza (2 HP).
- **Wieżyczki (Turrets)** – stacjonarne, opancerzone gniazda obronne strzelające precyzyjnie w kierunku gracza (3 HP).

Gracz musi mądrze zarządzać swoim zdrowiem (5 HP) oraz amunicją (100 jednostek), zbierając rozsiane na planszy diamentowe ulepszenia.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/retro/turrican
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o precyzyjne akcje platformowe i bojowe silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **D** | Ruch lewo / prawo | Bieg opancerzonym żołnierzem po metalowych platformach |
| **Spacja** / **W** | Skok (Jump) | Wykonanie skoku w celu pokonania przeszkód i przepaści |
| **F** | Strzał karabinowy | Prowadzenie szybkiego ognia zaporowego (lub trójdrożnego po ulepszeniu) |
| **G** (przytrzymanie) | Bicz laserowy (Energy Beam) | Uruchamia obracającą się wiązkę lasera (zużywa amunicję) |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Turrican (1990) zaprojektowany przez Manfreda Trenza dla Rainbow Arts**
  - *Opis powiązania*: Gra to kompletny i niezwykle satysfakcjonujący hołd dla jednej z najbardziej cenionych europejskich strzelanek platformowych. Nasza wersja Lurek2D rekonstruuje unikalny i rewolucyjny element oryginału – **ruchomą wiązkę lasera obracającą się wokół gracza (sweeping energy beam)** zrealizowaną w czystej wektorowości, system ulepszeń typu spread shot oraz klasyczną, dynamiczną fizykę platformową. Wzbogaciliśmy wersję o nowoczesne rozbłyski cząsteczkowe trafień pocisków, wstrząsy i flesze interfejsu (weapon switch flash) oraz czysty, estetyczny HUD ze wskaźnikami zdrowia i energii.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra kompleksowo demonstruje wydajność rysowania dwuwymiarowego oraz zaawansowaną trygonometrię wektorową:

- `lurek.camera` – Płynnie podąża horyzontalnie za pędzącym bohaterem, utrzymując dynamiczne pozycjonowanie pola walki w kadrze.
- `lurek.render` – Rysuje kafelkowe tła baz kosmicznych, wrogów z animacjami ruchu, postać gracza, smugi pocisków, obrotowy bicz laserowy (wyliczany z funkcji sinus/cosinus kąta obrotu) oraz nowoczesny interfejs HUD z paskami HP i amunicji.
- `lurek.input` – Przechwytuje responsywne wejście, obsługując równoległe bieganie, skakanie i ciągły ogień plazmowy bez konfliktów klawiszy.
- `lurek.particle` – Odpowiada za bogate efekty uderzeń pocisków (impact sparks), iskry kręcącego się lasera, pożary zniszczonych robotów oraz błyszczące aury ulepszeń.
- `lurek.tween` – Animuje wsuwanie się banerów ukończenia poziomu (level complete banner slide), pulsowanie punktów oraz efekty zmiany broni.
- `lurek.timer` – Mierzy Delta Time, kontroluje szybkostrzelność wrogów oraz częstotliwość obrotu lasera.
- `lurek.window` & `lurek.event` – Kontrolują konfigurację okna i bezpieczne wyjście.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To wybitny pokaz **zaawansowanej trygonometrii 2D (trigonometrical vector math)** wykorzystywanej do symulowania obrotowej wiązki lasera (`sin`/`cos` kąta zataczającego łuk wokół współrzędnych gracza z precyzyjną detekcją kolizji liniowej). Prezentuje również doskonałe wdrożenie mechaniki platformowej z progresją poziomów i dynamicznymi ulepszeniami broni.
- **Unikalność**: Jedyna gra platformowa z ** systemem obrotowego lasera wektorowego (sweeping energy beam)** oraz zaawansowanym zarządzaniem amunicją (ammo management), co tworzy unikalny balans taktyczny pomiędzy podstawowym strzałem a potężną bronią defensywną.
- **Podobne gry**: *Giana Sisters* (platformówka kafelkowa, ale bez strzelania i broni), *Cannon Fodder* (shooter, ale z widokiem z góry bez grawitacji). *Turrican* to jedyny tradycyjny przedstawiciel platformówek run-and-gun (w stylu Contra/Metal Slug) w tym zestawie.
