# 🃏 Card Game — Turn-Based Strategic Card Battler

**Category:** Strategy / Tactical CCG  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Card Game** to wciągająca, taktyczna karcianka turowa (Collectible Card Game - CCG), mocno inspirowana hitami takimi jak *Hearthstone* oraz *Magic: The Gathering*. Wciel się w rolę strategicznego maga, kontroluj limitowaną pulę many i skomponuj potężną linię obrony oraz ataku. Przyzywaj waleczne stwory o unikalnych zdolnościach (prowokacja, odrodzenie), rzucaj niszczycielskie lub wspomagające zaklęcia (kula ognia, leczenie, tarcza ochronna) i pokonaj sztuczną inteligencję przeciwnika, redukując jego punkty życia do zera. Gra łączy głęboką taktykę zarządzania zasobami z dynamicznymi efektami wizualnymi, tworząc wspaniały pokaz możliwości silnika Lurek2D.

### Pętla Rozgrywki i Mechaniki
1. **Zasoby i Mana:** Gracze rozpoczynają z 20 punktami życia (HP) i pulą 3 kryształów many. Co turę maksymalna mana rośnie o 1 punkt (aż do limitu 10) i w pełni się odnawia. 
2. **Dobieranie i Ekwipunek:** Obaj gracze posiadają talie złożone z 20 zbalansowanych kart. Na początku tury gracz dobiera 1 kartę (maksymalny rozmiar ręki to 8). Ręka układa się automatycznie w czytelny wachlarz na dole ekranu.
3. **Katalog Kart (Card Collection):**
   - **Kreatury (Creatures):** Posiadają punkty ataku (ATK) oraz zdrowia (HP). Nowo przyzwane stwory mają "Summoning Sickness" (nie mogą atakować w tej samej turze).
     - **Soldier (Żołnierz):** Koszt: 1 mana | Statystyki: 2/1. Tani wojownik.
     - **Wolf (Wilk):** Koszt: 2 mana | Statystyki: 3/2. Szybki drapieżnik.
     - **Knight (Rycerz):** Koszt: 3 mana | Statystyki: 3/4. Solidna linia frontu.
     - **Golem:** Koszt: 5 mana | Statystyki: 2/8 | Cecha: **Taunt (Prowokacja)** — przeciwnik musi najpierw zaatakować i pokonać Golema, zanim zrani inne jednostki lub maga!
     - **Phoenix (Feniks):** Koszt: 6 mana | Statystyki: 4/4 | Cecha: **Revive (Odrodzenie)** — po śmierci odradza się raz z połową zdrowia (2/2) w ognistym rozbłysku.
     - **Dragon (Smok):** Koszt: 7 mana | Statystyki: 6/5. Potężna bestia o niszczycielskiej sile ognia.
   - **Zaklęcia (Spells):** Natychmiastowe efekty modyfikujące pole bitwy:
     - **Shield (Tarcza):** Koszt: 1 mana. Dodaje wybranej sojuszniczej kreaturze +3 HP i zwiększa jej maksymalne zdrowie.
     - **Heal (Leczenie):** Koszt: 2 mana. Przywraca magowi +5 punktów życia.
     - **Fireball (Kula ognia):** Koszt: 3 mana. Zadaje 3 punkty obrażeń wybranej wrogiej kreaturze lub bezpośrednio wrogiemu magowi.
