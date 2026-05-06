# RPG Turnos - Modo Ondas

- Data: `2026-05-05`
- Agente: `codex`
- Projeto: `Projetos/rpg-turnos`
- Status: `done`

## Objetivo

Implementar o proximo modo oficial pequeno: `ondas`.

## Escopo

- ler `waves` em encontros JSON
- spawnar a primeira onda no inicio do encontro
- spawnar a proxima onda na manutencao inimiga apos limpar a onda atual
- manter HP, mesa do jogador, mao, deck e rampa de energia entre ondas
- vencer apenas apos limpar a ultima onda
- expor indicador de onda na UI de batalha
- tornar `invasao_em_ondas` acessivel no mapa
- adicionar testes GUT focados

## Resultado

- `ondas` implementado em `BattleEngine`
- `invasao_em_ondas` acessivel no mapa apos `fortaleza_do_desfiladeiro`
- HUD de batalha exibe `Onda X/Y`
- validacao verde: 65/65 testes

## Fora de Escopo

- novos assets
- novas cartas
- modo `defesa`
- narrativa nova para a campanha
