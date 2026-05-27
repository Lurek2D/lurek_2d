# 📖 Visual Novel — Branching Story & Affection System RPG

**Category:** RPG / Visual Novel & Narrative Simulation  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Visual Novel** to kompletna, wielowątkowa gra powieściowa w duchu japońskich klasyków. Wciel się w rolę nowego kadeta na prestiżowej Akademii Studiów Astralnych. Poznaj troje niezwykłych studentów — cichą bibliotekarkę Lunę, pewnego siebie wojownika Sola i genialną badaczkę anomalii Novą. Podejmuj nieliniowe decyzje, kształtuj relacje za pomocą wbudowanego systemu punktów sympatii (Affection System) i pomóż uratować Akademię przed katastrofalnym wybuchem energii. Twoje wybory zadecydują o tym, z kim połączysz siły i jakie z 3 unikalnych zakończeń odblokujesz!

### Pętla Rozgrywki i Mechaniki
1. **Trzyaktyczna Opowieść (Act 1 ➔ Act 2 ➔ Act 3):**
    *   **Act 1: Arrivals (Przybycie):** Poznajesz bohaterów, zwiedzasz bibliotekę, arenę treningową i obserwatorium astronomiczne. Dokonujesz pierwszych wyborów dialogowych.
    *   **Act 2: The Crisis (Kryzys):** Nad Akademią wybucha groźna anomalia energetyczna. Musisz podjąć kluczową decyzję, komu pomożesz w opanowaniu zagrożenia.
    *   **Act 3: Resolution (Rozwiązanie):** Finał historii oraz odblokowane zakończenie zależą od tego, która z postaci ma najwyższy wskaźnik sympatii.
2. **System Sympatii (Affection Tracking):** Każdy wybór w grze przyznaje od +10 do +20 punktów sympatii wybranej postaci, a czasami odejmuje -5 od innych. Wyniki są dynamicznie kalkulowane.
3. **Portrety i Wektorowe Scenerie:** Każda postać ma swój unikalny kolorowy profil i płynne wejścia/wyjścia (tweens). Tła scenerii zmieniają kolor w zależności od lokacji (biblioteka, lab, arena).
4. **Wygodne Funkcje Replay:**
    *   **Auto-Advance (Tab):** Automatyczne przewijanie tekstu z 3-sekundowym opóźnieniem.
    *   **Skip Mode (S):** Pomijanie tekstu typewriter i szybkie przechodzenie bezpośrednio do kolejnych wyborów decyzyjnych (świetne do ponownego przechodzenia gry).
    *   **History Log (H):** Otwiera przewijany panel z historią 10 ostatnich linijek dialogowych.
5. **Zakończenia (3 Endings):**
    *   📘 **Luna Ending** — Spokojne życie w archiwach bibliotecznych.
    *   📙 **Sol Ending** — Wyruszenie w nieznane w poszukiwaniu wielkiej przygody.
    *   🌸 **Nova Ending** — Praca w zespole badawczym anomalii i naukowe przełomy.

---

## 🇬🇧 Game Description (English)

### Short Pitch (Elevator Pitch)
**Visual Novel** is a feature-rich branching narrative simulation built in Lurek2D. Step into the sprawling halls of the Academy of Astral Studies as a new student. Engage with three brilliantly written characters: Luna, the shy archivist; Sol, the bravado warrior; and Nova, the eccentric anomaly scientist. Navigate dynamic visual transitions, manage your character affection scores through tactical choices, and survive a magical energy crisis to unlock three separate character-bound endings.

### Gameplay Loop & Mechanics
1. **Three-Act Narrative Structure:**
    *   **Act 1 — Arrivals:** Meet all three classmates, visit their workplaces, and establish initial bonding scores.
    *   **Act 2 — The Crisis:** A violent energy anomaly threatens the Academy structure. You must select which friend to back—a major fork in the story tree.
    *   **Act 3 — Resolution:** The ending acts evaluate runtime affection scales to determine the final epilogue.
2. **Affection Multipliers:** Conversational branches award +10 to +20 sympathy points to targeted characters, with some options applying -5 penalties to rivals.
3. **Responsive Visuals:** Character slots enter and slide using mathematical frametime lerps. Scene background gradients morph color palettes to match locations.
4. **Replay & QoL Toolsets:**
    *   **Auto-Advance (Tab):** Automatically slides lines forward with a convenient 3-second pacing delay.
    *   **Skip Mode (S):** Speeds past the typewriter print, halting only at branching selection overlays (perfect for exploring endings).
    *   **History Overlay (H):** Toggles a translucent frame reviewing the last 10 dialog lines.
