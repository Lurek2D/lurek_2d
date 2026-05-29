# Learning Route Attention Lab

Aplikacja demo z konkretnymi danymi mapy ryzyka i sekwencji trasy.

## Dane wejściowe
- mapa ryzyka 4x4 (`RISK_GRID`)
- sekwencja trasy 3x4 (`ROUTE_SEQUENCE`)
- sekwencja pamięci 3x4 (`MEMORY_SEQUENCE`)

## Co robi demo
- Przetwarza mapę przez `Conv2D` i `MaxPool2D`.
- Koduje sekwencję przez `PositionalEncoding` i `MultiHeadAttention`.
- Uruchamia `TransformerEncoder` + `TransformerDecoder`.
- Wypisuje deterministyczny raport (kształty tensorów i max tile).

## Run
`cargo run -- content/games/apps/learning_route_attention_lab`
