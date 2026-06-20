# Sensible Soccer

_Niezwykle szybka, dynamiczna retro-gra piłkarska — przejmij kontrolę nad 5-osobową drużyną, stosuj podania i wślizgi taktyczne, i pokonaj komputer w emocjonującym meczu z fizyką piłki._

## 🎮 O grze (About the Game)

**Sensible Soccer** (wierny hołd dla kultowej sagi piłkarskiej z 1992 roku na Amigę) to szybka, zręcznościowa symulacja piłki nożnej z widokiem z góry (bird's-eye view). Kontrolujesz 5-osobową drużynę w zielonych strojach przeciwko sterowanej przez komputer (AI) drużynie w barwach czerwonych. Gra toczy się w dynamicznym tempie, a mecze trwają 180 sekund z zamianą stron boiska w połowie czasu (po 90 sekundach).

Kluczowe mechaniki rozgrywki:
- **Automatyczne przełączanie zawodników (Auto-switching)** – w warstwie obronnej i przy podaniach gra automatycznie przekazuje kontrolę nad zawodnikiem, który znajduje się najbliżej piłki, zapewniając nieprzerwaną płynność akcji.
- **Fizyka piłki (Ball Physics)** – piłka posiada realistyczne tarcie podłoża (friction 0.88/klatkę), odbija się od krawędzi boiska oraz posiada zaawansowany system siły kopnięcia (kick power charging).
- **Sztuczna inteligencja CPU** – komputerowi przeciwnicy aktywnie ścigają piłkę najbliższym zawodnikiem, podczas gdy reszta zespołu utrzymuje pozycje taktyczne w formacji.
- **Wślizgi taktyczne (Slide Tackle)** – pozwala na szybki skok wślizgiem w kierunku piłki w celu jej odebrania wrogowi (wiązany z ryzykiem minięcia piłki).
- **Zasady meczu** – pełne oznakowanie boiska (pole karne, koło środkowe, bramki), naprzemienne rozpoczynanie gry ze środka po stracie bramki oraz spektakularne celebrowanie goli.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/retro/sensible_soccer
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało zoptymalizowane pod kątem szybkiej i zręcznościowej rozgrywki klawiaturowej.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W, A, S, D** | Ruch zawodnika | Poruszanie się aktualnie kontrolowanym piłkarzem po boisku |
| **Spacja** | Silny strzał (Shot) | Mocne kopnięcie piłki w kierunku spojrzenia (strzał na bramkę) |
| **F** | Podanie (Pass) | Precyzyjne podanie piłki do najbliższego kolegi z drużyny |
| **T** | Wślizg (Slide Tackle) | Wykonanie agresywnego wślizgu obronnego w celu odebrania piłki |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Sensible Soccer / Sensible World of Soccer (1992-1994) stworzony przez Sensible Software na komputer Amiga**
  - *Opis powiązania*: Gra to zjawiskowa rekonstrukcja legendarnego hitu stworzonego przez Jona Hare'a. Nasza wersja w Lurek2D idealnie odtwarza charakterystyczny **widok z lotu ptaka (tele-view)**, niesamowicie szybkie tempo rozgrywki, płynną mechanikę automatycznego przełączania zawodników oraz precyzyjną kontrolę nad toczącą się piłką. Gra rezygnuje ze złożonego symulowania na rzecz czystego zręcznościowego "feeling-u" rozgrywki podwórkowej. Dodatkowo wzbogaciliśmy wersję o animowane, rozbłyskujące celebrowanie goli przy pomocy cząsteczek, ślady wślizgów na murawie oraz płynną kamerę śledzącą piłkę.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra kompleksowo demonstruje precyzyjną fizykę wieloobiektową oraz interakcje z kamerą:

- `lurek.camera` – Kamera dynamicznie śledzi pozycję piłki, a nie gracza, co pozwala zachować idealny widok na całą akcję rozgrywającą się na boisku.
- `lurek.render` – Rysuje zieloną murawę z pełnym białym liniowaniem boiska, bramki z siatkami, zawodników obu drużyn z animacją biegu i wślizgu, piłkę z cieniem (nadającym jej iluzję wysokości przy strzałach) oraz interfejs wyniku.
- `lurek.input` – Odpowiada za precyzyjne odczytywanie kombinacji ruchowych oraz natychmiastowe wyzwalanie podań i wślizgów.
- `lurek.particle` – Generuje obłoki kurzu spod butów biegnących i wykonujących wślizgi piłkarzy, smugę za mocno uderzoną piłką oraz eksplozję confetti przy zdobyciu bramki (celebration burst).
- `lurek.tween` – Animuje spektakularne powiększanie i pulsowanie napisów "GOAL!" na środku ekranu oraz przejścia ekranów połowy meczu.
- `lurek.timer` – Mierzy czas trwania meczu (180 sekund), obsługuje odliczanie wślizgów i precyzyjnie przelicza prędkości w Delta Time.
- `lurek.window` & `lurek.event` – Kontrolują konfigurację okna i bezpieczne wyjście.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To wybitny pokaz **kamery śledzącej obiekt niezależny (ball-focused tracking camera)** oraz ** dynamicznej logiki przełączania kontroli (auto-switching entity controller)** w czasie rzeczywistym. Doskonale ilustruje, jak zarządzać sztuczną inteligencją wielu wędrujących agentów (piłkarze CPU i bezczynni piłkarze gracza) realizujących proste zadania taktyczne (pozycja formacji vs atak na piłkę).
- **Unikalność**: Jedyna gra sportowo-zespołowa (team sports game) w całym repozytorium Lureka z pełną symulacją drużynową, mechaniką wślizgów obronnych i dryfu piłki.
- **Podobne gry**: Brak zbliżonych gier sportowo-zespołowych w kolekcji. Gra jest absolutnie unikalną pozycją.