4. **Faza Walki i AI:**
   - Rozstaw swoje kreatury na 5 dostępnych slotach planszy (LMB). Kreatury, które przetrwały turę, są gotowe do ataku (oznaczone żółtym paskiem).
   - Zakończ turę (Space lub kliknięcie). Twoje stwory automatycznie przeprowadzą atak: uderzają we wrogie kreatury (priorytetyzując Prowokację, a następnie najsilniejsze jednostki) lub bezpośrednio wroga, jeśli jego linia obrony jest pusta. Walka odbywa się symultanicznie — jednostki zadają sobie obrażenia nawzajem.
   - **Tura AI:** Przeciwnik logicznie zagrywa karty (najdroższe na jakie go stać), kalkuluje ataki i rzuca czary w celu zniszczenia Twojego maga.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Card Game** is a highly engaging, tactical turn-based card battler (Collectible Card Game - CCG) heavily inspired by genre defining blockbusters like *Hearthstone* and *Magic: The Gathering*. Assume the role of a strategic arcanist managing a dynamic mana pool to field armies and command magical assets. Summon valiant creatures with unique passive traits (Taunt blockades, Phoenix revivals), sling devastating targeted spells (Fireballs, Shields, Holy Heals), and dismantle the opposing AI's deck by driving their health pool to zero. Perfecting the delicate balance between active board control, health preservation, and mana curve investing represents a true testament to the tactical depth supported by Lurek2D!

### Gameplay Loop & Mechanics
1. **Resource Dials (Mana Curve):** Players begin with 20 Health Points (HP) and 3 active Mana crystals. At the start of each turn, maximum mana capacity increases by 1 crystal (up to a ceiling of 10) and fully replenishes.
2. **Deck & Card Draw:** Both players start with identical, shuffled 20-card decks. Drawing occurs at the start of each turn (capped at an 8-card hand). Cards dynamically scale and slide along the bottom overlay.
3. **The Card Registry (Deck Build):**
   - **Creatures:** Possess Attack (ATK) and Health (HP) stats. Summoned creatures undergo summoning sickness, preventing attacks on their entry turn.
     - **Soldier:** Costs 1 mana | Stats: 2/1. Efficient early pressure.
     - **Wolf:** Costs 2 mana | Stats: 3/2. Swift damage dealer.
     - **Knight:** Costs 3 mana | Stats: 3/4. Relentless frontliner.
     - **Golem:** Costs 5 mana | Stats: 2/8 | Trait: **Taunt** — forces enemy creatures and spells to target the Golem before damaging other friendly units or the hero.
     - **Phoenix:** Costs 6 mana | Stats: 4/4 | Trait: **Revive** — upon receiving fatal damage, rises once from the ashes with 50% HP (2/2) in a burst of fire particles.
     - **Dragon:** Costs 7 mana | Stats: 6/5. High-threat boss beast.
   - **Spells:** Instantaneous magical adjustments:
     - **Shield:** Costs 1 mana. Grants +3 HP and extends maximum health to a chosen friendly unit.
     - **Heal:** Costs 2 mana. Restores +5 HP directly to your hero's health pool.
     - **Fireball:** Costs 3 mana. Hurls a fiery blast dealing 3 damage to any selected enemy creature or the enemy hero.
4. **Autonomous AI & Combat resolution:**
   - Deploy creatures to 5 dedicated slots on the battlefield. Ready attackers are highlighted with a glowing yellow indicator.
   - Press Space or click the End Turn button to trigger the combat phase. Creatures exchange blows simultaneously (creatures retaliate using their ATK stat, damaging attackers).
   - **AI Strategy:** The opponent dynamically evaluates playable hands (prioritizing top cost cards), directs physical attacks at your vulnerabilities, and casts targeted spells to destroy you.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/card_game
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **LMB (Lewy Klik)** | Wybór / Zagranie karty | Wybiera kartę z ręki. Kliknięcie na slot pola (dla stwora) lub na cel (dla czaru) zagrywa ją. |
| **Space (Spacja)** | Zakończ Turę (End Turn) | Kończy Twoją turę i uruchamia automatyczną fazę walki kreatur. |
| **Esc** | Wyjście | Zamyka bezpiecznie aplikację. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Hearthstone (2014) by Blizzard Entertainment**
  - *Opis powiązania*: Bezpośrednie odwzorowanie rdzenia mechaniki: system przyrostu many od 1 do 10, paski zdrowia i ataku jednostek (ATK/HP), mechanika **Taunt** wymuszająca ataki na konkretne kreatury, syndrom zmęczenia przywoływaniem oraz rzucanie czarów bezpośrednio na cele na planszy.
