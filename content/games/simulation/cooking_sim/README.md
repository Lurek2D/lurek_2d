# 🍳 Cooking Sim — Culinary Station Time-Management Simulator

**Category:** Simulation  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Cooking Sim** to dynamiczna gra symulacyjna i zręcznościowa typu "czas na talerzu" (Station Cooking Manager), mocno inspirowana hitami takimi jak *Overcooked* oraz *Cooking Mama*. Jako szef kuchni prowadzisz restaurację zmuszoną realizować coraz bardziej skomplikowane i zróżnicowane zamówienia wiecznie niecierpliwych klientów. Przemieszczaj się między stacjami roboczymi (Prep Station, Stove, Oven, Serving Counter), dobieraj świeże składniki z magazynu, twórz receptury, precyzyjnie kontroluj czas smażenia i pieczenia (uważając, by nie spalić potrawy!), a następnie sprawnie wydawaj gotowe dania. Czy dasz radę zapanować nad kuchennym chaosem, zarobić fortunę i utrzymać zadowolenie klientów na najwyższym poziomie?

### Pętla Rozgrywki i Mechaniki
1. **Dzień w Kuchni:** Każdy dzień trwa 120 sekund czasu rzeczywistego. Twoim celem jest realizacja napływających zamówień klientów, gromadzenie złota i przetrwanie jak najdłużej.
2. **Kolejka Klientów i Cierpliwość:** Z lewej strony ekranu widnieje lista 3 aktywnych zamówień. Każdy klient ma pasek cierpliwości (30 sekund). Gdy czas upłynie, klient odchodzi wściekły, co obniża współczynnik Zadowolenia (Satisfaction) o 15%. Spadek zadowolenia do 0% oznacza zamknięcie restauracji i Game Over.
3. **Książka Kucharska (Recipes):** Restauracja serwuje 4 klasyczne potrawy:
   - **Sandwich (Kanapka):** Składniki: *bread + meat + lettuce*. Danie ekspresowe (wystarczy przygotować na Prep Station i wydać). Cena: 15 złota.
   - **Salad (Sałatka):** Składniki: *tomato + lettuce + cheese*. Danie ekspresowe. Cena: 10 złota.
   - **Burger:** Składniki: *bread + meat + cheese*. Wymaga usmażenia na kuchence (Stove) przez 5 sekund. Cena: 20 złota.
   - **Pizza:** Składniki: *bread + cheese + tomato*. Wymaga upieczenia w piecu (Oven) przez 8 sekund. Cena: 25 złota.
4. **Cztery Stacje Kuchenne:**
   - **Prep Station (Przygotowanie):** Wybierz z menu surowce i ułóż maksymalnie 3 na stole kuchennym (Enter), a następnie połącz je w bazę dania (Space).
   - **Stove (Kuchenka):** Smażenie burgerów (5 sekund). Jeśli przetrzymasz je o 3 sekundy za długo, spalą się na węgiel!
   - **Oven (Piec):** Pieczenie pizzy (8 sekund). Podobnie jak na kuchence, zbyt długi czas pieczenia doprowadzi do spalenia dania.
   - **Serving Counter (Lada wydawcza):** Lądują tu przygotowane potrawy, które za pomocą spacji wydajesz pierwszemu klientowi w kolejce.
5. **Ekonomia i Zaopatrzenie:** Pomiędzy dniami możesz dokupić paczkę świeżych składników (daje +2 do każdego typu surowca) za 5 jednostek złota. Pomyłki kuchenne kosztują — wydanie spalonego lub nieprawidłowego dania skutkuje spadkiem zadowolenia klientów i utratą cennego czasu.

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Cooking Sim** is a high-octane culinary time-management and station simulator heavily inspired by legendary titles like *Overcooked* and *Cooking Mama*. Step into the hectic shoes of a master chef managing a bustling restaurant under tight deadlines. Navigate fluidly between preparation tables, stoves, ovens, and the serving hatch. Grab raw ingredients (tomato, cheese, bread, meat, lettuce), combine them according to recipes, accurately time your cooking phases to prevent severe burning, and serve satisfying meals to an impatient queue of hungry guests. Balance speed, strategy, and stockpile investments to keep your customer satisfaction rating above zero!

### Gameplay Loop & Mechanics
1. **The Chef's Shift:** Each shift lasts 120 seconds. You must fulfill incoming customer tickets, amass gold coins, and maintain high reputation scores to unlock successive days.
2. **Customer Queue & Patience:** Up to 3 active tickets fill the order display. Each customer possesses a patience gauge of 30 seconds. If a guest is left waiting too long, they walk out, penalizing your restaurant's overall Satisfaction by 15%. Dropping to 0% satisfaction triggers an immediate health inspector closure (Game Over).
3. **The Culinary Menu (Recipes):** Master four distinct dishes:
   - **Sandwich:** Ingredients: *bread + meat + lettuce*. Served instantly from the Prep Station. Yields 15 Gold.
   - **Salad:** Ingredients: *tomato + lettuce + cheese*. Served instantly from the Prep Station. Yields 10 Gold.
   - **Burger:** Ingredients: *bread + meat + cheese*. Requires 5 seconds of cooking on the Stove. Yields 20 Gold.
   - **Pizza:** Ingredients: *bread + cheese + tomato*. Requires 8 seconds of baking inside the Oven. Yields 25 Gold.
