# Dev Lab Workflow Notes

Registro operacional dos problemas corrigidos nos labs do Godot em 2026-05-26.

## Regras Do Runner Godot

- As telas dev-only chamam Deno por `OS.execute`; no Windows, `npx` deve ser resolvido para `npx.cmd` e executado via `cmd.exe /C`.
- Nunca acumular argumentos dinamicos (`generate.ts`, `--request`, `--response`, `--profile`, `--milestone`) dentro de `ProjectSettings`; a tela deve montar esses argumentos a cada chamada.
- `tools/smoke_dev_labs.gd` valida o caminho real do processo dentro do Godot: Battle Lab bridge e Progression Lab generate.

## Battle Lab

- Runs e analytics sao outputs persistentes; replay custom e um resultado de sessao, nao uma run arquivada.
- Mesmo sendo de sessao, replay custom precisa ser visivel: registrar em `_last_replays`, mostrar no History e trocar automaticamente para a aba Replay.
- A barra de velocidade do replay deve mostrar a porcentagem do tempo normal selecionada (`100%`, `250%`, etc.) para deixar claro o ritmo do autoplay.
- Antes de chamar o bridge, limpar o response JSON para evitar leitura de resposta antiga quando algum processo falhar silenciosamente.
- `tools/smoke_dev_lab_ui.gd` cobre o comportamento visual: Builds visivel, replay custom abrindo a aba Replay, History registrando a entrada custom e label de porcentagem na velocidade do replay.

## Progression Lab

- Gerar relatorio nao cria cache de sessao. O cache server-backed nasce do seeder local com `SUPABASE_SERVICE_ROLE_KEY`.
- Para playtest visual sem Supabase, a tela deve conseguir montar um cache local-only a partir de `docs/progression-lab/generated/healthy_saves.json`.
- Esse cache local-only serve para carregar o Refugio/SessionStore e avaliar UI, recursos, base, monetizacao e checklist; acoes online ainda dependem de uma sessao real seeded no Supabase.
- `Carregar Save` deve ser tolerante: se nao houver cache em `.progression_lab_scratch/`, ele gera um cache local-only a partir do healthy save selecionado.

## UI

- Labels dentro de `ScrollContainer` precisam de largura minima/responsiva; sem isso, o texto quebra uma letra por linha.
- Para screenshot visual, rode `tools/smoke_dev_lab_ui.gd` sem `--headless`. Em headless, o smoke valida comportamento mas pula captura por causa do renderer dummy.

## Comandos Uteis

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_dev_labs.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_dev_lab_ui.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_dev_lab_ui.gd
```
