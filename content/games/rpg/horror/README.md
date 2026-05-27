# 🔦 Horror — Psychological Top-Down Horror Survival

**Category:** RPG / Psychological Horror  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Horror** to mroczny, dwuwymiarowy thriller survivalowy w rzucie z góry (Top-Down), zrealizowany w klimacie psychologicznego horroru science-fiction. Wciel się w rolę uwięzionego ocalałego w opuszczonym laboratorium. Wyposażony jedynie w latarkę o ograniczonym zasilaniu, musisz przemierzać pogrążone w niemal całkowitej ciemności korytarze, odnaleźć 5 kluczy bezpieczeństwa, czytać porzucone dzienniki i unikać przerażającego potwora, który bezustannie patroluje placówkę. Pamiętaj: ciemność niszczy Twoje zmysły — spędzenie zbyt wiele czasu bez światła doprowadzi Cię do szaleństwa i wywoła przerażające halucynacje!

### Pętla Rozgrywki i Mechaniki
1. **Zarządzanie Latarką (F):** Latarka emituje stożkowy snop światła (rozpiętość 0.6 radiana, zasięg 200px), podążający za ruchem postaci. Włączona latarka zużywa baterię (15%/s). Energię możesz odnawiać na zielonych stacjach ładowania.
2. **Mechanika Poczytalności (Sanity):** Przebywanie w ciemnościach (wyłączona latarka, rozładowana bateria) wysysa poczytalność (-5%/s).
    *   **Poniżej 50% poczytalności:** Ekran zaczyna falować, kolory ulegają przesunięciu, a obraz staje się niestabilny.
    *   **Poniżej 25% poczytalności:** W ciemnościach zaczynają pojawiać się czerwone, halucynacyjne stwory, które znikają po kilku chwilach.
    *   **0% poczytalności:** Umysł bohatera pęka — gra kończy się śmiercią z obłędu.
3. **Unikanie Przeciwnika:** Czerwona bestia patroluje korytarze według ustalonej ścieżki i zacznie Cię gonić, gdy tylko znajdziesz się w jej polu widzenia (i będziesz oświetlony). Kontakt z wrogiem to natychmiastowa śmierć. **Twoja jedyna obrona to skierowanie snopu światła latarki wprost na potwora — to zmusi go do panicznej ucieczki!**
4. **Scenariusz i Eksploracja:** Zbierz 5 żółtych kart dostępu, aby odblokować wyjście (czerwony kaflek EXIT w prawym dolnym rogu mapy). Po drodze czytaj zapiski badawcze (Note Reading Mode), by poznać dramatyczną historię placówki.
5. **Zjawiska Paranormalne (Scares):** Gra losowo generuje niepokojące zdarzenia (odgłosy kroków, szepty, nagłe trzaski drzwi), wywołując gwałtowne drżenie kamery i rozbłyski światła (efekt strachu).

---

## 🇬🇧 Game Description (English)

### Short Pitch (Elevator Pitch)
**Horror** is a high-tension, atmospheric psychological top-down survival horror. Arming yourself only with a depleting flashlight, you must navigate the pitch-black corridors of an abandoned underground research facility. Solve the mystery by gathering 5 missing security cards, reading survivor notebooks, and dodging a lethal patrolling monstrosity. Beware the darkness—stay in shadows too long, and your sanity will shatter, triggering color-shifted screen distortions, auditory panic cues, and terrifying hallucinations.

### Gameplay Loop & Mechanics
1. **Flashlight Dynamics (F):** Light is cast in a precise trigonometric cone (0.6 radians half-width, 200px range) that turns with your movement. Keeping the light on drains battery by 15%/s. Battery is recharged at glowing green generators.
2. **Sanity Thresholds:** Standing in pure darkness drains your sanity by 5%/s:
    *   **Below 50% Sanity:** The screen begins to warp and shake rhythmically, representing neurological deterioration.
    *   **Below 25% Sanity:** Red-eyed auditory ghost hallucinations briefly blink into existence in shadows.
    *   **0% Sanity:** Your mind breaks completely, resulting in an instant Game Over.
3. **Stalking Enemy AI:** A red creature patrols the map, immediately hunting you down if you enter its line of sight while illuminated. Contact is lethal. **Your sole defense: shine your flashlight directly at the monster to burn its eyes and force it into retreat!**
4. **Collectibles & Escape:** Scavenge for 5 keycards to open the terminal locked door in the southeast sector. Read 3 paper files (Notes) left by deceased scientists to compile lore.
5. **Paranormal Jumpscares:** Ambient scares (echoing footsteps, icy breathing on your neck, sudden door slams) trigger random particle flashes, camera shakes, and terrifying text messages.

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **W, A, S, D / ↑, ↓, ←, →** | Ruch postacią / Kierowanie latarki | Move around facility / Point flashlight cone |
| **F** | Włącz / Wyłącz latarkę | Toggle flashlight ON / OFF |
| **E** | Interakcja / Czytanie notatek / Dalej | Interact / Read log files / Close overlay |
| **Escape** | Wyjście z gry / Zamknięcie notatki | Exit to OS / Close active lore note |

