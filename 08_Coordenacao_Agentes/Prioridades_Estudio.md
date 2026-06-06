# Prioridades do Estudio

Este documento e a fonte de verdade de portfolio para agentes e para coordenacao do `D:\Estudio`.

## Foco Atual

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao (`BOSQUE_SYNC_RESPONSIVENESS_V1_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`; publicado em `main`, com migration remota `202606050003_openworld_bosque_collect_batch_v1.sql`, APK/manifest `0.0.3-alpha.0`/version code `3`, preservando Arena/Bosque Visible V2, Arena/Bosque Regression Hotfix, Arena PVE Season 1 Loop v1, Arena Duel Flow Hotfix, Arena PVE First Real Run + Update Recovery, Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync, Foundation Hardening V2, Track 23 Arena recovery, Track 21 Arena Loop Unlock/Friction, Track 20 Season 1 Arena Calibration, Remote Lab Runner, Track 13 release safety e Track 14 agent ops): `Projetos/draxos-mobile/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/` (preservado como referencia - nao e o projeto ativo)
- Projetos pausados: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## Portfolio

| Prioridade | Projeto | Caminho | Fase | Status | Trabalho permitido | Proximo passo | Restricao operacional |
|---|---|---|---|---|---|---|---|
| P0 | Draxos Roguelike Cardgame | `Projetos/draxos-roguelike-cardgame/` | Implementacao | `P0_IMPLEMENTACAO` | Codigo, validacao, playtest, documentacao local | Playtest de usuario da Track 02 completa; AutoRun Gate Pack V1, Scenario Fixtures V1, Gameplay Lab V1, Lab Diff Reporter V1, Card Impact Pack V1, Card Impact Effect Signature V2, Card Impact V2 Non-Damage Coverage e Card Redesign Batch 01 disponiveis para regressao/tuning explicitos; proximo trabalho recomendado e reduzir ambiguidade do `card_focus_legal` antes de redesigns amplos | Pode receber trabalho de implementacao por padrao |
| P2 | DraxosMobile | `Projetos/draxos-mobile/` | Implementacao - `BOSQUE_SYNC_RESPONSIVENESS_V1_PUBLISHED_INTERNAL_ALPHA` | `P2_IMPLEMENTACAO` | Codigo, design, documentacao local, configuracao de infraestrutura | Playtest humano do pacote publicado Bosque Sync Responsiveness v1: coletar 10+ recursos rapidamente, depositar durante sync pendente, craftar, sair/reabrir e confirmar persistencia de bolso/bau/nodes; regressao de Arena Preparacao e buff -> Resolver duelo | Bosque Sync Responsiveness v1 publicado em 2026-06-05 no release root `internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`; publicado a partir de `main`, aplica migration remota `202606050003_openworld_bosque_collect_batch_v1.sql`, forca APK/manifest `0.0.3-alpha.0`/version code `3`, restaura coleta/deposito/craft local-first do Bosque via `collect_batch` e mantem conclusao/reward server-authoritative. Arena/Bosque Visible V2 fica preservado como pacote visivel anterior. Stable Portal/Web ficam Cloudflare Access protected. Android APK usa `debug_fallback`, aceito para playtest funcional; release signing adiado. iOS sem pedido explicito; mobile browser fora do escopo primario; secrets e service role nunca entram no cliente/export; novas mutacoes economicas/social devem seguir RPC transacional v1; tuning amplo, PVP, novas armas/spells/economia e visual final bloqueados ate decisao propria |
| Arquivo | Mobile Universe (conceito) | `Projetos/_conceitos/mobile-universe/` | Arquivo de design | `ARQUIVO_DESIGN` | Leitura e referencia de design apenas | - | Nao criar codigo, cenas, assets ou projeto Godot a partir daqui |
| Pausado | RPG Isometrico | `Projetos/rpg-isometrico/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, expandir gates ou selecionar Next Gate sem pedido explicito |
| Pausado | RPG Turnos | `Projetos/rpg-turnos/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, selecionar track/gate, regenerar `.tres` ou alterar escopo sem pedido explicito |

Nota DraxosMobile: `Bosque Sync Responsiveness v1` foi publicado como Internal Alpha em `internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`, mantendo a URL principal como contrato player-facing e usando `main` como trunk local/publicacao Pages. `Arena/Bosque Visible V2` segue preservado como pacote visivel anterior, `Arena/Bosque Regression Hotfix` como visibility hotfix anterior, `Arena PVE Season 1 Loop v1` como pacote Season 1 anterior, `Arena Duel Flow Hotfix` como duel-flow hotfix anterior e `Arena PVE First Real Run + Update Recovery` como baseline Arena anterior.


## Status Aceitos

- `P0_IMPLEMENTACAO`: foco principal do trabalho de desenvolvimento, com permissao padrao para codigo, validacao e playtest.
- `P1_CONCEITO`: projeto em incubacao conceitual; permite documentos, pitch, design e referencias.
- `P2_IMPLEMENTACAO`: projeto ativo secundario; permite codigo, design, documentacao local e infraestrutura.
- `PAUSADO_INDEFINIDO`: projeto preservado, sem trabalho ativo por padrao.
- `AGUARDANDO_DECISAO`: projeto ou area sem proximo passo definido.
- `ARQUIVO_DESIGN`: material de conceito promovido - preservado apenas para leitura e referencia.
- `ARQUIVO_HISTORICO`: material preservado apenas para consulta historica.

## Regras Para Agentes

- Leia este arquivo antes de escolher projeto alvo.
- Se o pedido nao citar projeto, assuma que trabalho de implementacao pertence ao Draxos Roguelike Cardgame (P0).
- Nao mova mecanicas, decisoes ou escopo entre projetos sem documento local adotando a regra.
- Em `_conceitos/mobile-universe/`, apenas leitura e referencia de design - o projeto ativo e `draxos-mobile/`.
- Em RPG Isometrico e RPG Turnos, nao implemente nem expanda escopo sem pedido explicito do usuario.
- Ao concluir tarefa que mude status observavel, atualize este arquivo, `Estado_Atual.md` e o registro relevante em `Projetos/README.md`.
