# Brick Breaker

_Dynamiczna, nowoczesna zręcznościówka typu Breakout/Arkanoid — odbijaj piłkę paletką, niszcz wielobarwne cegły o zróżnicowanej wytrzymałości i łap opadające modyfikatory rozgrywki._

## 🎮 O grze (About the Game)

**Brick Breaker** to zręcznościowa gra akcji nawiązująca do kultowego *Arkanoida*. Kontrolujesz paletkę u dołu ekranu, odbijając piłkę w kierunku muru cegieł. Celem gry jest całkowite zniszczenie wszystkich bloków na planszy.

Cechy i zaawansowane mechaniki gry:
- **Wytrzymałość bloków (Brick HP)** – cegły ułożone są w 10 kolumnach i 4–8 wierszach (zależnie od poziomu). Bloki posiadają od 1 do 3 punktów życia, a stopień ich uszkodzenia sygnalizuje zmiana koloru (fioletowy [3 HP] → niebieski [2 HP] → zielony [1 HP]).
- **Kąt odbicia (Paddle Segment Angling)** – kierunek lotu piłki po odbiciu od paletki zależy od precyzyjnego punktu kontaktu. Trafienie w środek paletki odbija piłkę pionowo, natomiast uderzenie bliżej krawędzi nadaje jej ostry kąt boczny, co pozwala na precyzyjne celowanie w szczeliny.
- **Dynamiczne ulepszenia (Power-ups)** – zniszczenie cegły daje 30% szans na upuszczenie modyfikatora:
  - **Szerokość (W) [Pomarańczowy]** – czasowo poszerza paletkę na 8 sekund, ułatwiając odbijanie.
  - **Multi-ball (M) [Błękitny]** – błyskawicznie dzieli każdą aktywną piłkę na ekranie na dwie dodatkowe piłki, wywołując chaos.
  - **Spowolnienie (S) [Zielony]** – zmniejsza prędkość piłki o 45% na 8 sekund, dając graczowi pełną kontrolę.

Gra oferuje rosnący stopień trudności (prędkość piłki rośnie z każdym poziomem), zaawansowany HUD oraz system 3 żyć.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/action/brick_breaker
```

## 🕹️ Sterowanie (Controls)

Sterowanie wykorzystuje responsywne mapowanie akcji wejściowych silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **D** lub **←** / **→** | Ruch paletki | Przesuwanie paletki w lewo i w prawo |
| **Spacja** | Wypuszczenie piłki | Wystrzelenie przyklejonej piłki na początku rundy |
| **Enter** | Start / Następny poziom | Uruchomienie gry, restart lub przejście po wygranej |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Arkanoid (1986) stworzony przez firmę Taito** oraz **Breakout (1976) autorstwa Atari**
  - *Opis powiązania*: Gra to kompletny i świetnie zbalansowany klon kultowego *Arkanoida*. Replikuje najważniejsze atuty legendarnego automatu: zróżnicowaną wytrzymałość bloków, ulepszenia spadające z nieba wymagające ryzykownego złapania ich paletką, oraz fizykę kąta odbicia zależną od punktu kontaktu (segment angling). Wersja Lurek2D unowocześnia rozgrywkę poprzez wprowadzenie płynnych cząsteczek kruszących się cegieł, tweenowych rozbłysków przy ukończeniu poziomu oraz precyzyjnego wsparcia dla wielu piłek jednocześnie na ekranie (Multi-ball entity logic).

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje wydajność silnika Lurek w obsłudze wielu dynamicznych obiektów oraz fizyki kolizji:

- `lurek.camera` – Gwarantuje stałą rozdzielczość wirtualną viewportu, ułatwiając precyzyjne obliczenia kolizji z krawędziami okna.
- `lurek.render` – Rysuje neonowe, gradientowe cegły z obrysami, okrągłe piłki, paletkę, spadające pigułki ulepszeń oraz interfejs HUD (HP bloków, paski czasu trwania power-upów, stan żyć).
- `lurek.input` – Odpowiada za płynne i pozbawione opóźnień przesuwanie paletki.
- `lurek.particle` – Generuje efektowne chmury kolorowych iskier (particles) rozchodzące się przy niszczeniu każdej cegły (kolor cząsteczek odpowiada kolorowi zniszczonego bloku).
- `lurek.tween` – Kontroluje jasny błysk ekranu (flash) przy ukończeniu poziomu.
- `lurek.timer` – Kontroluje odliczanie czasu działania ulepszeń (8 sekund) oraz Delta Time ruchu piłek i paletki.
- `lurek.window` & `lurek.event` – Kontrola nad oknem i bezpiecznym wyjściem.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: To genialny pokaz **fizyki odbić wektorowych (collision vector reflection)** i obsługi **wielu aktywnych piłek jednocześnie (multi-entity list updates)**. Pokazuje również, jak za pomocą prostych liczników czasu w update zarządzać czasowym działaniem ulepszeń (power-up cooldown/duration mapping) z graficznym paskiem postępu.
- **Unikalność**: Jedyna gra w sekcji Action oferująca **dynamiczne mnożenie piłek (multi-ball split)** wykraczające poza standardową fizykę pojedynczego pocisku, co testuje wydajność kolizji dla chmary obiektów.
- **Podobne gry**: *Pong* (również paletka i piłka), ale *Brick Breaker* jest przeznaczony dla jednego gracza, stawia na niszczenie statycznych bloków, system HP cegieł oraz łapanie spadających modyfikatorów rozgrywki.
