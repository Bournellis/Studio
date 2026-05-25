# Track 00 - First Slice Foundation

- Last Updated: `2026-05-20`
- Track Status: `COMPLETE - T00-P01 a T00-P13 concluidos; pronto para playtest alpha`
- Goal: montar o primeiro slice completo do DraxosMobile, iniciando pelo MVP tecnico minimo

---

## Escopo

Track 00 tem dois niveis:

1. **MVP tecnico minimo:** provar arquitetura Godot 4.6.2 + Supabase com guest, battle fixture server-authoritative e log animavel placeholder.
2. **Primeiro slice completo:** entregar PVP autobattler, base manager, social, ranking, bots, conta, economia, Battle Pass/Diamante, validacao e exports Android/PC/browser.

Detalhes em `scope.md` e `mvp-technical-definition.md`.

---

## Documentos Da Track

- `scope.md` - escopo, fora de escopo e criterios de aceite.
- `mvp-technical-definition.md` - primeira entrega implementavel.
- `implementation-plan.md` - sequencia completa T00-P00 a T00-P13.
- `implementation-prompts.md` - prompts atomicos para agentes.
- `../../../docs/reuse-map.md` - mapa de reuso conservador entre projetos.

---

## Status Dos Passos

| Passo | Status | Saida |
|---|---|---|
| T00-P00 - Preparacao Documental | Completo | Docs, contratos, design pending e prompts definidos |
| T00-P01 - Inicializacao Godot | Completo | `project.godot`, boot minimo, validate, GUT |
| T00-P02A - Supabase Base Standalone | Completo | migration MVP, healthcheck, Deno standalone verde |
| T00-P02B - Supabase Runtime Local | Completo | Docker Desktop local, Supabase CLI via `npx` 2.100.1, Deno via `npx` 2.7.14 |
| T00-P03 - Fundacao Reutilizavel Do Cliente | Completo | `.gutconfig`, autoloads, content generator, validate integrado |
| T00-P04 - Fixtures MVP E Catalogo Gerado | Completo | `data/definitions/*.json`, `mvp_training_battle`, catalogo `.tres` |
| T00-P05 - Conta Guest MVP | Completo | `account/guest`, `account/state`, convite `ALPHA-TEST`, RPC idempotente e estado inicial server-authoritative |
| T00-P06 - Cliente Account/Session Shell | Completo | HTTP client, `SessionStore`, token/cache local nao autoritativo e tela minima de conta |
| T00-P07 - Battle Request MVP | Completo | battle fixture server-authoritative, `battle_log_v1`, recompensa e idempotencia |
| T00-P08 - Battle Replay Client MVP | Completo | loop guest -> batalha -> resultado com replay placeholder e skip |
| T00-P09 - Gate De Design Do Primeiro Slice | Completo | DMOB-D001-D005 e D008-D028 resolvidos; economia/season baseline, simulador, base v0, missoes/onboarding v0, monetizacao/recompensas v0, social/ranking/chat v0 e combate real/simulador v0 criados |
| T00-P10 - Conteudo Real E Simulador Completo | Completo | conteudo real inicial, seeds de bots, simulador deterministico completo do slice, endpoint `FIRST_SLICE_SIM`, smoke runtime e replay rico |
| T00-P11 - Base Manager E Economia | Completo | estruturas permanentes, recursos, ledger, coleta offline, fila e cliente minimo |
| T00-P12 - Social, Matchmaking, Bots E Ranking | Completo | social/guilda/chat, matchmaking preview, bots fora do ranking e ranking de season |
| T00-P13 - Monetizacao Funcional E Alpha | Completo | Battle Pass, Diamante alpha, rewards diarias/semanais, claims free/premium e export smoke |

---

## Validacao Atual

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
```

Resultado local: passou com GUT integrado, `18/18` testes e `91` asserts.

Smoke client:

- Boot scene carrega em headless.
- Smoke P06 via Godot HTTPRequest: Auth anonimo -> `account/guest` -> `account/state` passou no Supabase local com player guest; fixture atual do rework usa build `varinha_cinzas`.
- Smoke P07: `battle/request` exige auth, retorna `battle_log_v1`, `battle/latest` recupera o log e repetir `request_id` nao duplica XP/Ossos.
- Smoke P08/P10: Godot solicita `FIRST_SLICE_SIM`, formata timeline rica, recupera `battle/latest` e nao calcula resultado/recompensa no cliente.
- Smoke P11: Godot possui fluxo minimo de Base; `base/state`, `base/collect` e `base/upgrade` vivem no servidor.
- Smoke P12: Godot possui fluxo minimo de Social/Matchmaking/Ranking; `social/*` e `competition/*` vivem no servidor.
- Smoke P13: Godot possui fluxo minimo de Loja alpha; `monetization/*` vive no servidor.
- `tools/smoke_exports.gd`: presets Android Alpha, PC Windows Alpha e PC Browser Alpha validados.

Server/Supabase local:

- `npx -y deno task check`: passou em `supabase/functions` e `server/functions`.
- `npx -y deno task lint`: passou em `supabase/functions` e `server/functions`.
- `npx -y deno test server/tests/first_slice_simulator_test.ts`: passou.
- `npx -y supabase db reset`: passou aplicando migrations ate `202605200005_monetization_rewards_alpha.sql`.
- `npx -y deno run --allow-net --allow-env server/tests/first_slice_battle_smoke.ts`: passou validando `FIRST_SLICE_SIM`, bots de variacao, idempotencia e recompensas.
- `npx -y deno run --allow-net --allow-env server/tests/base_manager_smoke.ts`: passou validando `base/state`, `base/collect` idempotente e erro controlado de upgrade sem Energia.
- `npx -y deno run --allow-net --allow-env server/tests/social_competition_smoke.ts`: passou validando guilda/chat idempotentes, matchmaking com bot fora do ranking, ranking proprio e bloqueio de insert direto em `guilds`.
- `npx -y deno run --allow-net --allow-env server/tests/monetization_rewards_smoke.ts`: passou validando Battle Pass, rewards, Diamante alpha, premium alpha, idempotencia e bloqueio de insert direto em `reward_claims`.
- `tools/smoke_battle_replay.gd`: passou com replay `FIRST_SLICE_SIM` de 30 eventos sem eventos desconhecidos.
- `GET /functions/v1/healthcheck`: passou.
- `POST /functions/v1/account/guest`: convite invalido retorna `INVALID_INVITE`; convite valido cria conta; repeticao do mesmo `request_id` retorna o mesmo player.
- `GET /functions/v1/account/state`: passou e recuperou player/resources/build.
- Insert direto em `public.players` com JWT anonimo: bloqueado com `403`.

---

## Next

1. Executar playtest alpha do primeiro slice.
2. Coletar feedback de UX/economia/estabilidade nos fluxos guest, batalha, base, social e monetizacao.
3. Calibrar recompensas com base em telemetria e simulador antes da proxima track.
