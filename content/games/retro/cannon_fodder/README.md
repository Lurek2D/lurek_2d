# Cannon Fodder

_Dowodź oddziałem żołnierzy w niebezpiecznej dżungli — kieruj ruchem, prowadź ogień zaporowy i rzucaj granatami taktycznymi, pamiętając, że każda strata w ludziach jest bezpowrotna._

## 🎮 O grze (About the Game)

W **Cannon Fodder** (hołd dla legendarnej taktycznej gry z 1993 roku) obejmujesz dowództwo nad maksymalnie trzyosobowym oddziałem żołnierzy wysłanych na misje pacyfikacyjne w gęstej dżungli. Gra łączy zręcznościowe strzelanie z taktycznym zarządzaniem pozycjonowaniem i zasobami.

Cechy rozgrywki:
- **Permanentna śmierć (Permadeath)** – żołnierze polegli na polu bitwy giną na zawsze. Przystąpienie do kolejnej misji z mniejszym oddziałem drastycznie utrudnia walkę i zwiększa ryzyko porażki.
- **Sterowanie oddziałem** – Twoi żołnierze poruszają się w zwartej formacji (squad). Wszyscy żyjący członkowie oddziału strzelają jednocześnie w kierunku, w którym są aktualnie zwróceni.
- **Taktyczny arsenał** – oprócz standardowych karabinów, dysponujesz ograniczoną liczbą **granatów** (3 na misję). Wybuch granatu zadaje potężne obrażenia obszarowe w promieniu 60 pikseli – to doskonały sposób na szybkie eliminowanie zgrupowań wroga lub niszczenie ich punktów obronnych.
- **Struktura misji** – kampania składa się z 5 eskalujących misji (od 6 do 22 wrogów patrolujących teren i otwierających ogień po wykryciu oddziału). Ukończenie misji wymaga wyeliminowania wszystkich wrogów na mapie i dotarcia do flagi ewakuacyjnej na szczycie planszy.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/retro/cannon_fodder
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o precyzyjny system akcji wejściowych silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W, A, S, D** | Ruch oddziału | Marsz całej formacji żołnierzy w określonym kierunku dżungli |
| **Spacja** | Ogień karabinowy | Wszyscy żyjący żołnierze oddziału oddają strzał w kierunku marszu |
| **G** | Rzut granatem | Rzuca granat w kierunku celowania (limitowany zapas, obrażenia obszarowe) |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Cannon Fodder (1993) stworzony przez Sensible Software na komputer Amiga**
  - *Opis powiązania*: Gra jest hołdem dla kultowego, czarnohumorystycznego klasyka Jon Hare'a. Nasza implementacja Lurek2D doskonale oddaje fundamentalną mechanikę gry – **permanentną śmierć żołnierzy o unikalnych imionach**, dynamiczną formację oddziału maszerującego ramię w ramię oraz taktyczny podział na szybką broń maszynową i limitowane granaty obszarowe. Zamiast statycznej planszy, gra oferuje płynnie przewijany w pionie świat dżungli (vertical scrolling camera), klimatyczne efekty cząsteczkowe eksplozji granatów i smug strzałów oraz proceduralnie generowane przeszkody (drzewa dżungli).

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje zaawansowane zarządzanie kamerą w świecie o otwartej strukturze oraz efekty balistyczne:

- `lurek.camera` – Realizuje płynnie przewijaną w pionie kamerę (scrolling camera), która centrowana jest na środku ciężkości poruszającego się oddziału żołnierzy.
- `lurek.render` – Rysuje bogate środowisko dżungli (geometryczne korony drzew, pnie, wzniesienia), postacie żołnierzy i wrogów, trajektorie pocisków, rzucane łukowo granaty oraz rozbudowany panel HUD.
- `lurek.input` – Odpowiada za płynną obsługę jednoczesnego poruszania się i prowadzenia ognia w marszu bez blokowania klawiszy.
- `lurek.particle` – Generuje widowiskowe chmury pyłu, ognia i dymu przy wybuchu granatów oraz małe iskry przy zestrzeleniach.
- `lurek.tween` – Obsługuje dynamiczne pulsowanie flagi ewakuacyjnej, animacje interfejsu oraz przejścia ekranów misji.
- `lurek.timer` – Kontroluje odliczanie do wybuchu rzuconego granatu, częstotliwość ognia wrogów oraz mierzy Delta Time do fizyki poruszania się.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i poprawnym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To sztandarowy pokaz **kamery przewijanej w świecie 2D (world-space viewport and scrolling camera)** oraz **asynchronicznych pocisków balistycznych (projectile logic)**. Doskonale ilustruje, jak zaimplementować dynamiczną fizykę rzutu granatu po paraboli w osi Z (mimo widoku 2D z góry) z rozchodzeniem się fali uderzeniowej.
- **Unikalność**: Jedyna gra taktyczna z widokiem z góry (top-down tactical squad shooter) wprowadzająca **system trwałej straty jednostek (permadeath campaign)**, w której błędy gracza z poprzednich poziomów rzutują bezpośrednio na trudność kolejnych misji.
- **Podobne gry**: *Commando* (również shooter z góry), ale *Cannon Fodder* wyróżnia się dowodzeniem wieloosobowym oddziałem (squad mechanics) oraz permanentną śmiercią zamiast klasycznego systemu żyć i respawnów.
