# Prioridades do Estudio

## Metadata

- status: `active`
- authority: `portfolio_state`
- last_verified: `2026-07-16`
- review_when: `Fabio changes focus, portfolio status or allowed work`
- supersedes: `none`
- superseded_by: `none`

Este documento e a unica fonte de verdade para foco, status de portfolio e trabalho permitido no `D:\Estudio`.

## Foco Atual

- Foco operacional ativo: `Projetos/JogoDaCopa/` (10D publicada e aprovada; 10A fallback aprovado) + `Projetos/draxos-mobile/` (hardening integrado localmente preservado; Web Static Assets Hotfix v1 aprovada sobre Arena Runtime Config Sync Ready v3; Arena core ainda aguardando prova humana) + `Projetos/FpsPlayground/` (Track 14I limpeza de debugger Godot aprovada em teste humano; movimento atual preservado)
- Pausa temporaria por poucos dias: `Projetos/draxos-roguelike-cardgame/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/` (referencia - nao e o projeto ativo)
- Projetos pausados: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## Portfolio

| Prioridade | Projeto | Caminho | Status | Trabalho permitido | Proximo passo |
|---|---|---|---|---|---|
| P0 TEMP | JogoDaCopa | `Projetos/JogoDaCopa/` | `P2_IMPLEMENTACAO` | Codigo, design, validacao, playtest no editor e documentacao local | Decidir a proxima etapa: continuar reducoes locais conservadoras ou abrir nova melhoria de feel/polish |
| Pausa | Draxos Roguelike Cardgame | `Projetos/draxos-roguelike-cardgame/` | `PAUSADO_TEMPORARIO` | Consulta historica e retomada explicita apenas | Retomar quando o foco temporario encerrar |
| Ativo | DraxosMobile | `Projetos/draxos-mobile/` | `P2_IMPLEMENTACAO` | Codigo, design, validacao, playtest, documentacao local e infraestrutura | Web Static Assets Hotfix v1 aprovada sobre Arena Runtime Config Sync Ready v3 `0.0.27-alpha.0` / vc `27`; proximo passo e prova humana do roteiro Arena antes de tuning, PVP, economia, conteudo ou expansao |
| Ativo | FpsPlayground | `Projetos/FpsPlayground/` | `P2_IMPLEMENTACAO` | Codigo, design, validacao, playtest no editor e documentacao local | Track 14I limpeza de debugger Godot aprovada em teste humano; proximo passo recomendado: Multi-Arena Balance Baseline V1 |
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
