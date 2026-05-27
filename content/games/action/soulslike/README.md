# Soulslike

_Wymagający pojedynek z potężnym bossem — zarządzaj energią (Stamina), wykonuj uniki z klatkami niezniszczalności, lecz się flakonami Estusa i przetrwaj 3 mordercze fazy walki._

## 🎮 O grze (About the Game)

**Soulslike** to zręcznościowa, bezwzględna gra akcji na zamkniętej kamiennej arenie, oddająca hołd kultowej formule gier z gatunku *Dark Souls*. Stawiasz czoła jednemu, potężnemu bossowi (The Forsaken Knight) posiadającemu unikalne, zmieniające się w locie fazy bojowe. Walka wymaga absolutnego skupienia, nauki wzorców ataków i bezbłędnego gospodarowania zasobami.

Najważniejsze mechaniki i systemy walki:
- **Zarządzanie Kondycją (Stamina Management)** – każdy atak lekki (Light), ciężki (Heavy), blok czy unik zużywa zielony pasek kondycji (maksymalnie 100 pkt). Wyzerowanie staminy wprowadza postać w **stan wyczerpania (Exhaustion)** na pełną 1 sekundę, blokując wszelkie akcje i wystawiając na zabójcze ciosy. Kondycja regeneruje się szybko (30 pkt/s), gdy nie wykonujesz żadnych akcji.
- **Unik (Dodge Roll) [L]** – błyskawiczny przewrót o 100 pikseli w kierunku ruchu, dający 0.3 sekundy całkowitej niewrażliwości na ciosy i pociski (invincibility frames).
- **Blokowanie [Spacja]** – trzymanie bloku redukuje otrzymywane obrażenia o 75%, ale każde uderzenie w tarcze kosztuje staminę.
- **Leczenie Estusem [E]** – dysponujesz 3 ładunkami flakonów Estusa, z których każdy przywraca 30 HP. Użycie leczenia nakłada na postać 1-sekundową blokadę ruchu (animation lock).
- **3 Fazy Bossa**:
  - **Faza 1 (100%–66% HP)**: Wolne, sygnalizowane 2-hitowe kombosy mieczem.
  - **Faza 2 (66%–33% HP)**: Boss staje się szybszy, dodaje szarże z uderzeniem oraz obszarowe uderzenie w ziemię (Ground Slam AoE).
  - **Faza 3 (33%–0% HP)**: Boss wpada w szał (czerwona poświata), zyskuje 4-hitowe kombosy oraz zasypuje arenę seriami ognistych pocisków plazmowych.
- **Efekt Uderzenia (Hitlag)** – gra zamraża animacje na zaledwie 0.05 sekundy przy udanym trafieniu (hitlag), nadając każdemu ciosowi niesamowicie fizyczne wyczucie ciężaru broni.

Śmierć gracza wywołuje kultowe, powolne przejście ekranu z krwawym napisem **"YOU DIED"** w zwolnionym tempie (slow-motion).

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/soulslike
```

## 🕹️ Sterowanie (Controls)

Sterowanie wymaga perfekcyjnej koordynacji i cierpliwości.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W, A, S, D** | Ruch bohatera | Przemieszczanie się po kamiennej arenie w 8 kierunkach |
| **J** | Atak lekki | Szybki cios mieczem (12 obrażeń, koszt: 15 staminy) |
| **K** | Atak ciężki | Wolny, potężny cios mieczem (25 obrażeń, koszt: 30 staminy) |
| **L** | Unik (Dodge Roll) | Przewrót w kierunku ruchu z klatkami niezniszczalności (koszt: 20 staminy) |
| **Spacja** (przytrzymanie) | Blok tarczą | Redukcja obrażeń o 75% kosztem kondycji przy zderzeniu |
| **E** | Flakon Estusa | Użycie leczenia (restauruje 30 HP, 3 ładunki, blokada animacji 1s) |
| **Enter** | Start / Restart | Uruchomienie pojedynku lub restart po ekranie YOU DIED |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Seria Dark Souls / Elden Ring stworzona przez FromSoftware (Hidetaka Miyazaki)**
  - *Opis powiązania*: Gra to genialny i bezkompromisowy hołd dla rewolucyjnej mechaniki wyzwań stworzonych przez FromSoftware. Nasza wersja w Lurek2D precyzyjnie rekonstruuje całe DNA gatunku: rygorystyczny system zarządzania kondycją (stamina management) karzący za agresywny button-mashing karą paraliżu (exhaustion lockout), niezniszczalne klatki uniku (i-frames roll) wymagające idealnego timingu, leczenie obarczone dużym ryzykiem zablokowania ruchu (Estus animation lock), oraz wielofazowy boss ewoluujący i zyskujący nowe, mordercze ataki. Hitlag nadaje ciosom ciężar rodem z mechaniki walki wielkim mieczem.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra reprezentuje absolutny szczyt dopracowania mechaniki pojedynkowej (gameplay polish) i kolizyjnej w Lurek2D:

- `lurek.camera` – Dynamicznie centruje widok areny, a także wykonuje spektakularne wstrząsy przy ciosach ciężkich oraz potężnych wybuchach AoE bossa.
- `lurek.render` – Rysuje kamienną arenę, cieniowaną sylwetkę bohatera (deformacje przy skokach/unikach), bossa z dynamicznym mieczem, krąg wybuchu AoE (Ground Slam), pociski, oraz zaawansowane nakładki HUD (paski HP i Staminy gracza, potężny dolny pasek HP bossa z nazwami faz, wskaźniki Estusa).
- `lurek.input` – Przechwytuje responsywne wejście, w tym przytrzymanie bloku (Space) i szybkie uniki.
- `lurek.particle` – Generuje rozbłyski przy cięciach (impact sparks), iskry blokowania tarczy, chmury dymu przy szarżach i uderzeniach AoE w ziemię, złoty blask leczenia Estusem oraz mroczne wybuchy przy zgonie bossa.
- `lurek.tween` – Kontroluje płynne skracanie pasków na HUD, powolną zmianę czasu (slow-motion time-scaling) po śmierci oraz krwawy napis YOU DIED.
- `lurek.timer` – Odpowiada za taktowanie regeneracji staminy, precyzyjne odliczanie czasu trwania wyczerpania i i-frames, czas hitlagu (0.05 sekundy) oraz wzorce ataków bossa.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To najwyższej klasy pokaz **zaawansowanego "game feel" (juice and hit confirmation)** – realizacja efektu **Hitlag** (krótkie zamrożenie klatki w czasie rzeczywistym oddające siłę uderzenia) oraz **dynamicznego spowalniania czasu (slow-motion system)** po śmierci. Uczy jak zaprojektować wielofazową, agresywną sztuczną inteligencję bossa (multi-phase boss AI state machine) w środowisku 2D.
- **Unikalność**: Jedyny **soulslike** w kolekcji oferujący rygorystyczny pasek kondycji (stamina bar) powiązany z karą wyczerpania, uniki oparte o ramki niewrażliwości (dodge i-frames), blokowanie tarczą oraz animowane leczenie Estusem.
- **Podobne gry**: *Fighting Game* (również bijatyka, ale bez staminy, uników i leczenia Estusem, o charakterze 2D z boku), *Roguelite* (również z widokiem z góry i zrywem, ale zorientowany na eksplorację lochów, walkę z chmarami wrogów i ulepszenia perków). *Soulslike* to czyste, surowe starcie z jednym kolosem wymagające bezbłędnej taktyki.
