# ⛳ Golf Classic — 9-Hole Retro Golf

**Category:** Sports / Golf Simulator  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Golf Classic** to kompletny, top-down symulator gry w golfa na 9 dołkach, będący bezpośrednim hołdem dla legendarnych retro hitów, takich jak *NES Open Tournament Golf* (NES) czy kultowe *Neo Turf Masters* z automatów arcade. Gracz przejmuje kontrolę nad piłeczką golfową, a jego celem jest przejście całego 9-dołkowego pola z jak najmniejszą liczbą uderzeń (strokes) poniżej normy (Par). Gra oferuje mouse-aiming z wizualną linią trajektorii, precyzyjną fizykę toczenia piłki z tarciem zależnym od podłoża (fairway, rough, piasek, woda), kolizje i odbicia od ścian, system dynamicznego wiatru oraz pełną kartę wyników (Scorecard) na koniec rundy. To wspaniały pokaz fizyki zderzeń, interpolacji ruchu i zaawansowanego interfejsu TOML w silniku Lurek2D.

### Pętla Rozgrywki i Mechaniki
1. **Model Fizyki i Uderzenia:**
   - Wybierz kierunek uderzenia myszką — z piłeczki rozciąga się linia pomocnicza.
   - Przytrzymaj **Spację** lub lewy przycisk myszy (LMB), aby naładować moc uderzenia (0% - 100%). Puść, aby uderzyć piłeczkę.
   - Piłeczka toczy się z uwzględnieniem kierunku uderzenia oraz tarcia. Jeśli prędkość spadnie poniżej 2 px/s, piłka zatrzymuje się, umożliwiając kolejny strzał.
2. **Katalog Terenów i Zderzeń:**
   - **Fairway (Główny Tor):** Standardowa zielona trawa o niskim tarciu (0.97). Piłka toczy się płynnie i daleko.
   - **Rough (Wysoka Trawa):** Ciemnozielona trawa o wysokim tarciu (0.95), znacznie spowalniająca piłeczkę.
   - **Sand Bunker (Bunkier Piaskowy):** Żółty piasek o skrajnym tarciu (0.90), gwałtownie tłumiący energię piłki i wyzwalający piaskowy pył.
   - **Water Hazard (Woda):** Niebieskie zbiorniki wodne. Wpadnięcie piłki do wody resetuje jej pozycję do punktu ostatniego uderzenia i nakłada **karę 1 uderzenia**.
   - **Walls (Ściany i Przeszkody):** Drewniane bariery. Piłeczka odbija się od nich zgodnie z wektorem odbicia lustrzanego (Mirror bounce reflection) z tłumieniem 20% energii.
3. **Dynamiczny System Wiatru:**
   - Na każdym dołku kierunek i siła wiatru są losowane i wizualizowane za pomocą strzałki wiatru w lewym górnym rogu.
   - Wiatr wywiera stałe poziome parcie aerodynamiczne, znnosząc toczącą się piłeczkę z wyznaczonego toru.
4. **Punktacja i Scorecard:**
   - Gra rejestruje liczbę uderzeń na każdym dołku i zestawia je z Par (normą dołka).
   - Po przejściu 9 dołków wyświetlana jest pełna karta wyników podsumowująca Twój wynik (Par, Birdie, Eagle, Bogey). Spróbuj ukończyć rundę poniżej par!

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Golf Classic** is a comprehensive top-down 9-hole golf simulator standing as a high-fidelity tribute to retro sports masterpieces like *NES Open Tournament Golf* (NES) and arcade icons like *Neo Turf Masters*. Command your golf ball across a series of 9 progressively harder holes featuring complex terrain profiles including lush fairways, speed-dampening roughs, trap bunkers, water hazards, and wooden barrier walls. With responsive mouse aiming, a real-time trajectory guide, a precise charge-and-release swing meter, and dynamic aerodynamic wind drift, this project represents Lurek2D's ultimate demonstration of surface friction math and bounding reflections!

### Gameplay Loop & Mechanics
1. **Precise Roll & Swing Physics:**
   - Adjust your shot direction using the mouse cursor — a guide line projects out from the ball.
   - Hold **Space** or Left-Click (LMB) to charge your shot power (0% - 100%). Release to strike the ball.
   - The ball rolls factoring in your stroke vector, friction damping, and active wind vectors. Once speed drops below 2px/s, the ball settles for your next shot.
