# Prioridades do Estudio

Este documento e a fonte de verdade de portfolio para agentes e para coordenacao do `D:\Estudio`.

## Foco Atual

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao (`BOSQUE_WORLD_HUB_DOMAIN_SEPARATION_V1_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-bosque-world-hub-domain-separation-v1-20260606-81ecf05`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://d1872010.draxos-mobile-internal-alpha.pages.dev`; publicado em `main`, APK/manifest `0.0.8-alpha.0`/version code `8`, separando materiais locais do Bosque (`resto_ritual`, `po_cinzento`) de recursos globais da conta (`ossos`, `po_osso`) e persistindo `fogueira_estavel_1` como `upgrades` + `structures`; Bosque Fogueira Potion Crafting v1 preservado como pacote anterior de station craft (`internal-alpha/v0-bosque-fogueira-potion-crafting-v1-20260606-cad6d2c`, preview `https://08d00f24.draxos-mobile-internal-alpha.pages.dev`), seguido por Bosque Durable Bau Mochila v1, Arena PVE Menu Flow Simplification v1 e Bosque Offline-First Checkpoint v1): `Projetos/draxos-mobile/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/` (preservado como referencia - nao e o projeto ativo)
- Projetos pausados: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## Portfolio

| Prioridade | Projeto | Caminho | Fase | Status | Trabalho permitido | Proximo passo | Restricao operacional |
|---|---|---|---|---|---|---|---|
| P0 | Draxos Roguelike Cardgame | `Projetos/draxos-roguelike-cardgame/` | Implementacao | `P0_IMPLEMENTACAO` | Codigo, validacao, playtest, documentacao local | Track 02 completa segue pronta para playtest, mas o proximo trabalho recomendado e expansao de conteudo via Design Lab proposal packs antes de promocao manual: AutoRun Gate Pack V1, Scenario Fixtures V1, Gameplay Lab V1, Lab Diff Reporter V1, Card Impact V1-V5 e Design Lab V1 ficam disponiveis para regressao/tuning explicitos; depois de promover candidatos, proteger com Card Impact V4.2/V5 e Run Lab smoke/quick antes de full-run feel playtests | Pode receber trabalho de implementacao por padrao |
| P2 | DraxosMobile | `Projetos/draxos-mobile/` | Implementacao - `BOSQUE_WORLD_HUB_DOMAIN_SEPARATION_V1_PUBLISHED_INTERNAL_ALPHA` | `P2_IMPLEMENTACAO` | Codigo, design, documentacao local, configuracao de infraestrutura | Playtest humano do pacote Bosque World Hub Domain Separation v1; validar que nodes antigos aparecem como `Resto ritual`/`Po cinzento`, que `ossos`/`po_osso` globais nao mudam por coleta, que Fogueira nao some apos sair/relogar, que station craft consome `Bau do Bosque` + `Conta/Ossario`, e que Arena Preparacao continua equipando pocoes | Bosque World Hub Domain Separation v1 publicado em 2026-06-06 no release root `internal-alpha/v0-bosque-world-hub-domain-separation-v1-20260606-81ecf05`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://d1872010.draxos-mobile-internal-alpha.pages.dev`; publicado a partir de `main`, APK/manifest `0.0.8-alpha.0`/version code `8`, aplica migration `202606060004_bosque_world_hub_domain_separation_v1.sql`, normaliza inventarios legados e preserva gameplay ativo client-owned/offline-first. Stable Portal/Web ficam Cloudflare Access protected. Android APK usa `debug_fallback`, aceito para playtest funcional; release signing adiado. iOS sem pedido explicito; mobile browser fora do escopo primario; secrets e service role nunca entram no cliente/export; novas mutacoes economicas/social devem seguir RPC transacional v1; tuning amplo, PVP, novas armas/spells/economia e visual final bloqueados ate decisao propria |
| Arquivo | Mobile Universe (conceito) | `Projetos/_conceitos/mobile-universe/` | Arquivo de design | `ARQUIVO_DESIGN` | Leitura e referencia de design apenas | - | Nao criar codigo, cenas, assets ou projeto Godot a partir daqui |
| Pausado | RPG Isometrico | `Projetos/rpg-isometrico/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, expandir gates ou selecionar Next Gate sem pedido explicito |
| Pausado | RPG Turnos | `Projetos/rpg-turnos/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, selecionar track/gate, regenerar `.tres` ou alterar escopo sem pedido explicito |

Nota Draxos Roguelike Cardgame: `Design Lab V1 Foundation` foi concluido em 2026-06-06. O sample `design_lab_sample_v1` passou gate em `user://design_lab/design_lab_sample_v1_gate` com 36 candidatos, 3 recomendacoes, 0 mecanicas bloqueadas e sem alterar `data/definitions/slice_catalog.json`. O lab agora e a ponte recomendada entre ideia de carta/mecanica/encontro e numeros jogaveis. Regressao preservada: `validate.gd` 220/220, Card Impact V5 official before gate PASS, Run Lab smoke/quick gates PASS. A baseline anterior `Enemy Card Redesign Batch 02 Using V5 Terra` segue aceita com 30/30 assinaturas inimigas e 21/21 Card Flow Expectations.

Nota DraxosMobile: `Bosque World Hub Domain Separation v1` foi publicado como Internal Alpha em `internal-alpha/v0-bosque-world-hub-domain-separation-v1-20260606-81ecf05`, mantendo a URL principal como contrato player-facing e usando `main` como trunk local/publicacao Pages. O pacote corrige a confusao entre materiais locais do Bosque e recursos globais da conta, troca `ossos_preview`/`po_osso_preview` publicos por `resto_ritual`/`po_cinzento`, persiste `fogueira_estavel_1` em `upgrades` e `structures`, e preserva `Bosque Fogueira Potion Crafting v1` (`internal-alpha/v0-bosque-fogueira-potion-crafting-v1-20260606-cad6d2c`, preview `https://08d00f24.draxos-mobile-internal-alpha.pages.dev`) como pacote anterior de station craft. Track 13 release safety e Track 14 agent ops seguem como guardrails operacionais.

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
