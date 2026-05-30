# Lurek2D MMO Support - Plan Szczegolowy

Status: Draft v1 (manager synthesis)
Data: 2026-05-30

## 1. Cel

Zaprojektowac i wdrozyc MMO support dla scenariusza:
- 1000 graczy jednoczesnie w lobby world map
- mapa lobby 8x8 = 64 pokoje
- przejscie do bitwy w pokoju: max 15 vs 15 (30 graczy)

Plan ma byc zgodny z ograniczeniami Lurek2D i ma rozdzielac:
- to, co zostaje w silniku (engine-side)
- to, co musi dzialac jako backend zewnetrzny (external control-plane)

## 2. Jak powstal plan

Plan zostal zlozony z 4 niezaleznych perspektyw:
- Architect: architektura docelowa i opcje rozwiazania
- Planner: fazy 0-12, metryki, bramki binarne
- Developer: backlog Epics -> Tasks z ownerami
- Verifier/Review: luki, residual risks, zaostrzenie gate'ow

## 3. Ograniczenia architektoniczne (binding)

Plan musi respektowac:
- runtime-only (bez embeddowania edytora do binarki)
- desktop-only (bez mobile i wasm)
- 2D-only
- brak cykli zaleznosci
- thin bindings w lua_api
- composition root one-way

Wniosek: control-plane MMO nie moze byc "upchany" do core engine. Najbezpieczniejsza droga to model hybrid.

## 4. Opcje i decyzja

## Opcja A - All-in-engine

Opis:
- lobby, matchmaking, allocator, authority i telemetry glownie w silniku

Plusy:
- szybki start lokalny

Minusy:
- duze ryzyko przeciazenia scope engine
- wzrost coupling i trudniejsza skalowalnosc operacyjna
- wyzsze ryzyko naruszenia granic architektury

## Opcja B - Hybrid (WYBRANA)

Opis:
- Engine: data-plane (transport, sync helpery, Lua facade)
- External: control-plane (auth, lobby, allocator, battle authority, telemetry, anti-abuse)

Plusy:
- zgodne z filozofia Lurek2D
- najlepszy balans koszt/skalowalnosc/ryzyko
- czyste granice odpowiedzialnosci

Minusy:
- wymaga ostrego kontraktu protokolu i wersjonowania

## Opcja C - External authoritative full thin-client

Opis:
- prawie caly stan i logika po stronie zewnetrznych serwerow

Plusy:
- mocna kontrola anty-cheat

Minusy:
- potencjalnie gorsza responsywnosc
- wyzszy koszt backend

Decyzja: Opcja B (Hybrid).

## 5. Architektura docelowa (Hybrid)

| Komponent | Odpowiedzialnosc | Granica | Krytycznosc |
|---|---|---|---|
| Network Transport Adapter | ENet/TCP/WS, framing, poll | engine | krytyczna |
| Net Sync Helpers | pack/unpack, snapshot, reconcile | engine | wysoka |
| Lua Network Facade | API lurek.network do flow matchmaking/session | engine | wysoka |
| Gateway/Session | session token, edge rate limit, routing | external | krytyczna |
| Lobby Service | presence, room directory 8x8 | external | krytyczna |
| Room Allocator | rozklad 1000 graczy na 64 pokoje | external | krytyczna |
| Battle Orchestrator | start/stop instancji bitwy 15v15 | external | krytyczna |
| Authoritative Battle Runtime | walidacja input i symulacja serwerowa | external | krytyczna |
| State Sync Backbone | fanout delta + interest management | external | krytyczna |
| Telemetry Pipeline | SLI/SLO, tracing, alerty | external | wysoka |
| Anti-Abuse | flood/abuse detection i reakcja | external | wysoka |
| Persistence | profile, sesje, historia i audit | external | wysoka |

## 6. Przeplywy krytyczne

## A) Login -> Lobby

1. Klient pobiera token sesji przez Gateway.
2. Lobby Service przypisuje do roomu mapy 8x8.
3. Klient dostaje strumien stanu lobby i presence.

## B) Lobby -> Bitwa 15v15

1. Matchmaking/Allocator wybiera battle room.
2. Orchestrator uruchamia instancje.
3. Gateway robi handoff endpointu bitwy.

## C) Tick bitwy

1. Klient wysyla input commands.
2. Serwer autoratywny waliduje i liczy tick.
3. Klient dostaje delta snapshots i robi reconcile.

## D) Koniec bitwy