2. **Surface Friction & Bounces:**
   - **Fairway:** Lush light-green grass offering minimal friction (0.97) for maximum rolls.
   - **Rough:** Dark-green dense grass with high friction (0.95) that bogs down rolls.
   - **Sand Bunker:** Golden sand traps with extreme friction (0.90) that arrest momentum and emit sand spray particles.
   - **Water Hazard:** Deep blue pools. Landing in water incurs a **1-stroke penalty** and resets the ball to its last shot origin.
   - **Walls:** Rigid wooden barriers. The ball bounces off walls utilizing a mirrored bounce reflection algorithm, losing 20% of its kinetic energy.
3. **Aerodynamic Wind Drift:**
   - Wind speed and direction are randomized per hole, represented by a vector compass in the HUD.
   - Wind continuously pushes the rolling ball, curving its path away from your intended trajectory.
4. **Hole Analysis & Scorecards:**
   - Track your strokes against par for each hole.
   - Sinking the ball triggers dynamic banners (Birdie, Eagle, Par, Bogey). Complete all 9 holes to review a detailed scorecard summary of your performance!

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/sports/golf_classic
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **Mouse (Kursor)** | Celowanie (Aim) | Obraca kierunek uderzenia piłki wokół jej środka. |
| **Space / Mouse1 (Przytrzymaj)** | Ładuj moc (Charge Swing) | Ładuje moc uderzenia kija golfowego (0% - 100%). |
| **Space / Mouse1 (Puść)** | Strzał (Hit Ball) | Uderza piłeczkę z aktualną siłą i w wybranym kierunku. |
| **Esc** | Wyjście (Quit) | Zamyka grę w bezpieczny sposób. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **NES Open Tournament Golf (1991) by Nintendo**
  - *Opis powiązania*: Wyraźna inspiracja top-down widokiem, podziałem na fairwaye, roughy i bunkry, paskiem siły naładowania z boku ekranu oraz obecnością flagi z chorągiewką w dołku.
- **Neo Turf Masters (1996) by Nazca Corporation / SNK**
  - *Opis powiązania*: Wprowadzenie wiatru spychającego piłeczkę, dynamicznych komunikatów po trafieniu (BIRDIE, EAGLE, PAR) oraz szczegółowego scorecardu.
- **Micro Golf**
  - *Opis powiązania*: Koncepcja odbijania się piłeczki od ścianek i barier w celu omijania przeszkód wodnych metodą bilardową.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

- `lurek.ui` – Wczytywanie zautomatyzowanego interfejsu TOML (`ui.toml`) obsługującego paski naładowania, wskaźniki uderzeń (Strokes), kierunek wiatru oraz pełny Scorecard z wynikami 9 dołków.
- `lurek.input` – Pobieranie pozycji myszy w celu określenia kąta uderzenia oraz obsługa ładowania spacji.
- `lurek.window` / `lurek.event` – Inicjalizacja stabilnej rozdzielczości 800x600 px z wyświetlaniem FPS i czystym zamknięciem przy Esc.
- **Aż Cztery Systemy Cząsteczek (Multiple Particle Systems):**
  - *Ślad piłki (Ball Trail)*: Białe kropelki gasnące za toczącą się szybko piłką.
  - *Plusk wody (Water Splash)*: Niebiesko-biała fontanna kropli wyzwalana przy wpadnięciu do wody.
  - *Rozbłysk piasku (Sand Spray)*: Żółtawe drobiny piasku sypiące się podczas toczenia po bunkrze.
  - *Wpadnięcie do dołka (Hole Sink)*: Złoto-żółta eksplozja iskier sukcesu po trafieniu do dołka.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Fantastyczny pokaz fizyki tarcia i detekcji kolizji AABB z przeszkodami w skryptach Lua. Prezentuje algorytmy badania przynależności punktu do prostokąta (Point-in-rect), fizykę uślizgu piłki pod wpływem wiatru oraz bilardowe zderzenia ze sprężystym odbiciem (reflection vectors).
- **Unikalność (Uniqueness):** Jedyny symulator golfa z pełnym zestawem 9 zróżnicowanych dołków, różnymi typami nawierzchni oraz wiatrem.
- **Podobne gry (Similar Games):** Gra dzieli charakter toczenia się piłki z `pinball` oraz `physics_puzzle`, ale wyróżnia się unikalnym charakterem sportowej rywalizacji opartej na Par i cichym, precyzyjnym planowaniu trajektorii.
