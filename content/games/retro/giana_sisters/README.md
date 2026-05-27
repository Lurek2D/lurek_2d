# Giana Sisters

_Klasyczna platformówka 2D z przewijanym ekranem — biegaj, skacz, rozbijaj bloki od spodu i eliminuj potworki, zbierając lśniące klejnoty pośród kolorowych plansz retro._

## 🎮 O grze (About the Game)

**Giana Sisters** to barwna platformówka 2D będąca bezpośrednim hołdem dla słynnej produkcji z komputerów Commodore 64. Wcielasz się w postać jednej z sióstr przemierzającej pełne niebezpieczeństw światy snów. Gra stawia na klasyczne wyzwania zręcznościowe: precyzyjne skoki nad przepaściami, niszczenie cegieł oraz walkę z wrogami.

Cechy rozgrywki:
- **Trzy zróżnicowane poziomy** – ręcznie zaprojektowane plansze o rosnącym stopniu trudności, wypełnione sekretami.
- **Kolekcjonerstwo** – zbieraj złote klejnoty (Gems) rozrzucone na planszy (+50 pkt za sztukę).
- **Interakcja z blokami** – uderzanie głową od spodu w ceglane bloki niszczy je lub ujawnia ukryte sekrety, takie jak skaczące gwiazdy mocy.
- **System ulepszeń (Invincibility Star)** – zebranie gwiazdy daje 5 sekund niezniszczalności. Podczas jej trwania Twoja postać zostawia za sobą świecący ogon (star trail particles) i automatycznie eliminuje wrogów przy kontakcie.
- **Walka z wrogami** – pokonuj wędrujące sowy i potworki poprzez naskakiwanie na nie z góry (+100 pkt). Kontakt z boku lub od dołu kończy się utratą życia.

Poziom ulega zaliczeniu po dotarciu do zielonej bramy wyjściowej (Exit Arch) na końcu planszy. Gracz ma 3 życia.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/retro/giana_sisters
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o standardowe, zmapowane akcje platformowe w silniku Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **←** | Ruch w lewo | Przemieszczanie postaci w lewą stronę |
| **D** / **→** | Ruch w prawo | Przemieszczanie postaci w prawą stronę |
| **W** / **↑** / **Spacja** | Skok (Jump) | Skakanie nad przeszkodami i naskakiwanie na wrogów |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **The Great Giana Sisters (1987) stworzony przez Time Warp Productions na komputer Commodore 64**
  - *Opis powiązania*: Gra stanowi pełen pasji i wierny hołd dla kultowej 8-bitowej platformówki, która zasłynęła jako bezpośrednia alternatywa dla konsolowego *Super Mario Bros*. Nasza implementacja w Lurek2D doskonale oddaje **klasyczny model fizyki platformowej** (inercja biegu, grawitacja skoku z kontrolą wysokości poprzez czas trzymania przycisku), system rozbijania bloków od dołu, naskakiwanie na wrogów oraz charakterystyczne zielone portale wyjściowe. Unowocześnieniem jest płynne, bezszwowe śledzenie kamery (camera tracking with damping), bogate efekty cząsteczkowe pyłu, odłamków cegieł i ogonów gwiazd oraz animowany interfejs.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra stanowi wspaniałą demonstrację tradycyjnego dwuwymiarowego silnika fizyki platformowej opartego na siatce kafli:

- `lurek.camera` – Realizuje płynne, horyzontalne śledzenie pozycji gracza z odpowiednim współczynnikiem tłumienia (damping), zapobiegając drganiom obrazu przy skokach.
- `lurek.render` – Rysuje wielopoziomowe kafelkowe plansze, postać bohaterki, patrolujące potworki, cegły, świecące klejnoty, bramy wyjściowe oraz interfejs HUD z licznikiem zebranych diamentów.
- `lurek.input` – Przechwytuje responsywne wejście ruchu i skoku, oferując płynne sterowanie bezwładnością bohatera.
- `lurek.particle` – Odpowiada za bogaty zestaw efektów wizualnych: iskry klejnotów (gem sparkles), pył przy skokach i stompie wrogów, odpadające odłamki rozbijanych bloków (brick debris) oraz ogon świecący za niezniszczalną postacią.
- `lurek.tween` – Kontroluje płynne animacje pulsowania napisów, przejść ekranów oraz licznik HUD.
- `lurek.timer` – Mierzy precyzyjnie czas niezniszczalności (5 sekund), obsługuje cykl fizyki grawitacji i poruszania wrogów.
- `lurek.window` & `lurek.event` – Cykl życia okna i zdarzenia systemowe.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To wzorcowy pokaz **klasycznej platformówki 2D (scrolling tile platformer)**. Ilustruje idealne połączenie detekcji kolizji AABB z kafelkową mapą (tilemap collisions), implementację siły grawitacji, wektorów prędkości pionowej i poziomej oraz bezwładności postaci w czystym Lua bez polegania na zewnętrznych bibliotekach fizycznych.
- **Unikalność**: Jedyna platformówka z przewijanym ekranem w sekcji Retro oparta o **niszczenie bloków od spodu (brick breaking from below)** oraz dedykowany **power-up niezniszczalności**, który czasowo modyfikuje interakcje z przeciwnikami i generuje ślad cząsteczkowy.
- **Podobne gry**: *Another World* (również platformówka, ale o charakterze kinowym, bez kafelków i fizyki skokowej SMB), *Endless Runner* (kategoria Action, ciągły bieg bez swobody zatrzymania). *Giana Sisters* to jedyna tradycyjna, swobodna platformówka eksploracyjna w tym zestawie.
