# ⚖️ Courtroom Drama — Ace Attorney-style Courtroom Debate Game

**Category:** RPG / Narrative Simulation  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Courtroom Drama** to dynamiczna gra detektywistyczno-sądowa inspirowana kultową serią *Ace Attorney*. Wciel się w rolę nieugiętego obrońcy, przesłuchuj świadków, badaj dowody, zgłaszaj spektakularne sprzeciwy i walcz o werdykt uniewinniający przed ławą przysięgłych. Każda sprawa to intelektualne starcie, w którym jeden logiczny błąd może zrujnować Twoją wiarygodność!

### Pętla Rozgrywki i Mechaniki
1. **Wprowadzenie do Sprawy (Case Intro):** Sędzia przedstawia tło dramatycznego oskarżenia (np. skradziony diament, zatruta pieczeń, szpiegostwo korporacyjne).
2. **Przesłuchanie Świadka (Testimony):** Świadek przedstawia swoje zeznania zdanie po zdaniu. Twoim zadaniem jest dokładna analiza wypowiedzi pod kątem niespójności z zebranymi dowodami.
3. **Zgłaszanie Sprzeciwu (OBJECTION!):** Kiedy znajdziesz kłamstwo lub pomyłkę w zeznaniach, wciśnij klawisz sprzeciwu i wskaż obciążający dowód. Prawidłowy sprzeciw napełnia wskaźnik poparcia ławy przysięgłych (+25%), a błędny niszczy Twoją wiarygodność (-20%).
4. **Zadawanie Pytań (Questioning):** Możesz pogłębić przesłuchanie w dowolnym momencie, wybierając jedno z trzech pytań pomocniczych, aby wydobyć ze świadka więcej szczegółów.
5. **Panel Dowodów (Evidence Panel):** Podglądaj zebrane dowody, aby analizować opisy i przygotowywać obronę.
6. **Werdykt (Verdict):** Przekonaj ławę przysięgłych (100% poparcia), aby zdobyć upragnione „NIEWINNY”. Utrata całej wiarygodności (0%) skutkuje wyrokiem skazującym.

### Sprawy Sądowe
*   **Case 1: The Missing Diamond** (Zniknięcie diamentu z muzeum — alibi strażnika kontra nagrania z kamer).
*   **Case 2: The Poisoned Cake** (Zatrucie gości hotelowych — zeznania szefa kuchni kontra data na paragonie).
*   **Case 3: Corporate Espionage** (Wyciek tajnych planów firmy — oś czasu dyrektora generalnego kontra logi e-mail).

---

## 🇬🇧 Game Description (English)

### Short Pitch (Elevator Pitch)
**Courtroom Drama** is a high-tension courtroom simulation heavily inspired by the legendary *Ace Attorney* franchise. Step into the shoes of a brilliant defense attorney, cross-examine suspicious witnesses, examine the evidence, shout "OBJECTION!" at the perfect moment, and convince the jury of your client's innocence.

### Gameplay Loop & Mechanics
1. **Case Introduction:** The Judge sets the scene of a grand accusation.
2. **Witness Testimony:** The witness shares their side of the story line by line. Your job is to spot the logical contradiction.
3. **OBJECTION!:** Present the exact contradicting piece of evidence at the correct line of testimony. A correct objection wins over the jury (+25%); a wrong one shatters your credibility (-20%).
4. **Cross-Examination Questions:** Ask deep dive questions (1/2/3) to extract further details.
5. **Evidence Organizer:** Toggle the folder (E) to review item descriptions at any time.
6. **Verdict:** Reach 100% jury approval to win. Lose all credibility (0%), and your client is declared guilty!

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **Space** | Przejdź dalej / Następne zeznanie | Advance dialogue / Next testimony |
| **O** | Zgłoś sprzeciw (**OBJECTION!**) | Shout **OBJECTION!** during testimony |
| **Q** | Przejdź do trybu pytań pomocniczych | Toggle question mode during testimony |
| **E** | Pokaż / ukryj panel dowodów | Toggle evidence organizer panel |
| **1 / 2 / 3** | Wybór opcji (pytania, dowody do sprzeciwu) | Select choices (questions / evidence) |
| **Escape** | Wyjście z gry | Quit to OS |

