# 🚀 Social Deduction — Among Us-style Space Vessel Survival

**Category:** RPG / Tactical & Social Deduction  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Social Deduction** to wciągająca, taktyczna gra wieloosobowa offline z udziałem sztucznej inteligencji, inspirowana światowym hitem *Among Us*. Wciel się w rolę członka załogi statku kosmicznego wykonującego krytyczne misje utrzymania systemów podtrzymywania życia — lub wylosuj rolę bezwzględnego zdrajcy (traitora) sabotującego misję od wewnątrz. Wypatruj zagrożenia w ograniczonej mgłą wojny widoczności, zwołuj narady alarmowe, debatuj i głosuj nad wyeliminowaniem podejrzanych załogantów.

### Pętla Rozgrywki i Mechaniki
1. **Losowanie Ról:** Na początku gry (1/6 szans) zostajesz przydzielony jako **Zdrajca** (Traitor) lub **Członek Załogi** (Crewmate).
2. **Cele Załogi (Crewmates):** Musisz zlokalizować i ukończyć 8 rozproszonych po statku zadań (np. kalibracja nawigacji, przeciągnięcie karty, ładowanie reaktora). Podejdź do terminala oznaczonego wykrzyknikiem i przytrzymaj klawisz E przez 2 sekundy.
3. **Cele Zdrajcy (Traitor):** Twoim zadaniem jest skryta eliminacja załogi (klawisz E z bliska). Musisz uważać, by nie robić tego w obecności świadków! Świadkowie natychmiast zgłoszą to na naradzie, zwiększając wskaźnik podejrzenia (Suspicion).
4. **Sabotaże:** Jako zdrajca wywołujesz automatyczne awarie, np. wygaszenie świateł (Sabotage Lights Out), co drastycznie zmniejsza zasięg wzroku pozostałych załogantów.
5. **Ograniczone Pole Widzenia (Vision Radius):** Zasięg wzroku postaci jest ograniczony do 180 pikseli wokół niej. W czasie sabotażu spada do zaledwie 80 pikseli.
6. **Narady i Głosowanie (Emergency Meetings - M):** Naciśnij M, aby zwołać zebranie w stołówce. Wszyscy ocalali głosują na gracza o najwyższym współczynniku podejrzeń. Naciśnij klawisze 1-6, aby oddać swój głos. Gracz z większością głosów zostaje wyrzucony w próżnię.

---

## 🇬🇧 Game Description (English)

### Short Pitch (Elevator Pitch)
**Social Deduction** is a suspenseful offline tactical simulation inspired by the gaming phenomenon *Among Us*. Set aboard a top-down spaceship corridors layout, 6 players (1 human, 5 advanced AI agents) must maintain life-support systems by completing 8 crucial tasks—while a hidden Traitor sabotages devices and assassinates crew members. Work around limited vision cones, call emergency meetings to debate, and cast votes to eject the suspected traitor.

### Gameplay Loop & Mechanics
1. **Dynamic Role Selection:** At startup, you are randomly assigned (1/6 chance) as either the **Crewmate** or the **Traitor**.
2. **Crewmate Objective:** Track down and execute 8 tasks highlighted across 6 spaceship compartments (Bridge, Shields, Engine, Medbay, Reactor, Cafeteria). Hold E for 2 seconds at active yellow ports.
3. **Traitor Objective:** Assassinate the crew step-by-step (E at close range). Avoid killing in front of active crew witnesses; doing so triggers a severe suspicion multiplier.
4. **Traitor Sabotage:** Triggers periodic events like "Lights Out" which diminishes crew sight radius from `VISION_RADIUS = 180` down to `SABOTAGE_VISION = 80` alongside pulsing emergency alarms.
5. **Masked Sight Lines:** Visual rendering limits visibility using a circular overlay mask.
6. **Emergency Meetings (M) & Voting:** Call a summit (M) to convene at the Cafeteria. AI bots cast votes based on calculated suspicion arrays. Cast your vote (1-6). The majority vote ejects the suspect into space.

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **W, A, S, D / Strzałki** | Ruch postacią po statku | Move player around the ship corridors |
| **E** | Wykonaj zadanie / Zabij załoganta (jako Zdrajca) | Complete task / Eliminate crewmate (as Traitor) |
| **M** | Zwołaj zebranie alarmowe | Call Emergency Meeting |
| **1 – 6** | Głosuj na gracza o danym numerze na zebraniu | Vote for player index during meeting |
| **Escape** | Wyjście z gry | Quit to OS |

