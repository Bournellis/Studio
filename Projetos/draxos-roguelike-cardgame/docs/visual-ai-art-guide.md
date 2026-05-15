# Guia de Arte AI - Suporte Visual V1

Este guia cobre arte provisoria para playtest. A meta nao e arte final: e dar leitura visual para nave, mapa, tabuleiro e cartas.

## Direcao Base

Use uma frase base consistente:

```text
dark arcane sci-fi fantasy, Draxos ether-plasm technology, astral energy, high contrast readable game art, no text, no UI, no logos
```

Evite texto, letras, logos, molduras prontas e elementos de interface dentro da imagem. A UI do Godot escreve valores e textos.

## Fundos

Formato: `1920x1080`, 16:9.

- `main_menu_background.png`: menu principal Draxos com a mesma linguagem visual da nave; enquanto ausente, o jogo usa o fundo da nave.
- `ship_hub_background.png`: ponte de comando Draxos, nave/base de eter-plasma, consoles arcanos, energia astral.
- `mission_map_background.png`: mapa de missao do planeta elemental, rota de invasao, geografia vulcanica/astral.
- `battle_board_background.png`: mesa de batalha ritualistica, dois lados enfrentados, espaco limpo para slots e cartas.

## UI Da Nave E Classes

- `assets/ui/characters/Arcano.png`, `Invocador.png`, `Necromante.png`: personagens completos clicaveis para escolha de classe.
- `assets/ui/characters/ship/Arcano_ship.png`, `Invocador_ship.png`, `Necromante_ship.png`: versoes recortadas, sem fundo, para encaixar o jogador na cena da nave como botao de Deck.
- `assets/ui/battleship/Mapa.png`: imagem clicavel do mapa no centro da nave; precisa ser PNG RGBA real, sem xadrez fake desenhado.
- `assets/ui/battleship/NpcAlmas.png`: NPC recortado, sem fundo, para ficar a esquerda e abrir a loja de Almas.
- O manifest `data/definitions/visual_assets.json` posiciona estes overlays por coordenadas normalizadas em `ship_overlays`.

## Cartas

Formato de arte: `1024x1024`.

Gere a imagem sem texto e sem borda. A carta final no jogo combina:

- arte square;
- frame PNG por classe/faccao;
- texto e valores renderizados pela UI.

Frames esperados: `512x768`, PNG transparente.

- Arcano: energia astral, runas, tons violeta/azul.
- Invocador: vinculos, criatura comandada, tons verdes/metais escuros.
- Necromante: cinzas, morte ritual, tons roxos/pretos.
- Elemental: rocha, fogo, cristal, tons laranja/ambar.
- Neutral: metal escuro, eter neutro.

Cartas novas do pool atual que ainda podem usar fallback ate a arte existir:

- Arcano: `arcano_bola_de_fogo.png`, `arcano_acelerar.png`.
- Invocador: `invocador_atacar.png`, `invocador_golem.png`.
- Necromante: `necro_carniceiro.png`, `necro_punir.png`.

As variantes `_lvl2` e `_lvl3` reutilizam a arte/manifesto da carta base.
