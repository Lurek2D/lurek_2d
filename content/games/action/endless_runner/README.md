# Endless Runner

_Dynamiczny, niekończący się bieg z przeszkodami — omijaj wysokie zapory, wykonuj wślizgi pod belkami, przeskakuj przepaście i zbieraj monety w stale przyspieszającym świecie._

## 🎮 O grze (About the Game)

W **Endless Runner** wcielasz się w postać sprintera stale biegnącego w prawą stronę ekranu. Świat gry automatycznie przewija się w poziomie (auto-scrolling), a prędkość biegu sukcesywnie wzrasta wraz z pokonanym dystansem (od początkowych 300 do maksymalnie 600 pikseli na sekundę), co drastycznie skraca czas na reakcję gracza.

Rozgrywka wymaga błyskawicznej oceny sytuacji i stosowania zróżnicowanych manewrów:
- **Wysokie zapory (Tall barriers)** – wymagają wykonania standardowego skoku.
- **Niskie zawieszenia (Low beams)** – wymagają wykonania wślizgu (sliding) pod przeszkodą, co czasowo zmniejsza wysokość hitboxa gracza.
- **Przepaście (Gaps)** – szerokie dziury w ziemi wymagające precyzyjnego przeskoczenia (dla ułatwienia detekcja kolizji z krawędzią przepaści jest lekko tolerancyjna).
- **Podwójny skok (Double Jump)** – po przebiegnięciu pierwszych 500 metrów odblokowuje się stała umiejętność podwójnego skoku, ułatwiająca pokonywanie bardziej skomplikowanych sekwencji przeszkód.

Wzdłuż toru biegu rozłożone są złote monety (+50 punktów każda). Wynik końcowy to suma przebiegniętych metrów oraz zebranych monet. Gra posiada klimatyczną, 3-warstwową paralaksę tła, która działa nawet na ekranie tytułowym, oraz zaawansowaną fizycznie animację śmierci (postać obraca się i spada poza ekran).

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/endless_runner
```

## 🕹️ Sterowanie (Controls)

Sterowanie opiera się na prostych, responsywnych komendach ruchu.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **Spacja** / **W** / **↑** | Skok (Jump) | Przeskoczenie zapory / przepaści (podwójny skok po przekroczeniu 500m) |
| **S** / **↓** | Wślizg (Slide) | Prześlizgnięcie się pod niską przeszkodą |
| **Enter** | Start / Restart | Uruchomienie gry lub szybki restart po porażce |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Canabalt (2009) autorstwa Adama Saltsmana** oraz **klasyki typu Temple Run / Subway Surfers**
  - *Opis powiązania*: Gra stanowi udaną rekonstrukcję fenomenu gier typu *endless runner*, zapoczątkowanego w 2D przez minimalistyczny hit *Canabalt*. Doskonale odtwarza to nostalgiczne poczucie pędu, narastający poziom trudności powiązany z fizycznym przyspieszaniem kamery świata, oraz płynną trójwarstwową paralaksę (odległe góry, zarysy lasów, bliższe pagórki). Wersja Lurek2D unowocześnia model rozgrywki poprzez wprowadzenie mechaniki **wślizgu pod belkami** oraz precyzyjnego systemu **odblokowywania podwójnego skoku** (double jump progression gate) na określonym dystansie jako elementu urozmaicającego rozgrywkę.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra stanowi doskonały poligon doświadczalny dla dynamicznych systemów cząsteczkowych i fizyki skokowej:

- `lurek.render` – Generuje płynną trójwarstwową paralaksę tła, rysuje biegnącą postać (z deformacjami kształtu przy skoku i wślizgu), złote monety, przeszkody oraz HUD.
- `lurek.input` – Obsługuje responsywne wejście w czasie rzeczywistym, w tym dwukrotne tapnięcie skoku do wyzwolenia Double Jump.
- `lurek.particle` – Generuje efektowne kłęby kurzu spod stóp sprintera przy lądowaniu po skoku, złote iskry przy zjadaniu monet (sparkles) oraz obłok pyłu (poof) przy zderzeniu i śmierci postaci.
- `lurek.tween` – Animuje pulsowanie napisów tytułowych, napisy bonusów oraz płynną rotację i upadek fizyczny postaci przy śmierci.
- `lurek.timer` – Mierzy dystans w metrach w oparciu o prędkość klatkową Delta Time oraz dynamicznie zarządza czasem trwania wślizgu.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: Znakomity pokaz **płynnego horyzontalnego przewijania nieskończonej planszy (infinite auto-scrolling runner architecture)** z dynamicznym generowaniem kolejnych przeszkód i coinów na krawędzi ekranu oraz ich sprzątaniem z pamięci po wylocie z drugiej strony. Pokazuje jak implementować dwustopniowy skok (Double Jump) i czasową zmianę wysokości hitboxa (sliding mechanics).
- **Unikalność**: Jedyna gra w sekcji Action oferująca **progresję zdolności bohatera w locie (ability unlock at milestone)** – odblokowanie podwójnego skoku po przebiegnięciu 500 metrów jako sposobu na przełamanie krzywej trudności.
- **Podobne gry**: *Giana Sisters* (platformówka z przewijanym ekranem), ale *Endless Runner* odróżnia się brakiem swobody zatrzymania się i stania w miejscu – postać nieprzerwanie i stale pędzi do przodu pod wpływem automatycznego przyspieszenia.
