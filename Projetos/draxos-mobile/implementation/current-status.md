# Current Status

- Last Updated: `2026-05-19`
- Active Project Name: `draxos-mobile`
- Active Surface: `Track 00 - First Slice Foundation`
- Active Track: `Track 00 - First Slice Foundation`
- Active Track Status: `OPEN`
- Current Operational Baseline: `T00-P01, T00-P02A, T00-P02B, T00-P03, T00-P04 e T00-P05 concluidos. Projeto Godot 4.6.2 tem boot scene, GUT 9.6.0, validate integrado, autoloads UiTokens/AssetIds/ContentLibrary, pipeline data/definitions -> data/generated/draxos_mobile_catalog.tres e fixtures MVP_ONLY. Supabase local esta configurado no layout oficial supabase/, db reset passa, healthcheck responde pelo gateway local e a conta guest MVP cria/recupera estado server-authoritative.`

---

## Estado Atual

| Area | Estado | Observacao |
|---|---|---|
| MVP tecnico minimo | Em andamento | Godot/client foundation, Supabase runtime e conta guest MVP prontos; falta cliente de sessao e battle request server-authoritative |
| Primeiro slice completo | Escopo definido | Inclui PVP autobattler, base manager, social, ranking, bots, economia, Battle Pass/Diamante |
| Design pendente | Registrado | Fonte viva: `../docs/design-pending.md` |
| Reuso entre projetos | Documentado | Fonte viva: `../docs/reuse-map.md`; estrategia conservadora |
| Contratos tecnicos | Definidos | Fonte inicial: `../docs/contracts/` |
| Godot project | Fundacao pronta | Boot minimo, autoloads, `.gutconfig.json`, content generator, catalogo gerado e GUT |
| Supabase project | Conta guest MVP pronta | Layout `supabase/`, migration MVP, Auth anonimo, healthcheck e `account/guest` + `account/state` configurados |
| Validacao | Verde para bootstrap + P05 | Godot validate + GUT passam; Deno check/lint passam; `supabase db reset` passa; healthcheck, conta guest, idempotencia e bloqueio de escrita direta passam no gateway local |

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
- Reuso de outros projetos e conservador: padroes e infraestrutura, nao gameplay.
- Tudo que exigir design ou tuning entra em `../docs/design-pending.md` antes de implementar.
- iOS e mobile browser ficam fora da Track 00.

---

## Baseline De Conceito Preservada

- Personagem: Draxos, sem classes, varinha magica, 0-3 spells, 1 passiva, 1 pet, summons.
- Combate: 7 tipos de dano, DoTs, resistencias, barreiras, status effects, anti-stall.
- Base Manager: 6 estruturas permanentes e Energia como gargalo.
- Social: amigos, guilda, ajudas, chat de guilda e direct.
- Infraestrutura: Godot 4.6.2, Supabase, batalha 100% servidor, Android + PC + PC browser.
- Season: 4 meses, 2 Battle Passes, cap Season 1 = 40.

---

## Implementacao Atual

- `project.godot` registra `UiTokens`, `AssetIds` e `ContentLibrary`.
- `data/definitions/` contem os 9 arquivos esperados pelo contrato.
- `tools/content_generator.gd` gera `data/generated/draxos_mobile_catalog.tres`.
- `tools/validate.gd` gera conteudo, valida contrato client, valida recursos/autoloads e roda GUT.
- `tests/client/` cobre `ProjectInfo`, autoloads, tokens, asset ids, catalogo gerado e fixture `mvp_training_battle`.
- `supabase/migrations/202605190001_mvp_foundation.sql` e `supabase/functions/healthcheck/` sao a fonte de execucao local da Supabase CLI.
- `supabase/migrations/202605190002_guest_account_mvp.sql` cria convite `ALPHA-TEST`, RPC `create_guest_account` e fixture inicial de `players/resources/builds`.
- `supabase/functions/account/` implementa `POST /account/guest` e `GET /account/state` com JWT anonimo, service role interno e idempotencia por `request_id`.
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
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
```

Ultimo resultado local:

- `tools/validate.gd`: passou.
- GUT integrado: `8/8` testes, `33` asserts.

Server standalone:

```powershell
cd D:\Estudio\Projetos\draxos-mobile\server\functions
npx -y deno task check
npx -y deno task lint
npx -y deno run --allow-net healthcheck/index.ts
```

Supabase runtime validado localmente:

- Docker Desktop local ativo.
- Supabase CLI via `npx -y supabase`, versao `2.100.1`.
- Deno via `npx -y deno`, versao `2.7.14`.
- `supabase db reset`: passou.
- `GET http://127.0.0.1:54321/functions/v1/healthcheck`: passou.
- `POST http://127.0.0.1:54321/functions/v1/account/guest`: convite invalido falha, convite valido cria conta guest e repeticao do mesmo `request_id` retorna o mesmo player.
- `GET http://127.0.0.1:54321/functions/v1/account/state`: recupera player/resources/build.
- Insert direto em `public.players` com JWT anonimo: bloqueado com `403`.

---

## Next

1. Implementar `T00-P06 - Cliente Account/Session Shell`.
2. Criar HTTP client Godot para Auth anonimo, `account/guest` e `account/state`.
3. Adicionar `SessionStore` como cache local nao autoritativo, sem mutar recursos/progressao.
