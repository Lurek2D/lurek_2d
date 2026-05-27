# Commando

_Pionowa strzelanka z przewijanym ekranem — przedrzyj się przez nieprzyjacielską dżunglę, ratuj jeńców wojennych, wysadzaj wrogie bunkry granatami i staw czoła potężnym bossom._

## 🎮 O grze (About the Game)

W **Commando** (inspirowanym klasycznym hitem Capcomu z 1985 roku) wcielasz się w postać elitarnego komandosa (Super Joe) wysłanego na samotną misję za linie wroga. Gra oferuje dynamiczną rozgrywkę z widokiem z góry i nieprzerwanie **przewijaną w pionie kamerą (vertical scrolling)** w tempie 60 pikseli na sekundę.

Twoim celem jest brnięcie do przodu przez terytorium wroga, eliminacja wrogich jednostek i dotarcie do silnie strzeżonej bazy dowodzenia (Boss Encounter) co każde 2000 pikseli przebytego dystansu.
Na Twojej drodze staną zróżnicowani przeciwnicy i obiekty:
- **Piechota (Infantry)** – standardowi żołnierze biegający po mapie i strzelający w kierunku gracza.
- **Bunkry (Fortified Bunkers)** – stacjonarne gniazda karabinowe prowadzące potrójny ogień zaporowy (3-bullet spread).
- **Oficerowie (Officers)** – szybkie jednostki o zwiększonej wytrzymałości (2 HP).
- **Jeńcy wojenni (POW)** – uwięzieni żołnierze, których możesz uratować podchodząc blisko nich, co daje bonus +300 punktów.
- **Osłony terenowe** – niszczalne worki z piaskiem i beczki oraz niezniszczalne palmy dżungli.

Dysponujesz karabinem maszynowym o nieograniczonej amunicji oraz **granatami** o potężnej sile rażenia obszarowego (60px), które idealnie nadają się do niszczenia wrogich bunkrów i gęstych grup piechoty. Gra oferuje system 3 żyć z punktami zapisu (checkpoints) rozmieszczonymi co 1000 pikseli dystansu.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/retro/commando
```

## 🕹️ Sterowanie (Controls)

Sterowanie wykorzystuje responsywne mapowanie akcji wejściowych silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W, A, S, D** | Ruch bohatera | Poruszanie się komandosem w ośmiu kierunkach na ekranie |
| **Spacja** | Strzał karabinowy | Prowadzenie szybkiego ognia zaporowego w kierunku spojrzenia |
| **G** | Rzut granatem | Rzuca granat zadający potężne obrażenia obszarowe |
| **Enter** | Start / Restart | Uruchomienie gry lub restart po ekranie porażki |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Commando (1985) stworzony przez Capcom**
  - *Opis powiązania*: Gra jest niezwykle dynamiczną rekonstrukcją absolutnego klasyka gatunku pionowych strzelanek (run-and-gun) stworzonego przez Tokuro Fujiwarę. Nasza wersja w Lurek2D w pełni replikuje fundamentalne mechaniki: samotną walkę z przewagą liczebną wroga, konieczność taktycznego podbiegania do uwięzionych zakładników (POWs), rzuty granatami za osłony oraz epickie starcia z ufortyfikowanymi bossami na końcu każdego etapu. Gra wzbogaca klasyczne doświadczenie o efekty cząsteczkowe rozbłysków lufy (muzzle flash), dymu eksplozji granatów oraz płynne animacje napisów za pomocą tweenów.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje zaawansowane dynamiczne renderowanie przewijanego świata i obsługę wielu wrogów jednocześnie:

- `lurek.camera` – Kontroluje nieprzerwany, pionowy ruch kamery w głąb mapy oraz obsługuje cofanie postaci przy zderzeniach z krawędziami viewportu.
- `lurek.render` – Rysuje bujną dżunglę (geometria palm, krzewów), wędrujących żołnierzy, pociski, rzucane łukowo granaty, worki z piaskiem wykazujące ślady zniszczeń, jeńców wojennych, bossów-bunkry oraz rozbudowany HUD.
- `lurek.input` – Odpowiada za precyzyjne sterowanie poruszaniem się w 8 kierunkach z jednoczesnym strzelaniem i rzucaniem granatów.
- `lurek.particle` – Tworzy spektakularne chmury ognia i dymu przy wybuchach bunkrów oraz iskry przy trafieniach.
- `lurek.tween` – Animuje pulsowanie wskaźników interfejsu HUD oraz wyskakujące cyfry punktów (+300 za jeńca).
- `lurek.timer` – Mierzy precyzyjnie czas cyklu życia granatów, czasy regeneracji broni komandosa oraz wylicza dystans przewijania mapy w Delta Time.
- `lurek.window` & `lurek.event` – Kontrolują konfigurację okna i bezpieczne wyjście.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To genialny pokaz **wymuszonego pionowego przewijania ekranu (forced vertical scrolling camera)** oraz obsługi **zróżnicowanego zachowania AI wrogów (multi-profile AI)** na jednej, rozległej mapie. Uczy, jak zarządzać spawnami i czyszczeniem pamięci obiektów wylatujących poza krawędzie widocznego ekranu (culling).
- **Unikalność**: Jedyna gra z kategorii pionowych strzelanek run-and-gun oferująca **starcia z wieloczęściowymi bossami (multi-turret Boss Fortresses)** oraz mechanikę ratowania zakładników generującą dynamiczne cele poboczne.
- **Podobne gry**: *Cannon Fodder* (strzelanka z widokiem z góry i kamerą scrollowaną), ale *Commando* to samotna misja z dynamicznie i stale przewijaną w pionie planszą (forced auto-scroller) zamiast swobodnego marszu oddziału we wszystkich kierunkach.
