# Another World

_Kinowa platformówka przygodowa inspirowana arcydziełem Erica Chahi — przemierzaj nieprzyjazną obcą planetę, manipuluj tarczami energetycznymi i walcz o przetrwanie, łącząc spryt z precyzją._

## 🎮 O grze (About the Game)

W **Another World** (hołd dla legendarnego hitu z 1991 roku) wcielasz się w postać młodego naukowca, który w wyniku nieudanego eksperymentu fizycznego zostaje przetransportowany do obcego, niebezpiecznego świata. Gra stawia na filmową atmosferę, minimalizm interfejsu oraz wyzwania środowiskowo-zręcznościowe.

Gra składa się z **5 połączonych ze sobą, przewijanych w bok scen (side-scrolling scenes)** tworzących spójny świat. Przeciwnikami są patrolujący obcy, którzy natychmiast otwierają ogień po wykryciu intruza.
Twoją jedyną bronią jest zaawansowany **pistolet plazmowy (energy gun) oferujący 3 tryby działania** w zależności od czasu przytrzymania klawisza strzału:
1. **Szybkie dotknięcie (F)** – wystrzeliwuje standardowy pocisk plazmowy, zdolny wyeliminować zwykłego wroga.
2. **Krótkie przytrzymanie (F)** – generuje stacjonarną tarczę energetyczną (shield wall), która blokuje wrogie pociski przez 2.5 sekundy.
3. **Długie przytrzymanie (F)** – ładuje niszczycielski super-strzał (super-shot), który potrafi rozbić wrogie tarcze energetyczne oraz zabić przeciwnika ukrywającego się za osłoną.

Gra posiada klimatyczne, kinowe intro z przewijanym tekstem fabularnym, system 3 żyć z punktami zapisu (checkpoints) w obrębie każdej sceny oraz piękną ciemnofioletową, minimalistyczną oprawę graficzną z księżycem i sylwetkami w tle.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/retro/another_world
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o zaawansowane akcje wejściowe, replikując oryginalną obsługę pistoletu z gry Erica Chahi.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **D** | Ruch w lewo / w prawo | Chodzenie postacią wzdłuż terenu |
| **Spacja** / **W** | Skok (Jump) | Wykonanie skoku w celu ominięcia szczelin lub przeszkód |
| **F** (szybkie tapnięcie) | Zwykły strzał | Wystrzeliwuje pocisk plazmowy eliminujący wroga |
| **F** (krótkie przytrzymanie) | Tarcza energetyczna | Tworzy pionową barierę blokującą wrogie pociski |
| **F** (długie przytrzymanie) | Super-strzał | Ładuje potężny strzał niszczący wrogie osłony |
| **Enter** | Start / Kontynuacja | Uruchomienie gry lub przejście ekranu historii |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Another World / Out of This World (1991) stworzony przez Erica Chahi dla firmy Delphine Software**
  - *Opis powiązania*: Gra jest niezwykle ambitną i wierną rekonstrukcją rewolucyjnej gry przygodowo-zręcznościowej. Nasza wersja Lurek2D rekonstruuje unikalny styl graficzny oparty na płaskich wielokątach (flat-shaded polygons) i ciemnej, niepokojącej palecie barw. Kluczowym osiągnięciem jest perfekcyjne przeniesienie **taktycznej fizyki walki pistoletem plazmowym** (zarządzanie tarczami, wyczucie czasu ładowania super-strzału), a także płynne, ekranowe przechodzenie między sekcjami (scene transitions), które pioniersko wyeliminowało ekrany ładowania w latach 90.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje elastyczność silnika Lurek w tworzeniu kinowych produkcji z narracją i zaawansowanymi stanami broni:

- `lurek.camera` – Dynamicznie śledzi pozycję gracza lub blokuje się na statycznych kadrach scen kinowych, zachowując filmowy charakter.
- `lurek.render` – Rysuje wielokątny, klimatyczny świat (geometryczne krajobrazy, księżyc, sylwetki obcych), tarcze plazmowe, pociski oraz kinowe napisy.
- `lurek.input` – Obsługuje zaawansowany czas nacisku klawisza strzału w celu rozróżnienia trzech zróżnicowanych trybów działania pistoletu plazmowego.
- `lurek.tween` – Animuje przewijanie tekstu w intrze oraz płynne przechodzenie (fade in/out) ekranu przy zmianie scen.
- `lurek.particle` – Odpowiada za iskry energetyczne przy ładowaniu super-strzału, rozbłyski przy uderzeniu w tarczę oraz pył eksplozji.
- `lurek.timer` – Precyzyjnie mierzy czas przytrzymania klawisza F oraz odmierza 2.5 sekundy czasu życia tarcz energetycznych.
- `lurek.window` & `lurek.event` – Kontrolują konfigurację okna i bezpieczne wyjście.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To absolutnie genialny pokaz **czasowej interpretacji wejścia klawiatury (input duration mapping)** – rozróżnienie pojedynczego naciśnięcia od krótkiego i długiego przytrzymania w celu wyzwolenia różnych stanów gry. Prezentuje również bezszwowe przełączanie scen środowiskowych (world state transitions) i kinową reżyserię zrealizowaną całkowicie w skryptach Lua.
- **Unikalność**: Jedyny taktyczny shooter platformowy w kolekcji oferujący **rozkładanie osłon, niszczenie osłon wroga super-strzałami** oraz filmową narrację bez tradycyjnych klocków kafelkowych (tilemaps).
- **Podobne gry**: *Giana Sisters*, *Turrican* (również platformówki), ale *Another World* odcina się od zręcznościowej dynamiki na rzecz powolnego, pełnego napięcia klimatu i kinowych zagadek.
