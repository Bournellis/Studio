# Prioridades do Estudio

Este documento e a fonte de verdade de portfolio para agentes e para coordenacao do `D:\Estudio`.

## Foco Atual

- Foco operacional ativo: `Projetos/JogoDaCopa/` (`Super Campeao v1.2.1+4a323fab` publico aprovado; Track 09I local validada) + `Projetos/draxos-mobile/` (hardening integrado localmente preservado; Arena UX/readability/recovery publicado Web/APK; aguardando prova humana) + `Projetos/FpsPlayground/` (Track 06 arena variety/bot generalization planejada)
- Pausa temporaria por poucos dias: `Projetos/draxos-roguelike-cardgame/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/` (referencia - nao e o projeto ativo)
- Projetos pausados: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## Portfolio

| Prioridade | Projeto | Caminho | Status | Trabalho permitido | Proximo passo |
|---|---|---|---|---|---|
| P0 TEMP | JogoDaCopa | `Projetos/JogoDaCopa/` | `P2_IMPLEMENTACAO` | Codigo, design, validacao, playtest no editor e documentacao local | Track 09I local validada; proximo passo: Fabio fazer push via GitHub Desktop, depois decidir publicar 09I ou seguir Track 09J local |
| Pausa | Draxos Roguelike Cardgame | `Projetos/draxos-roguelike-cardgame/` | `PAUSADO_TEMPORARIO` | Consulta historica e retomada explicita apenas | Retomar quando o foco temporario encerrar |
| Ativo | DraxosMobile | `Projetos/draxos-mobile/` | `P2_IMPLEMENTACAO` | Codigo, design, validacao, playtest, documentacao local e infraestrutura | Arena UX/readability/recovery publicado Web/APK `0.0.24-alpha.0` / vc `24`; proximo passo e prova humana do roteiro Arena antes de tuning, PVP, economia, conteudo ou expansao |
| Ativo | FpsPlayground | `Projetos/FpsPlayground/` | `P2_IMPLEMENTACAO` | Codigo, design, validacao, playtest no editor e documentacao local | Executar Track 06 `Arena Variety And Bot Generalization V1`; depois seguir Track 07 match UX, Track 08 movement feel, Track 09 combat sandbox |
| Arquivo | Mobile Universe (conceito) | `Projetos/_conceitos/mobile-universe/` | `ARQUIVO_DESIGN` | Leitura e referencia de design apenas | - |
| Pausado | RPG Isometrico | `Projetos/rpg-isometrico/` | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado |
| Pausado | RPG Turnos | `Projetos/rpg-turnos/` | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado |

Baselines, markers e detalhes por projeto vivem em `Estado_Atual.md` e no `implementation/current-status.md` de cada projeto. Historico de pacotes do DraxosMobile: `Projetos/draxos-mobile/docs/release-history.md`.

## Status Aceitos

- `P0_IMPLEMENTACAO`: foco principal do trabalho de desenvolvimento, com permissao padrao para codigo, validacao e playtest.
- `P1_CONCEITO`: projeto em incubacao conceitual; permite documentos, pitch, design e referencias.
- `P2_IMPLEMENTACAO`: projeto ativo secundario; permite codigo, design, documentacao local e infraestrutura.
- `PAUSADO_TEMPORARIO`: projeto preservado e retomavel em poucos dias; agentes devem ignorar por padrao e so atuar com pedido explicito de retomada.
- `PAUSADO_INDEFINIDO`: projeto preservado, sem trabalho ativo por padrao.
- `AGUARDANDO_DECISAO`: projeto ou area sem proximo passo definido.
- `ARQUIVO_DESIGN`: material de conceito promovido - preservado apenas para leitura e referencia.
- `ARQUIVO_HISTORICO`: material preservado apenas para consulta historica.

## Regras Para Agentes

- Leia este arquivo antes de escolher projeto alvo.
- Se o pedido nao citar projeto nem dominio claro, confirme o alvo entre os focos ativos (`JogoDaCopa`, `draxos-mobile`) antes de agir.
- Ignore os projetos `PAUSADO_TEMPORARIO`/`PAUSADO_INDEFINIDO` por padrao, salvo pedido explicito de retomada ou consulta historica.
- Nao mova mecanicas, decisoes ou escopo entre projetos sem documento local adotando a regra.
- Em `_conceitos/mobile-universe/`, apenas leitura e referencia de design - o projeto ativo e `draxos-mobile/`.
- Em RPG Isometrico e RPG Turnos, nao implemente nem expanda escopo sem pedido explicito do usuario.
- Ao concluir tarefa que mude status observavel, atualize `Estado_Atual.md` e, se foco/prioridade mudou, a tabela deste arquivo. Nao replique estado em outros documentos.
