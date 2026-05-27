# Dyna Blaster

_Taktyczna zręcznościówka typu bomber — rozmieszczaj bomby na siatce gridowej, niszcz przeszkody, eliminuj wrogów i unikaj stref rażenia eksplozji._

## 🎮 O grze (About the Game)

W **Dyna Blaster** wcielasz się w postać sapera poruszającego się w labiryncie opartym na siatce (grid). Celem gry jest przetrwanie, eliminacja wędrujących po mapie przeciwników oraz zdobywanie punktów za rozbijanie skrzyń za pomocą bomb. 

Gra posiada zaawansowane propagowanie fali wybuchu (grid blast propagation) – po podłożeniu bomby, eksplozja rozchodzi się w czterech kierunkach kardynalnych. Fala uderzeniowa jest blokowana przez niezniszczalne, solidne ściany, ale rozbija niszczalne skrzynie, które mogą skrywać power-upy lub przejścia. Przeciwnicy poruszają się autonomicznie za pomocą wbudowanej inteligencji omijania przeszkód. 
Gra oferuje dopracowany cykl scen oparty na systemie `lurek.scene` (Menu, Gameplay, Game Over), a także stylowy interfejs HUD zrealizowany za pomocą plików TOML.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/arcade/dyna_blaster
```

## 🕹️ Sterowanie (Controls)

Gra korzysta z precyzyjnego systemu obsługi wejścia silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W, A, S, D** / **Strzałki** | Ruch gracza | Poruszanie się postacią po siatce labiryntu (góra, dół, lewo, prawo) |
| **Spacja** | Podłożenie bomby | Umieszcza bombę pod nogami postaci w bieżącej komórce siatki |
| **Enter** / **LPM** | Wybór w menu | Potwierdzenie opcji w menu głównym lub restart gry po porażce |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Bomberman / Dyna Blaster (1990) autorstwa Hudson Soft**
  - *Opis powiązania*: Gra jest wierną rekonstrukcją mechaniki legendarnego *Bombermana* (znanego w Europie na komputerach Amiga i MS-DOS właśnie jako *Dyna Blaster*). Odwzorowuje kluczowe elementy klasyka: zniszczalne skrzynie tworzące dynamiczny układ korytarzy, taktyczne blokowanie płomieni przez ściany twarde (solid blocks) oraz wrogów, których należy wabić w pułapki ogniowe. Implementacja w Lurek2D unowocześnia strukturę poprzez zastosowanie zaawansowanego systemu zarządzania encjami **ECS (Entity Component System)**, co ułatwia zarządzanie stanami bomb, płomieni i AI wrogów w czystym Lua.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra reprezentuje wysoki poziom modularności kodu i prezentuje kompleksowe możliwości integracji systemów silnika:

- `lurek.scene` – Zarządza przełączaniem całych kontekstów gry (Scena Menu, Scena Rozgrywki, Scena Konńca Gry), upraszczając czyszczenie i inicjalizację pamięci.
- `lurek.ecs` – Serce logiczne gry. Cała rozgrywka opiera się o uniwersum encji (Player, Bomb, Enemy, Exploding Flame, Crates), ułatwiając detekcję kolizji i cykl życia obiektów.
- `lurek.render` – Odpowiada za bezpośrednie rysowanie kafelkowej mapy (grid), postaci, wrogów z dynamicznym cieniowaniem oraz animowanych płomieni wybuchu.
- `lurek.ui` – Zaawansowane wczytywanie interfejsu (HUD, licznik żyć i punktów, overlay porażki) za pomocą pliku `ui.toml` poprzez `lurek.ui.loadLayoutFile`.
- `lurek.timer` – Mierzy Delta Time oraz czas do eksplozji bomby (detonacja po 2 sekundach) i czas trwania płomieni.
- `lurek.input` – Wczytuje zdarzenia klawiatury i myszy (kliknięcia menu) w zintegrowany sposób.
- `lurek.event` – Wykrywa sygnały wyjścia z aplikacji.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To sztandarowy pokaz wykorzystania wbudowanego w Lurek systemu **ECS (Entity Component System)** oraz silnika scen (`lurek.scene`). Udowadnia, że Lurek świetnie nadaje się do tworzenia gier o strukturze obiektowej z wieloma dynamicznymi encjami wchodzącymi w skomplikowane interakcje (kolizje płomieni z wrogami, graczem i skrzyniami).
- **Unikalność**: Jedyna gra w sekcji Arcade z pełnym podziałem na modularne pliki w katalogu `modules` (map_grid, gameplay, enemy_brain, ui_overlay) oraz jedna z niewielu demonstrujących zaawansowany **TOML-driven UI** – interfejs HUD ładowany bezpośrednio z konfiguracji zewnętrznej pliku `ui.toml`.
- **Podobne gry**: Brak zbliżonych gier o strukturze czysto kafelkowo-taktycznej na siatce gridowej w katalogu Arcade.
