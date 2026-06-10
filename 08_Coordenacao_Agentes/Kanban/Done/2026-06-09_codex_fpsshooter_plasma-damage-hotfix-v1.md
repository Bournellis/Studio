# FpsShooter - Plasma Damage Hotfix V1

- Data: `2026-06-09`
- Agente: `codex`
- Branch: `codex/fpsshooter/plasma-damage-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--plasma-damage-hotfix-v1`
- Projeto alvo: `Projetos/FpsShooter`
- Status: `DONE`

## Objetivo

Corrigir o problema observado no smoke: o tiro secundario `Plasma Bolt` dispara e aparece, mas nao causa dano de forma confiavel no uso real.

## Escopo Pretendido

- Auditar fluxo de RMB do player ate resolucao de colisao/dano na arena.
- Reproduzir o caso com teste automatizado que simule o uso real: disparo visual/muzzle offset, viagem do projetil e acerto no bot.
- Corrigir colisao/dano/knockback/feedback sem alterar escopo de arma, cooldown, reload, ammo ou mapa.
- Atualizar status local e validacao se o baseline observavel mudar.
- Commitar e mergear na `main`.
- Depois do hotfix, apresentar plano completo para a proxima etapa.

## Fora Do Escopo

- Novas armas ou variantes.
- Tuning amplo de dano/cadencia/cooldown.
- Redesenho de mapa.
- Jump pads, plataformas suspensas, void/fall.
- Multiplayer/export/backend.

## Arquivos Pretendidos

- `Projetos/FpsShooter/modes/arena/arena_root.gd`
- `Projetos/FpsShooter/tests/unit/test_bootstrap.gd`
- `Projetos/FpsShooter/docs/validation.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/implementation/tracks/track-02a-combat-loop-expansion-v1/current-status.md`
- `Projetos/FpsShooter/implementation/tracks/track-02a-plasma-damage-hotfix-v1/current-status.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- `Projetos/README.md`
- `AGENTS.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/FpsShooter/AGENTS.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/docs/work-plan.md`

## Validacao Planejada

- `tools/validate.gd`
- `git diff --check`
- editor headless filtrado para warnings/erros GDScript nos scripts tocados
- `git status --short`

## Entrega

- Plasma Bolt agora converge do muzzle visual deslocado para o ponto de mira/crosshair da camera.
- Resolucao de projetil do jogador adiciona colisao radius-aware apos o raycast central para evitar tiro visual acertando sem dano.
- Testes cobrem Plasma Bolt carregado com dano/knockback forte e disparo real por `request_alt_fire()` acertando a borda do corpo a partir do muzzle deslocado.
- Status local, validacao e portfolio atualizados para `FPS_SHOOTER_TRACK_02A_PLASMA_DAMAGE_HOTFIX_COMPLETE`.

## Validacao Executada

- `tools/validate.gd`: PASS (`30/30`, `253` asserts).
- `git diff --check`: PASS.
- editor headless filtrado para warnings/erros GDScript nos scripts tocados: PASS.

## Proximo Handoff

Branch pronta para commit e merge na `main`; plano completo da Track 03A deve ser apresentado na resposta final.