5. **Epilogue Verdicts (3 Endings):**
    *   📘 **Luna:** Peace in the catalog archives, analyzing ancient relics.
    *   📙 **Sol:** Embarking on a glorious quest into uncharted wilderness.
    *   🌸 **Nova:** Making groundbreaking scientific strides in anomaly containment.

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **Space** | Przejdź dalej / Zaakceptuj wybór | Advance dialogue line / Proceed |
| **1 / 2 / 3** | Wybór opcji dialogowej (podczas decyzji) | Select branching choice option |
| **S** | Włącz / Wyłącz tryb szybkiego pomijania (Skip Mode) | Toggle dialogue skip mode |
| **Tab** | Włącz / Wyłącz tryb autoodtwarzania (Auto-Advance) | Toggle automatic dialogue slide (3s delay) |
| **H** | Pokaż / Ukryj historię ostatnich wypowiedzi (Log) | Toggle history dialogue logs overlay |
| **F3** | Pokaż / Ukryj wskaźnik FPS | Toggle debug frame-rate counter |
| **Escape** | Wyjście z gry | Quit to OS |

---

## 🎭 Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
Gra stanowi hołd dla pionierskich japońskich powieści wizualnych (Visual Novels) z lat 90. (np. **Fate/stay night**, **Steins;Gate**, gry wydawnictwa **Key** oraz RPG typu **Dating Sim**). Odtwarza ich flagowe mechaniki:
*   Format narracyjny oparty na dialogach wyświetlanych w dużym oknie u dołu ekranu.
*   System portretów postaci wchodzących i wychodzących ze sceny w zależności od tego, kto aktualnie mówi.
*   Śledzenie ukrytych statystyk relacji determinujących ostateczny epilog (Affection-based endings).

### Modernizacja w Lurek2D
Silnik Lurek2D wzbogaca to klasyczne doświadczenie o wspaniałe, płynne urozmaicenia wizualne:
*   **Płynne Animacje Portretów (Portraits Tweens):** Portrety Luna, Sol i Nova nie pojawiają się skokowo — wsuwają się z boków ekranu z płynną regulacją przezroczystości za pomocą interpolacji matematycznej `lerp` czasu delty.
*   **Efekty Cząsteczkowe:** Każde przejście aktu wyzwala deszcze ambientowych cząsteczek (`spawn_transition`). Zablokowanie wyboru wyzwala barwne rozbłyski dopasowane do charakteru wybranego bohatera.

---

## 🛠️ Wykorzystane API silnika Lurek2D / Lurek APIs Showcased

*   `lurek.render`: Rysowanie chmury dialogowej z zaawansowaną regulacją przezroczystości (`text_box_alpha`), tablic wyboru, wskaźników sympatii postaci oraz portretów geometrycznych (`rectangle`, `circle`, `print`, `setColor`).
*   `lurek.input`: Wykrywanie precyzyjnych naciśnięć klawiatury dla celów interaktywnego wyboru ścieżek dialogowych i obsługi klawiszy funkcyjnych (H, S, Tab).
*   `lurek.timer`: Odmierzanie precyzyjnych interwałów czasu dla autoodtwarzania, animacji typewriter oraz pobierania FPS (`getFPS`, `getTime`).
*   `lurek.window` & `lurek.event`: Dynamiczne aktualizowanie paska nazwy okna o aktualną płynność działania (`setTitle`) oraz bezpieczne zamykanie gry (`quit`).

---

## 💎 Unikalność i Wartość Prezentacyjna / Showcase Value & Uniqueness

### Dlaczego ta gra jest wyjątkowa?
**Visual Novel** to jeden z najbardziej dopracowanych, wielowątkowych projektów w całym portfolio Lurek2D:
1.  **Pokazuje zaawansowany stan narracyjny:** Zarządzanie skomplikowaną strukturą scen o zmiennej liczbie uczestników, automatyczne wyliczanie sympatii i przekierowywanie wątków na bazy danych w Lua.
2.  **Doskonałe systemy wspomagające (QoL):** Implementacja trybu Skip Mode i Auto-Advance na poziomie kodu uczy twórców tworzenia profesjonalnych, gotowych na rynek komercyjny interfejsów przyjaznych użytkownikowi.
3.  **Wspaniała wektorowa grafika dynamiczna:** Wykorzystanie czystych prymitywów wektorowych z efektami cieniowania, lerpów i emiterów cząsteczek daje fenomenalny, nowoczesny efekt wizualny (glassmorphism UI) bez użycia zewnętrznych plików PNG.

To bezkonkurencyjny szablon edukacyjny dla każdego dewelopera pragnącego stworzyć własną grę tekstową, nieliniową przygodówkę RPG lub tradycyjną powieść wizualną na silniku Lurek2D!
