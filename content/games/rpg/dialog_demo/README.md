# 💬 Dialog Demo — Branching Dialogue & Conversation System

**Category:** RPG / Narrative Engine  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Dialog Demo** to zaawansowana demonstracja kompletnego, nieliniowego systemu dialogowego z drzewami wyboru, efektami typewriter (maszynopisu) i dynamicznymi scenami w tle. Wciel się w rolę wędrowca przemierzającego świat i rozmawiaj z napotkanymi postaciami — mędrcem w lesie, kupcem w sklepie oraz strażnikiem u bram miasta. Twoje decyzje wpływają na relacje z rozmówcami, co odblokowuje unikalne ścieżki dialogowe i decyduje o ostatecznym werdykcie lojalnościowym.

### Pętla Rozgrywki i Mechaniki
1. **Scena 1: Las (The Forest):** Spotkanie z Mędrcem (Sage) — wybierz temat rozmowy (szukanie mądrości, niebezpieczeństwa bramy, sekrety kupca). Twój wybór ustala flagi fabularne wykorzystywane w kolejnych scenach.
2. **Scena 2: Sklep (The Shop):** Rozmowa z Kupcem (Merchant) — możesz kupić tarczę (i negocjować cenę, co kupiec zapamięta!), kupić rzadkie eliksiry lub wymienić przysługę na kluczowe informacje wywiadowcze o strażniku.
3. **Scena 3: Brama (The Gate):** Konfrontacja ze Strażnikiem (Guard) — strażnik blokuje przejście do miasta. Możesz spróbować przejść siłą (co go rozgniewa), powołać się na znajomości zebrane wcześniej lub udowodnić swoją szczerość.
4. **Maszyna Stanów Dialogu (Node System):** Pod maską działa autorski interpreter stanów w Lua, obsługujący cztery typy węzłów:
    *   `say`: Wyświetla wypowiedź danej postaci.
    *   `choice`: Prezentuje interaktywne opcje wyboru i kieruje do odpowiednich odgałęzień.
    *   `wait`: Wprowadza naturalne pauzy czasowe między dialogami.
    *   `event`: Wykonuje dowolne funkcje Lua w tle (np. modyfikowanie punktów reputacji, zmiana grafiki w tle).
5. **Historia Konwersacji (Dialog Log):** W lewym górnym rogu ekranu stale wyświetlany jest przewijany dziennik 8 ostatnich wypowiedzi.
6. **Autoodtwarzanie i Pomijanie:** Gracz może włączyć automatyczne przewijanie (2 sekundy opóźnienia) lub natychmiastowo wyświetlić cały tekst z pominięciem animacji typewriter.

---

## 🇬🇧 Game Description (English)

### Short Pitch (Elevator Pitch)
**Dialog Demo** is a comprehensive, production-ready narrative scripting system built from scratch in Lurek2D. Navigate a branching dialogue story across three beautifully drawn vector scenes. Engage with three distinct NPCs—the forest Sage, the village Merchant, and the gate Guard—where every conversational branch shapes your reputation, sets global flags, and determines how characters react to your presence.

### Gameplay Loop & Mechanics
1. **Scene 1: Forest (Sage):** Choose your focus (wisdom, merchant secrets, gate threats) to gain initial modifiers and narrative flags.
2. **Scene 2: Shop (Merchant):** Deal with the shopkeeper. Choose to buy equipment (haggling lowers relations but saves money!), purchase rare potions, or trade respect for actionable intelligence about the gatekeeper.
3. **Scene 3: Gate (Guard):** Confront the suspicious gate guard. Use your reputation, names of mutual contacts, peaceful transparency, or aggressive intimidation to earn passage.
4. **Narrative Node-Based Engine:** Dialog paths are parsed via four highly configurable Node types:
    *   `say`: Outputs speech with speaker colors.
    *   `choice`: Halts narration to display selectable branches.
    *   `wait`: Introduces programmatic cinematic delays.
    *   `event`: Executes raw Lua logic on-the-fly (triggers scene changes, changes stats, sets flags).
