# Vertical Climber

_Nieskończona wspinaczka w stylu Doodle Jump — odbijaj się automatycznie od różnorodnych platform, strzelaj do wrogów, owijaj ekran i wspinaj się jak najwyżej w proceduralnie generowanym świecie._

## 🎮 O grze (About the Game)

**Vertical Climber** to wciągająca, pionowa platformówka zręcznościowa z niekończącą się wspinaczką. Sterujesz stale skaczącym bohaterem, którego celem jest dotarcie na jak najwyższą wysokość. Gra rezygnuje z tradycyjnego przycisku skoku – postać **odbija się automatycznie** w momencie kontaktu stóp z podłożem.

Gra oferuje zaawansowany zestaw mechanik środowiskowych:
- **Owijanie ekranu (Screen Wrapping)** – wylatując poza lewą krawędź ekranu, natychmiastowo teleportujesz się na prawą stronę (i odwrotnie), co pozwala na dynamiczne ucieczki.
- **Różnorodne typy platform**:
  - **Normalne (Zielone)** – stabilne, standardowe podłoża.
  - **Ruchome (Niebieskie)** – poruszają się wahadłowo w poziomie.
  - **Kruche (Brązowe)** – rozpadają się i spadają w przepaść jako odłamki ułamek sekundy po wylądowaniu.
  - **Super-sprężyny (Żółte)** – wystrzeliwują bohatera dwukrotnie wyżej z dynamiczną animacją rozprężania sprężyny.
- **Przeciwnicy i Strzelanie** – na platformach patrolują czerwone stworki. Kontakt z nimi jest śmiertelny, ale możesz je zestrzelić za pomocą pocisków wystrzeliwanych pionowo w górę (klawisz W/Spacja).
- **Proceduralny generator pionowy (Procedural Generation)** – nowe platformy generują się automatycznie nad górną krawędzią kamery w miarę wspinaczki. Stopień trudności płynnie rośnie wraz z wysokością (rzadziej generują się platformy stabilne, pojawia się więcej platform kruchych i ruchomych).

Wynik końcowy zależy od maksymalnego osiągniętego pułapu wysokości.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/vertical_climber
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o prosty, responsywny schemat akcji bocznych i bojowych.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **←** | Ruch w lewo | Przechylenie lotu w lewą stronę (z owijaniem krawędzi) |
| **D** / **→** | Ruch w prawo | Przechylenie lotu w prawą stronę (z owijaniem krawędzi) |
| **Spacja** / **W** | Strzał w górę | Wystrzelenie pocisku pionowo w górę w celu likwidacji wroga |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Doodle Jump (2009) stworzony przez Lima Sky** oraz **klasyk automatowy Icy Tower**
  - *Opis powiązania*: Gra stanowi wyśmienitą i wierną rekonstrukcję rewolucyjnej gry mobilnej, która zdefiniowała gatunek pionowych wspinaczek (*vertical auto-jumpers*). Nasza wersja Lurek2D doskonale odwzorowuje **płynne przewijanie kamery w osi Y (vertical scroll snap)**, cztery unikalne, interaktywne typy platform (w tym kruszące się i sprężynujące z zaawansowaną animacją deformacji) oraz owijanie boków ekranu. Wzbogaciliśmy wersję o nowoczesne cząsteczki rozpadu kruchych belek, smugi dymne skoków oraz tablicę rekordów sesji.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra reprezentuje wysoki poziom obsługi dynamicznych generatorów świata i fizyki odbić:

- `lurek.camera` – Kontroluje pionowy ruch kamery, płynnie podnosząc się wyłącznie wtedy, gdy gracz przekroczy połowę wysokości ekranu, i blokując opadanie kamery w dół.
- `lurek.render` – Rysuje zróżnicowane graficznie platformy (zielone, ruchome niebieskie, kruszące się brązowe, żółte z cewką sprężyny), animowaną postać gracza (rozciąganie przy skoku i spłaszczanie przy uderzeniu – squash & stretch), latających wrogów, lecące pociski oraz HUD wysokości.
- `lurek.input` – Przechwytuje responsywne sterowanie bezwładnością ruchu na osi X oraz wyzwala strzały.
- `lurek.particle` – Generuje odłamki ziemi (debris) spadające przy zniszczeniu kruchych platform, iskry po zestrzeleniu wroga, smugi ciągu przy wystrzale ze sprężyny oraz pył przy standardowym odbiciu.
- `lurek.tween` – Animuje rozciąganie sprężyny, pulsowanie rekordu oraz ekrany przejść.
- `lurek.timer` – Kontroluje Delta Time, fizykę grawitacji i bezwładności na osi X oraz animacje klatek.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To kapitalny pokaz **pionowej kamery śledzącej jednokierunkowo (one-way vertical tracking camera)**, która nie pozwala cofnąć się w dół (upadek oznacza porażkę), oraz **proceduralnej generacji nieskończonego świata (infinite procedural generation)** w locie na bazie wysokości gracza. Prezentuje również doskonałe wdrożenie plastycznej animacji postaci (squash & stretch) na podstawie wektora prędkości pionowej.
- **Unikalność**: Jedyna pionowa platformówka z automatycznym odbijaniem (vertical auto-jumper) w kolekcji, oferująca **proceduralny wzrost trudności wysokościowej** i 4 zróżnicowane fizycznie zachowania podłoży.
- **Podobne gry**: *Platformer*, *Giana Sisters* (platformówki kafelkowe), ale *Vertical Climber* odróżnia się pionową strukturą nieskończoną, całkowitym brakiem przycisku skoku (auto-jump) oraz proceduralną generacją, co czyni ją całkowicie odmiennym doświadczeniem.
