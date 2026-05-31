# Estado Atual - Estudio

- Ultima atualizacao: `2026-05-31`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Prioridade Do Estudio

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao: `Projetos/draxos-mobile/` (`FOUNDATION_FINAL_POLISH_DELIVERED`; Track 13/Track 14 seguem baselines; `codex/draxos-mobile/rpgsuave-visual-upgrade-v1` publicou Rpgsuave Bosque Visual Upgrade v1 no Internal Alpha)
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Projetos pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## draxos-roguelike-cardgame

- Status: **P0_IMPLEMENTACAO - ativo**
- Fase: `Implementacao`
- Track ativa: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline atual: Track 02 completa para playtest de usuario em Godot 4.6.2 com rota fixa de 29 mapas, recompensas/reliquias/loja, keywords, AI/intent, modos, field effects, boss hooks, UI polida, validacao verde 94/94, telemetria de rota completa e screenshots obrigatorias capturadas.
- Meta ativa: playtest manual da Track 02 completa e coleta de feedback de balanceamento.
- Trabalho permitido: codigo, validacao, playtest e documentacao local.
- Proximo passo: executar playtest de usuario da Track 02 completa.

## DraxosMobile

- Status: **P2_IMPLEMENTACAO - FOUNDATION_FINAL_POLISH_DELIVERED + RPGSUAVE_VISUAL_UPGRADE_V1_PUBLISHED**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Track 00-15 integradas e Foundation Final Polish seguem como base de fundacao; Track 13 e Track 14 continuam como baselines de release safety e operacao de agentes. Rpgsuave Bosque + Minigame Platform v0 publicou o primeiro minigame real em Labs Dev com Edge Function `minigames`, schema `mode_*` e Reward Bridge v0 server-authoritative. A branch `codex/draxos-mobile/rpgsuave-visual-upgrade-v1` publicou o upgrade visual do Bosque com fullscreen mobile portrait, camera no personagem, joystick-only, HUD in-game, Mochila funcional e assets procedurais Godot. Release root atual: `internal-alpha/v0-rpgsuave-visual-upgrade-v1-20260531-809c4dc`; preview Web/Portal: `https://b5b7a32a.draxos-mobile-internal-alpha.pages.dev`.
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo. Secrets e service role nunca entram no cliente/export. Publicacao remota exige `-ConfirmRemoteMutation`; override do release manifest exige `SUPABASE_ACCESS_TOKEN`. Mudancas visuais em Entry/Refugio/Batalha exigem `foundation-responsive-layout-contract.md` + `smoke_responsive_layout.gd`. Novas features devem respeitar `account_profiles/game_saves`, ruleset registry, idempotencia v1 e RPC transacional v1 para mutations economicas/social. Direct chat, ajudas, contribuicoes, moderacao, tuning numerico, novas armas, novas spells, economia, visual final, previsao de vitoria, contra-escolha por oponente, thresholds customizados, comportamento por inimigo e controles avancados de replay ficam bloqueados ate decisao propria.
- Proximo passo: playtest humano do Rpgsuave Bosque Visual Upgrade v1 em mobile portrait; observar joystick, camera, leitura de recursos, HUD, Mochila, deposito, craft, progresso local vs recompensa real e estabilidade do fluxo Labs Dev.

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

## Kanban Rapido

- Backlog: `08_Coordenacao_Agentes/Kanban/Backlog/`
- Doing: `08_Coordenacao_Agentes/Kanban/Doing/`
- Review: `08_Coordenacao_Agentes/Kanban/Review/`
- Done: `08_Coordenacao_Agentes/Kanban/Done/`

## Canon

- Fonte de verdade compartilhada: `canon/`
- Brief rapido: `canon/canon-brief.md`
