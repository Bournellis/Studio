# Estado Atual - Estudio

- Ultima atualizacao: `2026-06-24`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- Regra de tamanho: maximo ~12 linhas por projeto. Historia de pacotes/validacoes vai para os arquivos de historico do projeto (`implementation/tracks/`, `docs/release-history.md`, Kanban Done), nunca para este snapshot.

## Prioridade Do Estudio

- Foco operacional ativo: `Projetos/JogoDaCopa/` (10D publicada com gates remotos PASS; aguardando reteste humano; 10A fallback aprovado) + `Projetos/draxos-mobile/` (Arena Web Static Assets Hotfix v1 aprovada; Arena core ainda aguardando prova humana) + `Projetos/FpsPlayground/` (Track 14I limpeza de debugger Godot mergeada localmente; movimento atual preservado)
- Pausados temporariamente (poucos dias): `Projetos/draxos-roguelike-cardgame/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## JogoDaCopa

- Status: `P2_IMPLEMENTACAO - TRACK10D_PUBLISHED_REMOTE_GATES_PASSED_HUMAN_RETEST_PENDING`
- Marker: `JOGO_DA_COPA_TRACK10D_PUBLISHED_REMOTE_GATES_PASSED_HUMAN_RETEST_PENDING`
- Publicacao atual: Track 10D `Super Campeao v1.2.1+45da58b1` (`web/v1-copa-arena-futebol-20260620-45da58b1`) em `https://copa-arena-futebol.pages.dev/`; gates remotos PASS, reteste humano pendente.
- Track 10D: gol Web por pop dourado maior, audio default ainda desligado; remoto 5min PASS com `js_heap_growth -5.35%`, pico `+0.04%`, pior 5s `139.8 FPS`.
- Fallback aprovado: Track 10A `Super Campeao v1.2.1+fc3c72bb` (`web/v1-copa-arena-futebol-20260620-fc3c72bb`); reteste humano 10A aprovado.
- Fallback historico aprovado: Track 09S `Super Campeao v1.2.1+925f3b9f`; gates remotos 09S PASS e reteste humano aprovado.
- Fallback historico aprovado: Track 09Q `Super Campeao v1.2.1+bb604c77`; remote menu/first-minute/stability/luma PASS (`js_heap_growth +8.41%`) e aprovada por Fabio/tester.
- Trabalho permitido: codigo, design, validacao, playtest no editor e documentacao local.
- Proximo passo: Fabio/tester retestar a 10D no link publico; se aprovar, registrar 10D como baseline aprovada; se reprovar, decidir novo hotfix focado ou rollback 10A.

## draxos-roguelike-cardgame

- Status: `PAUSADO_TEMPORARIO - retomada prevista em poucos dias`
- Track ativa preservada: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline: Track 02 completa em Godot 4.6.2 (rota de 29 mapas, save v5, keywords, AI/intent, labs Card Impact V5 e Design Lab V1, `validate.gd` 220/220). Detalhes em `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`.
- Meta preservada: expansao de conteudo via Design Lab antes de playtests completos de sensacao.
- Trabalho permitido: consulta historica; retomada apenas com pedido explicito.
- Proximo passo: retomar quando o foco temporario do JogoDaCopa encerrar.

## DraxosMobile

- Status: `P2_IMPLEMENTACAO` - Web Static Assets Hotfix v1 aprovada por Fabio em 2026-06-24 sobre Arena runtime_config recovery v3; Arena core ainda aguardando prova humana
- Marker: `ARENA_WEB_STATIC_ASSETS_HOTFIX_V1_HUMAN_APPROVED`
- Pacote publicado: app/runtime `Arena Runtime Config Sync Ready v3`, Web/APK/PC `0.0.27-alpha.0` / vc `27`; Web host hotfix preview `https://10efff9c.draxos-mobile-internal-alpha.pages.dev`. Historico: `Projetos/draxos-mobile/docs/release-history.md`.
- Programa de hardening: Web runtime assets sairam do Supabase Storage publico para Cloudflare Pages (`index.pck` local + `index.wasm.part*`); runtime_config Web repinta rota ao sair de fallback.
- Resultado de produto Arena PVE: `ARENA_CORE_NEEDS_UX_FIX` + `ARENA_CORE_NOT_PROVEN`; decisao em `08_Coordenacao_Agentes/Decisoes/2026-06-14_draxos-mobile_arena-core-ux-fix-not-proven.md`.
- Guardrails preservados: Track 13 release safety, Track 14 agent ops; fundacao server-authoritative/idempotencia/RLS NAO deve ser refatorada.
- Restricao operacional: ver `Projetos/draxos-mobile/AGENTS.md` (Hard Stops); secrets nunca no cliente; publicacao remota exige `-ConfirmRemoteMutation`; sem tuning numerico/PVP/economia/visual final sem decisao.
- Proximo passo: Fabio/tester executar a prova humana do roteiro Arena seguindo `docs/arena-pve-product-proof.md`; registrar veredito antes de tuning, economia, PVP, conteudo novo, visual final ou expansao Openworld.

## FpsPlayground

- Status: `P2_IMPLEMENTACAO - TRACK14I_GODOT_DEBUGGER_CLEANUP_LOCAL`
- Marker: `FPS_PLAYGROUND_TRACK14I_GODOT_DEBUGGER_CLEANUP_LOCAL`
- Baseline: Track 14I mergeada localmente; debugger/editor Godot limpos de warnings GUT UID/text-path e leak headless; gameplay Track 14H preservado.
- Guardrail recente: Track 08 movement feel descartada antes de merge; movimento atual, jump pads, mapas e bot route-control preservados.
- Validacao: editor/menu/arena headless sem warnings; `tools/validate.gd` quick/full PASS `67/67`, `599 asserts`; `tools/check_doc_drift.ps1` PASS.
- Trabalho permitido: codigo, design, validacao, playtest no editor e documentacao local.
- Proximo passo: Fabio/tester confirmar `Relay Foundry V1` no editor; depois executar `Multi-Arena Balance Baseline V1` antes de novas armas, buffs, mapas, tuning ou bot intelligence.

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
