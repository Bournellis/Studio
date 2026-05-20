# CLAUDE.md

Este workspace e multi-projeto. Siga `AGENTS.md` como autoridade principal.

## Entrada Padrao

1. Leia `AGENTS.md`.
2. Leia `Projetos/README.md`.
3. Leia a secao relevante de `08_Coordenacao_Agentes/Estado_Atual.md`.
4. Escolha o projeto alvo antes de ler documentacao profunda.
5. Ao entrar em um projeto, leia o `AGENTS.md` local e `implementation/current-status.md`.

## Regra De Leitura

Use Fast Lane por padrao. Escale para a leitura completa somente quando a tarefa afetar canon, arquitetura, plataforma, produto, mais de um projeto, ou quando o escopo deixar de ser local.

## Fronteiras

- `canon/` e a fonte compartilhada de produto, arquitetura, plataforma, progressao e lore.
- `Projetos/rpg-isometrico/` e o RPG de acao isometrico campaign-first.
- `Projetos/rpg-turnos/` e o RPG-cardgame por turnos; ele pode compartilhar lore, mas possui mecanicas independentes.
- `Projetos/draxos-roguelike-cardgame/` e o roguelike cardgame Draxos menu-first; use para ship hub, run map, rota de 10 mapas, almas/cura, batalhas por lanes e Track 01.
- `Projetos/draxos-mobile/` e o jogo mobile PVP assincrono com base manager e sistema social. Promovido de `_conceitos/mobile-universe/` em 2026-05-18. Stack: Godot 4.6.2 (GDScript) + Supabase (TypeScript Edge Functions). Batalha 100% servidor. Track ativa: Track 00. Nao confundir com `draxos-roguelike-cardgame`.
- Nao importe mecanicas entre projetos sem documento local adotando a regra.
- Nao use historico como canon atual.

## Desambiguacao Rapida

`Draxos` e `cardgame` aparecem em mais de um projeto. Se o pedido citar `draxos-roguelike-cardgame`, `Draxos roguelike`, `ship hub`, `run map`, `10 mapas`, `almas`, ou `rota completa`, escolha `Projetos/draxos-roguelike-cardgame/` antes de ler qualquer guia local de `rpg-turnos`.

Se o pedido citar `draxos-mobile`, `DraxosMobile`, `PVP assincrono`, `base manager`, `mobile`, `mago Draxos`, `autobattler` ou `primeiro slice`, escolha `Projetos/draxos-mobile/`.

## Estado Operacional

`08_Coordenacao_Agentes/Estado_Atual.md` e o snapshot vivo do estudio. Atualize apenas quando uma tarefa mudar status observavel, track ativa, baseline ou proximo passo.
