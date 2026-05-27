# Roguelite

_Dynamiczna akcja typu roguelite z widokiem z góry w stylu Hadesa — pokonuj komnaty pełne potworów za pomocą miecza i czarów, wykonuj zrywy z klatkami niezniszczalności i twórz potężne zestawy ulepszeń (Perks)._

## 🎮 O grze (About the Game)

**Roguelite** to niezwykle zaawansowana, dynamiczna gra akcji zintegrowana z systemem rozwoju postaci i losowo generowaną zawartością komnat. Wcielasz się w postać bohatera przemierzającego niebezpieczne podziemia (Dungeons). Twoim nadrzędnym celem jest przetrwanie jak najdłużej, przechodzenie kolejnych pokoi i pokonywanie bossów.

Rozgrywka łączy szybką zręcznościową walkę z elementami RPG:
- **Zróżnicowany Arsenał** – dysponujesz szybkim atakiem mieczem (Melee Slash) o szerokim kącie rażenia, pociskiem dystansowym (Ranged Projectile) o stałym czasie odnowienia oraz **zrywem (Dash)** dającym ułamek sekundy całkowitej niezniszczalności (invulnerability frames), co pozwala przenikać bezpiecznie przez wrogie pociski.
- **Trzy Typy Wrogów** – na drodze stają nacierający Walkery wręcz, strzelający z dystansu Ranged, oraz niebezpieczni Szarżownicy (Chargers), którzy przed atakiem zatrzymują się na ładowanie energii, a następnie błyskawicznie szarżują na gracza.
- **Bramy i ulepszenia (Perk Selection)** – po pokonaniu wszystkich wrogów w pokoju otwierają się drzwi, a gracz staje przed wyborem 1 z 3 losowych modyfikatorów cech (Perks): zwiększenie obrażeń miecza, skrócenie czasów odnowienia czarów, powiększenie puli HP, odzyskanie zdrowia czy szybszy bieg.
- **Starcia z Bossami** – co każde 5 komnat plansza ulega zamrożeniu, a na arenie pojawia się potężny boss o wielofazowych wzorcach ataków i ogromnym pasku zdrowia.

Śmierć jest ostateczna (Permadeath) i wywołuje pełny ekran statystyk podsumowujących rundę (zebrane ulepszenia, zabici wrogowie, pokonane pokoje).

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/roguelite
```

## 🕹️ Sterowanie (Controls)

Sterowanie łączy precyzyjną celowanie myszką (ruch pocisków i cięć miecza podąża za kursorem) z responsywnym ruchem klawiatury.

| Klawisz / Mysz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W, A, S, D** | Ruch bohatera | Przemieszczanie się po arenie komnaty w 8 kierunkach |
| **LPM** / **J** | Cięcie mieczem | Szybki atak wręcz o określonym kącie w stronę kursora |
| **PPM** / **K** | Strzał dystansowy | Wystrzelenie pocisku plazmowego w stronę kursora |
| **Shift** | Zryw (Dash) | Błyskawiczny zryw z klatkami niezniszczalności |
| **1** / **2** / **3** | Wybór ulepszenia | Wybór danej karty ulepszenia (Perk) między pokojami |
| **R** | Restart | Restart rozgrywki po śmierci bohatera |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Hades (2020) stworzony przez Supergiant Games** oraz **klasyki gatunku jak The Binding of Isaac**
  - *Opis powiązania*: Gra stanowi wyśmienitą, zrealizowaną w Lurek2D miniaturyzację mechanik kultowego *Hadesa*. Perfekcyjnie odtwarza dynamiczną walkę opartą na kompozycji **melee slash + ranged blast + invulnerable dash**, losowe nagrody w postaci kart modyfikatorów cech (Perks) na koniec każdej areny oraz epickie, wielofazowe starcia z potężnymi bossami co 5 poziomów. Sterowanie celowaniem zintegrowane z myszką, wstrząsy kamery przy silnych uderzeniach i bogate smugi cząsteczek przy dashu tworzą niezwykle wysoki poziom dopracowania (juice).

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra reprezentuje szczyt programistycznego zaawansowania w Lua pod kątem sterowania hybrydowego klawiatura+mysz:

- `lurek.camera` – Podąża płynnie za pędzącym bohaterem, a także wykonuje dynamiczne wibracje przy zrywaniu ścian i silnych ciosach mieczem.
- `lurek.render` – Rysuje wielokątny, cieniowany świat podziemi, postać gracza, trzy typy wrogów z paskami HP, pociski, szeroki łuk cięcia mieczem (geometryczne wielokąty), oraz rozbudowany system nakładek interfejsu (wybór ulepszeń, ekran podsumowania rundy, HUD).
- `lurek.input` – Obsługuje sterowanie zintegrowane z myszką (wykrywanie kliknięć myszy oraz odczytywanie pozycji kursora worlds-space `input.getMousePosition` do celowania atakami) i dynamicznie blokuje ruch przy zrywach.
- `lurek.particle` – Generuje rozbłyski przy cięciach mieczem, iskry po zestrzeleniu przeciwników, niebieskie smugi za pędzącym bohaterem (dash trails) oraz ogień przy śmierci bossa.
- `lurek.tween` – Kontroluje płynne rozsuwanie się portali, zanikanie pasków zdrowia oraz wysuwanie menu ulepszeń.
- `lurek.timer` – Mierzy Delta Time, kontroluje czas niezniszczalności zrywu, cooldown strzałów dystansowych oraz tempo szarży wrogów Chargerów.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To absolutnie wzorcowy pokaz **hybrydowego systemu celowania myszą w świecie 2D (hybrid keyboard-mouse aiming controller)** oraz **logiki fizyki zrywu z ochroną przed obrażeniami (invulnerability frames Dash calculation)**. Uczy zaawansowanych struktur danych w Lua do zarządzania losowym pulem ulepszeń (perk progression tree) oraz wielofazowych starć bojowych.
- **Unikalność**: Jedyna gra w całej kolekcji typu **action roguelite** oferująca dynamiczne celowanie myszką (aim-at-cursor), cięcia mieczem w łuku wektorowym podążającym za kursorem oraz czasową niezniszczalność zrywu.
- **Podobne gry**: *Horde Survivor* (również widok z góry, ale tam ataki są całkowicie automatyczne i gracz nie celuje), *Infiltration* (skradanka, brak otwartej walki). *Roguelite* to bezkonkurencyjny lider dynamiki walki bezpośredniej.
