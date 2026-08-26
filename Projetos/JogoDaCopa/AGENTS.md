# AGENTS.md — JogoDaCopa

## Metadata

- status: living
- authority: operational_contract
- last_verified: 2026-08-26
- review_when: governança, arquitetura ou gates locais mudarem
- supersedes: AGENTS.md anterior ao cutover de governança v2
- superseded_by: none

## Papel do projeto

`JogoDaCopa` é o projeto Godot oficial do minigame TPS de futebol `Super Campeao`. Seu `STUDIO_CORE.md` declara `universe_binding: none`: ele é independente do universo compartilhado, do FPS e de mecânicas Draxos.

O portfólio governa o trabalho permitido; este arquivo governa como trabalhar localmente.

## Ordem de leitura

1. `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `implementation/current-status.md`
3. `STUDIO_CORE.md` quando universo, ficção ou identidade compartilhada forem relevantes
4. `08_Coordenacao/README.md`
5. `qa/QA_INDEX.md`
6. `docs/documentation-index.md`
7. contrato ou arquivo tocado

## Coordenação e Git

- Use worktree dedicada em `D:\Estudio-worktrees\jogodacopa--<agente>--<slug>` e branch `codex/jogodacopa/<slug>` para Codex.
- Cards e handoffs novos de escopo local vivem em `08_Coordenacao/`.
- Trabalho local enfileira `global_sync_needed`; não edita `Prioridades_Estudio.md`, `Estado_Atual.md` ou dashboards.
- Commits separam documentação, QA, runtime, evidência e coordenação.
- Git é somente local. Push, fetch, pull, deploy e publicação são exclusivos de Fabio.

## Arquitetura

- `autoloads/`: input e bootstrap.
- `gameplay/avatar/`, `gameplay/player/`, `gameplay/football/`: avatar, movimento, bola, bot e regras.
- `modes/menu/`, `modes/football/`, `modes/shared/`: composição e ciclo da partida.
- `presentation/`: câmera, HUD e feedback.
- `tools/`: geração, captura e validação.
- `tests/`: regressão GUT.

Cenas são geradas por `tools/bootstrap_scene_generator.gd`; não edite `.tscn` gerado como texto. Toda força aplicada à bola passa por `FootballBall3D.kick()`. Ação nova do jogador exige paridade do bot. Input action nova nasce em `autoloads/app_bootstrap.gd`.

## QA

Use `qa/qa_manifest.json` como contrato executável e `qa/QA_INDEX.md` para jornadas e gates. Validação integral:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd -- --profile=full
```

Importe uma worktree nova uma vez com `--headless --editor --quit` antes de interpretar erros de asset. Validadores não podem alterar arquivos rastreados; efeitos colaterais são falha, não motivo para restauração automática.

## Gates humanos

- feel/tuning, câmera, áudio e qualidade visual exigem decisão humana;
- UI interativa exige clique real nas três resoluções contratuais e evidência visual;
- publicação exige autorização e execução de Fabio;
- trabalho técnico verde pode ser integrado antes do gate humano, mas o card permanece em `Review`.

Bugfix reproduzível começa com teste vermelho. Fallback degradante deve emitir `push_error` ou `push_warning`. Assets externos exigem licença registrada antes do uso.

## Hard stops

Pare diante de segredo, remoto/publicação, cena ou binário ambíguo, mudança de produto/prioridade, conflito semântico de história única ou necessidade de decidir gate humano.
