# Horde Survivor

_Mroczna, zręcznościowa walka z hordą potworów — unikaj fal nacierających przeciwników, zbieraj kryształy doświadczenia i twórz potężne buildy bojowe za pomocą rotujących pocisków._

## 🎮 O grze (About the Game)

**Horde Survivor** (hołd dla niesamowicie popularnej gry *Vampire Survivors*) to wciągająca gra akcji z widokiem z góry. Wcielasz się w postać bohatera uwięzionego na bezkresnej arenie, stawiając czoła nieprzerwanie rosnącym hordom potworów spawnujących się na krawędziach ekranu i dążących do Twojej eliminacji.

Kluczowe mechaniki i pętla rozgrywki:
- **Automatyczny Atak Rotacyjny (Orbiting Projectiles)** – nie musisz ręcznie celować. Wokół Twojego bohatera krążą magiczne pociski plazmowe, które automatycznie ranią każdego potwora wchodzącego w promień ich orbity.
- **Kryształy XP i Przyciąganie (XP Gems)** – pokonani przeciwnicy pozostawiają po sobie lśniące kryształy doświadczenia. Podbiegnięcie blisko nich wyzwala **magnetyczne przyciąganie** (auto-collection radius), zasysając je i napełniając pasek doświadczenia (XP bar).
- **Progresja i Poziomy (Level up upgrades)** – każdy awans na kolejny poziom zamraża grę i pozwala na wybór 1 z 3 wylosowanych kart ulepszeń:
  - **Dodatkowe pociski (+2 Projectiles)** – zwiększa zagęszczenie krążących pocisków.
  - **Szybkość (+20% Speed)** – przyspiesza ruch bohatera.
  - **Siła ciosu (+3 Damage)** – pociski zadają większe obrażenia.
  - **Promień orbitowania (+15px Orbit Radius)** – pociski krążą na większym dystansie.
  - **Przebijalność (+1 Pierce)** – pociski przebijają wrogów, raniąc wielu z nich przed zniknięciem.
- **Cztery typy wrogów** – powolne Walkery (1 HP), szybkie Runnery (2 HP), masywne Tanki (5 HP) oraz niebezpieczne Explodery (3 HP), które po śmierci wybuchają, raniąc inne potwory oraz gracza.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/horde_survivor
```

## 🕹️ Sterowanie (Controls)

Sterowanie łączy precyzyjny ruch klawiatury z obsługą kart ulepszeń w interfejsie.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W, A, S, D** | Ruch bohatera | Przemieszczanie się po bezkresnej arenie w 8 kierunkach |
| **1** / **2** / **3** | Wybór ulepszenia | Wybór danej karty ulepszenia podczas ekranu Level Up |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Vampire Survivors (2022) stworzone przez poncle (Luca Galante)** oraz **klasyki typu Magic Survival**
  - *Opis powiązania*: Gra to niezwykle grywalna, w pełni zrealizowana w Lurek2D replika fenomenu gier typu *bullet heaven* i *horde survival*. Doskonale odtwarza ona uzależniającą pętlę rozgrywki: unikanie wrogów, zbieranie kryształów doświadczenia, losowy wybór kart ulepszeń budujących niepowtarzalne synergie (builds) oraz rosnącą presję hordy. Z technicznego punktu widzenia, gra unowocześnia klasyka o płynny ruch wektorowy pocisków (obliczany funkcjami trygonometrycznymi wokół gracza) oraz zaawansowane cząsteczki XP zasysane wektorem przyciągania magnetycznego.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra stanowi doskonały poligon doświadczalny dla obsługi chmar obiektów oraz magnetycznego przyciągania fizycznego:

- `lurek.camera` – Podąża płynnie za poruszającym się bohaterem, symulując bezkresną arenę walki.
- `lurek.render` – Rysuje gracza, chmary wędrujących potworów, rotujące pociski plazmowe, świecące kryształy XP, wybuchy Exploderów oraz zaawansowane nakładki UI (pasek postępu XP na górze ekranu, panel wyboru ulepszeń, statystyki).
- `lurek.input` – Odpowiada za responsywny ruch oraz obsługę klawiszy numerycznych podczas pauzy awansu poziomu.
- `lurek.particle` – Generuje rozbłyski przy pokonywaniu wrogów, iskry orbitowania pocisków, płomienie eksplodujących potworów oraz ślady ciągnące się za zasysanymi magnetycznie kryształami XP.
- `lurek.tween` – Animuje rozszerzanie się panelu Level Up, pulsowanie ostrzeżeń niskiego stanu zdrowia oraz napisy informujące o zgonie gracza.
- `lurek.timer` – Mierzy precyzyjnie czas przetrwania (survival timer), kontroluje narastający w czasie spawn wrogów i Delta Time fizyki.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To genialny pokaz **fizyki przyciągania wektorowego (gravitational/magnetic attraction vector logic)** w czystym Lua (kryształy XP wykrywają bliskość gracza i płynnie przyspieszają w jego kierunku wzdłuż wektora dystansu). Prezentuje również doskonałe zarządzenie stanem pauzy logicznej z pełnym rysowaniem interfejsu (game menu pause and state selection).
- **Unikalność**: Jedyny "bullet heaven" (reverse bullet-hell) w całej kolekcji Lureka z **automatycznym systemem orbitujących tarcz bojowych** oraz rozbudowanym drzewem ulepszeń (level up progression system) w locie.
- **Podobne gry**: *Bullet Hell* (również shooter z chmarami obiektów), ale *Horde Survivor* stawia na automatyczny atak, zbieranie przedmiotów XP i dynamiczny rozwój RPG postaci, zamiast unikania kurtyn ognia.
