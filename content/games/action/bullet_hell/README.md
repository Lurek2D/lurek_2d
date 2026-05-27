# Bullet Hell

_Ekstremalna strzelanka zaporowa — unikaj tysięcy wrogich pocisków, muskaj je dla punktów (graze) i toruj sobie drogę niszczycielskymi bombami czyszczącymi planszę._

## 🎮 O grze (About the Game)

**Bullet Hell** (hołd dla japońskich strzelanek typu *Danmaku*, takich jak seria *Touhou*) to widowiskowy vertical-shooter stawiający na absolutną precyzję, refleks i zdolność planowania drogi w gęstym roju barwnych pocisków wroga. Gra oferuje dynamiczną i wysoce hipnotyzującą rozgrywkę.

Najważniejsze mechaniki gry:
- **Precyzyjny Hitbox i Skupienie (Focus Mode)** – Twój statek kosmiczny ma zaledwie 2-pikselowy punkt trafienia (hitbox) na środku kadłuba. Przytrzymanie klawisza **Shift** aktywuje tryb skupienia: ruch statku spowalnia o 60%, a hitbox staje się wyraźnie widoczny jako świecący punkt, umożliwiając mikromanewry pomiędzy ścianami pocisków.
- **Mechanika Muskania (Graze Mechanic)** – przelatywanie wrogich pocisków ekstremalnie blisko Twojego hitboxa (w promieniu 20px) wywołuje zjawisko muskania (Graze). Zwiększa to Twój mnożnik punktów (score multiplier), nagradzając ryzykowne manewry. Mnożnik zeruje się po utracie życia.
- **Bomby Czyszczące (Screen-clearing Bombs)** – dysponujesz bombami taktycznymi (3 na życie). Użycie bomby (klawisz X) wywołuje potężną falę uderzeniową, która natychmiastowo niszczy wszystkie pociski wroga na ekranie, dając chwilę wytchnienia.
- **Wrogowie i Wzorce (Bullet Curtains)** – napotkasz małych przeciwników (strzały celowane), średnich (wzorce spiralne) oraz wielkich (promieniste rozbłyski). Co 5 fal pojawia się mini-boss o wielu emiterach pocisków tworzących geometryczne firany ognia.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/bullet_hell
```

## 🕹️ Sterowanie (Controls)

Sterowanie zostało oparte o precyzyjny i wysoce responsywny system akcji silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **W, A, S, D** | Ruch statkiem | Poruszanie się myśliwcem we wszystkich kierunkach ekranu |
| **Spacja** | Strzał | Prowadzenie ciągłego ognia plazmowego |
| **Shift** (przytrzymanie) | Focus Mode (Skupienie) | Spowalnia ruch o 60% i ujawnia świecący 2px hitbox |
| **X** | Detonacja Bomby | Wywołuje falę uderzeniową usuwającą wszystkie wrogie kule z ekranu |
| **Enter** | Start / Restart | Uruchomienie gry lub restart po ekranie porażki |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Seria Touhou Project (autorstwa ZUN-a / Team Shanghai Alice)** oraz **DoDonPachi (stworzone przez Cave)**
  - *Opis powiązania*: Gra jest precyzyjną, zrealizowaną w Lurek2D repliką kultowych japońskich strzelanek *danmaku* (dosł. "kurtyna pocisków"). Odtwarza kluczowe zasady tego niszowego gatunku: miniaturowy hitbox ukryty w sprajcie gracza, mechanikę Graze nagradzającą ekstremalną odwagę, tryb Focus spowalniający ruch w celu wpasowania się w milimetrowe szczeliny pocisków, oraz ratunkowe bomby usuwające kule. Geometryczne wzorce emiterów tworzą spektakularne kalejdoskopy barwnych linii i okręgów o wysokiej płynności.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra jest niesamowitym pokazem wydajności silnika w przetwarzaniu i renderowaniu tysięcy ruchomych obiektów kolizyjnych jednocześnie:

- `lurek.camera` – Blokuje stabilną rozdzielczość wirtualną pionowego viewportu, dbając o retro proporcje znane z automatów arcade typu "tate".
- `lurek.render` – Rysuje statek gracza, precyzyjny świecący hitbox, zastępy wrogów, chmary pocisków o różnych barwach i rozmiarach, falę uderzeniową bomby oraz pasek zdrowia bossa.
- `lurek.input` – Obsługuje jednoczesny odczyt kierunkowy, strzały oraz dynamicznie modyfikuje wektor prędkości przy wciśniętym klawiszu Shift (Focus).
- `lurek.particle` – Generuje rozbłyski przy niszczeniu wrogów, iskry otarcia pocisków o statek (graze particles) oraz pył silników.
- `lurek.tween` – Kontroluje płynne rozszerzanie się fali uderzeniowej bomby, migotanie punktu hitboxa oraz pulsowanie ostrzeżeń bossa.
- `lurek.timer` – Mierzy Delta Time i z ogromną precyzją wylicza trajektorie rotacji emiterów pocisków wrogów na bazie funkcji matematycznych.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To absolutnie bezkonkurencyjny pokaz **wysokiej wydajności przetwarzania obiektów (high-performance object processing)**. Silnik Lurek przetwarza i renderuje ponad **500–1000 aktywnych pocisków w klatce** w czystym Lua wraz z detekcją kolizji AABB/Circle i mechaniką Graze, zachowując stabilne 60 klatek na sekundę.
- **Unikalność**: Jedyna gra w sekcji Action wprowadzająca ** Focus Mode z wizualizacją hitboxa**, system **Graze (muskanie kul)** oraz geometryczne generatory chmur pocisków.
- **Podobne gry**: *Galaga*, *Space Invaders* (strzelanki), ale *Bullet Hell* przewyższa je stokrotnie pod kątem liczby pocisków na ekranie, braku formacji, oraz nacisku na precyzyjny taniec pomiędzy kurtynami ognia.
