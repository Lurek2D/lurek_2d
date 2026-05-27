# 🏪 Merchant Demo — Quick-Start Sandbox & Trade Simulator

**Category:** RPG / Shop Management & Economy Simulation (Demo)  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Merchant Demo** to wersja demonstracyjna średniowiecznego symulatora sklepu. Działa jako gotowy do uruchomienia kodowo sandbox, w którym deweloperzy i projektanci mogą natychmiast eksperymentować z parametrami popytu, mnożnikami marż klienckich, systemem reputacji oraz wektorowymi animacjami postaci i cząsteczek. Prowadź sklep, testuj mechaniki handlowe i zobacz, jak Lurek2D realizuje zaawansowane symulatory ekonomiczne.

### Rola i Przeznaczenie Wersji Demo
Gra dzieli architekturę i kod źródłowy z głównym modułem `merchant`, lecz jest wydzielona jako łatwo dostępny poligon doświadczalny:
1.  **Modyfikacja Parametrów Popytu:** Możliwość szybkiej zmiany częstotliwości przychodzenia klientów (`CUSTOMER_INTERVAL = 5.0`) lub ich czasu cierpliwości.
2.  **Testowanie Mnożników Ceny:** Bezpośredni wgląd w to, jak reputacja handlowa modyfikuje ostateczną cenę płaconą przez klientów (od 50% do 200%).
3.  **Wygodny Ledger logujący:** Prosty w obsłudze podgląd dziennika transakcji (L) jako narzędzie do debugowania stanów gry w Lua.

---

## 🇬🇧 Game Description (English)

### Short Pitch (Elevator Pitch)
**Merchant Demo** serves as a lightweight, single-script sandbox companion to the main `merchant` trading simulator. This tech-demo gives creators a seamless entry point to modify trade economies, tweak customer arrival intervals, alter profit margins, and experiment with real-time vector UI scaling and particle rewards inside Lurek2D.

### Sandbox Highlights & Purposes
Based on the exact codebase of `merchant`, this demo is optimized for developer experimentation:
1.  **Reputation & Price Sandbox:** Tinker with reputation gains and loss rates to see how they impact pricing scales in real-time.
2.  **Transaction Logger Template:** Great baseline code for capturing and reviewing multi-day transaction arrays in Lua.
3.  **UI & Particle Playground:** Instant test-bed for smooth number count displays (tweens) and vector silhouette movements.

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **1 – 8** | Kup produkt z półki / Sprzedaj produkt z magazynu | Buy item from shelf / Sell item from inventory |
| **S** | Przełącz tryb sklepu (Kupowanie ⇄ Sprzedawanie) | Toggle shop mode (Buy Mode ⇄ Sell Mode) |
| **A** | Automatyczny zakup najdroższego dostępnego towaru | Auto-buy the most expensive affordable item |
| **R** | Uzupełnij zapasy na półkach hurtowych | Restock the wholesale shelf inventory |
| **L** | Otwórz / Zamknij księgę transakcji | Open / Close the sales ledger history panel |
| **Escape** | Wyjście z gry / Zamknięcie księgi | Quit to OS / Close active ledger panel |

---

## 💰 Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
Wzorowane na klasycznych grach handlowych, takich jak **Recettear** oraz **Patrician**, demo skupia się na ekonomicznej zależności popytu i podaży oraz znaczeniu renomy kupieckiej.

### Modernizacja w Lurek2D
*   **Zwięzły Kod:** Całość zamknięta w pojedynczym pliku `main.lua` bez zewnętrznych assetów, co czyni grę idealnym szablonem edukacyjnym.
*   **Soczystość Graficzna (Game Juice):** Płynne animacje odliczania złota (`tweens`) i dynamiczny deszcz monet (`particles`) wyznaczają nowy standard dla prostych gier zręcznościowo-ekonomicznych.

---

## 🛠️ Wykorzystane API silnika Lurek2D / Lurek APIs Showcased

*   `lurek.render`: Rysowanie lady sklepowej, kafelków podłogi, podziału półek, ikon towarów oraz tablic transakcyjnych i tekstów pomocniczych (`rectangle`, `circle`, `print`, `setColor`).
*   `lurek.input`: Obsługa mapowania 8 klawiszy numerycznych oraz detekcja akcji pojedynczych (`wasActionPressed`) dla szybkiego i sprawnego handlowania.
*   `lurek.camera`: Precyzyjne pozycjonowanie sceny w oparciu o układ współrzędnych kamery (`getPosition`).
*   `lurek.window` & `lurek.event`: Modyfikacja paska systemowego okna gry (`setTitle`) oraz bezpieczne zamykanie aplikacji (`quit`).
*   `lurek.timer`: Precyzyjne pobieranie liczby klatek na sekundę (`getFPS`) i odmierzanie czasu trwania dnia oraz cierpliwości klientów.

---

## 💎 Unikalność i Wartość Prezentacyjna / Showcase Value & Uniqueness

### Dlaczego ta gra jest wyjątkowa?
**Merchant Demo** to wzorowy **szablon edukacyjny gry ekonomicznej**:
1.  **Zrozumiała struktura danych:** Doskonale pokazuje, jak operować na tablicach asocjacyjnych Lua w celu modelowania stanów magazynowych i cenników.
2.  **Pokaz dynamicznej kamery i UI:** Dowodzi, że Lurek2D radzi sobie ze stabilnym renderowaniem interfejsu o wysokiej gęstości danych (shelf layout, inventory blocks, ledger overlays).
3.  **Wysoka Wydajność:** Stabilny czas klatki przy jednoczesnej aktualizacji cząsteczek, odliczania liczb i animacji postaci na starszych maszynach deweloperskich.