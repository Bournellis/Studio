# Track 10 - Battle Presentation Rework

## Objetivo

Reformular a apresentacao da batalha para o loop portrait do DraxosMobile. Durante a execucao, a tela deve mostrar apenas o duelo dos magos, o HUD interno do palco e o botao `Pular batalha` no canto inferior direito. Logs, historico, recompensas e detalhes administrativos ficam fora da execucao e aparecem apenas depois.

## Decisoes

- O app permanece portrait, inclusive batalha.
- `battle_running` e fullscreen sem chrome do app.
- A execucao usa palco limpo com `BattleStage2D` como foco.
- HP, mana, spells, status, efeitos e summons continuam visiveis dentro do palco.
- O summary principal mostra apenas resultado minimo e acoes.
- Logs da batalha atual abrem em tela propria.

## Fora De Escopo

- Backend novo, schema, migracao ou endpoint novo.
- Alteracao do simulador, `battle_log_v1`, recompensa, ranking ou economia.
- Assets finais.
- Publicacao remota.
- Rework de Refugio, Social, Competicao, Loja ou Conta.
