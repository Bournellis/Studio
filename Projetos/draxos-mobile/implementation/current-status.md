# Current Status

- Last Updated: `2026-05-20`
- Active Project Name: `draxos-mobile`
- Active Surface: `Track 00 - First Slice Foundation`
- Active Track: `Track 00 - First Slice Foundation`
- Active Track Status: `OPEN`
- Current Operational Baseline: `T00-P01 a T00-P10 concluidos; pronto para T00-P11. Projeto Godot 4.6.2 tem boot scene, GUT 9.6.0, validate integrado, autoloads UiTokens/AssetIds/ContentLibrary/SessionStore/SupabaseClient, pipeline data/definitions -> data/generated/draxos_mobile_catalog.tres, conteudo real inicial, cliente de sessao guest via HTTPRequest e replay rico de battle_log_v1. Supabase local esta configurado no layout oficial supabase/, db reset passa, healthcheck responde pelo gateway local, conta guest MVP cria/recupera estado server-authoritative, battle/request server-authoritative grava log/recompensa idempotente, Godot consome o log sem calcular resultado e FIRST_SLICE_SIM gera replay deterministico com varinha, mana, spells diretas, DoTs, status, resistencias, passivas, barreira, pet, summons, cooldowns, anti-stall e recompensa XP/Almas/Energia/Sangue/Ossos. Design do primeiro slice ja definiu cap 40, levels permanentes, unlocks de slots/pet/passiva, base v0 implementavel, missoes/onboarding v0, monetizacao/recompensas v0, social/ranking/chat v0, combate real/simulador, matchmaking por poder, bots iniciais, telemetria minima, schema de build, UX alpha com Refugio e baseline calibravel de economia/simulador de seasons.`

---

## Estado Atual

| Area | Estado | Observacao |
|---|---|---|
| MVP tecnico minimo | Completo | Loop guest -> battle/request -> replay placeholder -> latest/state validado; cliente nao calcula resultado, recompensa ou progressao |
| Primeiro slice completo | Em implementacao | T00-P10 completo; proximo bloco implementavel e T00-P11 Base Manager/Economia |
| Design pendente | T00-P09 completo | DMOB-D001-D005, D008-D028 resolvidos; nao ha pendencia `PRIMEIRO_SLICE` bloqueando T00-P10. D006-D007 e D029-D032 seguem calibraveis via simulador/playtest |
| Economia e seasons | Baseline calibravel | `../docs/economy/README.md`, JSON versionado e gerador Deno/TypeScript criados; outputs em `../docs/economy/generated/` |
| Reuso entre projetos | Documentado | Fonte viva: `../docs/reuse-map.md`; estrategia conservadora |
| Contratos tecnicos | Definidos | Fonte inicial: `../docs/contracts/` |
| Godot project | MVP tecnico pronto | Boot minimo, autoloads, `.gutconfig.json`, content generator, catalogo gerado, `SessionStore`, `SupabaseClient`, `BattleLogPresenter` e GUT |
| Supabase project | Conta guest + battle MVP + first-slice sim prontos | Layout `supabase/`, migrations MVP, Auth anonimo, healthcheck, `account/*`, `battle/*`, seeds `FIRST_SLICE`, JWT config de `battle` e simulador compartilhado configurados |
| Validacao | Verde para bootstrap + P10 completo | Godot validate + GUT passam; Deno check/lint passam; teste deterministico do simulador passa; Supabase `db reset`, MVP smoke, FIRST_SLICE smoke e replay smoke passam |

---

## Fontes Vivas

- Escopo Track 00: `tracks/track-00-first-slice-foundation/scope.md`
- MVP tecnico: `tracks/track-00-first-slice-foundation/mvp-technical-definition.md`
- Plano sequencial: `tracks/track-00-first-slice-foundation/implementation-plan.md`
- Prompts atomicos: `tracks/track-00-first-slice-foundation/implementation-prompts.md`
- Mapa de reuso: `../docs/reuse-map.md`
- Pendencias de design: `../docs/design-pending.md`
- Contratos: `../docs/contracts/`
- Design autoritativo: `../docs/game-design-document.md`
- Decision log historico: `../docs/pre-implementation-decisions.md`

---

## Decisoes De Escopo

- Track 00 monta o primeiro slice completo.
- MVP tecnico minimo e a primeira etapa da Track 00.
- MVP tecnico usa fixtures `MVP_ONLY` e nao depende de balanceamento final.
- Economia de Season 1 usa cap 40 por padrao, todos os levels sao permanentes e caps futuros ficam editaveis no simulador.
- Reuso de outros projetos e conservador: padroes e infraestrutura, nao gameplay.
- Tudo que exigir design ou tuning entra em `../docs/design-pending.md` antes de implementar.
- iOS e mobile browser ficam fora da Track 00.

---

## Baseline De Conceito Preservada

- Personagem: Draxos, sem classes, varinha magica, 0-3 spells por unlock de level, 1 passiva, 1 pet, summons.
- Combate: 7 tipos de dano, DoTs, resistencias, barreiras, status effects, anti-stall.
- Base Manager: 6 estruturas permanentes e Energia como gargalo.
- Social: amigos, guilda, ajudas, chat de guilda e direct.
- Infraestrutura: Godot 4.6.2, Supabase, batalha 100% servidor, Android + PC + PC browser.
- Season: 4 meses, 2 Battle Passes, cap Season 1 = 40, progressao permanente e catch-up suave futuro.

---

## Implementacao Atual

