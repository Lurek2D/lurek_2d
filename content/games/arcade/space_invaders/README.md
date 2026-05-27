# Space Invaders

_Obrona Ziemi przed kosmiczną inwazją — odpieraj fale schodzących obcych, kryj się za niszczalnymi tarczami obronnymi i poluj na rzadkie statki UFO dla bonusowych punktów._

## 🎮 O grze (About the Game)

W **Space Invaders** wcielasz się w rolę obrońcy stacji planetarnej, kontrolując działo laserowe poruszające się na dole ekranu. Twoim nadrzędnym zadaniem jest powstrzymanie i eliminacja maszerującej armii kosmitów, ułożonych w zwartą formację 11×5. 

Obcy przemieszczają się synchronicznie w poziomie. Gdy dotrą do krawędzi ekranu, cała formacja schodzi o jeden rząd niżej i przyspiesza. Im mniej obcych pozostaje na ekranie, tym szybciej i agresywniej się poruszają, zwiększając tempo odtwarzania charakterystycznego, rytmicznego dźwięku marszu. Obcy zrzucają bomby laserowe, przed którymi możesz chronić się za czterema **niszczalnymi tarczami obronnymi (shields)**, ulegającymi stopniowej destrukcji przy każdym uderzeniu pocisku (zarówno wrogiego, jak i Twojego).
Okazjonalnie na samej górze ekranu przelatuje rzadki czerwony statek **UFO (Mystery Ship)** – jego zestrzelenie nagradzane jest losową liczbą punktów bonusowych. Gra kończy się, gdy obcy dotrą do poziomu tarczy obrońcy lub gdy gracz utraci wszystkie 3 życia.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/arcade/space_invaders
```

## 🕹️ Sterowanie (Controls)

Sterowanie wykorzystuje zmapowane akcje klawiatury silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **←** | Ruch w lewo | Przesunięcie działka obronnego w lewą stronę ekranu |
| **D** / **→** | Ruch w prawo | Przesunięcie działka obronnego w prawą stronę ekranu |
| **Spacja** | Strzał (Fire) | Wystrzelenie pocisku pionowo w górę (maksymalnie 1 aktywny pocisk na ekranie) |
| **Enter** | Start | Uruchomienie gry z poziomu ekranu tytułowego |
| **R** | Restart | Restart rozgrywki po ekranie porażki |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Space Invaders (1978) stworzony przez Tomohiro Nishikado dla firmy Taito**
  - *Opis powiązania*: Gra stanowi precyzyjną, dynamiczną rekonstrukcję absolutnego kamienia milowego w branży, który rozpoczął złotą erę gier arkadowych. Nasza wersja w Lurek2D doskonale odwzorowuje kluczowe mechaniki oryginalnego hitu: stopniowy wzrost prędkości poruszania się obcych (symulując legendarny błąd sprzętowy z 1978 roku, który stał się zamierzoną mechaniką), niszczalne osłony piksel po pikselu, losowy wylot UFO oraz limit 1 pocisku gracza na ekranie wymuszający celność. Wzbogaciliśmy wersję o nowoczesny, czytelny ekran tytułowy z tabelą wartości punktowych kosmitów, cząsteczki eksplozji, dynamiczne tweeny interfejsu oraz licznik klatek.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje perfekcyjne współdziałanie podstawowych modułów silnika Lurek w minimalistycznym wydaniu:

- `lurek.camera` – Konfiguruje wirtualny viewport o stałych proporcjach i ostrych retro krawędziach kafli.
- `lurek.render` – Odpowiada za precyzyjne rysowanie rzędów obcych (każdy rząd ma inny retro kształt geometryczny), pikselowych tarcz obronnych z widocznym stanem zniszczenia, działka gracza, pocisków oraz latającego UFO.
- `lurek.input` – Obsługuje ruch boczny oraz wyzwala pojedyncze strzały (działanie semi-auto blokujące ciągły ogień przy trzymaniu Spacji).
- `lurek.particle` – Generuje efektowne zielone eksplozje cząsteczkowe (sparks) w miejscu zestrzelenia kosmitów i UFO.
- `lurek.tween` – Obsługuje płynne animacje pojawiania się elementów menu oraz wyskakujące cyfry punktów (+100, +150, itp.).
- `lurek.timer` – Kontroluje narastający takt ruchu formacji obcych oraz precyzyjnie wylicza kolizje w Delta Time.
- `lurek.window` & `lurek.event` – Kontrolują konfigurację okna oraz wyjście z gry.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To genialny pokaz **stopniowej i nieliniowej trudności gry (difficulty scaling)** opartej o prosty wzór: prędkość poruszania się grupy wrogów jest odwrotnie proporcjonalna do ich liczebności na ekranie. Prezentuje również doskonałą implementację **niszczalnego terenu (destructible covers)** z wielostopniową grafiką uszkodzeń tarcz.
- **Unikalność**: Jedyna gra w sekcji Arcade oferująca stacjonarne osłony (shields), które gracz może aktywnie wykorzystywać jako taktyczną ochronę, ale musi pamiętać, że jego własne pociski również je niszczą.
- **Podobne gry**: *Galaga* (również kosmiczna strzelanka), jednak *Space Invaders* wyróżnia się brakiem ataków nurkujących obcych, obecnością stacjonarnych tarcz obronnych oraz znacznie bardziej rygorystycznym limitem strzałów na sekundę.
