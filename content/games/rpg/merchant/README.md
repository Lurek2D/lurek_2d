# 🏪 Merchant — Medieval Trading Shop Simulator

**Category:** RPG / Shop Management & Economy Simulation  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Merchant** to wciągający symulator średniowiecznego kupca. Otwórz swój sklep, zarządzaj stanem magazynowym półek, kupuj towary tanio i sprzedawaj je z zyskiem. Obsługuj przybywających w czasie rzeczywistym klientów, buduj swoją reputację kupiecką, aby zwiększać marże i sprawdzaj szczegółowy księgowości rejestr transakcji. Twoim celem jest zgromadzenie jak największego majątku w ciągu 5 dni roboczych!

### Pętla Rozgrywki i Mechaniki
1. **Zarządzanie Półkami (Shelf Management):** Twój sklep oferuje 8 towarów w trzech kategoriach:
    *   ⚔️ **Weapons (Broń):** Iron Sword, Steel Sword, Magic Staff.
    *   🛡️ **Armor (Pancerz):** Leather Armor, Chainmail, Plate Armor.
    *   🧪 **Potions (Eliksiry):** Health Potion, Mana Potion.
    Każdy produkt na półce ma ograniczony zapas (maks. 5 sztuk). Kiedy towary się skończą, musisz uzupełnić zapasy (Restock).
2. **Kupowanie i Sprzedawanie (Buy & Sell Modes):**
    *   **Buy Mode (Kupowanie):** Kupujesz towary z półki hurtowej do swojego prywatnego podręcznego magazynu.
    *   **Sell Mode (Sprzedawanie):** Możesz natychmiast odsprzedać towar z powrotem na półkę za 75% jego ceny bazowej (szybka wyprzedaż).
3. **Obsługa Klientów (Customers):** Co 5 sekund do sklepu wchodzi klient (reprezentowany przez poruszającą się wektorową sylwetkę). Klient szuka konkretnego towaru i czeka 4 sekundy na transakcję:
    *   Jeśli **posiadasz** ten towar w ekwipunku: Następuje automatyczna sprzedaż z **potężną marżą 120% pomnożoną przez Twoją reputację**! Dodatkowo zyskujesz reputację (+2%).
    *   Jeśli **nie posiadasz** towaru: Klient odchodzi rozczarowany, a Twoja reputacja spada (-3%).
4. **Wskaźnik Reputacji (Reputation):** Im wyższa reputacja, tym więcej klienci zapłacą za Twoje towary (mnożnik od 50% do 200% wartości).
5. **Księga Transakcji (Sales Ledger - L):** Prowadź szczegółowy rejestr księgowy. Klawisz L otwiera pełną historię zakupów, sprzedaży i pominiętych klientów z podziałem na dni.
6. **Pięciodniowy Tydzień Pracy:** Każdy dzień trwa 60 sekund. U góry ekranu widzisz dynamiczny pasek czasu. Pod koniec 5 dnia następuje podsumowanie finansów.

---

## 🇬🇧 Game Description (English)

### Short Pitch (Elevator Pitch)
**Merchant** is an intricate medieval shopkeeping simulator. Buy wholesale goods, manage shelf stocking across Weapons, Armor, and Potions, serve incoming procedurally generated customer requests in real-time, scale up your market reputation to charge sky-high premiums, and review your historical transactions in the sales ledger. Maximize your gold over a stressful 5-day cycle!

### Gameplay Loop & Mechanics
1. **Catalog Management:** Restock your shelves with 8 core items in 3 major classifications:
    *   ⚔️ **Weapons:** Iron Sword, Steel Sword, Magic Staff.
    *   🛡️ **Armor:** Leather Armor, Chainmail, Plate Armor.
    *   🧪 **Potions:** Health Potion, Mana Potion.
    Items have finite shelf capacities (max 5). Trigger a restock (R) once inventories deplete.
2. **Flexible Trade Loops:**
    *   **Buy Mode:** Secure items from wholesale shelves into your backpack.
    *   **Sell Mode:** Liquify inventory by selling it back to the shelf immediately at a 75% wholesale cost.