- `project.godot` registra `UiTokens`, `AssetIds`, `ContentLibrary`, `SessionStore` e `SupabaseClient`.
- `data/definitions/` contem os 9 arquivos esperados pelo contrato com conteudo inicial de primeiro slice.
- `tools/content_generator.gd` gera `data/generated/draxos_mobile_catalog.tres`.
- `tools/validate.gd` gera conteudo, valida contrato client, valida recursos/autoloads e roda GUT.
- `online/session_store.gd` guarda token/cache local nao autoritativo, valida expiracao e preserva snapshots de estado recebido do servidor.
- `online/supabase_client.gd` implementa HTTPRequest para Auth anonimo, `account/guest`, `account/state`, `battle/request` e `battle/latest` no Supabase local.
- `ui/battle_log_presenter.gd` ordena e formata eventos `battle_log_v1`, tolerando tipos desconhecidos sem quebrar replay.
- `modes/boot/boot.gd` conecta `Entrar como guest`, `Solicitar batalha` e `Ver resultado` ao fluxo real, com replay simples e skip.
- `tests/client/` cobre `ProjectInfo`, autoloads, tokens, asset ids, catalogo gerado, fixture `mvp_training_battle`, session shell e presenter de replay.
- `supabase/migrations/202605190001_mvp_foundation.sql` e `supabase/functions/healthcheck/` sao a fonte de execucao local da Supabase CLI.
- `supabase/migrations/202605190002_guest_account_mvp.sql` cria convite `ALPHA-TEST`, RPC `create_guest_account` e fixture inicial de `players/resources/builds`.
- `supabase/migrations/202605200001_battle_request_mvp.sql` cria RPC `request_mvp_battle`, aplica recompensa `MVP_ONLY` e grava `battle_log_v1`.
- `supabase/migrations/202605200002_first_slice_simulator_seed.sql` cria seeds de bots `FIRST_SLICE` para matchmaking/simulacao.
- `supabase/functions/account/` implementa `POST /account/guest` e `GET /account/state` com JWT anonimo, service role interno e idempotencia por `request_id`.
- `supabase/functions/battle/` implementa `POST /battle/request` e `GET /battle/latest` com JWT anonimo, service role interno, idempotencia por `request_id`, modo `MVP_ONLY` via RPC e modo `FIRST_SLICE_SIM` via simulador TypeScript.
- `supabase/functions/_shared/battle_simulator.ts` e `server/functions/_shared/battle_simulator.ts` simulam batalha com varinha, mana, spells diretas, DoTs, status, resistencias, passivas, barreira, pet, summons, cooldowns, anti-stall e recompensa server-authoritative.
- `server/schema/` e `server/functions/` preservam a organizacao backend espelhada/documental durante o bootstrap.

---

## Read Next

1. `../AGENTS.md`
2. `tracks/track-00-first-slice-foundation/current-status.md`
3. `tracks/track-00-first-slice-foundation/implementation-prompts.md`
4. `../docs/reuse-map.md`
5. `../docs/design-pending.md`
6. `../docs/contracts/`

---

## Validation

Godot client:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_session_shell.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_battle_replay.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
```

Ultimo resultado local:

- `tools/validate.gd`: passou.
- GUT integrado: `15/15` testes, `61` asserts.
- `npx -y deno test server/tests/first_slice_simulator_test.ts`: passou.

Server standalone:

```powershell
cd D:\Estudio\Projetos\draxos-mobile\server\functions
npx -y deno task check
npx -y deno task lint
npx -y deno run --allow-net healthcheck/index.ts
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno test server/tests/first_slice_simulator_test.ts
npx -y deno run --allow-net --allow-env server/tests/battle_request_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/first_slice_battle_smoke.ts
```

Supabase runtime validado localmente:

- Docker Desktop local ativo.
- Supabase CLI via `npx -y supabase`, versao `2.100.1`.
- Deno via `npx -y deno`, versao `2.7.14`.
- `supabase db reset`: passou.
- `GET http://127.0.0.1:54321/functions/v1/healthcheck`: passou.
- `POST http://127.0.0.1:54321/functions/v1/account/guest`: convite invalido falha, convite valido cria conta guest e repeticao do mesmo `request_id` retorna o mesmo player.
- `GET http://127.0.0.1:54321/functions/v1/account/state`: recupera player/resources/build.
- Smoke P06 via Godot HTTPRequest: Auth anonimo -> `account/guest` -> `account/state` retornou player guest e build `varinha_magica`.
- `POST http://127.0.0.1:54321/functions/v1/battle/request`: retorna `battle_log_v1`, grava `battles` e aplica recompensa `MVP_ONLY`.
- Repetir `battle/request` com o mesmo `request_id`: retorna o mesmo `battle_id`; estado permanece `xp=5`, `ossos=1`.
- `GET http://127.0.0.1:54321/functions/v1/battle/latest`: retorna o ultimo `battle_log_v1`.
- Smoke P08/P10 via Godot HTTPRequest: guest -> `battle/request` `FIRST_SLICE_SIM` -> replay rico formatado -> `battle/latest` passou com 30 eventos e sem calculo client-side.
- Insert direto em `public.players` com JWT anonimo: bloqueado com `403`.

---

## Next

1. Iniciar `T00-P11 - Base Manager E Economia`.
2. Criar migrations/tabelas para estruturas permanentes, upgrades, coleta offline e ledger.
3. Implementar endpoints idempotentes para upgrade/coleta.
4. Conectar tela/fluxo minimo de Base no Godot sem mutacao local de recursos.
