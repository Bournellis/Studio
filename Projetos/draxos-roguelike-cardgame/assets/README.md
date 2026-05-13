# Assets

Contrato visual provisorio do Draxos Roguelike Cardgame.

- O runtime le `data/definitions/visual_assets.json`.
- PNGs ausentes usam fallback tematico e nao quebram validacao.
- Fundos principais: 16:9 em `1920x1080`.
- Retratos de classe para escolha inicial: personagem completo em `assets/ui/characters/`.
- Personagens recortados para overlay da nave: PNG transparente em `assets/ui/characters/ship/`.
- Imagens clicaveis da nave: objetos/NPCs/sistemas em PNG transparente em `assets/ui/battleship/`.
- Arte de carta: square em `1024x1024`.
- Frames de carta: PNG transparente em `512x768`.
- Cardback inimigo: pendente em `assets/cards/cardback.png`; enquanto ausente, a batalha usa mockup visual.
- `Deck` usa a imagem da classe selecionada como fallback ate chegarem `Arcano_ship.png`, `Invocador_ship.png` e `Necromante_ship.png`.
- `Almas` usa mockup discreto ate chegar `assets/ui/battleship/NpcAlmas.png`.
- `Mapa.png` deve virar PNG RGBA real; o arquivo atual ainda tem xadrez fake desenhado e e reportado como divida visual.

Nao coloque texto, logotipo ou UI dentro das imagens geradas.
