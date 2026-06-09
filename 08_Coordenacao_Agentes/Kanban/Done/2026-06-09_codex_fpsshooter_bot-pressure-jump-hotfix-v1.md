# FpsShooter - Bot Pressure Jump Hotfix V1

- Data: `2026-06-09`
- Agente: `codex`
- Branch: `codex/fpsshooter/bot-pressure-jump-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--bot-pressure-jump-hotfix-v1`
- Projeto alvo: `Projetos/FpsShooter`
- Status: `DONE`

## Objetivo

Corrigir dois problemas observados no smoke da Track 02A:

- o bot prioriza demais ir ate a vida e perde pressao ofensiva;
- o bot nao sabe pular, limitando o uso de rampas/plataformas e futuro eixo vertical.

## Escopo Pretendido

- Ajustar prioridade da IA para atirar quando tiver linha de visao, cooldown pronto e alvo valido.
- Fazer Health Shard virar decisao de sobrevivencia/rotacao, nao primeira escolha sempre que estiver abaixo de meia vida.
- Preservar Overcharge como contest situacional, sem roubar tiro claro.
- Adicionar salto simples ao bot para:
  - subir pequenas diferencas de altura ao reposicionar;
  - pular se estiver travado diante de obstaculo pequeno;
  - manter cooldown para evitar spam de pulo.
- Atualizar testes automatizados para ofensiva sobre cura e salto do bot.
- Atualizar docs/status locais e portfolio apenas se o baseline observavel mudar.

## Fora Do Escopo

- `NavigationAgent3D`.
- Jump pads, plataformas suspensas, void/fall.
- Redesenho do mapa.
- Tuning amplo de dano/cadencia/precisao.
- Novas armas, ammo/reload ou recoil/spread.
- Multiplayer/export/backend.

## Arquivos Pretendidos

- `Projetos/FpsShooter/gameplay/bot/basic_duel_bot.gd`
- `Projetos/FpsShooter/tests/unit/test_bootstrap.gd`
- `Projetos/FpsShooter/docs/validation.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/implementation/tracks/track-02a-combat-loop-expansion-v1/current-status.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- `Projetos/README.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/FpsShooter/AGENTS.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/docs/work-plan.md`
- `Projetos/FpsShooter/implementation/tracks/track-02a-combat-loop-expansion-v1/current-status.md`

## Validacao Planejada

- `tools/validate.gd`
- `git diff --check`
- editor headless filtrado para warnings/erros GDScript nos scripts tocados
- `git status --short`

## Entrega

- Bot passa a priorizar tiro normal pronto antes de Health Shard ou Overcharge.
- Health Shard continua util quando ferido, mas vira decisao de sobrevivencia/rotacao durante cooldown, reacao, fora de alcance/pressao ou vida critica.
- Rotas ativas para cura sao interrompidas assim que linha de visao, alcance, cooldown e reacao permitem windup.
- Bot ganhou salto simples com cooldown e probe de contato com o chao para objetivos de reposicionamento elevados e bloqueios baixos.
- Status local e portfolio atualizados para `FPS_SHOOTER_TRACK_02A_BOT_PRESSURE_JUMP_HOTFIX_COMPLETE`.

## Validacao Executada

- `tools/validate.gd`: PASS.
- GUT: `29/29`.
- Asserts: `249`.
- `git diff --check`: PASS.
- editor headless filtrado para `GDScript::reload`, `SCRIPT ERROR`, `Parse Error`, `SHADOWED`, `INT_AS_ENUM`, `basic_duel_bot.gd` e `test_bootstrap.gd`: sem ocorrencias.

## Proximo Handoff

Merge na `main` e novo smoke humano no editor focado em pressao do bot antes de cura e salto simples em rampas/plataformas.