4. **Kitchen Operations (Stations):**
   - **Prep Station:** Browse inventory lists, stack up to 3 raw items (Enter), and assemble them (Space) to prepare raw dishes or base mixtures.
   - **Stove:** Sears Burgers (5s cook timer). Leaving the burger on the burner for an extra 3s burns the patty, turning it into useless ash!
   - **Oven:** Bakes Pizzas (8s cook timer). Requires vigilant monitoring; overbaking results in a charred dish.
   - **Serving Counter:** The final staging area where cooked or prepped meals are placed and handed off (Space) to the first customer in line.
5. **Kitchen Economy:** At the end of each day, spend 5 gold to restock your ingredients (+2 units of each raw material). Serving incorrect or charred dishes penalizes satisfaction ratings and wastes expensive stockpiles.

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/simulation/cooking_sim
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **Left / Right (Strzałki)** | Nawigacja stacji | Przełącza wybór między czterema stacjami kuchennymi. |
| **Up / Down (Strzałki)** | Przeglądanie spiżarni | Wybiera składnik z listy ekwipunku (tomato, cheese, bread, meat, lettuce). |
| **Enter (Return)** | Wyjmij składnik | Kładzie zaznaczony składnik ze spiżarni na stację przygotowawczą (Prep Station). |
| **Space (Spacja)** | Akcja stacji / Interakcja | Wykonuje domyślne działanie: łączy składniki, wkłada do pieca, zbiera potrawę, wydaje klientowi, lub restartuje grę. |
| **Esc** | Wyjście | Zamyka bezpiecznie aplikację. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Cooking Mama (2006) by Taito**
  - *Opis powiązania*: Gra kładzie duży nacisk na pojedyncze etapy powstawania posiłków (siekanie/nakładanie surowców na Prep Station, a potem kontrolowane czasowo pieczenie lub smażenie). Cooking Sim wspaniale oddaje to uczucie "przygotowania bazy", a dopiero potem obróbki termicznej.
- **Overcooked (2016) by Team17**
  - *Opis powiązania*: Napięcie wywołane wieloma stacjami roboczymi, kurczącym się czasem cierpliwości klientów oraz tragicznym ryzykiem spalenia potraw i wywołania dymu na stacji. Gracz musi nieustannie optymalizować swoją ścieżkę ruchu i monitorować paski postępu Stove/Oven.
- **Diner Dash (2004) by Gamelab**
  - *Opis powiązania*: Pętla oparta na zadowoleniu gości i obsłudze kolejkowej, w której priorytetyzacja wydawania potraw ma kluczowe znaczenie dla przetrwania kolejnych dni.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje bogactwo funkcjonalności interfejsu i zarządzania stanem w silniku Lurek2D:
- `lurek.window` – Dynamiczna aktualizacja paska tytułowego okna (`lurek.window.setTitle`) pokazująca numer aktualnego dnia, saldo finansowe szefa kuchni oraz bieżący klatkaż (FPS).
- `lurek.input` – Wzorcowe, dedykowane mapowanie akcji klawiatury (`lurek.input.bind`) dla precyzyjnej nawigacji po menu i stacjach.
- `lurek.render` – Rysowanie estetycznego interfejsu 2D (podświetlenia stacji, kolorowe paski cierpliwości i pieczenia) oraz renderowanie szczegółowych tekstów statusowych potraw i wskazówek QoL.
- `lurek.camera` – Definiowanie wirtualnej kamery viewportu w celu prawidłowego i ostrego rzutowania sceny kuchennej.
- `lurek.event` – Prawidłowe zamykanie aplikacji przy naciśnięciu Esc.
- **Zaawansowany System Cząsteczek (Particles):**
  - *Para (Steam)*: Unoszące się jasnoniebieskie cząsteczki nad stacją smażenia/pieczenia symulują wrzącą potrawę.
  - *Dym (Smoke)*: Szare, ciężkie drobiny ulatniające się w razie przypalenia dania lub złego wydania potrawy.
  - *Błyski (Sparkle)*: Złote iskierki świętujące udane złożenie potrawy lub jej pomyślne wydanie klientowi.
- **Zintegrowany Silnik Tweeningu:** Płynna interpolacja animacji finansowych (Gold) z użyciem wygładzania Ease Out Quad, eliminująca skokowy przyrost gotówki na rzecz pięknego, rosnącego licznika.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Gra doskonale prezentuje, jak w Lurek2D stworzyć angażującą grę o zarządzaniu czasem bez użycia grafiki rastrowej. Skupia się na czytelności UI, płynnym przejściu stanów dni, obsłudze struktur danych (tablice składników, kolejki FIFO klientów) oraz wielowariantowych cząsteczkach.
- **Unikalność (Uniqueness):** Unikalny miks mechanik polegający na monitorowaniu stanów "ukrytych" (czas pieczenia na stacji, na której aktualnie nie stoimy) oraz zarządzaniu ograniczonymi zasobami (Inventory), co stawia gracza w roli planisty i taktyka kuchennego.
- **Podobne gry (Similar Games):** Gra dzieli elementy ekonomiczne z `merchant`, ale różni się od niej czynną zręcznościową obróbką termiczną potraw i presją czasu w trybie rzeczywistym. Podobne mechaniki łączenia składników spotkamy też w `alchemy`.
