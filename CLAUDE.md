# CLAUDE.md

Este workspace e multi-projeto. Siga `AGENTS.md` como autoridade principal.

## Fonte Unica De Estado

O estado operacional vive somente em:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md` - foco, prioridades e trabalho permitido por projeto
2. `08_Coordenacao_Agentes/Estado_Atual.md` - snapshot e proximo passo por projeto

Este arquivo nao carrega status, track ativa, pacote publicado nem proximo passo de nenhum projeto. Se outro documento conflitar com os dois acima, os dois acima prevalecem.

## Entrada Padrao

1. Leia `08_Coordenacao_Agentes/Prioridades_Estudio.md` e escolha o projeto alvo.
2. Leia `AGENTS.md` (worktrees, gates, roteamento).
3. Leia a secao relevante de `08_Coordenacao_Agentes/Estado_Atual.md`.
4. Ao entrar em um projeto, leia o `AGENTS.md` local e `implementation/current-status.md`.

## Regra De Leitura

Use Fast Lane por padrao. Escale para a leitura completa somente quando a tarefa afetar canon, arquitetura, plataforma, produto, mais de um projeto, ou quando o escopo deixar de ser local.

## Fronteiras (identidade estavel - sem status)

- `canon/` e a fonte compartilhada de lore, identidade de produto, arquitetura e plataforma. Nao carrega estado operacional.
- `Projetos/draxos-roguelike-cardgame/` e o roguelike cardgame Draxos menu-first para Steam/PC: ship hub, run map, almas, reliquias, batalhas por lanes.
- `Projetos/draxos-mobile/` e o Draxos PVE Arena-first async autobattler mobile/PC/browser com Refugio/Base e backend Supabase server-authoritative (batalha nunca simulada no cliente). Nao confundir com o roguelike.
- `Projetos/JogoDaCopa/` e o projeto de futebol/minigames de copa, PC Windows editor-first, terceira pessoa.
- `Projetos/FpsPlayground/` e o laboratorio FPS PC editor-first (sucessor do antigo `FpsShooter`).
- `Projetos/rpg-isometrico/` e o RPG de acao isometrico campaign-first.
- `Projetos/rpg-turnos/` e o RPG-cardgame por turnos; compartilha lore, mecanica independente.
- `Projetos/_conceitos/mobile-universe/` e arquivo de design somente leitura.
- Nao importe mecanicas entre projetos sem documento local adotando a regra.
- Nao use historico como canon atual.

## Desambiguacao R