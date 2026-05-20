# Track 00 - Implementation Plan

- Ultima atualizacao: `2026-05-20`
- Status: rebaselineado apos bootstrap Godot/Supabase e fundacao reutilizavel do cliente

## Sequencia Reorganizada

### T00-P00 - Preparacao Documental

Status: **Completo**.

Criar escopo, MVP tecnico, contratos, pendencias de design e prompts atomicos.

Aceite: `../../../docs/design-pending.md`, `../../../docs/contracts/`, `scope.md`, `mvp-technical-definition.md`, `implementation-plan.md` e `implementation-prompts.md` existem e estao linkados pelo status.

### T00-P01 - Inicializacao Godot

Status: **Completo**.

Inicializar Godot 4.6.2, boot scene minima, `ProjectInfo`, `tools/validate.gd`, GUT 9.6.0 e teste client inicial.

Aceite: Godot headless abre o projeto, `tools/validate.gd` roda e GUT executa a suite client.

### T00-P02A - Supabase Base Standalone

Status: **Completo**.

Criar migration MVP, tabelas iniciais, RLS base, seed tecnico, Edge Function `healthcheck`, `.env.example` e checks Deno standalone.

Aceite: Deno check/lint passam e `healthcheck` responde fora do runtime Supabase via `npx deno`.

### T00-P02B - Supabase Runtime Local

Status: **Completo**.

Resolver layout oficial Supabase CLI, Docker, Supabase CLI via `npx`, Deno via `npx` e validacao real de `supabase db reset` e Edge Functions no gateway local.

Aceite: migration aplica em banco limpo, healthcheck responde no runtime Supabase e docs de ambiente refletem o fluxo real.

### T00-P03 - Fundacao Reutilizavel Do Cliente

Status: **Completo**.

Adotar reuso conservador dos outros projetos Godot: `.gutconfig.json`, autoloads `UiTokens`, `AssetIds`, `ContentLibrary`, gerador de conteudo e validacao integrada.

Aceite: `project.godot` registra autoloads, `tools/validate.gd` gera catalogo, valida contrato, valida recursos e roda GUT.

### T00-P04 - Fixtures MVP E Catalogo Gerado

Status: **Completo**.

Criar `data/definitions/*.json` para todos os arquivos esperados, fixture `mvp_training_battle`, bot `mvp_training_bot` e `data/generated/draxos_mobile_catalog.tres`.

Aceite: catalogo gerado carrega no Godot, IDs sao unicos, referencias cruzadas basicas existem e testes GUT cobrem o contrato MVP_ONLY.

### T00-P05 - Conta Guest MVP

Status: **Completo**.

Implementar criacao de conta guest server-authoritative, convite alpha, estado inicial de player/resources/build, `account/state` e idempotencia por `request_id`.

Aceite: convite valido cria conta e estado inicial; convite invalido falha sem criar player; repetir o mesmo `request_id` retorna a mesma resposta; cliente nao possui policy de escrita direta para estado autoritativo.

### T00-P06 - Cliente Account/Session Shell

Status: **Completo**.

Adicionar HTTP client, `SessionStore`, validacao de token e tela minima para entrar, recuperar estado e lidar com erro controlado.

Aceite: fluxo Auth anonimo -> `account/guest` -> `account/state` funciona em ambiente local; cache nao altera recurso autoritativo.

### T00-P07 - Battle Request MVP

Status: **Completo**.

Implementar `battle/request` com bot fixture, seed deterministica, log `battle_log_v1`, gravacao de resultado e recompensa `MVP_ONLY`.

Aceite: teste server cobre sucesso, auth ausente, replay deterministico e idempotencia.

### T00-P08 - Battle Replay Client MVP

Status: **Completo**.

Conectar Godot ao endpoint de batalha e exibir timeline placeholder ordenada por `t`.

Aceite: cliente envia intencao, recebe `battle_log`, anima/exibe resultado e nunca calcula vencedor/recompensa.

### T00-P09 - Gate De Design Do Primeiro Slice

Status: **Completo**.

Resolver ou adiar explicitamente pendencias que bloqueiam conteudo real: level cap, unlocks, build schema, matchmaking, bots, recompensas, UX base, economia de seasons e telemetria.

Aceite: `docs/design-pending.md` nao possui pendencia `PRIMEIRO_SLICE` que bloqueie a proxima implementacao sem decisao registrada; economia usa `docs/economy/README.md` e `tools/economy_simulator/` como baseline calibravel antes de custos/recompensas reais.

### T00-P10 - Conteudo Real E Simulador Completo

Status: **Em andamento - v0 executavel**.

Expandir JSONs e implementar simulador server-authoritative com varinha, spells, DoTs, barreiras, status, pets, passivas, summons e anti-stall.

Progresso v0: conteudo real inicial versionado em `data/definitions/`, seeds de bots `FIRST_SLICE`, simulador TypeScript deterministico espelhado em `server/functions/_shared/` e `supabase/functions/_shared/`, `battle/request` aceita `FIRST_SLICE_SIM`, aplica recompensas de XP/Almas/Energia/Sangue/Ossos e preserva idempotencia por `request_id`.

Aceite: servidor gera replay deterministico por seed e eventos conforme `battle-event-log.md`.

### T00-P11 - Base Manager E Economia

Status: **Pendente**.

Implementar estruturas, upgrades, coleta offline, recursos, armazenamento, cotas e recompensas.

Aceite: servidor valida caps/custos e mutacoes economicas sao idempotentes com ledger.

### T00-P12 - Social, Matchmaking, Bots E Ranking

Status: **Pendente**.

Implementar amigos, guilda, ajudas, chat por polling, matchmaking real/bot e ranking de season.

Aceite: RLS impede acesso indevido; bots nao entram em ranking.

### T00-P13 - Monetizacao Funcional E Alpha

Status: **Pendente**.

Implementar Battle Pass, Diamante, recompensas diarias/semanais, fluxos alpha e smoke de export Android, PC e PC browser.

Aceite: exports passam smoke e status muda para pronto para playtest alpha.

## Regra De Avanco

- Cada passo concluido atualiza `../../current-status.md` e este `current-status.md`.
- Mudanca de contrato atualiza `../../../docs/contracts/`.
- Toda pendencia nova vai para `../../../docs/design-pending.md` antes de implementar a regra.
- Reuso de outros projetos deve seguir `../../../docs/reuse-map.md`.
- Cliente Godot nunca simula resultado autoritativo nem muta recursos finais.