1. Wynik i metryki trafiaja do persistence.
2. Lobby aktualizuje stan mapy/roomu.
3. Gracze wracaja do lobby lub kolejki.

## 7. Plan faz 0-12 (Owner + Binary Gate)

## Horyzont MVP (F0-F5)

| Faza | Owner | Zakres | Binary Gate |
|---|---|---|---|
| F0 Discovery/NFR Freeze | Architect + Leads | NFR, granice engine/external, risk register | zatwierdzony baseline v1 + 0 blockerow P0 |
| F1 Contract-first API | Backend Lead + Engine Lead | kontrakty auth/match/session/reconnect | contract tests 100%, 0 breaking changes |
| F2 Control-plane Skeleton | Backend Team | auth, lobby, allocator, presence, health endpoints | integration smoke green, p95 API < 120 ms przy 200 RPS |
| F3 Engine Data-plane Adapter | Engine Team | adapter do control-plane + Lua facade | cargo test + clippy -D warnings + testy Lua green |
| F4 E2E Match/Lobby | Backend + Engine + QA | queue -> lobby -> room reservation -> join | 1000 parallel users, success >= 99.5%, MM p95 <= 12 s |
| F5 Battle 15v15 + Reconnect | Gameplay Net + Backend Session | 64 roomy, lifecycle bitwy, reconnect basic | 64x30 przez 60 min crash-free, reconnect >= 92% |

## Horyzont Scale-up (F6-F8)

| Faza | Owner | Zakres | Binary Gate |
|---|---|---|---|
| F6 Tick Authority + Delta Optim | NetSync Team | drift control, delta compression, snapshot cadence | tick drift p99 <= 8 ms, payload delta -25% vs MVP |
| F7 Match Scale + Sharding | Backend + Data + SRE | party, region, shard routing, fairness | 10k synthetic, MM p95 <= 8 s, queue drop < 0.5% |
| F8 Reliability + Partial Failure | Backend + SRE | circuit breaker, retry budget, graceful degrade | chaos 1h: join >= 97%, reconnect >= 95% |

## Horyzont Production Hardening (F9-F12)

| Faza | Owner | Zakres | Binary Gate |
|---|---|---|---|
| F9 Security + Anti-Abuse | Security + Backend + Engine | auth hardening, abuse scoring, rate limiting | 0 CVE/P1 open, false-positive abuse < 3% |
| F10 Observability + Incident Ops | SRE + QA Perf | dashboard SLO, tracing, runbooki | MTTA <= 5 min, MTTR <= 20 min w game-day |
| F11 Release Strategy | Release + SRE + Leads | canary 5/25/50/100, auto rollback | 2 dry-run canary + rollback < 3 min |
| F12 Go-live + Hypercare | PM + On-call Leads | 14 dni stabilizacji i codzienny review | 14 dni bez Sev-1 + SLO OK w >=95% dni |

## 8. Metryki SLO po horyzontach

| Horyzont | Join latency | Tick drift | Packet loss tolerance | Reconnect success | Matchmaking time |
|---|---|---|---|---|---|
| MVP | p95 <= 450 ms, p99 <= 900 ms | p99 <= 15 ms | do 2% bez disconnect storm | >= 92% (90 s) | p95 <= 12 s |
| Scale-up | p95 <= 250 ms, p99 <= 600 ms | p99 <= 8 ms | do 3% z degradacja jakosci, bez utraty sesji | >= 96% (120 s) | p95 <= 8 s, p99 <= 15 s |
| Hardening | p95 <= 180 ms, p99 <= 400 ms | p99 <= 5 ms | do 5% chwilowo z auto-recovery | >= 98% (120 s) | p95 <= 6 s, p99 <= 10 s |

## 9. Backlog Epics -> Tasks (detal wykonawczy)

## Epic E0 - Foundations i kontrakty

- E0-T01 (Engine Lead): zdefiniowac granice engine/external dla modelu hybrid
  - Proposed modules: src/network/mod.rs, src/lua_api/network_api.rs, docs/specs/network.md
  - AC: podpisany kontrakt odpowiedzialnosci, zero konfliktow z constraints
- E0-T02 (Backend Architect): zdefiniowac vendor-neutral backend contracts
  - AC: spec auth/match/session/reconnect v1 gotowy do contract tests

## Epic E1 - Identity/Auth Session

- E1-T01 (Engine): auth bootstrap i refresh token przez net runtime
  - Proposed modules: src/network/net_thread.rs, src/network/http.rs, src/lua_api/network_api.rs
  - AC: flow auth bez blokowania game loop