- **Magic: The Gathering (MTG)**
  - *Opis powiązania*: Koncepcja jednoczesnej walki i obrony (simultaneous damage exchange), w której stwory broniące zadają obrażenia atakującym w oparciu o swój współczynnik siły.
- **Slay the Spire by Mega Crit**
  - *Opis powiązania*: Minimalistyczny, czytelny design kart z barwnymi paskami przynależności, dynamicznie przesuwającymi się kartami po zaznaczeniu oraz minimalistyczny interfejs walki taktycznej.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Card Game w mistrzowski sposób eksponuje możliwości Lurek2D:
- `lurek.input` – Zaawansowane pobieranie koordynatów myszy w celu precyzyjnego wykrywania kliknięć kart na ręce (względny start_x i card_gap) oraz celowania czarami w sloty jednostek.
- `lurek.render` – Rysowanie planszy (sloty, paski HP, kryształy many, grafika kart ze statystykami za pomocą poleceń `rect`, `circ` i `text_`).
- `lurek.camera` – Wdrożenie wirtualnej kamery viewportu (`lurek.camera.new`) zapewniającej wycentrowany widok pola walki.
- `lurek.timer` – Odmierzanie precyzyjnego czasu delta (`dt`) i sterowanie zegarem AI w fazie tury przeciwnika.
- `lurek.event` – Prawidłowa i bezpieczna realizacja wyjścia z gry przy naciśnięciu klawisza Esc.
- **Wbudowane Animacje Tweeningu:** Wykorzystywane do dynamicznego wysuwania kart z dołu ekranu podczas dobierania (z ujemnego offsetu) oraz do płynnego i miękkiego animowania paska HP gracza i przeciwnika.
- **Efekt Drżenia Ekranu (Screen Shake):** Wykorzystanie precyzyjnej trzęsącej się offsetowej kamery (`shake_timer`) przy silnych uderzeniach kulą ognia lub bezpośrednich atakach na wizerunek gracza.
- **Bogaty System Cząsteczek (Particles):**
  - *Ogień (Fireball)*: Pomarańczowo-czerwona eksplozja iskier w punkcie uderzenia kuli ognia.
  - *Leczenie (Heal)*: Jasnozielone cząsteczki zdrowia lecące ku górze z panelu życia gracza.
  - *Tarcza (Shield)*: Błękitne drobiny energii otaczające wzmocnioną kreaturę.
  - *Odzyskanie (Phoenix Revive)*: Jasnoczerwone i złote gejzery ognia w momencie zmartwychwstania Feniksa.
  - *Rozpad (Debris)*: Cząsteczki w kolorze pokonanej kreatury rozsypujące się w momencie jej śmierci.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Najbardziej zaawansowana gra karciana w portfolio. Stanowi wspaniały przykład pełnej sztucznej inteligencji AI, która potrafi logicznie zarządzać swoimi zasobami many, podejmować decyzje o priorytetach celów i rzucaniu zaklęć, oraz zarządzać złożonymi mechanikami stanów (SUMMONING_SICKNESS, TAUNT, REVIVE, COMBAT_PHASES) zachowując perfekcyjną czytelność kodu.
- **Unikalność (Uniqueness):** Jedyny turowy system karciany w bibliotece gier. Gra stawia w 100% na logiczny, taktyczny charakter, w którym losowość ogranicza się do doboru kart, a o zwycięstwie decyduje planowanie tura po turze.
- **Podobne gry (Similar Games):** Gra dzieli turowy charakter i paski HP z `deckbuilder`, ale w odróżnieniu od niego posiada fizyczne pozycjonowanie kreatur na planszy opartej na slotach, co zbliża ją do klasycznych gier typu auto-battler lub CCG.
