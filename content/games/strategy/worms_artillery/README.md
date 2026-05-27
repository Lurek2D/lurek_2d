# 🐛 Worms Artillery — Deformable Terrain Ballistics

**Category:** Strategy / Artillery Physics  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Worms Artillery** to wciągająca taktyczna gra artyleryjska rozgrywana w turach, będąca bezpośrednim hołdem dla legendarnych klasyków Amigi, takich jak *Worms (1995)* oraz kultowej gry pecetowej *Scorched Earth (1991)*. Dwie czteroosobowe drużyny robaków stają naprzeciw siebie na w pełni zniszczalnym wyspiarskim krajobrazie, wygenerowanym proceduralnie przy użyciu szumów fraktalnych (Perlin Noise). Gracze muszą precyzyjnie kontrolować kąt celowania, siłę wystrzału z bazooki oraz dynamicznie zmieniający się wiatr, by posyłać pociski po krzywej parabolicznej prosto w pozycje wroga. Wybuchy pocisków fizycznie niszczą i drążą kratery w ziemi, a robaki podlegają sile grawitacji. Gra stanowi kapitalny pokaz zaawansowanej fizyki ballistycznej i nieliniowej procgen w silniku Lurek2D.

### Pętla Rozgrywki i Mechaniki
1. **Proceduralny i Zniszczalny Teren (Deformable Procgen):**
   - Teren generowany jest na start przy użyciu algorytmu szumu Perlina (`lurek.procgen.perlin2d`), tworząc naturalne wzniesienia i doliny podzielone na 120 kolumn.
   - **Niszczenie terenu:** Eksplozje pocisków fizycznie wypalają kratery o promieniu 45 pikseli, obniżając wysokość odpowiednich kolumn ziemi i zmuszając robaki stojące na nich do osunięcia się na nowo uformowany poziom gruntu.
2. **Fizyka i Ballistyka (Wind & Gravity):**
   - Wystrzelony pocisk bazooki podlega stałemu przyspieszeniu grawitacyjnemu (GRAVITY = 240 px/s²) ciągnącemu go w dół.
   - **Wiatr (Wind):** Co turę kierunek i siła wiatru ulegają zmianie (reprezentowane przez białą strzałkę u dołu). Wiatr wywiera stałe poziome parcie aerodynamiczne na lecący pocisk, zakrzywiając jego tor lotu.
3. **Pętla Tur i Drużyn:**
   - W starciu biorą udział dwie ekipy: **Team A** (pomarańczowy) i **Team B** (niebieski), po 4 robaki w każdej.
   - W swojej turze gracz steruje jednym aktywnym robakiem (oznaczonym migającym żółtym okręgiem i linią celowniczą). Posiada 30 sekund na oddanie strzału.
   - Steruj kątem (Left/Right) oraz siłą wystrzału (Up/Down) i naciśnij **Space**, by posłać pocisk!
4. **Zniszczenia i Warunki Zwycięstwa:**
   - Wybuch w bliskim sąsiedztwie zadaje obrażenia proporcjonalne do odległości od centrum eksplozji (do 60 HP obrażeń).
   - Robaki, których zdrowie spadnie do 0, są eliminowane z planszy. Ostatnia drużyna posiadająca żywe robaki wygrywa mecz!

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Worms Artillery** is a thrilling turn-based tactical physics game standing as a direct, high-fidelity tribute to Commodore Amiga masterpieces like *Worms (1995)* and the DOS classic *Scorched Earth (1991)*. Two teams of four combat worms face off on a fully deformable procedural terrain generated live using fractal Perlin Noise. Players must meticulously calculate aim angles, firing velocities, and dynamic wind resistance vectors to lob bazooka projectiles across ballistic gravity arcs. Projectiles physically carve out craters from the landscape, altering geometry and causing occupants to fall down to the new ground levels. Integrating live geometry deformation, aerodynamic wind drift, and seeded RNG placement, this is Lurek2D's ultimate physics showcase!

### Gameplay Loop & Mechanics
1. **Procedural & Deformable Landscapes:**
   - The map terrain is created at boot utilizing a Perlin Noise formula (`lurek.procgen.perlin2d`), carving out organic hills and valleys split into 120 geometric columns.
   - **Deformation:** Explosions physically subtract height from affected ground columns in a 45px radius, carving smooth impact craters and causing worms to dynamically slip down to the new floor level.