- E1-T02 (Backend): login/refresh/revoke i token lifecycle
  - AC: contract tests positive/negative pass

## Epic E2 - Matchmaking/Lobby

- E2-T01 (Engine): backend-managed matchmaking request/cancel + assignment events
  - Proposed modules: src/network/lobby.rs, src/network/net_thread.rs, src/lua_api/network_api.rs
  - AC: Lua dostaje assignment event i obsluguje timeout/cancel
- E2-T02 (Backend): queue + allocator + fairness policy
  - AC: SLA kolejki i brak starvation przypadkow

## Epic E3 - Reconnect i Session Lease

- E3-T01 (Engine): reconnect token i lease renew flow
  - Proposed modules: src/network/host.rs, src/network/net_thread.rs, src/network/relay.rs
  - AC: reconnect do tej samej sesji w oknie lease
- E3-T02 (Backend): lease manager + idempotent rejoin
  - AC: jednoznaczna decyzja accept/reject dla reconnect

## Epic E4 - Snapshot Authority Split

- E4-T01 (Engine): typy snapshot full/delta/corrective i reconcile policy
  - Proposed modules: src/network/net_sync.rs, src/network/message.rs, src/lua_api/network_api.rs
  - AC: brak teleport jitter > prog QA
- E4-T02 (Backend): monotonic sequence + stale drop policy
  - AC: stream-order tests pass

## Epic E5 - Interest Management/Bandwidth

- E5-T01 (Engine): interest filters i budzety payload per channel
  - Proposed modules: src/network/host.rs, src/network/constants.rs, src/network/message.rs
  - AC: bandwidth per client w budzecie dla scenariusza referencyjnego
- E5-T02 (Backend): dynamic sub/unsub wg strefy i kontekstu
  - AC: egress redukowany bez utraty eventow krytycznych

## Epic E6 - Delivery Semantics

- E6-T01 (Engine): jednoznaczne reliable/unreliable ordering per channel
  - Proposed modules: src/network/host.rs, src/network/tcp.rs, src/network/websocket.rs
  - AC: brak silent reordering gdzie zabronione
- E6-T02 (Backend): retry budget + dedupe keys
  - AC: delivery matrix zatwierdzona i przetestowana

## Epic E7 - Security/Anti-Abuse

- E7-T01 (Engine): payload validation, flood guards, parse hardening
  - Proposed modules: src/network/error.rs, src/network/message.rs, src/network/net_thread.rs
  - AC: malformed/flood nie destabilizuje runtime
- E7-T02 (Backend): abuse scoring + throttling + audit trail
  - AC: detection -> mitigation -> audit dziala end-to-end

## Epic E8 - Observability/SLO

- E8-T01 (Engine): metryki RTT/loss/queue/correction/reconnect
  - Proposed modules: src/network/net_thread.rs, src/network/host.rs, src/lua_api/network_api.rs
  - AC: metryki widoczne i korelowane po session/room
- E8-T02 (Backend): telemetry schema + dashboard i alert policy
  - AC: test alarmow 100% expected trigger

## Epic E9 - Sharding/Handoff

- E9-T01 (Engine): shard handoff bez restartu sesji
  - Proposed modules: src/network/lobby.rs, src/network/net_thread.rs, src/lua_api/network_api.rs
  - AC: transfer shard-to-shard przechodzi integration suite
- E9-T02 (Backend): shard directory + handoff token + rollback path
  - AC: bounded downtime i failover pass

## Epic E10 - QA Harness/Determinism

- E10-T01 (Engine QA): MMO regression pack
  - Proposed tests: tests/rust/unit/network_tests.rs, tests/lua/unit/test_network_core_unit.lua, tests/lua/security/test_network.lua
  - AC: deterministic replay pass + security regression pass
- E10-T02 (Backend QA): consumer-driven contract pack
  - AC: zgodnosc klient-serwer dla current i n-1

## Epic E11 - Rollout/Migration

- E11-T01 (Engine Release): protocol version negotiation + feature flags
  - Proposed modules: src/network/constants.rs, src/network/error.rs, src/lua_api/network_api.rs
  - AC: kompatybilnosc n i n-1
- E11-T02 (Backend Release): canary/rollback runbook
  - AC: 2 dry-run rollout i 1 rollback drill zaliczony

## Epic E12 - Production Readiness

- E12-T01 (Engine Ops): guardrails, panic containment, recoverability
  - Proposed modules: src/network/net_thread.rs, src/network/host.rs
  - AC: 24h soak + chaos pass bez krytycznych regresji
