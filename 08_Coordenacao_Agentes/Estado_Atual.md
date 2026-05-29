# Estado Atual - Estudio

- Ultima atualizacao: `2026-05-29`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Prioridade Do Estudio

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao: `Projetos/draxos-mobile/` (`VISUAL_DIRECTION_V1_IMPLEMENTED`, sobre Social Guilda v1 publicado, Foundation baseline confirmada, Track 13 release safety, Track 14 agent ops, Track 15 UX e ultimo pacote tecnico Track 16)
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

- Status: **P2_IMPLEMENTACAO - VISUAL_DIRECTION_V1_IMPLEMENTED**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Track 00-15 integradas. O projeto tem uma base implementada para refinamento: primeiro slice server-authoritative, Refugio/Base, batalha, recompensa, social/competicao/loja em substancia de prototipo, Supabase remoto, manifest/version gate e builds Internal Alpha site/Web/APK/Windows republicadas em 2026-05-29 com Social Basico Guilda v1. Track 16 e o ultimo pacote tecnico de comportamento, Po de Osso e crafting inicial, mas nao e a etapa ativa de produto. Conteudo atual de armas, spells, economia, tema, visual e apresentacao existe para nao parecer app vazio e deve ser tratado como mock/substancia. A auditoria do loop esta registrada em `Projetos/draxos-mobile/docs/foundation-loop-audit.md`; Foundation Loop UX Pass 01 esta implementado, publicado e confirmado em revisao manual Android/Windows/Web em 2026-05-29. Social Basico Guilda v1 esta publicado: tela Social mais clara, username proprio copiavel, secoes Amigos/Guilda/Chat e auto-sync leve de 8s no chat de guilda sem backend/schema novo. Visual Direction v1 esta implementado localmente: acentos por superficie/acao, CTAs e paineis passam por `core/ui_tokens.gd` e `docs/visual-direction-v1.md`, sem publicacao remota nesta etapa.
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo. Secrets e service role nunca entram no cliente/export. Publicacao remota exige `-ConfirmRemoteMutation`. Mudancas visuais em Entry/Refugio/Batalha exigem `foundation-responsive-layout-contract.md` + `smoke_responsive_layout.gd`. Direct chat, ajudas, contribuicoes, moderacao, migration conta/save, tuning numerico, armas, spells, economia, visual final e apresentacao de batalha ficam bloqueados ate decisao propria.
- Proximo passo: revisar Visual Direction v1 em Android/Windows/Web e decidir publicacao ou Battle Presentation v1.

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
