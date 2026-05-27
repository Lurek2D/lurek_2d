# 🎣 Fishing — Side-View Fishing Simulator

**Category:** Sports / Fishing Simulator  
**Engine:** Lurek2D  
**Language:** Polish & English  

---

## 🇵🇱 Opis Gry (Polish)

### Krótki Opis (Elevator Pitch)
**Fishing** to relaksujący, side-view symulator wędkarstwa jeziornego, będący hołdem dla kultowych gier zręcznościowych takich jak *Sega Bass Fishing* czy wbudowanych minigier wędkarskich ze *Stardew Valley* i serii *Animal Crossing*. Gracz wciela się w postać wędkarza na brzegu urokliwego jeziora. Dostosuj moc rzutu, zarzuć wędkę, obserwuj ruchy spławika i zareaguj na branie! Po zacięciu ryby uruchamia się minigra holowania w formie przeciągania liny (tug-of-war), gdzie kluczem jest optymalne napięcie żyłki. Gra oferuje 5 unikalnych gatunków ryb (od pospolitej strzebli po legendarną Złotą Rybkę), 3 rodzaje przynęt, dynamiczną pogodę (deszcz zwiększający brania) oraz pełen cykl dobowy (dzień/noc), w którym nocą aktywują się rzadkie gatunki głębinowe.

### Pętla Rozgrywki i Mechaniki
1. **Rzut i Branie (Casting & Bite Window):**
   - Przytrzymaj **Spację**, by naładować pasek mocy rzutu. Puść, by posłać spławik na określoną odległość w głąb jeziora.
   - Spławik kołysze się na wodzie. Gdy ryba podpłynie, spławik gwałtownie zanurkuje pod wodę, wydając dźwięk i pokazując wykrzyknik (!).
   - Masz 1.5 sekundy na zacięcie (naciśnięcie Spacji). Zbyt wolna reakcja oznacza stratę przynęty!
2. **Minigra Holowania (Tug-of-War Tension):**
   - Po zacięciu przechodzisz w tryb walki z rybą. Ryba próbuje odpłynąć w prawo w dynamicznych zrywach (Fight Burst).
   - Przytrzymuj i puszczaj **Spację**, by zwijać żyłkę (Reel). Reeling przyciąga rybę w lewo do brzegu, ale zwiększa napięcie żyłki (Tension).
   - **Uwaga na zerwanie:** Utrzymywanie napięcia w strefie krytycznej (> 80%) przez ponad 2 sekundy spowoduje zerwanie żyłki i ucieczkę ryby! Przyciągnij rybę na odległość 20px od brzegu, by ją złowić.
3. **Przynęty i Gatunki Ryb:**
   - **Worm (Robak - 1):** Podstawowa, wszechstronna przynęta.
   - **Fly (Mucha - 2):** Przyciąga pstrągi (Trout) i okonie (Bass) o 150-200% mocniej.
   - **Deep Bait (Przynęta Głębinowa - 3):** Niezbędna do łowienia sumów (Catfish) na głębokiej wodzie.
   - **Katalog ryb:** Minnow (5 pkt), Trout (15 pkt), Bass (30 pkt), Catfish (25 pkt), Golden Fish (100 pkt - legenda!).
4. **Pogoda i Cykl Dobowy (Day/Night & Rain):**
   - Doba trwa 120 sekund. W nocy niebo ciemnieje, pojawiają się gwiazdy, a szansa na złowienie legendarnej Złotej Rybki i Suma rośnie dwukrotnie.
   - **Deszcz (Rain):** Losowa ulewa zwiększa częstotliwość brań dwukrotnie.
   - **Warunki zwycięstwa:** Złów **10 ryb** do wiadra lub wyciągnij legendarną **Złotą Rybkę** (5% szansy w nocy), by odnieść natychmiastowe zwycięstwo!

---

## 🇬🇧 Game Description (English)

### Elevator Pitch
**Fishing** is a highly relaxing, atmospheric side-view fishing simulator standing as a direct mechanical tribute to arcade masterpieces like *Sega Bass Fishing* and beloved cozy minigames in *Stardew Valley* and *Animal Crossing*. Step onto the grassy shore of a beautiful lakeside, charge your casting arm, send your bobber into the deep, and wait for the perfect bite! Once hooked, engage in a high-tension, tug-of-war reeling minigame: balance line tension, fight off aggressive fish pull bursts, and pull your catch ashore. With 5 distinct species (from tiny Minnows to the legendary Golden Fish), 3 bait choices, real-time rain cycles, and a dynamic 120s day/night progression, this project is Lurek2D's ultimate cozy simulator!

### Gameplay Loop & Mechanics
1. **Casting & Hooking:**
   - Hold **Space** to charge your casting force. Release to send your bobber to the desired distance.
   - The bobber floats gently on the waves. When a fish approaches, the bobber dips underwater with a splash and a warning exclamation point (!).
   - Tap Space within 1.5 seconds to hook the fish. Missing the window forfeits your bait!
2. **Reeling Minigame (Tug-of-War):**
   - Hooking triggers combat mode. The fish fights back in intense bursts, pulling to the right.
   - Hold and release **Space** to reel. Reeling pulls the fish leftward but increases line Tension.
   - **Line Snap Hazard:** Keeping the tension bar in the critical zone (> 80%) for more than 2 seconds snaps the line, losing the fish. Guide the fish within 20px of the shoreline to land it.
