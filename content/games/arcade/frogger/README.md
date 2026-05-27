# Frogger

_Klasyczna zręcznościowa przeprawa płaza — pomóż żabie bezpiecznie pokonać ruchliwą autostradę i niebezpieczną rzekę, aby dotrzeć do bezpiecznego schronienia._

## 🎮 O grze (About the Game)

W **Frogger** Twoim zadaniem jest przeprowadzenie małej żabki z dolnego bezpiecznego pasa na samą górę planszy do jednego z pięciu wolnych schronień (home slots). Droga do celu podzielona jest na dwa skrajnie różne i niebezpieczne etapy:

1. **Ruchliwa szosa (Roadway)** – pięć pasów ruchu, po których z różnymi prędkościami i w różnych kierunkach poruszają się samochody i ciężarówki. Zderzenie z dowolnym pojazdem kończy się natychmiastową śmiercią żaby.
2. **Niebezpieczna rzeka (River)** – żaba nie potrafi pływać w wartkim nurcie rzeki (woda jest śmiertelna). Aby ją pokonać, musisz przeskakiwać po płynących kłodach drewna oraz skorupach żółwi. Dodatkowym utrudnieniem są żółwie, które okresowo zanurzają się pod wodę – pozostanie na nich zbyt długo grozi utonięciem.

Czas na wykonanie każdej przeprawy jest ściśle ograniczony przez licznik czasu (countdown timer) u dołu ekranu. W schronieniach losowo pojawiają się muchy, których zjedzenie daje dodatkowe punkty. Celem gry jest zapełnienie wszystkich 5 schronień, co pozwala przejść do kolejnego, szybszego poziomu. Gracz rozpoczyna z 3 życiami.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/arcade/frogger
```

## 🕹️ Sterowanie (Controls)

Gra w pełni korzysta ze zmapowanych akcji wejściowych silnika Lurek, oferując responsywne sterowanie skokowe.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W** / **↑** | Skok w przód | Wykonuje skok żaby o jedną komórkę siatki w górę |
| **S** / **↓** | Skok w tył | Wykonuje skok żaby o jedną komórkę siatki w dół |
| **A** / **←** | Skok w lewo | Wykonuje skok żaby o jedną komórkę siatki w lewo |
| **D** / **→** | Skok w prawo | Wykonuje skok żaby o jedną komórkę siatki w prawo |
| **Enter** | Start / Restart | Uruchomienie gry z ekranu tytułowego lub restart po przegranej |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Frogger (1981) opracowany przez Konami / wydany przez Sega**
  - *Opis powiązania*: Gra jest niezwykle wiernym odwzorowaniem jednego z najbardziej wpływowych tytułów ery automatów arcade. Zaimplementowano w niej pełen zestaw klasycznych mechanik: podział na drogę i rzekę z poruszającymi się niezależnie obiektami, specyficzny dryf żaby płynącej na kłodzie/żółwiu (przenoszenie pozycji gracza o prędkość podłoża), zanurzające się żółwie oraz presję czasu. Wersja Lurek2D dodaje płynne, nieliniowe animacje skoku żabki (hop tweening) oraz dynamiczne efekty cząsteczkowe wody (splash) przy utonięciu i pyłu (poof) przy rozjechaniu przez samochód.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra stanowi doskonały przykład precyzyjnego pozycjonowania i obsługi dryfu fizycznego na ruchomych platformach:

- `lurek.camera` – Konfiguruje stały widok obszaru gry, zachowując pionowy podział ekranu idealny dla planszy w stylu oryginalnego automatu.
- `lurek.render` – Rysuje animowaną żabę, pasy asfaltu, płynącą rzekę, zróżnicowane graficznie samochody, kłody drewna, żółwie, muchy bonusowe oraz pasek czasu.
- `lurek.input` – Odpowiada za skokową detekcję ruchu (wykrywanie pojedynczego naciśnięcia klawisza akcji), co zapobiega niezamierzonemu wykonaniu serii skoków przy przytrzymaniu klawisza.
- `lurek.tween` – Kontroluje płynne skoki żaby, symulując parabolę lotu (skalowanie sprajta w trakcie skoku tworzy iluzję trójwymiarowości) oraz animacje menu.
- `lurek.particle` – Generuje niebieskie cząsteczki rozbryzgu wody (splash) przy wpadnięciu do rzeki oraz szare cząsteczki pyłu (smash poof) przy zderzeniu z pojazdem.
- `lurek.timer` – Mierzy Delta Time dla płynnego ruchu kłód i samochodów, a także obsługuje zegar odliczający czas gry (game timer).
- `lurek.window` & `lurek.event` – Zarządzają aplikacją i przechwytują zdarzenie wyjścia (Escape).

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: Wybitny pokaz **mechaniki dziedziczenia pędu (momentum transfer)**. Pokazuje, jak w prosty sposób zaimplementować wykrywanie kolizji z płynącą platformą i automatyczne modyfikowanie pozycji X gracza o prędkość tej platformy w pętli `update` (żaba porusza się razem z kłodą/żółwiem).
- **Unikalność**: Jedyna gra w sekcji Arcade z mechaniką **zanurzających się stref bezpiecznych (submerging platforms)** oraz **surowym limitem czasu (timer penalty)** wymuszającym na graczu dynamiczne planowanie ścieżki i szybkie podejmowanie decyzji.
- **Podobne gry**: *Donkey Kong* (omijanie przeszkód w ruchu wertykalnym), jednak *Frogger* jest unikalny ze względu na brak grawitacji i obecność dryfujących podłoży rzecznych.