---

## 📻 Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
Gra nawiązuje do klasycznych horrorów 2D i psychologicznych gier survivalowych z ery 16-bitowej i wczesnego PC (np. **Silent Hill**, **Darkwood**, **Clock Tower**, **Teleglitch**). Dzieli z nimi najważniejsze cechy:
*   Klaustrofobiczny klimat i bardzo małe pole widzenia gracza.
*   Zarządzanie zasobami (bateria do latarki, punkty zdrowia psychicznego) jako główna presja rozgrywki.
*   Poczucie bezbronności — gracz nie może zabić potwora, a jedynie spowolnić go lub przestraszyć światłem.
*   Głęboki lore ukryty w notatkach znajdowanych w świecie gry.

### Modernizacja w Lurek2D
Lurek2D wspaniale unowocześnia te mechaniki za pomocą wbudowanych systemów:
*   **Trzy Systemy Cząsteczkowe:** Efekt pyłków unoszących się w świetle reflektora (`dust_ps`), rozbłysk wstrząsów psychicznych (`flash_ps`) oraz zielona aura stacji ładujących (`glow_ps`).
*   **Wektorowa Trygonometria Oświetlenia:** Dokładne matematyczne wyznaczanie kątów stożka i odległości pozwala na idealne maskowanie cieni na kafelkach mapy w czasie rzeczywistym.
*   **Zaawansowana Praca Kamery (`lurek.camera`):** Płynne podążanie za graczem połączone z dynamicznym, fizycznie zanikającym drżeniem ekranu w momentach zagrożenia.

---

## 🛠️ Wykorzystane API silnika Lurek2D / Lurek APIs Showcased

*   `lurek.particle`: Równoległe zarządzenie trzema dedykowanymi systemami cząsteczek (`newSystem`, `emit`, `update`, `render`) dla pyłków światła, iskier grozy oraz aury ładującej.
*   `lurek.camera`: Płynne śledzenie gracza w czasie rzeczywistym oraz nakładanie dynamicznych wektorów wstrząsów o zmiennej amplitudzie (`setPosition`).
*   `lurek.render`: Rysowanie siatki korytarzy, wektorowych stożków oświetlenia (wykorzystanie trygonometrii `atan2`, `sin`, `cos`), wskaźników HUD oraz interaktywnych notatek (`rectangle`, `circle`, `print`, `line`, `setColor`).
*   `lurek.input`: Obsługa dwuosiowego ruchu WASD, sprawdzanie zdarzeń jednostkowych (`wasActionPressed` dla latarki/notatek) oraz stanów ciągłych (`isActionDown`).
*   `lurek.window`: Kontrola paska tytułowego okna i integracja z licznikiem klatek (`setTitle`).
*   `lurek.event` & `lurek.timer`: Bezpieczne wyjście z gry (`quit`) oraz precyzyjny pobór FPS (`getFPS`).

---

## 💎 Unikalność i Wartość Prezentacyjna / Showcase Value & Uniqueness

### Dlaczego ta gra jest wyjątkowa?
**Horror** to genialny przykład tworzenia **niezwykle nastrojowych gier klimatycznych** w Lurek2D. Udowadnia potęgę silnika w tworzeniu gier zorientowanych na atmosferę:
1.  **Pokazuje dynamiczny system oświetlenia wektorowego:** Bez zaawansowanych shaderów, za pomocą czystej geometrii silnik symuluje zachowanie latarki i cieni na siatce kafelków, co zapiera dech w piersiach od pierwszego uruchomienia.
2.  **Zaawansowane efekty poczytalności:** Falowanie kamery, rozmycie pozycji i dynamiczne wstrząsy idealnie oddają stan psychiczny głównego bohatera, budując niesamowite napięcie.
3.  **Wielosystemowość interaktywna:** Przeplatanie zręcznościowego unikania wroga, logicznego zbieractwa, dynamicznego ładowania baterii i czytania pełnoekranowych notatek z pauzowaniem czasu gry.

Ta demonstracja udowadnia, że Lurek2D to nie tylko proste arkadówki, ale platforma zdolna udźwignąć głębokie, trzymające w napięciu projekty narracyjne z elementami horroru!