---

## 🛰️ Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
Gra nawiązuje bezpośrednio do gry **Among Us** (Innersloth, 2018) oraz klasycznych salonowych gier towarzyskich typu **Mafia** czy **Werewolf**. Przenosi kluczowe filary:
*   Wątek podejrzliwości i ukrytej tożsamości.
*   Zależność zadań od przetrwania — ukończenie zadań to alternatywna ścieżka zwycięstwa.
*   Faza zebrania jako jedyne demokratyczne narzędzie obrony przed mordercą.

### Modernizacja w Lurek2D
Lurek2D wspaniale symuluje to doświadczenie w trybie jednoosobowym dzięki:
*   **Sztucznej Inteligencji AI:** Zaawansowane profile załogantów realizują zadania, a sztuczny zdrajca poluje na odosobnione cele, oceniając brak obecności świadków przed atakiem.
*   **Wektorowej Mgle Wojny:** dynamiczne zaciemnianie krawędzi ekranu z pulsującym, fioletowym efektem podczas sabotażu oświetlenia nadaje grze niesamowitego klimatu grozy.

---

## 🛠️ Wykorzystane API silnika Lurek2D / Lurek APIs Showcased

*   `lurek.render`: Rysowanie podziału pomieszczeń statku kosmicznego, korytarzy, wektorowych okręgów graczy, znaczników zadań oraz interfejsu głosowania (`rectangle`, `circle`, `print`, `setColor`).
*   `lurek.input`: Obsługa dwuosiowego ruchu WASD, sprawdzanie zdarzeń jednostkowych (`wasActionPressed` dla narad i głosowań) oraz stanów ciągłych (`isActionDown` dla wykonywania zadań).
*   `lurek.camera`: Centrowanie rzutowania widoku kamery na pozycji gracza w czasie rzeczywistym (`setPosition`).
*   `lurek.tween`: Płynne, czasowe przejścia faz zebrania i animacja odliczania głosów (`to`).
*   `lurek.window` & `lurek.event`: Wyświetlanie FPS w pasku okna gry (`setTitle`) oraz bezpieczne zamknięcie programu (`quit`).

---

## 💎 Unikalność i Wartość Prezentacyjna / Showcase Value & Uniqueness

### Dlaczego ta gra jest wyjątkowa?
**Social Deduction** to wybitny pokaz **programowania sztucznej inteligencji (AI)** w silniku Lurek2D:
1.  **Złożone algorytmy decyzyjne botów:** Każdy bot niezależnie wyszukuje niedokończone zadania, przemieszcza się, wykonuje je oraz analizuje otoczenie. Bot-zdrajca potrafi zidentyfikować samotnego załoganta i zlikwidować go w cieniu.
2.  **Zaawansowany system Suspicion:** Boty posiadają tablice podejrzliwości i głosują logicznie na postacie, które zachowywały się podejrzanie, co udowadnia siłę skryptową Lurek2D-Lua.
3.  **Wspaniałe wektorowe tło:** Rysowanie statku kosmicznego w czasie rzeczywistym z płynną detekcją odległości.

To kompletny, genialny szablon dla programistów pragnących zaprojektować gry oparte na kooperacji sztucznej inteligencji, wykrywaniu kolizji i nieliniowych zachowaniach agentów w silniku Lurek2D!
