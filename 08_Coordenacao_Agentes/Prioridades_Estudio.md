# Prioridades do Estudio

Este documento e a fonte de verdade de portfolio para agentes e para coordenacao do `D:\Estudio`.

## Foco Atual

- Foco unico de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Projetos em conceito: `Projetos/_conceitos/RPGMobile/`, `Projetos/_conceitos/BattleMobile/`
- Projetos pausados: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## Portfolio

| Prioridade | Projeto | Caminho | Fase | Status | Trabalho permitido | Proximo passo | Restricao operacional |
|---|---|---|---|---|---|---|---|
| P0 | Draxos Roguelike Cardgame | `Projetos/draxos-roguelike-cardgame/` | Implementacao | `P0_IMPLEMENTACAO` | Codigo, validacao, playtest, documentacao local | Playtestar rota completa, substituir overlays por PNGs com alpha real e definir recompensas restantes | Pode receber trabalho de implementacao por padrao |
| P1 | RPGMobile | `Projetos/_conceitos/RPGMobile/` | Conceito | `P1_CONCEITO` | Conceito, pitch, design, referencias | Definir pitch, fantasia central, loop principal e pilares | Nao criar codigo, cenas, assets de implementacao ou projeto Godot sem pedido explicito |
| P1 | BattleMobile | `Projetos/_conceitos/BattleMobile/` | Conceito | `P1_CONCEITO` | Conceito, pitch, design, referencias | Definir pitch, fantasia central, loop principal e pilares | Nao criar codigo, cenas, assets de implementacao ou projeto Godot sem pedido explicito |
| Pausado | RPG Isometrico | `Projetos/rpg-isometrico/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, expandir gates ou selecionar Next Gate sem pedido explicito |
| Pausado | RPG Turnos | `Projetos/rpg-turnos/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, selecionar track/gate, regenerar `.tres` ou alterar escopo sem pedido explicito |

## Status Aceitos

- `P0_IMPLEMENTACAO`: foco principal do trabalho de desenvolvimento, com permissao padrao para codigo, validacao e playtest.
- `P1_CONCEITO`: projeto em incubacao conceitual; permite documentos, pitch, design e referencias.
- `PAUSADO_INDEFINIDO`: projeto preservado, sem trabalho ativo por padrao.
- `AGUARDANDO_DECISAO`: projeto ou area sem proximo passo definido.
- `ARQUIVO_HISTORICO`: material preservado apenas para consulta historica.

## Regras Para Agentes

- Leia este arquivo antes de escolher projeto alvo.
- Se o pedido nao citar projeto, assuma que trabalho de implementacao pertence ao Draxos Roguelike Cardgame.
- Nao mova mecanicas, decisoes ou escopo entre projetos sem documento local adotando a regra.
- Em RPGMobile e BattleMobile, limite o trabalho a conceito, pitch, design e referencias.
- Em RPG Isometrico e RPG Turnos, nao implemente nem expanda escopo sem pedido explicito do usuario.
- Ao concluir tarefa que mude status observavel, atualize este arquivo, `Estado_Atual.md` e o registro relevante em `Projetos/README.md`.