3. **Real-time Customers:** Every 5 seconds, a customer arrives at your counter (fully animated silhouette). They demand a random item and wait 4 seconds:
    *   If you **have** the item: It is sold automatically at a **120% base premium scaled by your active reputation multiplier**! Reputation increases (+2%).
    *   If you **lack** the item: The customer leaves angry, causing a reputation penalty (-3%).
4. **Reputation Engine:** Scales your customer selling profits. Modifiers range dynamically from a punishing 50% up to a highly lucrative 200%.
5. **Sales Ledger (L):** Access your financial ledger showing categorized stamps of all BUYS, SELLS, CUSTOMERS, and MISSED deals indexed by day.
6. **5-Day Calendar:** Each day runs for a tight 60 seconds monitored by a top-bar progress meter. End of Day 5 tallies your net score.

---

## 🎮 Sterowanie / Controls

| Klawisz / Key | Działanie (pl) | Action (en) |
| :--- | :--- | :--- |
| **1 – 8** | Kup przedmiot z półki / Sprzedaj przedmiot (w trybie sprzedaży) | Buy item from shelf / Sell item from inventory |
| **S** | Przełącz tryb (Kupowanie ⇄ Sprzedawanie) | Toggle shop mode (Buy Mode ⇄ Sell Mode) |
| **A** | Automatyczny zakup najdroższego towaru | Auto-buy the most expensive affordable item |
| **R** | Uzupełnij zapasy na półkach hurtowych | Restock the wholesale shelf supplies |
| **L** | Otwórz / Zamknij księgę transakcji | Open / Close the sales ledger history |
| **Escape** | Wyjście z gry / Powrót z księgi | Quit to OS / Close active ledger panel |

---

## 💰 Inspiracje i Modernizacja / Retro & Classic Inspirations

### Klasyczne Dziedzictwo
Gra nawiązuje do słynnych handlowych gier RPG oraz ekonomicznych symulatorów (takich jak **Recettear: An Item Shop's Tale**, **Patrician**, **Taipan!** oraz mechaniki handlu w grach **RPG MMO**). Prezentuje kluczowe elementy:
*   Zasada „kupuj tanio, sprzedawaj drogo” (arbitraż rynkowy).
*   Zarządzanie czasem i stres związany z szybką obsługą niecierpliwych klientów.
*   Reputacja handlowa jako odzwierciedlenie prestiżu i siły przetargowej sklepu.

### Modernizacja w Lurek2D
Lurek2D dodaje wspaniałe mechaniki interfejsu i płynności:
*   **Płynne Animacje Kwot (Gold Tweens):** Posiadane złoto nie zmienia się skokowo, lecz rośnie lub maleje płynnie za pomocą interpolacji matematycznej (`tweens`), co daje świetne uczucie bogacenia się.
*   **Wektorowa Animacja Klienta:** Płynne podchodzenie klienta do lady z dynamicznym cieniowaniem i fizyką grawitacyjnych cząsteczek złota (`particles`) wyzwalanych przy sfinalizowaniu umowy.

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
**Merchant** to rzadki, kapitalnie zaprojektowany **symulator ekonomiczno-zarządczy** w portfolio Lurek2D:
1.  **Złożona Ekonomia Matematyczna:** Płynne przeliczanie marż na bazie zmiennego współczynnika reputacji, stałych narzutów klienckich oraz ubytków hurtowych dowodzi przydatności silnika do programowania symulacji finansowych.
2.  **Zaawansowany Ledger Rejestrujący:** Dynamiczna tablica transakcji w Lua zapisuje każdą czynność, pozwalając na jej analizę w osobnym podmenu, co uczy deweloperów obsługi historii stanów gry.
3.  **Wspaniałe Sprzężenie Zwrotne (Game Juice):** Animacja podchodzenia klientów, miganie pasków czasu, dynamiczne odliczanie złota i fontanny monet udowadniają, że silnik 2D potrafi zachwycić oprawą bez skomplikowanej grafiki bitmapowej.

To idealny, unikalny kodowo projekt dla każdego twórcy pragnącego zaprogramować grę o zarządzaniu czasem, ekonomii i symulacji handlu w silniku Lurek2D!