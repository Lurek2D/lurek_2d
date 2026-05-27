# Stealth

_Taktyczna skradanka z rzutem z góry — przekradaj się obok patroli strażników, generuj jak najmniej hałasu, ukrywaj się w krzakach i zdobądź karty dostępu do wyjścia._

## 🎮 O grze (About the Game)

W **Stealth** wcielasz się w rolę cichego infiltratora infiltrującego strzeżony obiekt. Twoim nadrzędnym zadaniem jest odnalezienie 3 ukrytych kart dostępu (Keycards), otwarcie nimi portalu ewakuacyjnego i ucieczka bez wywoływania alarmu.

Cechy i rozbudowane systemy gry:
- **Stożki Wzroku Strażników (Vision Cones)** – strażnicy nieprzerwanie patrolują teren w wyznaczonych trasach, rzucając przed siebie 60-stopniowy stożek wzroku o zasięgu 5 kafelków. Stan strażnika obrazuje kolor stożka: zielony (spokojny), żółty (podejrzliwy), czerwony (alarm/pościg).
- **System Podejrzliwości (Suspicion System)** – przebywanie w stożku wzroku na linii prostej buduje wskaźnik podejrzliwości (0–100). Przy 50 strażnik przerywa patrol i idzie zbadać podejrzane miejsce; przy 100 rusza w bezpośredni pościg – zderzenie kończy się natychmiastowym schwytaniem i porażką.
- **Skradanie i Hałas (Crouch & Noise Ripples)** – szybki bieg generuje rozchodzące się na mapie kręgi hałasu (noise ripples), które alarmują i ściągają pobliskich strażników. Trzymanie klawisza **Shift** aktywuje skradanie: poruszasz się o połowę wolniej, ale nie wydajesz żadnych dźwięków i drastycznie redukujesz widoczność.
- **Kryjówki (Hide Spots)** – podchodząc do krzaków lub skrzyń i naciskając klawisz **E**, wchodzisz do kryjówki. Stajesz się całkowicie niewidoczny dla strażników, co pozwala przeczekać ich patrole.

Gra oferuje 3 progresywne poziomy trudności z coraz gęstszym rozmieszczeniem patroli wroga.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/stealth
```

## 🕹️ Sterowanie (Controls)

Sterowanie wymaga cierpliwości i dokładnego planowania ścieżek patrolowych wrogów.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W, A, S, D** / **Strzałki** | Ruch agenta | Poruszanie się po kafelkowych korytarzach placówki |
| **Shift** (przytrzymanie) | Skradanie (Crouch) | Cichy ruch o połowę wolniejszy, eliminujący hałas i redukujący widoczność |
| **E** | Ukryj się / Interakcja | Wejście/wyjście z kryjówki (krzaki, skrzynie) przy bezpośrednim kontakcie |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Metal Gear (1987) autorstwa Hideo Kojimy** oraz **seria Thief / Commandos**
  - *Opis powiązania*: Gra to wspaniały i niezwykle autentyczny hołd dla korzeni gier skradankowych opartych na skomplikowanym patrolowaniu i unikaniu zmysłów wrogów. Wersja Lurek2D doskonale implementuje **aktywne rozchodzenie się dźwięku (sound propagation physics)** w postaci wizualnych, rozchodzących się okręgów hałasu (noise ripples), detekcję linii wzroku (Raycast LOS check) oraz mechanikę chowania się w trójwymiarowym otoczeniu (krzaki/skrzynie) wyłączającą kolizje wroga. 

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra reprezentuje wysoki stopień zaawansowania sztucznej inteligencji opartej o kafelki i dźwięki:

- `lurek.camera` – Podąża płynnie za poruszającym się agentem, dbając o pełen pogląd na najbliższych strażników.
- `lurek.render` – Rysuje kafelkowe korytarze, postać agenta (w tym zmianę wyglądu w krzakach), strażników o zmiennych kolorach stożków światła (vision cones), rozchodzące się kręgi hałasu (`render.circle` o rosnącym promieniu i spadającej przezroczystości), karty dostępu oraz interfejs podejrzliwości wrogów.
- `lurek.input` Przechwytuje responsywny ruch oraz blokuje rozchodzenie się hałasu przy wciśniętym klawiszu Shift.
- `lurek.particle` – Generuje pył pod stopami podczas biegu, małe iskry przy zbieraniu kart oraz wyładowania przy wykryciu.
- `lurek.tween` – Kontroluje płynne rozjaśnianie i zanikanie kręgów hałasu, wskaźniki HUD oraz pulsowanie napisów.
- `lurek.timer` – Mierzy Delta Time, kontroluje tempo opadania podejrzliwości strażników poza polem wzroku, a także wylicza pozycje patrolowe.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: Wybitny pokaz **akustyki w grach 2D (visual acoustics and noise propagation)** – generowanie rozchodzących się fal dźwiękowych o zmiennym promieniu, które dynamicznie przyciągają uwagę AI wrogów (strażnicy porzucają trasę i idą zbadać źródło hałasu). Prezentuje również doskonałe wdrożenie **stanu niewidzialności w strefach (hiding triggers)**.
- **Unikalność**: Jedyna gra w całej kolekcji Lureka wprowadzająca **kręgi hałasu (noise ripples)** jako aktywną mechanikę przyciągania uwagi strażników oraz wchodzenie w interaktywne kryjówki (bushes/crates).
- **Podobne gry**: *Infiltration* (również skradanka), ale *Stealth* kładzie znacznie większy nacisk na mechanikę skradania (crouching), fizykę hałasu przy bieganiu i ukrywanie się w krzakach, podczas gdy *Infiltration* opiera się na gadżetach (EMP, lockpicks), kamerach ściennych i minigrach hakerskich.