---

## 🏛️ Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
Gra stanowi bezpośredni hołd dla kultowej serii **Phoenix Wright: Ace Attorney** (wydanej pierwotnie na Game Boy Advance i Nintendo DS przez Capcom). Oddaje kluczowe, kultowe elementy:
*   Wielki, czerwony napis **OBJECTION!** wlatujący na ekran przy gwałtownym sprzeciwie.
*   Charakterystyczny efekt maszynopisu (typewriter) budujący tempo rozmowy.
*   Dwuwymiarowy widok sali sądowej z sędzią na podwyższeniu, świadkiem na mównicy i dwoma biurkami procesowymi.
*   System kar reprezentowany przez wskaźnik wiarygodności adwokata.

### Modernizacja w Lurek2D
Lurek2D wnosi nowoczesne usprawnienia, które ułatwiają tworzenie gier narracyjnych:
*   **W pełni zadeklarowany interfejs w TOML (`ui.toml`):** Cały układ paneli pytań, paska wiarygodności, wskaźnika przysięgłych oraz chmury dialogowej jest wczytywany deklaratywnie, bez konieczności pozycjonowania pikseli bezpośrednio w kodzie Lua.
*   **Dynamiczne Tweeningi:** Płynne skalowanie napisu „OBJECTION!”, dynamiczne spadki pasków energii i wybuchy cząsteczek konfetti/iskier sędziowskiego młotka nadają grze niespotykanego w retro oryginałach dynamizmu (tzw. game juice).

---

## 🛠️ Wykorzystane API silnika Lurek2D / Lurek APIs Showcased

*   `lurek.ui`: Dynamiczne wczytywanie i sterowanie strukturą drzewa UI z pliku [ui.toml](file:///c:/Users/tombl/Documents/lurek_2D/content/games/rpg/courtroom/ui.toml). Zarządzanie widocznością elementów (`visible`), treściami (`text`), kolorami (`color`) oraz animowanymi szerokościami (`width`) pasków postępu.
*   `lurek.render`: Rysowanie pełnej sceny sali sądowej za pomocą prymitywów wektorowych (`rectangle`, `circle`, `line`, `setColor`) tworząc estetyczny, minimalistyczny pixel-art sylwetek w czasie rzeczywistym.
*   `lurek.input.keyboard`: Precyzyjne przechwytywanie klawiszy akcji (`isDown`) do płynnego sterowania przebiegiem dialogu i wyborem dowodów.
*   `lurek.timer`: Kontrola prędkości efektu typewriter, animacji migania promptów (`getTime`) oraz pobieranie wydajności (`getFPS`).
*   `lurek.event`: Bezpieczne wyjście z aplikacji poprzez wywołanie zdarzenia `push("quit")`.

---

## 💎 Unikalność i Wartość Prezentacyjna / Showcase Value & Uniqueness

### Dlaczego ta gra jest wyjątkowa?
Większość demówek prezentuje proste zręcznościówki (poruszanie się, strzelanie). **Courtroom Drama** to rzadki pokaz możliwości tworzenia **zaawansowanych gier narracyjno-logicznych i RPG** na silniku Lurek2D. Udowadnia, że Lurek2D doskonale radzi sobie z:
1.  **Stanową strukturą narracyjną:** Zarządzaniem skomplikowaną maszyną stanów (`TITLE` ➔ `INTRO` ➔ `TESTIMONY` ➔ `QUESTION` ➔ `OBJECTION` ➔ `VERDICT`).
2.  **Zaawansowanym UI:** Pokaźny zestaw paneli w `ui.toml` dowodzi stabilności systemu interfejsu użytkownika w silniku, obsługując zagnieżdżone kontenery, obcinanie tekstu oraz dynamiczne maskowanie.
3.  **Animacjami Cząsteczek w Lua:** Efekt młotka sędziowskiego i deszczu konfetti pokazują wydajność tablic Lua przy aktualizacji dziesiątek obiektów fizycznych na klatkę.

Nie jest to kolejny powielony klon zręcznościowy, lecz kompletna, trójsprawowa przygoda tekstowa, pokazująca, jak elastyczny jest silnik Lurek2D przy tworzeniu systemów dialogowych i drzew wyborów.
