# Paradroid

_Przejmuj kontrolę nad wrogimi robotami na stacji kosmicznej — rozpocznij jako najsłabszy droid (001), hakuj silniejsze jednostki w kultowej minigrze zręcznościowej i dbaj o zapasy energii._

## 🎮 O grze (About the Game)

W **Paradroid** (inspirowanym arcydziełem Andrew Braybrooka z 1985 roku na Commodore 64) wcielasz się w postać słabego droida-prototypu o oznaczeniu **001 (Influence Device)**. Twoim celem jest oczyszczenie pokładów dryfującego statku kosmicznego z uszkodzonych, wrogich robotów bojowych i wartowniczych. Ponieważ Twój bazowy droid ma minimalny pancerz i zerową siłę ognia, kluczem do przetrwania jest **mechanika transferu umysłu (haking robotów)**.

Gra oferuje unikalny zestaw mechanik:
1. **Klasy Robotów (Droid Classes)**:
   - **Seria 100 (Konserwacyjne)** – słabe, 1 HP, nikłe zagrożenie.
   - **Seria 200 (Strażnicze)** – średnie, 2 HP, umiarkowana siła ognia.
   - **Seria 500 (Bojowe)** – silne, 3 HP, ciężka broń palna.
   - **Seria 900 (Dowódcze)** – potężne, 5 HP, niszczycielskie pociski.
2. **Minigra Transferu (The Transfer Game)**:
   Podbiegając blisko robota i naciskając klawisz **E**, uruchamiasz hakowanie. Na ekranie pojawia się minigra zręcznościowa – dwa paski postępu (Twój i wroga) ścigają się w poziomie. Musisz jak najszybciej i rytmicznie naciskać klawisze **W, A, S, D**, aby zasilić i przesunąć swój pasek hakowania. Zwycięstwo daje Ci pełną kontrolę nad wrogim droidem (zyskujesz jego statystyki, broń i HP). Porażka oznacza zniszczenie Twojej jednostki i utratę życia.
3. **Zarządzanie Energią (Energy Drain)**:
   Każdy przejęty robot zużywa energię, która powoli wyczerpuje się z czasem. Im wyższa klasa droida, tym szybszy drenaż energii. Zmusza to gracza do ciągłego planowania i wykonywania kolejnych transferów w celu odnawiania zasobów.

Rozgrywka obejmuje 4 poziomy pokładów stacji kosmicznej o rosnącym zagęszczeniu wrogów.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/retro/paradroid
```

## 🕹️ Sterowanie (Controls)

Sterowanie łączy klasyczny ruch z dynamicznym sterowaniem w minigrze zręcznościowej.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **Strzałki** | Ruch droidem | Poruszanie robotem po korytarzach statku kosmicznego |
| **Spacja** | Strzał | Wystrzelenie pocisku plazmowego (o sile zależnej od przejętej klasy drona) |
| **E** | Hakowanie / Transfer | Zainicjowanie procedury transferu po zbliżeniu do wrogiego robota |
| **W, A, S, D** | Minigra Transferu | Szybkie, rytmiczne wciskanie klawiszy w celu wygrania procesu hakowania |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Paradroid (1985) stworzony przez Andrew Braybrooka dla Hewson Consultants na C-64**
  - *Opis powiązania*: Gra to niezwykle ambitna, nowoczesna implementacja jednej z najbardziej cenionych gier w historii 8-bitowców. Nasza wersja w Lurek2D wiernie replikuje skomplikowaną **mechanikę hierarchicznego przejmowania ciał wrogów**, dynamiczny upływ energii (energy decay) wymuszający agresywną grę oraz charakterystyczną, pełną napięcia minigrę transferową. Geometryczna, neonowa grafika zrzuca retro sprajty na rzecz stylowych, wektorowych schematów technicznych robotów, co nadaje grze unikalną tożsamość.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje elastyczność silnika w obsłudze asymetrycznego projektowania poziomów oraz oddzielnych minigier:

- `lurek.render` – Generuje rozbudowane korytarze stacji kosmicznej, schematyczne grafiki robotów z oznaczeniami numerycznymi klasy, pociski energetyczne, interaktywny HUD stanu energii oraz pełnoekranową arenę minigry hakowania.
- `lurek.input` – Obsługuje dynamiczne przełączanie mapowania klawiszy (podczas eksploracji strzałki sterują ruchem, a w trakcie minigry klawisze WASD są intensywnie odpytywane w celu wykrywania szybkich kliknięć).
- `lurek.tween` – Animuje poruszanie się pasków postępu hakowania, pulsujące diody ostrzegawcze niskiego stanu energii oraz przejścia poziomów.
- `lurek.particle` – Generuje niebieskie wyładowania elektryczne przy udanym transferze oraz eksplozje przy zniszczeniu droidów.
- `lurek.timer` – Kontroluje Delta Time ruchu oraz precyzyjnie wylicza współczynniki drenażu energii dla każdej z klas drona.
- `lurek.window` & `lurek.event` – Kontrolują konfigurację okna i bezpieczne wyjście.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To genialny pokaz **dynamicznej zmiany cech kontrolowanej postaci (possess/morph mechanics)** – gracz w locie przejmuje zmienne parametry kolizji, zdrowia i siły ognia innej encji. Jest to również wspaniały przykład zaimplementowania minigry typu "Button Masher" w czystym Lua z odpowiednim sprzężeniem zwrotnym (feedback).
- **Unikalność**: Jedyna gra w całej kolekcji Lureka z **mechaniką pasożytniczą (parasitic/possession gameplay)**, w której gracz nie posiada trwałego ciała, a jego status i styl walki zmieniają się z każdym przejętym robotem.
- **Podobne gry**: *Dyna Blaster*, *Pac-Man* (widok z góry), ale *Paradroid* wyróżnia się strzelaniem kierunkowym, drenażem energii oraz osobnym ekranem hakowania.
