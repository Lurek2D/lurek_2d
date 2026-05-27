# Sniper

_Precyzyjny symulator strzelecki — celuj przez kołyszącą się lunetę, bierz poprawkę na wiatr i opad pocisku, i wstrzymaj oddech w kluczowym momencie, by oddać strzał życia._

## 🎮 O grze (About the Game)

**Sniper** to taktyczny symulator balistyczny zrealizowany na silniku Lurek2D. Gra stawia przed graczem wyzwanie precyzyjnego eliminowania celów (tarcz strzeleckich) na dużych dystansach, replikując fizyczne czynniki wpływające na strzelectwo wyborowe.

Rozgrywka obejmuje 3 progresywne rundy o rosnących wymaganiach balistycznych:
1. **Runda 1 (Bliski dystans)** – cele są stacjonarne, a wiatr jest zerowy. Doskonały etap do wyczucia naturalnego chwiania się broni.
2. **Runda 2 (Średni dystans)** – pojawia się stały boczny wiatr, znoszący trajektorię pocisku. Wymaga brania poprawki na osi X.
3. **Runda 3 (Daleki dystans)** – wiatr stale zmienia siłę i kierunek, a tarcze poruszają się poziomo, zmuszając do wyliczania wyprzedzenia celu.

Kluczowe mechaniki symulacji:
- **Kołysanie celownika (Scope Sway)** – luneta karabinu naturalnie pływa po ekranie w sinusoidalnym wzorze symulującym oddech i tętno strzelca.
- **Wstrzymanie oddechu (Hold Breath) [Shift]** – pozwala na czasowe ustabilizowanie i unieruchomienie celownika na 3 sekundy. Zbyt długie wstrzymanie oddechu wywołuje silne niedotlenienie i gwałtowne "szarpnięcie" lunety.
- **Pełna Balistyka (Bullet Drop & Wind)** – na wystrzeloną kulę działa grawitacja (opad pocisku w pionie) oraz wektor wiatru (znoszenie boczne w poziomie).
- **Punktacja tarczowa** – tarcze podzielone są na strefy: środek (100), wewnętrzny pierścień (70), zewnętrzny pierścień (40) oraz pudło (0).

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/sniper
```

## 🕹️ Sterowanie (Controls)

Sterowanie wymaga opanowania precyzyjnych mikro-korekt i wyczucia czasu.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W, A, S, D** / **Strzałki** | Ruch celownika | Celowanie lunetą poprzez powolne naprowadzanie krzyża na tarczę |
| **Shift** (przytrzymanie) | Wstrzymanie oddechu | Stabilizuje lunetę (maksymalnie na 3 sekundy) |
| **Spacja** | Oddanie strzału (Fire) | Wystrzeliwuje pocisk z uwzględnieniem opadu i wiatru |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Sniper Elite (stworzony przez Rebellion) oraz gry typu Silent Scope (Konami)**
  - *Opis powiązania*: Gra to niezwykle przemyślana rekonstrukcja realizmu strzeleckiego znanego z zaawansowanych gier taktycznych. Wersja Lurek2D doskonale odwzorowuje **fizykę opadu i znoszenia wiatrem (ballistic trajectory simulation)**, konieczność wyprzedzania ruchomego celu oraz klimatyczną mechanikę wstrzymywania oddechu ze wskaźnikiem stabilizacji płuc. Neonowy celownik lunety, wektorowe tarcze i dynamiczny wskaźnik kierunku wiatru (wind gauge) tworzą spójną i estetyczną całość.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje zaawansowane fizyczne i matematyczne obliczenia trajektorii w czasie rzeczywistym:

- `lurek.render` – Generuje spektakularny widok przez okrągłą lunetę snajperską z ruchomym krzyżem celowniczym (reticle), linie wskaźnika wiatru, wielopierścieniowe wektorowe tarcze o zmiennej skali (symulującej dystans), oraz wskaźnik napełnienia płuc powietrzem.
- `lurek.input` – Obsługuje precyzyjne odczytywanie klawiszy celowania oraz natychmiastowe wystrzelenie pocisku i stabilizację Shift.
- `lurek.particle` – Generuje rozbłysk dymu wystrzału (muzzle smoke), smugę lecącego pocisku (bullet vapor trail) oraz iskry pyłu po uderzeniu w tarczę lub pudle w ścianę.
- `lurek.tween` – Kontroluje odrzut lunety (recoil offset) po strzale, odkształcenia wskaźników interfejsu oraz przejścia rund.
- `lurek.timer` – Mierzy czas 3 sekund wstrzymania oddechu, Delta Time ruchu tarcz oraz wylicza sinusoidalny wiatr i kołysanie celownika.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To genialny pokaz **symulowania fizyki balistycznej (ballistic gravity & wind drift simulation)** oraz **sinusoidalnego kołysania (sinusoidal offset math)** w czystym Lua (opóźnienie kuli zależy od wirtualnego dystansu tarcz, a celownik pływa po złożonej krzywej matematycznej). Uczy, jak stworzyć zaawansowaną grę o statycznym charakterze, która wymaga od gracza czystej chłodnej kalkulacji zamiast bezmyślnego biegania.
- **Unikalność**: Jedyny **symulator snajperski (sniper simulation)** w całej kolekcji Lureka z fizycznym znoszeniem pocisków, wskaźnikiem płuc i kołysaniem lunety.
- **Podobne gry**: Brak zbliżonych taktycznych symulatorów strzeleckich w katalogu. Gra jest unikalną i niezwykle świeżą pozycją prezentującą zaawansowane skrypty matematyczne.
