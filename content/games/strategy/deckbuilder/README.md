# 🃏 Deckbuilder — Slay-the-Spire-Style Roguelike Card Battler

**Category:** Strategy / Roguelike CCG  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Deckbuilder** to wciągająca, taktyczna gra jednoosobowa typu roguelike z budowaniem talii (Roguelike Deckbuilder), będąca wiernym, minimalistycznym odwzorowaniem światowego hitu *Slay the Spire*. Jako samotny bohater przemierzasz kolejne piętra niebezpiecznej wieży, tocząc pojedynki z groźnymi potworami. Rozpoczynając ze skromnym zestawem podstawowych ciosów i bloków, po każdej wygranej walce wybierasz potężne nagrody karciane, optymalizując synergię swojej talii. Wykorzystaj unikalne mechaniki osłabiania przeciwników (Vulnerable), ogłuszania ich (Stun), tarcz blokujących ataki (Block) oraz darmowych ciosów (Rage), by pokonać bossa wieży — potężnego smoka!

### Pętla Rozgrywki i Mechaniki
1. **Wspinaczka po Piętrach (Floor Progress):** Twoja misja składa się z 3 trudnych starć na kolejnych piętrach:
   - **Floor 1:** Slime (Pasiak) — 30 HP, zadaje 7 obrażeń.
   - **Floor 2:** Goblin (Złośliwiec) — 45 HP, zadaje 10 obrażeń.
   - **Floor 3 (Finał):** Dragon (Smok Boss) — 65 HP, zadaje 14 obrażeń.
2. **System Energii i Tur (Turn Dials):**
   - W każdej turze gracz otrzymuje 3 punkty Energii (Energy) i dobiera 5 kart z talii. Wszystkie niewykorzystane karty z ręki na koniec tury lądują na stosie kart odrzuconych.
   - Kiedy stos dobierania opustoszeje, karty odrzucone są automatycznie tasowane i tworzą nowy stos dobierania.
3. **Katalog Kart i Synergie (Card Registry):**
   - **Strike (Uderzenie):** Koszt: 1 | Atak: 6 obrażeń.
   - **Defend (Obrona):** Koszt: 1 | Blok: +5 pancerza.
   - **Bash (Walnięcie):** Koszt: 2 | Atak: 8 obrażeń + nakłada status **Vulnerable (Wrażliwy)** na 2 tury (obrażenia zadawane wrogowi rosną o 50%!).
   - **Fireball (Kula ognia):** Koszt: 3 | Atak: 12 obrażeń.
   - **Shield+ (Super Tarcza):** Koszt: 1 | Blok: +8 pancerza.
   - **Slash (Cięcie):** Koszt: 1 | Atak: 9 obrażeń.
   - **Heal (Leczenie):** Koszt: 1 | Zaklęcie: przywraca 5 punktów życia.
   - **Rage (Szał):** Koszt: 0 | Atak: 3 obrażenia. Karta darmowa!
   - **Shockwave (Fala uderzeniowa):** Koszt: 2 | Atak: 10 obrażeń + nakłada status **Stun (Ogłuszenie)** na 1 turę (przeciwnik traci swoją kolejną turę!).
   - **Fortify (Wzmocnienie):** Koszt: 1 | Blok: +12 pancerza.
4. **Pancerz i Walka:** Blok (pancerz) absorbuje ataki przeciwnika w 100%, chroniąc Twoje cenne punkty życia. Niewykorzystany pancerz znika na początku Twojej kolejnej tury.
5. **Wybór Nagrody (Card Reward):** Pokonanie wroga na danym piętrze przenosi Cię do panelu wyboru karty nagrody. Możesz dobrać jedną z dwóch losowych kart (Q lub E), stale ulepszając i różnicując swoją talię przed kolejnym starciem.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Deckbuilder** is a deeply engaging, single-player roguelike card-crafting adventure (Roguelike Deckbuilder) designed in Lurek2D as a faithful, minimalist tribute to the global indie hit *Slay the Spire*. Climb a high-stakes, 3-floor tower of escalating threat. Start with a humble starter deck of standard Strikes and Defends, draft powerful card upgrades upon defeating hostile monsters, and optimize your deck's synergy as you ascend. Exploit unique status effects like multiplying damage via Vulnerability, stalling attacks via Stuns, buffering hits via Block armor, and playing free zero-cost maneuvers to slay the final boss — the legendary red Dragon!

### Gameplay Loop & Mechanics
1. **The Tower Climb (Floor Progress):** Ascend through 3 increasingly dangerous enemy encounters:
   - **Floor 1:** Slime (HP: 30, deals 7 damage).
   - **Floor 2:** Goblin (HP: 45, deals 10 damage).
   - **Floor 3 (Boss):** Dragon (HP: 65, deals 14 damage).
2. **Energy & Turn Dials:**
   - At the start of your turn, you draw 5 cards and receive 3 Energy. Any remaining cards on your hand at the end of the turn are discarded.
   - Once your draw pile empties, your discard pile is automatically shuffled back to form the new draw stack.