2. **Aerodynamic Ballistics:**
   - Active bazooka rounds are pulled down by constant gravity acceleration (GRAVITY = 240 px/s²).
   - **Wind Drift:** Each turn generates random wind velocities (visualized by a horizontal pointer at the bottom). Wind exerts a constant horizontal force, curving trajectories midway through flight.
3. **Turn-Based Team Roster:**
   - Battle pits **Team A** (orange) against **Team B** (blue), each fielding 4 worms with individual HP bars.
   - On your turn, command a single active worm (indicated by a glowing yellow target circle and guide line). You have 30 seconds to aim and fire.
   - Rotate angle (Left/Right), adjust thruster power (Up/Down), and tap **Space** to fire!
4. **Impact Blast Radius & Victory:**
   - Blasts deal damage scaled by distance to the epicenter (up to 60 HP).
   - Worms reduced to 0 HP are vaporized. The last team standing wins!

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/strategy/worms_artillery
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **Left / Right** | Kąt celowania (Aim Angle) | Obraca kierunek celownika bazooki (w lewo / w prawo). |
| **Up / Down** | Siła wystrzału (Adjust Power) | Zwiększa lub zmniejsza moc wyjściową strzału (80 - 500). |
| **Space (Spacja)** | Wystrzał (Fire Bazooka) | Odpala pocisk z aktualną mocą i kątem celowania. |
| **R** | Restart (Po przegranej) | Generuje nową mapę proceduralną i restartuje starcie (dostępne na ekranie końcowym). |
| **Esc** | Wyjście (Quit) | Zamyka grę w bezpieczny sposób. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Worms (1995) by Team17**
  - *Opis powiązania*: Bezpośrednie estetyczne i mechaniczne natchnienie: postacie robaków, tury bojowe z ograniczeniem czasu, paski HP nad głowami, drążenie kraterów wybuchami oraz okrągłe wskaźniki celownika i wiatru.
- **Scorched Earth (1991) by Wendy Windham**
  - *Opis powiązania*: Rdzeń fizyki balistycznej: płynne dostosowywanie siły wystrzału oraz stałe oddziaływanie wiatru na tor lotu pocisku.
- **Artillery (1976) by BASIC Computer Games**
  - *Opis powiązania*: Koncepcja naprzemiennego celowania z dwóch odległych krawędzi ekranu ponad przeszkodami terenowymi.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

- `lurek.procgen.perlin2d` – Generowanie proceduralnego ukształtowania wyspy za pomocą gładkiego szumu fraktalnego o stałym ziarnie (seed).
- `lurek.math` – Wykorzystanie `lurek.math.newRandomGenerator` do sprawiedliwego rozstawienia drużyn oraz `lurek.math.distance` i `lerp` do obliczania spływu obrażeń w promieniu wybuchu.
- `lurek.input` – Sprawne mapowanie akcji klawiatury dla sterowania celowaniem bazooki.
- `lurek.render` – Rysowanie nieba, rysowanie terenu kolumna po kolumnie za pomocą `rect`, linia celownika i strzałka wiatru przy użyciu dynamicznych zmian kolorów.
- **Zaawansowany System Cząsteczek (Advanced Particle System):**
  - *Iskry wybuchu (Explosion Sparks)*: Emisja aż do 80 jasnopomarańczowych i żółtych iskier rozchodzących się promieniście w momencie kolizji pocisku z ziemią.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Niesamowita demonstracja fizyki lotu i modyfikowania geometrii świata. Pokazuje, jak w Lua zaimplementować integrację numeryczną (Euler integration) dla lotu pocisku z grawitacją i wiatrem, oraz jak realizować dynamiczną modyfikację bufora wysokości terenu (Deformable heightmap buffer) bez spadków wydajności.
- **Unikalność (Uniqueness):** Jedyna gra w portfolio oferująca w pełni zniszczalne środowisko 2D oraz fizykę wiatru wpływającego na tory lotu ciał.
- **Podobne gry (Similar Games):** Gra dzieli charakter fizyczny z `physics_puzzle` oraz `bridge_builder`, ale wyróżnia się unikalną turową strukturą PvP i proceduralnym generatorem świata.