- E12-T02 (Backend SRE): on-call readiness i game-day
  - AC: dyzur i runbook validated

## 10. Plan testow

| Typ testu | Zakres | Kiedy | Gate |
|---|---|---|---|
| Unit | parsery, allocator rules, tick math, lease logic | F1-F3, F6, F9 | pass 100%, flaky <= 1% przy 3 rerunach |
| Integration | kontrakty API + E2E queue/lobby/battle | F2-F5, F7 | scenariusze krytyczne green |
| Load | 1000 lobby, 64 rooms, 15v15, bursty | F4-F8, F11 | p95/p99 wg SLO, error budget nieprzekroczony |
| Chaos | kill service, jitter/loss, partial outage | F8, F10, F11 | brak Sev-1, recovery w progach |
| Security | replay, flood, malformed, bypass attempts | F7-F11 | 0 open critical |

## 11. Operacje i release

- Observability:
  - tracing end-to-end join -> match -> battle
  - logi strukturalne z correlation id
  - dashboard SLO per region/shard/room
- Incident response:
  - runbook klas incydentow
  - war-room procedure
  - postmortem template
- Release strategy:
  - canary 5% -> 25% -> 50% -> 100%
  - automatyczny rollback na breach SLO
  - freeze windows i compat gate klient-serwer

## 12. Top ryzyk i mitigacje

1. przeciaganie scope do engine: trzymac control-plane poza core
2. desync przy jitterze: authoritative tick + sequence + reconcile window
3. przeciazenie pasma: AOI/interest + delta compression
4. reconnect storm: lease + backoff + bounded retry
5. queue deadlock/starvation: fairness tests + fallback FIFO
6. abuse/flood: edge throttling + scoring + quarantine
7. niedeterministyczny protokol: contract tests i replay traces
8. awaria instancji bitwy: restart policy + checkpoint + graceful degrade
9. brak obserwowalnosci: obligatoryjne telemetry gates
10. niezgodnosc wersji: negotiate + n-1 compatibility mandatory
11. alert fatigue: priorytety P1/P2 i tuning progow
12. rollout regression: canary + auto rollback < 3 min

## 13. Definition of Done (15)

1. Kazdy krytyczny flow ma kontrakt request/response/error.
2. Runtime engine nie blokuje game loop przez I/O network.
3. Reconcile jitter miesci sie w progu QA.
4. Timeout/retry/cancel istnieja dla operacji krytycznych.
5. Reconnect lease ma testy pozytywne i negatywne.
6. Security suite pokrywa malformed/replay/flood.
7. Delivery class matrix jest jawna i testowana.
8. Interest management spelnia budzet transferu.
9. Metryki sa korelowane po session/room/shard.
10. Contract tests current i n-1 przechodza.
11. Rollout ma canary i rollback z progami.
12. Specy i changelog sa aktualizowane razem z kontraktem.
13. Soak i chaos przechodza bez krytycznych regresji.
14. Incident runbook i on-call sa zweryfikowane game-day.
15. Sign-off koncowy: Engine Lead + Backend Lead + QA Lead + SRE Lead.

## 14. Quick wins (2 sprinty)

Sprint 1:
- domknac auth bootstrap/refresh
- domknac matchmaking request/cancel + assignment event
- dorzucic bazowe security payload tests

Sprint 2:
- reconnect lease basic
- metryki RTT/loss/queue/reconnect
- pierwszy E2E 1000 users synthetic i raport luk

## 15. Artefakty do utworzenia

W repo Lurek:
- ten plan (ideas)
- spec kontraktow i event schema
- test plan i benchmark spec
- release playbook i runbook operacyjny
- raporty load/chaos/security

Poza repo (external backend):
- auth service
- matchmaking service
- lobby directory
- session allocator
- battle orchestrator + authoritative runtime
- telemetry stack
- anti-abuse pipeline
- persistence store i retention policy

## 16. Warunki replanningu

- jesli matchmaking p95 > 12s po F4: redesign kolejki przed F5
- jesli reconnect < 92% po F5: blokada F6
- jesli chaos F8 generuje Sev-1: blokada F9-F11
- jesli rollback drill F11 nie dziala: zakaz F12 go-live

## 17. Minimalny plan startowy na teraz

1. Zamknac F0 i F1 dokumentacyjnie + kontraktowo.
2. Rownolegle uruchomic F2 (backend skeleton) i F3 (engine adapter) pod wspolnym contract test gate.
3. Po zielonym E2E (F4) dopiero uruchomic battle-scale (F5/F6).
