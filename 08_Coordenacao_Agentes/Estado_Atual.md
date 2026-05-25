# Estado Atual - Estudio

- Ultima atualizacao: `2026-05-25`
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

- Status: **P2_IMPLEMENTACAO - progression lab tooling implemented**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Track 00 completa com T00-P01 a T00-P13 concluidos e Track 01 completa para hardening do alpha PC local. O cliente Godot 4.6.2 tem boot hub alpha com abas/telas rolaveis, Voltar/Esc, confirmacoes simples para mutacoes, busy states, erros offline/pre-condicoes visiveis, refresh de sessao, reset seguro de cache/sessao local, `session_id` local persistido, `tools/validate.gd`, `tools/smoke_session_shell.gd`, `tools/smoke_battle_replay.gd`, `tools/smoke_alpha_loop.gd`, `tools/smoke_exports.gd`, GUT 9.6.0, autoloads `UiTokens`/`AssetIds`/`ContentLibrary`/`SessionStore`/`SupabaseClient`, `BattleLogPresenter`, pipeline `data/definitions/*.json` -> `data/generated/draxos_mobile_catalog.tres`, conteudo real inicial, cliente HTTPRequest para Auth anonimo + `account/*` + `battle/*` + `base/*` + `social/*` + `competition/*` + `monetization/*` + `telemetry/*`, cache local nao autoritativo, replay rico de `battle_log_v1`, fluxos minimos de Base/Social/Competicao/Monetizacao e testes client verdes (`26/26`, `122` asserts). Supabase runtime local esta configurado no layout oficial `supabase/` com Docker Desktop, Deno via `npx`, Auth anonimo, migrations MVP/base/social/ranking/monetizacao, healthcheck Edge Function, `account/*`, `battle/*`, `base/*`, `social/*`, `competition/*`, `monetization/*`, `telemetry/client-event`, seeds de bots `FIRST_SLICE`, modo `FIRST_SLICE_SIM` server-authoritative completo, Base Manager v0, Social/Competicao v0, Monetizacao v0 com Battle Pass, Diamante alpha, rewards diarios/semanais, premium alpha, ledger/idempotencia, telemetria client nao autoritativa, escrita direta do cliente bloqueada e smokes verdes. Battle Lab offline implementado em `tools/battle_lab/` com relatorio HTML/CSV/JSON, runs oficiais em `docs/battle-lab/runs/`, comparacao de deltas, replays amostrados, bridge para Godot e tela dev-only no Refugio para gerar scratch runs, montar builds e assistir arena debug 2D fora dos exports; pacing alpha levou duracao media a `18.19s`, e tuning v02 por arquetipo/fonte deixou baseline em `18.91s`, curtas `0%`, longas `0%`, anti-stall `0.12%`, status `REVIEW` por `pet_handler` ainda em `70.45%` no poder proximo. Progression Lab v1 implementado em `tools/progression_lab/` com `25` saves saudaveis, `75` bots, relatorios, seeder local, cache `.progression_lab_scratch/`, tela dev-only no Refugio e matriz integrada ao Battle Lab. Design do primeiro slice ja definiu cap 40, levels permanentes, unlocks de spell/passiva/pet, base v0 implementavel, missoes/onboarding v0, monetizacao/recompensas v0, social/ranking/chat v0, combate real/simulador, matchmaking por poder, bots iniciais, telemetria minima, schema de build, UX alpha com Refugio e baseline calibravel de economia/simulador de seasons.
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo.
- Proximo passo: rodar Progression Lab com Supabase local, carregar saves `2h`-`20h` manualmente no Godot e usar Battle Lab/relatorios para rodada before/after de recompensa, poder e bots.

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