3. **Drafting Synergies (Card Registry):**
   - **Strike:** Costs 1 energy | Deals 6 damage.
   - **Defend:** Costs 1 energy | Grants 5 Block armor.
   - **Bash:** Costs 2 energy | Deals 8 damage and inflicts **Vulnerable 2** (the target receives 50% extra attack damage!).
   - **Fireball:** Costs 3 energy | Deals 12 heavy damage.
   - **Shield+:** Costs 1 energy | Grants 8 Block armor.
   - **Slash:** Costs 1 energy | Deals 9 damage.
   - **Heal:** Costs 1 energy | Restores 5 HP directly to your health pool.
   - **Rage:** Costs 0 energy | Deals 3 quick damage. Absolutely free!
   - **Shockwave:** Costs 2 energy | Deals 10 damage and inflicts **Stun 1** (skips the monster's next attack turn!).
   - **Fortify:** Costs 1 energy | Grants 12 massive Block armor.
4. **Armor Preservation:** Block armor acts as an AABB shield, absorbing enemy attacks entirely. Unused block armor decay at the start of your next turn.
5. **Card Rewards Drafting:** Slaying a monster transitions you to a reward drafting screen, presenting 2 random card options (draft with Q or E). Add these cards to your deck to evolve your arsenal before climbing to the next floor.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/deckbuilder
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **1 - 5** | Zagraj kartę z ręki | Zagrywa odpowiednią kartę z ręki (od lewej do prawej), jeśli masz wystarczająco energii. |
| **Enter (Return)** | Zakończ Turę (End Turn) | Kończy Twoją turę. Przeciwnik wykonuje swój ruch, a Ty dobierasz nową rękę. |
| **Q** | Nagroda: Wybierz lewą kartę | Wybiera pierwszą kartę nagrody w panelu draftu po wygranej walce. |
| **E** | Nagroda: Wybierz prawą kartę | Wybiera drugą kartę nagrody w panelu draftu po wygranej walce. |
| **Space (Spacja)** | Potwierdzenie / Restart | Rozpoczyna nową grę z ekranu tytułowego lub restartuje po wygranej/przegranej walce. |
| **Esc** | Wyjście | Zamyka bezpiecznie aplikację. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Slay the Spire (2019) by Mega Crit Games**
  - *Opis powiązania*: Bezpośrednie odwzorowanie rdzenia i mechaniki gry: system energii (3 na turę), pętla discardowania i tasowania kart, identyczne nazewnictwo kart startowych (Strike, Defend, Bash), nakładanie statusu Wrażliwości (Vulnerable) zwiększającego obrażenia o 50%, a także system wyboru kart nagród po każdej wygranej.
- **Monster Train (2020) by Shiny Shoe**
  - *Opis powiązania*: Obecność paska zapisu przebiegu pięter (Floor 1-3) oraz zróżnicowana i kolorowa typizacja kart (ataki czerwone, bloki niebieskie, leczenie zielone).
- **Hearthstone: Dungeon Run**
  - *Opis powiązania*: Wybór losowych kart do talii jako główny motor napędzający unikalność i siłę talii gracza na drodze do ostatecznego bossa.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Deckbuilder to znakomity pokaz zręcznych mechanik i efektów w silniku Lurek2D:
- `lurek.input` – Mapowanie akcji klawiatury dla cyfrowego wyboru kart (1-5), przycisku Enter dla tury, oraz Q/E w panelu nagród.
- `lurek.render` – Rysowanie pięknych, kolorowych kart o odmiennej przezroczystości (karty niedostępne z braku energii stają się półprzezroczyste), generowanie pasków zdrowia, statusów i tła za pomocą `rect` i `text_`.
- `lurek.timer` – Odmierzanie precyzyjnych czasów trwania komunikatów logów i zliczanie aktualnych FPS na pasku tytułowym.
- `lurek.event` – Bezpieczna realizacja wyjścia z gry przy naciśnięciu Esc.
- **Wbudowane Animacje Tweeningu:** Wykorzystywane do płynnej interpolacji ugięć paska HP bohatera oraz potwora w czasie rzeczywistym.
- **Dwa Niezależne Systemy Cząsteczek (Particles):**
  - *Cząsteczki Uderzenia (Hit Particles)*: Ognisto-czerwone iskry rozpryskujące się z wizerunku potwora lub gracza przy zadaniu obrażeń.
  - *Cząsteczki Blokujące (Card Particles)*: Błękitno-niebieskie cząsteczki energii otaczające tarczę gracza przy zagrywaniu bloków obronnych.
- **Konsola Logów Bitewnych (Battle Logs):** Dynamiczny system rejestrowania ostatnich akcji na dole ekranu, w którym napisy miękko wygaszają się za pomocą kanału alfa po 3 sekundach.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Fantastyczny pokaz zintegrowanego silnika cząsteczek, tweeningu HP i systemów logów tekstowych w Lurek2D. Udowadnia, że w silniku można łatwo stworzyć grę RPG/karcianą z pełną obsługą stosów (dobieranie, odrzucanie, tasowanie), zaawansowanym draftowaniem i dynamicznymi statusami bojowymi.
- **Unikalność (Uniqueness):** W odróżnieniu od klasycznej karcianki `card_game`, *Deckbuilder* kładzie nacisk na budowanie talii w trakcie rozgrywki (Deckbuilding), w którym gracz stale modyfikuje zawartość swojej talii, tworząc unikalne synergię z każdym podejściem.
- **Podobne gry (Similar Games):** Gra dzieli turowe mechaniki i ekonomię many z `card_game`, ale w odróżnieniu od niej nie posiada pozycjonowania jednostek na planszy, skupiając się na bezpośrednich pojedynkach 1v1 w stylu *Slay the Spire*.