3. **Bait Selection & Species Registry:**
   - **Worm (1):** Standard bait attracting all species equally.
   - **Fly (2):** Boosts Trout and Bass attraction by 1.5x - 2.0x.
   - **Deep Bait (3):** Attracts bottom-dwelling Catfish by 3.0x when cast deep.
   - **Fish Catalog:** Minnow (5 pts), Trout (15 pts), Bass (30 pts), Catfish (25 pts), Golden Fish (100 pts - legendary).
4. **Rain Weather & Day/Night Curves:**
   - A full day/night cycle runs for 120 seconds. Nightfall dims the skies, sparks blinking stars, and doubles the spawn rates of legendary Golden Fish and Catfish.
   - **Rain:** Random showers spawn rain particles and double bite frequencies.
   - **Victory:** Fill your bucket with **10 catches** OR land the ultra-rare **Golden Fish** for an instant legendary win!

---

## 🚀 Uruchomienie (Run Instructions)

Aby uruchomić grę w silniku Lurek2D, wpisz w konsoli PowerShell:

```powershell
cargo run -- content/games/sports/fishing
```

---

## 🕹️ Sterowanie (Controls)

| Klawisz (Key) | Akcja (Action) | Opis (Description) |
| :--- | :--- | :--- |
| **Space (Spacja - Przytrzymaj)** | Ładuj rzut (Charge Cast) | Ładuje pasek mocy rzutu wędki (0% - 100%). |
| **Space (Spacja - Puść)** | Zarzuć wędkę (Cast Line) | Posyła spławik na określoną odległość w głąb jeziora. |
| **Space (Spacja - Klik)** | Zacięcie / Holowanie (Hook / Reel) | Zaciąga żyłkę podczas brania lub ściąga rybę do brzegu (holowanie). |
| **1** | Robak (Select Worm) | Wybiera robaka jako przynętę (podstawowa przynęta). |
| **2** | Mucha (Select Fly) | Wybiera sztuczną muchę (bonus na pstrągi i okonie). |
| **3** | Przynęta głębinowa (Deep Bait) | Wybiera ciężką przynętę głębinową (bonus na sumy). |
| **Esc** | Wyjście (Quit) | Zamyka grę w bezpieczny sposób. |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Sega Bass Fishing (1997) by Sega**
  - *Opis powiązania*: Bezpośrednie odwzorowanie widoku z boku (profile lake cut), mechanika przeciągania ryby w lewo z kontrolą naprężenia wędki oraz wybór przynęt dopasowanych pod ryby.
- **Stardew Valley (Wędkarstwo) by ConcernedApe**
  - *Opis powiązania*: Zastosowanie paska napięcia (Tension Bar) z koniecznością balansowania i unikania skrajnych przeciążeń, które zrywają żyłkę.
- **Animal Crossing**
  - *Opis powiązania*: Koncepcja brania sygnalizowanego gwałtownym zanurkowaniem spławika pod wodę z dźwiękowym splashem oraz obecność ryb legendarnych.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

- `lurek.ui` – Wczytywanie dynamicznego interfejsu TOML (`ui.toml`) z panelami paska napięcia żyłki, etykietami wiadra, zebranych punktów, pory dnia, ostrzeżeń o przeciążeniu i ekranem podsumowania.
- `lurek.input` – Zaawansowane pobieranie informacji o stanie przytrzymania klawisza Spacja (charging) oraz szybkie zacięcie jednym kliknięciem.
- `lurek.window` / `lurek.event` – Wyświetlanie klatek FPS, konfiguracja okna (800x600 px) i bezpieczne wyjście z gry przy Esc.
- **Aż Cztery Równoległe Systemy Cząsteczek (Multiple Particle Systems):**
  - *Plusk spławika/ryby (Water Splash)*: Błękitne kropelki wody unoszące się przy uderzeniu spławika w wodę lub zrywach ryby.
  - *Kropelki deszczu (Rain)*: Lekkie, skośne kreski deszczu spadające z nieba podczas ulewy.
  - *Rozbłyski sukcesu (Catch Sparkles)*: Złote i żółte gwiazdki rozchodzące się wokół wędkarza po złowieniu ryby.
  - *Kręgi wodne (Ripples)*: Rozchodzące się pierścienie fal wodnych wokół spławika i holowanej ryby.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value):** Znakomita demonstracja algorytmów fizycznych i matematycznych w Lua. Gra implementuje płynne symulowanie drgań żyłki wędkarskiej, pętle nieliniowych zrywów ryb (Fight state machine in Lua) oraz tabelę dynamicznego spawnu ryb opartą na głębokości rzutu (cast_x), porze dnia i rodzaju przynęty.
- **Unikalność (Uniqueness):** Jedyny symulator wędkarstwa z pełną fizyką napięcia żyłki, cyklem dnia/nocy zmieniającym szanse spawnu i dynamiczną pogodą.
- **Podobne gry (Similar Games):** Brak duplikatów. Gra dzieli spokojny, relaksujący klimat z `farming_sim`, ale opiera się na unikalnej zręcznościowej minigrze przeciągania liny.