5. **Dynamic Conversation Log:** A scrollable overlay in the top-left tracks the last 8 turns of dialogue for accessibility.
6. **Juice & Quality-of-Life:** Supports instant typewriter skipping (S) and a fully automated auto-advance mode (Tab) with a 2-second pacing window.

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **Space** | Przewiń dialog dalej | Advance dialogue line |
| **1 / 2 / 3** | Wybór opcji dialogowej (podczas drzew wyboru) | Select branching dialogue option |
| **Tab** | Włącz / wyłącz tryb automatyczny (Auto-Advance) | Toggle automatic slide progression (2s delay) |
| **S** | Pomiń typewriter (pokaż całą linię tekstu natychmiast) | Skip typewriter, show complete line instantly |
| **F3** | Pokaż / ukryj licznik FPS | Toggle debug FPS counter overlay |
| **Escape** | Wyjście z gry | Quit to OS |

---

## 🎭 Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
System jest głęboko zakorzeniony w klasycznych grach przygodowych typu **Visual Novel** oraz RPG ze złotych lat (np. **Fallout 1/2**, **Planescape: Torment**, gry firmy **LucasArts**). Dzieli z nimi fundamentalne cechy:
*   Prezentacja portretów/imion postaci z dedykowanymi profilami kolorystycznymi.
*   Logicznie zagnieżdżone warunki — postacie pamiętają to, co zrobiłeś w poprzednich rozdziałach.
*   Werdykt na podstawie relacji — ocena działań gracza i podsumowanie reputacji na końcu gry.

### Modernizacja w Lurek2D
Silnik Lurek2D wnosi zaawansowane efekty estetyczne realizowane bezpośrednio w skrypcie:
*   **Dynamiczne Cząsteczki (Game Juice):** Pojawienie się chmury tekstu wyzwala urocze bąbelki (`bubble_particles`) dopasowane do barwy rozmówcy. Zablokowanie wyboru wyzwala złote iskry (`sparkle_particles`) z grawitacyjnym opadaniem.
*   **Wektorowe Tła Dynamiczne:** Trzy wspaniałe scenerie są generowane za pomocą matematyki Lurek2D w locie — od migoczących świetlików w lesie, przez migotanie lampionu w sklepie, po płonące pochodnie i migoczące gwiazdy przed bramą miasta.

---

## 🛠️ Wykorzystane API silnika Lurek2D / Lurek APIs Showcased

*   `lurek.render`: Rysowanie złożonych wektorowych środowisk tła, bąbelków wypowiedzi, pasków wyboru z pulsowaniem amplitudy i chmur dialogowych (`rectangle`, `circle`, `print`, `setColor`).
*   `lurek.input.keyboard`: Wygodne wykrywanie wciśnięć klawiszy funkcyjnych (`isDown`) dla wyboru opcji (1/2/3), pomijania (S) oraz autoodtwarzania (Tab).
*   `lurek.timer`: Odmierzanie precyzyjnych interwałów czasu dla węzłów typu `wait`, efektów pulsowania podświetleń (`getTime`) oraz wskaźnika wydajności (`getFPS`).
*   `lurek.window`: Kontrola paska okna systemowego i zmiana nazwy aplikacji (`setTitle`).
*   `lurek.event`: Wywołanie poprawnego zamknięcia gry przez system zdarzeń (`quit`).

---

## 💎 Unikalność i Wartość Prezentacyjna / Showcase Value & Uniqueness

### Dlaczego ta gra jest wyjątkowa?
Większość pokazów technologicznych silników 2D skupia się na grafice bitmapowej lub fizyce. **Dialog Demo** to potężne narzędzie prezentacyjne, które udowadnia, że Lurek2D jest **niezwykle elastyczny przy projektowaniu gier RPG o wysokiej liczbie dialogów**:
1.  **Pokazuje autorski parser scen:** Cała gra działa na czystej tabeli węzłów Lua bez potrzeby kompilowania zewnętrznych systemów (takich jak Ink czy Yarn Spinner). To doskonały punkt wyjścia dla twórców chcących zbudować grę narracyjną.
2.  **Doskonała prezentacja cząsteczek wektorowych:** Zamiast ładować ciężkie tekstury, gra udowadnia, jak setki małych kółek i kwadratów wektorowych rysowanych w czasie rzeczywistym mogą dać poczucie obcowania z dopracowaną produkcją komercyjną.
3.  **Wielowarstwowa architektura stanów:** Płynne przechodzenie z trybu opowiadania do trybu interaktywnego wyboru i dynamiczne śledzenie zmiennych w locie.

To idealny, przejrzysty kodowo szablon dla każdego dewelopera pragnącego stworzyć własną grę z rozbudowanymi konwersacjami na silniku Lurek2D.
