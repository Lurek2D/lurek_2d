# Alchemy Lab

_Magiczne laboratorium alchemiczne — rozcieraj składniki w moździerzu, kontroluj temperaturę kociołka, butelkuj eliksiry i handluj nimi na targu, by odnaleźć mityczny Kamień Filozoficzny._

## 🎮 O grze (About the Game)

**Alchemy Lab** to wciągająca gra symulacyjno-logiczna (RPG/Simulation). Wcielasz się w postać nadwornego alchemika pracującego przy laboratoryjnym stole. Twoim celem jest eksperymentowanie ze składnikami, odkrywanie unikalnych receptur eliksirów, sprzedawanie ich na targu w celu zarabiania złota oraz ostateczne uwarzenie mitycznego **Kamienia Filozoficznego (Philosopher's Stone)**.

Praca w laboratorium dzieli się na trzy interaktywne stanowiska robocze (Workstations):
1. **Moździerz (Mortar) [Klawisz G]** – służy do rozcierania wybranych składników na drobny proszek przed wrzuceniem ich do kociołka.
2. **Kociołek (Cauldron) [Klawisze H / J]** – serce laboratorium. Wrzucasz do niego składniki i dbasz o temperaturę za pomocą podgrzewania płomienia (Heat) oraz chłodzenia (Cool). Musisz precyzyjnie utrzymywać temperaturę w zielonej strefie optymalnej – niedogrzanie da słaby eliksir, a przegrzanie doprowadzi do katastrofalnej **eksplozji kociołka** i zniszczenia składników.
3. **Butelkowanie (Bottle) [Klawisz B]** – zlanie uwarzonego płynu do fiolki w celu utworzenia gotowego produktu handlowego.

Zasoby i ekonomia:
- **6 unikalnych składników** o różnych właściwościach żywiołów (ogień, woda, ziemia, powietrze).
- **Sklep alchemiczny [Klawisz S]** – pozwala na dokupywanie brakujących surowców za zarobione złoto.
- **5 legendarnych receptur** do odkrycia i uwarzenia.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/rpg/alchemy
```

## 🕹️ Sterowanie (Controls)

Sterowanie łączy taktyczne zarządzanie temperaturą kociołka z obsługą interfejsu rzemiosła.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **1 – 6** | Wybierz składnik | Dodaje dany surowiec do moździerza |
| **G** | Rozcieraj (Grind) | Rozciera składniki w moździerzu i wrzuca do kociołka |
| **H** | Podgrzej (Heat) | Zwiększa temperaturę kociołka (płomień rośnie) |
| **J** | Schłodź (Cool) | Zmniejsza temperaturę kociołka |
| **B** | Butelkuj (Bottle) | Zlewa wywar do fiolki, tworząc gotowy eliksir |
| **S** | Sklep (Shop) | Otwiera panel zakupu dodatkowych surowców |
| **Enter** | Potwierdź / Start | Rozpoczęcie gry lub akceptacja komunikatów targu |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Gry rzemieślnicze typu Potion Craft: Alchemist Simulator** oraz **klasyczne systemy craftingu z RPG (np. Wiedźmin, Skyrim)**
  - *Opis powiązania*: Gra to zjawiskowa rekonstrukcja głębokiej mechaniki warzenia mikstur. Wersja Lurek2D doskonale oddaje **proces rzemiosła w czasie rzeczywistym (real-time crafting workflow)**, gdzie gracz fizycznie kontroluje procesy obróbki (ucieranie, gotowanie, kontrola płomienia). Unikalną nowością jest fizyka termodynamiki kociołka (cauldron heat dynamics) – temperatura nie zmienia się skokowo, lecz posiada bezwładność termiczną, co zmusza do wyczucia momentu chłodzenia w celu uniknięcia eksplozji. Estetyczny panel HUD z rzutem kociołka i płomieni oraz fiolki eliksirów tworzą klimat starożytnego laboratorium.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje zaawansowane dynamiczne renderowanie wskaźników postępu i systemów rzemiosła:

- `lurek.render` – Rysuje bogate graficznie laboratorium: moździerz, kociołek z bąbelkami wywaru (o barwie zmieniającej się dynamicznie w zależności od składników!), płomienie podgrzewacza (skalujące się z temperaturą), termometr z optymalną zieloną strefą, regał ze składnikami, fiolki oraz interfejs sklepu (shop overlays).
- `lurek.input` – Obsługuje precyzyjne odczytywanie klawiszy numerycznych (1-6) oraz przycisków akcji bojowo-rzemieślniczych bez konfliktów.
- `lurek.particle` – Generuje bąbelki wyparu w kociołku, złoty pył udanego uwarzenia mikstury, iskry ognia pod kociołkiem oraz spektakularną **eksplozję cząsteczkową dymu i ognia** przy przegrzaniu.
- `lurek.tween` – Animuje kołysanie się moździerza podczas ucierania, dynamiczne kurczenie się płomienia, napełnianie fiolki oraz powiększanie napisów transakcji handlowych.
- `lurek.timer` – Kontroluje termodynamikę kociołka (tempo nagrzewania i stygnięcia z uwzględnieniem bezwładności w Delta Time) oraz mierzy czasy procesów ucierania.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To wybitny pokaz **termodynamiki płynów i bezwładności procesów (thermal inertia physics & fluid dynamics simulation)** w czystym Lua (temperatura płynnie dąży do zera, a podgrzewanie dodaje impulsy cieplne z bezwładnością). Uczy zaawansowanych struktur danych receptur (crafting recipe verification) oraz zarządzania dynamiczną kolorystyką (RGB color blending na bazie żywiołów dodanych składników).
- **Unikalność**: Jedyny **symulator rzemiosła (crafting simulation)** w całej kolekcji Lureka z dynamiczną bezwładnością temperatury, kolizją wybuchu kociołka oraz pełną pętlą ekonomiczną kupna-sprzedaży.
- **Podobne gry**: *Adventure* (również zbieranie i łączenie przedmiotów, ale tam ma to charakter statyczny oparty na fabule), *Alchemy Lab* kładzie nacisk na ciągłe zręcznościowe gotowanie, balansowanie temperaturą i handel.
