# Estado Atual - Estudio

- Ultima atualizacao: `2026-05-30`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Prioridade Do Estudio

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao: `Projetos/draxos-mobile/` (`FOUNDATION_EXPANSION_READINESS_ACTIVE`, sobre First Session Clarity v1 aprovado, Progression Clarity v1, Battle Preparation Complete v1, Battle Preparation v1, Battle Drama v1.1, Battle Presentation v1, Ossos Inteiros v1 publicado, Visual Direction v1, Social Guilda v1 publicado, Foundation baseline confirmada, Track 13 release safety, Track 14 agent ops, Track 15 UX e Track 16 tecnico)
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

- Status: **P2_IMPLEMENTACAO - FOUNDATION_EXPANSION_READINESS_ACTIVE**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Track 00-15 integradas. O projeto tem uma base implementada para refinamento: primeiro slice server-authoritative, Refugio/Base, batalha, recompensa, social/competicao/loja em substancia de prototipo, Supabase remoto, manifest/version gate e builds Internal Alpha site/Web/APK/Windows republicadas em 2026-05-30 com Social Basico Guilda v1, Visual Direction v1, Ossos Inteiros v1, Battle Presentation v1, Battle Drama v1.1, Battle Preparation v1, Battle Preparation Complete v1, Progression Clarity v1 e First Session Clarity v1. Track 16 e o ultimo pacote tecnico de comportamento, Po de Osso e crafting inicial; Ossos Inteiros v1 promoveu o subconjunto necessario para alinhar migration/funcoes/catalogo/build publicado e parar de expor `0.1 osso`. Battle Presentation v1 esta publicado como pacote client-only de estrutura do loop; Battle Drama v1.1 e o follow-up visual publicado que deixa o Web perceptivelmente diferente, com palco mais dramatico, combatentes procedurais maiores, menos marcador vazio/debug e callout de lance mais forte. Battle Preparation Complete v1 edita loadout real de instrumento ritual, habilidades, doutrina, familiar, pocao e comportamento simples no Refugio. Progression Clarity v1 explica Nivel, Poder, XP de batalha e proximos marcos usando dados existentes. First Session Clarity v1 foi aprovado manualmente em 2026-05-30: Refugio, Preparacao e Resultado agora orientam a primeira sessao como Refugio -> coleta -> evolucao -> preparacao -> batalha -> recompensa -> voltar para base, sem novo backend/schema/tuning/conteudo. Conteudo atual de armas, spells, economia, tema e visual final continua mock/substancia. Foundation Expansion Readiness ja promoveu `account_profiles/game_saves`, ruleset registry, idempotencia v1 e RPCs transacionais para Base, battle rewards, reward claim/alpha purchase, build/crafting e guild create/join em contrato/migrations/adapters locais; `transactional_rpc_live_test.ts` passou contra Supabase local resetado provando rollback/retry/idempotencia das RPCs v1 e `transactional_edge_rpc_smoke.ts` passou pelo caminho HTTP local das Edge Functions sobre adapters RPC v1. A auditoria do loop esta registrada em `Projetos/draxos-mobile/docs/foundation-loop-audit.md`; Foundation Loop UX Pass 01 esta implementado, publicado e confirmado em revisao manual Android/Windows/Web em 2026-05-29. Social Basico Guilda v1 esta publicado: tela Social mais clara, username proprio copiavel, secoes Amigos/Guilda/Chat e auto-sync leve de 8s no chat de guilda sem backend/schema novo. Visual Direction v1 esta publicado: acentos por superficie/acao, CTAs e paineis passam por `core/ui_tokens.gd`; Web usa asset root versionado para evitar cache de navegador.
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo. Secrets e service role nunca entram no cliente/export. Publicacao remota exige `-ConfirmRemoteMutation`; override do release manifest exige `SUPABASE_ACCESS_TOKEN`. Mudancas visuais em Entry/Refugio/Batalha exigem `foundation-responsive-layout-contract.md` + `smoke_responsive_layout.gd`. Novas features devem respeitar `account_profiles/game_saves`, ruleset registry, idempotencia v1 e RPC transacional v1 para mutations economicas/social. Direct chat, ajudas, contribuicoes, moderacao, tuning numerico, novas armas, novas spells, economia, visual final, previsao de vitoria, contra-escolha por oponente, thresholds customizados, comportamento por inimigo e controles avancados de replay ficam bloqueados ate decisao propria.
- Proximo passo: continuar split de servicos de dominio portaveis; depois escolher explicitamente o pacote de base builder, autobattler, social ou minigame.

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
