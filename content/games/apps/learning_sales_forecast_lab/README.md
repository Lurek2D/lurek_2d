# Learning Sales Forecast Lab

Mała aplikacja demo pokazująca `lurek.learning` na konkretnych danych sprzedaży miesięcznej.

## Dane wejściowe
- 8 miesięcy sprzedaży: `12100..15180`
- flaga promocji per miesiąc: `0/1`
- macierz nagród 3x3 dla wyboru tieru cenowego

## Co robi demo
- Liczy reprezentację sekwencji przez `newLstm(2,4)` i `newGru(2,4)`.
- Wybiera najlepszy tier cenowy przez `LQLearner` z ustawionymi Q-values.
- Wypisuje deterministyczny raport do konsoli.

## Run
`cargo run -- content/games/apps/learning_sales_forecast_lab`
