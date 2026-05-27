# Shadow of the Beast

_Nastrojowa, mroczna platformówka akcji inspirowana arcydziełem Psygnosis z Amigi — walcz z bestiami nocy pośród hipnotyzującego, 5-warstwowego krajobrazu z płynną paralaksą._

## 🎮 O grze (About the Game)

W **Shadow of the Beast** (hołd dla przełomowego pod względem technicznym i wizualnym hitu z 1989 roku wydanego na komputer Amiga) wcielasz się w postać zmutowanego wojownika przemierzającego mroczny, surrealistyczny świat pełen potworów. Gra stawia nacisk na gęstą, niepokojącą atmosferę zrealizowaną za pomocą ciemnoniebieskiej i fioletowej palety barw, ogromnego świecącego księżyca oraz legendarnego, wielowarstwowego przewijania tła.

Główne mechaniki rozgrywki:
- **5-warstwowa Paralaksa (5-layer parallax)** – tło gry składa się z pięciu niezależnie przewijanych z różną prędkością warstw geometrycznych (gwiezdne niebo z księżycem, odległe pasma górskie, mgliste lasy, bliższe pagórki oraz podłoże), co generuje niesamowitą iluzję głębi przestrzeni 2D.
- **Walka wręcz (Melee Combat)** – walka opiera się na precyzyjnych, szybkich ciosach pięścią w przód (punch o zasięgu 60px) z czasem odnowienia 0.3s. Wyczucie czasu i odległości jest kluczem do przetrwania.
- **Zróżnicowani wrogowie** – na drodze stają naziemne bestie (ground walkers), nurkujące maszkary latające (flying swoopers) oraz stacjonarne, kolczaste pułapki (spike traps).
- **Progresywne tempo** – gra przyspiesza w miarę przebytego dystansu (wrogowie pojawiają się częściej), a co 3000 pikseli dochodzi do walki z gigantycznym bossom o zwiększonej puli zdrowia.

Wizualne smaczki obejmują latające w powietrzu pyłki atmosferyczne (floating atmosphere motes), chmury cząsteczek przy uderzeniach oraz czerwone błyski obrażeń. Gracz rozpoczyna z 5 punktami życia (HP).

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/retro/shadow_beast
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o responsywne akcje wejściowe platformy Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **D** | Ruch lewo / prawo | Bieg bohatera po mrocznym pustkowiu |
| **Spacja** / **W** | Skok (Jump) | Wykonanie wysokiego skoku (z efektownym pyłem pod stopami) |
| **F** | Atak wręcz (Punch) | Wyprowadzenie ciosu pięścią w kierunku spojrzenia |
| **Enter** | Start / Restart | Uruchomienie gry lub restart po ekranie porażki |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Shadow of the Beast (1989) stworzony przez Reflections Interactive i wydany przez Psygnosis**
  - *Opis powiązania*: Gra to zjawiskowa rekonstrukcja technicznego majstersztyku Amigi, który w latach 80. zszokował graczy niespotykaną płynnością wielowarstwowej paralaksy (oryginał oferował aż 12 niezależnych warstw) oraz niepowtarzalną muzyką Davida Whittakera. Nasza wersja Lurek2D doskonale odtwarza ten nostalgiczny, surrealistyczny klimat za pomocą **5-warstwowego systemu dynamicznego pozycjonowania tła (parallax layers offset)** w czystym Lua, zachowując specyficzną i bezwzględną mechanikę walki na bliski dystans. Ponadto, gra wzbogaca retro doświadczenie o nowoczesne efekty pyłków atmosferycznych, zaawansowane cząsteczki zniszczeń i płynną obsługę bossów.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra stanowi wybitny pokaz manipulacji przestrzenią kamery i efektów środowiskowych:

- `lurek.camera` – Centruje widok na biegnącym bohaterze i dostarcza współrzędne X do precyzyjnego przesunięcia (offset) wszystkich pięciu warstw tła paralaksy.
- `lurek.render` – Rysuje bogatą geometrię świata: warstwy górskie, lasy, księżyc, postać gracza o monstrualnej sylwetce, animowane bestie, pułapki oraz interfejs zdrowia HUD z ikonami serc.
- `lurek.input` – Obsługuje ruch i precyzyjne odczytywanie ciosów pięścią bez zakleszczania wejścia.
- `lurek.particle` – Generuje rozbłyski energii przy uderzeniach w bestie, chmury pyłu przy skoku i lądowaniu bohatera oraz **latające w powietrzu drobiny kurzu/pyłków (atmosphere motes)** budujące niesamowitą głębię klimatyczną.
- `lurek.tween` – Kontroluje czerwony błysk obrażeń ekranu, płynne ściemnianie obrazu do czerni (fade-to-black) po śmierci oraz animowane komunikaty o zdobyciu punktów.
- `lurek.timer` – Mierzy precyzyjnie czasy odnowienia ataków (0.3 sekundy), kontroluje tempo przyspieszania rozgrywki oraz obsługuje precyzyjny ruch w Delta Time.
- `lurek.window` & `lurek.event` – Kontrolują konfigurację okna i bezpieczne wyjście.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To sztandarowy pokaz **zaawansowanej, wielowarstwowej paralaksy tła (multi-layer parallax scrolling)** powiązanej z wektorem kamery. Prezentuje również doskonałe wdrożenie **cząsteczek środowiskowych (ambient particles)** dryfujących na wietrze, co w prosty sposób drastycznie podnosi walory estetyczne gry.
- **Unikalność**: Jedyna gra w całej kolekcji Lureka implementująca **5-warstwową, dynamiczną paralaksę krajobrazu** oraz system walki wręcz (melee action) z precyzyjnymi hitboxami pięści zamiast klasycznych pocisków.
- **Podobne gry**: *Another World* (pod kątem fioletowej, filmowej palety retro barw), *Giana Sisters* (pod kątem przewijanej platformówki), ale *Shadow of the Beast* wyróżnia się unikalną głębią paralaksy, walką wręcz bez skakania po głowach wrogów oraz obecnością klimatycznych pyłków w powietrzu.
