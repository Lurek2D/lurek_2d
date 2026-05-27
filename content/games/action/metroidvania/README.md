# Metroidvania

_Eksploracyjna dwuwymiarowa platformówka z otwartym światem — przemierzaj siatkę połączonych komnat, odblokowuj specjalne umiejętności (wślizg-zryw, podwójny skok), niszcz bariery i odkrywaj mapę._

## 🎮 O grze (About the Game)

**Metroidvania** to zaawansowana platformówka eksploracyjna realizująca najważniejsze mechaniki legendarnego gatunku zapoczątkowanego przez serie *Metroid* i *Castlevania*. Gra oddaje do dyspozycji gracza otwarty labirynt złożony z **siatki 3×3 połączonych ze sobą komnat (interconnected rooms)**. Przejście przez krawędź ekranu płynnie przenosi postać do sąsiedniej strefy. Każda komnata to unikalna plansza kafelkowa o wymiarach 20×15 pól.

Bohater rozpoczyna z podstawowym ruchem oraz umiejętnością odbijania się od ścian (Wall Jump). Przemierzając świat, Twoim celem jest odnalezienie dwóch ukrytych, potężnych modyfikatorów ruchu (Ability Unlocks):
1. **Zryw (Dash) [Pokój 1,1]** – wciśnięcie klawisza Shift wyzwala błyskawiczny, poziomy zryw prędkości. Pozwala on nie tylko unikać wrogów, ale fizycznie **rozbija fioletowe bramy (dash-gates)**, odblokowując nowe ścieżki w lochach.
2. **Podwójny skok (Double Jump) [Pokój 2,0]** – pozwala na wykonanie drugiego skoku w powietrzu, umożliwiając dotarcie do wysoko zawieszonych platform.

Na Twojej drodze staną patrolujący Wędrowcy (Walkers), latające drony pościgowe (Flyers) oraz wieżyczki obronne (Turrets) prowadzące ogień cykliczny. Gracz ma 5 HP z ramkami niewrażliwości po trafieniu (i-frames). Gra oferuje **interaktywną minimapę** w rogu ekranu, która na bieżąco rysuje pokoje, które już zostały odkryte.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/metroidvania
```

## 🕹️ Sterowanie (Controls)

Sterowanie łączy klasyczną fizykę platformową z obsługą odblokowywanych w locie akcji specjalnych.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **←** | Ruch w lewo | Marsz postacią w lewo po korytarzach komnaty |
| **D** / **→** | Ruch w prawo | Marsz postacią w prawo po korytarzach komnaty |
| **W** / **↑** / **Spacja** | Skok (Jump) | Skok (podwójny skok w powietrzu po odblokowaniu, wall jump po kontakcie ze ścianą) |
| **Shift** | Zryw (Dash) | Błyskawiczny zryw w poziomie niszczący fioletowe bramy (po odblokowaniu) |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Super Metroid (1994) firmy Nintendo** oraz **Castlevania: Symphony of the Night (1997) Konami**
  - *Opis powiązania*: Gra to niezwykle kompletna i miniaturowa rekonstrukcja genialnych założeń projektowych gatunku. Wersja Lurek2D precyzyjnie rekonstruuje ideę **eksploracji zablokowanej barierami (backtracking / ability-gated progression)** – fioletowe bramy (dash-gates) wymuszają powrót do wcześniej odwiedzonych lokacji po odnalezieniu zrywu (Dash). Odbijanie się od ścian (wall jump), płynne kamery przesuwające się na krawędziach pokoi (screen transition snap), minimapa śledząca eksplorację (visitation tracker) oraz serca zdrowia tworzą wspaniałe, autentyczne doświadczenie w stylu klasyków z konsoli SNES.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra reprezentuje wysoki stopień zaawansowania architektury platformowej 2D z płynnym podziałem scen i dynamicznym pozycjonowaniem:

- `lurek.camera` – Kamera płynnie podąża za graczem wewnątrz komnaty, a przy przejściu przez krawędź ekranu wykonuje precyzyjne snap-przejście (room transition snap) do sąsiedniego kadru.
- `lurek.render` – Generuje geometryczne kafelki świata (ściany, platformy, bramy niszczalne Dash-gate), postać bohatera, trzy typy wrogów, pociski, zbieralne apteczki serca oraz dynamiczną, kafelkową minimapę HUD.
- `lurek.input` – Obsługuje dynamiczne wejście platformowe, w tym buforowanie odbicia od ścian (wall jump) oraz zryw Shift.
- `lurek.particle` – Generuje obłoki pyłu przy wall-jumpie i skokach, niebieski ogon zrywu (dash ghost trail), fioletowe odłamki kruszonej bramy (block debris) oraz iskry przy zniszczeniu wrogów.
- `lurek.tween` – Animuje rozbłyski przejść pokoi, pulsowanie zebranych serc na HUD oraz płynne wysuwanie banerów odblokowania umiejętności (Dash / Double Jump unlocked).
- `lurek.timer` – Mierzy Delta Time, kontroluje czas trwania zrywu (dash cooldown), niewrażliwość po ranieniu (i-frames) oraz tempo ognia wieżyczek.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To genialny pokaz **eksploracji opartej o odblokowywanie umiejętności (ability-gated exploration mechanics)** oraz obsługi **sieci połączonych poziomów (room transition snapping system)** w czystym Lua. Ilustruje nieliniową strukturę rozgrywki, zaawansowane odbijanie od pionowych ścian (Wall Jump physics) oraz logikę dynamicznej minimapy śledzącej pamięć odwiedzonych lokacji.
- **Unikalność**: Jedyna gra w całej kolekcji Lureka z **przejściami ekranowymi pomiędzy połączonymi komnatami (screen-edge grid transitions)** oraz trwałym niszczeniem bram środowiskowych za pomocą zrywu siły (Dash block breaking).
- **Podobne gry**: *Giana Sisters* (również platformówka kafelkowa, ale o charakterze liniowym bez backtrackingu, wall-jumpów, zrywu i minimapy komnat). *Metroidvania* jest nieporównywalnie bardziej rozbudowana pod kątem struktury i eksploracji.
