# Prioridades do Estudio

Este documento e a fonte de verdade de portfolio para agentes e para coordenacao do `D:\Estudio`.

## Foco Atual

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao (`ARENA_BOSQUE_REGRESSION_HOTFIX_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`; publicado em `main`, preservando Arena PVE Season 1 Loop v1 como pacote Season 1 anterior, Arena Duel Flow Hotfix como hotfix anterior, Arena PVE First Real Run + Update Recovery como pacote Arena anterior, Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync, Foundation Hardening V2 (`FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`), Track 23 Arena recovery, Track 21 Arena Loop Unlock/Friction, Track 20 Season 1 Arena Calibration, Remote Lab Runner, Track 13 release safety e Track 14 agent ops): `Projetos/draxos-mobile/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/` (preservado como referencia - nao e o projeto ativo)
- Projetos pausados: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## Portfolio

| Prioridade | Projeto | Caminho | Fase | Status | Trabalho permitido | Proximo passo | Restricao operacional |
|---|---|---|---|---|---|---|---|
| P0 | Draxos Roguelike Cardgame | `Projetos/draxos-roguelike-cardgame/` | Implementacao | `P0_IMPLEMENTACAO` | Codigo, validacao, playtest, documentacao local | Playtest de usuario da Track 02 completa; AutoRun Gate Pack V1, Scenario Fixtures V1, Gameplay Lab V1 e Lab Diff Reporter V1 disponiveis para regressao/tuning explicitos | Pode receber trabalho de implementacao por padrao |
| P2 | DraxosMobile | `Projetos/draxos-mobile/` | Implementacao - `ARENA_BOSQUE_REGRESSION_HOTFIX_PUBLISHED_INTERNAL_ALPHA` | `P2_IMPLEMENTACAO` | Codigo, design, documentacao local, configuracao de infraestrutura | Playtest humano do pacote publicado Arena/Bosque Regression Hotfix focando Preparacao antes de iniciar, menu ativo e buff choice, tutorial -> primeira Arena real de 3 duelos, buff pendente apos update/reopen, buff selecionado -> Resolver duelo, retomar/abandonar/encerrar tentativa antiga e Bosque deposit/craft/persistencia antes de tuning amplo ou novas expansoes | Arena/Bosque Regression Hotfix publicado em 2026-06-05 no release root `internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`; publicado a partir de `main`, restaura Preparacao antes de iniciar Arena, no menu ativo e na escolha de buff, e restaura feedback/persistencia de deposito/criacao do Bosque integrado antes de sair. Arena PVE Season 1 Loop v1 (`internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32`, evidence `https://d7333659.draxos-mobile-internal-alpha.pages.dev`) fica preservado como pacote Season 1 anterior. Arena Duel Flow Hotfix (`internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174`, evidence `https://0536635b.draxos-mobile-internal-alpha.pages.dev`) fica preservado como hotfix anterior. Arena PVE First Real Run + Update Recovery (`internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a`, evidence `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`) fica preservado como pacote Arena anterior. Export, Storage upload publico, Cloudflare Pages production branch `main`, manifest remoto, deploy da Edge Function `release`, smoke Web no preview e smokes remotos read-only passaram; stable Portal/Web ficam Cloudflare Access protected. Android APK usa `debug_fallback`, aceito para playtest funcional, com release signing adiado para distribuicao Android mais ampla. Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync, Bosque Mecanico Basico v2, First Access Runtime Fix, Foundation Hardening V2 (`FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`) e Hardening Platform V1 ficam preservados como baselines anteriores. Track 23 Arena recovery, Track 21 Arena Loop Unlock/Friction e Track 20 Season 1 Arena Calibration seguem preservados como contexto do modo Autobattler/Arena PVE; Remote Lab Runner segue preservado para Battle Lab/Progression Lab no Web export; iOS sem pedido explicito; mobile browser fora do escopo primario; secrets e service role nunca entram no cliente/export; publicacao remota exige `-ConfirmRemoteMutation`; mudancas visuais em Entry/Refugio/Batalha exigem `foundation-responsive-layout-contract.md` + `smoke_responsive_layout.gd`; novos dados devem usar `account_profiles/game_saves`; regras devem passar por registry/ruleset versionado; mutations economicas/social novas devem passar por RPC transacional v1 com `request_id`/`request_hash`; direct chat, ajudas, contribuicoes, moderacao, PVP, novas armas, novas spells, economia ampla, previsao de vitoria, contra-escolha por oponente, thresholds customizados, comportamento por inimigo e controles avancados de replay bloqueados ate decisao propria |
| Arquivo | Mobile Universe (conceito) | `Projetos/_conceitos/mobile-universe/` | Arquivo de design | `ARQUIVO_DESIGN` | Leitura e referencia de design apenas | - | Nao criar codigo, cenas, assets ou projeto Godot a partir daqui |
| Pausado | RPG Isometrico | `Projetos/rpg-isometrico/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, expandir gates ou selecionar Next Gate sem pedido explicito |
| Pausado | RPG Turnos | `Projetos/rpg-turnos/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, selecionar track/gate, regenerar `.tres` ou alterar escopo sem pedido explicito |

Nota DraxosMobile: `Arena/Bosque Regression Hotfix` foi publicado como Internal Alpha em `internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f`, mantendo a URL principal como contrato player-facing e usando `main` como trunk local/publicacao Pages. `Arena PVE Season 1 Loop v1` segue preservado como pacote Season 1 anterior, `Arena Duel Flow Hotfix` segue preservado como hotfix anterior e `Arena PVE First Real Run + Update Recovery` segue preservado como baseline Arena anterior.

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
