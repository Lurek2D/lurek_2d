# Cannon Fodder (Action Edition)

_Taktyczna dowódcza potyczka oddziału wojskowego — kieruj ruchem żołnierzy za pomocą kliknięć myszką, pozwalając im na automatyczne ostrzeliwanie wrogów w zasięgu wzroku z użyciem przyspieszanej optymalizacji przestrzennej._

## 🎮 O grze (About the Game)

**Cannon Fodder (Action Edition)** to odmienna, zorientowana na strategię czasu rzeczywistego (RTS) wersja taktycznego klasyka. Zamiast bezpośredniego kontrolowania oddziału klawiaturą, wcielasz się w rolę dowódcy taktycznego: wydajesz **rozkazy poruszania się kliknięciem myszki**, podczas gdy Twoi żołnierze automatycznie wyszukują cele i prowadzą ogień zaporowy.

Cechy i mechaniki gry:
- **Click-to-Move (Sterowanie myszą)** – wskaż punkt w dżungli lewym przyciskiem myszy, a czteroosobowy oddział automatycznie ułoży się w formację i pomaszeruje w wyznaczone miejsce.
- **Auto-Aim & Auto-Fire** – żołnierze automatycznie namierzają i ostrzeliwują najbliższego widocznego przeciwnika w swoim zasięgu wzroku. Nie musisz ręcznie kontrolować ognia – skupiasz się w pełni na pozycjonowaniu oddziału i unikaniu zasadzek.
- **Wykrywanie wrogów i ściganie** – wrogowie patrolują teren, a po wejściu gracza w ich promień detekcji (Alert Indicator) wszczynają alarm i ruszają w pościg.
- **Siatka kolizji i przeszkód** – ciemnozielone kafelki drzew i ścian stanowią nieprzekraczalną barierę dla żołnierzy oraz skutecznie blokują trajektorię pocisków.
- **Wydajne pozycjonowanie przestrzenne** – gra wykorzystuje wbudowany w silnik moduł **Spatial Hash (siatka przestrzenna)** do błyskawicznego wyliczania dystansów i wykrywania najbliższych celów.

Zwycięstwo następuje po eliminacji wszystkich wrogów na mapie, porażka zaś – po stracie wszystkich 4 żołnierzy oddziału.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/cannon_fodder
```

## 🕹️ Sterowanie (Controls)

Sterowanie opiera się na precyzyjnych rozkazach wydawanych myszką w czasie rzeczywistym.

| Klawisz / Przycisk | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **LPM (Lewy Przycisk Myszy)** | Rozkaz ruchu | Wydaje rozkaz marszu oddziału we wskazany punkt na mapie |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Cannon Fodder (1993) stworzony przez Sensible Software** oraz **taktyczne gry RTS typu Command &os; Conquer**
  - *Opis powiązania*: Gra łączy kultową Amigową stylistykę militarną *Cannon Fodder* z mechaniką dowodzenia typu Point-and-Click znaną z gier strategicznych RTS. Zamiast zręcznościowego biegania i ręcznego celowania, ta wersja kładzie nacisk na **makro-zarządzanie i strategiczne pozycjonowanie oddziału**, oferując autorski system automatycznej obrony. Z technicznego punktu widzenia, kluczową innowacją jest zastosowanie optymalizatora **Spatial Hash** silnika Lurek, który pozwala na płynne, bezkonfliktowe wyszukiwanie celów dla dziesiątek jednostek w czasie rzeczywistym.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje zaawansowane moduły matematyczne i strategiczne silnika Lurek:

- `lurek.math.newSpatialHash` – Zaawansowane API optymalizacji przestrzennej (Spatial Hashing) w Lurek2D. Używane do broad-phase grupowania jednostek w komórkach przestrzennych, co pozwala na błyskawiczne i bezwysiłkowe zapytania o najbliższych przeciwników w zasięgu ognia.
- `lurek.render` – Rysuje kafelkową mapę dżungli z blokującymi drzewami, postacie żołnierzy i wrogów, linie trajektorii pocisków, okręgi eksplozji oraz wskaźniki alarmów wrogów.
- `lurek.input` – Przechwytuje kliknięcia myszy (`mousepressed`) i konwertuje pozycję ekranową kliknięcia na koordynaty wirtualne świata gry.
- `lurek.timer` – Kontroluje Delta Time fizyki poruszania i częstotliwość automatycznych strzałów.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To jedyny w całym repozytorium pokaz **wykorzystania optymalizatora przestrzennego (Spatial Hashing showcase)**. Prezentuje, jak pisać gry z dużą liczbą dynamicznie wchodzących w interakcje obiektów bez narażania na spadki wydajności wynikające z kosztownych pętli typu O(N^2). Ilustruje również sterowanie Point-and-Click z automatycznym omijaniem prostych przeszkód kafelkowych.
- **Unikalność**: Jedyna gra strategiczna w czasie rzeczywistym (tactical micro-RTS) w sekcji Action oferująca **całkowicie zautomatyzowane celowanie i prowadzenie ognia (auto-aim combat)** na bazie Spatial Hash.
- **Podobne gry**: *Cannon Fodder* z sekcji Retro (ten sam motyw i podobna grafika, ale tamta wersja opiera się na bezpośrednim sterowaniu klawiaturą WASD, ręcznym celowaniu i strzelaniu Spacją oraz rzucaniu granatami, bez użycia Spatial Hash). Wersja Action kładzie nacisk na taktyczne dowodzenie myszką.
