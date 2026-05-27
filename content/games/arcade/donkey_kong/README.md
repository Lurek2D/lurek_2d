# Donkey Kong

_Klasyczna zręcznościowa platformówka wspinaczkowa — unikaj toczących się beczek, wspinaj się po drabinach i uratuj Pauline z rąk wielkiego goryla._

## 🎮 O grze (About the Game)

W **Donkey Kong** wcielasz się w postać wąsatego bohatera (Jumpmana/Mario), który wyrusza na ratunek uwięzionej na szczycie rusztowania Pauline. Konstrukcja poziomu składa się z sześciu pochyłych platform połączonych drabinami. Donkey Kong stoi na samej górze, skąd systematycznie ciska beczkami. Beczki toczą się w dół zgodnie z nachyleniem platform, spadają z krawędzi, a także mają 30% szans na zejście po drabinach, co czyni ich ruch nieprzewidywalnym.

Twoim celem jest omijanie beczek (poprzez przeskakiwanie nad nimi lub unikanie ich na drabinach) i dotarcie na najwyższy pomost do Pauline.
Aby ułatwić sobie zadanie, możesz zebrać **młot (Hammer power-up)** znajdujący się na trzeciej platformie. Daje on 5 sekund niezwyciężoności, podczas których automatycznie rozbijasz każdą napotkaną beczkę, zdobywając cenne punkty. 

Gra oferuje rosnący poziom trudności (kolejne fale przyspieszają rzuty beczkami), system 3 żyć, zaawansowane animacje oraz efekty cząsteczkowe pyłu przy lądowaniu czy rozbijaniu przeszkód.

## 🚀 Uruchomienie (Run Instructions)

Uruchom grę na silniku Lurek za pomocą poniższego polecenia:

```powershell
cargo run -- content/games/arcade/donkey_kong
```

## 🕹️ Sterowanie (Controls)

Sterowanie wykorzystuje zmapowane akcje silnika Lurek.

| Klawisz | Akcja w grze | Opis działania |
| :--- | :--- | :--- |
| **A** / **←** | Ruch w lewo | Marsz w lewo wzdłuż nachylenia platformy |
| **D** / **→** | Ruch w prawo | Marsz w prawo wzdłuż nachylenia platformy |
| **W** / **↑** | Drabina w górę | Wspinaczka po drabinie w górę |
| **S** / **↓** | Drabina w dół | Schodzenie po drabinie w dół |
| **Spacja** | Skok (Jump) | Skok w celu ominięcia beczki lub zsunięcia się z drabiny |
| **Escape** | Wyjście | Zamknięcie gry i powrót do konsoli |

---

## 🔗 Inspiracje i Klasyki (Inspirations & Classics)

- **Donkey Kong (1981) autorstwa Nintendo**
  - *Opis powiązania*: Bezpośrednia implementacja legendarnego hitu zaprojektowanego przez Shigeru Miyamoto. Gra rekonstruuje kultowy pierwszy etap (tzw. "25m" lub "Girders") ze skośnymi metalowymi belkami, toczącymi się beczkami, drabinami i Pauline na szczycie. Wersja Lurek2D zachowuje specyfikę skoku i mechaniki użycia młota, ale wzbogaca klasyka o nowoczesny podział stanów gry (z efektowną animacją cienia Donkey Konga na ekranie tytułowym), efekty cząsteczkowe pyłu przy skokach oraz płynne przejścia interfejsu oparte o tweeny.

---

## 🛠️ Wykorzystane API Lurek (Engine APIs Showcased)

Gra demonstruje zaawansowane możliwości graficzne i fizyczne Lurek2D:

- `lurek.camera` – Konfiguruje niestandardowe proporcje i rozdzielczość okna 960 × 540, dając pionowemu układowi planszy odpowiednią przestrzeń do wyświetlania.
- `lurek.render` – Rysuje stalowe skośne rusztowania, precyzyjne drabiny, animowanego Donkey Konga wykonującego rzuty, toczące się fizycznie beczki oraz pasek czasu trwania młota (Hammer gauge).
- `lurek.input` – Odczytuje akcje ruchu i skoku, blokując ruch w osi X podczas wspinaczki i zapewniając stabilne wykrywanie kolizji z drabinami.
- `lurek.particle` – Generuje rozbłyski iskier przy niszczeniu beczek młotkiem oraz obłoczki pyłu pod stopami bohatera przy lądowaniu po skoku.
- `lurek.tween` – Animuje kołysanie ramion Donkey Konga przy rzutach, pulsujące serce Pauline przy zwycięstwie oraz płynne wyskakiwanie napisów punktowych (+100, +300, +1000).
- `lurek.timer` – Mierzy precyzyjnie czas trwania power-upa młota (5 sekund) i obsługuje cykl klatek fizyki beczek.
- `lurek.window` & `lurek.event` – Kontroluje cykl życia okna i zdarzenia wyjścia.

---

## 💎 Przydatność i Unikalność (Showcase Value & Uniqueness)

- **Wartość demonstracyjna (Showcase Value)**: Znakomity przykład **platformówki 2D opartej o nachylone podłoża (sloped platforms)** i logikę wspinaczki po drabinach. Pokazuje, jak w czystym Lua zaprojektować prostą fizykę grawitacji, kolizji z podłożem o zmiennej wysokości Y(X) oraz przełączania stanów ruchu (chodzenie, wspinaczka, skok).
- **Unikalność**: Jedyna gra w sekcji Arcade wprowadzająca **zmienne stany bohatera (stan uzbrojenia młotem zmieniający interakcję z przeciwnikami)** oraz **poruszanie się po liniach pochyłych**, co stanowi spore wyzwanie programistyczne bez użycia zewnętrznego silnika fizycznego.
- **Podobne gry**: *Frogger* (omijanie przeszkód w drodze na szczyt), ale *Donkey Kong* kładzie znacznie większy nacisk na platformową grawitację, skakanie i wertykalną strukturę poziomów.
