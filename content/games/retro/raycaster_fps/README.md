# Raycaster FPS

_Trójwymiarowy shooter FPP w stylu Wolfenstein 3D — przemierzaj korytarze narysowane metodą rzucania promieni DDA, eliminuj wrogów, zarządzaj amunicją i przełączaj warunki pogodowe._

## 🎮 O grze (About the Game)

**Raycaster FPS** to zaawansowana technologicznie symulacja klasycznego trójwymiarowego strzelca pierwszoosobowego (FPP), nawiązująca bezpośrednio do ery przełomowych gier z początku lat 90. Całość opiera się na **autorskim silniku raycastingowym napisanym w Lua**, rzucającym 320 promieni na klatkę w obrębie 72-stopniowego pola widzenia (FOV).

Cechy i zaawansowane mechaniki gry:
- **Silnik Raycastowy z DDA** – precyzyjny algorytm Digital Differential Analysis (DDA) wylicza kolizje promieni ze ścianami, realizując korekcję efektu rybiego oka (fish-eye correction) oraz cieniowanie głębią (distance fog).
- **Proceduralne teksturowanie i cieniowanie** – 6 typów ścian (kamień, cegła, niebieski kamień, czerwony kamień, ściana omszona, złoty skarbiec) oraz wielopasmowe cieniowanie gradientowe podłogi i sufitu.
- **Rysowanie obiektów (Billboard Sprite Rendering)** – apteczki, amunicja i klucze są renderowane jako dwuwymiarowe sprajty zawsze obrócone do gracza (billboards) z uwzględnieniem bufora głębokości (depth buffer), co zapewnia ich poprawne zasłanianie przez ściany.
- **Sztuczna inteligencja wrogów** – przeciwnicy posiadają wzrok Line of Sight (LOS), ścigają gracza po wykryciu i prowadzą ataki typu hitscan.
- **Zmienne warunki pogodowe** – gracz może w locie przełączać pogodę (deszcz, śnieg lub bezchmurnie) za pomocą klawiszy funkcyjnych F1–F3, co nakłada na widok 3D dynamiczne cząsteczki atmosferyczne.
- **Efekty walki** – broń gracza ma animację strzału, płomień wylotowy (muzzle flash), wywołuje czerwony błysk obrażeń na ekranie oraz iskry w miejscu uderzenia.

Plansza zawiera w rogu pomocniczą minimapę 2D ułatwiającą orientację w przestrzeni.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/retro/raycaster_fps
```

## 🕹️ Sterowanie (Controls)

Sterowanie łączy poruszanie się po lochach ze strzelaniem i kontrolą pogody.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W** / **S** | Ruch przód / tył | Przemieszczanie się w głąb korytarzy lochu |
| **A** / **D** | Strafe lewo / prawo | Krok w bok (przemieszczanie boczne) |
| **Q** / **E** | Obrót kamery | Obracanie głowy bohatera w lewo / w prawo |
| **Spacja** | Strzał (Fire) | Wystrzelenie z pistoletu (system hitscan z detekcją odległości) |
| **F1** | Pogoda: Czysto | Wyłącza efekty cząsteczkowe deszczu i śniegu |
| **F2** | Pogoda: Deszcz | Włącza dynamiczne strugi deszczu w widoku 3D |
| **F3** | Pogoda: Śnieg | Włącza płatki opadającego śniegu |
| **Enter** | Start / Restart | Uruchomienie gry lub restart po porażce |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Wolfenstein 3D (1992) stworzony przez id Software**
  - *Opis powiązania*: Gra to niezwykle drobiazgowa rekonstrukcja legendarnego protoplasty gatunku strzelanek 3D stworzonego przez Johna Carmacka i Johna Romero. Nasza wersja w Lurek2D wiernie naśladuje **oryginalny silnik renderowania rzutów kolumn pikseli**, rzuty geometryczne DDA, buforowanie głębokości (zabezpieczające przed "prześwitywaniem" sprajtów przez ściany) oraz retro-niebieskie sufity i ceglane ściany. Nowością jest autorski system zmiennej pogody (deszcz/śnieg) nanoszony na trójwymiarową perspektywę oraz efekty cząsteczkowe eksplozji obcych i wystrzałów.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra to niesamowite osiągnięcie matematyczne zrealizowane na niskopoziomowym renderingu 2D:

- `lurek.render` – Rysuje setki pionowych linii o różnej wysokości i kolorze symulujących ściany 3D, cieniuje sufit i podłogę gradientami (`render.rectangle`), rysuje billboardy sprajtów broni, wrogów i przedmiotów oraz minimapę.
- `lurek.input` – Obsługuje jednoczesny ruch i rotację za pomocą zmapowanych klawiszy wejścia.
- `lurek.particle` – Odpowiada za iskry po trafieniu w ścianę pociskiem, rozbłyski lufy oraz dynamiczne, opadające płatki śniegu i deszczu (weather particles).
- `lurek.tween` – Kontroluje czerwony błysk ekranu po otrzymaniu obrażeń od wroga oraz animacje napisów HUD.
- `lurek.timer` – Mierzy Delta Time, czasy przeładowania broni oraz zarządza animacjami poruszania wrogów.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i poprawnym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To genialny pokaz **czystej matematyki trójwymiarowej (custom pure-Lua 3D raycasting mathematical pipeline)** zaimplementowanej na prymitywach 2D. Uczy zaawansowanych technik obliczania rzutu perspektywicznego, korekcji zniekształceń soczewki, zarządzania buforem głębi (Z-buffer) i pozycjonowania billboardów sprajtowych w przestrzeni trójwymiarowej.
- **Unikalność**: Jedyny shooter 3D (3D FPS) w całej kolekcji, dodatkowo wyposażony w dynamiczny **system symulacji pogody w przestrzeni FPP (3D-space weather overlays)**.
- **Podobne gry**: *Dungeon Crawler* (również raycaster, ale oparty na systemie GPU `buildScene` i skupiony na eksploracji RPG), *Raycaster FPS* to rasowy, szybki shooter run-and-gun z dynamiczną wymianą ognia i zbieraniem amunicji.
