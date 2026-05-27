# Galaga

_Klasyczna zręcznościowa strzelanka kosmiczna — eliminuj wrogie formacje kosmitów, odpieraj ataki nurkujące i uwolnij swój pojazd z promienia ściągającego, by uzyskać podwójną siłę ognia._

## 🎮 O grze (About the Game)

W **Galaga** sterujesz myśliwcem na dole ekranu, stawiając czoła nacierającym rojom wrogich statków obcych. Przeciwnicy początkowo wlatują na ekran w widowiskowych pętlach, tworząc zwartą formację na górze, z której co jakiś czas pojedyncze jednostki lub małe eskadry odrywają się i wykonują nurkujące ataki samobójcze, strzelając w kierunku gracza.

Gra implementuje unikalną, kultową mechanikę **promienia ściągającego (Tractor Beam)** używanego przez bossów z górnego rzędu (wymagających dwóch trafień). Boss może wyemitować promień i porwać statek gracza. Jeśli gracz dysponuje zapasowym życiem, może zestrzelić tego konkretnego bossa podczas jego kolejnego ataku nurkującego – uwolniony w ten sposób statek łączy się z obecnym, tworząc **podwójny myśliwiec (Dual Fighter)** o zdublowanej sile ognia!

Dodatkowo, co trzecia fala to **Etap Wyzwania (Challenging Stage)**, w którym wrogowie przelatują przez ekran w określonych wzorach i nie strzelają do gracza – celem jest zestrzelenie jak największej liczby obcych dla zdobycia ogromnych bonusów punktowych. Rozgrywce towarzyszy piękna, wielowarstwowa paralaksa gwiezdnego tła.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/arcade/galaga
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o responsywny system akcji wejściowych silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **←** | Ruch w lewo | Przesunięcie myśliwca w lewą stronę ekranu |
| **D** / **→** | Ruch w prawo | Przesunięcie myśliwca w prawą stronę ekranu |
| **Spacja** | Strzał (Fire) | Wystrzelenie pocisku (lub dwóch pocisków jednocześnie w trybie Dual Fighter) |
| **Enter** | Start | Uruchomienie gry z poziomu ekranu tytułowego |
| **R** | Restart | Restart rozgrywki po ekranie Game Over |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Galaga (1981) opracowany i wydany przez Namco**
  - *Opis powiązania*: Wybitna i niezwykle kompletna implementacja następcy gry *Galaxian*. Nasza wersja w Lurek2D rekonstruuje wszystkie przełomowe innowacje oryginału: dynamiczny wlot obcych na ekran w z góry określonych formacjach falowych, bezwzględne ataki nurkujące (dive-bombing) z trajektorią zakrzywioną w kierunku gracza, unikalny system Tractor Beam pozwalający na połączenie statków w tryb Dual Fighter oraz bonusowe etapy wyzwań Challenging Stages. Wzbogaciliśmy całość o płynną paralaksę gwiazd w tle, soczyste efekty cząsteczkowe eksplozji kosmitów oraz interpolowane w czasie (tween) napisy punktowe.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje wydajność renderowania 2D oraz obsługę wielu niezależnych trajektorii obiektów:

- `lurek.camera` – Gwarantuje idealną proporcję ekranu typu "vertical shoot-em-up" niezależnie od wymiarów monitora.
- `lurek.render` – Rysuje myśliwce gracza (pojedynczy lub podwójny), pociski, zróżnicowane typy obcych w formacji i w locie, promień ściągający oraz interaktywny HUD.
- `lurek.input` – Zapewnia płynną obsługę ruchu na osi X oraz ograniczenie liczby strzałów na ekranie (maksymalnie 2 pociski na raz dla pojedynczego statku).
- `lurek.tween` – Animuje rozszerzanie się promienia Tractor Beam oraz wyskakiwanie punktów przy zestrzeleniach.
- `lurek.particle` – Odpowiada za iskry eksplozji statków kosmicznych i efekty zniszczenia bossów.
- `lurek.timer` – Mierzy Delta Time, kontroluje czas trwania faz Challenging Stage oraz zarządza falami wlotu przeciwników i losowością ataków nurkujących.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i poprawnym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To genialny pokaz **zaawansowanej matematyki ruchu 2D** – zakrzywionych trajektorii lotu (Bézier curves lub interpolacje wektorowe) używanych przez wrogów wchodzących w formacje i nurkujących na gracza. Prezentuje również doskonałe zachowanie kolizji z promieniem Tractor Beam oraz płynną obsługę dynamicznego łączenia encji (połączenie dwóch graczy w jeden myśliwiec podwójny o zmienionej fizyce i hitboxie).
- **Unikalność**: Jedyna gra w sekcji strzelanek kosmicznych oferująca **mechanikę Tractor Beam (przechwytywanie gracza przez wroga i późniejsze uwalnianie)**, tryb podwójnego statku oraz dedykowany, bezkonfliktowy etap Challenging Stage z unikalnymi ścieżkami lotu.
- **Podobne gry**: *Space Invaders* (podstawowe strzelanie z dołu ekranu), jednak *Galaga* przewyższa ją pod każdym względem dynamiki, skomplikowania ruchu wrogów i mechanik power-upów.
