# Prioridades do Estudio

## Metadata

- status: `active`
- authority: `portfolio_state`
- last_verified: `2026-09-21`
- review_when: `Fabio changes focus, portfolio status or allowed work`
- supersedes: `none`
- superseded_by: `none`

Este documento e a unica fonte de verdade para foco, status de portfolio e trabalho permitido no `D:\Estudio`.

## Foco Atual

Decisão explícita de Fabio em 2026-09-21: o único produto ativo passou a ser
**RPG Comando**, no repositório independente `D:/RPG Comando`. Todos os jogos e
processos deste workspace ficam `PAUSADO_INDEFINIDO` até retomada explícita. O
MMORPG legado em `D:/Studio/Projetos/MMORPG` também está congelado e serve apenas
como fonte seletiva de recuperação para objetivos de migração nomeados.

Não retomar design, código, QA, builds, infraestrutura, depuração, integração,
publicação, monitors ou backlog de legados. Autorizações antigas e término de
outro trabalho não levantam a pausa. Preservar baselines, gates e evidências;
consulta seletiva ao acervo para objetivo nomeado do RPG Comando é permitida.
## Portfolio

| Prioridade | Projeto | Caminho | Status | Trabalho permitido | Proximo passo |
|---|---|---|---|---|---|
| Pausado | JogoDaCopa | `Projetos/JogoDaCopa/` | `PAUSADO_INDEFINIDO` | Preservação e consulta seletiva para objetivo nomeado do RPG Comando | Nenhum; aguardar retomada explícita de Fabio |
| Pausado | Draxos Roguelike Cardgame | `Projetos/draxos-roguelike-cardgame/` | `PAUSADO_INDEFINIDO` | Preservação e consulta seletiva para objetivo nomeado do RPG Comando | Nenhum; aguardar retomada explícita de Fabio |
| Pausado | DraxosMobile | `Projetos/draxos-mobile/` | `PAUSADO_INDEFINIDO` | Preservação e consulta seletiva para objetivo nomeado do RPG Comando | Nenhum; aguardar retomada explícita de Fabio |
| Pausado | FpsPlayground | `Projetos/FpsPlayground/` | `PAUSADO_INDEFINIDO` | Preservação e consulta seletiva para objetivo nomeado do RPG Comando | Nenhum; aguardar retomada explícita de Fabio |
| Arquivo | Mobile Universe (conceito) | `Projetos/_conceitos/mobile-universe/` | `ARQUIVO_DESIGN` | Leitura e referencia de design apenas | - |
| Pausado | RPG Isometrico | `Projetos/rpg-isometrico/` | `PAUSADO_INDEFINIDO` | Preservação e consulta seletiva para objetivo nomeado do RPG Comando | Nenhum; aguardar retomada explícita de Fabio |
| Pausado | RPG Turnos | `Projetos/rpg-turnos/` | `PAUSADO_INDEFINIDO` | Preservação e consulta seletiva para objetivo nomeado do RPG Comando | Nenhum; aguardar retomada explícita de Fabio |

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
- Um pedido genérico não autoriza selecionar um jogo legado. O produto ativo vive exclusivamente em `D:/RPG Comando`.
- Ignore os projetos `PAUSADO_TEMPORARIO`/`PAUSADO_INDEFINIDO` por padrao, salvo pedido explicito de retomada ou consulta historica.
- Nao mova mecanicas, decisoes ou escopo entre projetos sem documento local adotando a regra.
- Em `_conceitos/mobile-universe/`, apenas leitura e referencia de design; DraxosMobile também está congelado.
- Em RPG Isometrico e RPG Turnos, nao implemente nem expanda escopo sem pedido explicito do usuario.
- Tarefas locais enfileiram `global_sync_needed` em `PortfolioSync_QUEUE.md`; somente uma tarefa `portfolio_sync` atualiza `Estado_Atual.md`.
- Esta tabela muda apenas quando Fabio altera foco, status de portfolio ou trabalho permitido. Nao replique estado em outros documentos.

## Automação pausada

Studio Governance (GitHub workflow 314879984) desabilitado em 2026-09-15, sem
execuções pendentes. Não reativar sem retomada explícita. Evidência:
D:/StudioLabs-builds/mmorpg/legacy-freeze-20260915/github-workflows.json.
