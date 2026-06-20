# Estado Atual - Estudio

- Ultima atualizacao: `2026-06-20`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- Regra de tamanho: maximo ~12 linhas por projeto. Historia de pacotes/validacoes vai para os arquivos de historico do projeto (`implementation/tracks/`, `docs/release-history.md`, Kanban Done), nunca para este snapshot.

## Prioridade Do Estudio

- Foco operacional ativo: `Projetos/JogoDaCopa/` (10A publicada, aguardando reteste humano; 09S fallback aprovado) + `Projetos/draxos-mobile/` (Arena Runtime Config Sync Ready v3 publicado Web/APK/PC; aguardando prova humana) + `Projetos/FpsPlayground/` (Track 14G mergeada localmente; movimento atual preservado)
- Pausados temporariamente (poucos dias): `Projetos/draxos-roguelike-cardgame/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## JogoDaCopa

- Status: `P2_IMPLEMENTACAO - TRACK10A_PUBLISHED_PENDING_HUMAN`
- Marker: `JOGO_DA_COPA_TRACK10A_PUBLISHED_PENDING_HUMAN`
- Publicacao atual: `Super Campeao v1.2.1+fc3c72bb` (`web/v1-copa-arena-futebol-20260620-fc3c72bb`) em `https://copa-arena-futebol.pages.dev/`; remote menu/first-minute/stability/luma PASS (`js_heap_growth +8.34%`), reteste humano pendente.
- Baseline publico aprovado: Track 09S `Super Campeao v1.2.1+925f3b9f`; gates remotos 09S PASS e reteste humano aprovado.
- Fallback aprovado: Track 09Q `Super Campeao v1.2.1+bb604c77`; remote menu/first-minute/stability/luma PASS (`js_heap_growth +8.41%`) e aprovada por Fabio/tester.
- Trabalho permitido: codigo, design, validacao, playtest no editor e documentacao local.
- Proximo passo: Fabio/tester retestar a 10A publicada; aprovar como baseline ou decidir rollback/fix usando 09S como fallback aprovado.

## draxos-roguelike-cardgame

- Status: `PAUSADO_TEMPORARIO - retomada prevista em poucos dias`
- Track ativa preservada: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline: Track 02 completa em Godot 4.6.2 (rota de 29 mapas, save v5, keywords, AI/intent, labs Card Impact V5 e Design Lab V1, `validate.gd` 220/220). Detalhes em `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`.
- Meta preservada: expansao de conteudo via Design Lab antes de playtests completos de sensacao.
- Trabalho permitido: consulta historica; retomada apenas com pedido explicito.
- Proximo passo: retomar quando o foco temporario do JogoDaCopa encerrar.

## DraxosMobile

- Status: `P2_IMPLEMENTACAO` - Arena runtime_config recovery v3 publicado Web/APK/PC em 2026-06-16; aguardando prova humana
- Marker: `ARENA_RUNTIME_CONFIG_SYNC_READY_V3_PUBLISHED_INTERNAL_ALPHA`
- Pacote publicado: `Arena Runtime Config Sync Ready v3`, Web/APK/PC `0.0.27-alpha.0` / vc `27`, preview `https://a50d282b.draxos-mobile-internal-alpha.pages.dev`. Historico: `Projetos/draxos-mobile/docs/release-history.md`.
- Programa de hardening: runtime_config Web repinta rota ao sair de fallback; smoke remoto obrigatorio de runtime_config passou antes do reteste.
- Resultado de produto Arena PVE: `ARENA_CORE_NEEDS_UX_FIX` + `ARENA_CORE_NOT_PROVEN`; decisao em `08_Coordenacao_Agentes/Decisoes/2026-06-14_draxos-mobile_arena-core-ux-fix-not-proven.md`.
- Guardrails preservados: Track 13 release safety, Track 14 agent ops; fundacao server-authoritative/idempotencia/RLS NAO deve ser refatorada.
- Restricao operacional: ver `Projetos/draxos-mobile/AGENTS.md` (Hard Stops); secrets nunca no cliente; publicacao remota exige `-ConfirmRemoteMutation`; sem tuning numerico/PVP/economia/visual final sem decisao.
- Proximo passo: Fabio/tester executar a prova humana do pacote v3 seguindo `docs/arena-pve-product-proof.md`; registrar veredito antes de tuning, economia, PVP, conteudo novo, visual final ou expansao Openworld.

## FpsPlayground

- Status: `P2_IMPLEMENTACAO - TRACK14G_MERGED_LOCAL_BASELINE`
- Marker: `FPS_PLAYGROUND_TRACK14G_MERGED_LOCAL_BASELINE`
- Baseline: Track 14G mergeada localmente; adicionou boundaries de bot movement executor, projectile runtime, HUD feedback state e telemetry event facade; sem alteracao de gameplay.
- Guardrail recente: Track 08 movement feel descartada antes de merge; movimento atual, jump pads, mapas e bot route-control preservados.
- Validacao: `tools/validate.gd` quick/full PASS `66/66`, `593 asserts`; `tools/check_doc_drift.ps1` PASS; warnings GUT UID/text-path conhecidos.
- Trabalho permitido: codigo, design, validacao, playtest no editor e documentacao local.
- Proximo passo: executar `Multi-Arena Balance Baseline V1` antes de novas armas, buffs, mapas, tuning ou bot intelligence.

## rpg-isometrico

- Status: `PAUSADO_INDEFINIDO` (current-status de `2026-04-26`)
- Baseline preservada: B0 interno com Arena / Survival / Boss jogaveis e frontend campaign-first.
- Trabalho permitido: consulta historica com pedido explicito; nao implementar nem expandir escopo.

## rpg-turnos

- Status: `PAUSADO_INDEFINIDO` (current-status de `2026-05-13`)
- Baseline preservada: slice Godot 4.6.2 jogavel com runtime C1, modos de batalha, 3 classes, 13 encontros e save/load JSON v2.
- Trabalho permitido: consulta historica com pedido explicito; nao implementar, nao regenerar `.tres`.

## Kanban Rapido

- Backlog / Doing / Review / Done: `08_Coordenacao_Agentes/Kanban/`
- Handoffs: `08_Coordenacao_Agentes/Handoffs/`
- Decisoes: `08_Coordenacao_Agentes/Decisoes/`

## Canon

- Fonte compartilhada estavel: `canon/` (brief rapido: `canon/canon-brief.md`)
