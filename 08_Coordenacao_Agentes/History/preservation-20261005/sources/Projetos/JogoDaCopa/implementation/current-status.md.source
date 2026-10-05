# JogoDaCopa — estado técnico local

## Metadata

- status: living
- authority: local_state
- last_verified: 2026-07-16
- review_when: baseline técnica, track local ou gate técnico mudar
- supersedes: current-status anterior ao cutover de governança v2
- superseded_by: none

## Baseline

- Projeto: `JogoDaCopa`; produto local: `Super Campeao`.
- Referência de portfólio: `P2_IMPLEMENTACAO`; a autoridade permanece em `../../../08_Coordenacao_Agentes/Prioridades_Estudio.md`.
- Baseline técnica aplicada: Track 10D Web Goal Golden Pop Hotfix.
- Última regressão registrada: 108/108 testes, 1.844 asserts e 62 scripts verificados.
- Superfícies locais: editor Windows e export Web single-threaded.
- Nenhuma track de produto foi aberta pela migração de governança.

## Contrato preservado

- Futebol TPS 1x1 contra bot; partida padrão de 3 minutos com golden goal, além do modo 3 gols.
- Bola arcade solta, chute carregado, SUPER, boost/jump pads, dash/slide/stun/flip e emote.
- Arena fechada, gols com altura, avatares skinned, seleção de pele/camisa e HUD broadcast.
- PC mantém feedback completo; Web usa o caminho leve de gol com visual ativo e áudio de gol padrão desativado.
- Sem FPS, armas, mobile, multiplayer ou backend.

## Arquitetura aplicada

- `football_root.gd` orquestra ciclo e delega runtime, partida, UI, render e apresentação.
- `football_ball.gd`, `football_bot.gd` e `football_match_rules.gd` concentram bola, bot e regras.
- `football_hud.gd` é a fachada do HUD; pause/settings ficam no controller extraído.
- `bootstrap_scene_generator.gd` é a origem das cenas geradas.

## Gates e dívida

- Gates humanos preservados: feel/tuning, câmera, áudio, visual e publicação.
- Baseline de engenharia: `engineering-health-baseline.md`; dívida não pode crescer ao ser tocada.
- Linhagem de release, URLs, pacotes, tentativas e rollbacks: `../docs/release-history.md` somente.
- Evidências históricas: `../docs/playtest-reports/` e `../docs/screenshots/`.

## Próximo passo permitido

Não há nova track autorizada por esta migração. Trabalho futuro nasce em card local e respeita o foco do portfólio e os gates humanos existentes.
