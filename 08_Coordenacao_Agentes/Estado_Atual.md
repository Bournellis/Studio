# Estado Atual - Estudio

- Ultima atualizacao: `2026-05-20`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Prioridade do Estudio

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao: `Projetos/draxos-mobile/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Projetos pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## draxos-roguelike-cardgame

- Status: **P0_IMPLEMENTACAO - ativo**
- Fase: `Implementacao`
- Track ativa: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline atual: Track 02 completa para playtest de usuario em Godot 4.6.2 com rota fixa de 29 mapas, recompensas/reliquias/loja expandida, keywords completas, AI/intent, modos e formatos de encontro, field effects, boss hooks, UI polida para mapa/batalha/recompensa/loja/tooltips, descarte marcado na fase principal, validacao verde 94/94, telemetria de rota completa e screenshots obrigatorias capturadas.
- Meta ativa: playtest manual da Track 02 completa e coleta de feedback de balanceamento.
- Trabalho permitido: codigo, validacao, playtest e documentacao local.
- Proximo passo: executar playtest de usuario da Track 02 completa.

## DraxosMobile

- Status: **P2_IMPLEMENTACAO - bootstrap**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Track 00 em bootstrap com T00-P01, T00-P02A, T00-P02B, T00-P03, T00-P04, T00-P05, T00-P06, T00-P07 e T00-P08 concluidos; T00-P09 em andamento. O cliente Godot 4.6.2 tem boot scene, `tools/validate.gd`, `tools/smoke_session_shell.gd`, `tools/smoke_battle_replay.gd`, GUT 9.6.0, autoloads `UiTokens`/`AssetIds`/`ContentLibrary`/`SessionStore`/`SupabaseClient`, `BattleLogPresenter`, pipeline `data/definitions/*.json` -> `data/generated/draxos_mobile_catalog.tres`, fixture `mvp_training_battle`, cliente HTTPRequest para Auth anonimo + `account/guest` + `account/state` + `battle/request` + `battle/latest`, cache local nao autoritativo, replay placeholder de `battle_log_v1` e testes client verdes (`14/14`, `52` asserts). Supabase runtime local esta configurado no layout oficial `supabase/` com Docker Desktop, Deno via `npx`, Auth anonimo, migrations MVP, healthcheck Edge Function, `account/guest`, `account/state`, `battle/request`, `battle/latest`, `supabase db reset` verde, idempotencia por `request_id`, escrita direta do cliente bloqueada, smoke Godot HTTPRequest de sessao/replay verde e smoke server de battle request verde. Design do primeiro slice ja definiu cap 40, levels permanentes, unlocks de spell/passiva/pet, matchmaking por poder, bots iniciais, telemetria minima, schema de build, UX alpha com Refugio e baseline calibravel de economia/simulador de seasons.
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo.
- Proximo passo: continuar `T00-P09 - Gate De Design Do Primeiro Slice`, usando o simulador de economia para calibrar base/economia, missoes/onboarding e monetizacao antes de implementar custos/recompensas reais.

## rpg-isometrico

- Status: **PAUSADO_INDEFINIDO**
- Fase: `Pausado`
- Baseline preservada: B0 interno com Arena / Survival / Boss jogaveis e frontend campaign-first.
- Ultima atualizacao do current-status: `2026-04-26`
- Trabalho permitido: consulta historica e leitura de contexto quando o usuario pedir explicitamente.
- Restricao operacional: nao implementar, expandir gates, selecionar Next Gate ou alterar escopo sem pedido explicito.
- Proximo passo: nenhum enquanto pausado.

## rpg-turnos

- Status: **PAUSADO_INDEFINIDO**
- Fase: `Pausado`
- Baseline preservada: slice Godot 4.6.2 jogavel com runtime C1, modos de batalha, 3 classes, 13 encontros, ranks de operacao e save/load JSON v2.
- Ultima atualizacao do current-status: `2026-05-13`
- Trabalho permitido: consulta historica e leitura de contexto quando o usuario pedir explicitamente.
- Restricao operacional: nao implementar, selecionar proxima track/gate, regenerar `.tres` ou alterar escopo sem pedido explicito.
- Proximo passo: nenhum enquanto pausado.

## Kanban rapido

- Backlog: `08_Coordenacao_Agentes/Kanban/Backlog/`
- Doing: `08_Coordenacao_Agentes/Kanban/Doing/`
- Review: `08_Coordenacao_Agentes/Kanban/Review/`
- Done: `08_Coordenacao_Agentes/Kanban/Done/`

## Canon

- Fonte de verdade compartilhada: `canon/`
- Brief rapido: `canon/canon-brief.md`
