# Fighting Game

_Zręcznościowa bijatyka 1v1 przeciwko sztucznej inteligencji — wyprowadzaj kombosy, ładuj pasek mocy Super i zablokuj ciosy wroga w pojedynkach do dwóch wygranych rund._

## 🎮 O grze (About the Game)

**Fighting Game** to dynamiczny pojedynkownik 1v1 realizujący najważniejsze założenia klasycznych bijatyk 2D. Wcielasz się w postać niebieskiego wojownika, stawiając czoła sterowanemu przez komputer (AI) czerwonemu przeciwnikowi na płaskiej arenie w pojedynku składającym się z maksymalnie 3 rund (best of 3). Każda runda to walka do utraty 100 HP.

Gra oferuje rozbudowane mechaniki walki turniejowej:
- **System Kombosów (Combo System)** – udane trafienia w krótkim oknie czasu (0.5 sekundy) łączą się w serię. Licznik combo rośnie, zwiększając obrażenia każdego kolejnego uderzenia.
- **Pasek mocy Super (Super Meter)** – ładowany poprzez zadawanie ciosów (+5 pkt) oraz udane blokowanie ataków (+3 pkt). Po pełnym naładowaniu (100 pkt) klawisz **Q** wyzwala dewastujący atak specjalny (Super Attack) zadający 30 pkt obrażeń i odrzucający wroga (knockback).
- **Blokowanie i Ogłuszenie (Hit Stun & Block)** – wciśnięcie bloku redukuje otrzymywane obrażenia. Udany atak bez bloku wprowadza przeciwnika w stan krótkiego ogłuszenia (hit stun), dając napastnikowi ramki przewagi (advantage frames) do wyprowadzenia kolejnego ciosu.
- **Reaktywne AI wroga** – komputerowy sparingpartner analizuje odległość: zbliża się, gdy jest daleko, wyprowadza ciosy z bliska i losowo stosuje bloki obronne w zależności od tempa walki.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/fighting_game
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o precyzyjne mapowanie akcji bojowych platformy Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **D** | Ruch lewo / prawo | Przemieszczanie wojownika po płaskiej arenie |
| **W** | Skok (Jump) | Wykonanie skoku w celu uniknięcia ciosu lub ataku z góry |
| **F** | Szybki cios (Punch) | Zadaje 8 pkt obrażeń (szybki rozruch, mały zasięg) |
| **G** | Kopnięcie (Kick) | Zadaje 15 pkt obrażeń (wolniejszy rozruch, większy zasięg) |
| **H** | Blok (Block) | Redukuje obrażenia od ciosów wroga |
| **Q** | Atak Super | Wyprowadza potężne uderzenie specjalne (wymagane 100% Super) |
| **Enter** | Start / Następna runda | Rozpoczęcie walki z ekranu tytułowego lub przejście dalej |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Street Fighter II (1991) autorstwa Capcom** oraz **klasyczne bijatyki 2D (Neo-Geo, SNK)**
  - *Opis powiązania*: Gra to kompletny, minimalistyczny hołd dla rewolucyjnego hitu Yoshikiego Okamoto, który zdefiniował gatunek bijatyk 2D. Nasza wersja w Lurek2D precyzyjnie rekonstruuje mechaniki turniejowe: **stany klatek przewagi i ogłuszenia (hit stun / advantage frames)**, gromadzenie zasobów energii w pasku Super oraz łączenie uderzeń w kombinacje (combos). Walkę wzbogacono o nowoczesne, pulsujące wskaźniki interfejsu (HP i Super meter) animowane tweenami, chmury cząsteczek przy uderzeniach oraz dynamiczne wstrząsy kamery przy atakach Super.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje zaawansowane zarządzanie stanami postaci oraz efektami fizyki wstrząsów:

- `lurek.camera` – Centruje widok na arenie, a także wykonuje dynamiczne, wektorowe wstrząsy kamery (`camera.setOffset`) w momencie wyzwolenia potężnych ataków Super.
- `lurek.render` – Rysuje sylwetki wojowników (deformacje kształtu przy ciosach, skokach i bloku), paski życia, paski Super, napisy combo, dynamiczne overlays oraz retro napisy rund.
- `lurek.input` – Przechwytuje responsywne wejście, obsługując szybkie kombinacje Punch/Kick/Block bez opóźnień (input latency).
- `lurek.particle` – Generuje rozbłyski cząsteczkowe (sparks) przy zderzeniach ciosów z ciałem, iskry przy bloku oraz niebieski wybuch energii wokół wojownika przy uruchomieniu ataku Super.
- `lurek.tween` – Obsługuje płynne skracanie pasków zdrowia na HUD, zanikanie liczników Combo oraz powiększanie napisów "ROUND X" i "KO".
- `lurek.timer` – Mierzy Delta Time ruchów i precyzyjnie liczy 0.5-sekundowe okno komba oraz czas ogłuszenia (hit stun duration).
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To wybitny pokaz **zarządzania skończoną maszyną stanów postaci (Fighter State Machine)** w grach akcji 2D (stany: Idle, Walk, Jump, Punching, Kicking, Block, HitStun, KO). Prezentuje idealną implementację zliczania ramek przewagi (frame advantage) i czasu ogłuszenia oraz dynamiczne sterowanie kamerą (screen shake) z poziomu skryptu Lua.
- **Unikalność**: Jedyna bijatyka 1v1 (fighting game) w całym repozytorium Lureka z zaimplementowanym systemem Combo, ogłuszeniami oraz dedykowanym paskiem mocy specjalnej Super.
- **Podobne gry**: Brak zbliżonych gier pojedynkowych w kolekcji. Gra jest unikalną i dynamiczną prezentacją fizyki zderzeń AABB na płaskiej płaszczyźnie.
