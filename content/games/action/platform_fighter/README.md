# Platform Fighter

_Lokalna zręcznościowa bijatyka platformowa dla 2 graczy inspirowana Super Smash Bros. — odrzucaj przeciwnika na bazie rosnących procentów obrażeń, wykonuj podwójne skoki i chroń swoje rezerwy żyć (Stocks)._

## 🎮 O grze (About the Game)

**Platform Fighter** to niezwykle dynamiczna gra zręcznościowa przeznaczona do lokalnej rywalizacji dla dwóch graczy na jednym ekranie (kanapowy versus). Gra w pełni replikuje przełomowe założenia turniejowych bijatyk platformowych, gdzie celem nie jest tradycyjne wyzerowanie paska zdrowia wroga, lecz **wyrzucenie go poza granice ekranu (Blast Zones)**.

Cechy i unikalne mechaniki:
- **Procenty Obrażeń (Damage % System)** – każdy otrzymany cios nie zabija bezpośrednio, ale zwiększa Twój licznik procentowy (od 0% w górę). Im wyższa wartość procentowa, tym silniejszy staje się odrzut (Knockback) przy kolejnym trafieniu.
- **Skalowany Odrzut (Knockback Scaling)** – przy 0% ciosy ledwie przesuwają postać; powyżej 150% uderzenie potrafi wystrzelić wojownika na drugi koniec mapy z olbrzymią prędkością.
- **Strefy Śmierci (Blast Zones)** – wypadnięcie poza dowolną krawędź ekranu (lewo, prawo, góra lub dół) skutkuje utratą życia (Stock). Po stracie życia gracz odradza się w centrum mapy z 2-sekundową niewrażliwością (blinking).
- **Zróżnicowane Ataki**:
  - **Zwykły cios (Normal Attack) [F / K]** – szybki cios z bliska (8% obrażeń, mały odrzut). Wykonany w powietrzu spycha wroga gwałtownie w dół (spike down).
  - **Atak specjalny (Special Projectile) [G / L]** – wystrzeliwuje pocisk dystansowy (12% obrażeń, średni odrzut) z 1-sekundowym czasem odnowienia.
- **Podwójny skok (Double Jump)** – każdy z graczy może wykonać dwa skoki w powietrzu, co ułatwia ratowanie się (recovery) przed wypadnięciem z areny.

Arena składa się z głównego podłoża oraz trzech mniejszych, wiszących w powietrzu platform.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/platform_fighter
```

## 🕹️ Sterowanie (Controls)

Gra oferuje w pełni zmapowane sterowanie dla dwóch graczy na jednej klawiaturze.

| Gracz 1 (Niebieski - Lewa strona) | Klawisz / Akcja | Gracz 2 (Czerwony - Prawa strona) | Klawisz / Akcja |
| :--- | :--- | :--- | :--- |
| **A** / **D** | Ruch lewo / prawo | **Strzałka w lewo** / **Strzałka w prawo** | Ruch lewo / prawo |
| **W** | Skok (podwójny skok) | **Strzałka w górę** | Skok (podwójny skok) |
| **F** | Zwykły cios (8% dmg) | **K** | Zwykły cios (8% dmg) |
| **G** | Pocisk specjalny (12% dmg) | **L** | Pocisk specjalny (12% dmg) |
| **Enter** | Rozpoczęcie walki (Title) | **Escape** | Natychmiastowe wyjście |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Seria Super Smash Bros. (od 1999) stworzona przez Masahiro Sakurai dla Nintendo**
  - *Opis powiązania*: Gra to genialna, zrealizowana w Lurek2D rekonstrukcja fundamentalnych mechanik jednej z najpopularniejszych serii bijatyk na świecie. Perfekcyjnie odwzorowano tu **fizykę skalowanego odrzutu na bazie procentów (percentage-based knockback scaling)**, system ratowania się w locie podwójnymi skokami (recovery game), niszczycielskie ciosy powietrzne w dół (aerial downward spikes) oraz precyzyjne granice ekranowej strefy śmierci (Blast Zones). Wizualnym unowocześnieniem są chmury cząsteczkowych rozbłysków uderzeń i ogonów lecących postaci oraz trzęsienia kamery.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje wydajność silnika w kalkulacji złożonej fizyki kolizji w locie dla dwóch graczy:

- `lurek.camera` – Centruje i stabilizuje widok areny, a także wykonuje dynamiczne wstrząsy przy silnych odrzutach na wysokim procencie obrażeń.
- `lurek.render` – Rysuje platformy areny, sylwetki wojowników (odkształcenia, mruganie niewrażliwości), pociski plazmowe, wskaźniki HUD (procenty obrażeń, zapas żyć-stocks) dla obydwu graczy.
- `lurek.input` – Obsługuje jednoczesną, bezkonfliktową grę wieloosobową na jednej klawiaturze, z precyzyjnym czasem odnawiania pocisków.
- `lurek.particle` – Generuje rozbłyski przy uderzeniach, smugi dymne (trails) ciągnące się za graczem odrzuconym z dużą prędkością oraz iskry eksplozji przy wylocie w strefę śmierci.
- `lurek.tween` – Kontroluje płynne skale liczników obrażeń, pulsujące teksty menu oraz napisy końcowe zwycięstwa.
- `lurek.timer` – Mierzy Delta Time ruchu i fizyki, 2 sekundy ochrony po odrodzeniu oraz odlicza 1-sekundowy cooldown pocisków.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To wybitny pokaz **złożonej fizyki odrzutów opartej na skalowanej masie i obrażeniach (scaled impulse vector physics)** w czystym Lua (siła wektora odrzutu jest bezpośrednio mnożona przez współczynnik procentów obrażeń ofiary, a grawitacja wpływa na łuk lotu). Prezentuje również doskonałą implementację kolizji wieloplatformowych (one-way platforms, gdzie gracz może wskoczyć od dołu na wiszącą platformę).
- **Unikalność**: Jedyna gra w całej kolekcji typu **platform fighter (bijatyka platformowa)** oferująca mechanikę odrzutów Blast Zones oraz procentów obrażeń zamiast tradycyjnych punktów życia HP.
- **Podobne gry**: *Fighting Game* (bijatyka 1v1, ale tam walka opiera się na klasycznym zerowaniu HP, brakuje grawitacji platformowej, odrzutów Blast Zones i jest przeznaczona dla 1 gracza przeciwko AI). *Platform Fighter* to czysta, zręcznościowa rywalizacja 2-osobowa w locie.
