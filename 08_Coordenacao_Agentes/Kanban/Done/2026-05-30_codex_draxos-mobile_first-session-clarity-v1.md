# DraxosMobile - First Session Clarity v1

- Data: 2026-05-30
- Agente: Codex
- Status: DONE
- Branch: `codex/draxos-mobile/first-session-clarity-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--first-session-clarity-v1`
- Projeto: `Projetos/draxos-mobile/`
- Commit de implementacao: `50d35d2 feat(draxos-mobile): add first session clarity`

## Objetivo

Executar o pacote First Session Clarity v1 para transformar a baseline publicada de Progression Clarity v1 em uma primeira sessao mais clara: entrar, entender o Refugio, coletar, evoluir, preparar, batalhar, receber recompensa e voltar para a base com proximo passo legivel.

## Entregue

- Refugio ganhou dica persistente de primeira sessao dentro de `Progresso`.
- CTA contextual do Refugio agora explica recompensa, coleta, evolucao e batalha como ciclo.
- Preparacao ganhou frase curta para primeira leitura antes do detalhe de loadout.
- Resultado de batalha ganhou `Proximo passo`, conectando recompensa com base e nova batalha.
- Smoke/testes sem rede cobrem recompensa, coleta, evolucao, Preparacao e summary.
- Portal alpha passou a exibir `DraxosMobile Alpha`, alinhando o contrato remoto de release.
- Docs vivos, portfolio, painel visual e status do projeto foram atualizados para `FIRST_SESSION_CLARITY_V1_PUBLISHED`.

## Validacao

```powershell
git diff --check
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_loop.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { .\tools\validate_foundation.ps1 -ProjectDir . -Profile Client -RequireClean:`$false }"
```

Resultado local: PASS. GUT client passou com `123/123` testes e `1990` asserts.

## Publicacao

- Release root: `internal-alpha/v0-first-session-clarity-v1-20260530`
- Portal: `https://f2ead4bd.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web: `https://f2ead4bd.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-first-session-clarity-v1-20260530/downloads/draxos-mobile-alpha.apk`
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-first-session-clarity-v1-20260530/downloads/draxos-mobile-alpha.zip`
- Remote smoke: `server/tests/release_artifacts_remote_smoke.ts` PASS.

## Proximo Handoff

Revisar First Session Clarity v1 em Android/Windows/Web. Se o loop estiver claro, a recomendacao e seguir para Social Routine v1.1; se houver friccao, fazer ajuste pontual de primeira sessao ou um passe visual estreito antes de expandir.
