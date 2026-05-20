# Track 00 - First Slice Foundation

- Last Updated: `2026-05-20`
- Track Status: `OPEN - T00-P01 a T00-P09 concluidos; T00-P10 em andamento com v0 executavel`
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
| T00-P10 - Conteudo Real E Simulador Completo | Em andamento | conteudo real inicial, seeds de bots, simulador deterministic v0 e endpoint `FIRST_SLICE_SIM` |
| T00-P11 - Base Manager E Economia | Pendente | estruturas, recursos, ledger e coleta offline |
| T00-P12 - Social, Matchmaking, Bots E Ranking | Pendente | amigos, guilda, bots, matchmaking e ranking |
| T00-P13 - Monetizacao Funcional E Alpha | Pendente | battle pass, diamante, rewards e exports smoke |

---

## Validacao Atual

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
```

Resultado local: passou com GUT integrado, `14/14` testes e `52` asserts.

Smoke client:

- Boot scene carrega em headless.
- Smoke P06 via Godot HTTPRequest: Auth anonimo -> `account/guest` -> `account/state` passou no Supabase local com player guest e build `varinha_magica`.
- Smoke P07: `battle/request` exige auth, retorna `battle_log_v1`, `battle/latest` recupera o log e repetir `request_id` nao duplica XP/Ossos.
- Smoke P08: Godot solicita batalha, formata timeline placeholder, recupera `battle/latest` e nao calcula resultado/recompensa no cliente.

Server/Supabase local:

- `npx -y deno task check`: passou em `supabase/functions` e `server/functions`.
- `npx -y deno task lint`: passou em `supabase/functions` e `server/functions`.
- `npx -y deno test server/tests/first_slice_simulator_test.ts`: passou.
- Ultimo `npx -y supabase db reset` registrado: passou ate as migrations MVP; a migration `202605200002_first_slice_simulator_seed.sql` ainda precisa de reset/smoke runtime para validacao integrada.
- `GET /functions/v1/healthcheck`: passou.
- `POST /functions/v1/account/guest`: convite invalido retorna `INVALID_INVITE`; convite valido cria conta; repeticao do mesmo `request_id` retorna o mesmo player.
- `GET /functions/v1/account/state`: passou e recuperou player/resources/build.
- Insert direto em `public.players` com JWT anonimo: bloqueado com `403`.

---

## Next

1. Continuar `T00-P10 - Conteudo Real E Simulador Completo`.
2. Adicionar DoTs, status/resistencias e passivas funcionais ao simulador.
3. Rodar smoke local do endpoint `FIRST_SLICE_SIM` no Supabase runtime e validar idempotencia/recompensas.
4. Atualizar replay visual do cliente para tratar eventos ricos alem do placeholder.
