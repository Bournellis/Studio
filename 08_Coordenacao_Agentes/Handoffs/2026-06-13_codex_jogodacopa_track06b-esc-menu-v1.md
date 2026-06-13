# Handoff - JogoDaCopa Track 06B - ESC Menu Completo V1

- Data: `2026-06-13`
- Agente: Codex
- Status: `READY_FOR_REVIEW_PRE_MERGE`
- Branch: `codex/jogodacopa/track06b-esc-menu-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track06b`
- Base: `main` apos merge local da Track 06A (`b585b5d2`) e fechamento (`4f18f2fa`)
- Merge/publicacao: NAO realizados por regra do prompt; parar antes de merge.

## Escopo Fechado

- `GameSettings` autoload com persistencia em `user://jogodacopa_settings.cfg` para volumes, fullscreen, qualidade e sensibilidade.
- Menu ESC completo com abas `Controles`, `Audio`, `Video` e `Sensibilidade`.
- `RenderProfile` ganhou contrato de qualidade `Alta`/`Leve`; `Leve` usa o perfil Web/fallbacks em desktop e Web.
- Menu principal e HUD sincronizam valores salvos; mudancas de qualidade atualizam ambiente, placares/SubViewports e menu imediatamente quando seguro.
- Sensibilidade do mouse passa a persistir e ser aplicada no jogador ao spawn.
- Aviso no menu de video deixa claro que materiais/caches pesados mudam no proximo carregamento.

## Arquivos Principais

- `Projetos/JogoDaCopa/autoloads/game_settings.gd`
- `Projetos/JogoDaCopa/autoloads/render_profile.gd`
- `Projetos/JogoDaCopa/project.godot`
- `Projetos/JogoDaCopa/modes/menu/main_menu_root.gd`
- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/presentation/hud/football_hud.gd`
- `Projetos/JogoDaCopa/tests/unit/test_game_settings.gd`
- `Projetos/JogoDaCopa/tests/unit/test_pause_menu.gd`
- `Projetos/JogoDaCopa/tools/capture_track06b_esc_menu.gd`
- `Projetos/JogoDaCopa/docs/screenshots/track-06b/`

## Evidencias

- Validate completo: PASS, `95` testes, `1512` asserts.
- Web gzip gate: PASS, `30.34 MiB / 50.00 MiB`.
- Source integrity: PASS, `41` arquivos `.gd/.gdshader`.
- Export Web: PASS, `builds/web/index.html`.
- Boot Web local: PASS em navegador local `1280x720`; tela inicial renderizada em canvas, sem tela preta. Console exibiu apenas warnings conhecidos do `RenderProfile`.
- Testes de clique real: `tests/unit/test_pause_menu.gd` cobre menu principal e ESC completo em `1920x1080`, `1366x768` e `1280x720`.
- Capturas: 12 PNGs em `Projetos/JogoDaCopa/docs/screenshots/track-06b/` para Controles/Audio/Video/Sensibilidade nas 3 resolucoes.

Comando principal:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Comando de export:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"
```

## Pendencias Intencionais

- Review visual/subjetivo de Fabio e/ou Claude.
- Merge local em `main` somente apos aprovacao.
- Publicacao Web continua adiada para Track 06E.
- `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
